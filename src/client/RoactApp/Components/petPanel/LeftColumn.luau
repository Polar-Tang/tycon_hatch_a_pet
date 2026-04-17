local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Roact = require(ReplicatedStorage.Roact)
local PetTypes = require(ReplicatedStorage.Pets.PetTypes)

local assets = require(game:GetService("StarterPlayer").StarterPlayerScripts.Public.assets)
local images = assets.player_inventory

local LeftColumn = Roact.Component:extend("LeftColumn")

function LeftColumn:init()
	self.itemRefs = {}
end

function LeftColumn:_renderItemList(layoutOrder: number, petId: string, petInformation: PetTypes.PetData)
	local itemRef = Roact.createRef()
	self.itemRefs[petId] = itemRef

	-- local titleText = tostring(petInformation.petName) .. " - " .. tostring(petInformation.petId)
	local petName = tostring(petInformation.petName)
	local textSize = TextService:GetTextSize(petName, 23, Enum.Font.FredokaOne, Vector2.new(math.huge, math.huge))
	local scaleFactor = math.min(1, (petInformation.petName:len() * 11) / textSize.X)

	return Roact.createElement("ImageButton", {
		Size = UDim2.fromScale(1, 0.18),
		BackgroundTransparency = 1,
		Image = images.LeftHeader,
		LayoutOrder = layoutOrder,
		[Roact.Ref] = itemRef,
		[Roact.Event.Activated] = function()
			local selectPetData = self.props.selectPetData
			if selectPetData then
				selectPetData(petInformation)
			end
		end,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0.01, 0),
			PaddingBottom = UDim.new(0.01, 0),
			PaddingLeft = UDim.new(0.04, 0),
			PaddingRight = UDim.new(0.02, 0),
		}),
		Title = Roact.createElement("TextLabel", {
			Size = UDim2.new(0, scaleFactor, 0, textSize),
			BackgroundTransparency = 1,
			Font = Enum.Font.FredokaOne,
			TextScaled = true,
			Text = petName,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			LayoutOrder = 1,
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
	})
end

function LeftColumn:render()
	local imagesProp = self.props.images or images
	local sidesPadding = self.props.sidesPadding or (4 / 300)
	local yPadding = self.props.yPadding or (4 / 165)
	local petRegistry = self.props.petRegistry or (_G["pets_registry"] or {}) :: PetTypes.PetsDataStore

	local itemList = {}
	local itemOrder = 0
	for petId, petInformation in pairs(petRegistry) do
		itemOrder += 1
		itemList[itemOrder] = self:_renderItemList(itemOrder, petId, petInformation)
	end

	return Roact.createElement("ImageLabel", {
		Size = UDim2.fromScale(1 / 4, 1),
		LayoutOrder = self.props.LayoutOrder or 1,
		Image = imagesProp.ColumnBg,
		BackgroundTransparency = 1,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingRight = UDim.new(sidesPadding * 2, 0),
			PaddingLeft = UDim.new(sidesPadding * 2, 0),
			PaddingTop = UDim.new(0.019, 0),
			PaddingBottom = UDim.new(0.019, 0),
		}),

		Header = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1 - sidesPadding, yPadding * 4),
			Image = imagesProp.LeftHeader,
			Position = UDim2.fromScale(sidesPadding / 2, 0),
			BackgroundTransparency = 1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(yPadding / 2, 0),
				PaddingBottom = UDim.new(yPadding / 2, 0),
				PaddingLeft = UDim.new(sidesPadding / 2, 0),
				PaddingRight = UDim.new(sidesPadding / 2, 0),
			}),

			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.02, 0),
			}),

			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(0.6, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.FredokaOne,
				TextScaled = true,
				Text = "FreshOriginal",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				LayoutOrder = 1,
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

			ImagesContainer = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.4, 1),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0.05, 0),
				}),
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0.16, 0),
					PaddingBottom = UDim.new(0.16, 0),
					PaddingLeft = UDim.new(0.156, 0),
					PaddingRight = UDim.new(0.156, 0),
				}),

				Image1 = Roact.createElement("ImageLabel", {
					Size = UDim2.fromScale(0.5, 1),
					Image = "rbxassetid://117960101708858",
					BackgroundTransparency = 1,
					LayoutOrder = 1,
				}),

				Image2 = Roact.createElement("ImageLabel", {
					Size = UDim2.fromScale(0.5, 1),
					Image = "rbxassetid://81664351080568",
					BackgroundTransparency = 1,
					LayoutOrder = 2,
				}),
			}),
		}),

		Content = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1 - sidesPadding, 1 - (yPadding / 2 + yPadding * 4)),
			Image = imagesProp.ColumnPreview,
			Position = UDim2.fromScale(sidesPadding / 2, yPadding / 2 + yPadding * 4),
			BackgroundTransparency = 1,
		}, {
			Content = Roact.createElement("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ScrollBarThickness = 1,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
				ZIndex = 3,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
				}),

				Padding = Roact.createElement("UIPadding", {
					PaddingRight = UDim.new(sidesPadding * 2, 0),
					PaddingLeft = UDim.new(sidesPadding * 2, 0),
					PaddingTop = UDim.new(0.019, 0),
					PaddingBottom = UDim.new(0.019, 0),
				}),

				ItemList = Roact.createFragment(itemList),
			}),
		}),
	})
end

return LeftColumn
