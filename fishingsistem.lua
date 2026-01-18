-- ============================================
-- MOBILE FISHING CHEAT - Touch Optimized GUI
-- Support semua executor mobile
-- ============================================

-- Auto-detect platform
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Mobile detection
local IS_MOBILE = UserInputService.TouchEnabled
local IS_DESKTOP = not IS_MOBILE

-- Screen info
local screenSize = workspace.CurrentCamera.ViewportSize
local SCREEN_WIDTH = screenSize.X
local SCREEN_HEIGHT = screenSize.Y

-- Mobile optimizations
local UI_SCALE = math.clamp(SCREEN_WIDTH / 400, 0.8, 1.5)
local BUTTON_HEIGHT = 50
local FONT_SIZE = math.floor(16 * UI_SCALE)

-- ============================================
-- CONFIGURASI CHEAT
-- ============================================

local CheatConfig = {
    SelectedRarity = "SECRET",
    MinWeight = 300,
    MaxWeight = 500,
    InstantCatch = true,
    AutoSell = false,
    AutoFish = false,
    NoMinigame = true
}

-- ============================================
-- FUNGSI UTAMA
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
-- HOOK SISTEM FISHING
-- ============================================

local function HookFishingSystem()
    local success, FishingSystem = pcall(function()
        return ReplicatedStorage:WaitForChild("FishingSystem", 5)
    end)
    
    if not success or not FishingSystem then
        print("⚠️ FishingSystem tidak ditemukan")
        return false
    end
    
    -- Cari remote events
    local startRemote = FishingSystem:FindFirstChild("StartFishing") or 
                       FishingSystem:FindFirstChild("BeginFishing")
    
    local catchRemote = FishingSystem:FindFirstChild("CatchFish") or 
                       FishingSystem:FindFirstChild("CompleteFishing")
    
    if not startRemote or not catchRemote then
        print("⚠️ Remote events tidak ditemukan")
        return false
    end
    
    -- Hook untuk instant catch
    local originalFire = startRemote.FireServer
    startRemote.FireServer = function(self, ...)
        local args = {...}
        local result = originalFire(self, unpack(args))
        
        if CheatConfig.InstantCatch then
            task.wait(0.2) -- Delay pendek untuk mobile
            
            local fakeFish = CreateFakeFish()
            pcall(function()
                catchRemote:FireServer(fakeFish)
                print("🎣 " .. fakeFish.Name .. " (" .. fakeFish.Weight .. "kg)")
            end)
            
            -- Auto sell
            if CheatConfig.AutoSell then
                local sellRemote = FishingSystem:FindFirstChild("SellFish")
                if sellRemote then
                    task.wait(0.3)
                    pcall(function()
                        sellRemote:FireServer({fakeFish})
                    end)
                end
            end
        end
        
        return result
    end
    
    return true
end

-- ============================================
-- GUI UTAMA - MOBILE OPTIMIZED
-- ============================================

local function CreateMobileGUI()
    -- ScreenGui utama
    local screen = Instance.new("ScreenGui")
    screen.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    screen.Name = "FishingCheatMobile"
    screen.DisplayOrder = 999
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = IS_MOBILE
    
    -- Container utama
    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(0.85, 0, 0, 450 * UI_SCALE)
    mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    mainContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainContainer.BackgroundTransparency = 0.05
    mainContainer.BorderSizePixel = 0
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = mainContainer
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = mainContainer
    
    mainContainer.Parent = screen
    
    -- Header dengan gradient
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 55 * UI_SCALE)
    header.BackgroundColor3 = Color3.fromRGB(0, 255, 119)
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    header.Parent = mainContainer
    
    -- Judul
    local title = Instance.new("TextLabel")
    title.Text = "🎣 FISHING CHEAT"
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.15, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(0, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24 * UI_SCALE
    title.TextScaled = true
    title.Parent = header
    
    -- Tombol close (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 45 * UI_SCALE, 0, 45 * UI_SCALE)
    closeBtn.Position = UDim2.new(1, -50 * UI_SCALE, 0.5, -22.5 * UI_SCALE)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 22 * UI_SCALE
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeBtn
    
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
    
    -- Konten scrollable
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -65 * UI_SCALE)
    scrollFrame.Position = UDim2.new(0, 5, 0, 60 * UI_SCALE)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = mainContainer
    
    -- Container untuk konten
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = scrollFrame
    
    -- Layout untuk konten
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10 * UI_SCALE)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = content
    
    -- ============================================
    -- SECTION 1: RARITY SELECTION
    -- ============================================
    
    local raritySection = Instance.new("TextLabel")
    raritySection.Text = "📊 PILIH RARITY"
    raritySection.Size = UDim2.new(0.9, 0, 0, 35 * UI_SCALE)
    raritySection.BackgroundTransparency = 1
    raritySection.TextColor3 = Color3.new(1, 1, 1)
    raritySection.Font = Enum.Font.GothamBold
    raritySection.TextSize = FONT_SIZE + 2
    raritySection.TextXAlignment = Enum.TextXAlignment.Left
    raritySection.Parent = content
    
    -- Grid untuk rarity buttons
    local rarityGrid = Instance.new("Frame")
    rarityGrid.Size = UDim2.new(0.9, 0, 0, 120 * UI_SCALE)
    rarityGrid.BackgroundTransparency = 1
    rarityGrid.Parent = content
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellPadding = UDim2.new(0, 5 * UI_SCALE, 0, 5 * UI_SCALE)
    gridLayout.CellSize = UDim2.new(0.3, 0, 0, 50 * UI_SCALE)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.Parent = rarityGrid
    
    local rarities = {
        {name = "SECRET", color = module_upvr.RarityColors.SECRET},
        {name = "LEGENDARY", color = module_upvr.RarityColors.Legendary},
        {name = "EPIC", color = module_upvr.RarityColors.Epic},
        {name = "RARE", color = module_upvr.RarityColors.Rare},
        {name = "UNCOMMON", color = module_upvr.RarityColors.Uncommon},
        {name = "COMMON", color = module_upvr.RarityColors.Common}
    }
    
    local selectedRarityBtn = nil
    
    for _, rarity in pairs(rarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity.name:sub(1, 3)
        btn.BackgroundColor3 = rarity.color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18 * UI_SCALE
        btn.AutoButtonColor = true
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        btn.Parent = rarityGrid
        
        -- Highlight jika selected
        if rarity.name == CheatConfig.SelectedRarity then
            selectedRarityBtn = btn
            btn.BackgroundTransparency = 0
            local highlight = Instance.new("UIStroke")
            highlight.Color = Color3.new(1, 1, 1)
            highlight.Thickness = 2
            highlight.Parent = btn
        else
            btn.BackgroundTransparency = 0.3
        end
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = rarity.name
            
            -- Reset previous selection
            if selectedRarityBtn then
                selectedRarityBtn.BackgroundTransparency = 0.3
                local stroke = selectedRarityBtn:FindFirstChild("UIStroke")
                if stroke then stroke:Destroy() end
            end
            
            -- Set new selection
            selectedRarityBtn = btn
            btn.BackgroundTransparency = 0
            local highlight = Instance.new("UIStroke")
            highlight.Color = Color3.new(1, 1, 1)
            highlight.Thickness = 2
            highlight.Parent = btn
            
            print("Rarity: " .. rarity.name)
        end)
    end
    
    -- ============================================
    -- SECTION 2: WEIGHT CONTROL
    -- ============================================
    
    local weightSection = Instance.new("TextLabel")
    weightSection.Text = "⚖️ BERAT IKAN"
    weightSection.Size = UDim2.new(0.9, 0, 0, 35 * UI_SCALE)
    weightSection.BackgroundTransparency = 1
    weightSection.TextColor3 = Color3.new(1, 1, 1)
    weightSection.Font = Enum.Font.GothamBold
    weightSection.TextSize = FONT_SIZE + 2
    weightSection.TextXAlignment = Enum.TextXAlignment.Left
    weightSection.Parent = content
    
    -- Weight display
    local weightDisplay = Instance.new("TextLabel")
    weightDisplay.Text = CheatConfig.MinWeight .. " - " .. CheatConfig.MaxWeight .. " kg"
    weightDisplay.Size = UDim2.new(0.9, 0, 0, 45 * UI_SCALE)
    weightDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    weightDisplay.TextColor3 = Color3.new(1, 1, 1)
    weightDisplay.Font = Enum.Font.GothamBold
    weightDisplay.TextSize = 20 * UI_SCALE
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 12)
    displayCorner.Parent = weightDisplay
    
    weightDisplay.Parent = content
    
    -- Weight control buttons
    local weightControls = Instance.new("Frame")
    weightControls.Size = UDim2.new(0.9, 0, 0, 55 * UI_SCALE)
    weightControls.BackgroundTransparency = 1
    weightControls.Parent = content
    
    local function UpdateWeightDisplay()
        weightDisplay.Text = CheatConfig.MinWeight .. " - " .. CheatConfig.MaxWeight .. " kg"
    end
    
    -- Minus button
    local minusBtn = Instance.new("TextButton")
    minusBtn.Text = "-50"
    minusBtn.Size = UDim2.new(0.45, 0, 1, 0)
    minusBtn.Position = UDim2.new(0, 0, 0, 0)
    minusBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 22 * UI_SCALE
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 12)
    minusCorner.Parent = minusBtn
    
    minusBtn.Parent = weightControls
    
    minusBtn.MouseButton1Click:Connect(function()
        if CheatConfig.MinWeight > 50 then
            CheatConfig.MinWeight = math.max(1, CheatConfig.MinWeight - 50)
            CheatConfig.MaxWeight = math.max(CheatConfig.MinWeight + 50, CheatConfig.MaxWeight - 50)
            UpdateWeightDisplay()
        end
    end)
    
    -- Plus button
    local plusBtn = Instance.new("TextButton")
    plusBtn.Text = "+50"
    plusBtn.Size = UDim2.new(0.45, 0, 1, 0)
    plusBtn.Position = UDim2.new(0.55, 0, 0, 0)
    plusBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 22 * UI_SCALE
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 12)
    plusCorner.Parent = plusBtn
    
    plusBtn.Parent = weightControls
    
    plusBtn.MouseButton1Click:Connect(function()
        CheatConfig.MinWeight = CheatConfig.MinWeight + 50
        CheatConfig.MaxWeight = CheatConfig.MaxWeight + 50
        UpdateWeightDisplay()
    end)
    
    -- ============================================
    -- SECTION 3: FEATURE TOGGLES
    -- ============================================
    
    local featuresSection = Instance.new("TextLabel")
    featuresSection.Text = "⚙️ FITUR CHEAT"
    featuresSection.Size = UDim2.new(0.9, 0, 0, 35 * UI_SCALE)
    featuresSection.BackgroundTransparency = 1
    featuresSection.TextColor3 = Color3.new(1, 1, 1)
    featuresSection.Font = Enum.Font.GothamBold
    featuresSection.TextSize = FONT_SIZE + 2
    featuresSection.TextXAlignment = Enum.TextXAlignment.Left
    featuresSection.Parent = content
    
    -- Function untuk create toggle
    local function CreateToggle(text, configKey, yPos)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(0.9, 0, 0, 55 * UI_SCALE)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = content
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.Gotham
        label.TextSize = FONT_SIZE
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        -- Toggle button
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Text = CheatConfig[configKey] and "ON" or "OFF"
        toggleBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
        toggleBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
        toggleBtn.BackgroundColor3 = CheatConfig[configKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        toggleBtn.TextColor3 = Color3.new(1, 1, 1)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = FONT_SIZE
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 10)
        toggleCorner.Parent = toggleBtn
        
        toggleBtn.Parent = toggleFrame
        
        toggleBtn.MouseButton1Click:Connect(function()
            CheatConfig[configKey] = not CheatConfig[configKey]
            toggleBtn.Text = CheatConfig[configKey] and "ON" or "OFF"
            toggleBtn.BackgroundColor3 = CheatConfig[configKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
            
            if configKey == "AutoFish" and CheatConfig[configKey] then
                -- Start auto fishing
                task.spawn(function()
                    while CheatConfig.AutoFish do
                        task.wait(2)
                        if CheatConfig.InstantCatch then
                            local fakeFish = CreateFakeFish()
                            local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
                            local catchRemote = FishingSystem:FindFirstChild("CatchFish")
                            
                            if catchRemote then
                                pcall(function()
                                    catchRemote:FireServer(fakeFish)
                                end)
                            end
                        end
                    end
                end)
            end
        end)
        
        return toggleFrame
    end
    
    -- Create toggles
    CreateToggle("Instant Catch", "InstantCatch", 0)
    CreateToggle("Auto Sell", "AutoSell", 1)
    CreateToggle("Auto Fish", "AutoFish", 2)
    CreateToggle("No Minigame", "NoMinigame", 3)
    
    -- ============================================
    -- SECTION 4: QUICK ACTIONS
    -- ============================================
    
    local actionsSection = Instance.new("TextLabel")
    actionsSection.Text = "🚀 AKSI CEPAT"
    actionsSection.Size = UDim2.new(0.9, 0, 0, 35 * UI_SCALE)
    actionsSection.BackgroundTransparency = 1
    actionsSection.TextColor3 = Color3.new(1, 1, 1)
    actionsSection.Font = Enum.Font.GothamBold
    actionsSection.TextSize = FONT_SIZE + 2
    actionsSection.TextXAlignment = Enum.TextXAlignment.Left
    actionsSection.Parent = content
    
    -- Action buttons container
    local actionsContainer = Instance.new("Frame")
    actionsContainer.Size = UDim2.new(0.9, 0, 0, 70 * UI_SCALE)
    actionsContainer.BackgroundTransparency = 1
    actionsContainer.Parent = content
    
    local actionsLayout = Instance.new("UIListLayout")
    actionsLayout.FillDirection = Enum.FillDirection.Horizontal
    actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    actionsLayout.Padding = UDim.new(0, 10 * UI_SCALE)
    actionsLayout.Parent = actionsContainer
    
    -- Catch Now button
    local catchNowBtn = Instance.new("TextButton")
    catchNowBtn.Text = "🎣 CATCH NOW"
    catchNowBtn.Size = UDim2.new(0.45, 0, 1, 0)
    catchNowBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    catchNowBtn.TextColor3 = Color3.new(0, 0, 0)
    catchNowBtn.Font = Enum.Font.GothamBold
    catchNowBtn.TextSize = FONT_SIZE
    
    local catchCorner = Instance.new("UICorner")
    catchCorner.CornerRadius = UDim.new(0, 15)
    catchCorner.Parent = catchNowBtn
    
    catchNowBtn.Parent = actionsContainer
    
    catchNowBtn.MouseButton1Click:Connect(function()
        local fakeFish = CreateFakeFish()
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
        local catchRemote = FishingSystem:FindFirstChild("CatchFish")
        
        if catchRemote then
            pcall(function()
                catchRemote:FireServer(fakeFish)
                print("✅ Caught: " .. fakeFish.Name .. " (" .. fakeFish.Weight .. "kg)")
            end)
        else
            print("❌ Catch remote not found")
        end
    end)
    
    -- Sell All button
    local sellAllBtn = Instance.new("TextButton")
    sellAllBtn.Text = "💰 SELL ALL"
    sellAllBtn.Size = UDim2.new(0.45, 0, 1, 0)
    sellAllBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    sellAllBtn.TextColor3 = Color3.new(1, 1, 1)
    sellAllBtn.Font = Enum.Font.GothamBold
    sellAllBtn.TextSize = FONT_SIZE
    
    local sellCorner = Instance.new("UICorner")
    sellCorner.CornerRadius = UDim.new(0, 15)
    sellCorner.Parent = sellAllBtn
    
    sellAllBtn.Parent = actionsContainer
    
    sellAllBtn.MouseButton1Click:Connect(function()
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
        local sellRemote = FishingSystem:FindFirstChild("SellFish") or 
                          FishingSystem:FindFirstChild("SellAllFish")
        
        if sellRemote then
            pcall(function()
                sellRemote:FireServer("all")
                print("💰 Sold all fish")
            end)
        end
    end)
    
    -- ============================================
    -- SECTION 5: STATUS
    -- ============================================
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0.9, 0, 0, 45 * UI_SCALE)
    statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    statusFrame.Parent = content
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 12)
    statusCorner.Parent = statusFrame
    
    local statusText = Instance.new("TextLabel")
    statusText.Text = "✅ READY - " .. CheatConfig.SelectedRarity
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.fromRGB(0, 255, 119)
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = FONT_SIZE
    statusText.Parent = statusFrame
    
    -- Update status text
    game:GetService("RunService").Heartbeat:Connect(function()
        statusText.Text = "🎣 " .. CheatConfig.SelectedRarity .. 
                         " | " .. CheatConfig.MinWeight .. "-" .. CheatConfig.MaxWeight .. "kg"
    end)
    
    -- ============================================
    -- DRAGGABLE WINDOW FOR MOBILE
    -- ============================================
    
    local dragging = false
    local dragStart, startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
            
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
            mainContainer.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- ============================================
    -- AUTO-POSITION FOR SAFE AREA
    -- ============================================
    
    if IS_MOBILE then
        task.spawn(function()
            task.wait(0.5)
            local safeInsets = GuiService:GetSafeInsets()
            mainContainer.Position = UDim2.new(
                0.5, 0,
                0.5, safeInsets.Top / 2
            )
        end)
    end
    
    return screen
end

-- ============================================
-- SIMPLE FLOATING BUTTON (ALTERNATIVE)
-- ============================================

local function CreateFloatingButton()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    screen.Name = "FishingCheatFAB"
    screen.DisplayOrder = 999
    
    -- Floating Action Button
    local fab = Instance.new("TextButton")
    fab.Text = "🎣"
    fab.Size = UDim2.new(0, 70 * UI_SCALE, 0, 70 * UI_SCALE)
    fab.Position = UDim2.new(1, -80 * UI_SCALE, 0.5, -35 * UI_SCALE)
    fab.BackgroundColor3 = module_upvr.GetRarityColor("SECRET")
    fab.TextColor3 = Color3.new(0, 0, 0)
    fab.Font = Enum.Font.GothamBold
    fab.TextSize = 32 * UI_SCALE
    fab.ZIndex = 999
    
    local fabCorner = Instance.new("UICorner")
    fabCorner.CornerRadius = UDim.new(1, 0)
    fabCorner.Parent = fab
    
    fab.Parent = screen
    
    -- Quick menu
    local quickMenu = Instance.new("Frame")
    quickMenu.Size = UDim2.new(0, 200 * UI_SCALE, 0, 160 * UI_SCALE)
    quickMenu.Position = UDim2.new(1, -210 * UI_SCALE, fab.Position.Y.Scale, fab.Position.Y.Offset - 80 * UI_SCALE)
    quickMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    quickMenu.BackgroundTransparency = 0.1
    quickMenu.Visible = false
    quickMenu.ZIndex = 998
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 15)
    menuCorner.Parent = quickMenu
    
    quickMenu.Parent = screen
    
    -- Menu items
    local menuItems = {
        {text = "CATCH SECRET", color = module_upvr.GetRarityColor("SECRET"), rarity = "SECRET"},
        {text = "CATCH LEGENDARY", color = module_upvr.GetRarityColor("Legendary"), rarity = "LEGENDARY"},
        {text = "AUTO FISH: OFF", color = Color3.fromRGB(0, 150, 255)},
        {text = "CLOSE", color = Color3.fromRGB(255, 60, 60)}
    }
    
    for i, item in ipairs(menuItems) do
        local btn = Instance.new("TextButton")
        btn.Text = item.text
        btn.Size = UDim2.new(0.9, 0, 0, 35 * UI_SCALE)
        btn.Position = UDim2.new(0.05, 0, 0, (i-1) * 40 * UI_SCALE + 10)
        btn.BackgroundColor3 = item.color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14 * UI_SCALE
        btn.ZIndex = 999
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
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
            elseif item.text:find("AUTO FISH") then
                CheatConfig.AutoFish = not CheatConfig.AutoFish
                btn.Text = CheatConfig.AutoFish and "AUTO FISH: ON" or "AUTO FISH: OFF"
            elseif item.text == "CLOSE" then
                quickMenu.Visible = false
            end
        end)
    end
    
    -- Toggle menu
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
            
            -- Update menu position
            quickMenu.Position = UDim2.new(
                1, -210 * UI_SCALE,
                fab.Position.Y.Scale,
                fab.Position.Y.Offset - 80 * UI_SCALE
            )
        end
    end)
    
    return screen
end

-- ============================================
-- INITIALIZATION
-- ============================================

print("========================================")
print("   MOBILE FISHING CHEAT v1.0")
print("   Optimized for Mobile Executors")
print("========================================")

-- Tunggu game load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Hook fishing system
local hookSuccess = HookFishingSystem()

if hookSuccess then
    print("✅ Fishing system hooked successfully!")
    
    -- Pilih GUI type
    if IS_MOBILE then
        -- Untuk mobile, pilih salah satu:
        
        -- 1. Full GUI (recommended)
        CreateMobileGUI()
        print("📱 Full mobile GUI created")
        
        -- ATAU 2. Simple floating button
        -- CreateFloatingButton()
        -- print("📱 Floating button created")
    else
        CreateMobileGUI()
        print("💻 Desktop GUI created")
    end
    
else
    warn("❌ Failed to hook fishing system")
    -- Buat GUI anyway untuk manual catch
    if IS_MOBILE then
        CreateMobileGUI()
    else
        CreateMobileGUI()
    end
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

getgenv().setWeight = function(min, max)
    CheatConfig.MinWeight = min
    CheatConfig.MaxWeight = max
    print("Weight set to: " .. min .. "-" .. max .. "kg")
end

print("========================================")
print("   COMMANDS:")
print("   catchFish('SECRET')")
print("   setRarity('LEGENDARY')")
print("   setWeight(300, 500)")
print("========================================")
