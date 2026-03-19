Hi, **Pet Combat and Fight system** is ready to test on your experience. You got pets by default to test on, you can use the pet stats as you like to test them 
### Bug fixes
- The plot of the player who leaft is totally evicted
- No more floating pets
- Adding a visible toggling effect on "Stats" title when hover
### Features
##### Index panel
- Open-able from a totally new button
- A list of your pets and boxes
- They can be selected so you get details and they are framed with their rarity cloud
##### Top bottoms
- Three bottoms that quickly teleports you to your pets or shopkepeers
- Any combat instance is destroyed during this teleportation
- Usage of the plot player position
###### Pet follower
- A copy of your selected pet is following you
- The scale size of the pet at his current level is kept with a cap of 25.00 of magnitude (max magnitude reached by elephant at level 150 is 42.38)
- Animation speed is adjusted as needed
- Pet uses pathfinding to find the sortest path, when it gets stuck it quickly jumps to its goal
###### Combat
- Combat instance to boss that are isolated for each client
- Pet and boss has their stats
- Pets that lives in the client (good for perfomance) but server authorative (secure)
- Each pet attack every 2 seconds 
### Things to keep working on
##### Things missing
- When boss died not much happens, i still don't know what could be a fair reward
- Boss rigs, they are more likely a place holder
##### Pending fixes including in this task
- I need to see what happends to the UI when the player dies
- I still haven't see hatch system again
- Any request or detail you wanna change is included as part of this task