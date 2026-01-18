-- GREAT WHITE SHARK FORCE CATCH EXPLOIT
-- Target: Force catch Great White Shark (Mythic rarity)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 10)

-- Target fish configuration
local TARGET_FISH = {
    Id = "Fish_GreatWhiteShark",
    Name = "Great White Shark",
    Rarity = "Mythic", -- Atau mungkin "Legendary" tergantung game
    MinWeight = 200,
    MaxWeight = 2000,
    PricePerKG = 36000,
    BaseChance = 0.05 -- 1 in 2000
}

-- Hook fishing module untuk force Great White Shark
local function HookForGreatWhiteShark()
    -- Cari fishing module
    for _, module in pairs(getloadedmodules() or {}) do
        if module.Name:lower():find("fish") or module.Name:find("Fishing") then
            local success, moduleData = pcall(require, module)
            if success and type(moduleData) == "table" then
                
                -- OVERRIDE 1: RollFish function
                if moduleData.RollFish then
                    local originalRollFish = moduleData.RollFish
                    moduleData.RollFish = function(pityTracker, rodName, luckMultiplier)
                        -- 80% chance untuk Great White Shark
                        if math.random() <= 0.8 then
                            -- Generate weight
                            local weight = math.random(TARGET_FISH.MinWeight * 10, 
                                                     TARGET_FISH.MaxWeight * 10) / 10
                            
                            return {
                                name = TARGET_FISH.Name,
                                rarity = TARGET_FISH.Rarity,
                                id = TARGET_FISH.Id,
                                minKg = TARGET_FISH.MinWeight,
                                maxKg = TARGET_FISH.MaxWeight,
                                weight = weight,
                                value = weight * TARGET_FISH.PricePerKG
                            }
                        else
                            -- 20% chance untuk fish biasa
                            return originalRollFish(pityTracker, rodName, luckMultiplier)
                        end
                    end
                end
                
                -- OVERRIDE 2: GetRarityWithPity (jika ada)
                if moduleData.GetRarityWithPity then
                    local originalGetRarity = moduleData.GetRarityWithPity
                    moduleData.GetRarityWithPity = function(pityTable, rodName, luckMultiplier)
                        -- Force Mythic/Legendary rarity untuk Great White Shark
                        return TARGET_FISH.Rarity
                    end
                end
                
                -- OVERRIDE 3: FishTable manipulation
                if moduleData.FishTable then
                    -- Tambah probability Great White Shark
                    for _, fish in pairs(moduleData.FishTable) do
                        if fish.name == TARGET_FISH.Name or fish.Id == TARGET_FISH.Id then
                            fish.probability = 1000 -- Increase probability dramatically
                            fish.rarity = TARGET_FISH.Rarity
                        end
                    end
                    
                    -- Atau tambah fish baru jika tidak ada
                    local found = false
                    for _, fish in pairs(moduleData.FishTable) do
                        if fish.name == TARGET_FISH.Name then
                            found = true
                            break
                        end
                    end
                    
                    if not found then
                        table.insert(moduleData.FishTable, {
                            name = TARGET_FISH.Name,
                            rarity = TARGET_FISH.Rarity,
                            probability = 1000,
                            minKg = TARGET_FISH.MinWeight,
                            maxKg = TARGET_FISH.MaxWeight
                        })
                    end
                end
                
                -- OVERRIDE 4: RarityWeights manipulation
                if moduleData.RarityWeights then
                    -- Increase weight untuk Mythic/Legendary
                    local targetRarity = TARGET_FISH.Rarity
                    if moduleData.RarityWeights[targetRarity] then
                        moduleData.RarityWeights[targetRarity] = 100 -- Very high
                    end
                end
                
                return true
            end
        end
    end
    return false
end

-- GUI untuk control
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Great White Shark Hunter", "DarkTheme")

local MainTab = Window:NewTab("Main")
local SharkSection = MainTab:NewSection("Great White Shark Control")

local forceSharkEnabled = false

SharkSection:NewToggle("FORCE GREAT WHITE SHARK", 
    "80% chance untuk catch Great White Shark", function(state)
    forceSharkEnabled = state
    
    if state then
        HookForGreatWhiteShark()
    else
        -- Note: Might need game restart to fully undo hooks
    end
end)

-- Weight control untuk Great White Shark
SharkSection:NewSlider("Min Weight", "Minimum weight (kg)", 
    2000, 200, 500, function(value)
    TARGET_FISH.MinWeight = value
end)

SharkSection:NewSlider("Max Weight", "Maximum weight (kg)", 
    5000, 1000, 2000, function(value)
    TARGET_FISH.MaxWeight = value
end)

SharkSection:NewSlider("Catch Chance", "Probability percentage", 
    100, 10, 100, function(value)
    -- Update probability
    for _, module in pairs(getloadedmodules() or {}) do
        local success, moduleData = pcall(require, module)
        if success and moduleData.FishTable then
            for _, fish in pairs(moduleData.FishTable) do
                if fish.name == TARGET_FISH.Name then
                    fish.probability = value * 10
                    break
                end
            end
        end
    end
end)

-- Instant catch Great White Shark button
SharkSection:NewButton("CATCH GREAT WHITE SHARK NOW", 
    "Force catch immediately", function()
    
    -- Cari remote untuk catch fish
    local catchRemote = FishingSystem:FindFirstChild("CatchFish") or
                       FishingSystem:FindFirstChild("CompleteFishing") or
                       FishingSystem:FindFirstChild("AddFishToInventory")
    
    if catchRemote then
        -- Generate weight
        local weight = math.random(TARGET_FISH.MinWeight * 10, 
                                 TARGET_FISH.MaxWeight * 10) / 10
        
        local fishData = {
            Name = TARGET_FISH.Name,
            Id = TARGET_FISH.Id,
            Rarity = TARGET_FISH.Rarity,
            Weight = weight,
            Value = weight * TARGET_FISH.PricePerKG,
            MinWeight = TARGET_FISH.MinWeight,
            MaxWeight = TARGET_FISH.MaxWeight
        }
        
        -- Fire remote
        local success = pcall(function()
            if catchRemote:IsA("RemoteEvent") then
                catchRemote:FireServer(fishData)
            elseif catchRemote:IsA("RemoteFunction") then
                catchRemote:InvokeServer(fishData)
            end
        end)
        
        if success then
            Library:Notify("Great White Shark Caught!", 3)
        end
    end
end)

-- Auto farm Great White Shark
local autoFarmShark = false
local sharkFarmThread

SharkSection:NewToggle("AUTO FARM GREAT WHITE SHARK", 
    "Automatically farm sharks", function(state)
    autoFarmShark = state
    
    if state then
        sharkFarmThread = task.spawn(function()
            while autoFarmShark do
                -- Start fishing
                local castRemote = FishingSystem:FindFirstChild("CastLine") or
                                  FishingSystem:FindFirstChild("StartFishing")
                
                if castRemote then
                    pcall(function()
                        castRemote:FireServer()
                    end)
                    
                    task.wait(0.5)
                    
                    -- Force catch Great White Shark
                    local catchRemote = FishingSystem:FindFirstChild("CatchFish")
                    if catchRemote then
                        local weight = math.random(TARGET_FISH.MinWeight * 10, 
                                                 TARGET_FISH.MaxWeight * 10) / 10
                        
                        local fishData = {
                            Name = TARGET_FISH.Name,
                            Rarity = TARGET_FISH.Rarity,
                            Weight = weight,
                            Value = weight * TARGET_FISH.PricePerKG
                        }
                        
                        pcall(function()
                            catchRemote:FireServer(fishData)
                        end)
                    end
                end
                
                task.wait(2) -- Delay between catches
            end
        end)
    else
        if sharkFarmThread then
            task.cancel(sharkFarmThread)
            sharkFarmThread = nil
        end
    end
end)

-- Statistics
local StatsTab = Window:NewTab("Stats")
local StatsSection = StatsTab:NewSection("Shark Statistics")

local sharksCaught = 0
local totalWeight = 0
local totalValue = 0

local caughtLabel = StatsSection:NewLabel("Sharks Caught: 0")
local avgWeightLabel = StatsSection:NewLabel("Avg Weight: 0kg")
local totalValueLabel = StatsSection:NewLabel("Total Value: $0")

-- Hook untuk track catches
local function TrackSharkCatch(fishData)
    if fishData and fishData.Name == TARGET_FISH.Name then
        sharksCaught += 1
        totalWeight += (fishData.Weight or 0)
        totalValue += (fishData.Value or 0)
        
        caughtLabel:UpdateLabel("Sharks Caught: " .. sharksCaught)
        local avgWeight = sharksCaught > 0 and totalWeight / sharksCaught or 0
        avgWeightLabel:UpdateLabel(string.format("Avg Weight: %.1fkg", avgWeight))
        totalValueLabel:UpdateLabel(string.format("Total Value: $%d", totalValue))
    end
end

-- Hook catch remote untuk tracking
local catchRemote = FishingSystem:FindFirstChild("CatchFish")
if catchRemote and catchRemote:IsA("RemoteEvent") then
    local oldFire = catchRemote.FireServer
    catchRemote.FireServer = function(self, ...)
        local args = {...}
        if #args > 0 and type(args[1]) == "table" then
            TrackSharkCatch(args[1])
        end
        return oldFire(self, ...)
    end
end

-- Reset stats
StatsSection:NewButton("Reset Statistics", "Reset catch counters", function()
    sharksCaught = 0
    totalWeight = 0
    totalValue = 0
    
    caughtLabel:UpdateLabel("Sharks Caught: 0")
    avgWeightLabel:UpdateLabel("Avg Weight: 0kg")
    totalValueLabel:UpdateLabel("Total Value: $0")
end)

-- Utilities
local UtilTab = Window:NewTab("Utilities")
local UtilSection = UtilTab:NewSection("Shark Utilities")

UtilSection:NewButton("Hook Fishing Module", 
    "Force hook module untuk Great White Shark", function()
    local success = HookForGreatWhiteShark()
    Library:Notify(success and "Hook successful!" or "Hook failed", 3)
end)

UtilSection:NewButton("Increase Shark Rarity Weight", 
    "Increase rarity probability", function()
    for _, module in pairs(getloadedmodules() or {}) do
        local success, moduleData = pcall(require, module)
        if success and moduleData.RarityWeights then
            if moduleData.RarityWeights["Mythic"] then
                moduleData.RarityWeights["Mythic"] = 100
            elseif moduleData.RarityWeights["Legendary"] then
                moduleData.RarityWeights["Legendary"] = 100
            end
            break
        end
    end
    Library:Notify("Rarity weight increased", 3)
end)

-- Price multiplier
UtilSection:NewSlider("Price Multiplier", 
    "Multiply Great White Shark value", 100, 1, 10, function(value)
    TARGET_FISH.PricePerKG = 36000 * value
end)

-- INITIALIZATION
Library:Notify("Great White Shark Hunter Loaded!", 5)

-- Auto-hook on start
task.wait(1)
HookForGreatWhiteShark()

print("Great White Shark exploit activated!")
print("Target: " .. TARGET_FISH.Name)
print("Rarity: " .. TARGET_FISH.Rarity)
print("Weight Range: " .. TARGET_FISH.MinWeight .. "kg - " .. TARGET_FISH.MaxWeight .. "kg")
print("Price: $" .. TARGET_FISH.PricePerKG .. " per kg")