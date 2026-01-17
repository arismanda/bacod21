-- ZETA REALM - INSTANT FISHING REEL
-- Adjustable timing untuk instant catch!

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- === CONFIGURATION ===
local enabled = true
local TOGGLE_KEY = Enum.KeyCode.KeypadSix
local INSTANT_MODE = true -- Set false untuk manual timing

-- Timing settings (dalam detik)
local CATCH_DELAY = 0.1 -- Instant catch delay
local MIN_RANDOM_DELAY = 0.5
local MAX_RANDOM_DELAY = 2.0

-- UI untuk adjust timing
local showConfigUI = true

-- === STATE ===
local lastGuiVisible = false
local clickScheduled = false
local autoClickEnabled = true

-- === CONFIGURATION GUI ===
local function createConfigUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FishingConfig"
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 180)
    mainFrame.Position = UDim2.new(0, 10, 0, 100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 100, 100)
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "🎣 INSTANT FISHING CONFIG"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundColor3 = Color3.fromRGB(0, 50, 50)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.Parent = mainFrame
    
    -- Delay Setting
    local delayLabel = Instance.new("TextLabel")
    delayLabel.Size = UDim2.new(0.6, 0, 0, 25)
    delayLabel.Position = UDim2.new(0.05, 0, 0, 40)
    delayLabel.Text = "Catch Delay: " .. CATCH_DELAY .. "s"
    delayLabel.TextColor3 = Color3.new(1, 1, 1)
    delayLabel.BackgroundTransparency = 1
    delayLabel.Font = Enum.Font.SourceSans
    delayLabel.TextSize = 14
    delayLabel.TextXAlignment = Enum.TextXAlignment.Left
    delayLabel.Parent = mainFrame
    
    local delaySlider = Instance.new("TextBox")
    delaySlider.Size = UDim2.new(0.3, 0, 0, 25)
    delaySlider.Position = UDim2.new(0.65, 0, 0, 40)
    delaySlider.Text = tostring(CATCH_DELAY)
    delaySlider.PlaceholderText = "0.01-2.0"
    delaySlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    delaySlider.TextColor3 = Color3.new(1, 1, 1)
    delaySlider.Parent = mainFrame
    
    -- Mode Selection
    local instantBtn = Instance.new("TextButton")
    instantBtn.Size = UDim2.new(0.45, -5, 0, 30)
    instantBtn.Position = UDim2.new(0.05, 0, 0, 75)
    instantBtn.Text = INSTANT_MODE and "✅ INSTANT" or "INSTANT"
    instantBtn.TextColor3 = Color3.new(1, 1, 1)
    instantBtn.BackgroundColor3 = INSTANT_MODE and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(60, 60, 70)
    instantBtn.Font = Enum.Font.SourceSansBold
    instantBtn.TextSize = 12
    instantBtn.Parent = mainFrame
    
    local manualBtn = Instance.new("TextButton")
    manualBtn.Size = UDim2.new(0.45, -5, 0, 30)
    manualBtn.Position = UDim2.new(0.5, 5, 0, 75)
    manualBtn.Text = not INSTANT_MODE and "✅ MANUAL" or "MANUAL"
    manualBtn.TextColor3 = Color3.new(1, 1, 1)
    manualBtn.BackgroundColor3 = not INSTANT_MODE and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(60, 60, 70)
    manualBtn.Font = Enum.Font.SourceSansBold
    manualBtn.TextSize = 12
    manualBtn.Parent = mainFrame
    
    -- Min/Max Random Delay
    local minLabel = Instance.new("TextLabel")
    minLabel.Size = UDim2.new(0.6, 0, 0, 25)
    minLabel.Position = UDim2.new(0.05, 0, 0, 115)
    minLabel.Text = "Min Random: " .. MIN_RANDOM_DELAY .. "s"
    minLabel.TextColor3 = Color3.new(1, 1, 1)
    minLabel.BackgroundTransparency = 1
    minLabel.Font = Enum.Font.SourceSans
    minLabel.TextSize = 12
    minLabel.TextXAlignment = Enum.TextXAlignment.Left
    minLabel.Parent = mainFrame
    
    local minSlider = Instance.new("TextBox")
    minSlider.Size = UDim2.new(0.3, 0, 0, 25)
    minSlider.Position = UDim2.new(0.65, 0, 0, 115)
    minSlider.Text = tostring(MIN_RANDOM_DELAY)
    minSlider.PlaceholderText = "0.1-5.0"
    minSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    minSlider.TextColor3 = Color3.new(1, 1, 1)
    minSlider.Parent = mainFrame
    
    local maxLabel = Instance.new("TextLabel")
    maxLabel.Size = UDim2.new(0.6, 0, 0, 25)
    maxLabel.Position = UDim2.new(0.05, 0, 0, 145)
    maxLabel.Text = "Max Random: " .. MAX_RANDOM_DELAY .. "s"
    maxLabel.TextColor3 = Color3.new(1, 1, 1)
    maxLabel.BackgroundTransparency = 1
    maxLabel.Font = Enum.Font.SourceSans
    maxLabel.TextSize = 12
    maxLabel.TextXAlignment = Enum.TextXAlignment.Left
    maxLabel.Parent = mainFrame
    
    local maxSlider = Instance.new("TextBox")
    maxSlider.Size = UDim2.new(0.3, 0, 0, 25)
    maxSlider.Position = UDim2.new(0.65, 0, 0, 145)
    maxSlider.Text = tostring(MAX_RANDOM_DELAY)
    maxSlider.PlaceholderText = "0.5-10.0"
    maxSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    maxSlider.TextColor3 = Color3.new(1, 1, 1)
    maxSlider.Parent = mainFrame
    
    -- Event Handlers
    delaySlider.FocusLost:Connect(function()
        local num = tonumber(delaySlider.Text)
        if num and num >= 0.01 and num <= 2.0 then
            CATCH_DELAY = num
            delayLabel.Text = "Catch Delay: " .. CATCH_DELAY .. "s"
            print("[Config] Catch delay set to:", CATCH_DELAY)
        else
            delaySlider.Text = tostring(CATCH_DELAY)
        end
    end)
    
    instantBtn.MouseButton1Click:Connect(function()
        INSTANT_MODE = true
        instantBtn.Text = "✅ INSTANT"
        instantBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        manualBtn.Text = "MANUAL"
        manualBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        print("[Config] Mode: INSTANT")
    end)
    
    manualBtn.MouseButton1Click:Connect(function()
        INSTANT_MODE = false
        manualBtn.Text = "✅ MANUAL"
        manualBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        instantBtn.Text = "INSTANT"
        instantBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        print("[Config] Mode: MANUAL (random timing)")
    end)
    
    minSlider.FocusLost:Connect(function()
        local num = tonumber(minSlider.Text)
        if num and num >= 0.1 and num <= 5.0 then
            MIN_RANDOM_DELAY = num
            minLabel.Text = "Min Random: " .. MIN_RANDOM_DELAY .. "s"
            print("[Config] Min random delay:", MIN_RANDOM_DELAY)
        else
            minSlider.Text = tostring(MIN_RANDOM_DELAY)
        end
    end)
    
    maxSlider.FocusLost:Connect(function()
        local num = tonumber(maxSlider.Text)
        if num and num >= 0.5 and num <= 10.0 then
            MAX_RANDOM_DELAY = num
            maxLabel.Text = "Max Random: " .. MAX_RANDOM_DELAY .. "s"
            print("[Config] Max random delay:", MAX_RANDOM_DELAY)
        else
            maxSlider.Text = tostring(MAX_RANDOM_DELAY)
        end
    end)
    
    -- Hide/Show toggle
    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0, 30, 0, 30)
    hideBtn.Position = UDim2.new(1, -35, 0, 5)
    hideBtn.Text = "➖"
    hideBtn.TextColor3 = Color3.new(1, 1, 1)
    hideBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    hideBtn.Font = Enum.Font.SourceSansBold
    hideBtn.TextSize = 14
    
    hideBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        hideBtn.Text = mainFrame.Visible and "➖" or "➕"
    end)
    
    hideBtn.Parent = mainFrame
    
    screenGui.Parent = player:WaitForChild("PlayerGui")
    return screenGui
end

-- === FIND UI ===
local function findBars()
    local gui = player.PlayerGui:FindFirstChild("Reeling")
    if not gui then return end

    local frame = gui:FindFirstChild("Frame", true)
    if not frame then return end

    local white = frame:FindFirstChild("WhiteBar", true)
    local red = frame:FindFirstChild("RedBar", true)

    if white and red then
        return white, red, gui
    end
end

-- === INSTANT CATCH FUNCTION ===
local function instantCatch()
    -- Klik mouse untuk catch ikan
    VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- === MANUAL TIMING FUNCTION ===
local function manualCatch()
    -- Calculate random delay
    local delay = math.random() * (MAX_RANDOM_DELAY - MIN_RANDOM_DELAY) + MIN_RANDOM_DELAY
    
    print("[Manual] Waiting", string.format("%.2f", delay), "seconds...")
    task.wait(delay)
    
    -- Click to catch
    instantCatch()
end

-- === TOGGLE HANDLER ===
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then
        enabled = not enabled
        print("[Reeling Script]", enabled and "ON" or "OFF")

        -- reset state saat OFF
        if not enabled then
            lastGuiVisible = false
            clickScheduled = false
        end
    end
    
    -- Manual catch dengan F key
    if input.KeyCode == Enum.KeyCode.F and enabled then
        print("[Manual] Manual catch triggered!")
        instantCatch()
    end
end)

-- === MAIN LOOP ===
RunService.RenderStepped:Connect(function()
    if not enabled then return end

    local WhiteBar, RedBar, gui = findBars()

    -- GUI muncul (sedang fishing)
    if WhiteBar and RedBar and gui then
        if not lastGuiVisible then
            print("[Fishing] Fish hooked! Waiting for catch...")
        end
        
        lastGuiVisible = true
        clickScheduled = false

        -- INSTANT MODE: Auto catch segera
        if INSTANT_MODE and autoClickEnabled then
            -- Snap whitebar ke redbar untuk visual
            local parent = WhiteBar.Parent
            local relativeX = RedBar.AbsolutePosition.X - parent.AbsolutePosition.X
            WhiteBar.Position = UDim2.fromOffset(relativeX, WhiteBar.Position.Y.Offset)
            
            -- Tunggu delay kemudian catch
            task.delay(CATCH_DELAY, function()
                if enabled and lastGuiVisible then
                    print("[Instant] Catching fish with delay:", CATCH_DELAY)
                    instantCatch()
                end
            end)
            
            return
        end
        
        -- MANUAL MODE: Tunggu random delay
        if not INSTANT_MODE and not clickScheduled then
            clickScheduled = true
            
            task.delay(math.random() * (MAX_RANDOM_DELAY - MIN_RANDOM_DELAY) + MIN_RANDOM_DELAY, function()
                if enabled and lastGuiVisible then
                    print("[Manual] Random delay catch!")
                    instantCatch()
                end
            end)
        end
        
        return
    end

    -- GUI baru saja hilang (ikan sudah ditangkap/dilepas)
    if lastGuiVisible and not clickScheduled then
        lastGuiVisible = false
        print("[Fishing] Reeling completed or fish escaped")
    end
end)

-- === AUTO-FISHING MODE ===
local autoFishing = false
local autoFishThread = nil

local function startAutoFishing()
    if autoFishing then return end
    
    autoFishing = true
    print("[Auto-Fish] Started auto fishing mode!")
    
    autoFishThread = task.spawn(function()
        while autoFishing do
            -- Cast fishing rod (tekan E atau tombol fishing)
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            
            -- Tunggu ikan strike
            task.wait(math.random(2, 8))
            
            -- Script akan auto catch kalau ada fish hook
        end
    end)
end

local function stopAutoFishing()
    autoFishing = false
    if autoFishThread then
        task.cancel(autoFishThread)
        autoFishThread = nil
    end
    print("[Auto-Fish] Stopped")
end

-- === KEYBINDS ===
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- Toggle auto fishing dengan G
    if input.KeyCode == Enum.KeyCode.G then
        if autoFishing then
            stopAutoFishing()
        else
            startAutoFishing()
        end
    end
    
    -- Force instant catch dengan F
    if input.KeyCode == Enum.KeyCode.F then
        print("[Force] Manual catch!")
        instantCatch()
    end
end)

-- === STARTUP ===
print("\n" .. string.rep("=", 50))
print("🔥 ZETA REALM - INSTANT FISHING REEL")
print(string.rep("=", 50))
print("[Keybinds]")
print("  Keypad6: Toggle script")
print("  F: Force instant catch")
print("  G: Toggle auto-fishing mode")
print("[Config]")
print("  Instant Mode:", INSTANT_MODE)
print("  Catch Delay:", CATCH_DELAY, "seconds")
print("  Random Delay:", MIN_RANDOM_DELAY, "-", MAX_RANDOM_DELAY, "seconds")
print(string.rep("=", 50))

-- Create config UI
if showConfigUI then
    createConfigUI()
end

-- Auto start script
enabled = true
print("[Status] Script ENABLED - Waiting for fish...")