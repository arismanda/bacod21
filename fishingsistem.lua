-- DYRON EXECUTOR v1.0: Ultimate Fishing Exploit Suite
-- Engine: Reverse-Engineered Module v2_upvr
-- Build: Hyper-Optimized for Precision Control

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Auto-detect module
local FishingModule
for _, module in pairs(getloadedmodules() or getinstances()) do
    if type(module) == "table" and module.GetRodConfig and module.RodConfig then
        FishingModule = module
        break
    end
end

if not FishingModule then
    FishingModule = require(ReplicatedStorage:WaitForChild("FishingSystem"):WaitForChild("FishingConfig"))
end

-- GUI Construction
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("DYRON FISHING EXECUTOR v1.0", "DarkTheme")

-- Main Tabs
local MainTab = Window:NewTab("Core Exploits")
local RodTab = Window:NewTab("Rod Control")
local AutoTab = Window:NewTab("Automation")
local TeleportTab = Window:NewTab("Teleport")
local MiscTab = Window:NewTab("Misc")

-- CORE EXPLOITS SECTION
local MainSection = MainTab:NewSection("Instant Catch & Rarity Control")

local InstantCatchToggle = MainSection:NewToggle("Instant Catch", "Skip minigame completely", function(state)
    if state then
        -- Hook the fishing remote
        local remote = ReplicatedStorage:FindFirstChild("FishingSystem"):FindFirstChild("StartFishing")
        if remote then
            local old; old = hookfunction(remote.FireServer, function(self, ...)
                local args = {...}
                -- Immediately complete fishing
                local completeRemote = ReplicatedStorage.FishingSystem:FindFirstChild("CompleteFishing")
                if completeRemote then
                    spawn(function()
                        wait(0.1)
                        completeRemote:FireServer(true) -- Force success
                    end)
                end
                return old(self, ...)
            end)
        end
    end
end)

local BypassCooldown = MainSection:NewToggle("No Fishing Cooldown", "Remove delay between catches", function(state)
    while state do
        -- Find and modify cooldown values
        for _, obj in pairs(getgc()) do
            if type(obj) == "table" and rawget(obj, "cooldown") then
                rawset(obj, "cooldown", 0)
            end
        end
        task.wait(0.5)
    end
end)

-- RARITY SELECTOR
local RarityDropdown = MainSection:NewDropdown("Force Rarity", "Select fish rarity", 
    {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, function(selected)
    -- Override the RollFish function
    local oldRoll = FishingModule.RollFish
    FishingModule.RollFish = function(pityTracker, rodName, luckMultiplier)
        local forcedFish
        for _, fishData in pairs(FishingModule.FishTable) do
            if fishData.rarity == selected then
                forcedFish = fishData
                break
            end
        end
        
        if forcedFish then
            -- Generate weight with multiplier
            local rodConfig = FishingModule.GetRodConfig(rodName)
            local maxWeight = rodConfig.maxWeight
            local weight = math.random(forcedFish.minKg * 10, math.min(forcedFish.maxKg, maxWeight) * 10) / 10
            
            return {
                name = forcedFish.name,
                rarity = selected,
                minKg = forcedFish.minKg,
                maxKg = forcedFish.maxKg,
                probability = forcedFish.probability,
                _weight = weight
            }
        end
        return oldRoll(pityTracker, rodName, luckMultiplier)
    end
end)

-- WEIGHT CONTROL
local WeightSection = MainTab:NewSection("Weight Manipulation")

local MinWeightSlider = WeightSection:NewSlider("Min Weight (kg)", "Set minimum weight", 1000, 0.5, function(value)
    local oldGen = FishingModule.GenerateFishWeight
    FishingModule.GenerateFishWeight = function(fishData, rodLuck, maxRodWeight)
        local base = oldGen(fishData, rodLuck, maxRodWeight)
        return math.max(base, value)
    end
end)

local MaxWeightSlider = WeightSection:NewSlider("Max Weight (kg)", "Set maximum weight", 1000, 100, function(value)
    local oldGen = FishingModule.GenerateFishWeight
    FishingModule.GenerateFishWeight = function(fishData, rodLuck, maxRodWeight)
        local base = oldGen(fishData, rodLuck, math.min(maxRodWeight, value))
        return math.min(base, value)
    end
end)

local RandomWeightToggle = WeightSection:NewToggle("Random Extreme Weights", "Generate unrealistic weights", function(state)
    if state then
        local originalTable = FishingModule.FishTable
        for _, fish in pairs(originalTable) do
            fish.minKg = 1
            fish.maxKg = 9999
        end
    else
        -- Restore original values (would need backup)
    end
end)

-- ROD CONTROL SECTION
local RodSection = RodTab:NewSection("Rod Hacks")

local AllRodsDropdown = RodSection:NewDropdown("Equip Any Rod", "Use unobtainable rods", 
    {"Owner Rod", "Admin Rod", "Developer Rod", "Megalofriend", "Manifest", "Ancient Rod"}, function(selected)
    
    local fakeRod = {
        Name = selected,
        Config = FishingModule.GetRodConfig(selected)
    }
    
    -- Inject into player's inventory
    local player = Players.LocalPlayer
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = Instance.new("Tool")
        tool.Name = selected
        tool.Parent = backpack
    end
    
    -- Force equip via remote
    local equipRemote = ReplicatedStorage:FindFirstChild("FishingSystem"):FindFirstChild("EquipRod")
    if equipRemote then
        equipRemote:FireServer(selected)
    end
end)

local LuckMultiplier = RodSection:NewSlider("Luck Multiplier", "Multiply base luck", 1000, 1, function(value)
    for rodName, config in pairs(FishingModule.RodConfig) do
        if config.baseLuck then
            config.baseLuck = config.baseLuck * value
        end
    end
end)

-- AUTO FARMING SECTION
local AutoSection = AutoTab:NewSection("Auto Farm Configuration")

local AutoFishToggle = AutoSection:NewToggle("Auto Fish", "Automatically catch fish", function(state)
    local fishing = false
    
    while state do
        if not fishing then
            local remote = ReplicatedStorage.FishingSystem:FindFirstChild("StartFishing")
            if remote then
                remote:FireServer()
                fishing = true
                
                -- Auto-complete after delay
                spawn(function()
                    task.wait(0.5)
                    local complete = ReplicatedStorage.FishingSystem:FindFirstChild("CompleteFishing")
                    if complete then
                        complete:FireServer(true)
                        fishing = false
                    end
                end)
            end
        end
        task.wait(1) -- Adjust delay as needed
    end
end)

local AutoSellToggle = AutoSection:NewToggle("Auto Sell", "Automatically sell fish", function(state)
    while state do
        local sellRemote = ReplicatedStorage.FishingSystem:FindFirstChild("SellFish")
        if sellRemote then
            -- Sell all fish
            for i = 1, 50 do
                sellRemote:FireServer("all")
                task.wait(0.1)
            end
        end
        task.wait(5) -- Sell every 5 seconds
    end
end)

-- TELEPORT SECTION
local TeleSection = TeleportTab:NewSection("Location Teleport")

local fishingSpots = {
    ["Deep Ocean"] = Vector3.new(-150, 5, 280),
    ["Ice Lake"] = Vector3.new(200, 10, -400),
    ["Volcano Pool"] = Vector3.new(350, 25, 150),
    ["Secret Cave"] = Vector3.new(-500, -50, -200)
}

for spotName, position in pairs(fishingSpots) do
    TeleSection:NewButton("TP to " .. spotName, "Teleport to fishing spot", function()
        local char = Players.LocalPlayer.Character
        if char then
            char:SetPrimaryPartCFrame(CFrame.new(position))
        end
    end)
end

-- MISC SECTION
local MiscSection = MiscTab:NewSection("Utility Hacks")

MiscSection:NewButton("Unlock All Gamepasses", "Activate paid rods", function()
    for rodName, config in pairs(FishingModule.RodConfig) do
        if config.isGamepass then
            config.isGamepass = false
        end
    end
end)

MiscSection:NewButton("Infinite Inventory", "Remove fish limit", function()
    if FishingModule.InventoryLimitSettings then
        FishingModule.InventoryLimitSettings.maxFishInventory = 999999
        FishingModule.InventoryLimitSettings.enabled = false
    end
end)

MiscSection:NewSlider("Sell Price Multiplier", "Multiply fish value", 100, 1, function(value)
    if FishingModule.SellingSettings then
        for rarity, mult in pairs(FishingModule.SellingSettings.rarityMultiplier) do
            FishingModule.SellingSettings.rarityMultiplier[rarity] = mult * value
        end
    end
end)

-- KEYBINDS
local KeybindSection = MiscTab:NewSection("Keybinds")

KeybindSection:NewKeybind("Toggle GUI", "Show/Hide interface", Enum.KeyCode.RightControl, function()
    Library:ToggleUI()
end)

-- ANTI-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

