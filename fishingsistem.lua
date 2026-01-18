-- ============================================
-- MOBILE FISHING CHEAT v2.0
-- Support Touch & Mobile Controls
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- ============================================
-- MOBILE DETECTION & ADAPTATION
-- ============================================

local IS_MOBILE = UserInputService.TouchEnabled
local IS_CONSOLE = UserInputService.GamepadEnabled
local IS_DESKTOP = not IS_MOBILE and not IS_CONSOLE

-- Adjust for mobile screen
local SCREEN_SIZE = workspace.CurrentCamera.ViewportSize
local UI_SCALE = IS_MOBILE and 1.5 or 1

-- ============================================
-- KONFIGURASI CHEAT - TOUCH OPTIMIZED
-- ============================================

local CheatConfig = {
    -- Pilih rarity yang mau di-catch
    SelectedRarity = "SECRET",
    
    -- Atur weight fish (mobile-friendly ranges)
    MinWeight = 300,
    MaxWeight = 500,
    
    -- Auto settings
    AutoFish = false,
    AutoSell = false,
    InstantCatch = true,
    
    -- Mobile optimizations
    TouchMode = true,
    LargeButtons = true,
    Vibration = false,
    SimpleMode = true
}

-- ============================================
-- FUNGSI UTAMA - MOBILE COMPATIBLE
-- ============================================

local function GetRandomFishByRarity(rarity)
    local fishList = {}
    
    for _, fish in pairs(module_upvr.FishTable) do
        if fish.rarity == rarity then
            table.insert(fishList, fish)
        end
    end
    
    if #fishList > 0 then
        return fishList[math.random(1, #fishList)]
    end
    
    -- Fallback
    for _, fish in pairs(module_upvr.FishTable) do
        if fish.rarity == "Common" then
            table.insert(fishList, fish)
        end
    end
    
    return fishList[math.random(1, #fishList)]
end

local function GenerateFakeFishData()
    local targetFish = GetRandomFishByRarity(CheatConfig.SelectedRarity)
    local weight = math.random(CheatConfig.MinWeight * 10, CheatConfig.MaxWeight * 10) / 10
    local price = module_upvr.CalculateFishPrice(weight, CheatConfig.SelectedRarity)
    
    return {
        Name = targetFish.name,
        Weight = weight,
        Rarity = CheatConfig.SelectedRarity,
        Price = price,
        Timestamp = os.time()
    }
end

-- ============================================
-- VIBRATION FEATURE (MOBILE ONLY)
-- ============================================

local function Vibrate(duration)
    if IS_MOBILE and CheatConfig.Vibration then
        pcall(function()
            -- Try to simulate vibration
            for i = 1, duration * 10 do
                task.wait(0.1)
            end
        end)
    end
end

-- ============================================
-- HOOK REMOTE FUNCTION - MOBILE SAFE
-- ============================================

local function HookFishingSystem()
    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 10)
    
    if not FishingSystem then
        if IS_MOBILE then
            warn("⚠️ FishingSystem tidak ditemukan!")
        else
            warn("[CHEAT] FishingSystem tidak ditemukan!")
        end
        return false
    end
    
    -- Cari remote events dengan nama yang umum
    local remoteNames = {"StartFishing", "StartFish", "BeginFishing", "FishStart"}
    local CatchNames = {"CatchFish", "CompleteFishing", "FinishFishing", "FishCatch"}
    
    local StartFishingRemote
    local CatchFishRemote
    
    for _, name in pairs(remoteNames) do
        local remote = FishingSystem:FindFirstChild(name)
        if remote then
            StartFishingRemote = remote
            break
        end
    end
    
    for _, name in pairs(CatchNames) do
        local remote = FishingSystem:FindFirstChild(name)
        if remote then
            CatchFishRemote = remote
            break
        end
    end
    
    if not StartFishingRemote or not CatchFishRemote then
        warn("⚠️ Remote events tidak ditemukan!")
        return false
    end
    
    -- Hook StartFishing untuk instant catch
    local originalStart = StartFishingRemote.FireServer
    StartFishingRemote.FireServer = function(self, ...)
        local args = {...}
        
        originalStart(self, unpack(args))
        
        if CheatConfig.InstantCatch then
            task.wait(0.3) -- Shorter delay for mobile
            
            local fakeFish = GenerateFakeFishData()
            
            pcall(function()
                CatchFishRemote:FireServer(fakeFish)
            end)
            
            -- Mobile-friendly notification
            if IS_MOBILE then
                print(string.format("🎣 %s (%.1fkg)", fakeFish.Name, fakeFish.Weight))
            else
                print(string.format("[CHEAT] Caught: %s | Weight: %.1fkg", fakeFish.Name, fakeFish.Weight))
            end
            
            Vibrate(0.2)
            
            -- Auto sell jika aktif
            if CheatConfig.AutoSell then
                local SellRemote = FishingSystem:FindFirstChild("SellFish") or 
                                  FishingSystem:FindFirstChild("SellAllFish")
                
                if SellRemote then
                    task.wait(0.5)
                    pcall(function()
                        SellRemote:FireServer({fakeFish})
                    end)
                end
            end
        end
        
        return nil
    end
    
    return true
end

-- ============================================
-- MOBILE-FRIENDLY GUI
-- ============================================

local function CreateMobileGUI()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui
    screen.Name = "MobileFishingCheat"
    screen.DisplayOrder = 999
    
    -- Main Container (Responsive)
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300 * UI_SCALE, 0, 400 * UI_SCALE)
    main.Position = UDim2.new(0.5, -150 * UI_SCALE, 0.5, -200 * UI_SCALE)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.BackgroundTransparency = 0.1
    main.BorderSizePixel = 0
    
    -- Mobile rounded corners
    if IS_MOBILE then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = main
    end
    
    -- Shadow effect for mobile
    if IS_MOBILE then
        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 10, 1, 10)
        shadow.Position = UDim2.new(0, -5, 0, -5)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://1316045217"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.8
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(10, 10, 118, 118)
        shadow.Parent = main
        main.ZIndex = 2
        shadow.ZIndex = 1
    end
    
    main.Parent = screen
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40 * UI_SCALE)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 255, 119)
    titleBar.Parent = main
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = IS_MOBILE and UDim.new(0, 15) or UDim.new(0, 0)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Text = IS_MOBILE and "🎣 FISHING CHEAT" or "FISHING CHEAT v2.0"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(0, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = IS_MOBILE and 18 or 16
    title.Parent = titleBar
    
    -- Draggable for mobile
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function UpdateInput(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            UpdateInput(input)
        end
    end)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30 * UI_SCALE, 0, 30 * UI_SCALE)
    closeBtn.Position = UDim2.new(1, -35 * UI_SCALE, 0, 5 * UI_SCALE)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = IS_MOBILE and 20 or 16
    
    if IS_MOBILE then
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 15)
        btnCorner.Parent = closeBtn
    end
    
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
    
    -- Content Container
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -10 * UI_SCALE, 1, -50 * UI_SCALE)
    content.Position = UDim2.new(0, 5 * UI_SCALE, 0, 45 * UI_SCALE)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = IS_MOBILE and 8 or 6
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = main
    
    -- Rarity Selection
    local raritySection = Instance.new("TextLabel")
    raritySection.Text = "PILIH RARITY:"
    raritySection.Size = UDim2.new(1, 0, 0, 25 * UI_SCALE)
    raritySection.BackgroundTransparency = 1
    raritySection.TextColor3 = Color3.new(1, 1, 1)
    raritySection.Font = Enum.Font.Gotham
    raritySection.TextSize = IS_MOBILE and 16 or 14
    raritySection.TextXAlignment = Enum.TextXAlignment.Left
    raritySection.Parent = content
    
    local rarityButtonsFrame = Instance.new("Frame")
    rarityButtonsFrame.Size = UDim2.new(1, 0, 0, 40 * UI_SCALE)
    rarityButtonsFrame.BackgroundTransparency = 1
    rarityButtonsFrame.LayoutOrder = 1
    rarityButtonsFrame.Parent = content
    
    local rarityListLayout = Instance.new("UIListLayout")
    rarityListLayout.FillDirection = Enum.FillDirection.Horizontal
    rarityListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    rarityListLayout.Padding = UDim.new(0, 5 * UI_SCALE)
    rarityListLayout.Parent = rarityButtonsFrame
    
    local rarities = {
        {name = "SECRET", color = module_upvr.RarityColors.SECRET},
        {name = "LEGENDARY", color = module_upvr.RarityColors.Legendary},
        {name = "EPIC", color = module_upvr.RarityColors.Epic},
        {name = "RARE", color = module_upvr.RarityColors.Rare},
        {name = "UNCOMMON", color = module_upvr.RarityColors.Uncommon},
        {name = "COMMON", color = module_upvr.RarityColors.Common}
    }
    
    local rarityButtons = {}
    
    for i, rarity in ipairs(rarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity.name:sub(1, 3)
        btn.Size = UDim2.new(0, 40 * UI_SCALE, 0, 40 * UI_SCALE)
        btn.BackgroundColor3 = rarity.color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = IS_MOBILE and 14 or 12
        
        if IS_MOBILE then
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn
        end
        
        btn.Parent = rarityButtonsFrame
        
        -- Tooltip untuk mobile
        if IS_MOBILE then
            local tooltip = Instance.new("TextLabel")
            tooltip.Text = rarity.name
            tooltip.Size = UDim2.new(2, 0, 0, 20)
            tooltip.Position = UDim2.new(0.5, -40, 1, 5)
            tooltip.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            tooltip.TextColor3 = Color3.new(1, 1, 1)
            tooltip.Visible = false
            tooltip.ZIndex = 10
            
            if IS_MOBILE then
                local tipCorner = Instance.new("UICorner")
                tipCorner.CornerRadius = UDim.new(0, 5)
                tipCorner.Parent = tooltip
            end
            
            tooltip.Parent = btn
            
            btn.MouseEnter:Connect(function()
                tooltip.Visible = true
            end)
            
            btn.MouseLeave:Connect(function()
                tooltip.Visible = false
            end)
        end
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = rarity.name:upper()
            
            -- Update semua button states
            for _, otherBtn in pairs(rarityButtons) do
                otherBtn.BackgroundTransparency = 0.5
            end
            btn.BackgroundTransparency = 0
            
            Vibrate(0.1)
        end)
        
        rarityButtons[i] = btn
        
        -- Set selected button
        if rarity.name == CheatConfig.SelectedRarity then
            btn.BackgroundTransparency = 0
        else
            btn.BackgroundTransparency = 0.5
        end
    end
    
    -- Weight Control
    local weightSection = Instance.new("TextLabel")
    weightSection.Text = "BERAT IKAN (kg):"
    weightSection.Size = UDim2.new(1, 0, 0, 25 * UI_SCALE)
    weightSection.Position = UDim2.new(0, 0, 0, 50 * UI_SCALE)
    weightSection.BackgroundTransparency = 1
    weightSection.TextColor3 = Color3.new(1, 1, 1)
    weightSection.Font = Enum.Font.Gotham
    weightSection.TextSize = IS_MOBILE and 16 or 14
    weightSection.TextXAlignment = Enum.TextXAlignment.Left
    weightSection.LayoutOrder = 2
    weightSection.Parent = content
    
    local weightDisplay = Instance.new("TextLabel")
    weightDisplay.Text = string.format("%d - %d kg", CheatConfig.MinWeight, CheatConfig.MaxWeight)
    weightDisplay.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    weightDisplay.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    weightDisplay.TextColor3 = Color3.new(1, 1, 1)
    weightDisplay.Font = Enum.Font.GothamBold
    weightDisplay.TextSize = IS_MOBILE and 18 or 16
    weightDisplay.LayoutOrder = 3
    
    if IS_MOBILE then
        local displayCorner = Instance.new("UICorner")
        displayCorner.CornerRadius = UDim.new(0, 10)
        displayCorner.Parent = weightDisplay
    end
    
    weightDisplay.Parent = content
    
    local weightControls = Instance.new("Frame")
    weightControls.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
    weightControls.BackgroundTransparency = 1
    weightControls.LayoutOrder = 4
    weightControls.Parent = content
    
    local weightLayout = Instance.new("UIListLayout")
    weightLayout.FillDirection = Enum.FillDirection.Horizontal
    weightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    weightLayout.Padding = UDim.new(0, 20 * UI_SCALE)
    weightLayout.Parent = weightControls
    
    local function CreateWeightButton(text, color, offset)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(0, 60 * UI_SCALE, 0, 50 * UI_SCALE)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = IS_MOBILE and 24 or 20
        
        if IS_MOBILE then
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 15)
            btnCorner.Parent = btn
        end
        
        btn.Parent = weightControls
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.MinWeight = math.max(1, CheatConfig.MinWeight + offset)
            CheatConfig.MaxWeight = math.max(CheatConfig.MinWeight + 50, CheatConfig.MaxWeight + offset)
            weightDisplay.Text = string.format("%d - %d kg", CheatConfig.MinWeight, CheatConfig.MaxWeight)
            Vibrate(0.05)
        end)
        
        return btn
    end
    
    CreateWeightButton("-50", Color3.fromRGB(255, 100, 100), -50)
    CreateWeightButton("+50", Color3.fromRGB(100, 255, 100), 50)
    
    -- Feature Toggles
    local toggleSection = Instance.new("TextLabel")
    toggleSection.Text = "PENGATURAN:"
    toggleSection.Size = UDim2.new(1, 0, 0, 25 * UI_SCALE)
    toggleSection.BackgroundTransparency = 1
    toggleSection.TextColor3 = Color3.new(1, 1, 1)
    toggleSection.Font = Enum.Font.Gotham
    toggleSection.TextSize = IS_MOBILE and 16 or 14
    toggleSection.TextXAlignment = Enum.TextXAlignment.Left
    toggleSection.LayoutOrder = 5
    toggleSection.Parent = content
    
    local toggleButtons = {}
    
    local function CreateToggle(label, configKey, order)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.LayoutOrder = order
        toggleFrame.Parent = content
        
        local labelText = Instance.new("TextLabel")
        labelText.Text = label
        labelText.Size = UDim2.new(0.7, 0, 1, 0)
        labelText.BackgroundTransparency = 1
        labelText.TextColor3 = Color3.new(1, 1, 1)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = IS_MOBILE and 16 or 14
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = toggleFrame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Text = CheatConfig[configKey] and "ON" or "OFF"
        toggleBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
        toggleBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
        toggleBtn.BackgroundColor3 = CheatConfig[configKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleBtn.TextColor3 = Color3.new(1, 1, 1)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = IS_MOBILE and 16 or 14
        
        if IS_MOBILE then
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 10)
            btnCorner.Parent = toggleBtn
        end
        
        toggleBtn.Parent = toggleFrame
        
        toggleBtn.MouseButton1Click:Connect(function()
            CheatConfig[configKey] = not CheatConfig[configKey]
            toggleBtn.Text = CheatConfig[configKey] and "ON" or "OFF"
            toggleBtn.BackgroundColor3 = CheatConfig[configKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            Vibrate(0.05)
        end)
        
        toggleButtons[configKey] = toggleBtn
    end
    
    CreateToggle("INSTANT CATCH", "InstantCatch", 6)
    CreateToggle("AUTO SELL", "AutoSell", 7)
    CreateToggle("VIBRATION", "Vibration", 8)
    
    -- Action Buttons
    local actionSection = Instance.new("TextLabel")
    actionSection.Text = "AKSI CEPAT:"
    actionSection.Size = UDim2.new(1, 0, 0, 25 * UI_SCALE)
    actionSection.BackgroundTransparency = 1
    actionSection.TextColor3 = Color3.new(1, 1, 1)
    actionSection.Font = Enum.Font.Gotham
    actionSection.TextSize = IS_MOBILE and 16 or 14
    actionSection.TextXAlignment = Enum.TextXAlignment.Left
    actionSection.LayoutOrder = 9
    actionSection.Parent = content
    
    local actionFrame = Instance.new("Frame")
    actionFrame.Size = UDim2.new(1, 0, 0, 80 * UI_SCALE)
    actionFrame.BackgroundTransparency = 1
    actionFrame.LayoutOrder = 10
    actionFrame.Parent = content
    
    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    actionLayout.Padding = UDim.new(0, 10 * UI_SCALE)
    actionLayout.Parent = actionFrame
    
    local function CreateActionButton(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(0, 120 * UI_SCALE, 0, 70 * UI_SCALE)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = IS_MOBILE and 18 or 16
        
        if IS_MOBILE then
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 15)
            btnCorner.Parent = btn
        end
        
        btn.Parent = actionFrame
        
        btn.MouseButton1Click:Connect(function()
            callback()
            Vibrate(0.1)
        end)
        
        return btn
    end
    
    local autoFishing = false
    local autoBtn
    
    autoBtn = CreateActionButton("START AUTO", Color3.fromRGB(0, 150, 255), function()
        if not autoFishing then
            -- Start auto fishing
            autoFishing = true
            autoBtn.Text = "STOP AUTO"
            autoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            
            -- Simple auto fishing loop
            task.spawn(function()
                while autoFishing do
                    task.wait(2) -- Delay between auto casts
                    
                    -- Trigger fishing manually
                    local fakeFish = GenerateFakeFishData()
                    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
                    local CatchRemote = FishingSystem:FindFirstChild("CatchFish")
                    
                    if CatchRemote then
                        pcall(function()
                            CatchRemote:FireServer(fakeFish)
                        end)
                    end
                end
            end)
        else
            -- Stop auto fishing
            autoFishing = false
            autoBtn.Text = "START AUTO"
            autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end
    end)
    
    CreateActionButton("CATCH NOW", Color3.fromRGB(255, 200, 0), function()
        -- Manual catch
        local fakeFish = GenerateFakeFishData()
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
        local CatchRemote = FishingSystem:FindFirstChild("CatchFish")
        
        if CatchRemote then
            pcall(function()
                CatchRemote:FireServer(fakeFish)
                print(string.format("🎣 %s (%.1fkg) - %s", 
                    fakeFish.Name, fakeFish.Weight, fakeFish.Rarity))
            end)
        end
    end)
    
    -- Status Display
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, 0, 0, 40 * UI_SCALE)
    statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    statusFrame.LayoutOrder = 11
    
    if IS_MOBILE then
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(0, 10)
        statusCorner.Parent = statusFrame
    end
    
    statusFrame.Parent = content
    
    local statusText = Instance.new("TextLabel")
    statusText.Text = IS_MOBILE and "🎣 READY" or "Status: Ready"
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.fromRGB(0, 255, 119)
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = IS_MOBILE and 14 or 12
    statusText.Parent = statusFrame
    
    -- Mobile optimization: Auto-adjust size
    if IS_MOBILE then
        GuiService:GetSafeInsetsChangedSignal():Connect(function()
            local safeInsets = GuiService:GetSafeInsets()
            main.Position = UDim2.new(0.5, -150 * UI_SCALE, 
                                      0.5, -200 * UI_SCALE + safeInsets.Top)
        end)
    end
    
    return screen
end

-- ============================================
-- SIMPLE GUI MODE (EXTREME SIMPLICITY)
-- ============================================

local function CreateSimpleMobileGUI()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui
    screen.Name = "SimpleFishCheat"
    screen.DisplayOrder = 999
    
    -- Floating Button
    local floatBtn = Instance.new("TextButton")
    floatBtn.Text = "🎣"
    floatBtn.Size = UDim2.new(0, 60 * UI_SCALE, 0, 60 * UI_SCALE)
    floatBtn.Position = UDim2.new(1, -70 * UI_SCALE, 0.5, -30 * UI_SCALE)
    floatBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 119)
    floatBtn.TextColor3 = Color3.new(0, 0, 0)
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 24 * UI_SCALE
    floatBtn.ZIndex = 100
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 30 * UI_SCALE)
    corner.Parent = floatBtn
    
    floatBtn.Parent = screen
    
    -- Mini Panel (appears when button clicked)
    local miniPanel = Instance.new("Frame")
    miniPanel.Size = UDim2.new(0, 200 * UI_SCALE, 0, 150 * UI_SCALE)
    miniPanel.Position = UDim2.new(1, -210 * UI_SCALE, 0.5, -75 * UI_SCALE)
    miniPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    miniPanel.BackgroundTransparency = 0.1
    miniPanel.Visible = false
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 15)
    panelCorner.Parent = miniPanel
    
    miniPanel.Parent = screen
    
    -- Quick catch button
    local quickCatch = Instance.new("TextButton")
    quickCatch.Text = "CATCH SECRET 🎣"
    quickCatch.Size = UDim2.new(0.9, 0, 0, 40 * UI_SCALE)
    quickCatch.Position = UDim2.new(0.05, 0, 0.05, 0)
    quickCatch.BackgroundColor3 = module_upvr.RarityColors.SECRET
    quickCatch.TextColor3 = Color3.new(1, 1, 1)
    quickCatch.Font = Enum.Font.GothamBold
    quickCatch.TextSize = 14 * UI_SCALE
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = quickCatch
    
    quickCatch.Parent = miniPanel
    
    quickCatch.MouseButton1Click:Connect(function()
        CheatConfig.SelectedRarity = "SECRET"
        local fakeFish = GenerateFakeFishData()
        
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
        local CatchRemote = FishingSystem:FindFirstChild("CatchFish")
        
        if CatchRemote then
            pcall(function()
                CatchRemote:FireServer(fakeFish)
            end)
        end
        
        Vibrate(0.2)
        miniPanel.Visible = false
    end)
    
    -- Auto toggle
    local autoBtn = Instance.new("TextButton")
    autoBtn.Text = "AUTO: OFF"
    autoBtn.Size = UDim2.new(0.9, 0, 0, 40 * UI_SCALE)
    autoBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
    autoBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    autoBtn.TextColor3 = Color3.new(1, 1, 1)
    autoBtn.Font = Enum.Font.Gotham
    autoBtn.TextSize = 14 * UI_SCALE
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 10)
    autoCorner.Parent = autoBtn
    
    autoBtn.Parent = miniPanel
    
    local autoFishing = false
    autoBtn.MouseButton1Click:Connect(function()
        autoFishing = not autoFishing
        autoBtn.Text = autoFishing and "AUTO: ON" or "AUTO: OFF"
        autoBtn.BackgroundColor3 = autoFishing and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        Vibrate(0.1)
    end)
    
    -- Close panel button
    local closePanel = Instance.new("TextButton")
    closePanel.Text = "✕"
    closePanel.Size = UDim2.new(0, 30 * UI_SCALE, 0, 30 * UI_SCALE)
    closePanel.Position = UDim2.new(1, -35 * UI_SCALE, 0, 5 * UI_SCALE)
    closePanel.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closePanel.TextColor3 = Color3.new(1, 1, 1)
    closePanel.Font = Enum.Font.GothamBold
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closePanel
    
    closePanel.Parent = miniPanel
    
    closePanel.MouseButton1Click:Connect(function()
        miniPanel.Visible = false
    end)
    
    -- Toggle panel visibility
    floatBtn.MouseButton1Click:Connect(function()
        miniPanel.Visible = not miniPanel.Visible
        Vibrate(0.05)
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
-- INITIALIZATION - MOBILE OPTIMIZED
-- ============================================

print("========================================")
print("   MOBILE FISHING CHEAT v2.0 LOADED")
print("   Platform: " .. (IS_MOBILE and "MOBILE" or IS_CONSOLE and "CONSOLE" or "DESKTOP"))
print("========================================")

-- Tunggu game load
task.wait(2)

-- Hook fishing system
local hookSuccess = HookFishingSystem()

if hookSuccess then
    -- Pilih GUI berdasarkan platform
    if IS_MOBILE and CheatConfig.SimpleMode then
        CreateSimpleMobileGUI()
        print("📱 Simple Mobile GUI Loaded!")
    else
        CreateMobileGUI()
        print("🎣 Full GUI Loaded!")
    end
    
    print("✅ Cheat aktif! Pilih rarity dan mulai fishing!")
else
    warn("❌ Gagal hook fishing system!")
end

-- Export global functions untuk mobile
getgenv().catchFish = function()
    local fakeFish = GenerateFakeFishData()
    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
    local CatchRemote = FishingSystem:FindFirstChild("CatchFish")
    
    if CatchRemote then
        pcall(function()
            CatchRemote:FireServer(fakeFish)
        end)
        return fakeFish
    end
    return nil
end

getgenv().setRarity = function(rarity)
    CheatConfig.SelectedRarity = rarity:upper()
    print("Rarity set to: " .. rarity)
end

-- Auto-close GUI saat respawn (mobile optimization)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    -- Reset jika perlu
end)
