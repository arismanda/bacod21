-- LocalScript: TP + Sprint + Gravity + Jump + Speed Input
-- StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local function getRoot()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")
	return char, root, humanoid
end

------------------------------------------------
-- GUI
------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "TP_Sprint_Gui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 230)
frame.Position = UDim2.new(0, 12, 0, 12)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.15
frame.Active = true
frame.Parent = gui

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -12, 0, 22)
title.Position = UDim2.new(0, 6, 0, 6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "TP ● Sprint ● Gravity ● Jump ● Speed"
title.TextSize = 13
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

local function makeBtn(text, y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1, -12, 0, 28)
	b.Position = UDim2.new(0, 6, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Text = text
	return b
end

local function makeBox(default, placeholder, y)
	local b = Instance.new("TextBox", frame)
	b.Size = UDim2.new(1, -12, 0, 24)
	b.Position = UDim2.new(0, 6, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Text = tostring(default)
	b.PlaceholderText = placeholder
	b.TextColor3 = Color3.new(1,1,1)
	return b
end

local clickBtn    = makeBtn("Click TP: OFF",       32)
local sprintBtn   = makeBtn("Shift Sprint: OFF",   62)
local gravityBox  = makeBox(196.2, "Gravity",      92)
local gravityBtn  = makeBtn("Gravity: OFF",        118)
local jumpBox     = makeBox(50, "Jump Power",      148)
local jumpBtn     = makeBtn("Jump: OFF",           174)
local speedBox    = makeBox(35, "Run Speed",       204)
local hideBtn     = Instance.new("TextButton")

hideBtn.Size = UDim2.new(0, 22, 0, 22)
hideBtn.Position = UDim2.new(1, -28, 0, 6)
hideBtn.Parent = frame
hideBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
hideBtn.Text = "-"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 12
hideBtn.TextColor3 = Color3.new(1,1,1)

------------------------------------------------
-- Drag
------------------------------------------------
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
	end
end)

------------------------------------------------
-- Click TP
------------------------------------------------
local clickEnabled = false
local debounce = false
local mouse = player:GetMouse()

local function updateTpUI()
	clickBtn.BackgroundColor3 = clickEnabled and Color3.fromRGB(55,120,55) or Color3.fromRGB(45,45,45)
	clickBtn.Text = clickEnabled and "Click TP: ON" or "Click TP: OFF"
end

local function mouseOnGui(x,y)
	local p = frame.AbsolutePosition
	local s = frame.AbsoluteSize
	return x>=p.X and x<=p.X+s.X and y>=p.Y and y<=p.Y+s.Y
end

mouse.Button1Down:Connect(function()
	if not clickEnabled or debounce then return end
	if mouseOnGui(mouse.X,mouse.Y) then return end

	local _,root = getRoot()
	local pos = mouse.Hit and mouse.Hit.Position
	if not pos then return end

	local cam = workspace.CurrentCamera
	local look = cam.CFrame.LookVector
	local rot = math.atan2(-look.X, -look.Z)
	root.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) * CFrame.Angles(0,rot,0)

	debounce = true
	task.wait(0.2)
	debounce = false
end)

clickBtn.MouseButton1Click:Connect(function()
	clickEnabled = not clickEnabled
	updateTpUI()
end)

------------------------------------------------
-- Sprint + SPEED INPUT
------------------------------------------------
local sprintEnabled = false
local normalSpeed = 16
local sprintSpeed = 35

local function updateSprintUI()
	sprintBtn.BackgroundColor3 = sprintEnabled and Color3.fromRGB(55,120,55) or Color3.fromRGB(45,45,45)
	sprintBtn.Text = sprintEnabled and "Shift Sprint: ON" or "Shift Sprint: OFF"
end

local function applySprint(on)
	local _,_,hum = getRoot()
	local spd = tonumber(speedBox.Text) or sprintSpeed
	hum.WalkSpeed = on and spd or normalSpeed
end

UserInputService.InputBegan:Connect(function(i,gp)
	if gp or not sprintEnabled then return end
	if i.KeyCode==Enum.KeyCode.LeftShift then applySprint(true) end
end)
UserInputService.InputEnded:Connect(function(i,gp)
	if gp or not sprintEnabled then return end
	if i.KeyCode==Enum.KeyCode.LeftShift then applySprint(false) end
end)

speedBox.FocusLost:Connect(function()
	if sprintEnabled then applySprint(true) end
end)

sprintBtn.MouseButton1Click:Connect(function()
	sprintEnabled = not sprintEnabled
	updateSprintUI()
	if not sprintEnabled then applySprint(false) end
end)

------------------------------------------------
-- Gravity
------------------------------------------------
local defaultGrav = workspace.Gravity
local gravOn = false
local function updateGravUI()
	gravityBtn.BackgroundColor3 = gravOn and Color3.fromRGB(55,120,55) or Color3.fromRGB(45,45,45)
	gravityBtn.Text = gravOn and "Gravity: ON" or "Gravity: OFF"
end

gravityBtn.MouseButton1Click:Connect(function()
	gravOn = not gravOn
	workspace.Gravity = gravOn and tonumber(gravityBox.Text) or defaultGrav
	updateGravUI()
end)
gravityBox.FocusLost:Connect(function()
	if gravOn then workspace.Gravity = tonumber(gravityBox.Text) or defaultGrav end
end)

------------------------------------------------
-- Jump Power
------------------------------------------------
local defaultJump = 50
local jumpOn = false
local function updateJumpUI()
	jumpBtn.BackgroundColor3 = jumpOn and Color3.fromRGB(55,120,55) or Color3.fromRGB(45,45,45)
	jumpBtn.Text = jumpOn and "Jump: ON" or "Jump: OFF"
end

jumpBtn.MouseButton1Click:Connect(function()
	jumpOn = not jumpOn
	local _,_,hum = getRoot()
	hum.UseJumpPower = true
	hum.JumpPower = jumpOn and tonumber(jumpBox.Text) or defaultJump
	updateJumpUI()
end)

jumpBox.FocusLost:Connect(function()
	if jumpOn then
		local _,_,hum = getRoot()
		hum.JumpPower = tonumber(jumpBox.Text) or defaultJump
	end
end)

------------------------------------------------
-- Hide UI
------------------------------------------------
hideBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	local b = Instance.new("TextButton", gui)
	b.Size = UDim2.new(0,26,0,26)
	b.Position = UDim2.new(0,12,0,12)
	b.BackgroundColor3 = Color3.fromRGB(60,60,60)
	b.Text = "+"
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.new(1,1,1)
	b.MouseButton1Click:Connect(function()
		b:Destroy()
		frame.Visible = true
	end)
end)

updateTpUI()
updateSprintUI()
updateGravUI()
updateJumpUI()
