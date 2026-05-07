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
-[] Adding the new eggs
-[] Finish

# [Pet Family] task release
This task update the egg rng, assign pet rarity and classification to 16 different pets and create an animation for hatching. The game is avaible in [the experience]() please remember to request any change you like
## **Description**
You can acquire 6 different egg categories from store, the luck and randomness is what decides the pet you ge
## Features
- Eggs have proximity prompt
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
