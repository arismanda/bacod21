-- Combined Fishing Cheat (Auto Fishing + Auto Casting)
local Player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Load modules
local castingModule, fishingModule

for _, module in pairs(game.ReplicatedStorage.Modules:GetDescendants()) do
    if module.Name == "CastingBtn" and module:IsA("ModuleScript") then
        castingModule = require(module)
    elseif module.Name == "AutoFishingBtn" and module:IsA("ModuleScript") then
        fishingModule = require(module)
    end
end

if not castingModule or not fishingModule then
    warn("[CHEAT] Modules tidak ditemukan!")
    return
end

-- Setup auto fishing
fishingModule.isCanAuto = function() return true end

-- Variables
local autoMode = false
local taskRef

-- Function untuk auto fishing loop
local function startAutoFishingLoop()
    if autoMode then return end
    
    autoMode = true
    print("[AUTO FISHING LOOP] Dimulai...")
    
    taskRef = task.spawn(function()
        while autoMode do
            -- Aktifkan casting
            castingModule.casting = true
            castingModule.castingEvent:Fire(true)
            task.wait(1)
            
            -- Aktifkan auto fishing
            fishingModule._active = true
            fishingModule.autoFishingEvent:Fire(true)
            task.wait(3)
            
            -- Reset untuk loop berikutnya
            castingModule.casting = false
            castingModule.castingEvent:Fire(false)
            task.wait(1)
        end
    end)
end

local function stopAutoFishingLoop()
    autoMode = false
    if taskRef then
        task.cancel(taskRef)
    end
    print("[AUTO FISHING LOOP] Dihentikan")
end

-- Hotkey control
UIS.InputBegan:Connect(function(input, processed)
    if not processed then
        -- F10: Toggle auto fishing loop
        if input.KeyCode == Enum.KeyCode.F10 then
            if autoMode then
                stopAutoFishingLoop()
            else
                startAutoFishingLoop()
            end
        end
        
        -- F11: Toggle casting only
        if input.KeyCode == Enum.KeyCode.F11 then
            castingModule:onClick()
        end
        
        -- F12: Toggle auto fishing only
        if input.KeyCode == Enum.KeyCode.F12 then
            if fishingModule._active then
                fishingModule:_disableAutoFishing()
            else
                fishingModule:_enableAutoFishing()
            end
        end
    end
end)

-- Show buttons
castingModule:Show()
fishingModule:Show()

-- Notifikasi
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "FISHING CHEAT",
    Text = "Script loaded! F10: Auto Loop, F11: Cast, F12: Auto Fish",
    Duration = 5
})

print("[CHEAT] Fishing Cheat Package loaded!")
