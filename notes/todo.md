### [Pet Family]
#### Friday
-[.] Using pet rarities
-[.] Refactorize PetData
#### Saturday
-[.] Refactor progressBar for using custon progresion by props
-[.] Tape video
#### Sunday
-[.] All the rigs avaible with no bugs
### monday
-[.] Egg got a proximity prompt to call a remote
-[.] Calling Egg:Hatch through a remote event
-[.] Use cooldown utility to get the time to create a pet in server Time, 
#### monday-thursday
-[.] Animation#1 do a for in pet same category to render different posible pets. 
-[.] Animation#2 do a vfx trasure probably from the Egg:Hatch, create pet from server
-[] Rotates pet randomly
-[.] Adding the new eggs
-[] Finish

# [Pet Family] task release
This task update the egg rng, assign pet rarity and classification to 16 different pets and create an animation for hatching. The game is avaible in [the experience](https://www.roblox.com/games/80420751886453/Raise-and-hatch) please remember to request any change you like
## **Description**
You can acquire 6 different egg categories from store, the luck and randomness is what decides the pet you get
## Features
- Eggs have proximity prompt
- 8 new pets were added
- There's a tween that display 5 differents pets from the egg category (categories like legendary (2-3 pets) and rare (3-4 pets) with less than 5 pets will repeat some)
- Here's a list of which pets come from the eggs (pet's not avaible in game are prefixed by '--')
	Red (carnivore) = {
		"Gorilla", "Fox" (common)
		"Cat" (rare)
		--"Parrot"
		"Dog", "Bear", "Wolf" (epic)
		--"Tiger" (legendary)
		"Lion" (legendary)
	},
	Green (herbivore) = {
		--"Elk" (common)
        "Turtle", "Alpaca" (common)
		--"Bunny" (rare)
        "Elephant", "Panda" (rare)
        "Pig", "Giraffe", "Bull" (epic)
        "Rhino" (legendary)
	},
    White (common) = {
		"Turtle",
		"Alpaca",
		-- "Elk",
		"Gorilla",
		"Fox",
	},
	Blue (rare) = {
		-- "Bunny",
		"Elephant",
		"Panda",
		"Cat",
	},
	Purple (epic) = {
		"Pig",
		"Giraffe",
		"Bull",
		-- "Parrot",
		"Dog",
		"Bear",
		"Wolf",
	},
	Orange (legendary) = {
		"Rhino",
		"Lion",
		-- "Tiger",
	},

# Pet Duel

We may need a vfx for 

Combat Pets

### New task requirements
Currently we implement a handler for the duels between pets src/server/Pets/Pet/Combat/CombatController.luau. You can read further and discover the combat sessions are created in client too, besides the pet models + statemachine, everything does exists only in the client `src/myNeverMoreS/PetFollower/src/Client`, meanwhile it reads the NumberValues created in the replicated storage, but only server writes them. Currently all the attacks does come from src/myNeverMoreS/PetFollower/src/Client/Machine/States/Combat.luau but we need to change that. This is the task [Duel pets] and every attack will be turn based and fired by the server. When we create a session we need to register how much pets do the player have, every pet will have an interval to attack, this plus the boss will create a total time per round, for example every pet got an attack with some duration, there are 3 pets (pet1- 3s, pet2 -2s, pet3 - 3s) and a boss (4s) so every round will last 12 seconds, however this will not be a fixed amount of time. There's a pool of attack per pet they got an special attack an a basic one, anyways there should not be any coupling, we decide which attack and we can read the attack duration from it. The server will tell when to attack and Combat only listen to this event and play the vfx + animations, the only inconvinient is we need to change the health listener a little bit because it requires syncronization between the animation event and the Health subtraction.
Summary:
- We need to change Server.CombatController to initialize multiple pets per player (cap of 3)
- The combat init the pets in a given order determined by ReplicatedStorage.RemoteEvents.BossRemoteEvent petMediator:237
- Client.States.Combat will listen to a client event instead of using heartbeat
- Every pet will have specific abilities attacks that comes from a table similar how src/server/Pets/Pet/PetBonuses.luau does.
- For the moment we don't have any vfx so the client won't notice if the special attack is running, so we will use our RemoteEvent for sending a text saying they are doing their attack
- We need to create a new complex method for src/server/Pets/Pet/Combat/FightSessionHandler.luau
	- Every round 
		it should loop trhough their pets in a given order (start players pets and boss last to finnish the round) 
		check if pet is alive, 
		Starting by a method that selects an attack from the pet attacks pool depending on wether the other pets have casted their special abilities (1st pet cast their special ability, next round 2nd pet and so on)
			uses the pool attacks data to fire the remote event and subtract the damage, this is multiplied by the Melee stat of the pet
			wait the time from the pool PetAttacks[petName].basicAttack.duration to call the next pet ability
		boss attack but checks FightSessionHandler.defense, some special abilities of the pets create a defensive attack (damage reduction, some kind of weird vfx that will block the damage)
		Every pet should have a registry of buffs and debuffs effects registered during combat, play their effect
	rounds do trigger until the health boss is 0 or lower or not pet player stays alive, when this condition happens the combat ends
	

# [Duel pets] — turn-based combat $170
A Combat system totally driven by server but render by client (0% server overload, 100% performance and secure)
### How player starts a combat?
The player will not simply 'start a combat session', they will **strategically put together their team**. First the player will select the pets he wants to fight the boss with (up to **3 pets**). Then when he teloports to boss zone with their team following them (currently we only can start a combat session with a single pet) so when the combat starts the pets will attack in the order they were selected.
Player pets go first; the **boss attacks last** to close the round.
### The combat
Every pet got an special attack and a basic one they will do when special attack is on cooldown
The first pet selected starts the battle with its **special attack**; in the second round, the second pet will use its special attack; in the third round, the third pet will do the same, and the cycle repeats until the boss is defeated or no pets remain. If there are two pets, the cycle is limited to two rounds; if there is only one pet, it will always use its special attack.
There are three types of special attacks, 
- Instant, plays effect instatly (Tiger bleeds, debuffs apply at the end of turn)
- Defensive, Long live effect during the combat session (Lion buff, it applies on the next round)
- Trap, Only triggers when the boss attack (Fox decoy ability, Gorila)
### Ready for vfrx
No VFX exist yet, so the player can't visually distinguish a special attack. Instead there will be a displaying text leting you know when this occurs
**Deadline**: I have everything to start, i will wait for you to cofirm and the task will deliver in 1-2 weeks


i've been testing your new combat rounds and its incredibely, it's really impresive. As there are no errors we can jump directly to refactorizations. We can divide the specific logic for each pet to a generalized class, so we split the logic between fightSessions and pet combat handler, but their names will be in CamelCase because they are public methods:
PetBase
- TickEffects _tickEffects
- CastAttack _castAttack
PlayerPet
- ApplySpecial _applySpecial
Boss
- RunTraps _runTraps
This is due it's a little more clean in order to managing the internal damage/health/etc for each pet, also because every pet (PetBase) should have their own _buff and _debuff field. Also we should ask to the Pet class what damage would it be acordingly to heir internal state (buff, debuffs, some defense that reduce damage which is private to the pet) so i would cast the attack for the pet, return their value and call to :Apply to target, i imagine something like this:
local damage, targets = self.petControllers[petName]:CastAttack

for _, petController in ipairs(targets) then
	petController:Apply(damage)

	CombatTurn:FireClient(self.player, {
		band = attacker.band,
		attackId = isSpecial and "specialAttack" or "basicAttack",
		animation = attack.animation,
		isSpecial = isSpecial or false,
		text = (attacker.petName or attacker.id) .. " " .. (attack.text or ""),
		damage = damage,
		token = token,
	} :: NpcFighterTypes.CombatTurnData)
end


### Ver como seleccionar varios pet ids (desde la UI) y llevarlos al combate
~We should fire NPCFighter and call to CombatController.startRounds exaclty when all the pets are arranged (currently is fired when the first pet reach the position) to their position at BossCombatCon bindable event, from CombatCon but as this may fire for every pet with should register them keyed through its band and confirm the fight when all the pets are arrange. :MoveTo(path):Then is waiting to the pet to reach their final position. Also the goal position for each pet should be acordingly to their band, and i will add parts like, fightPos_[bossname]_[playerBand] and then rotates the pet to look at the boss like is already doing with `data.MovementController:LookTo(data.enemy_hrp.Position)`~

~src/client/RoactApp/Context/PromptContext/PromptProvider.luau uses the server to fire back the client with the npc data for creating the proximityPrompt, but sometimes data.npc PromptProvider:78, will be nil if this npc only lives in the client. Create a registry from the client and local npc = data.npc or registry[data.id].npc~

~Currently src/myNeverMoreS/PetFollower/src/Client/Machine/Controllers/TargetController.luau get the goal position of the pet which is sliglty to their right. We need to update TargetController to be aware of their pet ban, 
if pet band is 1 should be calulated as it is, `player_hrp.CFrame.RightVector * range` right
pet band 2 the pet should go to the left side `player_hrp.CFrame.RightVector * -range` left
pet band 3 it should be at players back `player_hrp.CFrame.LookVector * range` backwards
I'm not sure if i misstyped the CFrame calculations but it should align with i told you. Additionally if you can a little extra offset by the pet magnitud it would be great~

~Alright, now i just updated StarterGui.ScreenGui.PetScreen.PetDetails (this is the container)
It can contains at least 3 StarterGui.ScreenGui.PetScreen.PetDetails.PetDetails which is now the sign that contains all the information about the pet. Please update src/client/facade/petDetails.luau to this structure as well as update their method to be capable of stacking 3 different pet details. also update their client consumer src/client/facade/Index/init.luau:223 and allowing a stacking. You can use the stack and change the petDetails text to something like "goes first", "goes second", and so, If i order them by name they will be order alphabetically so StarterGui.ScreenGui.PetScreen.PetDetails[Name] its important for the stack~

### Ver de crear los efectos de todas las pets

This is the last feature for Duel Pet and is meant to write the special abilities. Every ability is meant to be merely maths regarding the fight. There are many features we need to add. First let's talk about the boss attack. We probably need a specialized class that inherits from PetBase by polymorphism.
There are 4 bosses, they a refered by keys
x-rhino
goaterberus
ghidra
croakan
all of them will have the same ability but for the moment they can be different tables as it should be easy to create different abilities for each boss in the future. There will be a pool of 3 abilities per boss
- Debuff to all player pets (damage ruction during 2 rounds)
- A hit single target, choosing the pet with lower health
- Damage to all pets

Two attacks are AOE that's why i've told you to CastAttack return targets, but as we need to damage all the player pets i don't know if would be necessary to pass the session data to, also we may need a method to choose the player pet wiht lower health we may need a dedicated method for that. Additionally CastAttack should be able to modify the target class besides dealing damage, how can we do that? That's not all because sometimes we may wanna render a text different from a number at ReplicatedStorage.RemoteEvents.TextFade event
the last thing i wanna remark is that debug and buffs will also set an attribute to health, as frontend is reading this attribute then would be easy to render some icon or something pointing out this buff

#### Refactorize this shit.
Before adding new features i prefer refactorizing this in order to make them more readable.
Looking at the PetAttacks table i do wonder if would be better to have the following structure:
PetAttacks: {[petNames] : {
	specialAttack = function(ctx, parentSession) - void,
	basicAttack = function(ctx, parentSession) - void,
}}
ctx will be a type PlayerPet or Boss and parentSession will be the figth session handler
Also i would add an init method for the PetClass and get their attack of the table once
```
for index, petInfo in ipairs(data.player_pets) do
		local band = "PlayerPet" .. index
		local healthValue = FightSessionHandler._createFighterFolder(self._folderSession, band, petInfo.petId, petInfo.healthVal)
		local pet = PlayerPet.new(self, {...})
		table.insert(self.pets, pet)
		self._byBand[band] = pet

		-- look this:
		local petAttacks = table.clone(PetAttacks[petInfo.petName])
		for attackName, attack in petAttacks do
			petAttacks[attackName] = attack
		end
	end
```
Then you do pet:SpecialAttack, otherwise pet:BasicAttack -- more idiomatic + easy to read
Next, before adding new pet abilities, please let's refactorize the boss attacks, instead of doing complex tables you can do most of the logic inside the ability cb and it only takes to arguments `pet:SpecialAttack(self) -- self (playerPet) and the fightSession handler which is calling it` from those arguments you will have enough context and you can do probably everything you need. Also update types. Boss is still very different but as we are using them in _castTurn we can refactorize them too

#### Passive effects
Okay that was an amazing work, we may need to cast a pasive ability which basically will be 
pet:TickEffects(self) -- called from fight session handler 
add the following ones, for each prints an alert at the very begging of the combat with their passive effect names but also set an attribute to its health for each pet using effect name as id

Dog
Passive: Loyalty Boost – Increases all stats slightly for the team
-- increase all the playerPets health of the session and increase meelestat by a quarter self.meelestat += self.meelestat/0.25
-- but only once (not heal) 
Lion
Passive: King’s Strength – Deals consistent high damage
-- increase melee stat self.meelestat += self.meelestat/0.75
-- but only once (not heal) 

Tiger
Passive: Predator Instinct – Increased critical hit chance and damage
-- do the same, increase melee stat self.meelestat += self.meelestat/0.75
-- but only once (not heal) 

Bear
Passive: Regeneration – Slowly restores health during battle
-- When tick effects by the end of turn health its life a 15% of its max value

Gorilla
Passive: Unshaken – Reduces effects of stuns and knockbacks
-- Only do the alerts for now

Wolf
Passive: Blood Hunt – Damage increases the longer the battle lasts
-- increase melee stat on turn end self.meelestat += self.meelestat/0.1

Bull
Passive: Armor Break – Attacks reduce enemy defense
-- Boss debuff, reduces health

Fox
Passive: Evasion – Chance to dodge incoming attacks
-- probably will need to add an extra field to Apply that is called if not nil

Rhino
Passive: Thick Hide – Reduces incoming damage and increases resistance while attacking
-- probably will need to add an extra field to Apply that is called if not nil


### Special abilities
Let's add this special attacks, probably need to add new changes, like a defense, a factor that reduce the damge on aplly a little bit, if this value is lower than zero it increases the damage. Also it would be hard to behaviour by data so we can create a table for buffs and debuffs using their names as keys, and call them just like we are already doing with pet abilities. This table will useful for avoiding a complex data-to-behaviour table as well as save a reference to a text and icon given a debuff name. Add all the debuffs/buffs to that table and may use a key to know if its buff or debuf. This table should be in replicated storage, probably at src/shared/Pets/Fights. When i say debuff is to their target (however it will always be the boss) and buff are only to their abilities, inscrease all are buff for all the petPlayers
Dog
Active: Rally – At the start of battle, boosts damage and defense for a short time
-- increase all the playerPets health by a quarter and meelestat by a quarter for the next turn

Lion
Active: Alpha Roar – Periodically increases team damage
-- increase all the playerPets health by a quarter a 15% every time it runs, you can use Outgoing

Tiger
Active: Pounce Strike – Deals high burst damage and applies bleed
-- Debuf: Deal a damage base like 200 * meleestats, use a debuff that reduce the target life a 20% of that damage , duration : 2 turns

Bear
Active: Rage Mode – Reduces incoming damage and increases attack
-- Buff: Reduce damage by a 20% of its own health, duration : 2 turns
-- Buff: Increase damage by a 20% of their melee stat, duration : 2 turns

Bull
Active: Stampede – Charges forward dealing heavy damage and lowering defense
-- Debuf: Deal a damage base like 300 * meleestats, use a debuff that reduce the defense field of boss, duration : 2 turns

Wolf
Active: Pack Frenzy – Increases attack speed and damage for a short time
-- there's no stat like attack speed, just buff its damage
buff: Increase its damage 50% the next turn, duration: 1 turns

Rhino
Active: Rampage Charge – Charges forward, dealing massive damage and breaking enemy defenses
-- Debuf: Deal a damage base like 300 * meleestats, use a debuff that reduce the target life a 5% of that damage , duration : 2 turns

Fox
Active: Clone Trick – Creates a decoy that distracts the boss
-- When fox is attacked the attack is completly blocked

Gorilla
Active: Ground Slam – Stuns the boss and interrupts attacks
-- This is the only trap for now activated by runTraps, it complatly avoids the boss attack

### [Duel Pet] Task realease
This task brings a new logic for combats, an improved logic that make the combat system way more sophisticated. Every pet now has 
- health (stats of full health, if a pet dies it cannot attack) 
- melee (stats for incresing the damage)
- defense/armor (not a stat, but its used for damage reduction)
- buff/debuff (some effect that runs by the end or start of the turn)
You can test it out with all the pets avaible for combat, they have points avaible so you can check the difference before increasing meleestat or health.
### Pet Attacks
Currently all the followings abilities were added [Dog, Lion, Tiger, Bear, Gorilla, Wolf, Bull, Fox, Rhino.](https://app.notion.com/p/Attack-abilities-3798ac3aaccd805ebd6bc24352e47da9?source=copy_link)
- **Passive Attacks**: Every pet got their own passive effect that runs at the end or begging of turn
- **Normal Attack**: A regular attack that dealt damage based in the pet stats
- **Special attack**: Some special ability specific to the pet
------------------------------------------------------------
### Suggetions:
This feature is incomplete but closer to its final phase, we still need more attack mechanics, vfx, animations and some images would be cool too.
- The pet attacks only do their effects but they don't play any vfx or animation (is not visible)
- Currently we have a debuf/buff system, we can give an icon for each one and list them avobe the healthBar [ALL PETS BUFF/DEBUFFS](https://app.notion.com/p/Buffs-Debuffs-37d8ac3aaccd8062a677c4c39569ae12?source=copy_link)
- All the bosses play the same attacks, if you wanna new boss abilities or any pet ability you need to tell me, you are the creative director
- Besides the vfx for some attacks we also need vfx for buffs, debbufs, healing
### Mechanics
All the pets have specific abilities and a team strategy may counter a boss rotation
For the moment the bosses got all the same pool of attacks, they go like
1. Reduce damage
2. Attack a single target
3. do an aoe
This got different interactions depending on the strategy you do, for example here's the perfect counter:
1. Lion, 
2. Fox (lowest health)
3. Dog
This is literally the perfect counter for the boss rotation: First lion increases the team damage, by the end of turn boss attemps to reduce them, then fox creates a decoy, at the end of turn boss attacks it, third turn the dog increase the team defense and damage and later the boss apllies an aoe


I recived the new rigs. I wanna talk about the Parrot, let me do a not tecnichal explanation: every pet have the same behaviour, different behaviour like the parrot requires changing the code infrastructure and do additional work. I can do that work but you need to know that i cannot plug the parrot into the game like the other pets for 10$ because this requires me to take extra time so i will treat that as a different task. Also i need you to answer me a few questions.
1. Pets level by eating the grass, if the parrot does not eat grass, how does it level up?
2. Pets have proximity prompt to see stats (the press e sign), should we avoid this proximity prompt to parrot?
3. Also we use a billboard for each pet, what you have in mind for parrot?
4. Parrot can fight bosses?