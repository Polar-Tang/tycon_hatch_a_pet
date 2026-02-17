****
I'm developing my own combat system that is totally data-driven, all the functionallity is intended to work with some provided data as well as some callbacks. The defenseAbilities are different thoug, this kind of attacks have an active state, during that amount of time the abiliti is listed in the character context
```lua
-- When a character/weapon is attacked, it calls this method to know if the damage is porcessed, reduce, conuter, dropped or whatever
function Weapon:OnIncomingAttack(context)
	-- Context should be modified through the chain, and the last in the change is TakeHit
	self:OnDefend(context)
end

function Weapon:OnDefend(context)
	-- Chain of Responsibility pattern
	local modifiedContext = context
	-- For the moment, the hit part always will be a torso
	context.HitPart = self.torso

	for _, description in ipairs(self._defenseChain) do
		local modifier = description.modifier
		if not modifier then
			return
		end
		modifiedContext = modifier:Process(modifiedContext)
		-- If a modifier blocks completely, stop the chain
		if modifiedContext.blocked then
			return
		end
	end

	self:TakeHit(modifiedContext)
end

function Weapon:TakeHit(context)
	context.anchorState = self._character_state
	-- all the effect that the ability can cause happens here
	EffectService:Apply(context)
end
```
Now the defense abilities share all the same class, only changing the data and some callbacks, most of this data come as a parameter
```lua
function DefenseAbility:Execute(params)
	local CHAR = self.character
	if CHAR:GetAttribute("Attacking") or CHAR:GetAttribute("Swing") or CHAR:GetAttribute("IsDefending") then
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

	local animHandler = self._animHandler

	local animName = params.get_anim_name and params.get_anim_name() or self._animName
	animHandler:LoadAnimation(true, animName)

	params:_execute()
	error("This method should be override by child class")
end

-- link the handler to the chain, should be called in every :Execute()
function DefenseAbility:Activate()
	self.isActive = true

	self._weaponHandler:SetActiveDefense(self)
end

function DefenseAbility:Process(context)
	-- TODO: [probably need to use observer ass soon as i figure out how to use quenty observer]
	--this is nasty but we may change it later
	local WeaponStats = CharacterInfo:getweapon("Shark")
	local attackData = WeaponStats["attacks"]
	local attProcess = attackData[self.keyCode]

	attProcess._process(self, context)
end
```
I always think that the responsability chain for the defense abilities can be a observer:Pipe, am i right?


Okay, your code is nice and does perfectly align to my orignial idea
```lua
function Weapon:OnIncomingAttack(hitData) -- The attack send hitData to the defender and calls Weapon which is a binder for the defender, the defender checks if there's already a defense mechanism still active by calling Weapon:OnIncomingAttack(hitData)

self._weaponDefense:ProcessAttack(hitData) -- your WeaponDefenseSystem

end
```
Now the hit data travels along the modifiers
```lua
-- single responsability chain
	for _, defenseObs in ipairs(defenseObservables) do
        contextObservable = contextObservable:Pipe({
            Rx.switchMap(function(ctx)

                -- If already blocked, skip
                if ctx.blocked then
                    return Rx.of(ctx) -- EMIT AN OBSERVABLE OF THAT ITEM
                end
                
                -- Apply this defense
                return defenseObs:Pipe({
                    Rx.map(function(defenseData)
                        return defenseData:Process(ctx)
                    end),
                    Rx.take(1)
                })
            end)
        })
    end
```
But i wonder what thing should my defenseAbilities returns? i simply returning the same raw table that's ctx, but i get this error when Suscribe is fired:
```lua
	defenseChain:Subscribe(function(finalContext)
		if finalContext.blocked then -- ReplicatedStorage.Nevermore.Custom.characters.src.Server.Utils.WeaponDefenseSystem:73: attempt to index nil with 'blocked'
            
        end
        self._weapon:TakeHit(finalContext)
    end)
```

I'm not sure how this works but it uses tap, and "Taps into the observable and executes the onFire/onError/onComplete commands." does that mean that i can stop the chain with onFire/onError/onComplete commands? anyway hit data becomes ctx and i think here comes your misconception about this system usage
```
 --|| DEFENSE CHAIN ||--
    local defenseChain = self:ObserveIncomingAttacks():Pipe({
        -- Process through each defense
        Rx.switchMap(function(ctx)
            print("ctx ", ctx)
            return self:_applyDefenseChain(ctx, defenseObservables)
        end),
        
        Rx.take(1) -- Only process this one attack
    })
```
Also i will commit things that i think you are not aware of

```lua
function WeaponDefenseSystem:_applyDefenseChain(context, defenseObservables)
    local contextObservable = Rx.of(context) -- the first context is just a table with data, so what is this now?
    
    for _, defenseObs in ipairs(defenseObservables) do
        contextObservable = contextObservable:Pipe({ 
            Rx.switchMap(function(ctx) -- i guess this unwrapp the context value, but i don't see this code executing
                if ctx.blocked then
                    return Rx.of(ctx) -- EMIT AN OBSERVABLE OF THAT ITEM
                end
                
                -- Apply this defense
                return defenseObs:Pipe({
                    Rx.map(function(defenseData)
                        return defenseData:Process(ctx)
                    end),
                    Rx.take(1)
                })
            end)
        })
    end
    
    return contextObservable
end 
```


Actually i would like to completly interrumpt the chain after blocking, cancelling the Pipe, the idea for filtering the denfense type by its priority is to avoid keep processing when the damage is completly block. For example, the character has two defenses, PERFECT_BLOCK and DAMAGE_REDUCTION

`PERFECT_BLOCK -> DAMAGE_REDUCTION`

As the defenses are sorted by its priority, the chain will need to stop there instead of keep processing and ignoring the damage on Suscribe. How could we do that? we need to analyze _applyDefenseChain to make this truly a responsability chain pattern (the modifier may stop de process)

In theory we are already doing that by Rx.of, right? before answer reads this definition "create an Observable that emits a particular item" and define what "emits" means, emits means to trigger suscribe inmediatly? in that case we are already stoping the chain with this.
