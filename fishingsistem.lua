-- ============================================
-- FISHING SYSTEM EXPLOIT v2.0 - Hyper-Optimized
-- Compatible dengan: module_upvr
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- MEMORY HIJACK ENGINE
-- ============================================

local function SecureHook(remote, callback)
    local connection
    local originalFire = remote.FireServer
    
    remote.FireServer = function(self, ...)
        local args = {...}
        local success, result = pcall(callback, args)
        if success and result ~= false then
            return originalFire(self, ...)
        end
        return nil
    end
    
    connection = remote:GetPropertyChangedSignal("FireServer"):Connect(function()
        if remote.FireServer ~= originalFire then
            originalFire = remote.FireServer
        end
    end)
    
    return function()
        if connection then connection:Disconnect() end
        remote.FireServer = originalFire
    end
end

-- ============================================
-- CORE FISHING EXPLOITS
-- ============================================

local FishingExploits = {
    _hooks = {},
    _active = false,
    _config = {
        AutoFishing = true,
        InstantCatch = true,
        MaxLuck = true,
        NoInventoryLimit = true,
        AutoSell = true,
        WeightMultiplier = 5.0,
        PriceMultiplier = 10.0,
        SecretFishChance = 0.3,
        SilentMode = false
    }
}

-- AUTO-FISHING SYSTEM
function FishingExploits:EnableAutoFishing()
    if self._hooks["FishingRemote"] then return end
    
    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 10)
    if not FishingSystem then
        warn("[EXPLOIT] FishingSystem tidak ditemukan!")
        return
    end
    
    -- Cari semua remote yang relevan
    local remotes = {}
    for _, child in pairs(FishingSystem:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            remotes[child.Name] = child
        end
    end
    
    -- Hook StartFishing
    if remotes["StartFishing"] then
        self._hooks["FishingRemote"] = SecureHook(remotes["StartFishing"], function(args)
            if self._config.AutoFishing then
                -- Override luck calculation
                if self._config.MaxLuck then
                    args[2] = 999 -- Max luck
                    args[3] = module_upvr.CurrentServerBoost * 100
                end
                
                -- Auto trigger catch setelah delay
                if self._config.InstantCatch then
                    task.spawn(function()
                        wait(0.5) -- Delay untuk natural feel
                        if remotes["CatchFish"] then
                            local randomFish = module_upvr.FishTable[math.random(1, #module_upvr.FishTable)]
                            
                            -- Manipulasi fish weight
                            local weight = module_upvr.GenerateFishWeight(randomFish, nil, 
                                randomFish.maxKg * self._config.WeightMultiplier)
                            
                            -- Prioritize SECRET fish
                            if math.random() < self._config.SecretFishChance then
                                local secretFishes = {}
                                for _, fish in pairs(module_upvr.FishTable) do
                                    if fish.rarity == "SECRET" then
                                        table.insert(secretFishes, fish)
                                    end
                                end
                                if #secretFishes > 0 then
                                    randomFish = secretFishes[math.random(1, #secretFishes)]
                                    weight = randomFish.minKg * self._config.WeightMultiplier
                                end
                            end
                            
                            remotes["CatchFish"]:FireServer({
                                Name = randomFish.name,
                                Weight = weight,
                                Rarity = randomFish.rarity,
                                Price = module_upvr.CalculateFishPrice(weight, randomFish.rarity) * self._config.PriceMultiplier
                            })
                        end
                    end)
                end
            end
            return true
        end)
    end
    
    -- Hook SellFish untuk auto-sell dengan harga tinggi
    if remotes["SellFish"] then
        self._hooks["SellRemote"] = SecureHook(remotes["SellFish"], function(args)
            if self._config.AutoSell then
                local fishData = args[1]
                if fishData and type(fishData) == "table" then
                    fishData.Price = fishData.Price * self._config.PriceMultiplier
                    fishData.Weight = fishData.Weight * self._config.WeightMultiplier
                end
            end
            return true
        end)
    end
end

-- INVENTORY LIMIT BYPASS
function FishingExploits:BypassInventoryLimit()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    
    setreadonly(mt, false)
    
    mt.__index = newcclosure(function(t, k)
        if tostring(t) == "InventoryService" and k == "CheckLimit" then
            return function() return true end -- Selalu return inventory tidak penuh
        end
        if tostring(t):find("Inventory") and k == "IsFull" then
            return false
        end
        return oldIndex(t, k)
    end)
    
    setreadonly(mt, true)
end

-- ROD STATS OVERRIDE
function FishingExploits:OverrideRodStats()
    local originalGetRodConfig = module_upvr.GetRodConfig
    
    module_upvr.GetRodConfig = function(rodName)
        local config = originalGetRodConfig(rodName)
        
        -- Boost semua rod ke level maksimal
        if config then
            config.baseLuck = config.baseLuck * 50
            config.maxWeight = 999999
            config.beamColor = Color3.fromRGB(255, 0, 255) -- Pink untuk indikasi aktif
            config.beamWidth = 0.1
        end
        
        return config
    end
end

-- ANTI-AFK SYSTEM
function FishingExploits:EnableAntiAFK()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local lastInput = tick()
    
    RunService.Heartbeat:Connect(function()
        if tick() - lastInput > 20 then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            lastInput = tick()
        end
    end)
end

-- TELEPORT FISH TO PLAYER
function FishingExploits:TeleportFish()
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant.Name:find("Fish") or descendant.Name:find("Hook") then
            task.wait(module_upvr.ProjectileSettings.detectionDelay or 0.3)
            
            -- Teleport langsung ke player
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local targetPos = char.HumanoidRootPart.Position + Vector3.new(0, 3, 0)
                
                if descendant:IsA("BasePart") then
                    descendant.CFrame = CFrame.new(targetPos)
                    descendant.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
end

-- GUI CONTROL PANEL
function FishingExploits:CreateControlPanel()
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Library.CreateLib("Fishing God Mode", "DarkTheme")
    
    -- Main Tab
    local MainTab = Window:NewTab("Main")
    local MainSection = MainTab:NewSection("Exploits Configuration")
    
    MainSection:NewToggle("Auto Fishing", "Automatically catch fish", function(state)
        self._config.AutoFishing = state
    end)
    
    MainSection:NewToggle("Instant Catch", "No minigame required", function(state)
        self._config.InstantCatch = state
    end)
    
    MainSection:NewToggle("Max Luck", "Always get best fish", function(state)
        self._config.MaxLuck = state
    end)
    
    MainSection:NewSlider("Weight Multiplier", "Fish weight multiplier", 100, 1, function(value)
        self._config.WeightMultiplier = value / 10
    end)
    
    MainSection:NewSlider("Price Multiplier", "Sell price multiplier", 100, 1, function(value)
        self._config.PriceMultiplier = value / 10
    end)
    
    MainSection:NewSlider("Secret Chance", "Chance for SECRET fish", 100, 0, function(value)
        self._config.SecretFishChance = value / 100
    end)
    
    -- Visuals Tab
    local VisualsTab = Window:NewTab("Visuals")
    local VisualsSection = VisualsTab:NewSection("ESP & Highlights")
    
    VisualsSection:NewToggle("Fish ESP", "Highlight all fish", function(state)
        if state then
            for _, fish in pairs(workspace:GetDescendants()) do
                if fish.Name:find("Fish") and fish:IsA("BasePart") then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = module_upvr.GetRarityColor("SECRET")
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.Parent = fish
                end
            end
        end
    end)
    
    -- Player Tab
    local PlayerTab = Window:NewTab("Player")
    local PlayerSection = PlayerTab:NewSection("Character Mods")
    
    PlayerSection:NewSlider("WalkSpeed", "Movement speed", 500, 16, function(value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end)
    
    PlayerSection:NewSlider("JumpPower", "Jump height", 500, 50, function(value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end)
    
    -- Init Button
    local InitSection = MainTab:NewSection("Activation")
    InitSection:NewButton("INITIATE EXPLOIT", "Start all systems", function()
        self:EnableAutoFishing()
        self:BypassInventoryLimit()
        self:OverrideRodStats()
        self:EnableAntiAFK()
        self:TeleportFish()
        
        Library:Notification("Exploit Activated", "All systems are now running!")
    end)
    
    InitSection:NewButton("SAFE MODE", "Reduce detection risk", function()
        self._config.SilentMode = true
        self._config.WeightMultiplier = 1.5
        self._config.PriceMultiplier = 2.0
        Library:Notification("Safe Mode", "Reduced multipliers for stealth")
    end)
end

-- EXECUTION INITIALIZATION
function FishingExploits:Init()
    -- Wait for game to load
    repeat task.wait() until game:IsLoaded()
    
    -- Check if module_upvr exists
    if not module_upvr then
        warn("[ERROR] module_upvr not found! Trying to locate...")
        -- Attempt to find the module in various locations
        for _, service in pairs({workspace, ReplicatedStorage, game}) do
            for _, obj in pairs(service:GetDescendants()) do
                if obj.Name == "module_upvr" or (obj:IsA("ModuleScript") and require(obj) == module_upvr) then
                    module_upvr = require(obj)
                    break
                end
            end
        end
    end
    
    if module_upvr then
        -- Create GUI
        self:CreateControlPanel()
        
        -- Auto-execute safe features
        self:BypassInventoryLimit()
        self:EnableAntiAFK()
        
        print("[EXPLOIT] Fishing God Mode v2.0 Loaded Successfully!")
        print("[INFO] Use GUI to configure features")
    else
        warn("[CRITICAL] Could not locate fishing module!")
    end
end

return FishingExploits
