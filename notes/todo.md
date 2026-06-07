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
Combat Pets

Dog
Passive: Loyalty Boost – Increases all stats slightly for the team
Active: Rally – At the start of battle, boosts damage and defense for a short time

Lion
Passive: King’s Strength – Deals consistent high damage
Active: Alpha Roar – Periodically increases team damage

Tiger
Passive: Predator Instinct – Increased critical hit chance and damage
Active: Pounce Strike – Deals high burst damage and applies bleed

Bear
Passive: Regeneration – Slowly restores health during battle
Active: Rage Mode – Reduces incoming damage and increases attack

Gorilla
Passive: Unshaken – Reduces effects of stuns and knockbacks
Active: Ground Slam – Stuns the boss and interrupts attacks

Bull
Passive: Armor Break – Attacks reduce enemy defense
Active: Stampede – Charges forward dealing heavy damage and lowering defense

Wolf
Passive: Blood Hunt – Damage increases the longer the battle lasts
Active: Pack Frenzy – Increases attack speed and damage for a short time

Fox
Passive: Evasion – Chance to dodge incoming attacks
Active: Clone Trick – Creates a decoy that distracts the boss

Rhino
Passive: Thick Hide – Reduces incoming damage and increases resistance while attacking
Active: Rampage Charge – Charges forward, dealing massive damage and breaking enemy defenses

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