local OfflineRewards = {}
OfflineRewards.__index = OfflineRewards

-- return eats and timeline
function OfflineRewards._init(petStats, offlineTime)
    local eat_interval = petStats.eat_interval
	local eat_duration = petStats.eat_duration
-- Edge case: if offline time is too short
	if offlineTime < eat_interval then
		return 0, 0
	end
	
	-- PHASE 1: Initial eat
	local timeline = eat_interval -- First eat happens at t=5
	local totalEats = 0
	
	-- Check if first eat completes
	if offlineTime >= timeline + eat_duration then
		totalEats = 1
		timeline = timeline + eat_duration  -- Now at t=9
	end
    
    return totalEats, timeline
end



--Return moeny and eats
function OfflineRewards:CalculateOfflineEarnings(petStats, offlineTime)--: number, number
	local eat_interval = petStats.eat_interval
	local eat_duration = petStats.eat_duration
    local patrol_duration = petStats.patrol_duration
    local base = petStats.base
	
    local totalEats, timeline = self._init(petStats, offlineTime)
	-- PHASE 3: Repeating cycle
	-- After first eat+patrol, the pattern stabilizes:
	-- Eat happens every (eat_interval + eat_duration + patrol_duration) seconds
	-- because: eat finishes → patrol starts immediately → patrol finishes → wait eat_interval → eat starts
	
	local cycleTime = eat_duration + patrol_duration + eat_interval
	-- Breakdown: eat(4s) + patrol(3s) + idle_wait(5s) = 12s per cycle
	
	local remainingTime = offlineTime - timeline
	local completeCycles = math.floor(remainingTime / cycleTime)
	totalEats = totalEats + completeCycles
	
	-- Check partial cycle
	local timeInPartialCycle = remainingTime % cycleTime
	
	-- Does the partial cycle reach the next eat?
	if timeInPartialCycle >= eat_interval then
		-- Started eating
		if timeInPartialCycle >= eat_interval + eat_duration then
			-- Completed eating
			totalEats = totalEats + 1
		end
	end
	
	local totalMoney = totalEats * base
	return totalMoney, totalEats
end
