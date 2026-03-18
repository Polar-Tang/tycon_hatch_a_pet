Please read and analyze the selected code, this method is like MoveTo from /home/nautilus/Documents/games/tycon_farm/src/shared/NPC/Controllers/MovementController/MovementController.luau but it will turn more complex. Considering this method is called at /home/nautilus/Documents/games/tycon_farm/src/myNeverMoreS/PetFollower/src/Client/Machine/States/Following.luau when the player position is updated it start a new path recomputation, is important to distinguish the entire path computation to the player position as an entry point method called MoveTo, that creates a cancellable thread just like promise so we can expose its cancellation as a public method called `ForgetCurrentPath` that can be used in Following.luau at line 21 and this will allow the pet to update the path on the player position being updated and at this method we can `self._AnimationHandler:LoadAnimation(false, "walk")` 
So `MoveTo` can start rotating looking at the goal position using the already existing logic: 
```
local rotateTime = 0.5

        local lookThatShit = CFrame.lookAt(startPos, targetPosition) * CFrame.Angles(0, math.rad(90), 0)
        local rotateTween = TweenService:Create(
            self.hrp,
            TweenInfo.new(rotateTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
            { CFrame = lookThatShit }
        )
        
        local rotationCOmplete = rotateTween.Completed:Once(function(playbackState)
```
This can be `_lookTo` method and it calculates the rotate time using the arc of the angle, assuming 360° will take 2 seconds times, `_lookAt` returns the once connection so we can start the waypoint looping after the rotation is completed and clean it when the following thread has started: **iterate over the waypoints** if the movement to every waypoint is enough smooth we could call `self._AnimationHandler:LoadAnimation(true, "walk")` before the iteration, it's important to iterate over the waypoints so we can decide when to call `_moveToWaypoint(currentWaypoint)`. For this method use the heartbet connection logic at line 170 and we use the calculation time to the end position for disconnecting the current heartbeat by that time as well as to iterate to the next waypoint by the exact time


### Describing the process
First anothers process happens and they create the instance into positioning them into this new place.
#### 1. Use the same function for calculating the Y position 
```lua
module.petGoal = function(playerCharacter: Model, range: number): Vector3
	local player_hrp = playerCharacter.PrimaryPart
	local offset = player_hrp.CFrame.RightVector * range
	local nearPlayer = player_hrp.CFrame + offset
	local _bottomY = player_hrp.Position.Y - (playerCharacter:GetExtentsSize().Y / 2)

	-- Avoid Y offset
	nearPlayer = Vector3.new(nearPlayer.X, _bottomY, nearPlayer.Z)
	return nearPlayer
end
```
Now the calculation to the goal is shared:
When it create the instance
```lua
function CombatControllerClient.createInstances(data: NpcFighterTypes.FightInfo)
	--...
	-- May use some attrbute or smthing to get a custom range per pet
	local nearPlayer = clientUtils.petGoal(Players.LocalPlayer.Character, 3)
end
```
When it calculates the path
```lua
function TargetController._getGoalPos(self: NpcFighterTypes.TargetController): Vector3
	return clientUtils.petGoal(self.player_character, 3)	
end
```
This prevent any mismatch between the calculated goal and the actual position. So far, so good.

### Can't cancell the thread
There are glitches from a position to another different. The glitches occurs because there are many threads attempting to modify the same pet position. I clear the main entry point that moves the pet in `/home/nautilus/Documents/games/tycon_farm/src/myNeverMoreS/PetFollower/src/Client/Machine/States/Following.luau` at line 20
```lua
function Following:OnHeartbeat(data: NpcFighterTypes.petStateCtx, deltaTime)
	data.timer += deltaTime
	if data.timer - data.lastTriggerTime >= 1 then
		local timerPhto = data.timer
		data.lastTriggerTime = timerPhto

		local goalPos = data.TargetController:GetGoal() -- if this return a vector is because is needed to move
		if goalPos then -- we need to move
			data.TargetController:CalculatePath(goalPos):Then(function(path: Path): ...any
				data.MovementController:ForgotPath()
				-- initialize the thread which completes over time
				data.MovementController:MoveTo(path)
			end)
		end
	end
end
```
i though this would disconnect the `_moveToWaypoint` but the connection may still live until the timeReach completes, at the same time the promise where destroyed and a new one is creating new movement connections so now MoveTo looks like:
```lua
self._currentMovePromise = Promise.new(function(resolve, reject)
	self.maid:DoCleaning()
	-- do stuff
	local function moveNext()
	local moveCon = self:_moveToWaypoint(waypoint.Position, function()
				currentIndex += 1
				moveNext()
			end)
	if moveCon then
				self.maid:GiveTask(moveCon)				
			end
end):Finally(function(...): ...any
	self.maid:DoCleaning()
end)
```
#### Update `_lookTo`

Please carefully analyze `_moveToWaypoint`, it's a kinematic function that never moves or tweens the pet directly to the next way point and it uses the position where the pet is when the function is called and simulate the npc movement over time, it disconnects the movement function moveConn when the time is done and calls the next `_moveToWaypoint` when the time is over, then start position has changed and start the connection again. 
We need what auto rotate does to humanoid:MoveTo. My idea is that for every moveCon the petModel look at the current waypoint position he's going to. That's the use case for `_rotate`so `rotate(timer)` takes a timer to lerp the righ fraction over time  now should use PivotTo instead of MoveTo so we handle its rotation. The problem is that i'm attempting to  know when the pet has rotated enough with `isRotated` because rotated needs to stop becaulled once the rotation is completed otherwise it will looks bad, however i'm not sure if the condition is right
```lua
isRotated
```

##### Update, condition:
```lua
-- Δθ=((θ2​−θ1​+π)mod2π)−π
-- angular displacement
local function shortestAngleDiff(a: number, b: number): number
	return (b - a + math.pi) % (2 * math.pi) - math.pi
end

function MovementController._isRotated(self: NpcFighterTypes.MovementController): boolean
	-- Check if orientation difference is meaningless
	local _, O_Y, _ = self.hrp.CFrame:ToEulerAngles(Enum.RotationOrder.XYZ) -- XYZ ANGLES
	local _, Op_Y, _ = self.goalRotation:ToEulerAngles(Enum.RotationOrder.XYZ) -- XYZ ANGLES
	print("O_Y deg", math.deg(O_Y))
	print("Op_Y deg", math.deg(Op_Y))

	local YDiff = math.abs(shortestAngleDiff(O_Y, Op_Y))

	return YDiff < math.rad(5)
end
```

also to avoid rotating once 
and calls `_rotate` to smothly rotates the pet over the movent, the single trouble is that it's happening after every completition, please check that the orientation is already the goal one and if it is take the necessary measures to avoid the current frame to lerp again at startCFrame
I need to adjust how `_rotate` should be called
### Multiple move cons `[bug]`
You may wondering why i do remove self.moveConn and start using maid, that's because i print deltatime and i confirmed they run more than once in some frame, then the variable self.movecon is redefined and some other moveCon may be cleaned, leaving connections without disconnect, to completly avoid that we handle local moveConn and give the task to maid, if there's a single connection per time maid:DoCleaning would cleanly remove it, so that's issue help to not forget any connection without disconnect. That's solved, but there's another issue i didn't aware of: these two conditions happen at the same frame
```lua
local moveConn = RunService.Heartbeat:Connect(function(deltaTime)
	if t >= T then
		self.moveConnsMaid:DoCleaning()
		onComplete()
	end
-- start the new shit
```
to solve this we use task.defer on onComplete calling, however i still see print(dt) x2 sometimes and i wonder why

### Compehend print(dt) x2
Please help me to understand why this happen, rather than you reaching a solution tries to explain why this can occur based in the knowledge in this code.
i still get print(dt) x2 if i defer all the moveNextPoint functionallity like this
```lua
local function moveNext()
			-- Ensure there a single movement connection at a time
			self.moveConnsMaid:DoCleaning()

			-- Start next movement after the last one finishes
			task.defer(function()
			-- do their thing
```
I can't comprehend how this occurs print occurs x2, the only scenario possible where moveNext may be called twice is if current promise is still active but moveTo is called
```lua
local goalPos = data.TargetController:GetGoal()
		if goalPos then
			data.TargetController:CalculatePath(goalPos):Then(function(path: Path): ...any
				data.MovementController:ForgotPath()
				data.MovementController:MoveTo(path)
			end)
		end
```
so i need to ensure the move con is cleaned before the new one starts, to do so the moveTo should clean and the promise should be defered
```lua
function MovementController.MoveTo(self: NpcFighterTypes.MovementController, path: Path)
	self.maid:DoCleaning()
	self._currentMovePromise = Promise.defer(function(resolve, reject)
```
But i still get print(dt) x2 when MoveTo is called during an active MoveTo promise.
### Simulated jump
This mechanism is working great, but there's a problem where the calculation got the movement has Y offset, that's where waypoint.Action == Enum.PathWaypointAction.Jump. `_moveToWaypoint`

-[.] Fist let's check if the waypoint tells you something like (waypoint.HastToJump)
-[.] Create the `_jumpToWaypoint` method

### Path find service sucks!
The calculation for the movement has an y offset
![[Pasted image 20260316141735.png]]
(image where waypoints position are parts and shows elevations that are not Action = Jump)
We may see that he thinks there's ground where actually isn't
![[Pasted image 20260317151643.png]]
(image where navigation link is visible and it draws a tiny mount in a flat ground)
I really wonder how pathfinding determines where how's the ground, as i want to avoid creating a custom pathfinding service, i hope pathfinding works good and the error is likely in my agentParams
```lua
local Path = PathfindingService:CreatePath({
		AgentCanJump = true,
		AgentRadius = 2,
		AgentHeight = 2,
		Costs = {
			-- need to test in different materials
			Snow = math.huge,
			Metal = math.huge,
		},
	})
```
Please help me to understand how pathfinding does work, what the parameters are and use all this knowledge to avoid pathfinding thinking there's ground where isn't

| Key                 | Type    | Default | Description                                                                                                                                                                                                                                                                                                                                      |
| ------------------- | ------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **AgentRadius**     | integer | 2       | Determines the minimum amount of horizontal space required for empty space to be considered traversable.                                                                                                                                                                                                                                         |
| ****AgentHeight**   | integer | 5       | Determines the minimum amount of vertical space required for empty space to be considered traversable.                                                                                                                                                                                                                                           |
| **AgentCanJump**    | boolean | true    | Determines whether jumping during pathfinding is allowed.                                                                                                                                                                                                                                                                                        |
| **AgentCanClimb**   | boolean | false   | Determines whether climbing [TrussParts](https://create.roblox.com/docs/reference/engine/classes/TrussPart) during pathfinding is allowed.                                                                                                                                                                                                       |
| **WaypointSpacing** | number  | 4       | Determines the spacing between intermediate waypoints in path.                                                                                                                                                                                                                                                                                   |
| **Costs**           | table   | {}      | Table of materials or defined [PathfindingModifiers](https://create.roblox.com/docs/reference/engine/classes/PathfindingModifier) and their "cost" for traversal. Useful for making the agent prefer certain materials/regions over others. See [here](https://create.roblox.com/docs/characters/pathfinding#pathfinding-modifiers) for details. |
##### Explore different engine classes
I use your agent params and the of phantom surface stills is happening. I set up a path modifier to the ground (which i repeat is completely flat and path finding is hallucinating non-sense surfaces) and the passThrough seems to be false as default value, when i set it to the ground part pathfinding thinks all the ground cannot be traversed. 
Reading the agent params from other sources, the say
>Agent height, in studs. Empty space smaller than this value, like the space under stairs, will be marked as non-traversable.

That makes me think that if the agentHeight is the same as groundHeight pathfinding may not hallucinate phantom surface, but agen height is actually the character height so i set the model height and i get a really good improvements in the Y positioning. But the phantom surface is still fucking things up. 
Let's see how to get the Y height for a damn model. You have two variables, one should store the lowest part and the other one the highest. Loop through all the model desendantast to filter for these two parts. Once the loop is completed we got the lowest and highest part, now as the position is the center get the top of the highest and the bottom of the lowest by `lowest = part.Size.Y -part.Size.Y/2` and the top of the highest `highest = part.Size.Y +part.Size.Y/2`. Now the sum between the bottom of the lowest part and the top of the highest part is the height
```
 
```
![[Pasted image 20260317205400.png]]

### The battle continues
I'm really struggling trying to compehend why there's a nav mesh that shouldn't be there. This navemesh is created exaclty when the connection begins, that's my single hint i just now that exactly when the compute path begins it thinks the model has a navmesh behind it. i think it may be some kind of corruption for two connections trying to modify the model at the same time but you can see in the logic that the operations for movin the model doesn't have in the same frame, i print the deltatime and i can see from the output logs there's no deltatime print happening at the same millisecond.
```lua
local moveConn = RunService.Heartbeat:Connect(function(deltaTime)
	print(deltaTime)
```
I also wonder if the pathfinder height is wrong and it think the agent is elevated above the ground, the he assumin is above a mesh and arrange this in the other waypoints, then as the agent height is wrong and path finding starts again, it thinks the model is above a navmesh again, that would explain why this is happening every time pathfinding starts, however i tried different height values and the navmesh at the start of pathfinding is still there:
```lua
local Path = PathfindingService:CreatePath({
		AgentCanJump = true,
		AgentRadius = self.pet:GetExtentsSize().X + 2, -- tighter for a small pet
		AgentHeight = 0, -- try 0 or 2 everything failed
		WaypointSpacing = 2, -- tighter spacing = smoother path on uneven ground
		Costs = {
			-- need to test in different materials
			GroundPlastic = 1,
			Snow = math.huge,
			Metal = math.huge,
		},
	})
```
the ground is at level 24.717 and pathfinding starts like
27.8, 27, 27.8
and the model height is 2.0359370708465576
i wonder if it's considering its own body as a navmesh
![[Pasted image 20260318105844.png]]
Is there anyway for telling pathfind to ignore their own parts?
### Solution

1. Using Pathfinding Modifiers  
    While pathfinding modifiers are especially useful for this, they are problematic in some cases. If you want to make a non-humanoid agent that can move around using the pathfinding service, their model will interfere with the navmesh, and generate on their model as if it’s a static object that other agents can navigate on. This can result in pathfinding issues, and is generally not ideal for this usecase.  
    Another place where pathfinding modifiers are problematic is user-placed structures within a game. Specifically in my game, players can place structures virtually anywhere, and in any orientation about the Y axis. In some cases, this can cause the navmesh to generate through solid walls when the structure is placed too close to a wall, or the opposite where the pathfinding modifier gets ignored due to its orientation or otherwise, and makes an area of a map completely inaccessible to pathfinding agents. This usually is caused by the limited resolution of the navmesh generation and the complexity of structure models.
    
2. Turning off CanCollide  
    This is the most straight forward way of making the navmesh ignore a part, but it is not at all ideal in cases where you want it to be ignored but maintain physics collisions. Take the example from earlier of a non-humanoid agent. Obviously an agent/character that can move around will necessitate physics collisions in order to interact with the world, and with players.
    
3. Humanoids  
    A model with a humanoid child will have all its descendants ignored by the navmesh generation regardless of CanCollide, which is very useful in the case of characters that actually use humanoids, but otherwise not ideal for every other case. If you want a single part, or a static model, or whatever else that is not a humanoid to be ignored by the navmesh generation, all the extra weight of the humanoid is a waste and will undoubtedly have a performance cost if you have a lot of these inert humanoids sitting around, even with their state machines turned off.