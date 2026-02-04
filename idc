-- Auto Fishing Cheat dengan Path yang Benar
local Player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Path module berdasarkan informasi Anda
local modulePath = game:GetService("ReplicatedStorage").Modules.UI.Buttons.AutoFishing

if not modulePath then
    warn("[CHEAT ERROR] Module tidak ditemukan di path tersebut!")
    return
end

-- Load module
local fishingModule = require(modulePath)

if not fishingModule then
    warn("[CHEAT ERROR] Gagal load module!")
    return
end

print("[CHEAT] Module ditemukan di:", modulePath:GetFullName())

-- Override fungsi isCanAuto untuk bypass syarat
fishingModule.isCanAuto = function(self)
    print("[CHEAT] Bypassing playtime & gamepass check")
    return true -- Selalu return true
end

-- Simpan fungsi asli untuk referensi
local originalEnable = fishingModule._enableAutoFishing
local originalDisable = fishingModule._disableAutoFishing

-- Override _enableAutoFishing untuk bypass semua
fishingModule._enableAutoFishing = function(self)
    print("[CHEAT] Enabling auto fishing (bypassed)")
    
    -- Langsung aktifkan tanpa cek
    fishingModule._active = true
    self.autoFishingEvent:Fire(true)
    
    -- Update UI button jika ada
    local autoBtn = Player.PlayerGui.GameGui:FindFirstChild("AutoFishingBtn")
    if autoBtn then
        autoBtn.TextLabel.Text = "AUTO: ON"
        if autoBtn:FindFirstChild("CanvasGroup") then
            autoBtn.CanvasGroup.Vector.BackgroundColor3 = Color3.fromRGB(83, 255, 57)
        end
    end
    
    -- Notifikasi
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎣 AUTO FISHING",
        Text = "DIAKTIFKAN (CHEAT)",
        Duration = 3,
        Icon = "rbxassetid://4456171839"
    })
end

-- Override _disableAutoFishing
fishingModule._disableAutoFishing = function(self)
    fishingModule._active = false
    self.autoFishingEvent:Fire(false)
    
    -- Update UI
    local autoBtn = Player.PlayerGui.GameGui:FindFirstChild("AutoFishingBtn")
    if autoBtn then
        autoBtn.TextLabel.Text = "AUTO: OFF"
        if autoBtn:FindFirstChild("CanvasGroup") then
            autoBtn.CanvasGroup.Vector.BackgroundColor3 = Color3.fromRGB(255, 77, 41)
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎣 AUTO FISHING",
        Text = "DIMATIKAN",
        Duration = 2
    })
end

-- Hotkey: F5 untuk toggle
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F5 then
        if fishingModule._active then
            fishingModule:_disableAutoFishing()
        else
            fishingModule:_enableAutoFishing()
        end
    end
end)

-- Cek dan show button
if fishingModule.Show then
    fishingModule:Show()
end

-- Auto enable saat inject
task.wait(1)
fishingModule:_enableAutoFishing()

print("======================================")
print("🎣 AUTO FISHING CHEAT LOADED!")
print("📍 Module Path: Modules.UI.Buttons.AutoFishing")
print("🔥 Hotkey: F5 (Toggle Auto Fishing)")
print("✅ Bypass: Playtime 50 jam & Gamepass")
print("======================================")
