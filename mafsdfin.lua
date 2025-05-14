local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.2
mainFrame.Parent = screenGui

-- Перемещение меню
local dragging = false
local dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Создание кнопок
local function createButton(text, posY)
	local button = Instance.new("TextButton", mainFrame)
	button.Size = UDim2.new(0.9, 0, 0, 40)
	button.Position = UDim2.new(0.05, 0, 0, posY)
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 18
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.BorderSizePixel = 0
	button.AutoButtonColor = false

	-- Анимация кнопки
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
	end)

	return button
end

local flyButton = createButton("✈️ Включить полёт", 10)
local noclipButton = createButton("🧱 Включить ноклип", 60)
local teleportButton = createButton("🚀 Телепорт к игроку", 110)
local espButton = createButton("👁️ ESP: Игроки", 160)

-- Ввод ника
local nameBox = Instance.new("TextBox", mainFrame)
nameBox.Size = UDim2.new(0.9, 0, 0, 35)
nameBox.Position = UDim2.new(0.05, 0, 0, 210)
nameBox.PlaceholderText = "Введите ник игрока"
nameBox.Text = ""
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 16
nameBox.TextColor3 = Color3.new(1,1,1)
nameBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
nameBox.BorderSizePixel = 0

-- Отображение создателей
local creatorLabel = Instance.new("TextLabel", mainFrame)
creatorLabel.Size = UDim2.new(1, 0, 0, 30)
creatorLabel.Position = UDim2.new(0, 0, 1, -30)
creatorLabel.BackgroundTransparency = 1
creatorLabel.Text = "Создатель: @swerejah12"
creatorLabel.TextColor3 = Color3.new(1, 1, 1)
creatorLabel.Font = Enum.Font.Gotham
creatorLabel.TextSize = 14

-- Уведомления
local function notify(title, text)
	StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = text,
		Duration = 3
	})
end

-- Переменные
local flying = false
local noclip = false
local espEnabled = false
local flyVelocity

-- Полёт
local function toggleFly()
	flying = not flying
	if flying then
		flyVelocity = Instance.new("BodyVelocity")
		flyVelocity.Name = "FlyVelocity"
		flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		flyVelocity.Velocity = Vector3.zero
		flyVelocity.Parent = humanoidRootPart

		RunService:BindToRenderStep("FlyControl", Enum.RenderPriority.Input.Value, function()
			if flying then
				local dir = Vector3.zero
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += workspace.CurrentCamera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= workspace.CurrentCamera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= workspace.CurrentCamera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += workspace.CurrentCamera.CFrame.RightVector end
				flyVelocity.Velocity = dir.Unit * 60
			end
		end)
		notify("Полёт", "Полёт включен")
	else
		if flyVelocity then flyVelocity:Destroy() end
		RunService:UnbindFromRenderStep("FlyControl")
		notify("Полёт", "Полёт выключен")
	end
end

-- Ноклип
local function toggleNoClip()
	noclip = not noclip
	RunService.Stepped:Connect(function()
		if noclip and character then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
	if noclip then
		notify("Ноклип", "Ноклип включен")
	else
		notify("Ноклип", "Ноклип выключен")
	end
end

-- Телепортация
local function teleportToPlayer()
	local name = nameBox.Text
	local target = Players:FindFirstChild(name)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		humanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
		notify("Телепорт", "Телепорт к " .. name)
	else
		notify("Ошибка", "Игрок не найден")
	end
end

-- ESP
local function toggleESP()
	espEnabled = not espEnabled
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			if espEnabled then
				local highlight = Instance.new("Highlight")
				highlight.Name = "ESP"
				highlight.FillColor = Color3.fromRGB(255, 0, 0)
				highlight.OutlineColor = Color3.new(1,1,1)
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Parent = plr.Character
			else
				local old = plr.Character:FindFirstChild("ESP")
				if old then old:Destroy() end
			end
		end
	end
	if espEnabled then
		notify("ESP", "ESP включен")
	else
		notify("ESP", "ESP выключен")
	end
end

-- Обработчики
flyButton.MouseButton1Click:Connect(toggleFly)
noclipButton.MouseButton1Click:Connect(toggleNoClip)
teleportButton.MouseButton1Click:Connect(teleportToPlayer)
espButton.MouseButton1Click:Connect(toggleESP)
