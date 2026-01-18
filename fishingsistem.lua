-- ============================================================================
-- DYRON MODE v1 - ENHANCED FISHING SYSTEM CHEAT MODULE
-- Optimized for Roblox | Mobile Support | Advanced Features
-- ============================================================================

local module_upvr = { ... } -- Your existing module

-- Service declarations
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Player reference
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Cheat configuration
local CheatConfig = {
    Enabled = true,
    AutoFish = false,
    InstantCatch = false,
    SetRarity = "Common",
    ForceMaxWeight = false,
    MaxWeightOverride = 9999,
    NoInventoryLimit = false,
    AutoSellAll = false,
    NoMinigame = false,
    TeleportFishToPlayer = true,
    BypassCooldowns = true,
    SilentMode = false,
    AntiAfk = true,
    MobileUI = true
}

-- UI Creation for Mobile/Desktop
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DyronCheatsV1"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0, 10, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 119)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Text = "DYRON FISHING CHEATS v1.0"
Title.TextColor3 = Color3.fromRGB(0, 255, 119)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.white
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Title

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    CheatConfig.Enabled = false
end)

-- Minimize button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.white
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = Title

local isMinimized = false
local originalSize = MainFrame.Size
MinimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        MainFrame.Size = originalSize
        MainFrame.ClipsDescendants = false
        MinimizeButton.Text = "_"
    else
        MainFrame.Size = UDim2.new(0, 320, 0, 40)
        MainFrame.ClipsDescendants = true
        MinimizeButton.Text = "+"
    end
    isMinimized = not isMinimized
end)

-- Scroll frame for options
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 119)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollFrame.Parent = MainFrame

-- Function to create toggle
local function CreateToggle(name, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name .. "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.LayoutOrder = #ScrollFrame:GetChildren()
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 200, 0, 30)
    toggleButton.Position = UDim2.new(0, 10, 0, 5)
    toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    toggleButton.Text = name .. ": " .. (defaultValue and "ON" or "OFF")
    toggleButton.TextColor3 = Color3.white
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.Parent = toggleFrame
    
    local value = defaultValue
    
    toggleButton.MouseButton1Click:Connect(function()
        value = not value
        toggleButton.BackgroundColor3 = value and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        toggleButton.Text = name .. ": " .. (value and "ON" or "OFF")
        if callback then callback(value) end
    end)
    
    toggleFrame.Parent = ScrollFrame
    return {Button = toggleButton, GetValue = function() return value end, SetValue = function(newVal) 
        value = newVal
        toggleButton.BackgroundColor3 = value and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        toggleButton.Text = name .. ": " .. (value and "ON" or "OFF")
        if callback then callback(value) end
    end}
end

-- Function to create dropdown
local function CreateDropdown(name, options, defaultIndex, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = name .. "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 60)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.LayoutOrder = #ScrollFrame:GetChildren()
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ":"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Size = UDim2.new(1, -20, 0, 30)
    dropdownButton.Position = UDim2.new(0, 10, 0, 25)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    dropdownButton.Text = options[defaultIndex] or options[1]
    dropdownButton.TextColor3 = Color3.white
    dropdownButton.TextSize = 14
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.Parent = dropdownFrame
    
    local dropdownFrameOpen = Instance.new("Frame")
    dropdownFrameOpen.Name = "DropdownOpen"
    dropdownFrameOpen.Size = UDim2.new(1, -20, 0, 0)
    dropdownFrameOpen.Position = UDim2.new(0, 10, 0, 55)
    dropdownFrameOpen.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    dropdownFrameOpen.BorderSizePixel = 1
    dropdownFrameOpen.BorderColor3 = Color3.fromRGB(100, 100, 120)
    dropdownFrameOpen.Visible = false
    dropdownFrameOpen.ClipsDescendants = true
    dropdownFrameOpen.Parent = dropdownFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = dropdownFrameOpen
    
    local selectedValue = options[defaultIndex] or options[1]
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option_" .. option
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = Color3.white
        optionButton.TextSize = 12
        optionButton.Font = Enum.Font.Gotham
        
        optionButton.MouseButton1Click:Connect(function()
            selectedValue = option
            dropdownButton.Text = option
            dropdownFrameOpen.Visible = false
            if callback then callback(option) end
        end)
        
        optionButton.Parent = dropdownFrameOpen
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownFrameOpen.Visible = not dropdownFrameOpen.Visible
        if dropdownFrameOpen.Visible then
            dropdownFrameOpen.Size = UDim2.new(1, -20, 0, math.min(#options * 25, 125))
        else
            dropdownFrameOpen.Size = UDim2.new(1, -20, 0, 0)
        end
    end)
    
    dropdownFrame.Parent = ScrollFrame
    return {GetValue = function() return selectedValue end}
end

-- Create cheat toggles
local AutoFishToggle = CreateToggle("Auto Fish", CheatConfig.AutoFish, function(value)
    CheatConfig.AutoFish = value
end)

local InstantCatchToggle = CreateToggle("Instant Catch", CheatConfig.InstantCatch, function(value)
    CheatConfig.InstantCatch = value
end)

local NoMinigameToggle = CreateToggle("No Minigame", CheatConfig.NoMinigame, function(value)
    CheatConfig.NoMinigame = value
end)

local ForceMaxWeightToggle = CreateToggle("Force Max Weight", CheatConfig.ForceMaxWeight, function(value)
    CheatConfig.ForceMaxWeight = value
end)

local NoInventoryLimitToggle = CreateToggle("No Inventory Limit", CheatConfig.NoInventoryLimit, function(value)
    CheatConfig.NoInventoryLimit = value
end)

local AutoSellAllToggle = CreateToggle("Auto Sell All", CheatConfig.AutoSellAll, function(value)
    CheatConfig.AutoSellAll = value
end)

local TeleportFishToggle = CreateToggle("Teleport Fish", CheatConfig.TeleportFishToPlayer, function(value)
    CheatConfig.TeleportFishToPlayer = value
end)

local BypassCooldownsToggle = CreateToggle("Bypass Cooldowns", CheatConfig.BypassCooldowns, function(value)
    CheatConfig.BypassCooldowns = value
end)

local AntiAfkToggle = CreateToggle("Anti AFK", CheatConfig.AntiAfk, function(value)
    CheatConfig.AntiAfk = value
end)

-- Rarity dropdown
local rarityOptions = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "SECRET"}
local RarityDropdown = CreateDropdown("Set Rarity", rarityOptions, 1, function(value)
    CheatConfig.SetRarity = value
end)

-- Mobile control buttons
if CheatConfig.MobileUI then
    local mobileFrame = Instance.new("Frame")
    mobileFrame.Name = "MobileControls"
    mobileFrame.Size = UDim2.new(0, 100, 0, 150)
    mobileFrame.Position = UDim2.new(1, 10, 0.5, -75)
    mobileFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40, 0.8)
    mobileFrame.BackgroundTransparency = 0.2
    mobileFrame.BorderSizePixel = 2
    mobileFrame.BorderColor3 = Color3.fromRGB(0, 255, 119)
    mobileFrame.Parent = ScreenGui
    
    local mobileTitle = Instance.new("TextLabel")
    mobileTitle.Name = "MobileTitle"
    mobileTitle.Size = UDim2.new(1, 0, 0, 25)
    mobileTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mobileTitle.Text = "MOBILE"
    mobileTitle.TextColor3 = Color3.fromRGB(0, 255, 119)
    mobileTitle.TextSize = 14
    mobileTitle.Font = Enum.Font.GothamBold
    mobileTitle.Parent = mobileFrame
    
    -- Quick action buttons for mobile
    local buttons = {
        {"AUTO ON", function() AutoFishToggle.SetValue(true) end},
        {"AUTO OFF", function() AutoFishToggle.SetValue(false) end},
        {"INSTANT", function() InstantCatchToggle.SetValue(not InstantCatchToggle.GetValue()) end},
        {"SELL ALL", function() SellAllFish() end}
    }
    
    for i, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Name = "MobileBtn_" .. i
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5, 0, 25 + (i-1)*30)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.Text = btnData[1]
        btn.TextColor3 = Color3.white
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        
        btn.MouseButton1Click:Connect(btnData[2])
        btn.Parent = mobileFrame
    end
end

-- Hook critical functions
local originalGenerateFishWeight = module_upvr.GenerateFishWeight
module_upvr.GenerateFishWeight = function(fishData, rodConfig, maxWeight)
    if CheatConfig.ForceMaxWeight then
        return CheatConfig.MaxWeightOverride
    end
    return originalGenerateFishWeight(fishData, rodConfig, maxWeight)
end

local originalCalculateFishPrice = module_upvr.CalculateFishPrice
module_upvr.CalculateFishPrice = function(weight, rarity)
    local price = originalCalculateFishPrice(weight, rarity)
    if CheatConfig.AutoSellAll then
        price = price * 2 -- Double price when auto selling
    end
    return price
end

-- Find fishing system remote events/functions
local fishingSystem
local fishingRemote
local minigameRemote
local sellRemote

local function FindFishingSystem()
    for _, child in pairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            if string.find(child.Name:lower(), "fish") or string.find(child.Name:lower(), "catch") then
                fishingRemote = child
            elseif string.find(child.Name:lower(), "minigame") then
                minigameRemote = child
            elseif string.find(child.Name:lower(), "sell") then
                sellRemote = child
            end
        end
    end
    
    -- Also check folders
    local folders = ReplicatedStorage:GetChildren()
    for _, folder in ipairs(folders) do
        if folder:IsA("Folder") and (string.find(folder.Name:lower(), "fish") or string.find(folder.Name:lower(), "system")) then
            fishingSystem = folder
        end
    end
end

-- Auto-fish function
local isFishing = false
local lastFishTime = 0
local fishCooldown = 2 -- seconds

local function StartAutoFishing()
    if not CheatConfig.AutoFish or isFishing then return end
    
    isFishing = true
    spawn(function()
        while CheatConfig.AutoFish and CheatConfig.Enabled do
            if tick() - lastFishTime > fishCooldown then
                -- Simulate fishing action
                if fishingRemote then
                    -- Cast fishing rod
                    fishingRemote:FireServer("StartFishing")
                    
                    -- Wait for bite
                    wait(math.random(1, 3))
                    
                    -- Catch fish with modified rarity if needed
                    local catchArgs = {
                        FishName = "Cheated Fish",
                        Weight = CheatConfig.ForceMaxWeight and CheatConfig.MaxWeightOverride or math.random(50, 200),
                        Rarity = CheatConfig.SetRarity,
                        Position = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart.Position
                    }
                    
                    if CheatConfig.InstantCatch then
                        fishingRemote:FireServer("CatchFish", catchArgs)
                    else
                        -- Handle minigame bypass
                        if minigameRemote and not CheatConfig.NoMinigame then
                            minigameRemote:FireServer("StartMinigame")
                            wait(0.1)
                            minigameRemote:FireServer("CompleteMinigame", 100) -- Always win
                        end
                        fishingRemote:FireServer("CatchFish", catchArgs)
                    end
                    
                    lastFishTime = tick()
                    
                    -- Auto sell if enabled
                    if CheatConfig.AutoSellAll and sellRemote then
                        sellRemote:FireServer("SellAllFish")
                    end
                end
                
                wait(fishCooldown)
            end
            RunService.Heartbeat:Wait()
        end
        isFishing = false
    end)
end

-- Anti-AFK system
local antiAfkConnection
if CheatConfig.AntiAfk then
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    antiAfkConnection = RunService.Heartbeat:Connect(function()
        if not CheatConfig.Enabled then return end
        
        -- Simulate small movements to prevent AFK
        if tick() % 30 < 0.1 then -- Every 30 seconds
            VirtualInputManager:SendMouseMoveEvent(10, 10)
        end
    end)
end

-- Hook into existing fishing mechanics
local function HookExistingFunctions()
    -- Find and hook any existing fishing functions
    local scripts = game:GetService("Workspace"):GetDescendants()
    for _, script in ipairs(scripts) do
        if script:IsA("Script") or script:IsA("LocalScript") then
            local success, src = pcall(function()
                return script.Source
            end)
            
            if success and src then
                if string.find(src:lower(), "fish") or string.find(src:lower(), "catch") then
                    -- Found fishing-related script
                    print("[DYRON] Found fishing script:", script:GetFullName())
                end
            end
        end
    end
end

-- Sell all fish function
function SellAllFish()
    if sellRemote then
        sellRemote:FireServer("SellAllFish")
    else
        -- Try to find sell remote
        FindFishingSystem()
        if sellRemote then
            sellRemote:FireServer("SellAllFish")
        end
    end
end

-- Create hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then -- Toggle auto fish
        AutoFishToggle.SetValue(not AutoFishToggle.GetValue())
    elseif input.KeyCode == Enum.KeyCode.G then -- Toggle instant catch
        InstantCatchToggle.SetValue(not InstantCatchToggle.GetValue())
    elseif input.KeyCode == Enum.KeyCode.H then -- Sell all fish
        SellAllFish()
    elseif input.KeyCode == Enum.KeyCode.J then -- Cycle rarity
        local currentIndex = table.find(rarityOptions, CheatConfig.SetRarity) or 1
        local nextIndex = currentIndex % #rarityOptions + 1
        CheatConfig.SetRarity = rarityOptions[nextIndex]
    end
end)

-- Mobile touch gestures
if UserInputService.TouchEnabled then
    local lastTapTime = 0
    local tapCount = 0
    
    UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
        if gameProcessed then return end
        
        local currentTime = tick()
        if currentTime - lastTapTime < 0.5 then
            tapCount = tapCount + 1
            if tapCount >= 3 then -- Triple tap
                -- Show/hide cheat menu
                MainFrame.Visible = not MainFrame.Visible
                tapCount = 0
            end
        else
            tapCount = 1
        end
        lastTapTime = currentTime
    end)
end

-- Initialize
FindFishingSystem()
HookExistingFunctions()

-- Start auto fishing if enabled
if CheatConfig.AutoFish then
    StartAutoFishing()
end

-- Connect toggle to auto fishing
AutoFishToggle.Button.MouseButton1Click:Connect(function()
    if AutoFishToggle.GetValue() then
        StartAutoFishing()
    end
end)

print("[DYRON MODE v1] Fishing cheats loaded successfully!")
print("[CONTROLS] F: Auto Fish | G: Instant Catch | H: Sell All | J: Cycle Rarity")
print("[MOBILE] Triple tap to toggle menu")

-- Return module for external use
return {
    Config = CheatConfig,
    ToggleAutoFish = function(value) AutoFishToggle.SetValue(value) end,
    ToggleInstantCatch = function(value) InstantCatchToggle.SetValue(value) end,
    SetRarity = function(rarity) CheatConfig.SetRarity = rarity end,
    SellAllFish = SellAllFish,
    GetUI = function() return ScreenGui end
}
