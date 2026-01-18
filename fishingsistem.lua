-- ============================================
-- INSTANT CATCH CHEAT
-- Menggunakan module_2_upvr secara langsung
-- ============================================

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Config
local CheatConfig = {
    SelectedRarity = "Unknown",
    MinWeight = 200,
    MaxWeight = 999,
    Enabled = true
}

-- ============================================
-- INSTANT CATCH FUNCTION
-- ============================================

local function SetupInstantCatch()
    -- Cari FishingSystem
    local FishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
    if not FishingSystem then
        print("❌ FishingSystem tidak ditemukan")
        return false
    end
    
    -- Cari remote events
    local startRemote = FishingSystem:FindFirstChild("StartFishing")
    local catchRemote = FishingSystem:FindFirstChild("CatchFish")
    
    if not startRemote or not catchRemote then
        print("❌ Remote events tidak ditemukan")
        return false
    end
    
    -- Hook StartFishing remote
    local originalFire = startRemote.FireServer
    
    startRemote.FireServer = function(self, ...)
        local args = {...}
        local result = originalFire(self, unpack(args))
        
        if CheatConfig.Enabled then
            -- Tunggu sebentar
            task.wait(0.2)
            
            -- Buat ikan sesuai rarity
            local fishData = {
                Name = "",
                Weight = 0,
                Rarity = CheatConfig.SelectedRarity,
                Price = 0
            }
            
            -- Ambil ikan dari module
            if module_2_upvr.FishTable then
                local availableFish = {}
                for _, fish in pairs(module_2_upvr.FishTable) do
                    if fish.rarity == CheatConfig.SelectedRarity then
                        table.insert(availableFish, fish)
                    end
                end
                
                if #availableFish > 0 then
                    local selectedFish = availableFish[math.random(1, #availableFish)]
                    fishData.Name = selectedFish.name
                    fishData.Weight = math.random(CheatConfig.MinWeight * 10, CheatConfig.MaxWeight * 10) / 10
                    
                    -- Hitung harga jika fungsi ada
                    if module_2_upvr.CalculateFishPrice then
                        fishData.Price = module_2_upvr.CalculateFishPrice(fishData.Weight, fishData.Rarity)
                    else
                        fishData.Price = fishData.Weight * 100
                    end
                else
                    -- Fallback jika tidak ada ikan dengan rarity tersebut
                    fishData.Name = "Boar Fish"
                    fishData.Weight = math.random(CheatConfig.MinWeight * 10, CheatConfig.MaxWeight * 10) / 10
                    fishData.Price = fishData.Weight * 100
                end
            else
                -- Simple fallback
                fishData.Name = "Unknown Fish"
                fishData.Weight = math.random(200, 999)
                fishData.Price = fishData.Weight * 100
            end
            
            -- Fire catch event
            catchRemote:FireServer(fishData)
            
            print("🎣 Caught: " .. fishData.Name .. " (" .. fishData.Weight .. "kg) - " .. fishData.Rarity)
        end
        
        return result
    end
    
    print("✅ Instant Catch activated!")
    return true
end

-- ============================================
-- SIMPLE GUI
-- ============================================

local function CreateGUI()
    -- Buat ScreenGui
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui
    screen.Name = "InstantCatchGUI"
    
    -- Frame utama
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 250, 0, 280)
    main.Position = UDim2.new(0.5, -125, 0.5, -140)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main
    
    main.Parent = screen
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    header.Parent = main
    
    -- Judul
    local title = Instance.new("TextLabel")
    title.Text = "INSTANT CATCH"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = header
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = header
    
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
    
    -- Konten
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -10, 1, -50)
    content.Position = UDim2.new(0, 5, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Status toggle
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = content
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Text = "Instant Catch:"
    toggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.TextColor3 = Color3.new(1, 1, 1)
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Text = CheatConfig.Enabled and "ON" or "OFF"
    toggleBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
    toggleBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
    toggleBtn.BackgroundColor3 = CheatConfig.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = toggleFrame
    
    toggleBtn.MouseButton1Click:Connect(function()
        CheatConfig.Enabled = not CheatConfig.Enabled
        toggleBtn.Text = CheatConfig.Enabled and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = CheatConfig.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        print("Instant Catch: " .. (CheatConfig.Enabled and "ON" or "OFF"))
    end)
    
    -- Rarity selection
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Text = "Select Rarity:"
    rarityLabel.Size = UDim2.new(1, 0, 0, 25)
    rarityLabel.Position = UDim2.new(0, 0, 0, 50)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.TextColor3 = Color3.new(1, 1, 1)
    rarityLabel.Font = Enum.Font.Gotham
    rarityLabel.TextSize = 14
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Parent = content
    
    -- Dapatkan rarity dari module
    local rarities = {}
    if module_2_upvr.RarityColors then
        for rarity, _ in pairs(module_2_upvr.RarityColors) do
            table.insert(rarities, rarity)
        end
    else
        rarities = {"Unknown", "Legendary", "Epic", "Rare", "Uncommon", "Common"}
    end
    
    table.sort(rarities, function(a, b)
        local orderA = module_2_upvr.rarityOrder and module_2_upvr.rarityOrder[a] or 1
        local orderB = module_2_upvr.rarityOrder and module_2_upvr.rarityOrder[b] or 1
        return orderA > orderB
    end)
    
    -- Buat buttons untuk rarity
    for i, rarity in ipairs(rarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.Position = UDim2.new(0, 0, 0, (i-1) * 30 + 80)
        
        -- Gunakan warna dari module jika ada
        if module_2_upvr.GetRarityColor then
            local success, color = pcall(function()
                return module_2_upvr.GetRarityColor(rarity)
            end)
            if success then
                btn.BackgroundColor3 = color
            else
                btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end
        else
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
        
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = content
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = rarity
            print("Selected: " .. rarity)
        end)
    end
    
    -- Weight control
    local weightLabel = Instance.new("TextLabel")
    weightLabel.Text = "Weight: " .. CheatConfig.MinWeight .. "-" .. CheatConfig.MaxWeight .. "kg"
    weightLabel.Size = UDim2.new(1, 0, 0, 25)
    weightLabel.Position = UDim2.new(0, 0, 0, 260)
    weightLabel.BackgroundTransparency = 1
    weightLabel.TextColor3 = Color3.new(1, 1, 1)
    weightLabel.Font = Enum.Font.Gotham
    weightLabel.TextSize = 14
    weightLabel.TextXAlignment = Enum.TextXAlignment.Left
    weightLabel.Parent = content
    
    -- Weight buttons (simplified)
    local weightFrame = Instance.new("Frame")
    weightFrame.Size = UDim2.new(1, 0, 0, 30)
    weightFrame.Position = UDim2.new(0, 0, 0, 285)
    weightFrame.BackgroundTransparency = 1
    weightFrame.Parent = content
    
    local function UpdateWeight()
        weightLabel.Text = "Weight: " .. CheatConfig.MinWeight .. "-" .. CheatConfig.MaxWeight .. "kg"
    end
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Text = "-100"
    minusBtn.Size = UDim2.new(0.45, 0, 1, 0)
    minusBtn.Position = UDim2.new(0, 0, 0, 0)
    minusBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 12
    minusBtn.Parent = weightFrame
    
    minusBtn.MouseButton1Click:Connect(function()
        if CheatConfig.MinWeight > 100 then
            CheatConfig.MinWeight = CheatConfig.MinWeight - 100
            CheatConfig.MaxWeight = CheatConfig.MaxWeight - 100
            UpdateWeight()
        end
    end)
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Text = "+100"
    plusBtn.Size = UDim2.new(0.45, 0, 1, 0)
    plusBtn.Position = UDim2.new(0.55, 0, 0, 0)
    plusBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 12
    plusBtn.Parent = weightFrame
    
    plusBtn.MouseButton1Click:Connect(function()
        CheatConfig.MinWeight = CheatConfig.MinWeight + 100
        CheatConfig.MaxWeight = CheatConfig.MaxWeight + 100
        UpdateWeight()
    end)
    
    -- Manually trigger catch button
    local catchBtn = Instance.new("TextButton")
    catchBtn.Text = "CATCH NOW"
    catchBtn.Size = UDim2.new(1, 0, 0, 40)
    catchBtn.Position = UDim2.new(0, 0, 0, 320)
    catchBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    catchBtn.TextColor3 = Color3.new(1, 1, 1)
    catchBtn.Font = Enum.Font.GothamBold
    catchBtn.TextSize = 16
    catchBtn.Parent = content
    
    catchBtn.MouseButton1Click:Connect(function()
        local FishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
        if FishingSystem then
            local catchRemote = FishingSystem:FindFirstChild("CatchFish")
            if catchRemote then
                local fishData = {
                    Name = "",
                    Weight = math.random(CheatConfig.MinWeight * 10, CheatConfig.MaxWeight * 10) / 10,
                    Rarity = CheatConfig.SelectedRarity,
                    Price = 0
                }
                
                -- Get fish name from module
                if module_2_upvr.FishTable then
                    for _, fish in pairs(module_2_upvr.FishTable) do
                        if fish.rarity == CheatConfig.SelectedRarity then
                            fishData.Name = fish.name
                            break
                        end
                    end
                end
                
                if fishData.Name == "" then
                    fishData.Name = "Unknown Fish"
                end
                
                catchRemote:FireServer(fishData)
                print("🎣 Manual catch: " .. fishData.Name)
            end
        end
    end)
    
    return screen
end

-- ============================================
-- MINIMAL GUI VERSION
-- ============================================

local function CreateMinimalGUI()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui
    screen.Name = "CatchCheatMini"
    
    -- Floating button
    local fab = Instance.new("TextButton")
    fab.Text = "🎣"
    fab.Size = UDim2.new(0, 50, 0, 50)
    fab.Position = UDim2.new(1, -60, 0.5, -25)
    fab.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    fab.TextColor3 = Color3.new(1, 1, 1)
    fab.Font = Enum.Font.GothamBold
    fab.TextSize = 20
    fab.ZIndex = 999
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = fab
    
    fab.Parent = screen
    
    -- Dropdown menu
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 150, 0, 120)
    menu.Position = UDim2.new(1, -160, fab.Position.Y.Scale, fab.Position.Y.Offset)
    menu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    menu.BackgroundTransparency = 0.1
    menu.Visible = false
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 8)
    menuCorner.Parent = menu
    
    menu.Parent = screen
    
    -- Top rarity options
    local topRarities = {"Unknown", "Legendary", "Epic", "Rare"}
    
    for i, rarity in ipairs(topRarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity
        btn.Size = UDim2.new(0.9, 0, 0, 25)
        btn.Position = UDim2.new(0.05, 0, 0, (i-1) * 28 + 5)
        
        -- Try to get color from module
        local btnColor = Color3.fromRGB(100, 100, 100)
        if module_2_upvr.GetRarityColor then
            local success, color = pcall(function()
                return module_2_upvr.GetRarityColor(rarity)
            end)
            if success then
                btnColor = color
            end
        end
        
        btn.BackgroundColor3 = btnColor
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.Parent = menu
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = rarity
            menu.Visible = false
            print("Set: " .. rarity)
        end)
    end
    
    -- Toggle menu
    fab.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)
    
    return screen
end

-- ============================================
-- INITIALIZE
-- ============================================

print("========================================")
print("   INSTANT CATCH CHEAT")
print("   Module Based")
print("========================================")

-- Wait for game
task.wait(2)

-- Setup instant catch
local hookSuccess = SetupInstantCatch()

-- Create GUI
if hookSuccess then
    print("✅ Hook successful")
    
    -- Pilih GUI style
    local useMinimal = false -- false untuk full GUI, true untuk minimal
    
    if useMinimal then
        CreateMinimalGUI()
        print("📱 Minimal GUI created")
    else
        CreateGUI()
        print("💻 Full GUI created")
    end
else
    print("❌ Hook failed")
    CreateGUI() -- Buat GUI anyway untuk manual catch
end

-- Export commands
getgenv().setRarity = function(rarity)
    CheatConfig.SelectedRarity = rarity
    print("Rarity set to: " .. rarity)
end

getgenv().setWeight = function(min, max)
    CheatConfig.MinWeight = min
    CheatConfig.MaxWeight = max
    print("Weight set to: " .. min .. "-" .. max .. "kg")
end

getgenv().toggleCatch = function()
    CheatConfig.Enabled = not CheatConfig.Enabled
    print("Instant Catch: " .. (CheatConfig.Enabled and "ON" or "OFF"))
end

