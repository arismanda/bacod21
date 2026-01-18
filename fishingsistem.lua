-- ============================================
-- SIMPLE FISHING CHEAT - MOBILE FRIENDLY
-- GUI Sederhana untuk Instant Catch
-- ============================================

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Mobile Detection
local IS_MOBILE = UserInputService.TouchEnabled
local UI_SCALE = IS_MOBILE and 1.2 or 1

-- ============================================
-- CONFIGURASI CHEAT
-- ============================================

local CheatConfig = {
    SelectedRarity = "Unknown",
    MinWeight = 200,
    MaxWeight = 999,
    InstantCatch = true,
    AutoSell = false,
    NoMinigame = true
}

-- ============================================
-- FUNGSI UTAMA
-- ============================================

local function GetFishByRarity(rarity)
    local fishList = {}
    for _, fish in pairs(module_2_upvr.FishTable) do
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
        Price = 0,
        Timestamp = os.time()
    }
end

-- ============================================
-- HOOK FISHING SYSTEM
-- ============================================

local function SetupHook()
    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 5)
    if not FishingSystem then return false end
    
    local remotes = {}
    for _, child in pairs(FishingSystem:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
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
                end
                
                if CheatConfig.AutoSell then
                    local sellRemote = remotes["SellFish"]
                    if sellRemote then
                        task.wait(0.5)
                        sellRemote:FireServer({fakeFish})
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
-- SIMPLE MOBILE GUI
-- ============================================

local function CreateSimpleGUI()
    -- ScreenGui
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    screen.Name = "SimpleFishCheat"
    screen.ResetOnSpawn = false
    
    -- Main Container
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300 * UI_SCALE, 0, 400 * UI_SCALE)
    main.Position = UDim2.new(0.5, -150 * UI_SCALE, 0.5, -200 * UI_SCALE)
    main.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    main.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = main
    
    main.Parent = screen
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
    header.BackgroundColor3 = module_2_upvr.GetRarityColor("Unknown")
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    header.Parent = main
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎣 FISHING CHEAT"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20 * UI_SCALE
    title.Parent = header
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 40 * UI_SCALE, 0, 40 * UI_SCALE)
    closeBtn.Position = UDim2.new(1, -45 * UI_SCALE, 0.5, -20 * UI_SCALE)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18 * UI_SCALE
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = closeBtn
    
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
    
    -- Content
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -10, 1, -60 * UI_SCALE)
    content.Position = UDim2.new(0, 5, 0, 55 * UI_SCALE)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 6
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = main
    
    -- Rarity Section
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Text = "PILIH RARITY:"
    rarityLabel.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.TextColor3 = Color3.new(1, 1, 1)
    rarityLabel.Font = Enum.Font.GothamBold
    rarityLabel.TextSize = 16 * UI_SCALE
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Parent = content
    
    -- Rarity Buttons
    local rarities = {"Unknown", "Legendary", "Epic", "Rare", "Uncommon", "Common"}
    
    for i, rarity in pairs(rarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity
        btn.Size = UDim2.new(1, 0, 0, 40 * UI_SCALE)
        btn.Position = UDim2.new(0, 0, 0, (i-1) * 45 * UI_SCALE + 35)
        btn.BackgroundColor3 = module_2_upvr.GetRarityColor(rarity)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16 * UI_SCALE
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.Parent = content
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = rarity
            print("Selected: " .. rarity)
        end)
    end
    
    -- Weight Control
    local weightLabel = Instance.new("TextLabel")
    weightLabel.Text = "BERAT IKAN (kg):"
    weightLabel.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    weightLabel.Position = UDim2.new(0, 0, 0, 280 * UI_SCALE)
    weightLabel.BackgroundTransparency = 1
    weightLabel.TextColor3 = Color3.new(1, 1, 1)
    weightLabel.Font = Enum.Font.GothamBold
    weightLabel.TextSize = 16 * UI_SCALE
    weightLabel.TextXAlignment = Enum.TextXAlignment.Left
    weightLabel.Parent = content
    
    -- Weight Display
    local weightDisplay = Instance.new("TextLabel")
    weightDisplay.Text = CheatConfig.MinWeight .. " - " .. CheatConfig.MaxWeight .. " kg"
    weightDisplay.Size = UDim2.new(1, 0, 0, 35 * UI_SCALE)
    weightDisplay.Position = UDim2.new(0, 0, 0, 310 * UI_SCALE)
    weightDisplay.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    weightDisplay.TextColor3 = Color3.new(1, 1, 1)
    weightDisplay.Font = Enum.Font.GothamBold
    weightDisplay.TextSize = 18 * UI_SCALE
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 8)
    displayCorner.Parent = weightDisplay
    
    weightDisplay.Parent = content
    
    -- Weight Buttons
    local weightControls = Instance.new("Frame")
    weightControls.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
    weightControls.Position = UDim2.new(0, 0, 0, 350 * UI_SCALE)
    weightControls.BackgroundTransparency = 1
    weightControls.Parent = content
    
    local function UpdateWeight()
        weightDisplay.Text = CheatConfig.MinWeight .. " - " .. CheatConfig.MaxWeight .. " kg"
    end
    
    -- Minus
    local minusBtn = Instance.new("TextButton")
    minusBtn.Text = "-100"
    minusBtn.Size = UDim2.new(0.45, 0, 1, 0)
    minusBtn.Position = UDim2.new(0, 0, 0, 0)
    minusBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 18 * UI_SCALE
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 10)
    minusCorner.Parent = minusBtn
    
    minusBtn.Parent = weightControls
    
    minusBtn.MouseButton1Click:Connect(function()
        if CheatConfig.MinWeight > 100 then
            CheatConfig.MinWeight = CheatConfig.MinWeight - 100
            CheatConfig.MaxWeight = CheatConfig.MaxWeight - 100
            UpdateWeight()
        end
    end)
    
    -- Plus
    local plusBtn = Instance.new("TextButton")
    plusBtn.Text = "+100"
    plusBtn.Size = UDim2.new(0.45, 0, 1, 0)
    plusBtn.Position = UDim2.new(0.55, 0, 0, 0)
    plusBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 18 * UI_SCALE
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 10)
    plusCorner.Parent = plusBtn
    
    plusBtn.Parent = weightControls
    
    plusBtn.MouseButton1Click:Connect(function()
        CheatConfig.MinWeight = CheatConfig.MinWeight + 100
        CheatConfig.MaxWeight = CheatConfig.MaxWeight + 100
        UpdateWeight()
    end)
    
    -- Quick Actions
    local actionsLabel = Instance.new("TextLabel")
    actionsLabel.Text = "AKSI CEPAT:"
    actionsLabel.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    actionsLabel.Position = UDim2.new(0, 0, 0, 410 * UI_SCALE)
    actionsLabel.BackgroundTransparency = 1
    actionsLabel.TextColor3 = Color3.new(1, 1, 1)
    actionsLabel.Font = Enum.Font.GothamBold
    actionsLabel.TextSize = 16 * UI_SCALE
    actionsLabel.TextXAlignment = Enum.TextXAlignment.Left
    actionsLabel.Parent = content
    
    -- Catch Now Button
    local catchBtn = Instance.new("TextButton")
    catchBtn.Text = "🎣 CATCH NOW"
    catchBtn.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
    catchBtn.Position = UDim2.new(0, 0, 0, 440 * UI_SCALE)
    catchBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    catchBtn.TextColor3 = Color3.new(0, 0, 0)
    catchBtn.Font = Enum.Font.GothamBold
    catchBtn.TextSize = 18 * UI_SCALE
    
    local catchCorner = Instance.new("UICorner")
    catchCorner.CornerRadius = UDim.new(0, 12)
    catchCorner.Parent = catchBtn
    
    catchBtn.Parent = content
    
    catchBtn.MouseButton1Click:Connect(function()
        local fakeFish = CreateFakeFish()
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
        local catchRemote = FishingSystem:FindFirstChild("CatchFish")
        
        if catchRemote then
            catchRemote:FireServer(fakeFish)
            print("Caught: " .. fakeFish.Name .. " (" .. fakeFish.Weight .. "kg)")
        end
    end)
    
    -- Draggable Window
    local dragging = false
    local dragStart, startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return screen
end

-- ============================================
-- MINIMAL GUI (FLOATING BUTTON)
-- ============================================

local function CreateMinimalGUI()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    screen.Name = "FishCheatMinimal"
    screen.ResetOnSpawn = false
    
    -- Floating Action Button
    local fab = Instance.new("TextButton")
    fab.Text = "🎣"
    fab.Size = UDim2.new(0, 60 * UI_SCALE, 0, 60 * UI_SCALE)
    fab.Position = UDim2.new(1, -70 * UI_SCALE, 0.5, -30 * UI_SCALE)
    fab.BackgroundColor3 = module_2_upvr.GetRarityColor("Unknown")
    fab.TextColor3 = Color3.new(1, 1, 1)
    fab.Font = Enum.Font.GothamBold
    fab.TextSize = 28 * UI_SCALE
    fab.ZIndex = 999
    
    local fabCorner = Instance.new("UICorner")
    fabCorner.CornerRadius = UDim.new(1, 0)
    fabCorner.Parent = fab
    
    fab.Parent = screen
    
    -- Mini Panel
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 180 * UI_SCALE, 0, 200 * UI_SCALE)
    panel.Position = UDim2.new(1, -190 * UI_SCALE, 0.5, -100 * UI_SCALE)
    panel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    panel.BackgroundTransparency = 0.1
    panel.Visible = false
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 15)
    panelCorner.Parent = panel
    
    panel.Parent = screen
    
    -- Rarity Selection in Panel
    local rarities = {"Unknown", "Legendary", "Epic", "Rare"}
    
    for i, rarity in pairs(rarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity
        btn.Size = UDim2.new(0.9, 0, 0, 35 * UI_SCALE)
        btn.Position = UDim2.new(0.05, 0, 0, (i-1) * 40 * UI_SCALE + 10)
        btn.BackgroundColor3 = module_2_upvr.GetRarityColor(rarity)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14 * UI_SCALE
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.Parent = panel
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = rarity
            local fakeFish = CreateFakeFish()
            local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
            local catchRemote = FishingSystem:FindFirstChild("CatchFish")
            
            if catchRemote then
                catchRemote:FireServer(fakeFish)
            end
            
            panel.Visible = false
        end)
    end
    
    -- Close Panel Button
    local closePanel = Instance.new("TextButton")
    closePanel.Text = "✕"
    closePanel.Size = UDim2.new(0, 30 * UI_SCALE, 0, 30 * UI_SCALE)
    closePanel.Position = UDim2.new(1, -35 * UI_SCALE, 0, 5 * UI_SCALE)
    closePanel.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closePanel.TextColor3 = Color3.new(1, 1, 1)
    closePanel.Font = Enum.Font.GothamBold
    closePanel.TextSize = 16 * UI_SCALE
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closePanel
    
    closePanel.Parent = panel
    
    closePanel.MouseButton1Click:Connect(function()
        panel.Visible = false
    end)
    
    -- Toggle Panel
    fab.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)
    
    -- Draggable FAB
    local dragging = false
    local dragStart, startPos
    
    fab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = fab.Position
        end
    end)
    
    fab.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            fab.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
            
            -- Update panel position
            panel.Position = UDim2.new(
                1, -190 * UI_SCALE,
                fab.Position.Y.Scale,
                fab.Position.Y.Offset - 100 * UI_SCALE
            )
        end
    end)
    
    return screen
end

-- ============================================
-- INISIALISASI
-- ============================================

print("========================================")
print("   SIMPLE FISHING CHEAT")
print("   Mobile Support: " .. (IS_MOBILE and "YES" or "NO"))
print("========================================")

-- Tunggu game load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Setup hook
local hookSuccess = SetupHook()

if hookSuccess then
    print("✅ Hook berhasil!")
else
    print("⚠️ Hook gagal, menggunakan manual mode")
end

-- Buat GUI berdasarkan platform
if IS_MOBILE then
    -- Pilih salah satu GUI untuk mobile:
    
    -- 1. GUI Minimal (Floating Button)
    CreateMinimalGUI()
    print("📱 Minimal GUI created")
    
    -- 2. GUI Full
    -- CreateSimpleGUI()
    -- print("📱 Full GUI created")
else
    CreateSimpleGUI()
    print("💻 Desktop GUI created")
end

-- Export Functions
getgenv().catchFish = function(rarity)
    if rarity then
        CheatConfig.SelectedRarity = rarity
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
    CheatConfig.SelectedRarity = rarity
    print("Rarity set to: " .. rarity)
end

getgenv().setWeight = function(min, max)
    CheatConfig.MinWeight = min
    CheatConfig.MaxWeight = max
    print("Weight set to: " .. min .. "-" .. max .. "kg")
end

print("========================================")
print("   Ready to use!")
print("   Commands: catchFish(), setRarity(), setWeight()")
print("========================================")
