-- ============================================
-- INSTANT CATCH CHEAT - MOBILE GUI FIXED
-- Optimized untuk layar mobile
-- ============================================

-- Platform detection
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Mobile detection
local IS_MOBILE = UserInputService.TouchEnabled
local IS_DESKTOP = not IS_MOBILE

-- Screen dimensions
local screenSize = workspace.CurrentCamera.ViewportSize
local SCREEN_WIDTH = screenSize.X
local SCREEN_HEIGHT = screenSize.Y

-- Mobile optimizations
local UI_SCALE = IS_MOBILE and math.min(1.2, SCREEN_WIDTH / 500) or 1
local BUTTON_HEIGHT = IS_MOBILE and 50 or 40
local FONT_SIZE = IS_MOBILE and 18 or 16

-- ============================================
-- CONFIGURATION
-- ============================================

local CheatConfig = {
    SelectedRarity = "SECRET",
    MinWeight = 300,
    MaxWeight = 500,
    InstantCatch = true,
    AutoSell = false,
    AutoFish = false
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
    if not FishingSystem then 
        print("❌ FishingSystem tidak ditemukan")
        return false 
    end
    
    local remotes = {}
    for _, child in pairs(FishingSystem:GetChildren()) do
        if child:IsA("RemoteEvent") then
            remotes[child.Name] = child
        end
    end
    
    local startRemote = remotes["StartFishing"] or remotes["BeginFishing"]
    if startRemote then
        local originalFire = startRemote.FireServer
        startRemote.FireServer = function(self, ...)
            local result = originalFire(self, ...)
            
            if CheatConfig.InstantCatch then
                task.wait(0.3)
                
                local catchRemote = remotes["CatchFish"] or remotes["CompleteFishing"]
                if catchRemote then
                    local fakeFish = CreateFakeFish()
                    catchRemote:FireServer(fakeFish)
                    
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
        return true
    end
    return false
end

-- ============================================
-- FIXED MOBILE GUI
-- ============================================

local function CreateMobileGUI()
    -- Create ScreenGui
    local screen = Instance.new("ScreenGui")
    screen.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    screen.Name = "MobileFishCheat"
    screen.DisplayOrder = 999
    screen.ResetOnSpawn = false
    
    -- Main Container - Mobile optimized size
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0.9, 0, 0, 450 * UI_SCALE) -- 90% width, fixed height
    main.Position = UDim2.new(0.05, 0, 0.5, -225 * UI_SCALE) -- Center vertically
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = main
    
    -- Shadow effect
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
    
    main.Parent = screen
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
    titleBar.BackgroundColor3 = module_upvr.GetRarityColor("SECRET")
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 20)
    titleCorner.Parent = titleBar
    
    titleBar.Parent = main
    
    -- Title Text
    local title = Instance.new("TextLabel")
    title.Text = "🎣 INSTANT CATCH"
    title.Size = UDim2.new(0.8, 0, 1, 0)
    title.Position = UDim2.new(0.1, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(0, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22 * UI_SCALE
    title.TextScaled = IS_MOBILE
    title.Parent = titleBar
    
    -- Close Button (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 40 * UI_SCALE, 0, 40 * UI_SCALE)
    closeBtn.Position = UDim2.new(1, -45 * UI_SCALE, 0.5, -20 * UI_SCALE)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20 * UI_SCALE
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = closeBtn
    
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
    
    -- Content Scrolling Frame
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -10, 1, -60 * UI_SCALE)
    content.Position = UDim2.new(0, 5, 0, 55 * UI_SCALE)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 8
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = main
    
    -- Rarity Selection Section
    local raritySection = Instance.new("TextLabel")
    raritySection.Text = "SELECT RARITY:"
    raritySection.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    raritySection.BackgroundTransparency = 1
    raritySection.TextColor3 = Color3.new(1, 1, 1)
    raritySection.Font = Enum.Font.GothamBold
    raritySection.TextSize = FONT_SIZE
    raritySection.TextXAlignment = Enum.TextXAlignment.Left
    raritySection.Parent = content
    
    -- Rarity Buttons Grid
    local rarityGrid = Instance.new("Frame")
    rarityGrid.Size = UDim2.new(1, 0, 0, 100 * UI_SCALE)
    rarityGrid.BackgroundTransparency = 1
    rarityGrid.Parent = content
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellPadding = UDim2.new(0, 5 * UI_SCALE, 0, 5 * UI_SCALE)
    gridLayout.CellSize = UDim2.new(0.3, 0, 0, 40 * UI_SCALE)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.Parent = rarityGrid
    
    local rarities = {"SECRET", "LEGENDARY", "EPIC", "RARE", "UNCOMMON", "COMMON"}
    
    for _, rarity in pairs(rarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity:sub(1, 3)
        btn.BackgroundColor3 = module_upvr.GetRarityColor(rarity)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16 * UI_SCALE
        btn.AutoButtonColor = true
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.Parent = rarityGrid
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = rarity
            print("Selected: " .. rarity)
        end)
    end
    
    -- Weight Control Section
    local weightSection = Instance.new("TextLabel")
    weightSection.Text = "FISH WEIGHT:"
    weightSection.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    weightSection.Position = UDim2.new(0, 0, 0, 110 * UI_SCALE)
    weightSection.BackgroundTransparency = 1
    weightSection.TextColor3 = Color3.new(1, 1, 1)
    weightSection.Font = Enum.Font.GothamBold
    weightSection.TextSize = FONT_SIZE
    weightSection.TextXAlignment = Enum.TextXAlignment.Left
    weightSection.Parent = content
    
    -- Weight Display
    local weightDisplay = Instance.new("TextLabel")
    weightDisplay.Text = CheatConfig.MinWeight .. " - " .. CheatConfig.MaxWeight .. " kg"
    weightDisplay.Size = UDim2.new(1, 0, 0, 40 * UI_SCALE)
    weightDisplay.Position = UDim2.new(0, 0, 0, 140 * UI_SCALE)
    weightDisplay.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    weightDisplay.TextColor3 = Color3.new(1, 1, 1)
    weightDisplay.Font = Enum.Font.GothamBold
    weightDisplay.TextSize = 18 * UI_SCALE
    weightDisplay.TextScaled = true
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 10)
    displayCorner.Parent = weightDisplay
    
    weightDisplay.Parent = content
    
    -- Weight Control Buttons
    local weightControls = Instance.new("Frame")
    weightControls.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
    weightControls.Position = UDim2.new(0, 0, 0, 190 * UI_SCALE)
    weightControls.BackgroundTransparency = 1
    weightControls.Parent = content
    
    local function UpdateWeightLabel()
        weightDisplay.Text = CheatConfig.MinWeight .. " - " .. CheatConfig.MaxWeight .. " kg"
    end
    
    -- Minus Button
    local minusBtn = Instance.new("TextButton")
    minusBtn.Text = "-50"
    minusBtn.Size = UDim2.new(0.4, 0, 1, 0)
    minusBtn.Position = UDim2.new(0.05, 0, 0, 0)
    minusBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 20 * UI_SCALE
    
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
    
    -- Plus Button
    local plusBtn = Instance.new("TextButton")
    plusBtn.Text = "+50"
    plusBtn.Size = UDim2.new(0.4, 0, 1, 0)
    plusBtn.Position = UDim2.new(0.55, 0, 0, 0)
    plusBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 20 * UI_SCALE
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 10)
    plusCorner.Parent = plusBtn
    
    plusBtn.Parent = weightControls
    
    plusBtn.MouseButton1Click:Connect(function()
        CheatConfig.MinWeight = CheatConfig.MinWeight + 50
        CheatConfig.MaxWeight = CheatConfig.MaxWeight + 50
        UpdateWeightLabel()
    end)
    
    -- Features Section
    local featuresSection = Instance.new("TextLabel")
    featuresSection.Text = "FEATURES:"
    featuresSection.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    featuresSection.Position = UDim2.new(0, 0, 0, 250 * UI_SCALE)
    featuresSection.BackgroundTransparency = 1
    featuresSection.TextColor3 = Color3.new(1, 1, 1)
    featuresSection.Font = Enum.Font.GothamBold
    featuresSection.TextSize = FONT_SIZE
    featuresSection.TextXAlignment = Enum.TextXAlignment.Left
    featuresSection.Parent = content
    
    -- Feature Toggles
    local function CreateFeatureToggle(text, configKey, yOffset)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
        toggleFrame.Position = UDim2.new(0, 0, 0, yOffset)
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
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Text = CheatConfig[configKey] and "ON" or "OFF"
        toggleBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
        toggleBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
        toggleBtn.BackgroundColor3 = CheatConfig[configKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        toggleBtn.TextColor3 = Color3.new(1, 1, 1)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 16 * UI_SCALE
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 10)
        toggleCorner.Parent = toggleBtn
        
        toggleBtn.Parent = toggleFrame
        
        toggleBtn.MouseButton1Click:Connect(function()
            CheatConfig[configKey] = not CheatConfig[configKey]
            toggleBtn.Text = CheatConfig[configKey] and "ON" or "OFF"
            toggleBtn.BackgroundColor3 = CheatConfig[configKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        end)
        
        return toggleFrame
    end
    
    CreateFeatureToggle("INSTANT CATCH", "InstantCatch", 280 * UI_SCALE)
    CreateFeatureToggle("AUTO SELL", "AutoSell", 340 * UI_SCALE)
    CreateFeatureToggle("AUTO FISH", "AutoFish", 400 * UI_SCALE)
    
    -- Quick Actions Section
    local actionsSection = Instance.new("TextLabel")
    actionsSection.Text = "QUICK ACTIONS:"
    actionsSection.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    actionsSection.Position = UDim2.new(0, 0, 0, 470 * UI_SCALE)
    actionsSection.BackgroundTransparency = 1
    actionsSection.TextColor3 = Color3.new(1, 1, 1)
    actionsSection.Font = Enum.Font.GothamBold
    actionsSection.TextSize = FONT_SIZE
    actionsSection.TextXAlignment = Enum.TextXAlignment.Left
    actionsSection.Parent = content
    
    -- Quick Action Buttons
    local actionsFrame = Instance.new("Frame")
    actionsFrame.Size = UDim2.new(1, 0, 0, 60 * UI_SCALE)
    actionsFrame.Position = UDim2.new(0, 0, 0, 500 * UI_SCALE)
    actionsFrame.BackgroundTransparency = 1
    actionsFrame.Parent = content
    
    local actionsLayout = Instance.new("UIListLayout")
    actionsLayout.FillDirection = Enum.FillDirection.Horizontal
    actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    actionsLayout.Padding = UDim.new(0, 10 * UI_SCALE)
    actionsLayout.Parent = actionsFrame
    
    -- Catch Now Button
    local catchBtn = Instance.new("TextButton")
    catchBtn.Text = "CATCH NOW"
    catchBtn.Size = UDim2.new(0.45, 0, 1, 0)
    catchBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    catchBtn.TextColor3 = Color3.new(0, 0, 0)
    catchBtn.Font = Enum.Font.GothamBold
    catchBtn.TextSize = 16 * UI_SCALE
    
    local catchCorner = Instance.new("UICorner")
    catchCorner.CornerRadius = UDim.new(0, 12)
    catchCorner.Parent = catchBtn
    
    catchBtn.Parent = actionsFrame
    
    catchBtn.MouseButton1Click:Connect(function()
        local fakeFish = CreateFakeFish()
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
        local catchRemote = FishingSystem:FindFirstChild("CatchFish")
        
        if catchRemote then
            catchRemote:FireServer(fakeFish)
            print("🎣 " .. fakeFish.Name .. " (" .. fakeFish.Weight .. "kg)")
        end
    end)
    
    -- Toggle Auto Button
    local autoBtn = Instance.new("TextButton")
    autoBtn.Text = "TOGGLE AUTO"
    autoBtn.Size = UDim2.new(0.45, 0, 1, 0)
    autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    autoBtn.TextColor3 = Color3.new(1, 1, 1)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 16 * UI_SCALE
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 12)
    autoCorner.Parent = autoBtn
    
    autoBtn.Parent = actionsFrame
    
    local autoFishing = false
    autoBtn.MouseButton1Click:Connect(function()
        autoFishing = not autoFishing
        autoBtn.Text = autoFishing and "STOP AUTO" or "TOGGLE AUTO"
        autoBtn.BackgroundColor3 = autoFishing and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(0, 150, 255)
        
        if autoFishing then
            -- Start auto fishing
            task.spawn(function()
                while autoFishing do
                    task.wait(2)
                    local fakeFish = CreateFakeFish()
                    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
                    local catchRemote = FishingSystem:FindFirstChild("CatchFish")
                    
                    if catchRemote then
                        catchRemote:FireServer(fakeFish)
                    end
                end
            end)
        end
    end)
    
    -- Make GUI draggable
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
            main.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Adjust for safe area on mobile
    if IS_MOBILE then
        task.wait(0.5)
        local safeInsets = GuiService:GetSafeInsets()
        main.Position = UDim2.new(0.05, 0, 0.5, -225 * UI_SCALE + safeInsets.Top)
    end
    
    return screen
end

-- ============================================
-- SIMPLE FLOATING BUTTON (Alternative)
-- ============================================

local function CreateSimpleMobileGUI()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    screen.Name = "SimpleFishCheat"
    screen.DisplayOrder = 999
    
    -- Floating Action Button
    local fab = Instance.new("TextButton")
    fab.Text = "🎣"
    fab.Size = UDim2.new(0, 70 * UI_SCALE, 0, 70 * UI_SCALE)
    fab.Position = UDim2.new(1, -80 * UI_SCALE, 0.5, -35 * UI_SCALE)
    fab.BackgroundColor3 = module_upvr.GetRarityColor("SECRET")
    fab.TextColor3 = Color3.new(0, 0, 0)
    fab.Font = Enum.Font.GothamBold
    fab.TextSize = 30 * UI_SCALE
    fab.ZIndex = 999
    
    local fabCorner = Instance.new("UICorner")
    fabCorner.CornerRadius = UDim.new(0.5, 0)
    fabCorner.Parent = fab
    
    -- Shadow
    local fabShadow = Instance.new("ImageLabel")
    fabShadow.Size = UDim2.new(1, 10, 1, 10)
    fabShadow.Position = UDim2.new(0, -5, 0, -5)
    fabShadow.BackgroundTransparency = 1
    fabShadow.Image = "rbxassetid://1316045217"
    fabShadow.ImageColor3 = Color3.new(0, 0, 0)
    fabShadow.ImageTransparency = 0.5
    fabShadow.ScaleType = Enum.ScaleType.Slice
    fabShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    fabShadow.Parent = fab
    
    fab.Parent = screen
    
    -- Quick Menu (appears when FAB is clicked)
    local quickMenu = Instance.new("Frame")
    quickMenu.Size = UDim2.new(0, 180 * UI_SCALE, 0, 150 * UI_SCALE)
    quickMenu.Position = UDim2.new(1, -190 * UI_SCALE, 0.5, -75 * UI_SCALE)
    quickMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    quickMenu.BackgroundTransparency = 0.1
    quickMenu.Visible = false
    quickMenu.ZIndex = 998
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 15)
    menuCorner.Parent = quickMenu
    
    quickMenu.Parent = screen
    
    -- Menu Items
    local menuItems = {
        {text = "CATCH SECRET", color = module_upvr.GetRarityColor("SECRET"), rarity = "SECRET"},
        {text = "CATCH LEGENDARY", color = module_upvr.GetRarityColor("Legendary"), rarity = "LEGENDARY"},
        {text = "TOGGLE AUTO", color = Color3.fromRGB(0, 150, 255)},
        {text = "CLOSE", color = Color3.fromRGB(255, 60, 60)}
    }
    
    for i, item in ipairs(menuItems) do
        local btn = Instance.new("TextButton")
        btn.Text = item.text
        btn.Size = UDim2.new(0.9, 0, 0, 30 * UI_SCALE)
        btn.Position = UDim2.new(0.05, 0, 0, (i-1) * 35 * UI_SCALE + 10)
        btn.BackgroundColor3 = item.color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14 * UI_SCALE
        btn.ZIndex = 999
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.Parent = quickMenu
        
        btn.MouseButton1Click:Connect(function()
            if item.rarity then
                CheatConfig.SelectedRarity = item.rarity
                local fakeFish = CreateFakeFish()
                local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
                local catchRemote = FishingSystem:FindFirstChild("CatchFish")
                
                if catchRemote then
                    catchRemote:FireServer(fakeFish)
                end
            elseif item.text == "TOGGLE AUTO" then
                CheatConfig.AutoFish = not CheatConfig.AutoFish
                btn.Text = CheatConfig.AutoFish and "AUTO: ON" or "TOGGLE AUTO"
            elseif item.text == "CLOSE" then
                quickMenu.Visible = false
            end
            
            quickMenu.Visible = false
        end)
    end
    
    -- Toggle menu visibility
    fab.MouseButton1Click:Connect(function()
        quickMenu.Visible = not quickMenu.Visible
    end)
    
    -- Make FAB draggable
    local fabDragging = false
    local fabDragStart, fabStartPos
    
    fab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            fabDragging = true
            fabDragStart = input.Position
            fabStartPos = fab.Position
        end
    end)
    
    fab.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            fabDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if fabDragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - fabDragStart
            fab.Position = UDim2.new(
                fabStartPos.X.Scale, 
                fabStartPos.X.Offset + delta.X,
                fabStartPos.Y.Scale, 
                fabStartPos.Y.Offset + delta.Y
            )
            
            -- Update menu position relative to FAB
            quickMenu.Position = UDim2.new(
                1, -190 * UI_SCALE,
                fab.Position.Y.Scale,
                fab.Position.Y.Offset - 75 * UI_SCALE
            )
        end
    end)
    
    return screen
end

-- ============================================
-- INITIALIZATION
-- ============================================

print("========================================")
print("   INSTANT CATCH CHEAT - MOBILE FIXED")
print("   Platform: " .. (IS_MOBILE and "MOBILE" or "DESKTOP"))
print("========================================")

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Setup instant catch
local success = SetupInstantCatch()

if success then
    print("✅ Instant Catch activated!")
    
    -- Create GUI based on preference
    if IS_MOBILE then
        -- You can choose which GUI to use:
        -- 1. Full GUI with all features
        CreateMobileGUI()
        print("📱 Full Mobile GUI created")
        
        -- OR 2. Simple floating button
        -- CreateSimpleMobileGUI()
        -- print("📱 Simple floating button created")
    else
        CreateMobileGUI()
        print("💻 Desktop GUI created")
    end
    
else
    warn("❌ Failed to setup instant catch!")
end

-- Global functions
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

print("========================================")
print("   Ready to use!")
print("========================================")
