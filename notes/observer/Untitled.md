How do you do an action every second? after 5 minutes i would do something like this:
```lua
local money_con = RunService.Heartbeat:Connect(function(dt: number)
		self._timer += dt

		if self._timer - self._last_timer >= 1 then
			self._last_timer = self._timer
			self:setRegisterTime()
			local moneyGenerated = money_cb()
			self.cash += moneyGenerated
		end
	end)
```
If we have this conection per player, let's say 16 player, we have 16 run service conection just for updating the cash player. However i've just realized i could do this:
```lua
local thread
	thread = function()
		task.delay(1, function()
			local moneyGenerated = money_cb()
			self.cash += moneyGenerated
			thread()
		end)
	end

	thread()
```
This seems simple but it completely avoids a runservice connection that may be unnecesary at all.
What could be

All my chain of though may be wrong because i'm not understanding cameraRecoiler does work and how it accumulates after many shots, if my idea is not posible explain why and if it's possible explain why and start the implementation.
#### My idea
To track the player cframe it's okay, however the boolean playerRotatedCamera is always false. I wonder this: We need to define self._recoilRestoreCFrame  as the last camera cframe which wasn't rotated by recoil but by the player. So what we need is to check if the camera was rotated by recoil or player, if the last camera that was rotated by the player is defined as self._recoilRestoreCFrame, then we can tween to the last camera position changed by the player in the `_restoreRecoil` method. In summary we need to know if the camera was changed by recoiler or the player, if the camera was changed by the player we declare it in _recoilRestoreCFrame. This is how i think we know this: We need to know the goal cframe of the recoil in the current shot, we declare that variable, if in the next shot the camera position is such variable it means player didn't rotate the camera by himself. Please  explain what CameraRecoiler.recoil(recoil) is doing. Can it return the CFrame the player will have? if it's calculable we can check if the current player camera is what we previouse guess would be by recoild, then player has not moved the camera by itself. 