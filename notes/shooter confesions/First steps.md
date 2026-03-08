### Hitscan
I have heard about **Hitscan** design that can hugely optimize the performance and is totally compatible with my current m1 system. This explanation comes from wikipedia
>weapon, for example, does not launch a projectile the player needs to lead; damage is applied as soon as the player's crosshair is on a target and the fire button is pressed. Internally, this is most commonly done by simulating a ray from the origin of the item along the trajectory of the "projectile" and simply scanning for any objects touching the ray. Games might still show a visual of a projectile although it technically has no effect. In contrast, a projectile-based weapon would launch an actual projectile object that moves through the virtual space at a certain speed and will apply damage only once it has actually touched ("hit") a target.

In a roblox game i think this would look like this 
```
client tells the server want to shot
	|
server creates a task delay
	|
it can compute exaclty where will be the bullet
	|
Can fire back the client to the position the bullet will have
	|
the client renders the bullet going to that position 
```
If there's a delay between the first fire server and when server fires back to client we can us timing to accelerate the bullet and still be 100% trustworthy with server. However i still not sure how the server knows what's hit, it can cast a ray, but i get that the cast ray is done from the 'fire' moment, that's why wikipedia says
>Visually representing the firing effect of a hitscan weapon can be difficult: since the weapon hits its target instantaneously, any bullet or projectile that comes from the weapon is merely a 'ghost', and where it lands may not necessarily represent its actual hit. In particular, a projectile bullet effect will always lag behind the effect of its hit, a problem which can be compounded by Internet [latency](https://en.wikipedia.org/wiki/Latency_\(engineering\) "Latency (engineering)") in [online multiplayer gaming](https://en.wikipedia.org/wiki/Multiplayer_video_game "Multiplayer video game").

So that does mean that i don't need the step of firing back the client, i

### understanding RayCast and shotgun design 
That's right, if the calculus about bullet velocity in the server and client are the same (client uses the ray-cast to render the bullet while the server uses the raycast to know what's hit) then the bullet rendered will be likely accurate and fairly similar to the server bullet (what matters). Also i don't need fire the client back, this may look like:
```
Clients shots
	| 0ms
renders the bullet
	| 0ms
client tells the server want to shot
	| 80ms
it can compute exaclty where will be the bullet (hit scan)
	|
server can fireAllClients to render the bullet but i'm not sure how necesarry is that
```
There could be a small mismatch between the position client and the position that the server thinks the player is (the position from the remote event) and this delay will be bigger as the player latency.
We can use blink libraries to try optimizing the remote events as much as posibles but as shot already reduce the player velocity a lil bit this mismatch will never be too huge
Let's analyze how the roblox template does the ray-casting 
##### Analyzing roblox shooter template
I got a m1 combat system with client side detection, totally driven by promises, now i understand there's no such thing as Promise.delay(int, function print("find the projectile position")). Actually we do a ray-cast and tries to optimize it the most.
Reading a shooter template this is the entry point from the shot method, used by the blasterClient binder, let's analyze it
```lua
function BlasterController:shoot()
	local spread = self.blaster:GetAttribute(Constants.SPREAD_ATTRIBUTE) -- what is spread?
	local raysPerShot = self.blaster:GetAttribute(Constants.RAYS_PER_SHOT_ATTRIBUTE) -- usually one
		local rayRadius = self.blaster:GetAttribute(Constants.RAY_RADIUS_ATTRIBUTE) -- is this like the radious of the bullet

	local now = Workspace:GetServerTimeNow()
	-- uses camera CFrame which server has no access to
	local origin = camera.CFrame
	
	-- No idea how's calculating this direction
	local rayDirections = getRayDirections(origin, raysPerShot, math.rad(spread), now)

	local rayResults = castRays(player, origin.Position, rayDirections, rayRadius)

-- Rather than passing the entire table of rayResults to the server, we'll pass the shot origin and a list of tagged humanoids.
	-- The server will then recalculate the ray directions from the origin and validate the tagged humanoids.
	-- Strings are used for the indices since non-contiguous arrays do not get passed over the network correctly.
	-- (This may be non-contiguous in the case of firing a shotgun, where not all of the rays hit a target)
	local tagged = {}
	local didTag = false
	for index, rayResult in rayResults do
		if rayResult.taggedHumanoid then
			tagged[tostring(index)] = rayResult.taggedHumanoid
			didTag = true
		end
	end

	shootRemote:FireServer(now, self.blaster, origin, tagged)
end
```
I removed fancy snippets of code that are not necessary to understanding the shot logic. We can see these approach has **Client-authoritative hits** i bet it because of rayResults used for tagging hits. Let's analyze their design first and later we can keep an eye on tthe functionas about the raycast calculation as `getRayDirections` or `castRays`. The server does:

```lua
local function onShootEvent(
	player: Player,
	timestamp: number,
	blaster: Tool,
	origin: CFrame,
	tagged: { [string]: Humanoid }
)
	if not validateShootArguments(timestamp, blaster, origin, tagged) then
		return
	end

	-- Validate that the player can make this shot
	if not validateShot(player, timestamp, blaster, origin) then
		return
	end
	
	local spread = blaster:GetAttribute(Constants.SPREAD_ATTRIBUTE)
	local raysPerShot = blaster:GetAttribute(Constants.RAYS_PER_SHOT_ATTRIBUTE)
	local range = blaster:GetAttribute(Constants.RANGE_ATTRIBUTE)
	local rayRadius = blaster:GetAttribute(Constants.RAY_RADIUS_ATTRIBUTE)
	local damage = blaster:GetAttribute(Constants.DAMAGE_ATTRIBUTE)

	-- No needs more remotes evenets to agree because they use the same math
	local spreadAngle = math.rad(spread)
	local rayDirections = getRayDirections(origin, raysPerShot, spreadAngle, timestamp)
	for index, direction in rayDirections do
		rayDirections[index] = direction * range
	end
	-- Raycast against static geometry only
	local rayResults = castRays(player, origin.Position, rayDirections, rayRadius, true)
	for indexString, taggedHumanoid in tagged do
		-- The tagged table contains a client-reported list of the humanoids hit by each of the rays that was fired.
		-- Strings are used for the indices since non-contiguous arrays do not get passed over the network correctly.
		-- (This may be non-contiguous in the case of firing a shotgun, where not all of the rays hit a target)
		-- For each humanoid that the client reports it tagged, we'll validate against the ray that was recast on the server.
		local index = tonumber(indexString)
		if not index then
			continue
		end
		local rayResult = rayResults[index]
		if not rayResults[index] then
			continue
		end
		local rayDirection = rayDirections[index]
		if not rayDirection then
			continue
		end

		-- Validate that the player is able to tag this humanoid based on the server raycast
		if not validateTag(player, taggedHumanoid, origin.Position, rayDirection, rayResult) then
			continue
		end

		rayResult.taggedHumanoid = taggedHumanoid

		-- Align the rayResult position to the tagged humanoid. This is necessary so that when we replicate
		-- this shot to the other clients they don't see lasers going through characters they should be hitting.
		local model = taggedHumanoid:FindFirstAncestorOfClass("Model")
		if model then
			local modelPosition = model:GetPivot().Position
			local distance = (modelPosition - origin.Position).Magnitude
			rayResult.position = origin.Position + rayDirection.Unit * distance
		end

		if taggedHumanoid.Health <= 0 then
			continue
		end

		-- Apply damage and fire any relevant events
		taggedHumanoid:TakeDamage(damage)
		taggedEvent:Fire(player, taggedHumanoid, damage)

		if taggedHumanoid.Health <= 0 then
			eliminatedEvent:Fire(player, taggedHumanoid, damage)
		end
	end
```
They loop in tagged which's the hits reported by the client, do some kind of valitaion but i don't get the model pivoting about the end. 

### Implement client authoritive hit in current m1-system

```lua
local function getRayDirections(origin: CFrame, numberOfRays: number, spreadAngle: number, seed: number): { Vector3 }
	-- Random seeds are ints. Since we'll generally be passing in a timestamp as the seed,
	-- we need to multiply it to make sure it isn't the same for an entire second.
	local random = Random.new(seed * 100_000)
	local rays = {}

	for _ = 1, numberOfRays do
		local roll = random:NextNumber() * math.pi * 2
		local pitch = random:NextNumber() * spreadAngle

		local rayCFrame = origin * CFrame.Angles(0, 0, roll) * CFrame.Angles(pitch, 0, 0)
		table.insert(rays, rayCFrame.LookVector)
	end

	return rays
end
```
```lua
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Blaster.Constants)
local canPlayerDamageHumanoid = require(ReplicatedStorage.Blaster.Utility.canPlayerDamageHumanoid)

export type RayResult = {
	taggedHumanoid: Humanoid?,
	position: Vector3,
	normal: Vector3,
	instance: Instance?,
}

local function castRays(
	player: Player,
	position: Vector3,
	directions: { Vector3 },
	radius: number,
	staticOnly: boolean?
): { RayResult }
	local exclude = CollectionService:GetTagged(Constants.RAY_EXCLUDE_TAG)

	if staticOnly then
		local nonStatic = CollectionService:GetTagged(Constants.NON_STATIC_TAG)
		-- Append nonStatic to exclude
		table.move(nonStatic, 1, #nonStatic, #exclude + 1, exclude)
	end

	-- Always include the player's character in the exclude list
	if player.Character then
		table.insert(exclude, player.Character)
	end

	local collisionGroup = nil

	-- If the player is on a team, use that team's collision group to ensure the ray passes through
	-- characters and forcefields on that team.
	if player.Team and not player.Neutral then
		collisionGroup = player.Team.Name
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	params.FilterDescendantsInstances = exclude
	if collisionGroup then
		params.CollisionGroup = collisionGroup
	end

	local rayResults = {}

	for _, direction in directions do
		-- In order to provide a simple form of bullet magnetism, we use spherecasts with a small radius instead of raycasts.
		-- This allows closely grazing shots to register as hits, making blasters feel a bit more accurate and improving the 'game feel'.
		local raycastResult = Workspace:Spherecast(position, radius, direction, params)
		local rayResult: RayResult = {
			position = position + direction,
			normal = direction.Unit,
		}

		if raycastResult then
			rayResult.position = raycastResult.Position
			rayResult.normal = raycastResult.Normal
			rayResult.instance = raycastResult.Instance

			local humanoid = raycastResult.Instance.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid and canPlayerDamageHumanoid(player, humanoid) then
				rayResult.taggedHumanoid = humanoid
			end
		end

		table.insert(rayResults, rayResult)
	end

	return rayResults
end

return castRays

```
Here many methods can be useful, however i find the networking communication quite weird. It sends arguments like `now` and backend uses this time stamp for the raycast meanwhile 
```lua
local rayDirections = getRayDirections(origin, raysPerShot, spreadAngle, timestamp)

local rayResults = castRays(player, origin.Position, rayDirections, rayRadius, true)
```
Server validate the position before
```lua
local pivot = character:GetPivot()
local characterOffset = pivot.Position - position
local characterDistance = characterOffset.Magnitude
local rayDistance = (position - rayResult.position).Magnitude
```
In my m1 system however will look like
```
client asks server to shot
|
server validates first
|
then cast a raycast (hit scan, every passes in the server no need validation)
use kinematics equation to know when to apply effect
|
instantly fires client to animate the bull using align position (perfectly arbitry and aligned with server)
|
server only has created a raycast, a promise (which holds the effect) and fires the client
```