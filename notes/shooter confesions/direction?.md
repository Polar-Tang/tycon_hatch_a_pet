I got a m1 combat system with client side detection, totatlly by promises
I have heard about **Hitscan** design that can hugely optimize the performance and is totally compatible with my current m1 system. Reading a shooter template for roblox which's basically a binder from the client side and this is the main entry point function for shooting
```lua
function BlasterController:shoot()
	local spread = self.blaster:GetAttribute(Constants.SPREAD_ATTRIBUTE)
	local raysPerShot = self.blaster:GetAttribute(Constants.RAYS_PER_SHOT_ATTRIBUTE)
	local range = self.blaster:GetAttribute(Constants.RANGE_ATTRIBUTE)
	local rayRadius = self.blaster:GetAttribute(Constants.RAY_RADIUS_ATTRIBUTE)

	self.viewModelController:playShootAnimation()
	self.characterAnimationController:playShootAnimation()
	self:recoil()

	self.ammo -= 1

	self.guiController:setAmmo(self.ammo)

	local now = Workspace:GetServerTimeNow()
	local origin = camera.CFrame

	local rayDirections = getRayDirections(origin, raysPerShot, math.rad(spread), now)
	for index, direction in rayDirections do
		rayDirections[index] = direction * range
	end

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

	if didTag then
		self.guiController:showHitmarker()
	end

	shootRemote:FireServer(now, self.blaster, origin, tagged)

	local muzzlePosition = self.viewModelController:getMuzzlePosition()
	drawRayResults(muzzlePosition, rayResults)

	-- fire haptic
	self.shootHaptic:Play()
end
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