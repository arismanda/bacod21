-- Fishing Simulator Ultimate Exploit v3.0
-- Advanced Features: Rarity/Weight Range, Silent Catch, FishGiver, Random Weights
-- Compatible: Synapse X, KRNL, Fluxus, Script-Ware

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 10)

if not FishingSystem then
    warn("[EXPLOIT] Game tidak dikenali, mencari alternative...")
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name:lower():find("fish") and obj:IsA("ModuleScript") then
            FishingSystem = obj.Parent
            break
        end
    end
end

-- CONFIGURASI ADVANCED dengan tambahan Random Weights
local Config = {
    AutoFish = true,
    InstantCatch = true,
    SilentCatch = true,
    MinRarity = "Common",
    MaxRarity = "Unknown",
    MinWeight = 1,
    MaxWeight = 999,
    WeightPrecision = 1,
    AutoSell = true,
    SellBelowRarity = "Rare",
    FishGiver = {
        Enabled = false,
        TargetPlayer = "",
        FishName = "Megalodon",
        Rarity = "Unknown",
        Weight = 999
    },
    RandomWeights = {
        Enabled = true,
        Mode = "Custom", -- "Realistic", "Random", "Extreme", "Custom"
        CustomMin = 1,
        CustomMax = 999,
        Bias = 0.7,
        Fluctuation = 0.3
    },
    WebhookNotify = false,
    AntiAFK = true,
    BypassCooldown = false
}

-- RARITY ORDER untuk perbandingan
local RarityOrder = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Unknown = 6
}

-- VARIABEL RANDOM WEIGHTS
local RandomWeightsActive = false
local OriginalWeightData = {}
local WeightModificationHooks = {}

-- OVERRIDE SYSTEM
local originalModule
local moduleHookActive = false

-- Function untuk backup original weight data
local function BackupWeightData()
    if originalModule and originalModule.FishTable then
        OriginalWeightData = {}
        for i, fish in pairs(originalModule.FishTable) do
            OriginalWeightData[i] = {
                minKg = fish.minKg,
                maxKg = fish.maxKg,
                name = fish.name,
                rarity = fish.rarity
            }
        end
    end
end

-- Function untuk mengaktifkan/menonaktifkan Random Weights
local function ToggleRandomWeights(state)
    RandomWeightsActive = state
    
    if state then
        BackupWeightData()
        
        if originalModule and originalModule.FishTable then
            for i, fish in pairs(originalModule.FishTable) do
                if OriginalWeightData[i] then
                    -- Apply sesuai mode
                    if Config.RandomWeights.Mode == "Custom" then
                        fish.minKg = Config.RandomWeights.CustomMin
                        fish.maxKg = Config.RandomWeights.CustomMax
                    elseif Config.RandomWeights.Mode == "Extreme" then
                        local scale = RarityOrder[fish.rarity] or 1
                        fish.minKg = 50 * scale
                        fish.maxKg = 500 * scale
                    elseif Config.RandomWeights.Mode == "Random" then
                        fish.minKg = math.random(1, 100)
                        fish.maxKg = math.random(200, 999)
                    end
                    
                    -- Ensure min < max
                    if fish.minKg >= fish.maxKg then
                        fish.maxKg = fish.minKg + 100
                    end
                    
                    -- Cap at reasonable values
                    if fish.maxKg > 9999 then
                        fish.maxKg = 9999
                    end
                end
            end
        end
    else
        -- Restore original weights
        if originalModule and originalModule.FishTable and next(OriginalWeightData) ~= nil then
            for i, fish in pairs(originalModule.FishTable) do
                local original = OriginalWeightData[i]
                if original then
                    fish.minKg = original.minKg
                    fish.maxKg = original.maxKg
                end
            end
        end
    end
end

-- Random Weight Generator dengan berbagai mode
local function GenerateRandomWeight(fishData, rodConfig)
    if not RandomWeightsActive then
        return nil -- Gunakan default
    end
    
    local mode = Config.RandomWeights.Mode
    local minWeight, maxWeight
    
    if mode == "Custom" then
        minWeight = Config.RandomWeights.CustomMin
        maxWeight = Config.RandomWeights.CustomMax
    elseif mode == "Extreme" then
        minWeight = 100
        maxWeight = 999
    elseif mode == "Random" then
        minWeight = math.random(1, 100)
        maxWeight = math.random(200, 999)
    else -- Realistic
        minWeight = fishData.minKg or 1
        maxWeight = fishData.maxKg or 100
    end
    
    -- Apply bias untuk weight tinggi
    local random = math.random()
    local bias = Config.RandomWeights.Bias or 0.7
    
    local weight
    if random < (1 - bias) then
        -- Lower weights
        weight = minWeight + (maxWeight - minWeight) * 0.3 * math.random()
    else
        -- Higher weights
        weight = maxWeight * 0.7 + (maxWeight * 0.3) * math.random()
    end
    
    -- Apply fluctuation
    local fluctuation = Config.RandomWeights.Fluctuation or 0.3
    weight = weight * (1 + (math.random() * 2 - 1) * fluctuation)
    
    -- Apply precision
    local precision = Config.WeightPrecision or 1
    local multiplier = 10 ^ precision
    weight = math.floor(weight * multiplier + 0.5) / multiplier
    
    -- Clamp within limits
    weight = math.max(minWeight, math.min(maxWeight, weight))
    
    return weight
end

-- Hook weight generation function
local function HookWeightGeneration()
    if not originalModule or not originalModule.GenerateFishWeight then
        return false
    end
    
    if WeightModificationHooks.GenerateFishWeight then
        return true -- Already hooked
    end
    
    local originalGenWeight = originalModule.GenerateFishWeight
    WeightModificationHooks.GenerateFishWeight = originalGenWeight
    
    originalModule.GenerateFishWeight = function(fishData, rodLuck, maxWeight)
        if RandomWeightsActive then
            local customWeight = GenerateRandomWeight(fishData, {maxWeight = maxWeight})
            if customWeight then
                return customWeight
            end
        end
        
        -- Apply min/max weight limits
        local weight = originalGenWeight(fishData, rodLuck, maxWeight)
        
        if Config.MinWeight and weight < Config.MinWeight then
            weight = Config.MinWeight
        end
        
        if Config.MaxWeight and weight > Config.MaxWeight then
            weight = Config.MaxWeight
        end
        
        -- Apply precision
        local precision = Config.WeightPrecision or 1
        local multiplier = 10 ^ precision
        weight = math.floor(weight * multiplier + 0.5) / multiplier
        
        return weight
    end
    
    return true
end

local function HookGameFunctions()
    if moduleHookActive then return end
    
    for _, module in pairs(getloadedmodules() or {}) do
        if module.Name:lower():find("fish") or module.Name:find("Fishing") then
            local success, moduleData = pcall(require, module)
            if success and type(moduleData) == "table" then
                originalModule = moduleData
                
                -- 1. OVERRIDE RARITY WITH RANGE
                if moduleData.GetRarityWithPity then
                    local originalGetRarity = moduleData.GetRarityWithPity
                    moduleData.GetRarityWithPity = function(pityTable, rodName, luckMultiplier)
                        if Config.InstantCatch then
                            local minOrder = RarityOrder[Config.MinRarity] or 1
                            local maxOrder = RarityOrder[Config.MaxRarity] or 6
                            local targetOrder = math.random(minOrder, maxOrder)
                            
                            for rarity, order in pairs(RarityOrder) do
                                if order == targetOrder then
                                    return rarity
                                end
                            end
                            return Config.MaxRarity
                        end
                        return originalGetRarity(pityTable, rodName, luckMultiplier)
                    end
                end
                
                -- 2. OVERRIDE WEIGHT GENERATION (with new hook)
                HookWeightGeneration()
                
                -- 3. OVERRIDE FISH ROLL COMPLETELY
                if moduleData.RollFish then
                    local originalRollFish = moduleData.RollFish
                    moduleData.RollFish = function(pityTable, rodName, luckMultiplier)
                        if Config.SilentCatch then
                            local fishTable = moduleData.FishTable or {}
                            local rarity = Config.MaxRarity
                            
                            local eligibleFish = {}
                            for _, fish in pairs(fishTable) do
                                local fishOrder = RarityOrder[fish.rarity] or 1
                                local minOrder = RarityOrder[Config.MinRarity] or 1
                                local maxOrder = RarityOrder[Config.MaxRarity] or 6
                                
                                if fishOrder >= minOrder and fishOrder <= maxOrder then
                                    table.insert(eligibleFish, fish)
                                end
                            end
                            
                            if #eligibleFish > 0 then
                                local selectedFish = eligibleFish[math.random(1, #eligibleFish)]
                                
                                -- Use random weight generator
                                local weight
                                if RandomWeightsActive then
                                    weight = GenerateRandomWeight(selectedFish, {})
                                else
                                    weight = math.random(Config.MinWeight * 10, Config.MaxWeight * 10) / 10
                                end
                                
                                local precision = Config.WeightPrecision or 1
                                local multiplier = 10 ^ precision
                                weight = math.floor(weight * multiplier + 0.5) / multiplier
                                
                                return {
                                    name = selectedFish.name,
                                    rarity = selectedFish.rarity,
                                    weight = weight,
                                    value = weight * 100
                                }
                            end
                        end
                        return originalRollFish(pityTable, rodName, luckMultiplier)
                    end
                end
                
                moduleHookActive = true
                BackupWeightData() -- Backup original data
                break
            end
        end
    end
end

-- SILENT CATCH SYSTEM
local function SilentCatchFish()
    if not Config.SilentCatch then return end
    
    local catchRemote = FishingSystem:FindFirstChild("CatchFish") or 
                       FishingSystem:FindFirstChild("ReelIn") or
                       FishingSystem:FindFirstChild("CompleteFishing")
    
    if catchRemote then
        local weight
        if RandomWeightsActive then
            weight = GenerateRandomWeight({}, {})
        else
            weight = math.random(Config.MinWeight * 10, Config.MaxWeight * 10) / 10
        end
        
        local fakeFishData = {
            Name = "Megalodon",
            Rarity = Config.MaxRarity,
            Weight = weight,
            Value = weight * 100
        }
        
        local success = pcall(function()
            if catchRemote:IsA("RemoteEvent") then
                catchRemote:FireServer(fakeFishData)
            elseif catchRemote:IsA("RemoteFunction") then
                catchRemote:InvokeServer(fakeFishData)
            end
        })
        
        return success
    end
    return false
end

-- FISH GIVER FUNCTION
local function GiveFishToPlayer(targetName, fishName, rarity, weight)
    if not Config.FishGiver.Enabled or targetName == "" then return end
    
    local targetPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName:lower()) or player.DisplayName:lower():find(targetName:lower()) then
            targetPlayer = player
            break
        end
    end
    
    if not targetPlayer then
        warn("[FishGiver] Player tidak ditemukan:", targetName)
        return false
    end
    
    local giveRemote = FishingSystem:FindFirstChild("GiveFish") or 
                      FishingSystem:FindFirstChild("TradeFish") or
                      FishingSystem:FindFirstChild("TransferFish")
    
    if giveRemote then
        local fishData = {
            Player = targetPlayer,
            FishName = fishName or Config.FishGiver.FishName,
            Rarity = rarity or Config.FishGiver.Rarity,
            Weight = weight or Config.FishGiver.Weight,
            Value = (weight or 999) * 100
        }
        
        local success = pcall(function()
            if giveRemote:IsA("RemoteEvent") then
                giveRemote:FireServer(fishData)
            elseif giveRemote:IsA("RemoteFunction") then
                giveRemote:InvokeServer(fishData)
            end
        })
        
        if success then
            print(string.format("[FishGiver] Berhasil give %s (%s, %skg) ke %s", 
                fishData.FishName, fishData.Rarity, fishData.Weight, targetPlayer.Name))
            return true
        end
    end
    
    return false
end

-- ADVANCED AUTO-FISHING
local AutoFishThread
local CatchCount = 0

local function AdvancedAutoFishing()
    if AutoFishThread then return end
    
    AutoFishThread = task.spawn(function()
        while Config.AutoFish do
            HookGameFunctions()
            
            local castRemote = FishingSystem:FindFirstChild("CastLine") or 
                              FishingSystem:FindFirstChild("StartFishing")
            
            if castRemote then
                pcall(function()
                    if castRemote:IsA("RemoteEvent") then
                        castRemote:FireServer()
                    elseif castRemote:IsA("RemoteFunction") then
                        castRemote:InvokeServer()
                    end
                })
                
                local waitTime = Config.BypassCooldown and 0.1 or math.random(0.5, 2.0)
                task.wait(waitTime)
                
                if Config.SilentCatch then
                    SilentCatchFish()
                else
                    local catchRemote = FishingSystem:FindFirstChild("CatchFish")
                    if catchRemote then
                        pcall(function()
                            catchRemote:FireServer()
                        end)
                    end
                end
                
                CatchCount += 1
                
                if Config.AutoSell and CatchCount % 5 == 0 then
                    task.spawn(function()
                        local sellRemote = FishingSystem:FindFirstChild("SellFish")
                        if sellRemote then
                            for rarity, order in pairs(RarityOrder) do
                                local sellOrder = RarityOrder[Config.SellBelowRarity] or 3
                                if order < sellOrder then
                                    pcall(function()
                                        sellRemote:FireServer(rarity)
                                    end)
                                end
                            end
                        end
                    end)
                end
            end
            
            local delay = math.random(100, 300) / 100
            task.wait(delay)
        end
    end)
end

-- GUI ADVANCED v3.0 dengan Random Weights
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fishing Simulator Exploit v3.0", "DarkTheme")

-- MAIN FEATURES
local MainTab = Window:NewTab("Main")
local FishingSection = MainTab:NewSection("Fishing Features")

FishingSection:NewToggle("Auto Fish", "Automatically fishes", function(state)
    Config.AutoFish = state
    if state then
        AdvancedAutoFishing()
    else
        AutoFishThread = nil
    end
end)

FishingSection:NewToggle("Instant Catch", "Skip minigame", function(state)
    Config.InstantCatch = state
end)

FishingSection:NewToggle("Silent Catch", "No animation, direct inventory", function(state)
    Config.SilentCatch = state
end)

-- RARITY CONTROL SECTION
local RarityTab = Window:NewTab("Rarity Control")
local MinRaritySection = RarityTab:NewSection("Minimum Rarity")

local MinRarityDropdown = MinRaritySection:NewDropdown("Min Rarity", "Lowest rarity to catch", 
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, 
    function(selected)
        Config.MinRarity = selected
    end)
MinRarityDropdown:SetOption("Common")

local MaxRaritySection = RarityTab:NewSection("Maximum Rarity")
local MaxRarityDropdown = MaxRaritySection:NewDropdown("Max Rarity", "Highest rarity to catch", 
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, 
    function(selected)
        Config.MaxRarity = selected
    end)
MaxRarityDropdown:SetOption("Unknown")

-- WEIGHT CONTROL SECTION dengan Random Weights
local WeightTab = Window:NewTab("Weight Control")

-- Weight Range Section
local WeightRangeSection = WeightTab:NewSection("Weight Range")

local MinWeightSlider = WeightRangeSection:NewSlider("Min Weight", "Minimum fish weight", 1000, 0.1, function(value)
    Config.MinWeight = value
end)
MinWeightSlider:SetValue(1)

local MaxWeightSlider = WeightRangeSection:NewSlider("Max Weight", "Maximum fish weight", 1000, 0.1, function(value)
    Config.MaxWeight = value
end)
MaxWeightSlider:SetValue(999)

-- Random Weights Section
local RandomWeightsSection = WeightTab:NewSection("Random Weights")

RandomWeightsSection:NewToggle("Enable Random Weights", "Randomize fish weights", function(state)
    Config.RandomWeights.Enabled = state
    ToggleRandomWeights(state)
end)

local WeightModeDropdown = RandomWeightsSection:NewDropdown("Weight Mode", "Select weight generation mode", 
    {"Realistic", "Random", "Extreme", "Custom"}, 
    function(selected)
        Config.RandomWeights.Mode = selected
        if Config.RandomWeights.Enabled then
            ToggleRandomWeights(true)
        end
    end)
WeightModeDropdown:SetOption("Custom")

-- Custom Weight Range (hanya muncul jika mode = Custom)
local CustomMinSlider = RandomWeightsSection:NewSlider("Custom Min Weight", "Minimum weight for custom mode", 
    1000, 1, 100, function(value)
    Config.RandomWeights.CustomMin = value
    if Config.RandomWeights.Enabled and Config.RandomWeights.Mode == "Custom" then
        ToggleRandomWeights(true)
    end
end)
CustomMinSlider:SetValue(1)

local CustomMaxSlider = RandomWeightsSection:NewSlider("Custom Max Weight", "Maximum weight for custom mode", 
    1000, 100, 999, function(value)
    Config.RandomWeights.CustomMax = value
    if Config.RandomWeights.Enabled and Config.RandomWeights.Mode == "Custom" then
        ToggleRandomWeights(true)
    end
end)
CustomMaxSlider:SetValue(999)

-- Weight Bias Settings
local WeightSettingsSection = WeightTab:NewSection("Weight Settings")

local BiasSlider = WeightSettingsSection:NewSlider("Weight Bias", "Bias towards higher weights (0-1)", 
    100, 0, 100, function(value)
    Config.RandomWeights.Bias = value / 100
end)
BiasSlider:SetValue(70)

local FluctuationSlider = WeightSettingsSection:NewSlider("Weight Fluctuation", "Random weight fluctuation (0-1)", 
    100, 0, 100, function(value)
    Config.RandomWeights.Fluctuation = value / 100
end)
FluctuationSlider:SetValue(30)

local PrecisionSection = WeightTab:NewSection("Precision")
local PrecisionSlider = PrecisionSection:NewSlider("Decimal Places", "Weight decimal precision", 3, 0, function(value)
    Config.WeightPrecision = value
end)
PrecisionSlider:SetValue(1)

-- Test Random Weights Button
RandomWeightsSection:NewButton("Test Random Weights", "Generate sample weights", function()
    if originalModule and originalModule.FishTable then
        print("\n=== RANDOM WEIGHTS TEST ===")
        for i = 1, 5 do
            local fish = originalModule.FishTable[math.random(1, #originalModule.FishTable)]
            if fish then
                local weight = GenerateRandomWeight(fish, {})
                print(string.format("Test %d: %s - %.1fkg (%s)", 
                    i, fish.name, weight, fish.rarity))
            end
        end
        print("=== TEST COMPLETE ===")
    end
end)

-- Reset Weights Button
RandomWeightsSection:NewButton("Reset to Original", "Restore original weights", function()
    ToggleRandomWeights(false)
    Config.RandomWeights.Enabled = false
    Library:Notify("Weights reset to original", 3)
end)

-- FISH GIVER TAB
local GiveTab = Window:NewTab("Fish Giver")
local GiveSection = GiveTab:NewSection("Give Fish to Players")

GiveSection:NewToggle("Enable FishGiver", "Allow giving fish", function(state)
    Config.FishGiver.Enabled = state
end)

local PlayerTextBox = GiveSection:NewTextBox("Target Player", "Player name to give fish", function(text)
    Config.FishGiver.TargetPlayer = text
end)

local FishDropdown = GiveSection:NewDropdown("Fish Type", "Select fish to give", 
    {"Megalodon", "Ancient Whale", "El Maja", "Plasma Shark", "Pink Dolphin", "Custom"}, 
    function(selected)
        Config.FishGiver.FishName = selected
    end)
FishDropdown:SetOption("Megalodon")

local GiveRarityDropdown = GiveSection:NewDropdown("Give Rarity", "Rarity of given fish", 
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, 
    function(selected)
        Config.FishGiver.Rarity = selected
    end)
GiveRarityDropdown:SetOption("Unknown")

local GiveWeightSlider = GiveSection:NewSlider("Give Weight", "Weight of given fish", 1000, 1, function(value)
    Config.FishGiver.Weight = value
end)
GiveWeightSlider:SetValue(999)

GiveSection:NewButton("Give Fish Now", "Execute fish give", function()
    local target = Config.FishGiver.TargetPlayer
    if target and target ~= "" then
        GiveFishToPlayer(target, Config.FishGiver.FishName, Config.FishGiver.Rarity, Config.FishGiver.Weight)
    else
        Library:Notify("Masukkan nama player terlebih dahulu!", 5)
    end
end)

-- AUTO-SELL TAB
local SellTab = Window:NewTab("Auto Sell")
local SellSettings = SellTab:NewSection("Sell Configuration")

SellSettings:NewToggle("Auto Sell", "Automatically sell fish", function(state)
    Config.AutoSell = state
end)

local SellBelowDropdown = SellSettings:NewDropdown("Sell Below", "Sell fish below this rarity", 
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, 
    function(selected)
        Config.SellBelowRarity = selected
    end)
SellBelowDropdown:SetOption("Rare")

SellSettings:NewButton("Sell All Now", "Sell all eligible fish", function()
    local sellRemote = FishingSystem:FindFirstChild("SellFish") or 
                      FishingSystem:FindFirstChild("SellAllFish")
    
    if sellRemote then
        for rarity, order in pairs(RarityOrder) do
            local sellOrder = RarityOrder[Config.SellBelowRarity] or 3
            if order < sellOrder then
                pcall(function()
                    sellRemote:FireServer(rarity)
                    task.wait(0.1)
                end)
            end
        end
        Library:Notify("Sell completed!", 3)
    end
end)

-- STATS & INFO
local StatsTab = Window:NewTab("Stats")
local LiveStats = StatsTab:NewSection("Live Statistics")

local TotalCatches = LiveStats:NewLabel("Total Catches: 0")
local CurrentRarity = LiveStats:NewLabel("Current Rarity: Unknown")
local CurrentWeight = LiveStats:NewLabel("Current Weight: 0kg")
local WeightModeLabel = LiveStats:NewLabel("Weight Mode: Custom")

-- Update live stats
task.spawn(function()
    while task.wait(1) do
        TotalCatches:UpdateLabel("Total Catches: " .. CatchCount)
        CurrentRarity:UpdateLabel("Target Rarity: " .. Config.MinRarity .. " - " .. Config.MaxRarity)
        CurrentWeight:UpdateLabel("Target Weight: " .. Config.MinWeight .. "kg - " .. Config.MaxWeight .. "kg")
        WeightModeLabel:UpdateLabel("Weight Mode: " .. Config.RandomWeights.Mode .. 
            (Config.RandomWeights.Enabled and " (Active)" : " (Inactive)"))
    end
end)

-- UTILITIES TAB
local UtilTab = Window:NewTab("Utilities")
local UtilitySection = UtilTab:NewSection("Tools")

UtilitySection:NewToggle("Bypass Cooldown", "Remove fishing cooldown", function(state)
    Config.BypassCooldown = state
end)

UtilitySection:NewToggle("Anti-AFK", "Prevent AFK kick", function(state)
    Config.AntiAFK = state
end)

UtilitySection:NewButton("Hook Game Functions", "Force hook fishing module", function()
    HookGameFunctions()
    BackupWeightData()
    Library:Notify(moduleHookActive and "Hook successful!" or "Hook failed", 3)
end)

UtilitySection:NewButton("Test Silent Catch", "Test silent catch system", function()
    local success = SilentCatchFish()
    Library:Notify(success and "Silent catch successful!" or "Silent catch failed", 3)
end)

UtilitySection:NewButton("Activate Random Weights", "Enable random weight system", function()
    ToggleRandomWeights(true)
    Config.RandomWeights.Enabled = true
    Library:Notify("Random Weights Activated!", 3)
end)

-- ANTI-AFK SYSTEM
if Config.AntiAFK then
    task.spawn(function()
        while task.wait(60) do
            if Config.AntiAFK then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, "LeftControl", false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "LeftControl", false, game)
                end)
            end
        end
    end)
end

-- INITIALIZATION
Library:Notify("Fishing Exploit v3.0 Loaded!", 5)

-- Auto-hook on startup
task.wait(1)
HookGameFunctions()
if Config.RandomWeights.Enabled then
    ToggleRandomWeights(true)
end
