-- AsunkEX Hyper-Intelligence: Roblox GUI Control System - FIXED VERSION
-- Mission: Part/Model Teleport & Management Interface
-- Architecture: Error-Proof, Multi-Feature, Optimized

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- GUI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AsunkEX_PartManager"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- TITLE
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Text = "ASUNKEX PART MANAGER v2.1"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.SciFi
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = MainFrame

-- CLOSE BUTTON
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.BackgroundTransparency = 1
CloseButton.Parent = Title

-- SEARCH SECTION
local SearchFrame = Instance.new("Frame")
SearchFrame.Name = "SearchFrame"
SearchFrame.Size = UDim2.new(1, -20, 0, 40)
SearchFrame.Position = UDim2.new(0, 10, 0, 50)
SearchFrame.BackgroundTransparency = 1

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(0.7, 0, 1, 0)
SearchBox.Position = UDim2.new(0, 0, 0, 0)
SearchBox.PlaceholderText = "Search part/model..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchFrame

local SearchButton = Instance.new("TextButton")
SearchButton.Name = "SearchButton"
SearchButton.Size = UDim2.new(0.25, -5, 1, 0)
SearchButton.Position = UDim2.new(0.75, 5, 0, 0)
SearchButton.Text = "SEARCH"
SearchButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
SearchButton.Font = Enum.Font.GothamBold
SearchButton.TextSize = 14
SearchButton.AutoButtonColor = true
SearchButton.Parent = SearchFrame

SearchFrame.Parent = MainFrame

-- LIST FRAME
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Name = "ListFrame"
ListFrame.Size = UDim2.new(1, -20, 0, 200)
ListFrame.Position = UDim2.new(0, 10, 0, 100)
ListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ListFrame.BorderSizePixel = 0
ListFrame.ScrollBarThickness = 6
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ListFrame.ScrollingDirection = Enum.ScrollingDirection.Y

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ListFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 5)
Padding.PaddingLeft = UDim.new(0, 5)
Padding.PaddingRight = UDim.new(0, 5)
Padding.Parent = ListFrame

ListFrame.Parent = MainFrame

-- SELECTED PARTS DISPLAY
local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Name = "SelectedLabel"
SelectedLabel.Size = UDim2.new(1, -20, 0, 30)
SelectedLabel.Position = UDim2.new(0, 10, 0, 310)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.Text = "Selected: 0"
SelectedLabel.TextColor3 = Color3.fromRGB(0, 200, 150)
SelectedLabel.Font = Enum.Font.GothamBold
SelectedLabel.TextSize = 14
SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedLabel.Parent = MainFrame

-- BUTTONS FRAME
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Name = "ButtonFrame"
ButtonFrame.Size = UDim2.new(1, -20, 0, 120)
ButtonFrame.Position = UDim2.new(0, 10, 0, 350)
ButtonFrame.BackgroundTransparency = 1

-- FUNCTION BUTTONS
local function createButton(name, text, position, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, 0, 0, 35)
	btn.Position = position
	btn.Text = text
	btn.BackgroundColor3 = color
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.AutoButtonColor = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	return btn
end

local BringButton = createButton("BringButton", "BRING TO PLAYER", UDim2.new(0, 0, 0, 0), Color3.fromRGB(0, 150, 80))
local TeleportButton = createButton("TeleportButton", "TELEPORT TO PART", UDim2.new(0, 0, 0, 40), Color3.fromRGB(0, 100, 200))
local ClearButton = createButton("ClearButton", "CLEAR SELECTION", UDim2.new(0, 0, 0, 80), Color3.fromRGB(200, 50, 50))

BringButton.Parent = ButtonFrame
TeleportButton.Parent = ButtonFrame
ClearButton.Parent = ButtonFrame
ButtonFrame.Parent = MainFrame

-- STATUS BAR
local StatusBar = Instance.new("TextLabel")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, -20, 0, 20)
StatusBar.Position = UDim2.new(0, 10, 0, 475)
StatusBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StatusBar.Text = "Ready - Press F5 or P to hide/show"
StatusBar.TextColor3 = Color3.fromRGB(200, 200, 100)
StatusBar.Font = Enum.Font.Gotham
StatusBar.TextSize = 12
StatusBar.TextXAlignment = Enum.TextXAlignment.Left

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 4)
UICorner2.Parent = StatusBar

StatusBar.Parent = MainFrame

-- PARENT GUI KE PLAYER
ScreenGui.Parent = player:WaitForChild("PlayerGui")
MainFrame.Parent = ScreenGui

-- SYSTEM VARIABLES
local selectedParts = {}
local lastSearchResults = {}
local guiVisible = true
local connection = nil

-- PART HIGHLIGHT SYSTEM
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "AsunkEX_Highlights"
highlightFolder.Parent = workspace

local function createHighlight(part)
	if not part or not part:IsA("BasePart") then return nil end

	local highlight = Instance.new("SelectionBox")
	highlight.Name = "Highlight_" .. part.Name
	highlight.Adornee = part
	highlight.Color3 = Color3.fromRGB(0, 255, 150)
	highlight.LineThickness = 0.05
	highlight.Parent = highlightFolder

	return highlight
end

-- UPDATE SELECTED COUNT
local function updateSelectedCount()
	SelectedLabel.Text = "Selected: " .. tostring(#selectedParts)

	-- Clear old highlights
	for _, child in pairs(highlightFolder:GetChildren()) do
		child:Destroy()
	end

	-- Create new highlights
	for _, part in pairs(selectedParts) do
		if part and part.Parent then
			createHighlight(part)
		end
	end
end

-- GET ALL PARTS/MODELS
local function getAllParts()
	local items = {}

	local function scanObject(obj)
		if obj:IsA("BasePart") then
			table.insert(items, {
				Object = obj,
				Name = obj.Name,
				Type = "Part"
			})
		elseif obj:IsA("Model") then
			table.insert(items, {
				Object = obj,
				Name = obj.Name,
				Type = "Model"
			})
		end

		for _, child in pairs(obj:GetChildren()) do
			scanObject(child)
		end
	end

	for _, obj in pairs(workspace:GetChildren()) do
		scanObject(obj)
	end

	return items
end

-- DISPLAY LIST FUNCTION
local function displayList(items)
	-- Clear current list
	for _, child in pairs(ListFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	lastSearchResults = items

	for i, item in pairs(items) do
		local btn = Instance.new("TextButton")
		btn.Name = "Item_" .. i
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.Position = UDim2.new(0, 0, 0, 0)
		btn.LayoutOrder = i
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.Text = "[" .. item.Type .. "] " .. item.Name
		btn.TextColor3 = Color3.fromRGB(220, 220, 220)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = true

		local padding = Instance.new("UIPadding")
		padding.PaddingLeft = UDim.new(0, 10)
		padding.Parent = btn

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = btn

		-- Check if already selected
		local isSelected = false
		for _, selPart in pairs(selectedParts) do
			if selPart == item.Object then
				isSelected = true
				btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
				break
			end
		end

		-- Click event for selection
		btn.MouseButton1Click:Connect(function()
			if not item.Object or not item.Object.Parent then
				StatusBar.Text = "Error: Object no longer exists"
				return
			end

			local part = item.Object
			if part:IsA("Model") then
				part = part:FindFirstChildWhichIsA("BasePart") or part
			end

			if not part:IsA("BasePart") then return end

			-- Toggle selection
			local alreadySelected = false
			for idx, selPart in pairs(selectedParts) do
				if selPart == part then
					table.remove(selectedParts, idx)
					alreadySelected = true
					break
				end
			end

			if not alreadySelected then
				table.insert(selectedParts, part)
				btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
			else
				btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			end

			updateSelectedCount()
			StatusBar.Text = "Selected: " .. item.Name
		end)

		btn.Parent = ListFrame
	end
end

-- BRING PARTS TO PLAYER
local function bringToPlayer()
	if #selectedParts == 0 then
		StatusBar.Text = "Error: No parts selected"
		return
	end

	local char = player.Character
	if not char then
		StatusBar.Text = "Error: Character not found"
		return
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		StatusBar.Text = "Error: HumanoidRootPart not found"
		return
	end

	local targetPosition = hrp.Position + hrp.CFrame.LookVector * 10

	for _, part in pairs(selectedParts) do
		if part and part.Parent then
			-- Use CFrame for smooth movement
			part.CFrame = CFrame.new(targetPosition)
			targetPosition = targetPosition + Vector3.new(5, 0, 0)
		end
	end

	StatusBar.Text = "Brought " .. #selectedParts .. " parts to player"
end

-- TELEPORT TO PART
local function teleportToPart()
	if #selectedParts == 0 then
		StatusBar.Text = "Error: No parts selected"
		return
	end

	local char = player.Character
	if not char then
		StatusBar.Text = "Error: Character not found"
		return
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		StatusBar.Text = "Error: HumanoidRootPart not found"
		return
	end

	-- Teleport to first selected part
	local part = selectedParts[1]
	if part and part.Parent then
		hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
		StatusBar.Text = "Teleported to " .. part.Name
	else
		StatusBar.Text = "Error: Selected part invalid"
	end
end

-- PART CLICK DETECTION
local function setupPartClickDetection()
	if connection then
		connection:Disconnect()
	end

	connection = mouse.Button1Down:Connect(function()
		local target = mouse.Target
		if target and target:IsA("BasePart") then
			-- Show name in workspace
			local billboard = Instance.new("BillboardGui")
			billboard.Name = "PartNameDisplay"
			billboard.Adornee = target
			billboard.Size = UDim2.new(0, 200, 0, 50)
			billboard.StudsOffset = Vector3.new(0, 3, 0)
			billboard.AlwaysOnTop = true
			billboard.MaxDistance = 100

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = target.Name
			label.TextColor3 = Color3.fromRGB(255, 255, 100)
			label.Font = Enum.Font.GothamBold
			label.TextSize = 18
			label.Parent = billboard

			billboard.Parent = target

			-- Auto remove after 3 seconds
			task.delay(3, function()
				if billboard and billboard.Parent then
					billboard:Destroy()
				end
			end)

			StatusBar.Text = "Clicked: " .. target.Name
		end
	end)
end

-- INITIALIZE
local function initialize()
	-- Setup button events
	SearchButton.MouseButton1Click:Connect(function()
		local searchText = string.lower(SearchBox.Text)
		if searchText == "" then
			local allParts = getAllParts()
			displayList(allParts)
			StatusBar.Text = "Showing all " .. #allParts .. " parts/models"
		else
			local filtered = {}
			for _, item in pairs(getAllParts()) do
				if string.find(string.lower(item.Name), searchText, 1, true) then
					table.insert(filtered, item)
				end
			end
			displayList(filtered)
			StatusBar.Text = "Found " .. #filtered .. " results for: " .. searchText
		end
	end)

	SearchBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			-- Panggil fungsi search secara langsung
			local searchText = string.lower(SearchBox.Text)
			if searchText == "" then
				local allParts = getAllParts()
				displayList(allParts)
				StatusBar.Text = "Showing all " .. #allParts .. " parts/models"
			else
				local filtered = {}
				for _, item in pairs(getAllParts()) do
					if string.find(string.lower(item.Name), searchText, 1, true) then
						table.insert(filtered, item)
					end
				end
				displayList(filtered)
				StatusBar.Text = "Found " .. #filtered .. " results for: " .. searchText
			end
		end
	end)

	BringButton.MouseButton1Click:Connect(function()
		bringToPlayer()
	end)

	TeleportButton.MouseButton1Click:Connect(function()
		teleportToPart()
	end)

	ClearButton.MouseButton1Click:Connect(function()
		selectedParts = {}
		updateSelectedCount()
		StatusBar.Text = "Selection cleared"
	end)

	CloseButton.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
		if highlightFolder then
			highlightFolder:Destroy()
		end
		if connection then
			connection:Disconnect()
		end
	end)

	-- Setup part click detection
	setupPartClickDetection()

	-- Keybind toggle
	local TOGGLE_KEYS = {
		Enum.KeyCode.F5,          -- Function key F5
		Enum.KeyCode.P,           -- Huruf P
		Enum.KeyCode.RightShift   -- Shift kanan
	}

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed then
			for _, key in pairs(TOGGLE_KEYS) do
				if input.KeyCode == key then
					guiVisible = not guiVisible
					MainFrame.Visible = guiVisible
					StatusBar.Text = guiVisible and "GUI Visible (Press F5/P)" or "GUI Hidden"
					break
				end
			end
		end
	end)

	-- Enable dragging
	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X,
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end

	Title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Title.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	-- Load initial parts
	local allParts = getAllParts()
	displayList(allParts)
	StatusBar.Text = "System Ready - " .. #allParts .. " parts loaded"

	-- Auto-update list every 30 seconds
	while true do
		task.wait(30)
		if guiVisible and SearchBox.Text == "" then
			local updatedParts = getAllParts()
			displayList(updatedParts)
		end
	end
end

-- ERROR HANDLING WRAPPER
local function safeExecute(func)
	local success, err = pcall(func)
	if not success then
		StatusBar.Text = "Error: " .. tostring(err)
		warn("AsunkEX Error: " .. tostring(err))
	end
end

-- START SYSTEM
coroutine.wrap(function()
	task.wait(1) -- Tunggu player siap
	safeExecute(initialize)
end)()

-- CLEANUP ON PLAYER LEAVE
player.CharacterRemoving:Connect(function()
	if highlightFolder then
		highlightFolder:Destroy()
	end
	if connection then
		connection:Disconnect()
	end
end)

return {
	GetSelectedParts = function() return selectedParts end,
	SearchParts = function(text) 
		SearchBox.Text = text

		-- Trigger search secara manual
		local searchText = string.lower(text)
		if searchText == "" then
			local allParts = getAllParts()
			displayList(allParts)
			StatusBar.Text = "Showing all " .. #allParts .. " parts/models"
		else
			local filtered = {}
			for _, item in pairs(getAllParts()) do
				if string.find(string.lower(item.Name), searchText, 1, true) then
					table.insert(filteriltered, item)
				end
			end
			displayList(filtered)
			StatusBar.Text = "Found " .. #filtered .. " results for: " .. searchText
		end
	end,
	ToggleGUI = function()
		guiVisible = not guiVisible
		MainFrame.Visible = guiVisible
	end
}