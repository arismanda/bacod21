-- Fishing Simulator Ultimate Exploit
-- Compatible: Synapse X, KRNL, Fluxus, Script-Ware
-- Game: Fishing Simulator (ID akan terdeteksi otomatis)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 10)

if not FishingSystem then
	warn("[EXPLOIT] Game tidak dikenali atau tidak support")
	return
end

-- CONFIGURASI EXPLOIT
local Config = {
	AutoFish = true,
	InstantCatch = true,
	MaxRarity = "Unknown", -- "Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"
	MinWeight = 500, -- KG minimum
	AutoSell = true,
	KeepLegendaryPlus = false,
	WebhookNotify = false,
	WebhookURL = "",
	AntiAFK = true
}

-- OVERRIDE GAME FUNCTIONS
local originalModule
for _, module in pairs(getloadedmodules() or {}) do
	if module.Name == "FishingSystem" or module.Name:find("Fishing") then
		originalModule = require(module)
		break
	end
end

if originalModule then
	-- 1. OVERRIDE RARITY SYSTEM
	local originalGetRarityWithPity = originalModule.GetRarityWithPity
	if originalGetRarityWithPity then
		originalModule.GetRarityWithPity = function(pityTable, rodName, luckMultiplier)
			if Config.InstantCatch then
				-- Force highest rarity
				local rarityOrder = {
					Common = 1,
					Uncommon = 2,
					Rare = 3,
					Epic = 4,
					Legendary = 5,
					Unknown = 6
				}

				-- Return configured rarity
				for rarity, order in pairs(rarityOrder) do
					if rarity == Config.MaxRarity then
						return rarity
					end
				end
				return "Unknown"
			end
			return originalGetRarityWithPity(pityTable, rodName, luckMultiplier)
		end
	end

	-- 2. OVERRIDE FISH WEIGHT
	local originalGenerateFishWeight = originalModule.GenerateFishWeight
	if originalGenerateFishWeight then
		originalModule.GenerateFishWeight = function(fishData, rodLuck, maxWeight)
			if Config.InstantCatch then
				-- Return max possible weight
				local weight = math.max(Config.MinWeight, fishData.maxKg or 1000)
				return math.floor(weight * 10 + 0.5) / 10
			end
			return originalGenerateFishWeight(fishData, rodLuck, maxWeight)
		end
	end

	-- 3. OVERRIDE MINIGAME
	local MinigameRemote = FishingSystem:FindFirstChild("StartMinigame") or FishingSystem:FindFirstChild("Minigame")
	if MinigameRemote then
		local originalFireServer = MinigameRemote.FireServer
		MinigameRemote.FireServer = function(self, ...)
			if Config.InstantCatch then
				-- Auto-complete minigame
				local args = {...}
				if #args > 0 and typeof(args[1]) == "table" then
					-- Simulate perfect minigame
					return true
				end
			end
			return originalFireServer(self, ...)
		end
	end
end

-- AUTO-FISHING SYSTEM
local AutoFishThread
local function StartAutoFishing()
	if AutoFishThread then return end

	AutoFishThread = task.spawn(function()
		while Config.AutoFish do
			-- Find fishing remote
			local fishRemote = FishingSystem:FindFirstChild("CastLine") or 
				FishingSystem:FindFirstChild("StartFishing") or
				FishingSystem:FindFirstChild("FishCast")

			if fishRemote then
				-- Cast line
				pcall(function()
					fishRemote:FireServer()
				end)

				-- Wait for bite (reduced wait time)
				task.wait(0.5)

				-- Trigger catch
				local catchRemote = FishingSystem:FindFirstChild("CatchFish") or 
					FishingSystem:FindFirstChild("ReelIn")
				if catchRemote then
					pcall(function()
						catchRemote:FireServer()
					end)
				end
			end

			-- Random delay to avoid detection
			task.wait(math.random(0.5, 1.5))
		end
	end)
end

-- AUTO-SELL SYSTEM
local function AutoSellFish()
	if not Config.AutoSell then return end

	local sellRemote = FishingSystem:FindFirstChild("SellFish") or 
		FishingSystem:FindFirstChild("SellAllFish")

	if sellRemote then
		pcall(function()
			-- Sell all except Legendary+ if configured
			if Config.KeepLegendaryPlus then
				-- Sell only Common/Uncommon/Rare
				sellRemote:FireServer("Common")
				sellRemote:FireServer("Uncommon")
				sellRemote:FireServer("Rare")
			else
				-- Sell all
				sellRemote:FireServer("All")
			end
		end)
	end
end

-- GUI CREATION
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fishing Simulator Exploit v2.1", "Sentinel")

-- MAIN TAB
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Auto Features")

MainSection:NewToggle("Auto Fish", "Automatically fishes", function(state)
	Config.AutoFish = state
	if state then
		StartAutoFishing()
	else
		AutoFishThread = nil
	end
end)

MainSection:NewToggle("Instant Catch", "No minigame, max rarity", function(state)
	Config.InstantCatch = state
end)

MainSection:NewToggle("Auto Sell", "Automatically sells fish", function(state)
	Config.AutoSell = state
	if state then
		spawn(AutoSellFish)
	end
end)

-- SETTINGS TAB
local SettingsTab = Window:NewTab("Settings")
local RaritySection = SettingsTab:NewSection("Rarity Settings")

local RarityDropdown = RaritySection:NewDropdown("Max Rarity", "Force this rarity", 
	{"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unknown"}, 
	function(selected)
		Config.MaxRarity = selected
	end)
RarityDropdown:SetOption("Unknown")

local WeightSlider = RaritySection:NewSlider("Min Weight (KG)", "Minimum fish weight", 1000, 1, function(value)
	Config.MinWeight = value
end)
WeightSlider:SetValue(500)

local KeepSection = SettingsTab:NewSection("Sell Settings")
KeepSection:NewToggle("Keep Legendary+", "Don't sell Legendary/Unknown", function(state)
	Config.KeepLegendaryPlus = state
end)

-- TELEPORT TAB (Farming Spots)
local TeleportTab = Window:NewTab("Teleport")
local LocationsSection = TeleportTab:NewSection("Fishing Spots")

local Spots = {
	["Deep Ocean"] = CFrame.new(200, 10, 500),
	["Cave Pool"] = CFrame.new(-150, 5, 300),
	["Volcano Lake"] = CFrame.new(400, 50, -200),
	["Ice Fishing"] = CFrame.new(-300, 15, -400)
}

for spotName, cf in pairs(Spots) do
	LocationsSection:NewButton(spotName, "Teleport to " .. spotName, function()
		LocalPlayer.Character:SetPrimaryPartCFrame(cf)
	end)
end

-- STATS TAB
local StatsTab = Window:NewTab("Stats")
local StatsSection = StatsTab:NewSection("Live Statistics")

local CoinsLabel = StatsSection:NewLabel("Coins: 0")
local FishLabel = StatsSection:NewLabel("Fish Caught: 0")

-- Update stats
task.spawn(function()
	while task.wait(1) do
		pcall(function()
			local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
			if leaderstats then
				local coins = leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("Money")
				if coins then
					CoinsLabel:UpdateLabel("Coins: " .. tostring(coins.Value))
				end

				local fish = leaderstats:FindFirstChild("FishCaught") or leaderstats:FindFirstChild("Fish")
				if fish then
					FishLabel:UpdateLabel("Fish Caught: " .. tostring(fish.Value))
				end
			end
		end)
	end
end)

-- ANTI-AFK
if Config.AntiAFK then
	local VirtualInputManager = game:GetService("VirtualInputManager")

	task.spawn(function()
		while task.wait(30) do
			pcall(function()
				VirtualInputManager:SendKeyEvent(true, "W", false, game)
				task.wait(0.1)
				VirtualInputManager:SendKeyEvent(false, "W", false, game)
			end)
		end
	end)
end

-- NOTIFICATION
Library:Notify("Exploit Loaded Successfully", "Fishing Simulator Ultimate v2.1")

-- CLEANUP ON EXIT
game:GetService("UserInputService").WindowFocusReleased:Connect(function()
	Config.AutoFish = false
	AutoFishThread = nil
end)