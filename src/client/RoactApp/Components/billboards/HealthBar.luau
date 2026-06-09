local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BillboardService = require(ReplicatedStorage.NPC.Servicies.BillboardService.BillboardService)
local Roact = require(ReplicatedStorage:WaitForChild("Roact"))

-- The per-band Health IntValue mirrors each active buff/debuff/passive onto an
-- attribute (key = effect id, value = rounds left, or `true` for an always-on passive).
-- This folder holds both those runtime session folders and the shared effect registry
-- the client reads to turn an effect id into its icon.
local FightsFolder = ReplicatedStorage:WaitForChild("Pets"):WaitForChild("Fights")
local FightEffects = require(FightsFolder.FightEffects)

local Healthbar = Roact.Component:extend("Healthbar")

local fontFamily = Enum.Font.Gotham

-- the one Health attribute that is NOT an effect icon (it carries the bar's max)
local MAX_HEALTH_ATTRIBUTE = "MaxHealth"

function Healthbar:init()
	self._modelConnection = nil
	self._attrConnection = nil
	self._healthValue = nil
	self._shouldUnmount = false

	self:bindModel(self.props.model)
	self:bindHealth()
end

function Healthbar:bindModel(model: Model?)
	if self._modelConnection then
		self._modelConnection:Disconnect()
		self._modelConnection = nil
	end

	if not model then
		self._shouldUnmount = true
		return
	end

	self._shouldUnmount = false
	self._modelConnection = model.AncestryChanged:Connect(function()
		if not self.props.model or not self.props.model.Parent  then
			print("should destroy that healthbar")
			self._shouldUnmount = true
			self.props.model = nil
			self:setState({})
			--[[
				Players.virtual_nautilus.PlayerScripts.RoactApp.Components.billboards.HealthBar:47: attempt to call missing method 'unMount' of table  
			]]
		end
	end)
end

-- Resolves this fighter's Health IntValue in the live session folder and subscribes to
-- its AttributeChanged so the buff row re-renders the instant the server adds, counts
-- down, or clears an effect. `props.petId` IS the band ("PlayerPet1" / "PlayerBoss").
-- Independent of the HealthCon push that drives `percent`. Returns true if it bound a
-- value (the IntValue can be absent at mount; didUpdate retries on later pushes).
function Healthbar:bindHealth(): boolean
	if self._attrConnection then
		self._attrConnection:Disconnect()
		self._attrConnection = nil
	end
	self._healthValue = nil

	local band = self.props.petId
	if not band then
		return false
	end

	local sessionFolder = FightsFolder:FindFirstChild(tostring(Players.LocalPlayer.UserId))
	local bandFolder = sessionFolder and sessionFolder:FindFirstChild(band)
	local healthValue = bandFolder and bandFolder:FindFirstChild("Health")
	if not healthValue then
		return false
	end

	self._healthValue = healthValue
	self._attrConnection = healthValue.AttributeChanged:Connect(function()
		self:setState({})
	end)
	return true
end

function Healthbar:didUpdate(previousProps)
	if previousProps.model ~= self.props.model then
		self:bindModel(self.props.model)
		self:setState({})
	end
	if previousProps.petId ~= self.props.petId then
		self:bindHealth()
		self:setState({})
	elseif not self._healthValue then
		-- the IntValue may not have existed at mount; retry on the next push-driven
		-- update. Only re-render when we actually find it, so this can't loop.
		if self:bindHealth() then
			self:setState({})
		end
	end
end

function Healthbar:willUnmount()
	if self._modelConnection then
		self._modelConnection:Disconnect()
		self._modelConnection = nil
	end
	if self._attrConnection then
		self._attrConnection:Disconnect()
		self._attrConnection = nil
	end
end

-- Builds the horizontal strip of buff/debuff icons under the health bar from the Health
-- IntValue's attributes: each non-MaxHealth attribute is one active effect (key = effect
-- id → FightEffects icon; a numeric value is the rounds left, `true` is an always-on
-- passive shown without a counter). Returns nil when there's nothing to show.
local function buildEffectRow(healthValue: IntValue?)
	if not healthValue then
		return nil
	end

	local icons = {}
	local count = 0
	for id, remaining in pairs(healthValue:GetAttributes()) do
		if id ~= MAX_HEALTH_ATTRIBUTE then
			count += 1
			local entry = FightEffects.get(id)
			-- the art is still a placeholder (`icon == ""`, which renders nothing), so
			-- fall back to a color-coded chip (debuff red / buff green) — the row stays
			-- visible in dev and just swaps to the image once an asset id is filled in.
			local hasIcon = entry.icon ~= ""
			local kindColor = if entry.kind == "debuff"
				then Color3.fromRGB(180, 45, 45)
				else Color3.fromRGB(45, 140, 65)

			icons[id] = Roact.createElement("ImageLabel", {
				BackgroundTransparency = if hasIcon then 1 else 0.15,
				BackgroundColor3 = kindColor,
				-- full-size max box; the AspectRatioConstraint below carves the largest
				-- 1:1 square out of it (= the row height), so the icon never collapses.
				-- A Size with a zero axis (e.g. height 0) starves the constraint → invisible.
				Size = UDim2.fromScale(1, 1),
				Image = entry.icon,
				LayoutOrder = count,
			}, {
				Aspect = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
				}),
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.2, 0),
				}),
				-- a numeric value is the remaining rounds (buff/debuff); a passive stores
				-- `true` and shows no counter
				Count = if typeof(remaining) == "number"
					then Roact.createElement("TextLabel", {
						Size = UDim2.fromScale(1, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						BackgroundTransparency = 1,
						Text = tostring(remaining),
						TextScaled = true,
						Font = Enum.Font.GothamBold,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextStrokeTransparency = 0.4,
					})
					else nil,
			})
		end
	end

	if count == 0 then
		return nil
	end

	icons.Layout = Roact.createElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	return Roact.createElement("Frame", {
		Name = "EffectRow",
		Size = UDim2.new(1, 0, 0.3, 0),
		-- just below the health bar (which sits at scale-Y 0.7..1.1)
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundTransparency = 1,
	}, icons)
end

function Healthbar:render()
	local pet = self.props.model
	local percent = self.props.percent
	local petLevel = self.props.petLevel
	
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
		Adornee = pet.PrimaryPart,
		Size = newSize,
		StudsOffset = newStudsOffset,
		AlwaysOnTop = true,
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
		-- row of active buff/debuff/passive icons, driven live off the Health
		-- IntValue's attributes (nil when the fighter has no active effects)
		EffectRow = buildEffectRow(self._healthValue),
	})
end

return Healthbar
