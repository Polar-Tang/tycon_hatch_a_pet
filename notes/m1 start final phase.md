Hi, it's me again. I been in the same project for about 3 or 4 months. This project is taking my so much time, and i think we are in the **start of the final phase**. I started copying a project of a guy from a roblox file, manually passing all to vs code, re-factorizing it, fall in a circular dependency, solve it with nevermore, full nevermore inclusion, creatin my custom nevermore, improving my anim handler, migrating server side hitboxes to client hitboxes and a lot of crazy new feature with a really solid architecture, what's my goal now? create m1 combats from a single file. I become crazy? probably will do after working 4 months in the same project, but this will be the base for building m1 combat comissions in a few days for money. Let's do it.
I have attack abilities, defense and transformation types, all of them are diferent module scripts, but what if we simply can create this classes from the data? let's take a look at a random ability created for this game:
```lua
function HydroBeam.new(config)
	local self = setmetatable(AttackBaseAbility.new(config), HydroBeam)
  
	return self
end
```
All the attack abilities does the same, another method is :Init 
```lua
function HydroBeam:Init()
	self._animHandler:PreloadAnims({ "HydroBeam" })
	local hitEnd = function(track: AnimationTrack)
		if not self.character:GetAttribute("IsBlocking") then
			self.humanoid.WalkSpeed = 14
			self.humanoid.JumpHeight = 6.5
		end

		self.character:SetAttribute("Attacking", false)
		self.character:SetAttribute("Swing", false)
	end

	self._animHandler:OnSignal({
		callback = hitEnd,
		animationName = "HydroBeam",
		animationEventName = "EndedCon",
	})
end
```
All the other attack abilities do practically the same, only changing the animationName, i guess at this point you may noticed where i aiming to. Look the most important method, Execute()
```lua
function HydroBeam:Execute()
	local CHAR = self.character
	if CHAR:GetAttribute("Attacking") or CHAR:GetAttribute("Swing") or CHAR:GetAttribute("IsTransformed") then
		return
	end

	if self:GetCD() then
		return
	end
	-- start attack
	self:StartCD()
	--Settin attr
	self:SetAttributes()

	self:_countAttack()
	-------------
	local attackId = self:_GenerateAttackID()

	local data = {}
	local animHandler = self._animHandler

	animHandler:LoadAnimation(true, "HydroBeam")
	-- describe more data used fot the effect

	-- Create promise for client detection, detection info sent to client

	local hitFx = function()
	end
    -- use this shit because we got no tha keyframes of the animation, so we can't adding events
	animHandler:OnSignal({
		callback = hitFx,
		animationName = "HydroBeam",
		animationEventName = "Hit",
		override = true,
	})
end
```
What if i tell you all the attacks abilities does practically the same? it only change the data and hitFx. What if we provide all of this as data? we likelly already doing somthing like that
```lua
 
local CharacterInfo = require("CharacterInfo")
local WeaponStats = CharacterInfo:getweapon("Shark")

function Shark:_createAbilities()
	local attackData = WeaponStats["attacks"]

	-- attacks of type Attack and maybe Movement in the future
	self.attacks, self.OnDefended = AbilityBuilder.new(self.char, self._serviceBag)
		:Add(Enum.UserInputType.MouseButton1, "M1", {
			name = "Basic",
			type = "Attack",
			_cooldown = attackData.Basic.cooldown,
			damage = attackData.Basic.damage,
			hitbox_size = attackData.Basic.hitbox_size,
			hitbox_offset = attackData.Basic.hitbox_offset,
			character = self.char,
			_max_combo = attackData.Basic.max_combo,
			stun_time = attackData.Basic.stun_time,
			tool_name = "Shark",
		})
		:Add(Enum.KeyCode.Two, "HydroBeam", {
			name = "HydroBeam",
			type = "Attack",
			_cooldown = attackData.HydroBeam.cooldown,
			damage = attackData.HydroBeam.damage,
			life_time = attackData.HydroBeam.life_time,
			hitbox_size = attackData.HydroBeam.hitbox_size,
			hitbox_offset = attackData.HydroBeam.hitbox_offset,
			stun_time = attackData.HydroBeam.stun_time,
			character = self.char,
			tool_name = "Shark",
			getRightGrip = WeaponStats.RightGrip,
		})
		:Add(Enum.KeyCode.Q, "Dash", {
          -- bla bla bla
```
at this point you were realized that this can be completly optimized. AbilityBuilder is maping the attack to the module script
```lua
function AbilityBuilder:Add(inputKey, abilityName, config: WeaponStats)
	local AbilityClass = require(abilityName)
	-- Get the cooldown controller from service bag to every ability

	config._serviceBag = self._serviceBag
	config.character = self.character
	local newAbility = AbilityClass.new(config)
	self._map[inputKey] = newAbility
	if config.type == "Defense" then
		-- local ability = DefenseAbility.new
		function self.OnDefended()
			newAbility:OnDefended()
		end
	end

	return self
end
```
but we can actually create a new class that inherits attack base ability, then attack base ability do exact all the same hydro beam and practially every attack does, but instead of using raw data use the table data, `attackData = require("CharacterInfo")["Shark"]["attacks"]` then we can go
```lua
for attackName, attackInfo in pairs(attackData)
	AbilityBuilder.new(self.char, self._serviceBag)
	:Add(attackInfo.KeyBing, AttackName, attackInfo)
end
```
`AbilityBuilder` can do something like setMetatable(attackBaseAbility)
and `attackBaseAbility` could use this data, including attackInfo.hitFx to completly automate all of this, i should migrate all the logic to this table and we are done. What do you think?