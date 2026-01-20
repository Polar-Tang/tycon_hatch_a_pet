## **Pet Leveling System**

### Experience & Leveling

- Each pet gains **experience (XP)** when entering the **Eat Grass** state.
    
- The Eat state already exists on the client.
    
- On each Eat action, the client **fires the server** to register XP gain.
    
- A **Level Controller** handles:
    
    - XP thresholds
        
    - Level ups
        
    - Stat point generation on level up
        

---

### Money Generation

- Pets generate money **passively every second**.
    
- Instead of one heartbeat per pet:
    
    - Use **one server-side loop per player**
        
    - This loop:
        
        - Iterates through all owned pets
            
        - Reads pet level & stats
            
        - Calculates total money per second
            
        - Grants currency in one operation
            
- Client-side heartbeats may exist visually, but:
    
    - **Server verifies all money generation**
        
    - No trust in client values
        

---

### Client–Server Architecture

- Pets exist and animate on the **client**
    
- All important actions:
    
    - XP gain
        
    - Level up
        
    - Money generation
        
    - Stat changes  
        are **validated and applied on the server**
        
- Replication is handled via:
    
    - Server-owned pet data
        
    - Client receives state updates only
[]  This validation system uses time stamps,  it register when the player connect to and every time EatGrass:FireServer, it count this eat time and uses the calculation for offline pet to calculate if this value is near expected

---

### Stats System

- Each pet has stats that scale with level:
    
    - Stats are increased on level up
        
    - Stat allocation is controlled by the Level Controller
        
- Stats affect:
    
    - Money per second generation
        
    - Future combat access (boss requirements)
        

---

### UI Interaction

- Each pet has a **ClickDetector**
    
- Clicking a pet:
    
    - Opens the **Stats UI**
        
    - Displays:
        
        - Pet level
            
        - XP
            
        - Current stats
            
- UI requests data from the server; server sends authoritative values
    

---

### Data Persistence

- Player pet data is saved in **DataStore**
    
- Saved data includes:
    
    - Pet ID
        
    - Level
        
    - XP
        
    - Stats
        
    - Assigned plot (if applicable)
        
- On player join:
    
    - Pets are reconstructed
        
    - State machines are initialized safely
        
    - Initialization is **shielded** to prevent duplicate events or XP triggers
        

---

### Replication & Safety

- Server:
    
    - Owns all pet data
        
    - Validates all client requests
        
- Client:
    
    - Handles visuals and animations
        
    - Requests actions only
        
- Anti-abuse measures:
    
    - XP gain limited to valid Eat state
        
    - Money generation loop server-side only
        

---

This is a **solid, scalable design**, and you’re thinking about it correctly:  
one loop per player, server authority, client visuals only.

If you want next, I can:

- Turn this into **pseudocode**
    
- Or split it into **milestones** so you don’t overbuild it in one go