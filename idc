-- Auto Fishing Cheat - No GUI, No Playtime Requirement
local Player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Tunggu GUI load
repeat task.wait() until Player.PlayerGui:FindFirstChild("GameGui")
repeat task.wait() until Player.PlayerGui.GameGui:FindFirstChild("AutoFishingBtn")

-- Load module
local autoFishingModule
for _, obj in pairs(game.ReplicatedStorage.Modules:GetDescendants()) do
    if obj.Name == "AutoFishingBtn" and obj:IsA("ModuleScript") then
        autoFishingModule = require(obj)
        break
    end
end

if not autoFishingModule then
    warn("[CHEAT] AutoFishing module tidak ditemukan!")
    return
end

-- Override fungsi isCanAuto untuk bypass playtime dan gamepass
autoFishingModule.isCanAuto = function()
    return true -- Selalu return true, tidak peduli playtime atau gamepass
end

-- Simpan fungsi asli untuk restore jika perlu
local originalEnable = autoFishingModule._enableAutoFishing
local originalDisable = autoFishingModule._disableAutoFishing

-- Override _enableAutoFishing untuk bypass semua check
autoFishingModule._enableAutoFishing = function(self)
    -- Langsung enable tanpa cek kondisi
    autoFishingModule._active = true
    self.autoFishingEvent:Fire(true)
    
    -- Update UI
    local btn = Player.PlayerGui.GameGui.AutoFishingBtn
    btn.TextLabel.Text = "AUTO: ON"
    btn.CanvasGroup.Vector.BackgroundColor3 = Color3.fromRGB(83, 255, 57)
    
    -- Notifikasi
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎣 AUTO FISHING",
        Text = "AKTIF (BYPASSED)",
        Duration = 3
    })
end

-- Override _disableAutoFishing
autoFishingModule._disableAutoFishing = function(self)
    autoFishingModule._active = false
    self.autoFishingEvent:Fire(false)
    
    -- Update UI
    local btn = Player.PlayerGui.GameGui.AutoFishingBtn
    btn.TextLabel.Text = "AUTO: OFF"
    btn.CanvasGroup.Vector.BackgroundColor3 = Color3.fromRGB(255, 77, 41)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎣 AUTO FISHING",
        Text = "NON-AKTIF",
        Duration = 3
    })
end

-- Hotkey: F5 untuk toggle auto fishing
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F5 then
        if autoFishingModule._active then
            autoFishingModule:_disableAutoFishing()
        else
            autoFishingModule:_enableAutoFishing()
        end
    end
end)

-- Force show button dan langsung aktifkan
autoFishingModule:Show()
autoFishingModule:_enableAutoFishing()

print("=======================================")
print("🎣 AUTO FISHING CHEAT LOADED!")
print("✅ Playtime 50 jam: BYPASSED")
print("✅ Gamepass requirement: BYPASSED")
print("🔥 Hotkey: F5 (Toggle Auto Fishing)")
print("=======================================")
