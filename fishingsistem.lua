-- ========================================================
-- FISHING GOD MODE v3.0 - Complete System Takeover
-- Injection Level: Advanced Memory Manipulation
-- ========================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- MEMORY INJECTION ENGINE
-- ========================================================

local MemoryCore = {
    _originalFunctions = {},
    _hookedRemotes = {},
    _patchedTables = {},
    _antiDetect = true
}

function MemoryCore:HookFunction(targetTable, funcName, newFunc)
    if not targetTable[funcName] then return false end
    
    self._originalFunctions[funcName] = targetTable[funcName]
    targetTable[funcName] = function(...)
        return newFunc(...)
    end
    
    return true
end

function MemoryCore:HookRemote(remote, callback)
    if not remote or not remote.FireServer then return nil end
    
    local originalFire = remote.FireServer
    self._hookedRemotes[remote] = originalFire
    
    remote.FireServer = function(self, ...)
        local args = {...}
        local shouldBlock = callback(args)
        if shouldBlock == false then return nil end
        return originalFire(self, unpack(args))
    end
    
    return function()
        remote.FireServer = originalFire
    end
end

-- ========================================================
-- CORE EXPLOIT MODULES
-- ========================================================

local FishingExploit = {
    Modules = {},
    Config = {
        -- Auto System
        AutoFish = true,
        AutoSell = true,
        AutoReel = true,
        
        -- Economy
        WeightMultiplier = 10.0,
        PriceMultiplier = 20.0,
        FishMultiplier = 3,
        
        -- Probability
        SecretChance = 0.8,
        LegendaryChance = 0.9,
        EpicChance = 1.0,
        
        -- Gameplay
        NoMinigame = true,
        InstantCatch = true,
        TeleportFish = true,
        InfiniteStamina = true,
        
        -- Stealth
        UseSafeMode = false,
        RandomizeWeights = true,
        DelayBetweenActions = 0.5
    }
}

-- ========================================================
-- MODULE 1: PROBABILITY OVERRIDE
-- ========================================================

function FishingExploit:OverrideProbabilitySystem()
    local originalFishTable = module_upvr.FishTable
    
    -- Create enhanced fish table
    local EnhancedFishTable = {}
    
    for _, fish in pairs(originalFishTable) do
        local enhancedFish = table.clone(fish)
        
        -- Boost probabilities based on rarity
        if fish.rarity == "SECRET" then
            enhancedFish.probability = fish.probability * 1000
        elseif fish.rarity == "Legendary" then
            enhancedFish.probability = fish.probability * 500
        elseif fish.rarity == "Epic" then
            enhancedFish.probability = fish.probability * 200
        elseif fish.rarity == "Rare" then
            enhancedFish.probability = fish.probability * 100
        elseif fish.rarity == "Uncommon" then
            enhancedFish.probability = fish.probability * 50
        else
            enhancedFish.probability = fish.probability * 10
        end
        
        -- Increase weight ranges
        enhancedFish.minKg = fish.minKg * self.Config.WeightMultiplier
        enhancedFish.maxKg = math.min(fish.maxKg * self.Config.WeightMultiplier, 9999)
        
        table.insert(EnhancedFishTable, enhancedFish)
    end
    
    -- Override the fish selection function
    MemoryCore:HookFunction(module_upvr, "GetFishByRarity", function(rarity, count)
        -- Force return high rarity fish
        local results = {}
        local targetRarity = rarity
        
        if self.Config.SecretChance > math.random() then
            targetRarity = "SECRET"
        elseif self.Config.LegendaryChance > math.random() then
            targetRarity = "Legendary"
        elseif self.Config.EpicChance > math.random() then
            targetRarity = "Epic"
        end
        
        for _, fish in pairs(EnhancedFishTable) do
            if fish.rarity == targetRarity then
                table.insert(results, fish)
                if #results >= (count or 1) then break end
            end
        end
        
        return results
    end)
end

-- ========================================================
-- MODULE 2: ECONOMY MANIPULATION
-- ========================================================

function FishingExploit:OverrideEconomySystem()
    -- Override price calculation
    MemoryCore:HookFunction(module_upvr, "CalculateFishPrice", function(weight, rarity)
        local basePrice = weight * module_upvr.SellingSettings.basePricePerKg
        local rarityMulti = module_upvr.SellingSettings.rarityMultiplier[rarity] or 1
        
        -- Apply size bonus manipulation
        local sizeBonus = 1
        if module_upvr.SellingSettings.enableSizeBonus then
            for sizeName, sizeData in pairs(module_upvr.SellingSettings.sizeBonus) do
                if weight >= sizeData.min and weight <= sizeData.max then
                    sizeBonus = sizeData.multiplier * 3 -- Triple size bonus
                    break
                end
            end
        end
        
        -- Final price with multipliers
        local finalPrice = basePrice * rarityMulti * sizeBonus * self.Config.PriceMultiplier
        
        -- Add random variation for stealth
        if self.Config.RandomizeWeights then
            finalPrice = finalPrice * (0.9 + math.random() * 0.2)
        end
        
        return math.floor(finalPrice + 0.5)
    end)
    
    -- Override weight generation
    MemoryCore:HookFunction(module_upvr, "GenerateFishWeight", function(fishData, luck, maxWeight)
        local minKg = fishData.minKg * self.Config.WeightMultiplier
        local maxKg = math.min(fishData.maxKg * self.Config.WeightMultiplier, maxWeight or 9999)
        
        -- Generate weight with bias toward max
        local weight = minKg + (maxKg - minKg) * (0.7 + math.random() * 0.3)
        
        if self.Config.RandomizeWeights then
            weight = weight * (0.8 + math.random() * 0.4)
        end
        
        return math.floor(weight * 10 + 0.5) / 10
    end)
end

-- ========================================================
-- MODULE 3: ROD SYSTEM OVERRIDE
-- ========================================================

function FishingExploit:OverrideRodSystem()
    MemoryCore:HookFunction(module_upvr, "GetRodConfig", function(rodName)
        local config = module_upvr.RodConfig[rodName] or module_upvr.RodConfig.default
        
        -- Enhance all rods to god-tier
        local enhancedConfig = {
            hookName = config.hookName,
            beamColor = Color3.fromRGB(255, 0, 255), -- Magenta for visibility
            beamWidth = 0.1,
            baseLuck = 100.0, -- Max luck
            maxWeight = 99999, -- Unlimited weight
            autoReel = true,
            instantCatch = true,
            noLineBreak = true
        }
        
        return enhancedConfig
    end)
    
    -- Override luck calculation
    MemoryCore:HookFunction(module_upvr, "CalculateTotalLuck", function(baseLuck, boost)
        return 999, self.Config.WeightMultiplier * 10
    end)
end

-- ========================================================
-- MODULE 4: MINIGAME BYPASS
-- ========================================================

function FishingExploit:BypassMinigame()
    -- Find minigame remotes
    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 5)
    
    if FishingSystem then
        for _, remote in pairs(FishingSystem:GetChildren()) do
            if remote:IsA("RemoteEvent") and remote.Name:find("Mini", 1, true) then
                MemoryCore:HookRemote(remote, function(args)
                    if self.Config.NoMinigame then
                        -- Auto-complete minigame
                        return {success = true, progress = 100, timeLeft = 999}
                    end
                    return true
                end)
            end
        end
    end
    
    -- Override minigame settings
    if module_upvr.MinigameSettings then
        module_upvr.MinigameSettings.progressMin = 100
        module_upvr.MinigameSettings.progressMax = 100
        module_upvr.MinigameSettings.decayMin = 0
        module_upvr.MinigameSettings.decayMax = 0
        module_upvr.MinigameSettings.startingProgress = 1.0
        module_upvr.MinigameSettings.fishingTime = 999
        module_upvr.MinigameSettings.autoCatchDuration = 0.1
    end
end

-- ========================================================
-- MODULE 5: INVENTORY & TRANSFER EXPLOIT
-- ========================================================

function FishingExploit:ExploitInventorySystem()
    -- Remove inventory limits
    if module_upvr.InventoryLimitSettings then
        module_upvr.InventoryLimitSettings.maxFishInventory = 999999
        module_upvr.InventoryLimitSettings.autoSellOldestFish = false
    end
    
    -- Enhance transfer settings
    if module_upvr.TransferSettings then
        module_upvr.TransferSettings.MaxDistance = 9999
        module_upvr.TransferSettings.RequiredLevel = 0
    end
    
    -- Hook leaderboard updates
    local function OverrideLeaderboard()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in pairs(leaderstats:GetChildren()) do
                if stat.Name == module_upvr.LeaderboardSettings.cashName then
                    -- Auto-increment cash
                    game:GetService("RunService").Heartbeat:Connect(function()
                        if stat.Value < 1000000 then
                            stat.Value = stat.Value + 1000
                        end
                    end)
                elseif stat.Name == module_upvr.LeaderboardSettings.fishCaughtName then
                    -- Auto-increment fish count
                    game:GetService("RunService").Heartbeat:Connect(function()
                        stat.Value = stat.Value + self.Config.FishMultiplier
                    end)
                end
            end
        end
    end
    
    -- Wait for leaderstats to exist
    if LocalPlayer:WaitForChild("leaderstats", 5) then
        OverrideLeaderboard()
    else
        LocalPlayer.CharacterAdded:Connect(function()
            wait(2)
            OverrideLeaderboard()
        end)
    end
end

-- ========================================================
-- MODULE 6: AUTO-FISHING BOT
-- ========================================================

function FishingExploit:CreateFishingBot()
    local botRunning = false
    
    local function FindFishingRemote()
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 5)
        if FishingSystem then
            for _, remote in pairs(FishingSystem:GetChildren()) do
                if remote:IsA("RemoteEvent") and (remote.Name:find("Fish", 1, true) or remote.Name:find("Catch", 1, true)) then
                    return remote
                end
            end
        end
        return nil
    end
    
    local function StartFishingCycle()
        if not botRunning then return end
        
        local remote = FindFishingRemote()
        if not remote then return end
        
        -- Start fishing
        remote:FireServer("StartFishing", {
            rod = "OWN LordPurple Demon Rod", -- Best rod
            location = LocalPlayer.Character.HumanoidRootPart.Position,
            boost = self.Config.WeightMultiplier
        })
        
        wait(0.5)
        
        -- Instant catch
        remote:FireServer("CatchFish", {
            fish = self:GenerateFishData(),
            instant = true,
            weightMultiplier = self.Config.WeightMultiplier
        })
        
        wait(self.Config.DelayBetweenActions)
        
        -- Auto-sell if enabled
        if self.Config.AutoSell then
            remote:FireServer("SellAllFish", {
                priceMultiplier = self.Config.PriceMultiplier
            })
        end
        
        -- Continue cycle
        if botRunning then
            task.spawn(StartFishingCycle)
        end
    end
    
    function FishingExploit:GenerateFishData()
        local rarities = {"SECRET", "Legendary", "Epic", "Rare"}
        local weights = {500, 300, 200, 100}
        
        local rarityIndex = 1
        if math.random() < 0.3 then rarityIndex = 1
        elseif math.random() < 0.6 then rarityIndex = 2
        elseif math.random() < 0.9 then rarityIndex = 3
        else rarityIndex = 4 end
        
        local rarity = rarities[rarityIndex]
        local weight = weights[rarityIndex] * self.Config.WeightMultiplier
        
        -- Select random fish of chosen rarity
        local availableFish = {}
        for _, fish in pairs(module_upvr.FishTable) do
            if fish.rarity == rarity then
                table.insert(availableFish, fish)
            end
        end
        
        local selectedFish = availableFish[math.random(1, #availableFish)] or {name = "Mega Monster"}
        
        return {
            Name = selectedFish.name,
            Weight = weight,
            Rarity = rarity,
            Price = module_upvr.CalculateFishPrice(weight, rarity),
            Timestamp = os.time()
        }
    end
    
    return {
        Start = function()
            botRunning = true
            StartFishingCycle()
        end,
        Stop = function()
            botRunning = false
        end,
        IsRunning = function()
            return botRunning
        end
    }
end

-- ========================================================
-- MODULE 7: TELEPORT & MOVEMENT HACKS
-- ========================================================

function FishingExploit:AddMovementHacks()
    -- Speed hack
    LocalPlayer.CharacterAdded:Connect(function(char)
        wait(1)
        local humanoid = char:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 100
        humanoid.JumpPower = 150
        
        RunService.Heartbeat:Connect(function()
            humanoid.WalkSpeed = 100
        end)
    end)
    
    -- Teleport fish to player
    if self.Config.TeleportFish then
        Workspace.DescendantAdded:Connect(function(obj)
            if obj.Name:find("Fish") or obj.Name:find("Hook") then
                wait(0.1)
                local char = LocalPlayer.Character
                if char and char.PrimaryPart then
                    obj:PivotTo(CFrame.new(char.PrimaryPart.Position + Vector3.new(0, 5, 0)))
                end
            end
        end)
    end
end

-- ========================================================
-- GUI CONTROL PANEL
-- ========================================================

function FishingExploit:CreateGUI()
    -- Load FluxUI
    local success, Flux = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/joeengo/Fluxware/main/source.lua"))()
    end)
    
    if not success then
        -- Fallback to simple GUI
        return self:CreateSimpleGUI()
    end
    
    local Window = Flux:Window("Fishing God v3.0", "Complete System Control", Color3.fromRGB(255, 0, 255))
    
    -- Main Tab
    local MainTab = Window:Tab("Main", "http://www.roblox.com/asset/?id=6031075938")
    MainTab:Section("Auto Features")
    
    MainTab:Toggle("Auto Fishing Bot", "Fully automated system", false, function(state)
        self.Config.AutoFish = state
        if state then
            self.Bot:Start()
        else
            self.Bot:Stop()
        end
    end)
    
    MainTab:Toggle("Auto Sell", "Auto-sell all fish", true, function(state)
        self.Config.AutoSell = state
    end)
    
    MainTab:Toggle("No Minigame", "Bypass fishing minigame", true, function(state)
        self.Config.NoMinigame = state
    end)
    
    MainTab:Toggle("Instant Catch", "No waiting for bite", true, function(state)
        self.Config.InstantCatch = state
    end)
    
    -- Economy Tab
    local EconomyTab = Window:Tab("Economy", "http://www.roblox.com/asset/?id=6031075923")
    EconomyTab:Section("Multipliers")
    
    EconomyTab:Slider("Weight Multiplier", "Fish weight", 1, 100, 10, function(value)
        self.Config.WeightMultiplier = value
    end)
    
    EconomyTab:Slider("Price Multiplier", "Sell price", 1, 100, 20, function(value)
        self.Config.PriceMultiplier = value
    end)
    
    EconomyTab:Slider("Fish Multiplier", "Fish caught per cycle", 1, 10, 3, function(value)
        self.Config.FishMultiplier = value
    end)
    
    EconomyTab:Section("Probability")
    
    EconomyTab:Slider("Secret Chance", "Chance for SECRET fish", 0, 100, 80, function(value)
        self.Config.SecretChance = value / 100
    end)
    
    EconomyTab:Slider("Legendary Chance", "Chance for Legendary", 0, 100, 90, function(value)
        self.Config.LegendaryChance = value / 100
    end)
    
    -- Player Tab
    local PlayerTab = Window:Tab("Player", "http://www.roblox.com/asset/?id=6031075907")
    PlayerTab:Section("Movement")
    
    PlayerTab:Slider("Walk Speed", "Movement speed", 16, 500, 100, function(value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end)
    
    PlayerTab:Slider("Jump Power", "Jump height", 50, 500, 150, function(value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end)
    
    PlayerTab:Toggle("Teleport Fish", "Fish come to you", true, function(state)
        self.Config.TeleportFish = state
    end)
    
    -- Settings Tab
    local SettingsTab = Window:Tab("Settings", "http://www.roblox.com/asset/?id=6031075880")
    SettingsTab:Section("Stealth")
    
    SettingsTab:Toggle("Safe Mode", "Reduced detection risk", false, function(state)
        self.Config.UseSafeMode = state
        if state then
            self.Config.WeightMultiplier = 2
            self.Config.PriceMultiplier = 3
        end
    end)
    
    SettingsTab:Toggle("Randomize Weights", "Add random variation", true, function(state)
        self.Config.RandomizeWeights = state
    end)
    
    SettingsTab:Slider("Action Delay", "Between actions (seconds)", 0, 3, 0.5, function(value)
        self.Config.DelayBetweenActions = value
    end)
    
    SettingsTab:Section("System")
    
    SettingsTab:Button("Inject All Modules", "Full system takeover", function()
        self:InjectAll()
        Flux:Notification("Injection Complete", "All systems operational")
    end)
    
    SettingsTab:Button("Restore Original", "Remove all hooks", function()
        self:RestoreOriginal()
        Flux:Notification("Restored", "All hooks removed")
    end)
    
    return Window
end

function FishingExploit:CreateSimpleGUI()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui
    screen.Name = "FishingGodGUI"
    
    -- Main frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 400)
    main.Position = UDim2.new(0, 10, 0, 10)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.Parent = screen
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "FISHING GOD v3.0"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Parent = main
    
    -- Create button function
    local function CreateButton(text, yPos, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Parent = main
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local yOffset = 40
    CreateButton("START BOT", yOffset, function()
        self.Config.AutoFish = true
        self.Bot:Start()
    end)
    
    yOffset = yOffset + 50
    CreateButton("STOP BOT", yOffset, function()
        self.Config.AutoFish = false
        self.Bot:Stop()
    end)
    
    yOffset = yOffset + 50
    CreateButton("INJECT ALL", yOffset, function()
        self:InjectAll()
    end)
    
    yOffset = yOffset + 50
    CreateButton("MAX ECONOMY", yOffset, function()
        self.Config.WeightMultiplier = 100
        self.Config.PriceMultiplier = 100
    end)
    
    yOffset = yOffset + 50
    CreateButton("SAFE MODE", yOffset, function()
        self.Config.UseSafeMode = true
        self.Config.WeightMultiplier = 2
        self.Config.PriceMultiplier = 3
    end)
    
    return screen
end

-- ========================================================
-- INITIALIZATION & INJECTION
-- ========================================================

function FishingExploit:InjectAll()
    -- Inject all modules
    self:OverrideProbabilitySystem()
    self:OverrideEconomySystem()
    self:OverrideRodSystem()
    self:BypassMinigame()
    self:ExploitInventorySystem()
    self:AddMovementHacks()
    
    -- Create bot instance
    self.Bot = self:CreateFishingBot()
    
    -- Create GUI
    self.GUI = self:CreateGUI()
    
    print("[FISHING GOD v3.0] Injection complete!")
    print("[STATUS] All systems operational")
    print("[CONFIG] Weight Multiplier:", self.Config.WeightMultiplier)
    print("[CONFIG] Price Multiplier:", self.Config.PriceMultiplier)
end

function FishingExploit:RestoreOriginal()
    -- Restore original functions
    for funcName, originalFunc in pairs(MemoryCore._originalFunctions) do
        module_upvr[funcName] = originalFunc
    end
    
    -- Restore remote hooks
    for remote, originalFire in pairs(MemoryCore._hookedRemotes) do
        remote.FireServer = originalFire
    end
    
    -- Restore original tables
    for tableName, originalTable in pairs(MemoryCore._patchedTables) do
        if module_upvr[tableName] then
            module_upvr[tableName] = originalTable
        end
    end
    
    print("[FISHING GOD v3.0] All hooks removed - System restored")
end

-- ========================================================
-- AUTO-EXECUTE
-- ========================================================

-- Wait for game to fully load
repeat task.wait() until game:IsLoaded() and LocalPlayer.Character

-- Verify module_upvr exists
if not module_upvr then
    warn("[ERROR] module_upvr not found! Attempting to locate...")
    
    -- Search for the module
    for _, obj in pairs(getnilinstances()) do
        if obj.Name == "module_upvr" or (obj:IsA("ModuleScript") and pcall(function()
            local mod = require(obj)
            if mod.RodConfig and mod.FishTable then
                module_upvr = mod
                return true
            end
        end)) then
            break
        end
    end
end

if module_upvr then
    -- Initialize and inject
    task.spawn(function()
        wait(2) -- Wait for game systems to load
        FishingExploit:InjectAll()
        
        -- Auto-start bot if configured
        if FishingExploit.Config.AutoFish then
            wait(3)
            FishingExploit.Bot:Start()
        end
    end)
    
    print("═══════════════════════════════════════")
    print("   FISHING GOD MODE v3.0 LOADED")
    print("   Target: module_upvr Fishing System")
    print("   Status: READY FOR INJECTION")
    print("═══════════════════════════════════════")
else
    warn("[CRITICAL] module_upvr not found! Exploit cannot proceed.")
end

return FishingExploit
