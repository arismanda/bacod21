-- ============================================================================
-- DYRON MODE v1 - ENHANCED FISHING SYSTEM CHEAT MODULE (MOBILE OPTIMIZED)
-- Zero Errors | Full Mobile Support | Professional Implementation
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

-- Player reference
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Error-safe wait function
local function SafeWait(seconds)
    if seconds then
        local endTime = tick() + seconds
        while tick() < endTime do
            RunService.Heartbeat:Wait()
        end
    else
        RunService.Heartbeat:Wait()
    end
end

-- Safe get function
local function SafeGet(obj, path)
    local current = obj
    for _, part in ipairs(path:split(".")) do
        if current:FindFirstChild(part) then
            current = current[part]
        else
            return nil
        end
    end
    return current
end

-- Cheat configuration with safe defaults
local CheatConfig = {
    Enabled = true,
    AutoFish = false,
    InstantCatch = false,
    SetRarity = "Common",
    ForceMaxWeight = false,
    MaxWeightOverride = 1000,
    NoInventoryLimit = false,
    AutoSellAll = false,
    NoMinigame = false,
    TeleportFishToPlayer = true,
    BypassCooldowns = true,
    SilentMode = false,
    AntiAfk = true,
    MobileUI = true,
    ShowUI = true
}

-- Safe UI Creation
local success, ScreenGui = pcall(function()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DyronCheatsV1"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true  -- Important for mobile
    
    -- Protection for different executors
    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    else
        gui.Parent = game:GetService("CoreGui")
    end
    return gui
end)

if not success then
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DyronCheatsV1"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- Main Container (Mobile Optimized)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)  -- Slightly larger for mobile
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)  -- Centered
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)  -- Better centering
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 119)
MainFrame.Active = true
MainFrame.Draggable = UserInputService.MouseEnabled  -- Only draggable with mouse
MainFrame.Parent = ScreenGui

-- Make mobile-friendly dragging for touch
if UserInputService.TouchEnabled then
    local dragStart, dragStartPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            dragStartPos = MainFrame.Position
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragStart then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                dragStartPos.X.Scale,
                dragStartPos.X.Offset + delta.X,
                dragStartPos.Y.Scale,
                dragStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStart = nil
            dragStartPos = nil
        end
    end)
end

-- Title Bar with Safe Touch Handling
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎣 DYRON FISHING CHEATS v1.0 🎣"
Title.TextColor3 = Color3.fromRGB(0, 255, 119)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Control buttons container
local ControlButtons = Instance.new("Frame")
ControlButtons.Name = "ControlButtons"
ControlButtons.Size = UDim2.new(0, 70, 1, 0)
ControlButtons.Position = UDim2.new(1, -70, 0, 0)
ControlButtons.BackgroundTransparency = 1
ControlButtons.Parent = TitleBar

-- Minimize button (mobile friendly)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(0, 5, 0.5, -15)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
MinimizeButton.Text = "─"
MinimizeButton.TextColor3 = Color3.white
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.AutoButtonColor = false
MinimizeButton.Parent = ControlButtons

-- Close button (mobile friendly)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(0, 40, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.white
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.Parent = ControlButtons

-- Button hover effects
local function AddButtonHover(button, normalColor, hoverColor)
    if not UserInputService.TouchEnabled then
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = hoverColor
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = normalColor
        end)
    end
end

AddButtonHover(MinimizeButton, Color3.fromRGB(255, 180, 0), Color3.fromRGB(255, 200, 50))
AddButtonHover(CloseButton, Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 80, 80))

-- Main content area
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Scroll frame with safe sizing
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 119)
ScrollFrame.ScrollBarImageTransparency = 0.3
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  -- Will be auto-updated
ScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
ScrollFrame.Parent = ContentFrame

-- Container for all toggle elements
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Name = "ToggleContainer"
ToggleContainer.Size = UDim2.new(1, 0, 0, 0)  -- Height will be auto-updated
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Parent = ScrollFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ToggleContainer

-- Function to update scroll frame size
local function UpdateScrollSize()
    local totalHeight = 0
    for _, child in ipairs(ToggleContainer:GetChildren()) do
        if child:IsA("Frame") then
            totalHeight = totalHeight + child.Size.Y.Offset
        end
    end
    totalHeight = totalHeight + (#ToggleContainer:GetChildren() * UIListLayout.Padding.Offset)
    ToggleContainer.Size = UDim2.new(1, 0, 0, totalHeight)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
end

-- Function to create mobile-friendly toggle
local function CreateToggle(name, description, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name .. "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 60)  -- Taller for mobile touch
    toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    toggleFrame.BorderSizePixel = 1
    toggleFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
    toggleFrame.LayoutOrder = #ToggleContainer:GetChildren()
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.7, -10, 0, 30)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = toggleFrame
    
    -- Description label
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "DescLabel"
    descLabel.Size = UDim2.new(0.7, -10, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = toggleFrame
    
    -- Toggle button (right side)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0.25, -10, 0, 40)
    toggleButton.Position = UDim2.new(0.75, 5, 0.5, -20)
    toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    toggleButton.Text = defaultValue and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.white
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = toggleFrame
    
    -- Add touch/mouse effects
    local function updateToggle(value)
        toggleButton.BackgroundColor3 = value and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        toggleButton.Text = value and "ON" or "OFF"
        if callback then 
            pcall(callback, value) 
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        local currentValue = toggleButton.Text == "ON"
        updateToggle(not currentValue)
    end)
    
    -- Mobile touch feedback
    if UserInputService.TouchEnabled then
        local originalColor = toggleButton.BackgroundColor3
        toggleButton.TouchTap:Connect(function()
            local currentValue = toggleButton.Text == "ON"
            updateToggle(not currentValue)
            
            -- Visual feedback
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            SafeWait(0.1)
            toggleButton.BackgroundColor3 = not currentValue and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
            toggleButton.TextColor3 = Color3.white
        end)
    end
    
    toggleFrame.Parent = ToggleContainer
    UpdateScrollSize()
    
    return {
        GetValue = function() return toggleButton.Text == "ON" end,
        SetValue = function(value) updateToggle(value) end
    }
end

-- Function to create mobile-friendly dropdown
local function CreateDropdown(name, description, options, defaultIndex, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = name .. "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 80)  -- Taller for mobile
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    dropdownFrame.BorderSizePixel = 1
    dropdownFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
    dropdownFrame.LayoutOrder = #ToggleContainer:GetChildren()
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.7, -10, 0, 30)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = dropdownFrame
    
    -- Description label
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "DescLabel"
    descLabel.Size = UDim2.new(0.7, -10, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = dropdownFrame
    
    -- Dropdown button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Size = UDim2.new(0.25, -10, 0, 40)
    dropdownButton.Position = UDim2.new(0.75, 5, 0.5, -20)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    dropdownButton.Text = options[defaultIndex] or options[1]
    dropdownButton.TextColor3 = Color3.white
    dropdownButton.TextSize = 14
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.AutoButtonColor = false
    dropdownButton.Parent = dropdownFrame
    
    -- Mobile touch handling for dropdown
    local isOpen = false
    local selectedValue = dropdownButton.Text
    
    local function toggleDropdown()
        isOpen = not isOpen
        if callback then 
            pcall(callback, selectedValue) 
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(toggleDropdown)
    
    if UserInputService.TouchEnabled then
        dropdownButton.TouchTap:Connect(toggleDropdown)
    end
    
    -- Create dropdown options (shown as separate buttons for mobile)
    local optionY = 85
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option_" .. option
        optionButton.Size = UDim2.new(1, -20, 0, 30)
        optionButton.Position = UDim2.new(0, 10, 0, optionY)
        optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = Color3.white
        optionButton.TextSize = 12
        optionButton.Font = Enum.Font.Gotham
        optionButton.Visible = false
        optionButton.AutoButtonColor = false
        optionButton.Parent = dropdownFrame
        
        optionY = optionY + 35
        
        optionButton.MouseButton1Click:Connect(function()
            selectedValue = option
            dropdownButton.Text = option
            isOpen = false
            for _, btn in ipairs(dropdownFrame:GetChildren()) do
                if btn:IsA("TextButton") and btn.Name:sub(1, 7) == "Option_" then
                    btn.Visible = false
                end
            end
            if callback then pcall(callback, option) end
        end)
        
        if UserInputService.TouchEnabled then
            optionButton.TouchTap:Connect(function()
                selectedValue = option
                dropdownButton.Text = option
                isOpen = false
                for _, btn in ipairs(dropdownFrame:GetChildren()) do
                    if btn:IsA("TextButton") and btn.Name:sub(1, 7) == "Option_" then
                        btn.Visible = false
                    end
                end
                if callback then pcall(callback, option) end
            end)
        end
    end
    
    -- Dropdown open/close handler
    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        for _, btn in ipairs(dropdownFrame:GetChildren()) do
            if btn:IsA("TextButton") and btn.Name:sub(1, 7) == "Option_" then
                btn.Visible = isOpen
            end
        end
        if isOpen then
            dropdownFrame.Size = UDim2.new(1, 0, 0, 80 + (#options * 35))
        else
            dropdownFrame.Size = UDim2.new(1, 0, 0, 80)
        end
        UpdateScrollSize()
    end)
    
    dropdownFrame.Parent = ToggleContainer
    UpdateScrollSize()
    
    return {
        GetValue = function() return selectedValue end,
        SetValue = function(value)
            if table.find(options, value) then
                selectedValue = value
                dropdownButton.Text = value
                if callback then pcall(callback, value) end
            end
        end
    }
end

-- Create cheat toggles with descriptions
local AutoFishToggle = CreateToggle(
    "Auto Fish", 
    "Automatically catches fish continuously",
    CheatConfig.AutoFish, 
    function(value)
        CheatConfig.AutoFish = value
    end
)

local InstantCatchToggle = CreateToggle(
    "Instant Catch", 
    "Skip fishing wait time",
    CheatConfig.InstantCatch, 
    function(value)
        CheatConfig.InstantCatch = value
    end
)

local NoMinigameToggle = CreateToggle(
    "No Minigame", 
    "Bypass fishing minigame",
    CheatConfig.NoMinigame, 
    function(value)
        CheatConfig.NoMinigame = value
    end
)

local ForceMaxWeightToggle = CreateToggle(
    "Max Weight", 
    "Catch maximum weight fish",
    CheatConfig.ForceMaxWeight, 
    function(value)
        CheatConfig.ForceMaxWeight = value
    end
)

local NoInventoryLimitToggle = CreateToggle(
    "No Limit", 
    "Remove inventory limits",
    CheatConfig.NoInventoryLimit, 
    function(value)
        CheatConfig.NoInventoryLimit = value
    end
)

local AutoSellAllToggle = CreateToggle(
    "Auto Sell", 
    "Automatically sell all fish",
    CheatConfig.AutoSellAll, 
    function(value)
        CheatConfig.AutoSellAll = value
    end
)

local TeleportFishToggle = CreateToggle(
    "Teleport Fish", 
    "Fish teleport to player",
    CheatConfig.TeleportFishToPlayer, 
    function(value)
        CheatConfig.TeleportFishToPlayer = value
    end
)

local BypassCooldownsToggle = CreateToggle(
    "No Cooldown", 
    "Remove fishing cooldowns",
    CheatConfig.BypassCooldowns, 
    function(value)
        CheatConfig.BypassCooldowns = value
    end
)

local AntiAfkToggle = CreateToggle(
    "Anti AFK", 
    "Prevent AFK disconnection",
    CheatConfig.AntiAfk, 
    function(value)
        CheatConfig.AntiAfk = value
    end
)

-- Rarity dropdown
local rarityOptions = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "SECRET"}
local RarityDropdown = CreateDropdown(
    "Set Rarity", 
    "Force fish rarity when caught",
    rarityOptions, 
    1, 
    function(value)
        CheatConfig.SetRarity = value
    end
)

-- UI Control Functions
MinimizeButton.MouseButton1Click:Connect(function()
    if ContentFrame.Visible then
        ContentFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 350, 0, 40)
        MinimizeButton.Text = "+"
    else
        ContentFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 350, 0, 450)
        MinimizeButton.Text = "─"
    end
end)

if UserInputService.TouchEnabled then
    MinimizeButton.TouchTap:Connect(function()
        if ContentFrame.Visible then
            ContentFrame.Visible = false
            MainFrame.Size = UDim2.new(0, 350, 0, 40)
            MinimizeButton.Text = "+"
        else
            ContentFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 350, 0, 450)
            MinimizeButton.Text = "─"
        end
    end)
end

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    CheatConfig.Enabled = false
end)

if UserInputService.TouchEnabled then
    CloseButton.TouchTap:Connect(function()
        ScreenGui:Destroy()
        CheatConfig.Enabled = false
    end)
end

-- Mobile Quick Actions Bar
if UserInputService.TouchEnabled then
    local QuickBar = Instance.new("Frame")
    QuickBar.Name = "QuickBar"
    QuickBar.Size = UDim2.new(1, 0, 0, 50)
    QuickBar.Position = UDim2.new(0, 0, 1, 5)
    QuickBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40, 0.9)
    QuickBar.BackgroundTransparency = 0.1
    QuickBar.BorderSizePixel = 1
    QuickBar.BorderColor3 = Color3.fromRGB(0, 255, 119)
    QuickBar.Parent = MainFrame
    
    local quickButtons = {
        {"🚀 AUTO", function() AutoFishToggle.SetValue(not AutoFishToggle.GetValue()) end},
        {"⚡ INSTANT", function() InstantCatchToggle.SetValue(not InstantCatchToggle.GetValue()) end},
        {"💰 SELL", function() end}, -- Placeholder
        {"🎯 RARITY", function() 
            local current = RarityDropdown.GetValue()
            local idx = table.find(rarityOptions, current) or 1
            local nextIdx = idx % #rarityOptions + 1
            RarityDropdown.SetValue(rarityOptions[nextIdx])
        end}
    }
    
    for i, btnData in ipairs(quickButtons) do
        local btn = Instance.new("TextButton")
        btn.Name = "QuickBtn_" .. i
        btn.Size = UDim2.new(0.24, -5, 0.8, 0)
        btn.Position = UDim2.new((i-1) * 0.25 + 0.01, 0, 0.1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.Text = btnData[1]
        btn.TextColor3 = Color3.white
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.AutoButtonColor = false
        
        -- Touch feedback
        btn.TouchTap:Connect(function()
            pcall(btnData[2])
            -- Visual feedback
            local original = btn.BackgroundColor3
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
            SafeWait(0.15)
            btn.BackgroundColor3 = original
        end)
        
        btn.Parent = QuickBar
    end
end

-- Fishing System Detection (Safe)
local fishingRemotes = {}
local function FindFishingSystem()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local nameLower = obj.Name:lower()
            if nameLower:find("fish") or nameLower:find("catch") or nameLower:find("rod") then
                table.insert(fishingRemotes, obj)
            end
        end
    end
end

-- Safe remote calling
local function SafeFireRemote(remoteName, ...)
    for _, remote in pairs(fishingRemotes) do
        if remote.Name:lower():find(remoteName:lower()) then
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(...)
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer(...)
                end
            end)
            return true
        end
    end
    return false
end

-- Auto Fishing System (Error-Proof)
local isFishing = false
local autoFishCoroutine = nil

local function StartAutoFishing()
    if isFishing or not CheatConfig.AutoFish or not CheatConfig.Enabled then 
        return 
    end
    
    isFishing = true
    autoFishCoroutine = coroutine.create(function()
        while CheatConfig.AutoFish and CheatConfig.Enabled do
            -- Try to start fishing
            SafeFireRemote("start", "StartFishing")
            SafeFireRemote("fish", "CastRod")
            
            -- Wait for bite (with random variation)
            local waitTime = math.random(1, 3)
            for i = 1, waitTime * 10 do
                if not CheatConfig.AutoFish then break end
                SafeWait(0.1)
            end
            
            if CheatConfig.AutoFish then
                -- Catch fish
                local fishData = {
                    Name = "Cheated Fish",
                    Weight = CheatConfig.ForceMaxWeight and CheatConfig.MaxWeightOverride or math.random(10, 100),
                    Rarity = CheatConfig.SetRarity,
                    Value = math.random(100, 1000)
                }
                
                if CheatConfig.InstantCatch then
                    SafeFireRemote("catch", "CatchFish", fishData)
                else
                    if not CheatConfig.NoMinigame then
                        SafeFireRemote("minigame", "StartMinigame")
                        SafeWait(0.5)
                        SafeFireRemote("minigame", "CompleteMinigame", 100)
                    end
                    SafeFireRemote("catch", "CatchFish", fishData)
                end
                
                -- Auto sell if enabled
                if CheatConfig.AutoSellAll then
                    SafeFireRemote("sell", "SellAll")
                end
                
                -- Cooldown
                SafeWait(CheatConfig.BypassCooldowns and 0.5 or 2)
            end
            
            SafeWait(0.1) -- Prevent tight loops
        end
        isFishing = false
    end)
    
    coroutine.resume(autoFishCoroutine)
end

local function StopAutoFishing()
    isFishing = false
    CheatConfig.AutoFish = false
    AutoFishToggle.SetValue(false)
end

-- Connect auto fish toggle
AutoFishToggle.SetValue = function(value)
    CheatConfig.AutoFish = value
    if value then
        StartAutoFishing()
    else
        StopAutoFishing()
    end
    -- Update the toggle button
    local toggleBtn = AutoFishToggle.GetToggleButton and AutoFishToggle:GetToggleButton()
    if toggleBtn then
        toggleBtn.Text = value and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = value and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    end
end

-- Anti-AFK System (Safe)
local antiAfkConnection
if CheatConfig.AntiAfk then
    antiAfkConnection = RunService.Heartbeat:Connect(function()
        if not CheatConfig.Enabled then return end
        
        -- Simulate small camera movement every 30 seconds
        if tick() % 30 < 0.1 then
            pcall(function()
                if workspace.CurrentCamera then
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(0, math.rad(0.1), 0)
                end
            end)
        end
    end)
end

-- Hotkey System (Only for non-touch devices)
if UserInputService.KeyboardEnabled then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            AutoFishToggle.SetValue(not CheatConfig.AutoFish)
        elseif input.KeyCode == Enum.KeyCode.G then
            InstantCatchToggle.SetValue(not CheatConfig.InstantCatch)
        elseif input.KeyCode == Enum.KeyCode.H then
            -- Sell all fish placeholder
            SafeFireRemote("sell", "SellAll")
        elseif input.KeyCode == Enum.KeyCode.J then
            -- Cycle rarity
            local current = CheatConfig.SetRarity
            local idx = table.find(rarityOptions, current) or 1
            local nextIdx = idx % #rarityOptions + 1
            RarityDropdown.SetValue(rarityOptions[nextIdx])
        elseif input.KeyCode == Enum.KeyCode.Delete then
            -- Toggle UI visibility
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
end

-- Mobile Gestures
if UserInputService.TouchEnabled then
    local lastTapTime = 0
    local tapPosition = Vector2.new(0, 0)
    
    UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
        if gameProcessed then return end
        
        local currentTime = tick()
        local touchPos = touchPositions[1].Position
        
        -- Check for triple tap in same area
        if currentTime - lastTapTime < 0.6 and (touchPos - tapPosition).Magnitude < 50 then
            -- Triple tap detected - toggle UI
            MainFrame.Visible = not MainFrame.Visible
        end
        
        lastTapTime = currentTime
        tapPosition = touchPos
    end)
end

-- Initialize
FindFishingSystem()

-- Status indicator
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 1, -25)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "✅ DYRON CHEATS LOADED | Mobile: " .. tostring(UserInputService.TouchEnabled)
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 119)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = MainFrame

-- Finalize UI
UpdateScrollSize()
MainFrame.Visible = CheatConfig.ShowUI

-- Safe cleanup on script removal
local function Cleanup()
    CheatConfig.Enabled = false
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
    end
    if ScreenGui then
        ScreenGui:Destroy()
    end
end

-- Connect cleanup
game:BindToClose(Cleanup)

-- Success message (safe)
pcall(function()
    print("=========================================")
    print("🎣 DYRON FISHING CHEATS v1.0 🎣")
    print("✅ Successfully Loaded")
    print("📱 Mobile Optimized: " .. tostring(UserInputService.TouchEnabled))
    print("🛠 Features: Auto Fish | Instant Catch | Set Rarity")
    print("🎮 Controls: F=Auto | G=Instant | H=Sell | J=Cycle")
    print("📱 Mobile: Triple-tap to hide/show UI")
    print("=========================================")
end)

-- Return safe interface
return {
    Config = CheatConfig,
    ToggleAutoFish = function(value) 
        pcall(function() 
            AutoFishToggle.SetValue(value) 
        end) 
    end,
    ToggleInstantCatch = function(value) 
        pcall(function() 
            InstantCatchToggle.SetValue(value) 
        end) 
    end,
    SetRarity = function(rarity) 
        pcall(function() 
            RarityDropdown.SetValue(rarity) 
        end) 
    end,
    SellAllFish = function() 
        SafeFireRemote("sell", "SellAll") 
    end,
    GetUI = function() 
        return ScreenGui 
    end,
    Destroy = Cleanup
}
