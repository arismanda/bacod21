-- Fishing Simulator Stealth Exploit v5.0
-- Advanced anti-detection with behavioral mimicry
-- Zero-trace execution system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- === STEALTH CONFIGURATION ===
local Stealth = {
    -- Execution Methods
    ExecutionMode = "DynamicHook",  -- "DirectCall", "EventProxy", "DynamicHook"
    HookMethod = "Metatable",       -- "Metatable", "Environment", "DebugHook"
    
    -- Behavioral Mimicry
    HumanDelay = {
        Min = 0.8,      -- Minimum delay between actions
        Max = 2.5,      -- Maximum delay
        Variance = 0.3, -- Randomness factor
    },
    
    -- Pattern Avoidance
    AntiPattern = {
        Enabled = true,
        PatternBreakInterval = 30,  -- Break patterns every N actions
        RandomActionInjection = true, -- Inject random legitimate actions
    },
    
    -- Memory Safety
    MemoryCleanup = {
        AutoClean = true,
        CleanInterval = 60, -- Clean traces every 60 seconds
        RemoveStrings = true,
    },
    
    -- Detection Evasion
    Evasion = {
        FakeFPS = true,          -- Mimic normal FPS
        HideScriptInstances = true,
        RandomIdentifierNames = true,
        ObfuscateCalls = true,
    },
    
    -- Network Stealth
    Network = {
        ThrottleCalls = true,
        MaxCallsPerSecond = 3,
        AddJitter = true,
    }
}

-- === OBFUSCATED VARIABLE NAMES ===
local _ = {
    _1 = Players,
    _2 = ReplicatedStorage,
    _3 = LocalPlayer or Players.LocalPlayer,
    _4 = "FishingSystem",
    _5 = {},
    _6 = {},
    _7 = math.random,
    _8 = task.wait,
    _9 = task.spawn,
    _10 = pcall,
    _11 = {}
}

-- === RANDOM IDENTIFIER GENERATOR ===
local function GenerateRandomIdentifier()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local id = ""
    for i = 1, 12 do
        id = id .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return id
end

-- Assign random names to functions
local __a = GenerateRandomIdentifier()
local __b = GenerateRandomIdentifier()
local __c = GenerateRandomIdentifier()
local __d = GenerateRandomIdentifier()

-- === ADVANCED HOOKING SYSTEM (UNDETECTABLE) ===
local function StealthHook(targetTable, functionName, replacement)
    if not targetTable or not targetTable[functionName] then return false end
    
    -- Method 1: Metatable hook (hardest to detect)
    local original = targetTable[functionName]
    local meta = getrawmetatable(targetTable) or {}
    
    if Stealth.HookMethod == "Metatable" then
        -- Create a closure that preserves original
        local closure = function(...)
            if Stealth.Evasion.RandomIdentifierNames then
                -- Random sleep to mimic human reaction
                if math.random(1, 100) > 70 then
                    task.wait(math.random(10, 30) / 1000)
                end
            end
            return original(...)
        end
        
        -- Replace via metatable
        local success, err = pcall(function()
            local oldMeta = getrawmetatable(targetTable)
            if oldMeta then
                setreadonly(oldMeta, false)
                oldMeta.__index = function(self, key)
                    if key == functionName then
                        return closure
                    end
                    return oldMeta[key]
                end
                setreadonly(oldMeta, true)
            end
        end)
        
        if success then
            _._11[functionName] = original
            return true
        end
    end
    
    -- Method 2: Environment hook
    if not success then
        local env = getfenv(original)
        if env then
            local newEnv = setmetatable({}, {
                __index = function(self, key)
                    if key == functionName then
                        return function(...)
                            local result = replacement(...)
                            return result
                        end
                    end
                    return env[key]
                end
            })
            setfenv(original, newEnv)
            return true
        end
    end
    
    return false
end

-- === BEHAVIORAL MIMICRY SYSTEM ===
local ActionHistory = {}
local LastActionTime = 0
local PatternCounter = 0

local function HumanizedDelay()
    -- Calculate delay with variance
    local baseDelay = math.random(Stealth.HumanDelay.Min * 100, Stealth.HumanDelay.Max * 100) / 100
    local variance = (math.random() * 2 - 1) * Stealth.HumanDelay.Variance
    local delay = math.max(0.1, baseDelay + variance)
    
    -- Store action pattern
    table.insert(ActionHistory, {
        Time = tick(),
        Delay = delay,
        Type = "Fishing"
    })
    
    -- Keep only last 50 actions
    if #ActionHistory > 50 then
        table.remove(ActionHistory, 1)
    end
    
    -- Break patterns periodically
    PatternCounter = PatternCounter + 1
    if PatternCounter >= Stealth.AntiPattern.PatternBreakInterval then
        PatternCounter = 0
        -- Inject random longer delay
        if Stealth.AntiPattern.RandomActionInjection then
            local extraDelay = math.random(200, 500) / 100
            task.wait(extraDelay)
        end
    end
    
    LastActionTime = tick()
    return delay
end

-- === NETWORK THROTTLING ===
local NetworkMonitor = {
    CallHistory = {},
    CallCount = 0,
    LastReset = tick()
}

local function ThrottledCall(remote, ...)
    local currentTime = tick()
    
    -- Reset counter every second
    if currentTime - NetworkMonitor.LastReset >= 1 then
        NetworkMonitor.CallCount = 0
        NetworkMonitor.LastReset = currentTime
    end
    
    -- Check rate limit
    if Stealth.Network.ThrottleCalls and NetworkMonitor.CallCount >= Stealth.Network.MaxCallsPerSecond then
        task.wait(1 - (currentTime - NetworkMonitor.LastReset) + math.random(10, 50) / 1000)
    end
    
    -- Add network jitter
    if Stealth.Network.AddJitter then
        task.wait(math.random(1, 30) / 1000)
    end
    
    -- Execute call
    local success, result = pcall(function()
        if remote:IsA("RemoteEvent") then
            return remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            return remote:InvokeServer(...)
        end
    end)
    
    NetworkMonitor.CallCount = NetworkMonitor.CallCount + 1
    return success, result
end

-- === MEMORY CLEANUP SYSTEM ===
local function CleanMemoryTraces()
    if not Stealth.MemoryCleanup.AutoClean then return end
    
    -- Clear strings and tables
    collectgarbage("collect")
    
    -- Randomize memory usage patterns
    if Stealth.MemoryCleanup.RemoveStrings then
        local temp = {}
        for i = 1, math.random(10, 50) do
            temp[i] = string.rep("X", math.random(100, 1000))
        end
        temp = nil
        collectgarbage("collect")
    end
end

-- === FAKE PERFORMANCE METRICS ===
local function MimicNormalPerformance()
    if Stealth.Evasion.FakeFPS then
        -- Create fake performance overhead
        local start = tick()
        for i = 1, math.random(1000, 5000) do
            local _ = math.sqrt(i) * math.random()
        end
        local overhead = tick() - start
        
        -- Adjust to mimic 30-60 FPS
        if overhead < 0.016 then
            task.wait(0.016 - overhead + math.random(1, 5) / 1000)
        end
    end
end

-- === STEALTH MODULE INJECTION ===
local function InjectStealthModule()
    -- Find fishing module with multiple detection methods
    local targetModule
    local detectionMethods = {
        "FishingSystem",
        "FishingModule",
        "FishSystem",
        "Module_Fishing",
        "MainModule"
    }
    
    for _, name in pairs(detectionMethods) do
        targetModule = ReplicatedStorage:FindFirstChild(name)
        if targetModule and targetModule:IsA("ModuleScript") then
            break
        end
    end
    
    if not targetModule then
        -- Search in all descendants
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("ModuleScript") and (obj.Name:lower():find("fish") or obj.Name:lower():find("fish")) then
                targetModule = obj
                break
            end
        end
    end
    
    if targetModule then
        local success, moduleTable = pcall(require, targetModule)
        if success and type(moduleTable) == "table" then
            -- Stealth hook for GenerateFishWeight
            if moduleTable.GenerateFishWeight then
                local originalWeight = moduleTable.GenerateFishWeight
                moduleTable.GenerateFishWeight = function(fishData, rodLuck, maxWeight)
                    MimicNormalPerformance()
                    
                    -- Calculate with human variance
                    local humanVariance = math.random(95, 105) / 100
                    local result = originalWeight(fishData, rodLuck, maxWeight)
                    
                    -- Apply slight random adjustment
                    result = result * humanVariance
                    result = math.floor(result * 10 + 0.5) / 10
                    
                    return result
                end
                
                -- Store for cleanup
                _._5.OriginalWeight = originalWeight
            end
            
            -- Hook for fishing logic
            if moduleTable.RollFish or moduleTable.GetFishByRarity then
                -- Inject probability manipulation
                local originalRoll = moduleTable.RollFish or moduleTable.GetFishByRarity
                if originalRoll then
                    local hookedFunction = function(...)
                        HumanizedDelay()
                        
                        -- Add random success/failure
                        if math.random(1, 100) > 95 then
                            -- Simulate occasional failure
                            return nil
                        end
                        
                        return originalRoll(...)
                    end
                    
                    if moduleTable.RollFish then
                        moduleTable.RollFish = hookedFunction
                    else
                        moduleTable.GetFishByRarity = hookedFunction
                    end
                end
            end
        end
    end
end

-- === RANDOMIZED AUTO-FISHING ===
local function StealthAutoFish()
    local fishingRemotes = {}
    local remoteNames = {
        "CastLine", "StartFishing", "FishCast", 
        "CatchFish", "ReelIn", "CompleteFishing"
    }
    
    -- Find remotes with random delay between searches
    for _, name in pairs(remoteNames) do
        task.wait(math.random(10, 50) / 1000)
        local remote = FishingSystem:FindFirstChild(name)
        if remote then
            fishingRemotes[name] = remote
        end
    end
    
    -- Main fishing loop with stealth
    while Stealth.Enabled do
        -- Random start delay
        task.wait(math.random(500, 1500) / 1000)
        
        -- Cast line
        if fishingRemotes["CastLine"] or fishingRemotes["StartFishing"] then
            local remote = fishingRemotes["CastLine"] or fishingRemotes["StartFishing"]
            ThrottledCall(remote)
            
            -- Variable wait time
            local biteWait = math.random(800, 2500) / 1000
            task.wait(biteWait)
            
            -- Catch with random success
            if fishingRemotes["CatchFish"] or fishingRemotes["ReelIn"] then
                local catchRemote = fishingRemotes["CatchFish"] or fishingRemotes["ReelIn"]
                
                -- Simulate occasional miss
                if math.random(1, 100) > 85 then
                    task.wait(math.random(300, 800) / 1000)
                    -- "Miss" the fish
                    if math.random(1, 100) > 50 then
                        -- Try again
                        ThrottledCall(catchRemote)
                    end
                else
                    ThrottledCall(catchRemote)
                end
            end
        end
        
        -- Clean memory periodically
        if math.random(1, 100) > 70 then
            CleanMemoryTraces()
        end
        
        -- Humanized break
        local breakTime = HumanizedDelay()
        task.wait(breakTime)
    end
end

-- === STEALTH GUI (HIDDEN) ===
local function CreateStealthGUI()
    -- Use minimal GUI with random positioning
    local gui = Instance.new("ScreenGui")
    gui.Name = GenerateRandomIdentifier()
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main frame with random color
    local frame = Instance.new("Frame")
    frame.Name = GenerateRandomIdentifier()
    frame.BackgroundColor3 = Color3.fromRGB(
        math.random(20, 40),
        math.random(20, 40),
        math.random(20, 40)
    )
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(
        math.random(0, 70) / 100,
        math.random(0, 100),
        math.random(0, 70) / 100,
        math.random(0, 100)
    )
    frame.Parent = gui
    
    -- Transparent toggle button
    local toggle = Instance.new("TextButton")
    toggle.Name = GenerateRandomIdentifier()
    toggle.Text = "|||"
    toggle.TextColor3 = Color3.fromRGB(150, 150, 150)
    toggle.TextSize = 12
    toggle.BackgroundTransparency = 0.8
    toggle.Size = UDim2.new(0, 30, 0, 30)
    toggle.Position = UDim2.new(1, -35, 0, 5)
    toggle.Parent = frame
    
    -- Hidden controls (visible on hover)
    local controls = Instance.new("Frame")
    controls.Name = GenerateRandomIdentifier()
    controls.BackgroundTransparency = 0.9
    controls.Size = UDim2.new(1, 0, 1, -40)
    controls.Position = UDim2.new(0, 0, 0, 40)
    controls.Visible = false
    controls.Parent = frame
    
    -- Show/hide toggle
    local isVisible = false
    toggle.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        controls.Visible = isVisible
        toggle.Text = isVisible and "X" or "|||"
    end)
    
    -- Add to CoreGui with random parent
    if math.random(1, 2) == 1 then
        gui.Parent = game:GetService("CoreGui")
    else
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    return gui
end

-- === EXECUTION WITH ANTI-DETECTION ===
local function InitializeStealth()
    -- Wait for game to fully load
    task.wait(math.random(2, 5))
    
    -- Randomize execution timing
    local startDelay = math.random(1000, 3000) / 1000
    task.wait(startDelay)
    
    -- Inject stealth module
    InjectStealthModule()
    
    -- Start cleanup scheduler
    if Stealth.MemoryCleanup.AutoClean then
        task.spawn(function()
            while task.wait(Stealth.MemoryCleanup.CleanInterval) do
                CleanMemoryTraces()
            end
        end)
    end
    
    -- Create stealth GUI
    local gui = CreateStealthGUI()
    
    -- Start fishing with random delay
    task.wait(math.random(1, 3))
    Stealth.Enabled = true
    StealthAutoFish()
    
    -- Final cleanup on exit
    game:BindToClose(function()
        Stealth.Enabled = false
        if gui then
            gui:Destroy()
        end
        CleanMemoryTraces()
        collectgarbage("collect")
    end)
end

-- === RANDOMIZED STARTUP ===
-- Random delay before starting
local startupDelay = math.random(3000, 8000) / 1000
task.wait(startupDelay)

-- Start in random order
local startupMethods = {
    function() InitializeStealth() end,
    function() task.wait(0.5); InitializeStealth() end,
    function() task.wait(1.0); InitializeStealth() end
}

-- Choose random startup method
startupMethods[math.random(1, #startupMethods)]()

-- === CLEAN EXIT HANDLER ===
local Connection
Connection = game:GetService("UserInputService").WindowFocused:Connect(function(focused)
    if not focused then
        -- Reduce activity when window not focused
        Stealth.HumanDelay.Min = Stealth.HumanDelay.Min * 2
        Stealth.HumanDelay.Max = Stealth.HumanDelay.Max * 2
    else
        -- Restore normal timing
        Stealth.HumanDelay.Min = 0.8
        Stealth.HumanDelay.Max = 2.5
    end
end)

-- Auto-disconnect after time
task.delay(300, function()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end)
