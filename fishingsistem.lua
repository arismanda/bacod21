-- Fishing Simulator Exploit v6.0
-- Updated for latest game structure
-- Full compatibility with new module

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")

-- === ANALYZED GAME STRUCTURE ===
-- Berdasarkan decompiled code:
-- 1. Rarity: "SECRET" (bukan "Unknown")
-- 2. Base Price: 10 per kg
-- 3. Size Bonus: small(0-5), medium(5-30), large(30-60), huge(60-999)
-- 4. Rarity Multiplier: Common=1, Uncommon=1.5, Rare=3.5, Epic=5, Legendary=7, SECRET=10
-- 5. FishTable: probability berbeda per rarity

-- === CONFIGURATION ===
local Config = {
    AutoFish = true,
    InstantCatch = true,
    
    -- Weight Control
    MinWeight = 1.0,
    MaxWeight = 1000.0,
    ForceMaxWeight = false,
    
    -- Rarity Control
    MinRarity = 1,  -- 1=Common, 2=Uncommon, 3=Rare, 4=Epic, 5=Legendary, 6=SECRET
    MaxRarity = 6,
    ForceSECRET = true,
    
    -- Auto Features
    AutoSell = false,
    SellBelowRarity = 3,  -- Sell below Rare (1=Common, 2=Uncommon, 3=Rare)
    
    -- Stealth
    HumanDelay = true,
    RandomFailures = true,
    FailureRate = 5,  -- 5% failure rate
}

-- === RARITY MAPPING ===
local RarityMap = {
    [1] = {Name = "Common", Color = Color3.fromRGB(200, 200, 200), Order = 1},
    [2] = {Name = "Uncommon", Color = Color3.fromRGB(30, 255, 30), Order = 2},
    [3] = {Name = "Rare", Color = Color3.fromRGB(30, 100, 255), Order = 3},
    [4] = {Name = "Epic", Color = Color3.fromRGB(160, 30, 255), Order = 4},
    [5] = {Name = "Legendary", Color = Color3.fromRGB(255, 128, 0), Order = 5},
    [6] = {Name = "SECRET", Color = Color3.fromRGB(0, 255, 119), Order = 6}
}

local RarityNameToNumber = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    SECRET = 6
}

-- === MODULE INJECTION ===
local OriginalModule = nil
local HookedFunctions = {}

local function InjectIntoModule()
    -- Cari module utama
    local moduleScript = FishingSystem:FindFirstChildWhichIsA("ModuleScript")
    if not moduleScript then
        -- Cari di semua tempat
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("ModuleScript") and (obj.Name:find("Fish") or obj.Name:find("Fishing")) then
                moduleScript = obj
                break
            end
        end
    end
    
    if moduleScript then
        local success, moduleTable = pcall(require, moduleScript)
        if success and type(moduleTable) == "table" then
            OriginalModule = moduleTable
            
            -- === HOOK GenerateFishWeight ===
            if moduleTable.GenerateFishWeight then
                HookedFunctions.GenerateFishWeight = moduleTable.GenerateFishWeight
                
                moduleTable.GenerateFishWeight = function(fishData, rodLuck, maxWeight)
                    -- Original calculation
                    local originalResult = HookedFunctions.GenerateFishWeight(fishData, rodLuck, maxWeight)
                    
                    -- Apply custom weight range
                    if Config.ForceMaxWeight then
                        -- Force maximum weight untuk fish SECRET
                        if fishData.rarity == "SECRET" then
                            return fishData.maxKg or 1000
                        end
                    end
                    
                    -- Custom weight range
                    local minKg = math.max(Config.MinWeight, fishData.minKg or 0.5)
                    local maxKgAllowed = math.min(Config.MaxWeight, fishData.maxKg or 1000, maxWeight or 1000)
                    
                    if minKg > maxKgAllowed then
                        return maxKgAllowed
                    end
                    
                    -- Generate weight dalam range
                    local weight = minKg + (math.random() * (maxKgAllowed - minKg))
                    weight = math.floor(weight * 10 + 0.5) / 10
                    
                    return weight
                end
                
                print("[HOOK] GenerateFishWeight hooked")
            end
            
            -- === HOOK GetRodConfig (untuk bypass rod limits) ===
            if moduleTable.GetRodConfig then
                HookedFunctions.GetRodConfig = moduleTable.GetRodConfig
                
                moduleTable.GetRodConfig = function(rodName)
                    local config = HookedFunctions.GetRodConfig(rodName)
                    
                    -- Boost rod stats
                    if Config.InstantCatch then
                        config.baseLuck = config.baseLuck * 2
                        config.maxWeight = math.max(config.maxWeight, Config.MaxWeight)
                    end
                    
                    return config
                end
                
                print("[HOOK] GetRodConfig hooked")
            end
            
            -- === HOOK CalculateFishPrice ===
            if moduleTable.CalculateFishPrice then
                HookedFunctions.CalculateFishPrice = moduleTable.CalculateFishPrice
                
                moduleTable.CalculateFishPrice = function(weight, rarity)
                    local price = HookedFunctions.CalculateFishPrice(weight, rarity)
                    
                    -- Price multiplier
                    local multiplier = 1.0
                    if rarity == "SECRET" then multiplier = 2.0
                    elseif rarity == "Legendary" then multiplier = 1.5
                    elseif rarity == "Epic" then multiplier = 1.3
                    end
                    
                    return math.floor(price * multiplier + 0.5)
                end
                
                print("[HOOK] CalculateFishPrice hooked")
            end
            
            -- === HOOK Fish Probability System ===
            -- Cari function yang handle fish selection
            if moduleTable.GetFishByRarity then
                HookedFunctions.GetFishByRarity = moduleTable.GetFishByRarity
                
                moduleTable.GetFishByRarity = function(rarity, arg2)
                    -- Force SECRET rarity jika diinginkan
                    if Config.ForceSECRET and Config.MaxRarity == 6 then
                        rarity = "SECRET"
                    end
                    
                    return HookedFunctions.GetFishByRarity(rarity, arg2)
                end
                
                print("[HOOK] GetFishByRarity hooked")
            end
            
            return true
        end
    end
    
    return false
end

-- === FISHING REMOTE DETECTION ===
local FishingRemotes = {
    CastLine = nil,
    CatchFish = nil,
    SellFish = nil,
    ReelIn = nil
}

local function FindFishingRemotes()
    for name, _ in pairs(FishingRemotes) do
        FishingRemotes[name] = FishingSystem:FindFirstChild(name)
    end
    
    -- Juga cari alternatif names
    if not FishingRemotes.CastLine then
        FishingRemotes.CastLine = FishingSystem:FindFirstChild("StartFishing")
    end
    
    if not FishingRemotes.CatchFish then
        FishingRemotes.CatchFish = FishingSystem:FindFirstChild("CompleteFishing")
    end
end

-- === NETWORK THROTTLING ===
local NetworkStats = {
    LastCall = 0,
    CallCount = 0,
    CallHistory = {}
}

local function ThrottledCall(remote, ...)
    local args = {...}
    local currentTime = tick()
    
    -- Rate limiting
    if currentTime - NetworkStats.LastCall < 0.3 then
        task.wait(0.3 - (currentTime - NetworkStats.LastCall) + math.random(10, 50)/1000)
    end
    
    -- Simulate occasional failure
    if Config.RandomFailures and math.random(1, 100) <= Config.FailureRate then
        if Config.HumanDelay then
            task.wait(math.random(500, 1500)/1000)
        end
        return false, "Simulated failure"
    end
    
    -- Execute call
    local success, result = pcall(function()
        if remote:IsA("RemoteEvent") then
            return remote:FireServer(unpack(args))
        elseif remote:IsA("RemoteFunction") then
            return remote:InvokeServer(unpack(args))
        end
    end)
    
    NetworkStats.LastCall = tick()
    NetworkStats.CallCount = NetworkStats.CallCount + 1
    
    -- Record call
    table.insert(NetworkStats.CallHistory, {
        Time = tick(),
        Remote = remote.Name,
        Success = success
    })
    
    -- Keep only last 100 calls
    if #NetworkStats.CallHistory > 100 then
        table.remove(NetworkStats.CallHistory, 1)
    end
    
    return success, result
end

-- === AUTO FISHING SYSTEM ===
local IsFishingActive = false
local FishingThread = nil
local TotalFishCaught = 0

local function StartAutoFishing()
    if IsFishingActive then return end
    
    FindFishingRemotes()
    
    if not FishingRemotes.CastLine or not FishingRemotes.CatchFish then
        warn("[ERROR] Fishing remotes not found!")
        return
    end
    
    IsFishingActive = true
    
    FishingThread = task.spawn(function()
        while IsFishingActive do
            -- Human-like delay sebelum mulai
            if Config.HumanDelay then
                local preDelay = math.random(500, 2000) / 1000
                task.wait(preDelay)
            end
            
            -- Cast line
            local castSuccess, castResult = ThrottledCall(FishingRemotes.CastLine)
            
            if castSuccess then
                -- Wait for bite dengan random timing
                local biteWait = math.random(800, 2500) / 1000
                if Config.HumanDelay then
                    biteWait = biteWait + math.random(-200, 300) / 1000
                end
                task.wait(biteWait)
                
                -- Catch fish
                local catchSuccess, catchResult = ThrottledCall(FishingRemotes.CatchFish)
                
                if catchSuccess then
                    TotalFishCaught = TotalFishCaught + 1
                    
                    -- Auto sell jika aktif
                    if Config.AutoSell and FishingRemotes.SellFish then
                        local sellRarities = {}
                        for i = 1, Config.SellBelowRarity do
                            local rarityName = RarityMap[i] and RarityMap[i].Name
                            if rarityName then
                                table.insert(sellRarities, rarityName)
                            end
                        end
                        
                        for _, rarity in ipairs(sellRarities) do
                            task.wait(0.1)
                            ThrottledCall(FishingRemotes.SellFish, rarity)
                        end
                    end
                end
            end
            
            -- Delay antara fishing attempts
            local betweenDelay = math.random(1500, 4000) / 1000
            if Config.HumanDelay then
                betweenDelay = betweenDelay + math.random(-500, 500) / 1000
            end
            task.wait(betweenDelay)
        end
    end)
    
    print("[AUTO FISH] Started")
end

local function StopAutoFishing()
    IsFishingActive = false
    if FishingThread then
        task.cancel(FishingThread)
        FishingThread = nil
    end
    print("[AUTO FISH] Stopped")
end

-- === GUI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishingExploitUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "🎣 FISHING EXPLOIT v6.0"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 20
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
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ScrollFrame.Parent = MainFrame

-- Function untuk create section
local function CreateSection(title, yPosition, height)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    section.Size = UDim2.new(1, 0, 0, height or 30)
    section.Position = UDim2.new(0, 0, 0, yPosition)
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "SectionTitle"
    sectionTitle.Text = "  " .. title
    sectionTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    sectionTitle.TextSize = 14
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Size = UDim2.new(1, 0, 0, 30)
    sectionTitle.Parent = section
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 4)
    sectionCorner.Parent = section
    
    section.Parent = ScrollFrame
    return section, sectionTitle
end

-- Function untuk create control dengan +/- buttons
local function CreateControl(parent, label, configField, minVal, maxVal, step, defaultValue, yOffset, isInteger, formatFunc)
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
    minusBtn.TextSize = 20
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
    valueBox.PlaceholderText = "Enter value"
    valueBox.Text = formatFunc and formatFunc(defaultValue) or tostring(defaultValue)
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
    plusBtn.TextSize = 20
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
        local numValue = tonumber(newValue)
        if not numValue then
            numValue = defaultValue
        end
        
        numValue = math.clamp(numValue, minVal, maxVal)
        
        if isInteger then
            numValue = math.floor(numValue)
        end
        
        Config[configField] = numValue
        
        if formatFunc then
            valueBox.Text = formatFunc(numValue)
        else
            valueBox.Text = isInteger and tostring(numValue) or string.format("%.1f", numValue)
        end
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
    
    container.Parent = parent
    return container, valueBox
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

-- Build GUI
local currentY = 0

-- Main Controls
local mainSection = CreateSection("MAIN CONTROLS", currentY, 110)
currentY = currentY + 40

CreateToggle(mainSection, "Auto Fishing", "AutoFish", Config.AutoFish, 35)
CreateToggle(mainSection, "Instant Catch", "InstantCatch", Config.InstantCatch, 65)
CreateToggle(mainSection, "Auto Sell", "AutoSell", Config.AutoSell, 95)

-- Rarity Control
local raritySection = CreateSection("RARITY CONTROL", currentY + 80, 90)
currentY = currentY + 120

local minRarityBox = CreateControl(raritySection, "Min Rarity:", "MinRarity", 1, 6, 1, Config.MinRarity, 35, true, 
    function(value) return RarityMap[value] and RarityMap[value].Name or "Common" end)
local maxRarityBox = CreateControl(raritySection, "Max Rarity:", "MaxRarity", 1, 6, 1, Config.MaxRarity, 75, true,
    function(value) return RarityMap[value] and RarityMap[value].Name or "SECRET" end)

-- Weight Control
local weightSection = CreateSection("WEIGHT CONTROL (KG)", currentY + 80, 90)
currentY = currentY + 120

local minWeightBox = CreateControl(weightSection, "Min Weight:", "MinWeight", 0.1, 1000, 0.5, Config.MinWeight, 35, false)
local maxWeightBox = CreateControl(weightSection, "Max Weight:", "MaxWeight", 0.1, 1000, 0.5, Config.MaxWeight, 75, false)

-- Sell Settings
local sellSection = CreateSection("SELL SETTINGS", currentY + 80, 90)
currentY = currentY + 120

local sellRarityBox = CreateControl(sellSection, "Sell Below:", "SellBelowRarity", 1, 6, 1, Config.SellBelowRarity, 35, true,
    function(value) return "Sell < " .. (RarityMap[value] and RarityMap[value].Name or "Rare") end)

CreateToggle(sellSection, "Force Max Weight", "ForceMaxWeight", Config.ForceMaxWeight, 65)
CreateToggle(sellSection, "Force SECRET", "ForceSECRET", Config.ForceSECRET, 95)

-- Stealth Settings
local stealthSection = CreateSection("STEALTH SETTINGS", currentY + 80, 90)
currentY = currentY + 120

CreateToggle(stealthSection, "Human Delay", "HumanDelay", Config.HumanDelay, 35)
CreateToggle(stealthSection, "Random Failures", "RandomFailures", Config.RandomFailures, 65)

local failureRateBox = CreateControl(stealthSection, "Failure %:", "FailureRate", 0, 20, 1, Config.FailureRate, 95, true)

-- Action Buttons
local actionSection = CreateSection("ACTIONS", currentY + 80, 140)
currentY = currentY + 150

local startBtn = Instance.new("TextButton")
startBtn.Name = "StartButton"
startBtn.Text = "▶ START FISHING"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 16
startBtn.Font = Enum.Font.GothamBold
startBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
startBtn.Size = UDim2.new(1, -20, 0, 40)
startBtn.Position = UDim2.new(0, 10, 0, 35)
startBtn.Parent = actionSection

local stopBtn = Instance.new("TextButton")
stopBtn.Name = "StopButton"
stopBtn.Text = "⏹ STOP FISHING"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextSize = 16
stopBtn.Font = Enum.Font.GothamBold
stopBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
stopBtn.Size = UDim2.new(1, -20, 0, 40)
stopBtn.Position = UDim2.new(0, 10, 0, 80)
stopBtn.Parent = actionSection

local injectBtn = Instance.new("TextButton")
injectBtn.Name = "InjectButton"
injectBtn.Text = "⚡ INJECT MODULE"
injectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
injectBtn.TextSize = 14
injectBtn.Font = Enum.Font.Gotham
injectBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
injectBtn.Size = UDim2.new(1, -20, 0, 40)
injectBtn.Position = UDim2.new(0, 10, 0, 125)
injectBtn.Parent = actionSection

-- Status Display
local statusSection = CreateSection("STATUS", currentY + 80, 60)
local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Text = "Ready to inject..."
statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
statusText.TextSize = 12
statusText.Font = Enum.Font.Gotham
statusText.BackgroundTransparency = 1
statusText.Size = UDim2.new(1, -10, 1, -10)
statusText.Position = UDim2.new(0, 5, 0, 5)
statusText.TextWrapped = true
statusText.Parent = statusSection

-- Stats Display
local statsSection = CreateSection("STATS", currentY + 150, 40)
local statsText = Instance.new("TextLabel")
statsText.Name = "StatsText"
statsText.Text = "Fish Caught: 0 | Calls: 0"
statsText.TextColor3 = Color3.fromRGB(200, 200, 255)
statsText.TextSize = 11
statsText.Font = Enum.Font.Gotham
statsText.BackgroundTransparency = 1
statsText.Size = UDim2.new(1, -10, 1, -10)
statsText.Position = UDim2.new(0, 5, 0, 5)
statsText.Parent = statsSection

-- Update Canvas Size
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentY + 200)

-- Button Events
startBtn.MouseButton1Click:Connect(function()
    if not IsFishingActive then
        StartAutoFishing()
        statusText.Text = "Fishing Active"
        statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    StopAutoFishing()
    statusText.Text = "Fishing Stopped"
    statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

injectBtn.MouseButton1Click:Connect(function()
    local success = InjectIntoModule()
    if success then
        statusText.Text = "Module Successfully Injected!"
        statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        statusText.Text = "Injection Failed - Module Not Found"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- === ANTI-AFK ===
local lastInput = tick()
UserInputService.InputBegan:Connect(function()
    lastInput = tick()
end)

task.spawn(function()
    while true do
        task.wait(30)
        if tick() - lastInput > 60 then
            VirtualInputManager:SendKeyEvent(true, "Space", false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, "Space", false, game)
            lastInput = tick()
        end
    end
end)

-- === STATS UPDATER ===
task.spawn(function()
    while task.wait(1) do
        statsText.Text = string.format("Fish: %d | Calls: %d | Active: %s", 
            TotalFishCaught, 
            NetworkStats.CallCount,
            IsFishingActive and "YES" or "NO")
        
        -- Update cash display jika ada
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            local cash = leaderstats:FindFirstChild("Cash")
            if cash then
                Title.Text = string.format("🎣 FISHING EXPLOIT | Cash: $%d", cash.Value)
            end
        end
    end
end)

-- === INITIALIZATION ===
task.wait(2) -- Wait for game load

-- Auto-inject
local injectSuccess = InjectIntoModule()
if injectSuccess then
    statusText.Text = "Module Injected - Ready to Fish!"
    statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
    
    -- Auto-start jika config aktif
    if Config.AutoFish then
        task.wait(1)
        StartAutoFishing()
    end
else
    statusText.Text = "Auto-Inject Failed - Click Inject Button"
    statusText.TextColor3 = Color3.fromRGB(255, 200, 0)
end

-- Find remotes
FindFishingRemotes()

-- === DRAGGABLE WINDOW ===
local dragging = false
local dragInput, dragStart, startPos

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

-- === HIDE/SHOW TOGGLE ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F9 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- === CLEANUP ===
game:BindToClose(function()
    StopAutoFishing()
    if ScreenGui then
        ScreenGui:Destroy()
    end
end)

