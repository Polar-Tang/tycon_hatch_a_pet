local Roact = require(game.ReplicatedStorage.Roact)
local StarterPlayer = game:GetService("StarterPlayer")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = require(StarterPlayer.StarterPlayerScripts.Public.assets)

local PetStat = ReplicatedStorage.RemoteEvents.PetStat

local context = script.Parent.Parent.Parent.Context
local InventoryContext = require(context.InventoryContext.InventoryContext)
local useContext = require(context.Utils.useContext)
local withCtx = useContext({ InventoryContext = InventoryContext })

local UpgradeSet = Roact.Component:extend("UpgradeSet")

function UpgradeSet:init()
	self:setState({
		statLevel = 0,
		boundPetId = nil,
		boundStat = nil,
	})
end

function UpgradeSet:_getStatValue(selectedPetData, statTitle: string): number
	if not selectedPetData or not selectedPetData.petStats then
		return 0
	end

	local value = selectedPetData.petStats[statTitle]
	if typeof(value) ~= "number" then
		return 0
	end

	return value
end

function UpgradeSet:_setSelectedPetOptimistic(inventoryCtx, selectedPetData, statTitle: string, newValue: number, availablePoints: number)
	if not inventoryCtx or not inventoryCtx.setSelectedPetData or not selectedPetData then
		return
	end

	local updatedPet = table.clone(selectedPetData)
	updatedPet.petStats = table.clone(selectedPetData.petStats)
	updatedPet.petStats[statTitle] = newValue
	updatedPet.avaiblePoints = availablePoints
	inventoryCtx.setSelectedPetData(updatedPet)
end

function UpgradeSet:render()
    local props = self.props

	local title = props.Title or "Speed"
	local statTitle = props.statTitle or title
	local maxLevel = props.MaxLevel or 7
	local font = Enum.Font.FredokaOne
	local textSize = TextService:GetTextSize(title, 30, font, Vector2.new(math.huge, math.huge))
	local refSize = Vector2.new(264, 171)
	local buttonWidth = 21

	return withCtx(function(ctx)
		local inventoryCtx = ctx.InventoryContext
		local selectedPetData = inventoryCtx.selectedPetData
		local selectedPetId = selectedPetData and selectedPetData.petId or nil
		local sourceLevel = self:_getStatValue(selectedPetData, statTitle)
		local level = sourceLevel
		if self.state.boundPetId == selectedPetId and self.state.boundStat == statTitle then
			level = self.state.statLevel
		end

		local availablePoints = selectedPetData and selectedPetData.avaiblePoints or 0

		local onPlus = function()
			if not selectedPetData then
				return
			end
			if availablePoints <= 0 then
				return
			end

			local nextLevel = math.clamp(level + 1, 0, maxLevel)
			if nextLevel == level then
				return
			end

			local nextPoints = math.max(0, availablePoints - 1)
			self:setState({
				statLevel = nextLevel,
				boundPetId = selectedPetId,
				boundStat = statTitle,
			})
			self:_setSelectedPetOptimistic(inventoryCtx, selectedPetData, statTitle, nextLevel, nextPoints)

			PetStat:FireServer({
				stat = statTitle,
				petId = selectedPetData.petId,
				action = "add",
			})
		end

		local onMinus = function()
			if not selectedPetData then
				return
			end
			if level <= 0 then
				return
			end

			local nextLevel = math.clamp(level - 1, 0, maxLevel)
			if nextLevel == level then
				return
			end

			local nextPoints = availablePoints + 1
			self:setState({
				statLevel = nextLevel,
				boundPetId = selectedPetId,
				boundStat = statTitle,
			})
			self:_setSelectedPetOptimistic(inventoryCtx, selectedPetData, statTitle, nextLevel, nextPoints)

			PetStat:FireServer({
				stat = statTitle,
				petId = selectedPetData.petId,
				action = "subtract",
			})
		end

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0.3333333333334, 0),
		}, {

		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			VerticalFlex = Enum.UIFlexAlignment.Fill,
		}),

		-- TITLE
		Title = Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Text = title,
			Font = font,
			-- TextSize = textSize,
			TextColor3 = Color3.fromRGB(235, 235, 235),
			Size = UDim2.new(0, textSize.X, 0, textSize.Y),
			LayoutOrder = 1,
			TextScaled = true,
			TextStrokeTransparency = 0.8,
			TextWrapped = true,
		}, {
			Outline = Roact.createElement("UIStroke", {
				Thickness = 2,
				Color = Color3.fromRGB(0, 0, 0),
			}),

			Shadow = Roact.createElement("UIShadow", {
				BlurRadius = UDim.new(0, 0),
				Transparency = 0.5,
				Offset = UDim2.new(0, 2, 0, 2),
			}),
		}),

		--[[
            0/264 , 0/171 - 7
            SCREENWIDTH - X
        ]]
		-- ROW
		Row = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 2.6,0 ),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
		}, {

			RowLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(5 / refSize.Y, 0),
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceAround,
			}),

			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 0),
				PaddingBottom = UDim.new(0.019, 0),
				PaddingLeft = UDim.new(0.007, 0),
				PaddingRight = UDim.new(0.007, 0),
			}),

			-- MINUS
			Minus = Roact.createElement("ImageButton", {
				Size = UDim2.fromScale(21 / 300, 56 / 165),
				BackgroundTransparency = 1,
				Image = assets.player_inventory.MinusIcon,
				LayoutOrder = 1,
				AutoButtonColor = false,
				[Roact.Event.Activated] = onMinus,
			}),

			-- UPGRADES
			Upgrades = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1 - (buttonWidth / 300 * 4), 0, 56 / 165, 0),
				LayoutOrder = 2,
			}, { --0.672

				Padding = Roact.createElement("UIPadding", {
					PaddingRight = UDim.new(0.037, 0),
				}),

				List = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 2),
				}),

				Icons = Roact.createFragment((function()
					local children = {}

					for i = 1, maxLevel do
						children["U" .. i] = Roact.createElement("ImageLabel", {
							Size = UDim2.new(1 / maxLevel, 0, 1, 0),

							BackgroundTransparency = 1,
							Image = i <= level and assets.player_inventory.DoneUpgrade
								or assets.player_inventory.BlankUpgrade,
						})
					end

					return children
				end)()),
			}),

			-- PLUS
			Plus = Roact.createElement("ImageButton", {
				Size = UDim2.fromScale(21 / 300, 56 / 165),
				BackgroundTransparency = 1,
				Image = assets.player_inventory.PlusIcon,
				LayoutOrder = 3,
				AutoButtonColor = false,
				[Roact.Event.Activated] = onPlus,
			}),
		}),
	})
	end)
end

return UpgradeSet
