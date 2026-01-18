-- Fishing Simulator Stealth Exploit v5.2
-- Complete fixed version with no syntax errors
-- Compatible with all executors

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")

-- === CONFIGURATION ===
local Config = {
	AutoFish = true,
	InstantCatch = true,
	MinWeight = 1.0,
	MaxWeight = 1000.0,
	MinRarity = 1,
	MaxRarity = 6,
	AutoSell = false,
	SellBelowRarity = 3
}

-- === RARITY MAPPING ===
local RarityMap = {
	[1] = {Name = "Common", Color = Color3.fromRGB(200, 200, 200)},
	[2] = {Name = "Uncommon", Color = Color3.fromRGB(30, 255, 30)},
	[3] = {Name = "Rare", Color = Color3.fromRGB(30, 100, 255)},
	[4] = {Name = "Epic", Color = Color3.fromRGB(160, 30, 255)},
	[5] = {Name = "Legendary", Color = Color3.fromRGB(255, 128, 0)},
	[6] = {Name = "SECRET", Color = Color3.fromRGB(0, 255, 119)}
}

-- === NETWORK THROTTLING ===
local NetworkStats = {
	CallCount = 0,
	LastReset = tick(),
	MaxCallsPerSecond = 3
}

local function ThrottledCall(remote, ...)
	local args = {...}
	local currentTime = tick()

	-- Reset counter setiap detik
	if currentTime - NetworkStats.LastReset >= 1 then
		NetworkStats.CallCount = 0
		NetworkStats.LastReset = currentTime
	end

	-- Rate limiting
	if NetworkStats.CallCount >= NetworkStats.MaxCallsPerSecond then
		local waitTime = 1 - (currentTime - NetworkStats.LastReset)
		task.wait(waitTime + math.random(10, 50) / 1000)
	end

	-- Execute call dengan error handling
	local success, result = pcall(function()
		if remote:IsA("RemoteEvent") then
			return remote:FireServer(unpack(args))
		elseif remote:IsA("RemoteFunction") then
			return remote:InvokeServer(unpack(args))
		end
	end)

	NetworkStats.CallCount = NetworkStats.CallCount + 1
	return success, result
end

-- === MODULE INJECTION ===
local OriginalFunctions = {}

local function InjectFishingModule()
	-- Cari module fishing
	local targetModule
	for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
		if obj:IsA("ModuleScript") and (obj.Name:lower():find("fish") or obj.Name:find("Fishing")) then
			targetModule = obj
			break
		end
	end

	if not targetModule then
		targetModule = FishingSystem:FindFirstChildWhichIsA("ModuleScript")
	end

	if targetModule then
		local success, moduleTable = pcall(require, targetModule)

		if success and type(moduleTable) == "table" then
			-- Hook GenerateFishWeight
			if moduleTable.GenerateFishWeight then
				OriginalFunctions.GenerateFishWeight = moduleTable.GenerateFishWeight

				moduleTable.GenerateFishWeight = function(fishData, rodLuck, maxWeight)
					-- Original result
					local originalResult = OriginalFunctions.GenerateFishWeight(fishData, rodLuck, maxWeight)

					-- Apply weight range
					local minKg = math.max(Config.MinWeight, fishData.minKg or 0.5)
					local maxKgAllowed = math.min(Config.MaxWeight, fishData.maxKg or 1000, maxWeight or 1000)

					if minKg > maxKgAllowed then
						return maxKgAllowed
					end

					-- Generate dalam range yang ditentukan
					local randomFactor = math.random()
					local weight = minKg + (randomFactor * (maxKgAllowed - minKg))

					-- Round to 1 decimal
					weight = math.floor(weight * 10 + 0.5) / 10

					return weight
				end
			end

			-- Hook untuk rarity control
			if moduleTable.GetFishByRarity then
				OriginalFunctions.GetFishByRarity = moduleTable.GetFishByRarity

				moduleTable.GetFishByRarity = function(rarity)
					-- Force max rarity jika InstantCatch aktif
					if Config.InstantCatch then
						local targetRarity = RarityMap[Config.MaxRarity]
						if targetRarity then
							return OriginalFunctions.GetFishByRarity(targetRarity.Name)
						end
					end
					return OriginalFunctions.GetFishByRarity(rarity)
				end
			end

			-- Hook untuk price calculation
			if moduleTable.CalculateFishPrice then
				OriginalFunctions.CalculateFishPrice = moduleTable.CalculateFishPrice

				moduleTable.CalculateFishPrice = function(weight, rarity)
					local price = OriginalFunctions.CalculateFishPrice(weight, rarity)

					-- Boost price jika diperlukan
					if Config.InstantCatch then
						price = price * 1.5
					end

					return math.floor(price + 0.5)
				end
			end

			print("[INJECTION] Module successfully hooked")
			return true
		end
	end

	print("[INJECTION] Module not found or failed to load")
	return false
end

-- === AUTO FISHING SYSTEM ===
local IsFishingActive = false
local FishingThread

local function StartFishing()
	if IsFishingActive then return end
	IsFishingActive = true

	FishingThread = task.spawn(function()
		while IsFishingActive do
			-- Find fishing remotes
			local castRemote = FishingSystem:FindFirstChild("CastLine") or 
				FishingSystem:FindFirstChild("StartFishing")

			local catchRemote = FishingSystem:FindFirstChild("CatchFish") or 
				FishingSystem:FindFirstChild("ReelIn") or
				FishingSystem:FindFirstChild("CompleteFishing")

			if castRemote and catchRemote then
				-- Cast line
				local castSuccess = ThrottledCall(castRemote)

				if castSuccess then
					-- Wait for bite (variable timing)
					local waitTime = math.random(500, 2000) / 1000
					task.wait(waitTime)

					-- Catch fish
					ThrottledCall(catchRemote)

					-- Auto sell jika aktif
					if Config.AutoSell then
						local sellRemote = FishingSystem:FindFirstChild("SellFish")
						if sellRemote then
							task.wait(0.5)
							ThrottledCall(sellRemote, "Common")
							ThrottledCall(sellRemote, "Uncommon")

							if Config.SellBelowRarity >= 3 then
								ThrottledCall(sellRemote, "Rare")
							end
						end
					end
				end
			end

			-- Human-like delay antara fishing attempts
			local delay = math.random(1000, 3000) / 1000
			task.wait(delay)
		end
	end)
end

local function StopFishing()
	IsFishingActive = false
	if FishingThread then
		task.cancel(FishingThread)
		FishingThread = nil
	end
end

-- === GUI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishingExploitGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "🎣 FISHING EXPLOIT v5.2"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Parent = MainFrame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 700)
ScrollFrame.Parent = MainFrame

-- Function untuk create section
local function CreateSection(title, yPosition)
	local section = Instance.new("Frame")
	section.Name = title .. "Section"
	section.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	section.Size = UDim2.new(1, 0, 0, 30)
	section.Position = UDim2.new(0, 0, 0, yPosition)

	local sectionTitle = Instance.new("TextLabel")
	sectionTitle.Name = "SectionTitle"
	sectionTitle.Text = "  " .. title
	sectionTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
	sectionTitle.TextSize = 14
	sectionTitle.Font = Enum.Font.GothamBold
	sectionTitle.BackgroundTransparency = 1
	sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	sectionTitle.Size = UDim2.new(1, 0, 1, 0)
	sectionTitle.Parent = section

	local sectionCorner = Instance.new("UICorner")
	sectionCorner.CornerRadius = UDim.new(0, 4)
	sectionCorner.Parent = section

	section.Parent = ScrollFrame
	return section
end

-- Function untuk create control dengan +/- buttons
local function CreatePrecisionControl(parent, label, configField, minVal, maxVal, step, defaultValue, yOffset)
	local container = Instance.new("Frame")
	container.Name = configField .. "Control"
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 0, 40)
	container.Position = UDim2.new(0, 0, 0, yOffset)

	local labelText = Instance.new("TextLabel")
	labelText.Name = "Label"
	labelText.Text = label
	labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
	labelText.TextSize = 14
	labelText.Font = Enum.Font.Gotham
	labelText.BackgroundTransparency = 1
	labelText.Size = UDim2.new(0.4, 0, 1, 0)
	labelText.Parent = container

	local controlFrame = Instance.new("Frame")
	controlFrame.Name = "ControlFrame"
	controlFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	controlFrame.BorderSizePixel = 0
	controlFrame.Size = UDim2.new(0.6, 0, 1, 0)
	controlFrame.Position = UDim2.new(0.4, 0, 0, 0)
	controlFrame.Parent = container

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 4)
	frameCorner.Parent = controlFrame

	-- Minus Button
	local minusBtn = Instance.new("TextButton")
	minusBtn.Name = "Minus"
	minusBtn.Text = "-"
	minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minusBtn.TextSize = 18
	minusBtn.Font = Enum.Font.GothamBold
	minusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	minusBtn.Size = UDim2.new(0.2, 0, 1, 0)
	minusBtn.Position = UDim2.new(0, 0, 0, 0)
	minusBtn.Parent = controlFrame

	local minusCorner = Instance.new("UICorner")
	minusCorner.CornerRadius = UDim.new(0, 4)
	minusCorner.Parent = minusBtn

	-- Value TextBox
	local valueBox = Instance.new("TextBox")
	valueBox.Name = "ValueBox"
	valueBox.Text = tostring(defaultValue)
	valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueBox.TextSize = 14
	valueBox.Font = Enum.Font.Gotham
	valueBox.BackgroundTransparency = 1
	valueBox.Size = UDim2.new(0.6, 0, 1, 0)
	valueBox.Position = UDim2.new(0.2, 0, 0, 0)
	valueBox.Parent = controlFrame

	-- Plus Button
	local plusBtn = Instance.new("TextButton")
	plusBtn.Name = "Plus"
	plusBtn.Text = "+"
	plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	plusBtn.TextSize = 18
	plusBtn.Font = Enum.Font.GothamBold
	plusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	plusBtn.Size = UDim2.new(0.2, 0, 1, 0)
	plusBtn.Position = UDim2.new(0.8, 0, 0, 0)
	plusBtn.Parent = controlFrame

	local plusCorner = Instance.new("UICorner")
	plusCorner.CornerRadius = UDim.new(0, 4)
	plusCorner.Parent = plusBtn

	-- Update function
	local function updateValue(newValue)
		newValue = tonumber(newValue) or defaultValue
		newValue = math.clamp(newValue, minVal, maxVal)

		valueBox.Text = string.format("%.1f", newValue)
		Config[configField] = newValue
	end

	-- Button events
	minusBtn.MouseButton1Click:Connect(function()
		local current = tonumber(valueBox.Text) or defaultValue
		updateValue(current - step)
	end)

	plusBtn.MouseButton1Click:Connect(function()
		local current = tonumber(valueBox.Text) or defaultValue
		updateValue(current + step)
	end)

	-- TextBox event
	valueBox.FocusLost:Connect(function()
		if valueBox.Text ~= "" then
			updateValue(valueBox.Text)
		end
	end)

	-- Initial update
	updateValue(defaultValue)

	container.Parent = parent
	return valueBox
end

-- Function untuk create toggle
local function CreateToggle(parent, label, configField, defaultValue, yOffset)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = configField .. "Toggle"
	toggleFrame.BackgroundTransparency = 1
	toggleFrame.Size = UDim2.new(1, 0, 0, 30)
	toggleFrame.Position = UDim2.new(0, 0, 0, yOffset)

	local toggleLabel = Instance.new("TextLabel")
	toggleLabel.Name = "Label"
	toggleLabel.Text = label
	toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleLabel.TextSize = 14
	toggleLabel.Font = Enum.Font.Gotham
	toggleLabel.BackgroundTransparency = 1
	toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
	toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
	toggleLabel.Parent = toggleFrame

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "Toggle"
	toggleBtn.Text = ""
	toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
	toggleBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
	toggleBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
	toggleBtn.Parent = toggleFrame

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0.5, 0)
	toggleCorner.Parent = toggleBtn

	local toggleCircle = Instance.new("Frame")
	toggleCircle.Name = "Circle"
	toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleCircle.Size = UDim2.new(0.5, 0, 1, 0)
	toggleCircle.Position = defaultValue and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
	toggleCircle.Parent = toggleBtn

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(0.5, 0)
	circleCorner.Parent = toggleCircle

	toggleBtn.MouseButton1Click:Connect(function()
		Config[configField] = not Config[configField]

		local targetPos = Config[configField] and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
		local targetColor = Config[configField] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)

		toggleCircle.Position = targetPos
		toggleBtn.BackgroundColor3 = targetColor
	end)

	toggleFrame.Parent = parent
	return toggleBtn
end

-- Create UI Sections
local yPosition = 0

-- Main Controls Section
local mainSection = CreateSection("MAIN CONTROLS", yPosition)
yPosition = yPosition + 40

CreateToggle(mainSection, "Auto Fish", "AutoFish", Config.AutoFish, 5)
CreateToggle(mainSection, "Instant Catch", "InstantCatch", Config.InstantCatch, 35)
CreateToggle(mainSection, "Auto Sell", "AutoSell", Config.AutoSell, 65)

-- Rarity Control Section
local raritySection = CreateSection("RARITY CONTROL", yPosition + 100)
yPosition = yPosition + 140

local minRarityBox = CreatePrecisionControl(raritySection, "Min Rarity:", "MinRarity", 1, 6, 1, Config.MinRarity, 5)
local maxRarityBox = CreatePrecisionControl(raritySection, "Max Rarity:", "MaxRarity", 1, 6, 1, Config.MaxRarity, 45)

-- Weight Control Section
local weightSection = CreateSection("WEIGHT CONTROL (KG)", yPosition + 100)
yPosition = yPosition + 140

local minWeightBox = CreatePrecisionControl(weightSection, "Min Weight:", "MinWeight", 0.1, 1000, 0.5, Config.MinWeight, 5)
local maxWeightBox = CreatePrecisionControl(weightSection, "Max Weight:", "MaxWeight", 0.1, 1000, 0.5, Config.MaxWeight, 45)

-- Sell Settings Section
local sellSection = CreateSection("SELL SETTINGS", yPosition + 100)
yPosition = yPosition + 140

local sellRarityBox = CreatePrecisionControl(sellSection, "Sell Below Rarity:", "SellBelowRarity", 1, 6, 1, Config.SellBelowRarity, 5)

-- Status Display
local statusSection = CreateSection("STATUS", yPosition + 100)
local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Text = "Ready"
statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
statusText.TextSize = 12
statusText.Font = Enum.Font.Gotham
statusText.BackgroundTransparency = 1
statusText.Size = UDim2.new(1, -10, 0, 50)
statusText.Position = UDim2.new(0, 5, 0, 5)
statusText.TextWrapped = true
statusText.Parent = statusSection

-- Action Buttons
local actionSection = CreateSection("ACTIONS", yPosition + 170)
yPosition = yPosition + 210

local startBtn = Instance.new("TextButton")
startBtn.Name = "StartButton"
startBtn.Text = "START FISHING"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 14
startBtn.Font = Enum.Font.GothamBold
startBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
startBtn.Size = UDim2.new(1, -20, 0, 40)
startBtn.Position = UDim2.new(0, 10, 0, 5)
startBtn.Parent = actionSection

local stopBtn = Instance.new("TextButton")
stopBtn.Name = "StopButton"
stopBtn.Text = "STOP FISHING"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextSize = 14
stopBtn.Font = Enum.Font.GothamBold
stopBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
stopBtn.Size = UDim2.new(1, -20, 0, 40)
stopBtn.Position = UDim2.new(0, 10, 0, 50)
stopBtn.Parent = actionSection

local injectBtn = Instance.new("TextButton")
injectBtn.Name = "InjectButton"
injectBtn.Text = "INJECT MODULE"
injectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
injectBtn.TextSize = 14
injectBtn.Font = Enum.Font.Gotham
injectBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
injectBtn.Size = UDim2.new(1, -20, 0, 40)
injectBtn.Position = UDim2.new(0, 10, 0, 95)
injectBtn.Parent = actionSection

-- Button Events
startBtn.MouseButton1Click:Connect(function()
	if not IsFishingActive then
		StartFishing()
		statusText.Text = "Fishing Active"
		statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
	end
end)

stopBtn.MouseButton1Click:Connect(function()
	StopFishing()
	statusText.Text = "Fishing Stopped"
	statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

injectBtn.MouseButton1Click:Connect(function()
	local success = InjectFishingModule()
	statusText.Text = success and "Module Injected Successfully" or "Injection Failed"
	statusText.TextColor3 = success and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
end)

-- Update Canvas Size
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 250)

-- === MAIN INITIALIZATION ===
task.wait(2) -- Wait for game to load

-- Auto-inject module
local injectSuccess = InjectFishingModule()
if injectSuccess then
	statusText.Text = "Module Injected - Ready"
	statusText.TextColor3 = Color3.fromRGB(0, 255, 0)

	-- Auto-start fishing jika config aktif
	if Config.AutoFish then
		task.wait(1)
		StartFishing()
	end
else
	statusText.Text = "Injection Failed - Manual Required"
	statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
end

-- === CLEANUP ===
game:BindToClose(function()
	StopFishing()
	if ScreenGui then
		ScreenGui:Destroy()
	end
end)

-- === DRAGGABLE WINDOW ===
local dragging
local dragInput
local dragStart
local startPos

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- === ANTI-AFK SYSTEM ===
local lastInput = tick()
local antiAFKConnection

local function ResetAFK()
	lastInput = tick()
end

-- Track user input
UserInputService.InputBegan:Connect(ResetAFK)
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(ResetAFK)

-- Auto move to prevent AFK
antiAFKConnection = game:GetService("RunService").Heartbeat:Connect(function()
	if tick() - lastInput > 60 then -- 1 minute no input
		VirtualInputManager:SendKeyEvent(true, "W", false, game)
		task.wait(0.1)
		VirtualInputManager:SendKeyEvent(false, "W", false, game)
		ResetAFK()
	end
end)

-- === FISH STATS TRACKER ===
local FishStats = {
	TotalCaught = 0,
	TotalWeight = 0,
	RarityCount = {
		Common = 0,
		Uncommon = 0,
		Rare = 0,
		Epic = 0,
		Legendary = 0,
		SECRET = 0
	}
}

-- Function to monitor fish catches
local function MonitorFishCatch()
	-- Hook player's inventory updates
	local leaderstats = LocalPlayer:WaitForChild("leaderstats")
	if leaderstats then
		local fishCaught = leaderstats:FindFirstChild("FishCaught")
		if fishCaught then
			local lastCount = fishCaught.Value

			fishCaught:GetPropertyChangedSignal("Value"):Connect(function()
				local newCount = fishCaught.Value
				if newCount > lastCount then
					FishStats.TotalCaught = newCount
					lastCount = newCount

					-- Update status
					statusText.Text = string.format("Fish Caught: %d", FishStats.TotalCaught)
				end
			end)
		end
	end
end

-- === ADVANCED FEATURES ===
local AdvancedSection = CreateSection("ADVANCED FEATURES", yPosition + 200)
local advancedY = 5

-- Fish Counter Display
local fishCountLabel = Instance.new("TextLabel")
fishCountLabel.Name = "FishCountLabel"
fishCountLabel.Text = "Total Fish: 0"
fishCountLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
fishCountLabel.TextSize = 12
fishCountLabel.Font = Enum.Font.Gotham
fishCountLabel.BackgroundTransparency = 1
fishCountLabel.Size = UDim2.new(1, 0, 0, 20)
fishCountLabel.Position = UDim2.new(0, 0, 0, advancedY)
fishCountLabel.Parent = AdvancedSection
advancedY = advancedY + 25

-- Quick Sell Button
local quickSellBtn = Instance.new("TextButton")
quickSellBtn.Name = "QuickSellButton"
quickSellBtn.Text = "QUICK SELL ALL"
quickSellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
quickSellBtn.TextSize = 12
quickSellBtn.Font = Enum.Font.GothamBold
quickSellBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
quickSellBtn.Size = UDim2.new(1, -20, 0, 30)
quickSellBtn.Position = UDim2.new(0, 10, 0, advancedY)
quickSellBtn.Parent = AdvancedSection

quickSellBtn.MouseButton1Click:Connect(function()
	local sellRemote = FishingSystem:FindFirstChild("SellFish")
	if sellRemote then
		statusText.Text = "Selling all fish..."

		-- Sell by rarity
		local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "SECRET"}
		for _, rarity in pairs(rarities) do
			ThrottledCall(sellRemote, rarity)
			task.wait(0.2)
		end

		statusText.Text = "All fish sold!"
		task.wait(2)
		statusText.Text = IsFishingActive and "Fishing Active" or "Ready"
	end
end)

advancedY = advancedY + 35

-- Preset Buttons
local presetFrame = Instance.new("Frame")
presetFrame.Name = "PresetFrame"
presetFrame.BackgroundTransparency = 1
presetFrame.Size = UDim2.new(1, 0, 0, 80)
presetFrame.Position = UDim2.new(0, 0, 0, advancedY)
presetFrame.Parent = AdvancedSection

local presets = {
	{"MAX", 6, 1000},
	{"LEGENDARY+", 5, 500},
	{"EPIC+", 4, 300},
	{"RARE+", 3, 100}
}

for i, preset in ipairs(presets) do
	local btn = Instance.new("TextButton")
	btn.Name = preset[1]
	btn.Text = preset[1]
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 11
	btn.Font = Enum.Font.Gotham
	btn.BackgroundColor3 = Color3.fromHSV(i/8, 0.8, 0.7)
	btn.Size = UDim2.new(0.25, -5, 1, 0)
	btn.Position = UDim2.new((i-1)*0.25, 0, 0, 0)
	btn.Parent = presetFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		Config.MaxRarity = preset[2]
		Config.MaxWeight = preset[3]

		maxRarityBox.Text = tostring(preset[2])
		maxWeightBox.Text = string.format("%.1f", preset[3])

		statusText.Text = string.format("Preset: %s (Rarity %d, Weight %d)", preset[1], preset[2], preset[3])
	end)
end

-- Update Canvas Size Again
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 350)

-- === REAL-TIME UPDATES ===
task.spawn(function()
	while task.wait(1) do
		if statusText then
			-- Update fish count if available
			local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
			if leaderstats then
				local fishStat = leaderstats:FindFirstChild("FishCaught")
				local cashStat = leaderstats:FindFirstChild("Cash")

				if fishStat then
					fishCountLabel.Text = string.format("Fish: %d", fishStat.Value)
				end

				if cashStat then
					-- Update title with cash
					Title.Text = string.format("🎣 FISHING EXPLOIT | Cash: $%d", cashStat.Value)
				end
			end

			-- Update fishing status
			if IsFishingActive then
				local timeActive = math.floor(tick() - (lastFishingStart or tick()))
				if timeActive > 0 then
					statusText.Text = string.format("Fishing: %d seconds", timeActive)
				end
			end
		end
	end
end)

-- === ERROR HANDLING ===
local function SafeRequire(module)
	local success, result = pcall(require, module)
	if success then
		return result
	end
	return nil
end

-- Start monitoring
MonitorFishCatch()

-- Set initial fishing start time
lastFishingStart = tick()

-- Hide/show toggle (F9 key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.F9 then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

-- Success notification
statusText.Text = "Exploit Successfully Loaded!"
statusText.TextColor3 = Color3.fromRGB(0, 255, 0)

-- Auto-cleanup on player leaving
LocalPlayer.CharacterRemoving:Connect(function()
	StopFishing()
	if antiAFKConnection then
		antiAFKConnection:Disconnect()
	end
end)
