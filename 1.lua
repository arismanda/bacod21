-- MOBILE FISH SPAMMER ZETA v2.0
-- Ultra optimized for mobile, with hide/show toggle

print("📱 ZETA MOBILE FISH SPAMMER LOADING...")

-- Deteksi mobile
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Wait for everything
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
while not player do task.wait(0.5); player = Players.LocalPlayer end

-- Mobile optimized GUI
local function createMobileGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZetaMobileSpammer"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    -- Main Container (compact for mobile)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 220) -- Compact size
    mainFrame.Position = UDim2.new(0, 10, 0, 10) -- Top-left corner
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(100, 0, 0)
    mainFrame.Visible = true -- Start visible
    mainFrame.Parent = screenGui
    
    -- Mini Toggle Button (when hidden)
    local miniToggle = Instance.new("TextButton")
    miniToggle.Size = UDim2.new(0, 50, 0, 50)
    miniToggle.Position = UDim2.new(0, 10, 0, 10)
    miniToggle.Text = "🎣"
    miniToggle.TextColor3 = Color3.new(1, 1, 1)
    miniToggle.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    miniToggle.Font = Enum.Font.SourceSansBold
    miniToggle.TextSize = 24
    miniToggle.Visible = false -- Start hidden
    miniToggle.Parent = screenGui
    
    -- Title Bar (drag + hide button)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    titleBar.Parent = mainFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Text = "🎣 ZETA MOBILE"
    titleText.TextColor3 = Color3.new(1, 1, 1)
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 14
    titleText.Parent = titleBar
    
    -- Hide/Show Button
    local hideButton = Instance.new("TextButton")
    hideButton.Size = UDim2.new(0, 30, 1, 0)
    hideButton.Position = UDim2.new(1, -30, 0, 0)
    hideButton.Text = "➖"
    hideButton.TextColor3 = Color3.new(1, 1, 1)
    hideButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    hideButton.Font = Enum.Font.SourceSansBold
    hideButton.TextSize = 16
    hideButton.Parent = titleBar
    
    -- Status Display
    local statusBox = Instance.new("Frame")
    statusBox.Size = UDim2.new(1, -20, 0, 30)
    statusBox.Position = UDim2.new(0, 10, 0, 35)
    statusBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    statusBox.BorderSizePixel = 1
    statusBox.Parent = mainFrame
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.Text = "READY"
    statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.SourceSansBold
    statusText.TextSize = 14
    statusText.Parent = statusBox
    
    -- Fish ID (simplified)
    local fishIdLabel = Instance.new("TextLabel")
    fishIdLabel.Size = UDim2.new(1, -20, 0, 20)
    fishIdLabel.Position = UDim2.new(0, 10, 0, 70)
    fishIdLabel.Text = "Fish ID:"
    fishIdLabel.TextColor3 = Color3.new(1, 1, 1)
    fishIdLabel.BackgroundTransparency = 1
    fishIdLabel.Font = Enum.Font.SourceSans
    fishIdLabel.TextSize = 12
    fishIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    fishIdLabel.Parent = mainFrame
    
    local fishIdBox = Instance.new("TextBox")
    fishIdBox.Size = UDim2.new(1, -20, 0, 25)
    fishIdBox.Position = UDim2.new(0, 10, 0, 90)
    fishIdBox.Text = "safsafwaetqw3fsa"
    fishIdBox.TextColor3 = Color3.new(1, 1, 1)
    fishIdBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    fishIdBox.BorderSizePixel = 1
    fishIdBox.Font = Enum.Font.SourceSans
    fishIdBox.TextSize = 12
    fishIdBox.ClearTextOnFocus = false
    fishIdBox.Parent = mainFrame
    
    -- Delay Control (compact)
    local delayFrame = Instance.new("Frame")
    delayFrame.Size = UDim2.new(1, -20, 0, 25)
    delayFrame.Position = UDim2.new(0, 10, 0, 120)
    delayFrame.BackgroundTransparency = 1
    delayFrame.Parent = mainFrame
    
    local delayLabel = Instance.new("TextLabel")
    delayLabel.Size = UDim2.new(0.5, -5, 1, 0)
    delayLabel.Text = "Delay: 0.5s"
    delayLabel.TextColor3 = Color3.new(1, 1, 1)
    delayLabel.BackgroundTransparency = 1
    delayLabel.Font = Enum.Font.SourceSans
    delayLabel.TextSize = 12
    delayLabel.TextXAlignment = Enum.TextXAlignment.Left
    delayLabel.Parent = delayFrame
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0.2, 0, 1, 0)
    plusBtn.Position = UDim2.new(0.5, 5, 0, 0)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(0, 1, 0)
    plusBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
    plusBtn.Font = Enum.Font.SourceSansBold
    plusBtn.TextSize = 14
    plusBtn.Parent = delayFrame
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0.2, 0, 1, 0)
    minusBtn.Position = UDim2.new(0.7, 5, 0, 0)
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.new(1, 0, 0)
    minusBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
    minusBtn.Font = Enum.Font.SourceSansBold
    minusBtn.TextSize = 14
    minusBtn.Parent = delayFrame
    
    -- Loop Counter
    local loopLabel = Instance.new("TextLabel")
    loopLabel.Size = UDim2.new(1, -20, 0, 20)
    loopLabel.Position = UDim2.new(0, 10, 0, 150)
    loopLabel.Text = "Loops: 0"
    loopLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    loopLabel.BackgroundTransparency = 1
    loopLabel.Font = Enum.Font.SourceSans
    loopLabel.TextSize = 12
    loopLabel.TextXAlignment = Enum.TextXAlignment.Left
    loopLabel.Parent = mainFrame
    
    -- Control Buttons (side by side)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -20, 0, 35)
    buttonFrame.Position = UDim2.new(0, 10, 1, -40)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0.48, -2, 1, 0)
    startBtn.Text = "▶ START"
    startBtn.TextColor3 = Color3.new(0, 1, 0)
    startBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
    startBtn.Font = Enum.Font.SourceSansBold
    startBtn.TextSize = 14
    startBtn.Parent = buttonFrame
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.48, -2, 1, 0)
    stopBtn.Position = UDim2.new(0.52, 0, 0, 0)
    stopBtn.Text = "⏹ STOP"
    stopBtn.TextColor3 = Color3.new(1, 0.5, 0)
    stopBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
    stopBtn.Font = Enum.Font.SourceSansBold
    stopBtn.TextSize = 14
    stopBtn.Parent = buttonFrame
    
    return {
        Gui = screenGui,
        MainFrame = mainFrame,
        MiniToggle = miniToggle,
        StatusText = statusText,
        FishIdBox = fishIdBox,
        DelayLabel = delayLabel,
        PlusBtn = plusBtn,
        MinusBtn = minusBtn,
        LoopLabel = loopLabel,
        StartBtn = startBtn,
        StopBtn = stopBtn,
        HideButton = hideButton
    }
end

-- Create GUI
local ui = createMobileGUI()
ui.Gui.Parent = player:WaitForChild("PlayerGui")

-- Variables
local isSpamming = false
local loopCount = 0
local currentDelay = 0.5
local spamThread = nil

-- Toggle GUI visibility
local function toggleGUI()
    if ui.MainFrame.Visible then
        -- Hide main frame, show mini toggle
        ui.MainFrame.Visible = false
        ui.MiniToggle.Visible = true
        ui.MiniToggle.Position = UDim2.new(
            0, ui.MainFrame.Position.X.Offset,
            0, ui.MainFrame.Position.Y.Offset
        )
    else
        -- Show main frame, hide mini toggle
        ui.MainFrame.Visible = true
        ui.MiniToggle.Visible = false
    end
end

-- Send fish function
local function sendFish()
    local fishId = ui.FishIdBox.Text
    if fishId == "" then return false end
    
    local args = {[1] = fishId}
    
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage").GiveFishFunction:InvokeServer(unpack(args))
    end)
    
    return success
end

-- Update display
local function updateDisplay()
    ui.LoopLabel.Text = "Loops: " .. tostring(loopCount)
end

-- Delay controls
ui.PlusBtn.MouseButton1Click:Connect(function()
    currentDelay = currentDelay + 0.1
    if currentDelay > 2 then currentDelay = 2 end
    ui.DelayLabel.Text = "Delay: " .. string.format("%.1f", currentDelay) .. "s"
end)

ui.MinusBtn.MouseButton1Click:Connect(function()
    currentDelay = currentDelay - 0.1
    if currentDelay < 0.1 then currentDelay = 0.1 end
    ui.DelayLabel.Text = "Delay: " .. string.format("%.1f", currentDelay) .. "s"
end)

-- Start button
ui.StartBtn.MouseButton1Click:Connect(function()
    if isSpamming then return end
    
    isSpamming = true
    ui.StatusText.Text = "SPAMMING"
    ui.StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
    
    spamThread = task.spawn(function()
        while isSpamming do
            local success = sendFish()
            if success then
                loopCount = loopCount + 1
                updateDisplay()
                
                -- Update every 10 loops
                if loopCount % 10 == 0 then
                    ui.StatusText.Text = "SPAM: " .. loopCount
                end
            end
            
            task.wait(currentDelay)
        end
    end)
end)

-- Stop button
ui.StopBtn.MouseButton1Click:Connect(function()
    if not isSpamming then return end
    
    isSpamming = false
    if spamThread then
        task.cancel(spamThread)
        spamThread = nil
    end
    
    ui.StatusText.Text = "STOPPED"
    ui.StatusText.TextColor3 = Color3.fromRGB(255, 50, 50)
end)

-- Hide/Show button
ui.HideButton.MouseButton1Click:Connect(toggleGUI)

-- Mini toggle button
ui.MiniToggle.MouseButton1Click:Connect(toggleGUI)

-- Drag functionality
local dragging = false
local dragStart, startPos

ui.MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ui.MainFrame.Position
    end
end)

ui.MiniToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ui.MiniToggle.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        
        if ui.MainFrame.Visible then
            ui.MainFrame.Position = newPos
        else
            ui.MiniToggle.Position = newPos
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Auto-stop when menu opens (mobile)
game:GetService("GuiService"):GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
    if game:GetService("GuiService").MenuIsOpen and isSpamming then
        ui.StopBtn.MouseButton1Click()
    end
end)

-- Save position when moved
local function savePosition()
    local position = ui.MainFrame.Visible and ui.MainFrame.Position or ui.MiniToggle.Position
    _G.ZetaSpammerPosition = {X = position.X.Offset, Y = position.Y.Offset}
end

-- Load saved position
if _G.ZetaSpammerPosition then
    ui.MainFrame.Position = UDim2.new(0, _G.ZetaSpammerPosition.X, 0, _G.ZetaSpammerPosition.Y)
    ui.MiniToggle.Position = UDim2.new(0, _G.ZetaSpammerPosition.X, 0, _G.ZetaSpammerPosition.Y)
end

-- Save position on move
game:GetService("RunService").Heartbeat:Connect(function()
    if dragging then
        savePosition()
    end
end)

-- Mobile notification (top-center)
local function mobileNotify(text, duration)
    local notify = Instance.new("TextLabel")
    notify.Size = UDim2.new(0.8, 0, 0, 40)
    notify.Position = UDim2.new(0.1, 0, 0.1, 0)
    notify.Text = text
    notify.TextColor3 = Color3.new(1, 1, 1)
    notify.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    notify.BorderSizePixel = 2
    notify.BorderColor3 = Color3.fromRGB(100, 100, 100)
    notify.Font = Enum.Font.SourceSansBold
    notify.TextSize = 14
    notify.TextScaled = true
    notify.ZIndex = 100
    notify.Parent = ui.Gui
    
    task.spawn(function()
        for i = 1, 20 do
            notify.Position = UDim2.new(0.1, 0, 0.1 - (i * 0.002), 0)
            task.wait(0.02)
        end
    end)
    
    task.wait(duration or 2)
    
    for i = 1, 20 do
        notify.BackgroundTransparency = i/20
        notify.TextTransparency = i/20
        task.wait(0.02)
    end
    
    notify:Destroy()
end

-- Initial notification
task.wait(1)
mobileNotify("🎣 ZETA MOBILE SPAMMER LOADED", 2)

print("✅ Mobile Fish Spammer ready!")
print("📱 Tap [-] to hide, tap mini button to show")
print("🔥 Drag to move, use +/- for delay")

-- Cleanup on script end
game:BindToClose(function()
    isSpamming = false
    if spamThread then
        task.cancel(spamThread)
    end
end)
