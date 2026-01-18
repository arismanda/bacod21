-- Fishing Simulator Ultimate Exploit v3.0
-- Advanced Features: Rarity/Weight Range, Silent Catch, FishGiver
-- Compatible: Synapse X, KRNL, Fluxus, Script-Ware

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 10)

if not FishingSystem then
    warn("[EXPLOIT] Game tidak dikenali, mencari alternative...")
    -- Cari modul fishing
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name:lower():find("fish") and obj:IsA("ModuleScript") then
            FishingSystem = obj.Parent
            break
        end
    end
end

-- CONFIGURASI ADVANCED
local Config = {
    AutoFish = true,
    InstantCatch = true,
    SilentCatch = true,  -- No animation, langsung inventory
    MinRarity = "Common",  -- Rarity minimum
    MaxRarity = "Unknown", -- Rarity maksimum
    MinWeight = 1,        -- KG minimum
    MaxWeight = 999,      -- KG maksimum
    WeightPrecision = 1,  -- Desimal weight (1 = 0.1, 2 = 0.01)
    AutoSell = true,
    SellBelowRarity = "Rare", -- Sell fish dibawah rarity ini
    FishGiver = {
        Enabled = false,
        TargetPlayer = "",
        FishName = "Megalodon",
        Rarity = "Unknown",
        Weight = 999
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

-- OVERRIDE SYSTEM
local originalModule
local moduleHookActive = false

local function HookGameFunctions()
    if moduleHookActive then return end
    
    -- Cari dan hook module fishing
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
                            -- Convert rarity range ke weight
                            local minOrder = RarityOrder[Config.MinRarity] or 1
                            local maxOrder = RarityOrder[Config.MaxRarity] or 6
                            
                            -- Random rarity dalam range
                            local targetOrder = math.random(minOrder, maxOrder)
                            
                            -- Convert back ke nama rarity
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
                
                -- 2. OVERRIDE WEIGHT GENERATION WITH RANGE
                if moduleData.GenerateFishWeight then
                    local originalGenWeight = moduleData.GenerateFishWeight
                    moduleData.GenerateFishWeight = function(fishData, rodLuck, maxWeight)
                        if Config.InstantCatch then
                            -- Generate weight dalam range
                            local minWeight = math.max(Config.MinWeight, fishData.minKg or 0.5)
                            local maxWeightAllowed = math.min(Config.MaxWeight, fishData.maxKg or 999, maxWeight or 999)
                            
                            if minWeight > maxWeightAllowed then
                                return maxWeightAllowed
                            end
                            
                            -- Random weight dengan precision
                            local randomFactor = math.random()
                            local weight = minWeight + (randomFactor * (maxWeightAllowed - minWeight))
                            
                            -- Apply precision
                            local multiplier = 10 ^ Config.WeightPrecision
                            weight = math.floor(weight * multiplier + 0.5) / multiplier
                            
                            return weight
                        end
                        return originalGenWeight(fishData, rodLuck, maxWeight)
                    end
                end
                
                -- 3. OVERRIDE FISH ROLL COMPLETELY
                if moduleData.RollFish then
                    local originalRollFish = moduleData.RollFish
                    moduleData.RollFish = function(pityTable, rodName, luckMultiplier)
                        if Config.SilentCatch then
                            -- Direct fish creation tanpa minigame
                            local fishTable = moduleData.FishTable or {}
                            local rarity = Config.MaxRarity
                            
                            -- Filter fish by rarity range
                            local eligibleFish = {}
                            for _, fish in pairs(fishTable) do
                                local fishOrder = RarityOrder[fish.rarity] or 1
                                local minOrder = RarityOrder[Config.MinRarity] or 1
                                local maxOrder = RarityOrder[Config.MaxRarity] or 6
                                
                                if fishOrder >= minOrder and fishOrder <= maxOrder then
                                    table.insert(eligibleFish, fish)
                                end
                            end
                            
                            -- Pilih random fish
                            if #eligibleFish > 0 then
                                local selectedFish = eligibleFish[math.random(1, #eligibleFish)]
                                
                                -- Custom weight
                                local weight = math.random(Config.MinWeight * 10, Config.MaxWeight * 10) / 10
                                weight = math.floor(weight * (10 ^ Config.WeightPrecision) + 0.5) / (10 ^ Config.WeightPrecision)
                                
                                return {
                                    name = selectedFish.name,
                                    rarity = selectedFish.rarity,
                                    weight = weight,
                                    value = weight * 100  -- Estimated value
                                }
                            end
                        end
                        return originalRollFish(pityTable, rodName, luckMultiplier)
                    end
                end
                
                moduleHookActive = true
                break
            end
        end
    end
end

-- SILENT CATCH SYSTEM (No Animation)
local function SilentCatchFish()
    if not Config.SilentCatch then return end
    
    local catchRemote = FishingSystem:FindFirstChild("CatchFish") or 
                       FishingSystem:FindFirstChild("ReelIn") or
                       FishingSystem:FindFirstChild("CompleteFishing")
    
    if catchRemote then
        -- Create fake fish data
        local fakeFishData = {
            Name = "Megalodon",
            Rarity = Config.MaxRarity,
            Weight = math.random(Config.MinWeight * 10, Config.MaxWeight * 10) / 10,
            Value = 9999
        }
        
        -- Direct invoke tanpa animation
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

-- FISH GIVER FUNCTION (Give Fish to Other Players)
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
    
    -- Find trade/give remote
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
        
        if success then
            print(string.format("[FishGiver] Berhasil give %s (%s, %skg) ke %s", 
                fishData.FishName, fishData.Rarity, fishData.Weight, targetPlayer.Name))
            return true
        end
    end
    
    -- Alternative: Simulate trade through UI
    local tradingUI = game:GetService("CoreGui"):FindFirstChild("TradingUI") or
                     game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Trade")
    
    if tradingUI then
        -- Auto-trade system bisa ditambahkan disini
        warn("[FishGiver] UI Trading ditemukan, butuh manual setup")
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
            
            -- Start fishing
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
                
                -- Wait time berdasarkan config
                local waitTime = Config.BypassCooldown and 0.1 or math.random(0.5, 2.0)
                task.wait(waitTime)
                
                -- Catch method berdasarkan config
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
                
                -- Auto sell periodically
                if Config.AutoSell and CatchCount % 5 == 0 then
                    task.spawn(function()
                        local sellRemote = FishingSystem:FindFirstChild("SellFish")
                        if sellRemote then
                            -- Sell based on rarity filter
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
            
            -- Randomized delay
            local delay = math.random(100, 300) / 100  -- 1.0 to 3.0 seconds
            task.wait(delay)
        end
    end)
end

-- GUI ADVANCED v3.0
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

-- WEIGHT CONTROL SECTION
local WeightTab = Window:NewTab("Weight Control")
local WeightRangeSection = WeightTab:NewSection("Weight Range")

local MinWeightSlider = WeightRangeSection:NewSlider("Min Weight", "Minimum fish weight", 1000, 0.1, function(value)
    Config.MinWeight = value
end)
MinWeightSlider:SetValue(1)

local MaxWeightSlider = WeightRangeSection:NewSlider("Max Weight", "Maximum fish weight", 1000, 0.1, function(value)
    Config.MaxWeight = value
end)
MaxWeightSlider:SetValue(999)

local PrecisionSection = WeightTab:NewSection("Precision")
local PrecisionSlider = PrecisionSection:NewSlider("Decimal Places", "Weight decimal precision", 3, 0, function(value)
    Config.WeightPrecision = value
end)
PrecisionSlider:SetValue(1)

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

-- Update live stats
task.spawn(function()
    while task.wait(1) do
        TotalCatches:UpdateLabel("Total Catches: " .. CatchCount)
        CurrentRarity:UpdateLabel("Target Rarity: " .. Config.MinRarity .. " - " .. Config.MaxRarity)
        CurrentWeight:UpdateLabel("Target Weight: " .. Config.MinWeight .. "kg - " .. Config.MaxWeight .. "kg")
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
    Library:Notify(moduleHookActive and "Hook successful!" or "Hook failed", 3)
end)

UtilitySection:NewButton("Test Silent Catch", "Test silent catch system", function()
    local success = SilentCatchFish()
    Library:Notify(success and "Silent catch successful!" or "Silent catch failed", 3)
end)

-- ANTI-AFK SYSTEM
if Config.AntiAFK then
    task.spawn(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
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
