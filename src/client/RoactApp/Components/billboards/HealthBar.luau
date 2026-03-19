local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BillboardService = require(ReplicatedStorage.NPC.Servicies.BillboardService.BillboardService)
local Roact = require(ReplicatedStorage:WaitForChild("Roact"))

local Healthbar = Roact.Component:extend("Healthbar")

local fontFamily = Enum.Font.Gotham

function Healthbar:render()
	local pet = self.props.model
	local percent = self.props.percent / 100
	local petLevel = self.props.petLevel
	print("new Percent ", percent)
	print("for ", pet.Name)
	if not pet then
		return
	end
	local billboardSizes = BillboardService.resizeBillboard(pet)
	local newSize = billboardSizes.Size
	local newStudsOffset = billboardSizes.StudsOffset
	local healthBarBackgroundColor3 = Color3.fromRGB(200, 0, 0)
	if percent > 0.5 then
		healthBarBackgroundColor3 = Color3.fromRGB(0, 200, 0)
	elseif percent > 0.2 then
		healthBarBackgroundColor3 = Color3.fromRGB(255, 170, 0)
	end
	if not petLevel then
		petLevel = "💀"
	end

	return Roact.createElement("BillboardGui", {
		Name = "CustomHumanoidBar",
		Adornee = pet:FindFirstChild("Head") or pet.PrimaryPart,
		Size = newSize,
		StudsOffset = newStudsOffset,
		AlwaysOnTop = true,
		Parent = pet,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
	}, {

		LevelLabel = Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0.35, 0),
			BackgroundTransparency = 1,
			Text = "Lvl. " .. petLevel,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Position = UDim2.new(0, 0, 0, 0),
			Font = Enum.Font.GothamBold,
			TextScaled = true,
		}),
		NameBackground = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0.4, 0),
			Position = UDim2.new(0, 0, 0.35, 0),
			BackgroundColor3 = Color3.fromRGB(30, 30, 60),
			BackgroundTransparency = 0.2,
		}, {
			NameLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = pet.Name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = fontFamily,
				TextScaled = true,
			}),
		}),
		HealthBackground = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0.4, 0),
			Position = UDim2.new(0, 0, 0.7, 0),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			BackgroundTransparency = 0.1,
		}, {
			HealthBar = Roact.createElement("Frame", {
				Name = "HealthBar",
				Size = UDim2.new(percent, 0, 1, 0),
				BackgroundColor3 = healthBarBackgroundColor3,
				BorderSizePixel = 0,
			}),
		}),
	})
end

return Healthbar
