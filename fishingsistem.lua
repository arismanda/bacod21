-- ============================================
-- SIMPLE FISHING CHEAT - FIXED VERSION
-- Error handling untuk GetRarityColor
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
-- CONFIGURASI CHEAT - FIXED
-- ============================================

local CheatConfig = {
    SelectedRarity = "Unknown",
    MinWeight = 200,
    MaxWeight = 999,
    InstantCatch = true,
    AutoSell = false
}

-- ============================================
-- FIXED FUNCTIONS - ERROR HANDLING
-- ============================================

-- Safe GetRarityColor dengan fallback
local function GetRarityColorSafe(rarity)
    local success, color = pcall(function()
        if module_2_upvr.RarityColors and module_2_upvr.RarityColors[rarity] then
            return module_2_upvr.RarityColors[rarity]
        end
        return nil
    end)
    
    if success and color then
        return color
    end
    
    -- Fallback colors jika error
    local fallbackColors = {
        Unknown = Color3.fromRGB(190, 0, 3),
        Legendary = Color3.fromRGB(255, 128, 0),
        Epic = Color3.fromRGB(160, 30, 255),
        Rare = Color3.fromRGB(30, 100, 255),
        Uncommon = Color3.fromRGB(30, 255, 30),
        Common = Color3.fromRGB(200, 200, 200)
    }
    
    return fallbackColors[rarity] or Color3.fromRGB(255, 255, 255)
end

-- Safe GetRodConfig
local function GetRodConfigSafe(rodName)
    local success, config = pcall(function()
        if module_2_upvr.GetRodConfig then
            return module_2_upvr.GetRodConfig(rodName)
        end
        return nil
    end)
    
    if success and config then
        return config
    end
    
    return {
        hookName = "BasicHook",
        beamColor = Color3.fromRGB(106, 106, 106),
        beamWidth = 0.05,
        baseLuck = 0.5,
        maxWeight = 100,
        maxRarity = "Common"
    }
end

-- ============================================
-- FUNGSI UTAMA - SAFE VERSION
-- ============================================

local function GetFishByRarity(rarity)
    local fishList = {}
    
    local success = pcall(function()
        if module_2_upvr.FishTable then
            for _, fish in pairs(module_2_upvr.FishTable) do
                if fish.rarity == rarity then
                    table.insert(fishList, fish)
                end
            end
        end
    end)
    
    if not success or #fishList == 0 then
        -- Fallback fish list
        fishList = {
            {name = "Boar Fish", rarity = "Common", minKg = 0.5, maxKg = 50},
            {name = "Blackcap Basslet", rarity = "Common", minKg = 0.5, maxKg = 45}
        }
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
        Price = weight * 100, -- Harga estimasi
        Timestamp = os.time()
    }
end

-- ============================================
-- HOOK FISHING SYSTEM - SAFE
-- ============================================

local function SetupHook()
    local success, FishingSystem = pcall(function()
        return ReplicatedStorage:WaitForChild("FishingSystem", 5)
    end)
    
    if not success or not FishingSystem then
        print("⚠️ FishingSystem tidak ditemukan")
        return false
    end
    
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
            local args = {...}
            local result
            
            local success2, err = pcall(function()
                result = originalFire(self, unpack(args))
            end)
            
            if not success2 then
                print("❌ Error in original fire:", err)
            end
            
            if CheatConfig.InstantCatch then
                task.wait(0.3)
                
                local catchRemote = remotes["CatchFish"] or remotes["CompleteFishing"]
                if catchRemote then
                    local fakeFish = CreateFakeFish()
                    pcall(function()
                        catchRemote:FireServer(fakeFish)
                        print("✅ Caught: " .. fakeFish.Name .. " (" .. fakeFish.Weight .. "kg)")
                    end)
                end
                
                if CheatConfig.AutoSell then
                    local sellRemote = remotes["SellFish"]
                    if sellRemote then
                        task.wait(0.5)
                        pcall(function()
                            sellRemote:FireServer({fakeFish})
                            print("💰 Sold fish")
                        end)
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
-- SIMPLE GUI - WITH ERROR HANDLING
-- ============================================

local function CreateSimpleGUI()
    -- ScreenGui
    local success, screen = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
        gui.Name = "SimpleFishCheatV2"
        gui.ResetOnSpawn = false
        return gui
    end)
    
    if not success then
        print("❌ Gagal membuat ScreenGui")
        return nil
    end
    
    -- Main Container
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300 * UI_SCALE, 0, 350 * UI_SCALE)
    main.Position = UDim2.new(0.5, -150 * UI_SCALE, 0.5, -175 * UI_SCALE)
    main.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    main.BorderSizePixel = 0
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = main
    
    main.Parent = screen
    
    -- Header dengan color safe
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50 * UI_SCALE)
    header.BackgroundColor3 = GetRarityColorSafe("Unknown")
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    header.Parent = main
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎣 FISH CHEAT"
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.15, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18 * UI_SCALE
    title.TextScaled = true
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
        pcall(function()
            screen:Destroy()
        end)
    end)
    
    -- Content Frame
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -60 * UI_SCALE)
    content.Position = UDim2.new(0, 10, 0, 55 * UI_SCALE)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Rarity Selection Label
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Text = "PILIH RARITY:"
    rarityLabel.Size = UDim2.new(1, 0, 0, 25 * UI_SCALE)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.TextColor3 = Color3.new(1, 1, 1)
    rarityLabel.Font = Enum.Font.GothamBold
    rarityLabel.TextSize = 14 * UI_SCALE
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Parent = content
    
    -- Rarity Buttons - Disederhanakan
    local rarities = {"Unknown", "Legendary", "Epic", "Rare", "Uncommon", "Common"}
    
    for i, rarity in pairs(rarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity
        btn.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
        btn.Position = UDim2.new(0, 0, 0, (i-1) * 35 * UI_SCALE + 30)
        btn.BackgroundColor3 = GetRarityColorSafe(rarity)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14 * UI_SCALE
        btn.AutoButtonColor = true
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.Parent = content
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = rarity
            print("🎯 Rarity: " .. rarity)
        end)
    end
    
    -- Weight Control Label
    local weightLabel = Instance.new("TextLabel")
    weightLabel.Text = "BERAT IKAN:"
    weightLabel.Size = UDim2.new(1, 0, 0, 25 * UI_SCALE)
    weightLabel.Position = UDim2.new(0, 0, 0, 240 * UI_SCALE)
    weightLabel.BackgroundTransparency = 1
    weightLabel.TextColor3 = Color3.new(1, 1, 1)
    weightLabel.Font = Enum.Font.GothamBold
    weightLabel.TextSize = 14 * UI_SCALE
    weightLabel.TextXAlignment = Enum.TextXAlignment.Left
    weightLabel.Parent = content
    
    -- Weight Display
    local weightDisplay = Instance.new("TextLabel")
    weightDisplay.Text = CheatConfig.MinWeight .. " - " .. CheatConfig.MaxWeight .. " kg"
    weightDisplay.Size = UDim2.new(1, 0, 0, 30 * UI_SCALE)
    weightDisplay.Position = UDim2.new(0, 0, 0, 265 * UI_SCALE)
    weightDisplay.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    weightDisplay.TextColor3 = Color3.new(1, 1, 1)
    weightDisplay.Font = Enum.Font.GothamBold
    weightDisplay.TextSize = 16 * UI_SCALE
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 8)
    displayCorner.Parent = weightDisplay
    
    weightDisplay.Parent = content
    
    -- Weight Control Buttons
    local weightControls = Instance.new("Frame")
    weightControls.Size = UDim2.new(1, 0, 0, 40 * UI_SCALE)
    weightControls.Position = UDim2.new(0, 0, 0, 300 * UI_SCALE)
    weightControls.BackgroundTransparency = 1
    weightControls.Parent = content
    
    local function UpdateWeightDisplay()
        weightDisplay.Text = CheatConfig.MinWeight .. " - " .. CheatConfig.MaxWeight .. " kg"
    end
    
    -- Minus Button
    local minusBtn = Instance.new("TextButton")
    minusBtn.Text = "-"
    minusBtn.Size = UDim2.new(0.2, 0, 1, 0)
    minusBtn.Position = UDim2.new(0.1, 0, 0, 0)
    minusBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 20 * UI_SCALE
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 8)
    minusCorner.Parent = minusBtn
    
    minusBtn.Parent = weightControls
    
    minusBtn.MouseButton1Click:Connect(function()
        if CheatConfig.MinWeight > 50 then
            CheatConfig.MinWeight = CheatConfig.MinWeight - 50
            CheatConfig.MaxWeight = CheatConfig.MaxWeight - 50
            UpdateWeightDisplay()
        end
    end)
    
    -- Weight Value
    local weightValue = Instance.new("TextLabel")
    weightValue.Text = "WEIGHT"
    weightValue.Size = UDim2.new(0.4, 0, 1, 0)
    weightValue.Position = UDim2.new(0.3, 0, 0, 0)
    weightValue.BackgroundTransparency = 1
    weightValue.TextColor3 = Color3.new(1, 1, 1)
    weightValue.Font = Enum.Font.Gotham
    weightValue.TextSize = 14 * UI_SCALE
    weightValue.Parent = weightControls
    
    -- Plus Button
    local plusBtn = Instance.new("TextButton")
    plusBtn.Text = "+"
    plusBtn.Size = UDim2.new(0.2, 0, 1, 0)
    plusBtn.Position = UDim2.new(0.7, 0, 0, 0)
    plusBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 20 * UI_SCALE
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 8)
    plusCorner.Parent = plusBtn
    
    plusBtn.Parent = weightControls
    
    plusBtn.MouseButton1Click:Connect(function()
        CheatConfig.MinWeight = CheatConfig.MinWeight + 50
        CheatConfig.MaxWeight = CheatConfig.MaxWeight + 50
        UpdateWeightDisplay()
    end)
    
    -- Action Button
    local actionBtn = Instance.new("TextButton")
    actionBtn.Text = "🎣 CATCH FISH"
    actionBtn.Size = UDim2.new(1, 0, 0, 45 * UI_SCALE)
    actionBtn.Position = UDim2.new(0, 0, 0, 350 * UI_SCALE)
    actionBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    actionBtn.TextColor3 = Color3.new(0, 0, 0)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 16 * UI_SCALE
    
    local actionCorner = Instance.new("UICorner")
    actionCorner.CornerRadius = UDim.new(0, 10)
    actionCorner.Parent = actionBtn
    
    actionBtn.Parent = content
    
    actionBtn.MouseButton1Click:Connect(function()
        local fakeFish = CreateFakeFish()
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
        local catchRemote = FishingSystem:FindFirstChild("CatchFish")
        
        if catchRemote then
            pcall(function()
                catchRemote:FireServer(fakeFish)
                print("✅ Caught: " .. fakeFish.Name)
            end)
        else
            print("❌ Remote tidak ditemukan")
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
-- MINIMAL GUI - ULTRA SIMPLE
-- ============================================

local function CreateMinimalGUI()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    screen.Name = "FishCheatMini"
    screen.ResetOnSpawn = false
    
    -- Main Button
    local mainBtn = Instance.new("TextButton")
    mainBtn.Text = "🎣"
    mainBtn.Size = UDim2.new(0, 70 * UI_SCALE, 0, 70 * UI_SCALE)
    mainBtn.Position = UDim2.new(1, -80 * UI_SCALE, 0.5, -35 * UI_SCALE)
    mainBtn.BackgroundColor3 = GetRarityColorSafe("Unknown")
    mainBtn.TextColor3 = Color3.new(1, 1, 1)
    mainBtn.Font = Enum.Font.GothamBold
    mainBtn.TextSize = 30 * UI_SCALE
    mainBtn.ZIndex = 999
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = mainBtn
    
    mainBtn.Parent = screen
    
    -- Dropdown Menu
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(0, 150 * UI_SCALE, 0, 180 * UI_SCALE)
    dropdown.Position = UDim2.new(1, -160 * UI_SCALE, mainBtn.Position.Y.Scale, mainBtn.Position.Y.Offset)
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dropdown.BackgroundTransparency = 0.1
    dropdown.Visible = false
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 10)
    dropdownCorner.Parent = dropdown
    
    dropdown.Parent = screen
    
    -- Menu Items
    local menuItems = {
        {text = "Unknown", color = GetRarityColorSafe("Unknown")},
        {text = "Legendary", color = GetRarityColorSafe("Legendary")},
        {text = "Epic", color = GetRarityColorSafe("Epic")},
        {text = "Catch Now", color = Color3.fromRGB(255, 200, 0)}
    }
    
    for i, item in pairs(menuItems) do
        local btn = Instance.new("TextButton")
        btn.Text = item.text
        btn.Size = UDim2.new(0.9, 0, 0, 35 * UI_SCALE)
        btn.Position = UDim2.new(0.05, 0, 0, (i-1) * 40 * UI_SCALE + 10)
        btn.BackgroundColor3 = item.color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14 * UI_SCALE
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 8)
        itemCorner.Parent = btn
        
        btn.Parent = dropdown
        
        btn.MouseButton1Click:Connect(function()
            if item.text ~= "Catch Now" then
                CheatConfig.SelectedRarity = item.text
                print("🎯 Set: " .. item.text)
            else
                local fakeFish = CreateFakeFish()
                local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
                local catchRemote = FishingSystem:FindFirstChild("CatchFish")
                
                if catchRemote then
                    pcall(function()
                        catchRemote:FireServer(fakeFish)
                        print("✅ Caught: " .. fakeFish.Name)
                    end)
                end
            end
            dropdown.Visible = false
        end)
    end
    
    -- Toggle Dropdown
    mainBtn.MouseButton1Click:Connect(function()
        dropdown.Visible = not dropdown.Visible
    end)
    
    -- Draggable
    local dragging = false
    local dragStart, startPos
    
    mainBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainBtn.Position
        end
    end)
    
    mainBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            mainBtn.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
            dropdown.Position = UDim2.new(
                1, -160 * UI_SCALE,
                mainBtn.Position.Y.Scale,
                mainBtn.Position.Y.Offset
            )
        end
    end)
    
    return screen
end

-- ============================================
-- INISIALISASI - WITH ERROR HANDLING
-- ============================================

print("========================================")
print("   FISHING CHEAT - FIXED VERSION")
print("   Error handling enabled")
print("========================================")

-- Tunggu game load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Setup hook dengan error handling
local hookSuccess = false
local success, err = pcall(function()
    hookSuccess = SetupHook()
end)

if success then
    if hookSuccess then
        print("✅ Hook berhasil diinstall")
    else
        print("⚠️ Hook gagal, mode manual")
    end
else
    print("❌ Error saat setup hook:", err)
end

-- Buat GUI berdasarkan platform
local guiSuccess, guiError = pcall(function()
    if IS_MOBILE then
        -- Pilih GUI untuk mobile
        local useMinimal = true -- true untuk minimal, false untuk full
        
        if useMinimal then
            CreateMinimalGUI()
            print("📱 Minimal GUI created")
        else
            CreateSimpleGUI()
            print("📱 Full GUI created")
        end
    else
        CreateSimpleGUI()
        print("💻 Desktop GUI created")
    end
end)

if not guiSuccess then
    print("❌ Error membuat GUI:", guiError)
end

-- Export Functions dengan error handling
getgenv().catchFish = function(rarity)
    if rarity then
        CheatConfig.SelectedRarity = rarity
    end
    
    local fakeFish = CreateFakeFish()
    local success3, result = pcall(function()
        local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
        local catchRemote = FishingSystem:FindFirstChild("CatchFish")
        
        if catchRemote then
            catchRemote:FireServer(fakeFish)
            return fakeFish
        end
        return nil
    end)
    
    if success3 then
        return result
    else
        print("❌ Error in catchFish:", result)
        return nil
    end
end

getgenv().setRarity = function(rarity)
    CheatConfig.SelectedRarity = rarity
    print("🎯 Rarity set to: " .. rarity)
end

getgenv().setWeight = function(min, max)
    CheatConfig.MinWeight = min
    CheatConfig.MaxWeight = max
    print("⚖️ Weight set to: " .. min .. "-" .. max .. "kg")
end

print("========================================")
print("   READY TO USE!")
print("   Commands available:")
print("   - catchFish('Unknown')")
print("   - setRarity('Legendary')")
print("   - setWeight(300, 800)")
print("========================================")
