-- ============================================
-- ULTIMATE INSTANT CATCH CHEAT
-- Support Mobile & Desktop
-- Rarity Selector + Auto Features
-- ============================================

-- Auto-detect platform
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Platform detection
local IS_MOBILE = UserInputService.TouchEnabled
local IS_CONSOLE = UserInputService.GamepadEnabled
local IS_DESKTOP = not IS_MOBILE and not IS_CONSOLE

-- Mobile optimizations
local UI_SCALE = IS_MOBILE and 1.3 or 1
local BUTTON_SIZE = IS_MOBILE and 50 or 40

-- ============================================
-- CONFIGURATION
-- ============================================

local CheatConfig = {
    -- Rarity Selection
    SelectedRarity = "SECRET",
    
    -- Weight Settings
    MinWeight = 300,
    MaxWeight = 500,
    
    -- Features
    InstantCatch = true,
    AutoSell = false,
    AutoFish = false,
    
    -- Mobile Features
    TouchVibration = false,
    SimpleMode = IS_MOBILE,
    LargeButtons = IS_MOBILE
}

-- ============================================
-- CORE FUNCTIONS
-- ============================================

local function GetFishByRarity(rarity)
    local fishList = {}
    for _, fish in pairs(module_upvr.FishTable) do
        if fish.rarity == rarity then
            table.insert(fishList, fish)
        end
    end
    return fishList
end

local function CreateFakeFish()
    local rarity = CheatConfig.SelectedRarity
    local fishList = GetFishByRarity(rarity)
    
    if #fishList == 0 then
        -- Fallback to any fish
        fishList = GetFishByRarity("Common")
    end
    
    local fish = fishList[math.random(1, #fishList)]
    local weight = math.random(CheatConfig.MinWeight * 10, CheatConfig.MaxWeight * 10) / 10
    
    return {
        Name = fish.name,
        Weight = weight,
        Rarity = rarity,
        Price = module_upvr.CalculateFishPrice(weight, rarity),
        Timestamp = os.time()
    }
end

-- ============================================
-- HOOK FISHING SYSTEM
-- ============================================

local function SetupInstantCatch()
    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 5)
    if not FishingSystem then return false end
    
    -- Find fishing remotes
    local remotes = {}
    for _, child in pairs(FishingSystem:GetChildren()) do
        if child:IsA("RemoteEvent") then
            remotes[child.Name] = child
        end
    end
    
    -- Hook fishing start
    local startRemote = remotes["StartFishing"] or remotes["BeginFishing"]
    if startRemote then
        local originalFire = startRemote.FireServer
        startRemote.FireServer = function(self, ...)
            local result = originalFire(self, ...)
            
            if CheatConfig.InstantCatch then
                task.wait(0.3) -- Short delay
                
                -- Get catch remote
                local catchRemote = remotes["CatchFish"] or remotes["CompleteFishing"]
                if catchRemote then
                    local fakeFish = CreateFakeFish()
                    catchRemote:FireServer(fakeFish)
                    
                    -- Mobile notification
                    if IS_MOBILE then
                        print("🎣 " .. fakeFish.Name .. " (" .. fakeFish.Weight .. "kg)")
                    end
                    
                    -- Auto sell
                    if CheatConfig.AutoSell then
                        local sellRemote = remotes["SellFish"]
                        if sellRemote then
                            task.wait(0.5)
                            sellRemote:FireServer({fakeFish})
                        end
                    end
                end
            end
            
            return result
        end
    end
    
    return true
end

-- ============================================
-- MOBILE-OPTIMIZED GUI
-- ============================================

local function CreateTouchGUI()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui
    screen.Name = "InstantCatchGUI"
    screen.DisplayOrder = 999
    
    -- Main Frame (Mobile-friendly)
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 320 * UI_SCALE, 0, 400 * UI_SCALE)
    main.Position = UDim2.new(0.5, -160 * UI_SCALE, 0.5, -200 * UI_SCALE)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    main.BackgroundTransparency = 0.1
    
    -- Rounded corners for mobile
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = main
    
    -- Shadow for mobile
    if IS_MOBILE then
        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 10, 1, 10)
        shadow.Position = UDim2.new(0, -5, 0, -5)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://1316045217"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.7
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(10, 10, 118, 118)
        shadow.Parent = main
    end
    
    main.Parent = screen
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45 * UI_SCALE)
    titleBar.BackgroundColor3 = module_upvr.GetRarityColor("SECRET")
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleBar
    
    titleBar.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Text = IS_MOBILE and "🎣 INSTANT CATCH" or "INSTANT CATCH CHEAT"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(0, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = IS_MOBILE and 20 or 18
    title.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 35 * UI_SCALE, 0, 35 * UI_SCALE)
    closeBtn.Position = UDim2.new(1, -40 * UI_SCALE, 0.5, -17.5 * UI_SCALE)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18 * UI_SCALE
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = closeBtn
    
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
    
    -- Content Scrolling
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -10 * UI_SCALE, 1, -55 * UI_SCALE)
    content.Position = UDim2.new(0, 5 * UI_SCALE, 0, 50 * UI_SCALE)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = IS_MOBILE and 8 or 6
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = main
    
    -- Rarity Selection
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Text = "SELECT RARITY:"
    rarityLabel.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.TextColor3 = Color3.new(1, 1, 1)
    rarityLabel.Font = Enum.Font.GothamBold
    rarityLabel.TextSize = 16 * UI_SCALE
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Parent = content
    
    -- Rarity Buttons Grid
    local rarityGrid = Instance.new("UIGridLayout")
    rarityGrid.CellPadding = UDim2.new(0, 5 * UI_SCALE, 0, 5 * UI_SCALE)
    rarityGrid.CellSize = UDim2.new(0, 70 * UI_SCALE, 0, 40 * UI_SCALE)
    rarityGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local rarities = {
        "SECRET", "LEGENDARY", "EPIC", 
        "RARE", "UNCOMMON", "COMMON"
    }
    
    for _, rarity in pairs(rarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity:sub(1, 3)
        btn.BackgroundColor3 = module_upvr.GetRarityColor(rarity)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14 * UI_SCALE
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.Parent = content
        
        -- Tooltip for mobile
        if IS_MOBILE then
            local tooltip = Instance.new("TextLabel")
            tooltip.Text = rarity
            tooltip.Size = UDim2.new(2, 0, 0, 25)
            tooltip.Position = UDim2.new(0.5, -50, 1, 5)
            tooltip.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            tooltip.TextColor3 = Color3.new(1, 1, 1)
            tooltip.Visible = false
            tooltip.ZIndex = 10
            
            local tipCorner = Instance.new("UICorner")
            tipCorner.CornerRadius = UDim.new(0, 5)
            tipCorner.Parent = tooltip
            
            tooltip.Parent = btn
            
            btn.MouseEnter:Connect(function()
                tooltip.Visible = true
            end)
            
            btn.MouseLeave:Connect(function()
                tooltip.Visible = false
            end)
        end
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = rarity
            print("Rarity set to: " .. rarity)
        end)
    end
    
    rarityGrid.Parent = content
    
    -- Weight Control
    local weightLabel = Instance.new("TextLabel")
    weightLabel.Text = "WEIGHT: " .. CheatConfig.MinWeight .. " - " .. CheatConfig.MaxWeight .. " kg"
    weightLabel.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    weightLabel.BackgroundTransparency = 1
    weightLabel.TextColor3 = Color3.new(1, 1, 1)
    weightLabel.Font = Enum.Font.Gotham
    weightLabel.TextSize = 16 * UI_SCALE
    weightLabel.Parent = content
    
    local weightControls = Instance.new("Frame")
    weightControls.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
    weightControls.BackgroundTransparency = 1
    weightControls.Parent = content
    
    local weightLayout = Instance.new("UIListLayout")
    weightLayout.FillDirection = Enum.FillDirection.Horizontal
    weightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    weightLayout.Padding = UDim.new(0, 20 * UI_SCALE)
    weightLayout.Parent = weightControls
    
    local function UpdateWeightLabel()
        weightLabel.Text = "WEIGHT: " .. CheatConfig.MinWeight .. " - " .. CheatConfig.MaxWeight .. " kg"
    end
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Text = "-50"
    minusBtn.Size = UDim2.new(0, 80 * UI_SCALE, 0, 40 * UI_SCALE)
    minusBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 18 * UI_SCALE
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 10)
    minusCorner.Parent = minusBtn
    
    minusBtn.Parent = weightControls
    
    minusBtn.MouseButton1Click:Connect(function()
        if CheatConfig.MinWeight > 50 then
            CheatConfig.MinWeight = CheatConfig.MinWeight - 50
            CheatConfig.MaxWeight = CheatConfig.MaxWeight - 50
            UpdateWeightLabel()
        end
    end)
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Text = "+50"
    plusBtn.Size = UDim2.new(0, 80 * UI_SCALE, 0, 40 * UI_SCALE)
    plusBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 18 * UI_SCALE
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 10)
    plusCorner.Parent = plusBtn
    
    plusBtn.Parent = weightControls
    
    plusBtn.MouseButton1Click:Connect(function()
        CheatConfig.MinWeight = CheatConfig.MinWeight + 50
        CheatConfig.MaxWeight = CheatConfig.MaxWeight + 50
        UpdateWeightLabel()
    end)
    
    -- Feature Toggles
    local function CreateToggle(text, configKey, yPos)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = content
        
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.Gotham
        label.TextSize = 16 * UI_SCALE
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        local toggle = Instance.new("TextButton")
        toggle.Text = CheatConfig[configKey] and "ON" or "OFF"
        toggle.Size = UDim2.new(0.3, 0, 0.7, 0)
        toggle.Position = UDim2.new(0.65, 0, 0.15, 0)
        toggle.BackgroundColor3 = CheatConfig[configKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        toggle.TextColor3 = Color3.new(1, 1, 1)
        toggle.Font = Enum.Font.GothamBold
        toggle.TextSize = 16 * UI_SCALE
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 10)
        toggleCorner.Parent = toggle
        
        toggle.Parent = toggleFrame
        
        toggle.MouseButton1Click:Connect(function()
            CheatConfig[configKey] = not CheatConfig[configKey]
            toggle.Text = CheatConfig[configKey] and "ON" or "OFF"
            toggle.BackgroundColor3 = CheatConfig[configKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        end)
    end
    
    CreateToggle("INSTANT CATCH", "InstantCatch", 250)
    CreateToggle("AUTO SELL", "AutoSell", 310)
    CreateToggle("AUTO FISH", "AutoFish", 370)
    
    -- Quick Actions
    local quickLabel = Instance.new("TextLabel")
    quickLabel.Text = "QUICK ACTIONS:"
    quickLabel.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    quickLabel.BackgroundTransparency = 1
    quickLabel.TextColor3 = Color3.new(1, 1, 1)
    quickLabel.Font = Enum.Font.GothamBold
    quickLabel.TextSize = 16 * UI_SCALE
    quickLabel.TextXAlignment = Enum.TextXAlignment.Left
    quickLabel.Parent = content
    
    local quickFrame = Instance.new("Frame")
    quickFrame.Size = UDim2.new(1, 0, 0, 60 * UI_SCALE)
    quickFrame.BackgroundTransparency = 1
    quickFrame.Parent = content
    
    local quickLayout = Instance.new("UIListLayout")
    quickLayout.FillDirection = Enum.FillDirection.Horizontal
    quickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    quickLayout.Padding = UDim.new(0, 10 * UI_SCALE)
    quickLayout.Parent = quickFrame
    
    local function CreateQuickButton(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(0, 120 * UI_SCALE, 0, 50 * UI_SCALE)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16 * UI_SCALE
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 12)
        btnCorner.Parent = btn
        
        btn.Parent = quickFrame
        
        btn.MouseButton1Click:Connect(callback)
    end
    
    CreateQuickButton("CATCH NOW", Color3.fromRGB(255, 200, 0), function()
        local fakeFish = CreateFakeFish()
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
        local catchRemote = FishingSystem:FindFirstChild("CatchFish")
        
        if catchRemote then
            catchRemote:FireServer(fakeFish)
            print("Caught: " .. fakeFish.Name .. " (" .. fakeFish.Weight .. "kg)")
        end
    end)
    
    CreateQuickButton("START AUTO", Color3.fromRGB(0, 150, 255), function()
        CheatConfig.AutoFish = not CheatConfig.AutoFish
        print("Auto Fish: " .. (CheatConfig.AutoFish and "ON" or "OFF"))
    end)
    
    -- Draggable for mobile
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Auto-position for mobile safe area
    if IS_MOBILE then
        task.wait(0.1)
        local safeInsets = GuiService:GetSafeInsets()
        main.Position = UDim2.new(0.5, -160 * UI_SCALE, 
                                 0.5, -200 * UI_SCALE + safeInsets.Top)
    end
    
    return screen
end

-- ============================================
-- SIMPLE FLOATING BUTTON (MOBILE MODE)
-- ============================================

local function CreateFloatingButton()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui
    screen.Name = "FloatingFishCheat"
    screen.DisplayOrder = 999
    
    -- Floating Button
    local floatBtn = Instance.new("TextButton")
    floatBtn.Text = "🎣"
    floatBtn.Size = UDim2.new(0, 70 * UI_SCALE, 0, 70 * UI_SCALE)
    floatBtn.Position = UDim2.new(1, -80 * UI_SCALE, 0.5, -35 * UI_SCALE)
    floatBtn.BackgroundColor3 = module_upvr.GetRarityColor("SECRET")
    floatBtn.TextColor3 = Color3.new(0, 0, 0)
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 28 * UI_SCALE
    floatBtn.ZIndex = 100
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 35 * UI_SCALE)
    corner.Parent = floatBtn
    
    floatBtn.Parent = screen
    
    -- Quick Menu (appears on click)
    local quickMenu = Instance.new("Frame")
    quickMenu.Size = UDim2.new(0, 200 * UI_SCALE, 0, 200 * UI_SCALE)
    quickMenu.Position = UDim2.new(1, -210 * UI_SCALE, 0.5, -100 * UI_SCALE)
    quickMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    quickMenu.BackgroundTransparency = 0.1
    quickMenu.Visible = false
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 15)
    menuCorner.Parent = quickMenu
    
    quickMenu.Parent = screen
    
    -- Quick Catch Button
    local quickCatch = Instance.new("TextButton")
    quickCatch.Text = "CATCH SECRET"
    quickCatch.Size = UDim2.new(0.9, 0, 0, 50 * UI_SCALE)
    quickCatch.Position = UDim2.new(0.05, 0, 0.05, 0)
    quickCatch.BackgroundColor3 = module_upvr.GetRarityColor("SECRET")
    quickCatch.TextColor3 = Color3.new(1, 1, 1)
    quickCatch.Font = Enum.Font.GothamBold
    quickCatch.TextSize = 16 * UI_SCALE
    
    local catchCorner = Instance.new("UICorner")
    catchCorner.CornerRadius = UDim.new(0, 10)
    catchCorner.Parent = quickCatch
    
    quickCatch.Parent = quickMenu
    
    quickCatch.MouseButton1Click:Connect(function()
        CheatConfig.SelectedRarity = "SECRET"
        local fakeFish = CreateFakeFish()
        
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
        local catchRemote = FishingSystem:FindFirstChild("CatchFish")
        
        if catchRemote then
            catchRemote:FireServer(fakeFish)
            print("🎣 " .. fakeFish.Name)
        end
        
        quickMenu.Visible = false
    end)
    
    -- Close Menu Button
    local closeMenu = Instance.new("TextButton")
    closeMenu.Text = "✕"
    closeMenu.Size = UDim2.new(0, 30 * UI_SCALE, 0, 30 * UI_SCALE)
    closeMenu.Position = UDim2.new(1, -35 * UI_SCALE, 0, 5 * UI_SCALE)
    closeMenu.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeMenu.TextColor3 = Color3.new(1, 1, 1)
    closeMenu.Font = Enum.Font.GothamBold
    closeMenu.TextSize = 18 * UI_SCALE
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeMenu
    
    closeMenu.Parent = quickMenu
    
    closeMenu.MouseButton1Click:Connect(function()
        quickMenu.Visible = false
    end)
    
    -- Toggle menu visibility
    floatBtn.MouseButton1Click:Connect(function()
        quickMenu.Visible = not quickMenu.Visible
    end)
    
    -- Make float button draggable
    local dragging = false
    local dragStart, startPos
    
    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = floatBtn.Position
        end
    end)
    
    floatBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                         startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return screen
end

-- ============================================
-- AUTO FISHING SYSTEM
-- ============================================

local AutoFishActive = false

local function StartAutoFishing()
    if AutoFishActive then return end
    AutoFishActive = true
    
    task.spawn(function()
        while AutoFishActive do
            task.wait(2) -- Delay between catches
            
            if CheatConfig.InstantCatch then
                local fakeFish = CreateFakeFish()
                local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
                local catchRemote = FishingSystem:FindFirstChild("CatchFish")
                
                if catchRemote then
                    catchRemote:FireServer(fakeFish)
                end
            end
        end
    end)
end

local function StopAutoFishing()
    AutoFishActive = false
end

-- ============================================
-- INITIALIZATION
-- ============================================

print("========================================")
print("   INSTANT CATCH CHEAT v3.0 LOADED")
print("   Platform: " .. (IS_MOBILE and "MOBILE" or IS_CONSOLE and "CONSOLE" or "DESKTOP"))
print("========================================")

-- Wait for game to load
task.wait(2)

-- Setup instant catch
local success = SetupInstantCatch()

if success then
    print("✅ Instant Catch activated!")
    
    -- Create appropriate GUI
    if IS_MOBILE and CheatConfig.SimpleMode then
        CreateFloatingButton()
        print("📱 Simple floating button created")
    else
        CreateTouchGUI()
        print("🎣 Full GUI created")
    end
    
    -- Auto fishing control
    if CheatConfig.AutoFish then
        StartAutoFishing()
        print("🤖 Auto fishing started")
    end
    
else
    warn("❌ Failed to setup instant catch!")
end

-- Export global functions
getgenv().catchFish = function(rarity)
    if rarity then
        CheatConfig.SelectedRarity = rarity:upper()
    end
    
    local fakeFish = CreateFakeFish()
    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
    local catchRemote = FishingSystem:FindFirstChild("CatchFish")
    
    if catchRemote then
        catchRemote:FireServer(fakeFish)
        return fakeFish
    end
    return nil
end

getgenv().setRarity = function(rarity)
    CheatConfig.SelectedRarity = rarity:upper()
    print("Rarity set to: " .. rarity)
end

getgenv().toggleAutoFish = function()
    if AutoFishActive then
        StopAutoFishing()
        print("Auto fishing: OFF")
    else
        StartAutoFishing()
        print("Auto fishing: ON")
    end
end

print("========================================")
print("   COMMANDS AVAILABLE:")
print("   catchFish('SECRET') - Catch fish")
print("   setRarity('LEGENDARY') - Set rarity")
print("   toggleAutoFish() - Toggle auto fish")
print("========================================")
