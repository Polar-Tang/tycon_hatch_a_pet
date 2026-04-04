--[[
    You can study incomes. It's a reactive class that uses valueObject which may be changed based in the current petList `bestiaryList.PetsValue:Observe():Subscribe`
    Besides the effect that should run during the pet is listed there are also bonuses that running after a random time between 1 minute and 5 minutes
    ```
    local function GetRandTime()
        return math.Random(60, 300) -- 1 between 5 minutes
    end

    bonus = function()
        print("do something")
        local t = GetRandTime()
		local bonus = task.delay(t, bonus)
		self._maid._cleanup = bonus
	end
    -- init the recursive task
    local t = GetRandTime()
	local bonus = task.delay(t, bonus)
	self._maid._cleanup = bonus
    ```
    Turn the previous snippet in a method that take a callback as an argument. But we got some limitation about that maid usage. We actually need to run this method for every pet as we'll as be able to clean the pet pending task by its unique id when the pet is removed from the list. We need a method that resembles mapPetsToBoosters but when looping to the newPets using their key (newPets key is a unique id used for the bestiaryList handler as well so please use this id instead of creating a new one) to run such method 
     and the bonus is a different function for each of them. 
         Please create a bonus function for each pet in `src/server/Pets/Pet/PetInformation.luau` that simply does a print. 
    {boosterType : boosterList}
]]