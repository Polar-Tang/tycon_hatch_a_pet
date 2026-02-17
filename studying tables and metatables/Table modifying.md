I agree with you. Callbacks can be called passing self as an argument. However i must insist that luau is incredibly weird for handling variables, i'm not sure when a varible is passed as a reference or as value. My hipothesis is that data mutation is happening to the table that should be statis. You give me an idea: `Never register engine callbacks (animation, heartbeat, touched) inside execution paths.`, instead of registering the callbacks and trying to injecting in the self i want to use it as Execute params

```
local attackData = WeaponStats["attacks"]

	for _, spec in pairs(attackData) do
		local data = table.clone(spec)
		if spec.config.type == "Defense" then
			skill = DefenseBaseAbility.new(data)
local key = spec.config.keyCode or spec.config.key
		self.attacks[key] = skill
		skill:Init()
		self._maid:GiveTask(skill)
```

I will use this instead:

```
for _, spec in pairs(attackData) do

		local data = table.clone(spec.config)
		data.character = self.char
		data._serviceBag = self._serviceBag

		local skill
		if data.type == "Defense" then
			skill = DefenseBaseAbility.new(data)
		elseif data.type == "Attack" then
			skill = AttackBaseAbility.new(data)
		elseif data.type == "Others" then
			skill = MovementAbility.new(data)
		else
			print("unknown ability ", spec)
			continue
		end
		local key = data.keyCode or data.key
		self.attacks[key] = skill
		skill:Init()
		self._maid:GiveTask(skill)
	end
```

And i changed WeaponStats["attacks"] to having enumItems as keys, now is posible to do

```
-- weapon attacks
	m1 = m1,

		[Enum.KeyCode.One.Name] = AquaBurst,
		[Enum.KeyCode.Two.Name] = HydroBeam,
		[Enum.KeyCode.Three.Name] = SharkFrenzy,
		--------- Counter attack ---------
		[Enum.KeyCode.Four.Name] = AquaCounter,
```

```
function Shark:Execute(action: EnumItem) -- adding the params fron the frontend later
	local attackData = WeaponStats["attacks"]
	local attack_data = attackData[action.Name]
	print("attack ", attack_data)
	print("self.attacks ", self.attacks)
	print("self.attacks[action.Name] ", self.attacks[action.Name])
	if not self.attacks[action.Name] then
		return
	end

	self.attacks[action.Name]:Execute(attack_data)
end
```

However the super lag from exhausted execution still exists, but the good part is that i have confirmed my hypothesis that the static table with the data is mutating, see the prints:

```
10:29:23.022  attack   ▶ {...}  -  Server - Shark:53
  10:29:23.215  self.attacks   ▶ {...}  -  Server - Shark:54
  10:29:26.840  self.attacks[action.Name]   ▶ {...}  -  Server - Shark:55
  10:29:56.271  attack  nil  -  Server - Shark:53 -- becomes nill
  10:29:56.514  self.attacks   ▶ {...}  -  Server - Shark:54
  10:30:00.833  self.attacks[action.Name]  ni
```

### solution:
uses table.clone
```lua
function Shark:Execute(action: EnumItem) -- adding the params fron the frontend later

local attackData = WeaponStats["attacks"]

local attack_data = table.clone(attackData[action.Name])

print("attack ", attack_data)

if not self.attacks[action.Name] then

return

end

  

self.attacks[action.Name]:Execute(attack_data)

end
```