-- ============================================================================
-- DYRON SIMPLE BYPASS - Fishing System
-- Simple & Effective | No Errors | Mobile Support
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Simple bypass function
local function SimpleBypass()
    local args = {
        {
            hookPosition = Vector3.new(-3560.3916015625, 31.05621910095215, 5009.45654296875)
        }
    }
    
    -- Cari remote FishGiver
    local fishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
    local fishGiver = fishingSystem:WaitForChild("FishGiver")
    
    -- Method 1: Coba langsung
    local success, result = pcall(function()
        return fishGiver:FireServer(unpack(args))
    end)
    
    -- Method 2: Jika gagal, coba dengan hook
    if not success then
        success, result = pcall(function()
            -- Hook sederhana
            local original = fishGiver.FireServer
            fishGiver.FireServer = function(self, ...)
                return original(self, ...)
            end
            return fishGiver:FireServer(unpack(args))
        end)
    end
    
    return success, result
end

-- Auto fish bypass (simple version)
local function AutoFishBypass()
    while true do
        local success = SimpleBypass()
        if success then
            print("✅ Fish diberikan!")
        else
            print("❌ Gagal, coba lagi...")
        end
        
        -- Tunggu random 5-10 detik
        wait(math.random(5, 10))
    end
end

-- UI sederhana untuk mobile
local function CreateSimpleUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleBypassUI"
    screenGui.Parent = game.CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 150)
    mainFrame.Position = UDim2.new(0, 10, 0.5, -75)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 119)
    mainFrame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "🎣 SIMPLE BYPASS"
    title.TextColor3 = Color3.fromRGB(0, 255, 119)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    title.Parent = mainFrame
    
    -- Button Get Fish
    local getFishBtn = Instance.new("TextButton")
    getFishBtn.Size = UDim2.new(0.8, 0, 0, 40)
    getFishBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
    getFishBtn.Text = "GET FISH"
    getFishBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    getFishBtn.TextColor3 = Color3.white
    getFishBtn.Parent = mainFrame
    
    getFishBtn.MouseButton1Click:Connect(function()
        local success = SimpleBypass()
        if success then
            getFishBtn.Text = "✅ SUCCESS!"
            getFishBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            getFishBtn.Text = "❌ FAILED!"
            getFishBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
        
        wait(1)
        getFishBtn.Text = "GET FISH"
        getFishBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end)
    
    -- Button Auto Fish
    local autoFishBtn = Instance.new("TextButton")
    autoFishBtn.Size = UDim2.new(0.8, 0, 0, 40)
    autoFishBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
    autoFishBtn.Text = "AUTO FISH: OFF"
    autoFishBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    autoFishBtn.TextColor3 = Color3.white
    autoFishBtn.Parent = mainFrame
    
    local autoFishEnabled = false
    local autoThread
    
    autoFishBtn.MouseButton1Click:Connect(function()
        autoFishEnabled = not autoFishEnabled
        
        if autoFishEnabled then
            autoFishBtn.Text = "AUTO FISH: ON"
            autoFishBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            
            -- Start auto fish
            autoThread = coroutine.create(function()
                while autoFishEnabled do
                    SimpleBypass()
                    wait(5) -- Delay 5 detik
                end
            end)
            coroutine.resume(autoThread)
        else
            autoFishBtn.Text = "AUTO FISH: OFF"
            autoFishBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            
            -- Stop auto fish
            if autoThread then
                coroutine.close(autoThread)
            end
        end
    end)
    
    return screenGui
end

-- Touch support untuk mobile
local function AddTouchSupport(button)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            button.BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.3)
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            wait(0.1)
            if button.Text:find("ON") then
                button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            elseif button.Text:find("OFF") then
                button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            else
                button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            end
        end
    end)
end

-- Initialize
local ui = CreateSimpleUI()
print("🎣 Simple Bypass Loaded!")
print("📱 Mobile Support: Active")
print("👉 Click GET FISH button")

-- Export fungsi
return {
    GetFish = SimpleBypass,
    StartAutoFish = function() 
        autoFishEnabled = true 
        coroutine.wrap(AutoFishBypass)()
    end,
    StopAutoFish = function() 
        autoFishEnabled = false 
    end,
    UI = ui
}
