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

also to avoid rotating once 
and calls `_rotate` to smothly rotates the pet over the movent, the single trouble is that it's happening after every completition, please check that the orientation is already the goal one and if it is take the necessary measures to avoid the current frame to lerp again at startCFrame
I need to adjust how `_rotate` should be called
 

The calculation for the movement has an y offset
![[Pasted image 20260316141735.png]]