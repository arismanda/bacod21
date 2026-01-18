-- ============================================
-- SIMPLE FISHING CHEAT v1.0
-- Instant Catch dengan Rarity Control
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- KONFIGURASI CHEAT
-- ============================================

local CheatConfig = {
    -- Pilih rarity yang mau di-catch
    SelectedRarity = "SECRET", -- "Common", "Uncommon", "Rare", "Epic", "Legendary", "SECRET"
    
    -- Atur weight fish
    MinWeight = 300,  -- Minimal weight dalam kg
    MaxWeight = 500,  -- Maksimal weight dalam kg
    
    -- Auto settings
    AutoFish = false,  -- Auto memancing terus menerus
    AutoSell = false,  -- Auto jual setelah catch
    InstantCatch = true, -- Instant catch tanpa minigame
}

-- ============================================
-- FUNGSI UTAMA
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
    
    -- Fallback jika tidak ada fish dengan rarity tersebut
    for _, fish in pairs(module_upvr.FishTable) do
        table.insert(fishList, fish)
    end
    
    return fishList[math.random(1, #fishList)]
end

local function GenerateFakeFishData()
    local targetFish = GetRandomFishByRarity(CheatConfig.SelectedRarity)
    
    -- Generate random weight dalam range config
    local weight = math.random(CheatConfig.MinWeight * 10, CheatConfig.MaxWeight * 10) / 10
    
    -- Calculate price berdasarkan module_upvr
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
-- HOOK REMOTE FUNCTION
-- ============================================

local function HookFishingSystem()
    -- Cari FishingSystem di ReplicatedStorage
    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 10)
    
    if not FishingSystem then
        warn("[CHEAT] FishingSystem tidak ditemukan!")
        return false
    end
    
    -- Cari remote events
    local StartFishingRemote = FishingSystem:FindFirstChild("StartFishing") or 
                               FishingSystem:FindFirstChild("StartFish") or
                               FishingSystem:FindFirstChild("BeginFishing")
    
    local CatchFishRemote = FishingSystem:FindFirstChild("CatchFish") or 
                           FishingSystem:FindFirstChild("CompleteFishing") or
                           FishingSystem:FindFirstChild("FinishFishing")
    
    if not StartFishingRemote or not CatchFishRemote then
        warn("[CHEAT] Remote events tidak ditemukan!")
        return false
    end
    
    -- Hook StartFishing untuk instant catch
    local originalStart = StartFishingRemote.FireServer
    StartFishingRemote.FireServer = function(self, ...)
        local args = {...}
        
        -- Panggil original function
        originalStart(self, unpack(args))
        
        -- Jika instant catch aktif, langsung catch fish
        if CheatConfig.InstantCatch then
            task.wait(0.5) -- Tunggu sedikit untuk natural feel
            
            local fakeFish = GenerateFakeFishData()
            
            -- Fire catch fish remote
            CatchFishRemote:FireServer(fakeFish)
            
            print(string.format("[CHEAT] Caught: %s | Weight: %.1fkg | Rarity: %s | Price: $%d",
                fakeFish.Name, fakeFish.Weight, fakeFish.Rarity, fakeFish.Price))
            
            -- Auto sell jika aktif
            if CheatConfig.AutoSell then
                local SellRemote = FishingSystem:FindFirstChild("SellFish") or 
                                  FishingSystem:FindFirstChild("SellAllFish")
                
                if SellRemote then
                    task.wait(1)
                    SellRemote:FireServer({fakeFish})
                    print("[CHEAT] Fish sold!")
                end
            end
        end
        
        return nil
    end
    
    print("[CHEAT] Hook berhasil dipasang!")
    print("[CONFIG] Rarity:", CheatConfig.SelectedRarity)
    print("[CONFIG] Weight Range:", CheatConfig.MinWeight, "-", CheatConfig.MaxWeight, "kg")
    
    return true
end

-- ============================================
-- AUTO FISHING BOT (SIMPLE)
-- ============================================

local autoFishing = false

local function StartAutoFishing()
    if autoFishing then return end
    
    autoFishing = true
    
    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
    local StartRemote = FishingSystem:FindFirstChild("StartFishing") or 
                       FishingSystem:FindFirstChild("StartFish")
    
    if not StartRemote then
        warn("[AUTO] Remote tidak ditemukan!")
        autoFishing = false
        return
    end
    
    while autoFishing do
        -- Start fishing
        StartRemote:FireServer("StartFishing", {
            rod = "OWN LordPurple Demon Rod",
            location = LocalPlayer.Character.HumanoidRootPart.Position
        })
        
        -- Tunggu sebelum fishing lagi
        wait(3)
    end
end

local function StopAutoFishing()
    autoFishing = false
end

-- ============================================
-- SIMPLE GUI
-- ============================================

local function CreateSimpleGUI()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui
    screen.Name = "SimpleFishingCheat"
    
    -- Main frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 250, 0, 300)
    main.Position = UDim2.new(0, 10, 0, 10)
    main.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    main.BorderSizePixel = 2
    main.BorderColor3 = Color3.fromRGB(0, 255, 119)
    main.Parent = screen
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "FISHING CHEAT v1.0"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 255, 119)
    title.TextColor3 = Color3.new(0, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.Parent = main
    
    -- Rarity Selection
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Text = "Pilih Rarity Fish:"
    rarityLabel.Size = UDim2.new(0.9, 0, 0, 20)
    rarityLabel.Position = UDim2.new(0.05, 0, 0, 40)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.TextColor3 = Color3.new(1, 1, 1)
    rarityLabel.Parent = main
    
    local rarityDropdown = Instance.new("TextButton")
    rarityDropdown.Text = CheatConfig.SelectedRarity
    rarityDropdown.Size = UDim2.new(0.9, 0, 0, 30)
    rarityDropdown.Position = UDim2.new(0.05, 0, 0, 65)
    rarityDropdown.BackgroundColor3 = module_upvr.GetRarityColor(CheatConfig.SelectedRarity)
    rarityDropdown.TextColor3 = Color3.new(1, 1, 1)
    rarityDropdown.Parent = main
    
    local rarities = {"SECRET", "Legendary", "Epic", "Rare", "Uncommon", "Common"}
    
    rarityDropdown.MouseButton1Click:Connect(function()
        local currentIndex = table.find(rarities, CheatConfig.SelectedRarity) or 1
        local nextIndex = currentIndex % #rarities + 1
        CheatConfig.SelectedRarity = rarities[nextIndex]
        rarityDropdown.Text = CheatConfig.SelectedRarity
        rarityDropdown.BackgroundColor3 = module_upvr.GetRarityColor(CheatConfig.SelectedRarity)
    end)
    
    -- Weight Controls
    local weightLabel = Instance.new("TextLabel")
    weightLabel.Text = string.format("Weight: %d-%d kg", CheatConfig.MinWeight, CheatConfig.MaxWeight)
    weightLabel.Size = UDim2.new(0.9, 0, 0, 20)
    weightLabel.Position = UDim2.new(0.05, 0, 0, 105)
    weightLabel.BackgroundTransparency = 1
    weightLabel.TextColor3 = Color3.new(1, 1, 1)
    weightLabel.Parent = main
    
    local weightMinus = Instance.new("TextButton")
    weightMinus.Text = "-"
    weightMinus.Size = UDim2.new(0.2, 0, 0, 30)
    weightMinus.Position = UDim2.new(0.05, 0, 0, 130)
    weightMinus.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    weightMinus.Parent = main
    
    local weightPlus = Instance.new("TextButton")
    weightPlus.Text = "+"
    weightPlus.Size = UDim2.new(0.2, 0, 0, 30)
    weightPlus.Position = UDim2.new(0.75, 0, 0, 130)
    weightPlus.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    weightPlus.Parent = main
    
    local function UpdateWeight()
        weightLabel.Text = string.format("Weight: %d-%d kg", CheatConfig.MinWeight, CheatConfig.MaxWeight)
    end
    
    weightMinus.MouseButton1Click:Connect(function()
        if CheatConfig.MinWeight > 1 then
            CheatConfig.MinWeight = CheatConfig.MinWeight - 50
            CheatConfig.MaxWeight = CheatConfig.MaxWeight - 50
            UpdateWeight()
        end
    end)
    
    weightPlus.MouseButton1Click:Connect(function()
        CheatConfig.MinWeight = CheatConfig.MinWeight + 50
        CheatConfig.MaxWeight = CheatConfig.MaxWeight + 50
        UpdateWeight()
    end)
    
    -- Toggle Buttons
    local function CreateToggleButton(text, yPos, configKey)
        local btn = Instance.new("TextButton")
        btn.Text = text .. ": " .. (CheatConfig[configKey] and "ON" or "OFF")
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, 0, yPos)
        btn.BackgroundColor3 = CheatConfig[configKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Parent = main
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig[configKey] = not CheatConfig[configKey]
            btn.Text = text .. ": " .. (CheatConfig[configKey] and "ON" or "OFF")
            btn.BackgroundColor3 = CheatConfig[configKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        end)
        
        return btn
    end
    
    CreateToggleButton("Instant Catch", 170, "InstantCatch")
    CreateToggleButton("Auto Sell", 210, "AutoSell")
    
    -- Auto Fish Button
    local autoBtn = Instance.new("TextButton")
    autoBtn.Text = "START AUTO FISH"
    autoBtn.Size = UDim2.new(0.9, 0, 0, 35)
    autoBtn.Position = UDim2.new(0.05, 0, 0, 250)
    autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    autoBtn.TextColor3 = Color3.new(1, 1, 1)
    autoBtn.Parent = main
    
    autoBtn.MouseButton1Click:Connect(function()
        if not autoFishing then
            StartAutoFishing()
            autoBtn.Text = "STOP AUTO FISH"
            autoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        else
            StopAutoFishing()
            autoBtn.Text = "START AUTO FISH"
            autoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -25, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Parent = main
    
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
    
    return screen
end

-- ============================================
-- MANUAL CATCH COMMAND
-- ============================================

local function ManualCatch()
    local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
    local CatchRemote = FishingSystem:FindFirstChild("CatchFish") or 
                       FishingSystem:FindFirstChild("CompleteFishing")
    
    if not CatchRemote then
        warn("[MANUAL] Catch remote tidak ditemukan!")
        return
    end
    
    local fakeFish = GenerateFakeFishData()
    CatchRemote:FireServer(fakeFish)
    
    print(string.format("[MANUAL CATCH] %s | %.1fkg | %s | $%d",
        fakeFish.Name, fakeFish.Weight, fakeFish.Rarity, fakeFish.Price))
    
    return fakeFish
end

-- ============================================
-- INISIALISASI
-- ============================================

print("========================================")
print("   SIMPLE FISHING CHEAT v1.0 LOADED")
print("========================================")
print("Commands:")
print("  - manualCatch() : Catch fish sekali")
print("  - toggleAutoFish() : Toggle auto fishing")
print("========================================")

-- Export fungsi ke global
getgenv().manualCatch = ManualCatch
getgenv().toggleAutoFish = function()
    if autoFishing then
        StopAutoFishing()
        print("[AUTO] Stopped")
    else
        StartAutoFishing()
        print("[AUTO] Started")
    end
end

-- Pasang hook
task.spawn(function()
    wait(2)
    local success = HookFishingSystem()
    if success then
        CreateSimpleGUI()
    end
end)

-- Auto-hook jika module sudah ada
if module_upvr then
    print("[INFO] module_upvr ditemukan!")
    print("[INFO] Ready untuk instant catch!")
else
    warn("[WARNING] module_upvr tidak ditemukan!")
end
