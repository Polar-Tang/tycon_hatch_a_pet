[.] The offline player should not gain the same money as the online player
[] As miner heaven, you will want to create number instance holding the pet stats values, and listen if changed attribute. use this for example to listen if stamina is changed, then fire the client moneyIncrease
[] The pets can be also be tagged by its owner
[] the pets can be tagged by id, so we can retrive the model by its id, orrr the pets may start with its default name and be changed after initializing setCtx

### [Link updated](https://www.roblox.com/games/80420751886453/Raise-and-hatch)
- **New resize formula**
    Since the pet can go up to level 150, its size growth needs to be more gradual. Instead of growing a lot early, it slowly gets bigger over many levels, which keeps the pet from becoming oversized and keeps the game balanced. The pet at max level becomes exaclty twice its size
- **New stats fromula**
    The stats are generated randomly for every pet, each stat has its own formula, the data store was restarted so you can see the changes


todo: look for GenerateRandStats in CaptureAllPets 

These two task holds all the logic needed to finish the basic stuff for the game (before any boss fighing logic)
### Pets Colection Task $40
Currently pets exist as static models and this task implements a full runtime system for per-player ownership and initialization. This includes
- Player owned plot
- Multiplayer gameplay
- Multiplayer replication (everyone sees everyone's pet)
- Plot behavior, plot per player
- Foundation for all future systems
### Shop keepers $20
Shop keepers do sold stuf to players
- Kibly Shop keeper
    - own UI
    - speed coil items
    - Kibble items, reset pet stats taking back to its normal size
- Egg shop keeper
    - Sells eggs with differen categories and precies
        - dog egg 
        - cat egg 
        - herbavore egg 
        - carnivore 
        - rare egg 
        - super rare egg 
        - legendary egg 
        - mythical egg
    - this eggs generates a new pet initialized in the player own plot

Deadline: I'm not sure that i can do all of this before february, february 1 to february 8 i will on vacation so the process may be slowed down, however by the time i get back at my home i will have most of these two task done and these two task will be surely finnished about februray 10 or like that, still leaving plenty of days to work in the boss fighting logic and having the game fully completed on march 