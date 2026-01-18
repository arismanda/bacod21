-- DYRON EXECUTOR v1.2: ULTIMATE FISHING DOMINATION
-- Engine: Reverse-Engineered Module v2_upvr with Multi-Layer Exploitation
-- Build: Hyper-Optimized for Maximum Control

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Safe player reference
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

-- Auto-detect fishing module dengan safe handling
local FishingModule
local function FindFishingModule()
    -- Method 1: Check loaded modules
    for _, obj in pairs(getloadedmodules() or {}) do
        if type(obj) == "table" and rawget(obj, "GetRodConfig") then
            return obj
        end
    end
    
    -- Method 2: Require from ReplicatedStorage
    local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
    if fishingSystem then
        local moduleScript = fishingSystem:FindFirstChild("FishingModule")
        if moduleScript and moduleScript:IsA("ModuleScript") then
            local success, result = pcall(require, moduleScript)
            if success then return result end
        end
    end
    
    -- Method 3: Search in game scripts
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("ModuleScript") and script.Name:find("Fish") then
            local success, result = pcall(require, script)
            if success and type(result) == "table" and rawget(result, "FishTable") then
                return result
            end
        end
    end
    
    return nil
end

FishingModule = FindFishingModule()

if not FishingModule then
    -- Create minimal stub jika module tidak ditemukan
    FishingModule = {
        RodConfig = {
            default = {
                hookName = "BasicHook",
                beamColor = Color3.new(1,1,1),
                beamWidth = 0.05,
                baseLuck = 1,
                maxWeight = 100,
                maxRarity = "Common"
            }
        },
        FishTable = {
            {name = "Basic Fish", rarity = "Common", minKg = 1, maxKg = 10, probability = 100}
        },
        GetRodConfig = function(rodName)
            return FishingModule.RodConfig[rodName] or FishingModule.RodConfig.default
        end,
        RollFish = function()
            return FishingModule.FishTable[1]
        end,
        GenerateFishWeight = function()
            return math.random(10, 100)
        end,
        SellingSettings = {
            rarityMultiplier = {
                Common = 1,
                Uncommon = 2,
                Rare = 4,
                Epic = 8,
                Legendary = 15,
                Unknown = 30
            }
        },
        InventoryLimitSettings = {
            maxFishInventory = 500,
            enabled = true
        }
    }
end

-- Backup original data
local OriginalFishData = {}
local OriginalRodConfig = {}
local OriginalFunctions = {}

if FishingModule then
    if FishingModule.FishTable then
        for i, fish in pairs(FishingModule.FishTable) do
            OriginalFishData[i] = {
                minKg = fish.minKg,
                maxKg = fish.maxKg,
                name = fish.name,
                rarity = fish.rarity,
                probability = fish.probability
            }
        end
    end
    
    if FishingModule.RodConfig then
        for rodName, config in pairs(FishingModule.RodConfig) do
            OriginalRodConfig[rodName] = table.clone(config)
        end
    end
    
    OriginalFunctions.GenerateFishWeight = FishingModule.GenerateFishWeight
    OriginalFunctions.RollFish = FishingModule.RollFish
end

-- GUI Library dengan safe loading
local Library
local success, err = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)

if not success then
    -- Fallback ke GUI sederhana
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    ScreenGui.Parent = game.CoreGui
    Frame.Parent = ScreenGui
    
    Library = {
        CreateLib = function(name, theme)
            return {
                NewTab = function(tabName)
                    return {
                        NewSection = function(sectionName)
                            return {
                                NewToggle = function() return {UpdateToggle = function() end} end,
                                NewButton = function() return {} end,
                                NewSlider = function() return {Set = function() end} end,
                                NewDropdown = function() return {} end,
                                NewTextBox = function() return {} end,
                                NewLabel = function(text) return {UpdateLabel = function() end} end,
                                NewKeybind = function() return {} end
                            }
                        end
                    }
                end,
                ToggleUI = function() end
            }
        end
    }
end

local Window = Library.CreateLib("DYRON FISHING v1.2", "DarkTheme")

-- ==================== CORE EXPLOITS ====================
local MainTab = Window:NewTab("Core Hacks")
local MainSection = MainTab:NewSection("Instant Catch & Rarity")

-- INSTANT CATCH SYSTEM
local instantCatchHooks = {}
MainSection:NewToggle("INSTANT CATCH", "Bypass all minigames", function(state)
    if state then
        local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
        if fishingSystem then
            local startRemote = fishingSystem:FindFirstChild("StartFishing")
            local completeRemote = fishingSystem:FindFirstChild("CompleteFishing")
            
            if startRemote and completeRemote then
                if hookfunction then
                    local oldStart = startRemote.FireServer
                    instantCatchHooks.start = oldStart
                    
                    startRemote.FireServer = function(self, ...)
                        task.spawn(function()
                            task.wait(0.1)
                            pcall(function()
                                completeRemote:FireServer(true, 100)
                            end)
                        end)
                        return oldStart(self, ...)
                    end
                end
            end
        end
        
        task.spawn(function()
            while state do
                for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextButton") and (gui.Text:find("Tap") or gui.Name:find("Click")) then
                        pcall(function()
                            gui:Fire("Activated")
                        end)
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        if instantCatchHooks.start then
            local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
            if fishingSystem then
                local startRemote = fishingSystem:FindFirstChild("StartFishing")
                if startRemote then
                    startRemote.FireServer = instantCatchHooks.start
                end
            end
        end
    end
end)

-- RARITY CONTROL SYSTEM
local forcedRarity = nil
MainSection:NewDropdown("FORCE RARITY", "Select guaranteed fish rarity",
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, function(selected)
    
    forcedRarity = selected
    
    if FishingModule and FishingModule.RollFish then
        local originalRoll = FishingModule.RollFish
        FishingModule.RollFish = function(pityTracker, rodName, luckMultiplier)
            if forcedRarity then
                local availableFish = {}
                if FishingModule.FishTable then
                    for _, fish in pairs(FishingModule.FishTable) do
                        if fish.rarity == forcedRarity then
                            table.insert(availableFish, fish)
                        end
                    end
                end
                
                if #availableFish == 0 then
                    availableFish = {{name = "Forced Fish", rarity = forcedRarity, minKg = 1, maxKg = 100}}
                end
                
                local selectedFish = availableFish[math.random(1, #availableFish)]
                local rodConfig = FishingModule.GetRodConfig and FishingModule.GetRodConfig(rodName) or {}
                
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
                    _weight = weight,
                    weight = weight
                }
            end
            
            return originalRoll(pityTracker, rodName, luckMultiplier)
        end
    end
end)

MainSection:NewButton("Disable Rarity Force", "Return to normal rarity", function()
    forcedRarity = nil
    if FishingModule and OriginalFunctions.RollFish then
        FishingModule.RollFish = OriginalFunctions.RollFish
    end
end)

-- ==================== WEIGHT MANIPULATION ====================
local WeightTab = Window:NewTab("Weight Control")
local WeightSection = WeightTab:NewSection("Weight Manipulation")

local extremeWeightsActive = false
local weightMultipliers = {min = 1, max = 1}

local function EnableExtremeWeights(minMult, maxMult)
    extremeWeightsActive = true
    weightMultipliers = {min = minMult, max = maxMult}
    
    if FishingModule and FishingModule.FishTable then
        for _, fish in pairs(FishingModule.FishTable) do
            local original = nil
            for _, orig in pairs(OriginalFishData) do
                if orig.name == fish.name then
                    original = orig
                    break
                end
            end
            
            if original then
                local rarityScale = {
                    Common = 1, Uncommon = 2, Rare = 3,
                    Epic = 5, Legendary = 10, Unknown = 20
                }
                
                local scale = rarityScale[fish.rarity] or 1
                fish.minKg = math.floor(original.minKg * minMult * scale * 10) / 10
                fish.maxKg = math.floor(original.maxKg * maxMult * scale * 10) / 10
                
                if fish.minKg >= fish.maxKg then
                    fish.maxKg = fish.minKg * 2
                end
                
                if fish.maxKg > 9999 then
                    fish.maxKg = 9999
                end
            end
        end
    end
    
    if FishingModule and FishingModule.RodConfig then
        for _, config in pairs(FishingModule.RodConfig) do
            if config.maxWeight then
                config.maxWeight = 9999
            end
        end
    end
    
    if FishingModule and FishingModule.GenerateFishWeight then
        local originalGen = FishingModule.GenerateFishWeight
        FishingModule.GenerateFishWeight = function(fishData, rodLuck, maxRodWeight)
            if not extremeWeightsActive then
                return originalGen(fishData, rodLuck, maxRodWeight)
            end
            
            local minW = fishData.minKg or 1
            local maxW = math.min(fishData.maxKg or 100, 9999)
            
            local random = math.random()
            local weight
            
            if random < 0.1 then
                weight = minW
            elseif random < 0.3 then
                weight = minW + (maxW - minW) * 0.3
            else
                weight = maxW * 0.7 + (maxW * 0.3) * math.random()
            end
            
            return math.floor(weight * 10 + 0.5) / 10
        end
    end
end

local function DisableExtremeWeights()
    extremeWeightsActive = false
    
    if FishingModule and FishingModule.FishTable then
        for i, fish in pairs(FishingModule.FishTable) do
            local original = OriginalFishData[i]
            if original then
                fish.minKg = original.minKg
                fish.maxKg = original.maxKg
            end
        end
    end
    
    if FishingModule and FishingModule.RodConfig then
        for rodName, config in pairs(FishingModule.RodConfig) do
            local original = OriginalRodConfig[rodName]
            if original and original.maxWeight then
                config.maxWeight = original.maxWeight
            end
        end
    end
    
    if FishingModule and OriginalFunctions.GenerateFishWeight then
        FishingModule.GenerateFishWeight = OriginalFunctions.GenerateFishWeight
    end
end

WeightSection:NewSlider("Min Multiplier", "Minimum weight multiplier", 100, 1, 10, function(value)
    weightMultipliers.min = value
    if extremeWeightsActive then
        EnableExtremeWeights(value, weightMultipliers.max)
    end
end)

WeightSection:NewSlider("Max Multiplier", "Maximum weight multiplier", 100, 10, 50, function(value)
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

WeightSection:NewDropdown("Weight Presets", "Quick weight configurations",
    {"Realistic (Original)", "Heavy (2x-5x)", "Monster (5x-20x)", "Titanic (10x-50x)", "GOD MODE (50x-100x)"},
    function(preset)
    
    local presets = {
        ["Realistic (Original)"] = {1, 1},
        ["Heavy (2x-5x)"] = {2, 5},
        ["Monster (5x-20x)"] = {5, 20},
        ["Titanic (10x-50x)"] = {10, 50},
        ["GOD MODE (50x-100x)"] = {50, 100}
    }
    
    local mults = presets[preset]
    if mults then
        EnableExtremeWeights(mults[1], mults[2])
    end
end)

-- ==================== ROD CONTROL ====================
local RodTab = Window:NewTab("Rod Hacks")
local RodSection = RodTab:NewSection("Rod Manipulation")

RodSection:NewButton("UNLOCK ALL RODS", "Get every rod in the game", function()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        if FishingModule and FishingModule.RodConfig then
            for rodName in pairs(FishingModule.RodConfig) do
                local tool = Instance.new("Tool")
                tool.Name = rodName
                tool.Parent = backpack
            end
        end
    end
    
    local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
    if fishingSystem then
        local unlockRemote = fishingSystem:FindFirstChild("UnlockRod") or fishingSystem:FindFirstChild("EquipRod")
        if unlockRemote then
            if FishingModule and FishingModule.RodConfig then
                for rodName in pairs(FishingModule.RodConfig) do
                    pcall(function()
                        unlockRemote:FireServer(rodName)
                    end)
                end
            end
        end
    end
end)

RodSection:NewSlider("Luck Multiplier", "Multiply all rod luck", 1000, 1, 100, function(value)
    if FishingModule and FishingModule.RodConfig then
        for _, config in pairs(FishingModule.RodConfig) do
            if config.baseLuck then
                config.baseLuck = config.baseLuck * value
            end
        end
    end
end)

-- ==================== AUTOMATION ====================
local AutoTab = Window:NewTab("Automation")
local AutoSection = AutoTab:NewSection("Auto Farming")

local autoFishing = false
local autoSelling = false

AutoSection:NewToggle("AUTO FISH", "Automatically catch fish continuously", function(state)
    autoFishing = state
    
    task.spawn(function()
        while autoFishing do
            local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
            if fishingSystem then
                local startRemote = fishingSystem:FindFirstChild("StartFishing")
                local completeRemote = fishingSystem:FindFirstChild("CompleteFishing")
                
                if startRemote and completeRemote then
                    pcall(function()
                        startRemote:FireServer()
                    end)
                    
                    task.wait(0.5)
                    
                    pcall(function()
                        completeRemote:FireServer(true, 100)
                    end)
                    
                    task.wait(0.5)
                end
            end
            task.wait(1)
        end
    end)
end)

AutoSection:NewToggle("AUTO SELL", "Automatically sell fish", function(state)
    autoSelling = state
    
    task.spawn(function()
        while autoSelling do
            local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
            if fishingSystem then
                local sellRemote = fishingSystem:FindFirstChild("SellFish") or fishingSystem:FindFirstChild("SellAllFish")
                if sellRemote then
                    for i = 1, 5 do
                        pcall(function()
                            sellRemote:FireServer("all")
                        end)
                        task.wait(0.1)
                    end
                end
            end
            task.wait(10)
        end
    end)
end)

-- ==================== TELEPORT ====================
local TeleTab = Window:NewTab("Teleport")
local TeleSection = TeleTab:NewSection("Location Teleport")

local fishingSpots = {
    ["Starter Beach"] = CFrame.new(85, 15, -45),
    ["Deep Ocean"] = CFrame.new(-250, 5, 300),
    ["Ice Lake"] = CFrame.new(180, 10, -420),
    ["Secret Cave"] = CFrame.new(-520, -30, -180)
}

for spotName, spotCFrame in pairs(fishingSpots) do
    TeleSection:NewButton("TP: " .. spotName, "Teleport to fishing spot", function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = spotCFrame
        end
    end)
end

-- ==================== MISC HACKS ====================
local MiscTab = Window:NewTab("Miscellaneous")
local MiscSection = MiscTab:NewSection("Utility Hacks")

MiscSection:NewToggle("Infinite Inventory", "Remove fish limit", function(state)
    if FishingModule and FishingModule.InventoryLimitSettings then
        FishingModule.InventoryLimitSettings.maxFishInventory = state and 999999 or 500
        FishingModule.InventoryLimitSettings.enabled = not state
    end
end)

MiscSection:NewSlider("Sell Price Multiplier", "Multiply fish sell price", 100, 1, 10, function(value)
    if FishingModule and FishingModule.SellingSettings and FishingModule.SellingSettings.rarityMultiplier then
        for rarity in pairs(FishingModule.SellingSettings.rarityMultiplier) do
            FishingModule.SellingSettings.rarityMultiplier[rarity] = FishingModule.SellingSettings.rarityMultiplier[rarity] * value
        end
    end
end)

MiscSection:NewSlider("Walk Speed", "Movement speed multiplier", 200, 16, 100, function(value)
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end)

MiscSection:NewSlider("Jump Power", "Jump height multiplier", 200, 50, 150, function(value)
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = value
        end
    end
end)

MiscSection:NewToggle("NoClip", "Walk through walls", function(state)
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end)

MiscSection:NewButton("RESET ALL HACKS", "Restore original game state", function()
    extremeWeightsActive = false
    forcedRarity = nil
    autoFishing = false
    autoSelling = false
    
    if FishingModule then
        if FishingModule.FishTable then
            for i, fish in pairs(FishingModule.FishTable) do
                local original = OriginalFishData[i]
                if original then
                    fish.minKg = original.minKg
                    fish.maxKg = original.maxKg
                end
            end
        end
        
        if FishingModule.RodConfig then
            for rodName, config in pairs(FishingModule.RodConfig) do
                local original = OriginalRodConfig[rodName]
                if original then
                    for k, v in pairs(original) do
                        config[k] = v
                    end
                end
            end
        end
        
        if OriginalFunctions.RollFish then
            FishingModule.RollFish = OriginalFunctions.RollFish
        end
        
        if OriginalFunctions.GenerateFishWeight then
            FishingModule.GenerateFishWeight = OriginalFunctions.GenerateFishWeight
        end
    end
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

-- ==================== AUTO INIT ====================
task.wait(1)
EnableExtremeWeights(5, 20)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
