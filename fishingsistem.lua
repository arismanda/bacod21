-- ============================================
-- ULTRA SIMPLE FISHING CHEAT
-- No errors, simple GUI
-- ============================================

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Config
local CheatConfig = {
    SelectedRarity = "Unknown",
    MinWeight = 200,
    MaxWeight = 999
}

-- Simple colors
local RarityColors = {
    Unknown = Color3.fromRGB(190, 0, 3),
    Legendary = Color3.fromRGB(255, 128, 0),
    Epic = Color3.fromRGB(160, 30, 255),
    Rare = Color3.fromRGB(30, 100, 255),
    Uncommon = Color3.fromRGB(30, 255, 30),
    Common = Color3.fromRGB(200, 200, 200)
}

-- Simple fish list
local FishList = {
    Unknown = {"Ancient Relic Crocodile", "Ancient Whale", "El Maja", "Megalodon"},
    Legendary = {"Plasma Shark"},
    Epic = {"Loving Shark", "Monster Shark", "Queen Crab", "Pink Dolphin"},
    Rare = {"Lion Fish", "Luminous Fish", "Zombie Shark", "Wraithfin Abyssal"},
    Uncommon = {"Dead Spooky Koi Fish", "Dead Scary Clownfish", "Jellyfish"},
    Common = {"Boar Fish", "Blackcap Basslet", "Pumpkin Carved Shark", "Freshwater Piranha", "Hermit Crab", "Goliath Tiger", "Fangtooth"}
}

-- Create fake fish
local function CreateFakeFish()
    local rarity = CheatConfig.SelectedRarity
    local fishNames = FishList[rarity] or FishList["Common"]
    local fishName = fishNames[math.random(1, #fishNames)]
    local weight = math.random(CheatConfig.MinWeight * 10, CheatConfig.MaxWeight * 10) / 10
    
    return {
        Name = fishName,
        Weight = weight,
        Rarity = rarity
    }
end

-- Hook fishing system
local function SetupHook()
    local FishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
    if not FishingSystem then return false end
    
    -- Find start remote
    local startRemote = FishingSystem:FindFirstChild("StartFishing") or 
                       FishingSystem:FindFirstChild("BeginFishing")
    
    -- Find catch remote
    local catchRemote = FishingSystem:FindFirstChild("CatchFish") or 
                       FishingSystem:FindFirstChild("CompleteFishing")
    
    if startRemote and catchRemote then
        local originalFire = startRemote.FireServer
        
        startRemote.FireServer = function(self, ...)
            local result = originalFire(self, ...)
            
            -- Auto catch after fishing starts
            task.wait(0.2)
            
            local fakeFish = CreateFakeFish()
            catchRemote:FireServer(fakeFish)
            
            print("🎣 Caught: " .. fakeFish.Name .. " (" .. fakeFish.Weight .. "kg)")
            
            return result
        end
        
        return true
    end
    
    return false
end

-- Simple GUI
local function CreateSimpleGUI()
    -- Create screen
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui
    screen.Name = "FishCheat"
    
    -- Main frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 250, 0, 300)
    main.Position = UDim2.new(0.5, -125, 0.5, -150)
    main.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    main.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main
    
    main.Parent = screen
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "FISH CHEAT"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = RarityColors.Unknown
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = main
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = title
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = title
    
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -10, 1, -50)
    content.Position = UDim2.new(0, 5, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Rarity label
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Text = "Select Rarity:"
    rarityLabel.Size = UDim2.new(1, 0, 0, 25)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.TextColor3 = Color3.new(1, 1, 1)
    rarityLabel.Font = Enum.Font.Gotham
    rarityLabel.TextSize = 16
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Parent = content
    
    -- Rarity buttons
    local rarities = {"Unknown", "Legendary", "Epic", "Rare", "Uncommon", "Common"}
    
    for i, rarity in pairs(rarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, (i-1) * 35 + 30)
        btn.BackgroundColor3 = RarityColors[rarity]
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        btn.Parent = content
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = rarity
            print("Selected: " .. rarity)
        end)
    end
    
    -- Weight section
    local weightLabel = Instance.new("TextLabel")
    weightLabel.Text = "Weight: " .. CheatConfig.MinWeight .. "-" .. CheatConfig.MaxWeight .. "kg"
    weightLabel.Size = UDim2.new(1, 0, 0, 25)
    weightLabel.Position = UDim2.new(0, 0, 0, 240)
    weightLabel.BackgroundTransparency = 1
    weightLabel.TextColor3 = Color3.new(1, 1, 1)
    weightLabel.Font = Enum.Font.Gotham
    weightLabel.TextSize = 16
    weightLabel.TextXAlignment = Enum.TextXAlignment.Left
    weightLabel.Parent = content
    
    -- Weight buttons
    local weightFrame = Instance.new("Frame")
    weightFrame.Size = UDim2.new(1, 0, 0, 40)
    weightFrame.Position = UDim2.new(0, 0, 0, 265)
    weightFrame.BackgroundTransparency = 1
    weightFrame.Parent = content
    
    local function UpdateWeightLabel()
        weightLabel.Text = "Weight: " .. CheatConfig.MinWeight .. "-" .. CheatConfig.MaxWeight .. "kg"
    end
    
    -- Minus
    local minusBtn = Instance.new("TextButton")
    minusBtn.Text = "-100"
    minusBtn.Size = UDim2.new(0.4, 0, 1, 0)
    minusBtn.Position = UDim2.new(0, 0, 0, 0)
    minusBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 16
    minusBtn.Parent = weightFrame
    
    minusBtn.MouseButton1Click:Connect(function()
        if CheatConfig.MinWeight > 100 then
            CheatConfig.MinWeight = CheatConfig.MinWeight - 100
            CheatConfig.MaxWeight = CheatConfig.MaxWeight - 100
            UpdateWeightLabel()
        end
    end)
    
    -- Plus
    local plusBtn = Instance.new("TextButton")
    plusBtn.Text = "+100"
    plusBtn.Size = UDim2.new(0.4, 0, 1, 0)
    plusBtn.Position = UDim2.new(0.6, 0, 0, 0)
    plusBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 16
    plusBtn.Parent = weightFrame
    
    plusBtn.MouseButton1Click:Connect(function()
        CheatConfig.MinWeight = CheatConfig.MinWeight + 100
        CheatConfig.MaxWeight = CheatConfig.MaxWeight + 100
        UpdateWeightLabel()
    end)
    
    return screen
end

-- Mini GUI (optional)
local function CreateMiniGUI()
    local screen = Instance.new("ScreenGui")
    screen.Parent = game.CoreGui
    screen.Name = "FishCheatMini"
    
    -- Floating button
    local fab = Instance.new("TextButton")
    fab.Text = "🎣"
    fab.Size = UDim2.new(0, 60, 0, 60)
    fab.Position = UDim2.new(1, -70, 0.5, -30)
    fab.BackgroundColor3 = RarityColors.Unknown
    fab.TextColor3 = Color3.new(1, 1, 1)
    fab.Font = Enum.Font.GothamBold
    fab.TextSize = 24
    fab.ZIndex = 999
    
    local fabCorner = Instance.new("UICorner")
    fabCorner.CornerRadius = UDim.new(1, 0)
    fabCorner.Parent = fab
    
    fab.Parent = screen
    
    -- Dropdown menu
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 120, 0, 150)
    menu.Position = UDim2.new(1, -130, fab.Position.Y.Scale, fab.Position.Y.Offset)
    menu.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    menu.BackgroundTransparency = 0.1
    menu.Visible = false
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 8)
    menuCorner.Parent = menu
    
    menu.Parent = screen
    
    -- Rarity options
    local options = {"Unknown", "Legendary", "Epic", "Rare"}
    
    for i, option in pairs(options) do
        local btn = Instance.new("TextButton")
        btn.Text = option
        btn.Size = UDim2.new(0.9, 0, 0, 30)
        btn.Position = UDim2.new(0.05, 0, 0, (i-1) * 35 + 10)
        btn.BackgroundColor3 = RarityColors[option]
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = menu
        
        btn.MouseButton1Click:Connect(function()
            CheatConfig.SelectedRarity = option
            menu.Visible = false
            print("Set: " .. option)
        end)
    end
    
    -- Toggle menu
    fab.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)
    
    return screen
end

-- Initialize
print("========================================")
print("   SIMPLE FISHING CHEAT")
print("   No errors, just works")
print("========================================")

-- Wait for game
task.wait(2)

-- Setup hook
local hookSuccess = SetupHook()
if hookSuccess then
    print("✅ Hook installed")
else
    print("⚠️ Hook failed - manual mode")
end

-- Create GUI
CreateSimpleGUI()
print("✅ GUI created")

-- Export commands
getgenv().setRarity = function(rarity)
    CheatConfig.SelectedRarity = rarity
    print("Rarity: " .. rarity)
end

getgenv().setWeight = function(min, max)
    CheatConfig.MinWeight = min
    CheatConfig.MaxWeight = max
    print("Weight: " .. min .. "-" .. max .. "kg")
end

print("========================================")
print("   COMMANDS:")
print("   setRarity('Unknown')")
print("   setWeight(200, 999)")
print("========================================")
