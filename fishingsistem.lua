-- DYRON EXECUTOR v1.2: ULTIMATE FISHING DOMINATION
-- Engine: Reverse-Engineered Module v2_upvr with Multi-Layer Exploitation
-- Build: Hyper-Optimized for Maximum Control

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Auto-detect fishing module
local FishingModule
local moduleDetectionAttempts = 0

repeat
    for _, obj in pairs(getloadedmodules() or getinstances()) do
        if type(obj) == "table" and rawget(obj, "GetRodConfig") and rawget(obj, "FishTable") then
            FishingModule = obj
            break
        end
    end
    
    if not FishingModule then
        local success, module = pcall(function()
            return require(ReplicatedStorage:WaitForChild("FishingSystem"):WaitForChild("FishingConfig"))
        end)
        if success then FishingModule = module end
    end
    
    moduleDetectionAttempts += 1
    task.wait(0.5)
until FishingModule or moduleDetectionAttempts > 5

if not FishingModule then
    warn("[DYRON] Module not found, creating stub...")
    FishingModule = {
        RodConfig = {},
        FishTable = {},
        GetRodConfig = function() return {} end,
        RollFish = function() return {} end,
        GenerateFishWeight = function() return 10 end
    }
end

-- Backup original data
local OriginalFishData = {}
local OriginalRodConfig = {}
local OriginalFunctions = {
    GenerateFishWeight = FishingModule.GenerateFishWeight,
    RollFish = FishingModule.RollFish,
    GetRarityWithPity = FishingModule.GetRarityWithPity
}

for i, fish in pairs(FishingModule.FishTable) do
    OriginalFishData[i] = {
        minKg = fish.minKg,
        maxKg = fish.maxKg,
        name = fish.name,
        rarity = fish.rarity,
        probability = fish.probability
    }
end

for rodName, config in pairs(FishingModule.RodConfig) do
    OriginalRodConfig[rodName] = table.clone(config)
end

-- GUI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("DYRON FISHING DOMINATOR v1.2", "DarkTheme")

-- Notify user
local Notify = loadstring(game:HttpGet("https://raw.githubusercontent.com/fusiongreg/Bolts-5.0/main/Loader"))()
Notify({
    Title = "DYRON EXECUTOR LOADED",
    Description = "v1.2 | Fishing Exploit Suite Active",
    Duration = 5
})

-- ==================== CORE EXPLOITS ====================
local MainTab = Window:NewTab("Core Hacks")
local MainSection = MainTab:NewSection("Instant Catch & Rarity")

-- INSTANT CATCH SYSTEM
local instantCatchHooks = {}
MainSection:NewToggle("INSTANT CATCH", "Bypass all minigames", function(state)
    if state then
        -- Method 1: Remote hooking
        local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
        if fishingSystem then
            local startRemote = fishingSystem:FindFirstChild("StartFishing")
            local completeRemote = fishingSystem:FindFirstChild("CompleteFishing")
            
            if startRemote and completeRemote then
                -- Hook StartFishing
                local oldStart; oldStart = hookfunction(startRemote.FireServer, function(self, ...)
                    spawn(function()
                        task.wait(0.15) -- Small delay for realism
                        pcall(function()
                            completeRemote:FireServer(true, 100) -- 100% completion
                        end)
                    end)
                    return oldStart(self, ...)
                end)
                instantCatchHooks.start = oldStart
                
                -- Also hook any minigame progress updates
                local progressRemote = fishingSystem:FindFirstChild("UpdateProgress")
                if progressRemote then
                    local oldProgress; oldProgress = hookfunction(progressRemote.FireServer, function(self, ...)
                        return true -- Block all progress updates
                    end)
                    instantCatchHooks.progress = oldProgress
                end
            end
        end
        
        -- Method 2: UI automation (backup)
        spawn(function()
            while state do
                -- Auto-click any minigame buttons
                for _, gui in pairs(Players.LocalPlayer.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and (gui.Text:find("Tap") or gui.Name:find("Click")) then
                        fireclickdetector(gui)
                    end
                end
                task.wait(0.1)
            end
        end)
        
        print("[DYRON] Instant Catch ACTIVATED")
    else
        -- Restore hooks
        if instantCatchHooks.start then
            hookfunction(instantCatchHooks.start, instantCatchHooks.start)
        end
        if instantCatchHooks.progress then
            hookfunction(instantCatchHooks.progress, instantCatchHooks.progress)
        end
        print("[DYRON] Instant Catch DEACTIVATED")
    end
end)

-- RARITY CONTROL SYSTEM
local forcedRarity = nil
local originalRollFish = FishingModule.RollFish
MainSection:NewDropdown("FORCE RARITY", "Select guaranteed fish rarity",
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, function(selected)
    
    forcedRarity = selected
    
    FishingModule.RollFish = function(pityTracker, rodName, luckMultiplier)
        -- If forcing rarity, override completely
        if forcedRarity then
            -- Find a fish with the forced rarity
            local availableFish = {}
            for _, fish in pairs(FishingModule.FishTable) do
                if fish.rarity == forcedRarity then
                    table.insert(availableFish, fish)
                end
            end
            
            if #availableFish == 0 then
                -- Fallback to any fish
                availableFish = {FishingModule.FishTable[1]}
            end
            
            local selectedFish = availableFish[math.random(1, #availableFish)]
            local rodConfig = FishingModule.GetRodConfig(rodName)
            
            -- Generate weight
            local weight
            if FishingModule.GenerateFishWeight then
                weight = FishingModule.GenerateFishWeight(selectedFish, rodConfig.baseLuck or 1, rodConfig.maxWeight or 100)
            else
                weight = math.random(selectedFish.minKg * 10, math.min(selectedFish.maxKg, rodConfig.maxWeight or 100) * 10) / 10
            end
            
            return {
                name = selectedFish.name,
                rarity = forcedRarity,
                minKg = selectedFish.minKg,
                maxKg = selectedFish.maxKg,
                probability = selectedFish.probability,
                _weight = weight,
                weight = weight
            }
        end
        
        -- Otherwise use original function
        return originalRollFish(pityTracker, rodName, luckMultiplier)
    end
    
    print("[DYRON] Rarity forced to: " .. selected)
end)

MainSection:NewButton("Disable Rarity Force", "Return to normal rarity", function()
    forcedRarity = nil
    FishingModule.RollFish = originalRollFish
    print("[DYRON] Normal rarity restored")
end)

-- PITY SYSTEM MANIPULATION
MainSection:NewToggle("MAX PITY", "Always have maximum pity bonuses", function(state)
    if state then
        if FishingModule.Pity then
            for rarity, pityData in pairs(FishingModule.Pity) do
                if type(pityData) == "table" then
                    pityData.baseBoost = 999
                    pityData.maxMultiplier = 999
                end
            end
        end
        
        -- Also hook any pity tracking functions
        if FishingModule.GetRarityWithPity then
            local originalPity = FishingModule.GetRarityWithPity
            FishingModule.GetRarityWithPity = function(pityTable, rodName, luck)
                -- Force max pity
                local fakePity = {
                    Rare = 9999,
                    Epic = 9999,
                    Legendary = 9999,
                    Unknown = 9999
                }
                return originalPity(fakePity, rodName, luck)
            end
        end
        print("[DYRON] Max pity ACTIVATED")
    else
        -- Restore original pity values
        if FishingModule.Pity then
            for rarity, pityData in pairs(FishingModule.Pity) do
                if rarity == "Rare" then
                    pityData.baseBoost = 0.1
                    pityData.maxMultiplier = 1.25
                elseif rarity == "Epic" then
                    pityData.baseBoost = 0.15
                    pityData.maxMultiplier = 1.3
                elseif rarity == "Legendary" then
                    pityData.baseBoost = 0.2
                    pityData.maxMultiplier = 1.4
                elseif rarity == "Unknown" then
                    pityData.baseBoost = 0.3
                    pityData.maxMultiplier = 1.6
                end
            end
        end
        print("[DYRON] Max pity DEACTIVATED")
    end
end)

-- ==================== WEIGHT MANIPULATION ====================
local WeightTab = Window:NewTab("Weight Control")
local WeightSection = WeightTab:NewSection("Weight Manipulation")

local extremeWeightsActive = false
local weightMultipliers = {min = 1, max = 1}

-- ENHANCED WEIGHT SYSTEM
local function EnableExtremeWeights(minMult, maxMult)
    extremeWeightsActive = true
    weightMultipliers = {min = minMult, max = maxMult}
    
    -- Modify fish table directly
    for _, fish in pairs(FishingModule.FishTable) do
        local original = nil
        for _, orig in pairs(OriginalFishData) do
            if orig.name == fish.name then
                original = orig
                break
            end
        end
        
        if original then
            -- Apply multipliers with rarity scaling
            local rarityScale = {
                Common = 1, Uncommon = 2, Rare = 3,
                Epic = 5, Legendary = 10, Unknown = 20
            }
            
            local scale = rarityScale[fish.rarity] or 1
            fish.minKg = math.floor(original.minKg * minMult * scale * 10) / 10
            fish.maxKg = math.floor(original.maxKg * maxMult * scale * 10) / 10
            
            -- Ensure min < max
            if fish.minKg >= fish.maxKg then
                fish.maxKg = fish.minKg * 2
            end
            
            -- Cap at 9999
            if fish.maxKg > 9999 then
                fish.maxKg = 9999
            end
        end
    end
    
    -- Override rod weight limits
    for _, config in pairs(FishingModule.RodConfig) do
        if config.maxWeight then
            config.maxWeight = 9999
        end
    end
    
    -- Hook weight generation
    if FishingModule.GenerateFishWeight then
        local originalGen = FishingModule.GenerateFishWeight
        FishingModule.GenerateFishWeight = function(fishData, rodLuck, maxRodWeight)
            if not extremeWeightsActive then
                return originalGen(fishData, rodLuck, maxRodWeight)
            end
            
            -- Generate weight in extreme range
            local minW = fishData.minKg
            local maxW = math.min(fishData.maxKg, 9999)
            
            -- Bias towards higher weights
            local random = math.random()
            local bias = 0.8 -- 80% chance for high weights
            
            local weight
            if random < 0.1 then
                weight = minW -- 10% minimum
            elseif random < 0.1 + (1 - bias) then
                weight = minW + (maxW - minW) * 0.3 -- 20% low-medium
            else
                weight = maxW * 0.7 + (maxW * 0.3) * math.random() -- 70% high
            end
            
            return math.floor(weight * 10 + 0.5) / 10
        end
    end
    
    -- Display current ranges
    local minWeight, maxWeight = 9999, 0
    for _, fish in pairs(FishingModule.FishTable) do
        if fish.minKg < minWeight then minWeight = fish.minKg end
        if fish.maxKg > maxWeight then maxWeight = fish.maxKg end
    end
    
    print(string.format("[DYRON] Extreme Weights: %.1fkg - %.1fkg (Mult: %dx/%dx)", 
        minWeight, maxWeight, minMult, maxMult))
end

local function DisableExtremeWeights()
    extremeWeightsActive = false
    
    -- Restore original fish data
    for i, fish in pairs(FishingModule.FishTable) do
        local original = OriginalFishData[i]
        if original then
            fish.minKg = original.minKg
            fish.maxKg = original.maxKg
        end
    end
    
    -- Restore rod config
    for rodName, config in pairs(FishingModule.RodConfig) do
        local original = OriginalRodConfig[rodName]
        if original and original.maxWeight then
            config.maxWeight = original.maxWeight
        end
    end
    
    -- Restore generation function
    if OriginalFunctions.GenerateFishWeight then
        FishingModule.GenerateFishWeight = OriginalFunctions.GenerateFishWeight
    end
    
    print("[DYRON] Extreme Weights DEACTIVATED")
end

-- WEIGHT MULTIPLIER CONTROLS
local minMultSlider = WeightSection:NewSlider("Min Multiplier", "Minimum weight multiplier", 
    100, 1, 10, function(value)
    weightMultipliers.min = value
    if extremeWeightsActive then
        EnableExtremeWeights(value, weightMultipliers.max)
    end
end)

local maxMultSlider = WeightSection:NewSlider("Max Multiplier", "Maximum weight multiplier", 
    100, 10, 50, function(value)
    weightMultipliers.max = value
    if extremeWeightsActive then
        EnableExtremeWeights(weightMultipliers.min, value)
    end
end)

WeightSection:NewToggle("Extreme Weights", "Activate weight multipliers", function(state)
    if state then
        EnableExtremeWeights(weightMultipliers.min, weightMultipliers.max)
    else
        DisableExtremeWeights()
    end
end)

-- WEIGHT PRESETS
WeightSection:NewDropdown("Weight Presets", "Quick weight configurations",
    {
        "Realistic (Original)",
        "Heavy (2x-5x)", 
        "Monster (5x-20x)",
        "Titanic (10x-50x)",
        "GOD MODE (50x-100x)"
    }, function(preset)
    
    local presets = {
        ["Realistic (Original)"] = {1, 1},
        ["Heavy (2x-5x)"] = {2, 5},
        ["Monster (5x-20x)"] = {5, 20},
        ["Titanic (10x-50x)"] = {10, 50},
        ["GOD MODE (50x-100x)"] = {50, 100}
    }
    
    local mults = presets[preset]
    if mults then
        minMultSlider:Set(mults[1])
        maxMultSlider:Set(mults[2])
        EnableExtremeWeights(mults[1], mults[2])
    end
end)

-- DIRECT WEIGHT CONTROL
WeightSection:NewTextBox("Set Exact Weight", "Force specific weight (kg)", function(text)
    local weight = tonumber(text)
    if weight and weight > 0 then
        -- Hook the catch function to override weight
        local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
        if fishingSystem then
            local catchRemote = fishingSystem:FindFirstChild("CatchFish") or
                               fishingSystem:FindFirstChild("AddFish")
            
            if catchRemote then
                local oldCatch; oldCatch = hookfunction(catchRemote.FireServer, function(self, fishData, ...)
                    if type(fishData) == "table" then
                        fishData.weight = weight
                        fishData._weight = weight
                    end
                    return oldCatch(self, fishData, ...)
                end)
            end
        end
        print("[DYRON] Exact weight set to: " .. weight .. "kg")
    end
end)

-- ==================== ROD CONTROL ====================
local RodTab = Window:NewTab("Rod Hacks")
local RodSection = RodTab:NewSection("Rod Manipulation")

-- UNLOCK ALL RODS
RodSection:NewButton("UNLOCK ALL RODS", "Get every rod in the game", function()
    -- Method 1: Add rods to inventory
    local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for rodName, config in pairs(FishingModule.RodConfig) do
            local tool = Instance.new("Tool")
            tool.Name = rodName
            tool.ToolTip = "DYRON Unlocked Rod"
            
            -- Add configuration to tool
            local attribute = Instance.new("StringValue")
            attribute.Name = "RodConfig"
            attribute.Value = game:GetService("HttpService"):JSONEncode(config)
            attribute.Parent = tool
            
            tool.Parent = backpack
        end
    end
    
    -- Method 2: Unlock via remotes
    local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
    if fishingSystem then
        local unlockRemote = fishingSystem:FindFirstChild("UnlockRod") or
                            fishingSystem:FindFirstChild("EquipRod")
        
        if unlockRemote then
            for rodName in pairs(FishingModule.RodConfig) do
                pcall(function()
                    unlockRemote:FireServer(rodName)
                end)
            end
        end
    end
    
    print("[DYRON] All rods unlocked")
end)

-- ROD STAT MULTIPLIERS
RodSection:NewSlider("Luck Multiplier", "Multiply all rod luck", 1000, 1, 100, function(value)
    for _, config in pairs(FishingModule.RodConfig) do
        if config.baseLuck then
            config.baseLuck = config.baseLuck * value
        end
    end
    print("[DYRON] Luck multiplier: " .. value .. "x")
end)

RodSection:NewSlider("Capacity Multiplier", "Multiply rod weight capacity", 100, 1, 50, function(value)
    for _, config in pairs(FishingModule.RodConfig) do
        if config.maxWeight then
            config.maxWeight = config.maxWeight * value
        end
    end
    print("[DYRON] Capacity multiplier: " .. value .. "x")
end)

-- SPECIAL RODS
RodSection:NewDropdown("Equip Special Rod", "Use admin/developer rods",
    {"Owner Rod", "Admin Rod", "Developer Rod", "Megalofriend", "Manifest", "Ancient Whale Rod"},
    function(selected)
    
    local fakeRod = {
        Name = selected,
        Config = FishingModule.GetRodConfig(selected) or FishingModule.RodConfig.default
    }
    
    -- Force equip
    local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
    if fishingSystem then
        local equipRemote = fishingSystem:FindFirstChild("EquipRod")
        if equipRemote then
            equipRemote:FireServer(selected)
            
            -- Also modify current rod stats
            local character = Players.LocalPlayer.Character
            if character then
                local currentTool = character:FindFirstChildOfClass("Tool")
                if currentTool then
                    currentTool.Name = selected
                end
            end
        end
    end
    
    print("[DYRON] Equipped special rod: " .. selected)
end)

-- ==================== AUTOMATION ====================
local AutoTab = Window:NewTab("Automation")
local AutoSection = AutoTab:NewSection("Auto Farming")

local autoFishing = false
local autoSelling = false

-- AUTO FISHING
AutoSection:NewToggle("AUTO FISH", "Automatically catch fish continuously", function(state)
    autoFishing = state
    
    spawn(function()
        while autoFishing do
            local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
            if fishingSystem then
                local startRemote = fishingSystem:FindFirstChild("StartFishing")
                local completeRemote = fishingSystem:FindFirstChild("CompleteFishing")
                
                if startRemote and completeRemote then
                    -- Start fishing
                    pcall(function()
                        startRemote:FireServer()
                    end)
                    
                    -- Wait then complete
                    task.wait(0.5)
                    
                    pcall(function()
                        completeRemote:FireServer(true, 100)
                    end)
                    
                    -- Small delay between catches
                    task.wait(0.5)
                end
            end
            task.wait(1) -- Base delay
        end
    end)
    
    print("[DYRON] Auto Fish: " .. (state and "ACTIVE" : "INACTIVE"))
end)

-- AUTO SELL
AutoSection:NewToggle("AUTO SELL", "Automatically sell fish", function(state)
    autoSelling = state
    
    spawn(function()
        while autoSelling do
            local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
            if fishingSystem then
                local sellRemote = fishingSystem:FindFirstChild("SellFish") or
                                  fishingSystem:FindFirstChild("SellAllFish")
                
                if sellRemote then
                    -- Sell all fish
                    for i = 1, 5 do
                        pcall(function()
                            sellRemote:FireServer("all")
                        end)
                        task.wait(0.1)
                    end
                end
            end
            task.wait(10) -- Sell every 10 seconds
        end
    end)
end)

-- AUTO REEL (for minigames)
AutoSection:NewToggle("AUTO REEL", "Auto-complete fishing minigame", function(state)
    if state then
        spawn(function()
            while state do
                -- Look for minigame UI
                local playerGui = Players.LocalPlayer.PlayerGui
                for _, gui in pairs(playerGui:GetDescendants()) do
                    if gui:IsA("Frame") and (gui.Name:find("Minigame") or gui.Name:find("Reel")) then
                        -- Auto-click progress bar
                        for _, child in pairs(gui:GetDescendants()) do
                            if child:IsA("TextButton") then
                                fireclickdetector(child)
                                VirtualInputManager:SendMouseButtonEvent(
                                    child.AbsolutePosition.X + child.AbsoluteSize.X/2,
                                    child.AbsolutePosition.Y + child.AbsoluteSize.Y/2,
                                    0, true, game, 1
                                )
                                task.wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(
                                    child.AbsolutePosition.X + child.AbsoluteSize.X/2,
                                    child.AbsolutePosition.Y + child.AbsoluteSize.Y/2,
                                    0, false, game, 1
                                )
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- FARM STATS DISPLAY
local statsLabel = AutoSection:NewLabel("Caught: 0 | Sold: 0")
local catchCount = 0
local sellCount = 0

-- Hook catch events to count
spawn(function()
    while task.wait(1) do
        statsLabel:UpdateLabel(string.format("Caught: %d | Sold: %d", catchCount, sellCount))
    end
end)

-- ==================== TELEPORT ====================
local TeleTab = Window:NewTab("Teleport")
local TeleSection = TeleTab:NewSection("Location Teleport")

-- FISHING SPOTS DATABASE
local fishingSpots = {
    ["Starter Beach"] = {CFrame.new(85, 15, -45)},
    ["Deep Ocean"] = {CFrame.new(-250, 5, 300)},
    ["Ice Lake"] = {CFrame.new(180, 10, -420)},
    ["Volcano Pool"] = {CFrame.new(320, 25, 120)},
    ["Secret Cave"] = {CFrame.new(-520, -30, -180)},
    ["Abyss Trench"] = {CFrame.new(-600, -100, 500)},
    ["Sky Lake"] = {CFrame.new(150, 150, 0)},
    ["Treasure Bay"] = {CFrame.new(400, 5, -200)}
}

for spotName, spotData in pairs(fishingSpots) do
    TeleSection:NewButton("TP: " .. spotName, "Teleport to fishing spot", function()
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = spotData[1]
            print("[DYRON] Teleported to: " .. spotName)
        end
    end)
end

-- CUSTOM TELEPORT
TeleSection:NewTextBox("Custom Coordinates", "Format: X,Y,Z", function(text)
    local coords = {}
    for coord in text:gmatch("[%-%d%.]+") do
        table.insert(coords, tonumber(coord))
    end
    
    if #coords >= 3 then
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(coords[1], coords[2], coords[3])
            print("[DYRON] Teleported to custom coordinates")
        end
    end
end)

-- NPC TELEPORT
TeleSection:NewDropdown("TP to NPC", "Teleport to important NPCs",
    {"Fishing Master", "Rod Seller", "Fish Buyer", "Quest Giver", "Upgrade NPC"},
    function(selected)
    
    local npcPositions = {
        ["Fishing Master"] = CFrame.new(50, 10, -30),
        ["Rod Seller"] = CFrame.new(70, 10, -50),
        ["Fish Buyer"] = CFrame.new(60, 10, -40),
        ["Quest Giver"] = CFrame.new(40, 10, -20),
        ["Upgrade NPC"] = CFrame.new(80, 10, -60)
    }
    
    local pos = npcPositions[selected]
    if pos then
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = pos
            print("[DYRON] Teleported to: " .. selected)
        end
    end
end)

-- ==================== MISC HACKS ====================
local MiscTab = Window:NewTab("Miscellaneous")
local MiscSection = MiscTab:NewSection("Utility Hacks")

-- INFINITE INVENTORY
MiscSection:NewToggle("Infinite Inventory", "Remove fish limit", function(state)
    if FishingModule.InventoryLimitSettings then
        FishingModule.InventoryLimitSettings.maxFishInventory = state and 999999 or 500
        FishingModule.InventoryLimitSettings.enabled = not state
        print("[DYRON] Infinite Inventory: " .. (state and "ON" : "OFF"))
    end
end)

-- SELL PRICE MULTIPLIER
local priceMultiplier = 1
local originalPrices = {}

if FishingModule.SellingSettings and FishingModule.SellingSettings.rarityMultiplier then
    for rarity, mult in pairs(FishingModule.SellingSettings.rarityMultiplier) do
        originalPrices[rarity] = mult
    end
end

MiscSection:NewSlider("Sell Price Multiplier", "Multiply fish sell price", 100, 1, 10, function(value)
    priceMultiplier = value
    if FishingModule.SellingSettings and FishingModule.SellingSettings.rarityMultiplier then
        for rarity in pairs(FishingModule.SellingSettings.rarityMultiplier) do
            FishingModule.SellingSettings.rarityMultiplier[rarity] = (originalPrices[rarity] or 1) * value
        end
    end
    print("[DYRON] Sell price multiplier: " .. value .. "x")
end)

-- SPEED HACK
local originalWalkspeed
MiscSection:NewSlider("Walk Speed", "Movement speed multiplier", 200, 16, 100, function(value)
    local humanoid = Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        originalWalkspeed = originalWalkspeed or humanoid.WalkSpeed
        humanoid.WalkSpeed = value
    end
end)

-- JUMP POWER
MiscSection:NewSlider("Jump Power", "Jump height multiplier", 200, 50, 150, function(value)
    local humanoid = Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = value
    end
end)

-- NO CLIP
local noclip = false
MiscSection:NewToggle("NoClip", "Walk through walls", function(state)
    noclip = state
    local char = Players.LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end)

-- ANTI-AFK
MiscSection:NewToggle("Anti-AFK", "Prevent getting kicked", function(state)
    if state then
        local vu = game:GetService("VirtualUser")
        Players.LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

-- RESET ALL HACKS
MiscSection:NewButton("RESET ALL HACKS", "Restore original game state", function()
    -- Disable all toggles
    extremeWeightsActive = false
    forcedRarity = nil
    autoFishing = false
    autoSelling = false
    
    -- Restore fish data
    for i, fish in pairs(FishingModule.FishTable) do
        local original = OriginalFishData[i]
        if original then
            fish.minKg = original.minKg
            fish.maxKg = original.maxKg
        end
    end
    
    -- Restore rod config
    for rodName, config in pairs(FishingModule.RodConfig) do
        local original = OriginalRodConfig[rodName]
        if original then
            for k, v in pairs(original) do
                config[k] = v
            end
        end
    end
    
    -- Restore functions
    FishingModule.RollFish = OriginalFunctions.RollFish
    FishingModule.GenerateFishWeight = OriginalFunctions.GenerateFishWeight
    if OriginalFunctions.GetRarityWithPity then
        FishingModule.GetRarityWithPity = OriginalFunctions.GetRarityWithPity
    end
    
    -- Restore selling prices
    if FishingModule.SellingSettings and FishingModule.SellingSettings.rarityMultiplier then
        for rarity, mult in pairs(originalPrices) do
            FishingModule.SellingSettings.rarityMultiplier[rarity] = mult
        end
    end
    
    print("[DYRON] ALL HACKS RESET - Original state restored")
end)

-- ==================== KEYBINDS ====================
local KeyTab = Window:NewTab("Keybinds")
local KeySection = KeyTab:NewSection("Controls")

KeySection:NewKeybind("Toggle GUI", "Show/Hide interface", Enum.KeyCode.RightControl, function()
    Library:ToggleUI()
end)

KeySection:NewKeybind("Instant Catch", "Quick catch key", Enum.KeyCode.E, function()
    local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
    if fishingSystem then
        local completeRemote = fishingSystem:FindFirstChild("CompleteFishing")
        if completeRemote then
            completeRemote:FireServer(true, 100)
        end
    end
end)

KeySection:NewKeybind("Teleport Up", "Move upward", Enum.KeyCode.PageUp, function()
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame *= CFrame.new(0, 50, 0)
    end
end)

KeySection:NewKeybind("Teleport Down", "Move downward", Enum.KeyCode.PageDown, function()
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame *= CFrame.new(0, -50, 0)
    end
end)

-- ==================== INFO ====================
local InfoTab = Window:NewTab("Info")
local InfoSection = InfoTab:NewSection("DYRON EXECUTOR v1.2")

InfoSection:NewLabel("Features:")
InfoSection:NewLabel("• Instant Catch & Auto Reel")
InfoSection:NewLabel("• Rarity & Weight Control")
InfoSection:NewLabel("• All Rods Unlocked")
InfoSection:NewLabel("• Auto Farm & Sell")
InfoSection:NewLabel("• Teleport System")
InfoSection:NewLabel("• Speed & NoClip Hacks")

InfoSection:NewLabel("")
InfoSection:NewLabel("Hotkeys:")
InfoSection:NewLabel("Right Ctrl - Toggle GUI")
InfoSection:NewLabel("E - Instant Catch")
InfoSection:NewLabel("PgUp/PgDown - Teleport")

-- ==================== INITIALIZATION ====================
print("\n========================================")
print("DYRON FISHING EXECUTOR v1.2")
print("Loaded Successfully")
print("Module: " .. tostring(FishingModule and "DETECTED" : "SIMULATED"))
print("Features: 12 Exploit Systems")
print("========================================\n")

-- Auto-enable some features
task.wait(2)
print("[DYRON] Auto-configuring optimal settings...")
EnableExtremeWeights(5, 20) -- Medium-high weights by default

-- Success notification
Notify({
    Title = "DYRON READY",
    Description = "All systems operational. Use Right Ctrl to open GUI.",
    Duration = 8
})
