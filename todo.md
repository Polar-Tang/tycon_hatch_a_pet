[.] The offline player should not gain the same money as the online player
[] As miner heaven, you will want to create number instance holding the pet stats values, and listen if changed attribute. use this for example to listen if stamina is changed, then fire the client moneyIncrease
[] The pets can be also be tagged by its owner
[] the pets can be tagged by id, so we can retrive the model by its id, orrr the pets may start with its default name and be changed after initializing setCtx


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


[.] Every pet should be listed in the Data store
[] Every pet should have a unique id as key, and that's the name
[] Fenced bounds can haver kinda attribute to know who belongs to

all the fenced bounds are tagged, i retrieve these collection service and for each plot i see the playerOwner or owner string value, for every owner value i ds:GetAsync("data_" .. player.UserId).pets and setCtx for each pet. Use a bool value to fenced bounce indicating that the plot is already initialized in the server


I want to understand Dot by its formula, you said:
A · B = |A| |B| cos(θ)
imagine 
Vector.new(2,2,2) * Vector.new(-3,-3,-3) = Vector.new(2,2,2) * Vector.new(3,3,3) cos(D)
Vector.new(-6,-6,-6) = Vector.new(6,6,6) cos(D)
Vector.new(-6,-6,-6) / Vector.new(6,6,6) = cos(D)
Vector.new(-1,-1,-1) = cos(D)
arcCos(Vector.new(-1,-1,-1))


check if the petId id exists on bestiary