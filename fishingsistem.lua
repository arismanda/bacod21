local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 10)

if not FishingSystem then
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name:lower():find("fish") and obj:IsA("ModuleScript") then
            FishingSystem = obj.Parent
            break
        end
    end
end

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
    RandomWeight = {
        Enabled = true,
        Mode = "CustomRange",
        MinRange = 1,
        MaxRange = 999,
        Bias = 0.7,
        Fluctuation = 0.3
    },
    WebhookNotify = false,
    AntiAFK = true,
    BypassCooldown = false
}

local RarityOrder = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Unknown = 6
}

local originalModule
local moduleHookActive = false
local originalWeightData = {}
local weightHooks = {}

local function BackupOriginalWeights()
    if originalModule and originalModule.FishTable then
        originalWeightData = {}
        for i, fish in pairs(originalModule.FishTable) do
            originalWeightData[i] = {
                minKg = fish.minKg,
                maxKg = fish.maxKg,
                name = fish.name
            }
        end
    end
end

local function ApplyRandomWeightMode()
    if not Config.RandomWeight.Enabled or not originalModule then return end
    
    if Config.RandomWeight.Mode == "Original" then
        for i, fish in pairs(originalModule.FishTable) do
            local original = originalWeightData[i]
            if original then
                fish.minKg = original.minKg
                fish.maxKg = original.maxKg
            end
        end
    elseif Config.RandomWeight.Mode == "CustomRange" then
        for _, fish in pairs(originalModule.FishTable) do
            fish.minKg = Config.RandomWeight.MinRange
            fish.maxKg = Config.RandomWeight.MaxRange
        end
    elseif Config.RandomWeight.Mode == "Extreme" then
        for _, fish in pairs(originalModule.FishTable) do
            local scale = RarityOrder[fish.rarity] or 1
            fish.minKg = 50 * scale
            fish.maxKg = 500 * scale
        end
    elseif Config.RandomWeight.Mode == "Chaos" then
        for _, fish in pairs(originalModule.FishTable) do
            fish.minKg = math.random(1, 100)
            fish.maxKg = math.random(200, 999)
        end
    end
    
    for _, fish in pairs(originalModule.FishTable) do
        if fish.minKg >= fish.maxKg then
            fish.maxKg = fish.minKg + 100
        end
        if fish.maxKg > 9999 then
            fish.maxKg = 9999
        end
    end
end

local function GenerateRandomWeight(fishData, rodConfig)
    if not Config.RandomWeight.Enabled then
        return nil
    end
    
    local mode = Config.RandomWeight.Mode
    local minW, maxW
    
    if mode == "CustomRange" then
        minW = Config.RandomWeight.MinRange
        maxW = Config.RandomWeight.MaxRange
    elseif mode == "Extreme" then
        minW = 100
        maxW = 999
    elseif mode == "Chaos" then
        minW = math.random(1, 100)
        maxW = math.random(200, 999)
    else
        minW = fishData.minKg or 1
        maxW = math.min(fishData.maxKg or 100, rodConfig.maxWeight or 999)
    end
    
    local random = math.random()
    local bias = Config.RandomWeight.Bias or 0.7
    
    local weight
    if random < (1 - bias) then
        weight = minW + (maxW - minW) * 0.3 * math.random()
    else
        weight = maxW * 0.7 + (maxW * 0.3) * math.random()
    end
    
    local fluctuation = Config.RandomWeight.Fluctuation or 0.3
    weight = weight * (1 + (math.random() * 2 - 1) * fluctuation)
    
    local precision = Config.WeightPrecision or 1
    local multiplier = 10 ^ precision
    weight = math.floor(weight * multiplier + 0.5) / multiplier
    
    weight = math.max(Config.MinWeight, math.min(Config.MaxWeight, weight))
    weight = math.max(minW, math.min(maxW, weight))
    
    return weight
end

local function HookGameFunctions()
    if moduleHookActive then return end
    
    for _, module in pairs(getloadedmodules() or {}) do
        if module.Name:lower():find("fish") or module.Name:find("Fishing") then
            local success, moduleData = pcall(require, module)
            if success and type(moduleData) == "table" then
                originalModule = moduleData
                BackupOriginalWeights()
                
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
                
                if moduleData.GenerateFishWeight then
                    local originalGenWeight = moduleData.GenerateFishWeight
                    weightHooks.GenerateFishWeight = originalGenWeight
                    
                    moduleData.GenerateFishWeight = function(fishData, rodLuck, maxWeight)
                        if Config.InstantCatch then
                            local customWeight = GenerateRandomWeight(fishData, {maxWeight = maxWeight})
                            if customWeight then
                                return customWeight
                            end
                            
                            local minWeight = math.max(Config.MinWeight, fishData.minKg or 0.5)
                            local maxWeightAllowed = math.min(Config.MaxWeight, fishData.maxKg or 999, maxWeight or 999)
                            
                            if minWeight > maxWeightAllowed then
                                return maxWeightAllowed
                            end
                            
                            local randomFactor = math.random()
                            local weight = minWeight + (randomFactor * (maxWeightAllowed - minWeight))
                            local multiplier = 10 ^ Config.WeightPrecision
                            weight = math.floor(weight * multiplier + 0.5) / multiplier
                            return weight
                        end
                        return originalGenWeight(fishData, rodLuck, maxWeight)
                    end
                end
                
                if moduleData.RollFish then
                    local originalRollFish = moduleData.RollFish
                    moduleData.RollFish = function(pityTable, rodName, luckMultiplier)
                        if Config.SilentCatch then
                            local fishTable = moduleData.FishTable or {}
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
                                local weight
                                
                                if Config.RandomWeight.Enabled then
                                    weight = GenerateRandomWeight(selectedFish, {})
                                else
                                    weight = math.random(Config.MinWeight * 10, Config.MaxWeight * 10) / 10
                                end
                                
                                local multiplier = 10 ^ Config.WeightPrecision
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
                
                ApplyRandomWeightMode()
                moduleHookActive = true
                break
            end
        end
    end
end

local function SilentCatchFish()
    if not Config.SilentCatch then return end
    
    local catchRemote = FishingSystem:FindFirstChild("CatchFish") or 
                       FishingSystem:FindFirstChild("ReelIn") or
                       FishingSystem:FindFirstChild("CompleteFishing")
    
    if catchRemote then
        local weight
        if Config.RandomWeight.Enabled then
            weight = GenerateRandomWeight({}, {})
        else
            weight = math.random(Config.MinWeight * 10, Config.MaxWeight * 10) / 10
        end
        
        local fakeFishData = {
            Name = "Megalodon",
            Rarity = Config.MaxRarity,
            Weight = weight,
            Value = 9999
        }
        
        local success = pcall(function()
            if catchRemote:IsA("RemoteEvent") then
                catchRemote:FireServer(fakeFishData)
            elseif catchRemote:IsA("RemoteFunction") then
                catchRemote:InvokeServer(fakeFishData)
            end
        end)
        
        return success
    end
    return false
end

local function GiveFishToPlayer(targetName, fishName, rarity, weight)
    if not Config.FishGiver.Enabled or targetName == "" then return end
    
    local targetPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName:lower()) or player.DisplayName:lower():find(targetName:lower()) then
            targetPlayer = player
            break
        end
    end
    
    if not targetPlayer then return false end
    
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
        end)
        
        return success
    end
    
    return false
end

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
                end)
                
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

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fishing Simulator v5.0", "DarkTheme")

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

FishingSection:NewToggle("Silent Catch", "No animation", function(state)
    Config.SilentCatch = state
end)

local RarityTab = Window:NewTab("Rarity Control")
local MinRaritySection = RarityTab:NewSection("Minimum Rarity")

local MinRarityDropdown = MinRaritySection:NewDropdown("Min Rarity", "Lowest rarity", 
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, 
    function(selected)
        Config.MinRarity = selected
    end)
MinRarityDropdown:SetOption("Common")

local MaxRaritySection = RarityTab:NewSection("Maximum Rarity")
local MaxRarityDropdown = MaxRaritySection:NewDropdown("Max Rarity", "Highest rarity", 
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, 
    function(selected)
        Config.MaxRarity = selected
    end)
MaxRarityDropdown:SetOption("Unknown")

local WeightTab = Window:NewTab("Weight Control")

local WeightRangeSection = WeightTab:NewSection("Weight Range")

local MinWeightSlider = WeightRangeSection:NewSlider("Min Weight", "Minimum weight", 1000, 0.1, function(value)
    Config.MinWeight = value
end)
MinWeightSlider:SetValue(1)

local MaxWeightSlider = WeightRangeSection:NewSlider("Max Weight", "Maximum weight", 1000, 0.1, function(value)
    Config.MaxWeight = value
end)
MaxWeightSlider:SetValue(999)

local RandomWeightSection = WeightTab:NewSection("Random Weight")

RandomWeightSection:NewToggle("Enable Random Weight", "Randomize weights", function(state)
    Config.RandomWeight.Enabled = state
    if state and originalModule then
        ApplyRandomWeightMode()
    end
end)

local WeightModeDropdown = RandomWeightSection:NewDropdown("Weight Mode", "Weight generation mode", 
    {"Original", "CustomRange", "Extreme", "Chaos"}, 
    function(selected)
        Config.RandomWeight.Mode = selected
        if Config.RandomWeight.Enabled and originalModule then
            ApplyRandomWeightMode()
        end
    end)
WeightModeDropdown:SetOption("CustomRange")

local CustomMinSlider = RandomWeightSection:NewSlider("Custom Min", "Minimum for custom mode", 
    1000, 1, 100, function(value)
    Config.RandomWeight.MinRange = value
    if Config.RandomWeight.Enabled and Config.RandomWeight.Mode == "CustomRange" and originalModule then
        ApplyRandomWeightMode()
    end
end)
CustomMinSlider:SetValue(1)

local CustomMaxSlider = RandomWeightSection:NewSlider("Custom Max", "Maximum for custom mode", 
    1000, 100, 999, function(value)
    Config.RandomWeight.MaxRange = value
    if Config.RandomWeight.Enabled and Config.RandomWeight.Mode == "CustomRange" and originalModule then
        ApplyRandomWeightMode()
    end
end)
CustomMaxSlider:SetValue(999)

local BiasSlider = RandomWeightSection:NewSlider("Weight Bias", "Bias to high weights", 
    100, 0, 100, function(value)
    Config.RandomWeight.Bias = value / 100
end)
BiasSlider:SetValue(70)

local FluctuationSlider = RandomWeightSection:NewSlider("Fluctuation", "Random variation", 
    100, 0, 100, function(value)
    Config.RandomWeight.Fluctuation = value / 100
end)
FluctuationSlider:SetValue(30)

local PrecisionSection = WeightTab:NewSection("Precision")
local PrecisionSlider = PrecisionSection:NewSlider("Decimal Places", "Weight precision", 3, 0, function(value)
    Config.WeightPrecision = value
end)
PrecisionSlider:SetValue(1)

RandomWeightSection:NewButton("Apply Weight Mode", "Apply current settings", function()
    if originalModule then
        ApplyRandomWeightMode()
        Library:Notify("Weight mode applied", 3)
    end
end)

local GiveTab = Window:NewTab("Fish Giver")
local GiveSection = GiveTab:NewSection("Give Fish")

GiveSection:NewToggle("Enable FishGiver", "Allow giving", function(state)
    Config.FishGiver.Enabled = state
end)

local PlayerTextBox = GiveSection:NewTextBox("Target Player", "Player name", function(text)
    Config.FishGiver.TargetPlayer = text
end)

local FishDropdown = GiveSection:NewDropdown("Fish Type", "Select fish", 
    {"Megalodon", "Ancient Whale", "El Maja", "Plasma Shark", "Pink Dolphin", "Custom"}, 
    function(selected)
        Config.FishGiver.FishName = selected
    end)
FishDropdown:SetOption("Megalodon")

local GiveRarityDropdown = GiveSection:NewDropdown("Give Rarity", "Rarity", 
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, 
    function(selected)
        Config.FishGiver.Rarity = selected
    end)
GiveRarityDropdown:SetOption("Unknown")

local GiveWeightSlider = GiveSection:NewSlider("Give Weight", "Weight", 1000, 1, function(value)
    Config.FishGiver.Weight = value
end)
GiveWeightSlider:SetValue(999)

GiveSection:NewButton("Give Fish Now", "Execute give", function()
    local target = Config.FishGiver.TargetPlayer
    if target and target ~= "" then
        GiveFishToPlayer(target, Config.FishGiver.FishName, Config.FishGiver.Rarity, Config.FishGiver.Weight)
        Library:Notify("Fish give attempted", 3)
    else
        Library:Notify("Enter player name", 5)
    end
end)

local SellTab = Window:NewTab("Auto Sell")
local SellSettings = SellTab:NewSection("Sell Configuration")

SellSettings:NewToggle("Auto Sell", "Automatically sell", function(state)
    Config.AutoSell = state
end)

local SellBelowDropdown = SellSettings:NewDropdown("Sell Below", "Sell below rarity", 
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, 
    function(selected)
        Config.SellBelowRarity = selected
    end)
SellBelowDropdown:SetOption("Rare")

SellSettings:NewButton("Sell All Now", "Sell all", function()
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
        Library:Notify("Sell completed", 3)
    end
end)

local StatsTab = Window:NewTab("Stats")
local LiveStats = StatsTab:NewSection("Statistics")

local TotalCatches = LiveStats:NewLabel("Total Catches: 0")
local CurrentRarity = LiveStats:NewLabel("Rarity Range: Common - Unknown")
local CurrentWeight = LiveStats:NewLabel("Weight Range: 1kg - 999kg")
local WeightModeLabel = LiveStats:NewLabel("Weight Mode: CustomRange")

task.spawn(function()
    while task.wait(1) do
        TotalCatches:UpdateLabel("Total Catches: " .. CatchCount)
        CurrentRarity:UpdateLabel("Rarity Range: " .. Config.MinRarity .. " - " .. Config.MaxRarity)
        CurrentWeight:UpdateLabel("Weight Range: " .. Config.MinWeight .. "kg - " .. Config.MaxWeight .. "kg")
        WeightModeLabel:UpdateLabel("Weight Mode: " .. Config.RandomWeight.Mode .. 
            (Config.RandomWeight.Enabled and " (Active)" or " (Inactive)"))
    end
end)

local UtilTab = Window:NewTab("Utilities")
local UtilitySection = UtilTab:NewSection("Tools")

UtilitySection:NewToggle("Bypass Cooldown", "Remove cooldown", function(state)
    Config.BypassCooldown = state
end)

UtilitySection:NewToggle("Anti-AFK", "Prevent AFK", function(state)
    Config.AntiAFK = state
end)

UtilitySection:NewButton("Hook Functions", "Hook module", function()
    HookGameFunctions()
    Library:Notify(moduleHookActive and "Hooked" or "Failed", 3)
end)

UtilitySection:NewButton("Test Silent Catch", "Test catch", function()
    local success = SilentCatchFish()
    Library:Notify(success and "Success" or "Failed", 3)
end)

UtilitySection:NewButton("Activate Random Weight", "Enable random", function()
    Config.RandomWeight.Enabled = true
    if originalModule then
        ApplyRandomWeightMode()
    end
    Library:Notify("Random weight activated", 3)
end)

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

Library:Notify("Exploit Loaded", 5)

task.wait(1)
HookGameFunctions()
if Config.RandomWeight.Enabled then
    ApplyRandomWeightMode()
end
