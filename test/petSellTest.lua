local Suffixes = {
	"k",
	"M",
	"B",
	"T",
	"qd",
	"Qn",
	"sx",
	"Sp",
	"O",
	"N",
	"de",
	"Ud",
	"DD",
	"tdD",
	"qdD",
	"QnD",
	"sxD",
	"SpD",
	"OcD",
	"NvD",
	"Vgn",
	"UVg",
	"DVg",
	"TVg",
	"qtV",
	"QnV",
	"SeV",
	"SPG",
	"OVG",
	"NVG",
	"TGN",
	"UTG",
	"DTG",
	"tsTG",
	"qtTG",
	"QnTG",
	"ssTG",
	"SpTG",
	"OcTG",
	"NoTG",
	"QdDR",
	"uQDR",
	"dQDR",
	"tQDR",
	"qdQDR",
	"QnQDR",
	"sxQDR",
	"SpQDR",
	"OQDDr",
	"NQDDr",
	"qQGNT",
	"uQGNT",
	"dQGNT",
	"tQGNT",
	"qdQGNT",
	"QnQGNT",
	"sxQGNT",
	"SpQGNT",
	"OQQGNT",
	"NQQGNT",
	"SXGNTL",
}

local function shorten(Input)
	local Negative = Input < 0
	Input = math.abs(Input)

	local Paired = false
	for i, v in pairs(Suffixes) do
		if not (Input >= 10 ^ (3 * i)) then
			Input = Input / 10 ^ (3 * (i - 1))
			local isComplex = (string.find(tostring(Input), ".") and string.sub(tostring(Input), 4, 4) ~= ".")
			Input = string.sub(tostring(Input), 1, (isComplex and 4) or 3) .. (Suffixes[i - 1] or "")
			Paired = true
			break
		end
	end
	if not Paired then
		local Rounded = math.floor(Input)
		Input = tostring(Rounded)
	end

	if Negative then
		return "-" .. Input
	end
	return Input
end

local HandleMoney = function(Input)
	local Negative = Input < 0
	if Negative then
		return "(-$" .. shorten(math.abs(Input)) .. ")"
	end
	return "$" .. shorten(Input)
end

local petsTest = {
	{
		name = "LegendaryGoat",
		rarity = "legendary",
		petStats = {
			["Health"] = 45,
			["Melee"] = 34,
			["Stamina"] = 36,
		},
	},
	{
		name = "EpicBuffalo",
		rarity = "epic",
		petStats = {
			["Health"] = 5,
			["Melee"] = 6,
			["Stamina"] = 7,
		},
	},
	{
		name = "rareFish",
		rarity = "rare",
		petStats = {
			["Health"] = 12,
			["Melee"] = 25,
			["Stamina"] = 35,
		},
	},
	{
		name = "uncommonFrog",
		rarity = "uncommon",
		petStats = {
			["Health"] = 45,
			["Melee"] = 34,
			["Stamina"] = 36,
		},
	},
	{
		name = "commonFrog",
		rarity = "common",
		petStats = {
			["Health"] = 56,
			["Melee"] = 45,
			["Stamina"] = 45,
		},
	},
}

local MoneyCalc = function(stamina)
	local staminaGT1 = stamina
	if stamina == 0 then
		staminaGT1 = 1
	end
	return (staminaGT1 ^ 1.8) * 2
end

local function CalculatePrice(petData)
	local petStats = petData.petStats
	local petRarity = petData.rarity
	local petName = petData.name

	local sum = 1
	for statName, petStat in pairs(petStats) do
		-- local stat = if petStat == 0 then 1 else petStat
		sum = sum + petStat
	end

	local rarirty_multiplier = {
		["common"] = 1.0,
		["uncommon"] = 1.1,
		["rare"] = 1.2,
		["epic"] = 1.3,
		["legendary"] = 1.4,
	}

	-- local price = reduce * rarirty_multiplier[petRarity]
	local base = sum ^ 4.942
	local price = base * rarirty_multiplier[petRarity]

	print("----------------------------- " .. string.upper(petRarity) .. " -----------------------------")
	print("This is the price for " .. petName, HandleMoney(price))
	local moneyPerSec = MoneyCalc(sum)
	local prcieGoal = math.floor(moneyPerSec * 2678400) -- money in a month
	print("This pet would generate ", HandleMoney(prcieGoal), " in a month")
	local farFromGoal = prcieGoal - price
	print("prcieGoal - price ", HandleMoney(farFromGoal))
	--[[
        priceGoal -> 100
        farFromgoal -> x
        ]]
	local percentage = (farFromGoal * 100) / prcieGoal
	print("Which is a ", percentage, "% from goal")
	print("---------------------------------------------------------------------")
end

for _, petData in ipairs(petsTest) do
	CalculatePrice(petData)
end
