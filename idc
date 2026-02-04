-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2026-02-04 06:33:39
-- Luau version 6, Types version 3
-- Time taken: 0.005274 seconds

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AutoFishingBtn_upvr = game.Players.LocalPlayer.PlayerGui:WaitForChild("GameGui", 22):WaitForChild("AutoFishingBtn", 11)
local Effect_upvr = require(game.ReplicatedStorage.Modules.UI.Effect)
local module_upvr = {
	_initialized = false;
	_active = true;
	_isDestroyed = false;
	_janitor = require(ReplicatedStorage.Packages.Janitor).new();
	autoFishingEvent = require(ReplicatedStorage.Packages.Signal).new();
}
function module_upvr._disableAutoFishing(arg1) -- Line 19
	module_upvr._active = false
	arg1.autoFishingEvent:Fire(false)
	AutoFishingBtn_upvr.TextLabel.Text = "AUTO: OFF"
	AutoFishingBtn_upvr.CanvasGroup.Vector.BackgroundColor3 = Color3.fromRGB(255, 77, 41)
end

-- MODIFIKASI: Selalu return true untuk bypass playtime
function module_upvr.isCanAuto(arg1) -- Line 25
	return true
end

local InfoPrompt_upvr = require(game.ReplicatedStorage.Modules.UI.Menus.InfoPrompt)
local Holder_upvr = require(game.ReplicatedStorage.Modules.UI.HUD.Holder)

-- MODIFIKASI: Hapus pengecekan playtime 50 jam
function module_upvr._enableAutoFishing(arg1) -- Line 36
	module_upvr._active = true
	arg1.autoFishingEvent:Fire(true)
	AutoFishingBtn_upvr.TextLabel.Text = "AUTO: ON"
	AutoFishingBtn_upvr.CanvasGroup.Vector.BackgroundColor3 = Color3.fromRGB(83, 255, 57)
end

function module_upvr.Init(arg1) -- Line 47
	if arg1._initialized and not arg1._isDestroyed then
		warn("AutoFishing:Init() called multiple times - ignoring subsequent calls")
	else
		arg1:Hide()
		arg1.Enabled = true
		arg1:ListenClick()
		arg1._initialized = true
		Effect_upvr.SetupHover(AutoFishingBtn_upvr)
	end
end

function module_upvr.ListenClick(arg1) -- Line 62
	AutoFishingBtn_upvr.Activated:Connect(function()
		if arg1._active then
			arg1:_disableAutoFishing()
		else
			arg1:_enableAutoFishing()
		end
	end)
end

function module_upvr.ToggleVisibility(arg1) -- Line 72
	AutoFishingBtn_upvr.Visible = not AutoFishingBtn_upvr.Visible
end

function module_upvr.Hide(arg1) -- Line 76
	AutoFishingBtn_upvr.Visible = false
	arg1:_disableAutoFishing()
end

function module_upvr.Show(arg1) -- Line 81
	AutoFishingBtn_upvr.Visible = true
	Effect_upvr.SlideIn(AutoFishingBtn_upvr, "Down", 0.3)
end

function module_upvr.Destroy(arg1) -- Line 86
	arg1._isDestroyed = true
	arg1._janitor:Destroy()
	arg1._initialized = false
end

return module_upvr
