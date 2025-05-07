-- Загрузка Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создание окна
local Window = Rayfield:CreateWindow({
    Name = "💀 DEAD RAILS | VISUAL & UTILS",
    Icon = 0,
    LoadingTitle = "DeadRails Visual Tools",
    LoadingSubtitle = "X-Ray / NoClip / Night / Visual Enemies",
    Theme = "Default",    Discord = {
        Enabled = true,
        Invite = "pyRSZ5E5",
        RememberJoins = false
    },
    KeySystem = true,
    KeySettings = {
        Title = "🔐 Access Required",
        Subtitle = "Key: Stavrapol_Creal",
        Note = "📌 Join our Discord for key: https://discord.gg/pyRSZ5E5",
        FileName = "DeadRailsVisual",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {"Stavrapol_Creal"}
    }
})

local Tab = Window:CreateTab("Visual & Utility", 4483362458)
local Section = Tab:CreateSection("Main Functions")

-- 🔘 Запуск внешнего скрипта автофарма
Tab:CreateButton({
    Name = "⚡ Run External Autofarm Script",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Dead-Rails-Alpha-Autobonds-NO-KEY-38587"))()
        end)
        if not success then
            Rayfield:Notify({ Title = "❌ Error", Content = "Failed to load autofarm script.", Duration = 3 })
        else
            Rayfield:Notify({ Title = "✅ Script Loaded", Content = "Autofarm is now running.", Duration = 3 })
        end
    end
})

-- 🔘 NoClip
local noclipEnabled = false
local noclipConnection
Tab:CreateButton({
    Name = "🧱 Toggle NoClip",
    Callback = function()
        noclipEnabled = not noclipEnabled
        if noclipEnabled then
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if game.Players.LocalPlayer.Character then
                    for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            Rayfield:Notify({ Title = "🧱 NoClip On", Content = "You can walk through walls.", Duration = 3 })
        else
            if noclipConnection then noclipConnection:Disconnect() end
            if game.Players.LocalPlayer.Character then
                for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            Rayfield:Notify({ Title = "🧱 NoClip Off", Content = "Walls are solid again.", Duration = 3 })
        end
    end
})

-- 🔘 X-Ray
local xrayEnabled = false
local originalTransparency = {}

Tab:CreateButton({
    Name = "👁️ Toggle X-Ray",
    Callback = function()
        xrayEnabled = not xrayEnabled
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
                if xrayEnabled then
                    originalTransparency[obj] = obj.Transparency
                    obj.Transparency = 0.6
                elseif originalTransparency[obj] then
                    obj.Transparency = originalTransparency[obj]
                end
            end
        end
        if not xrayEnabled then originalTransparency = {} end
        Rayfield:Notify({
            Title = xrayEnabled and "👁️ X-Ray On" or "👁️ X-Ray Off",
            Content = xrayEnabled and "Wall transparency enabled." or "Transparency restored.",
            Duration = 3
        })
    end
})

task.spawn(function()
    while true do
        if xrayEnabled then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
                    obj.Transparency = 0.6
                end
            end
        end
        task.wait(15)
    end
end)

-- 🔘 Ночной режим
local nightEnabled = false
local savedClockTime = game.Lighting.ClockTime

Tab:CreateButton({
    Name = "🌙 Toggle Night Mode",
    Callback = function()
        nightEnabled = not nightEnabled
        if nightEnabled then
            savedClockTime = game.Lighting.ClockTime
            game.Lighting.ClockTime = 0
            Rayfield:Notify({ Title = "🌙 Night Mode On", Content = "Switched to night.", Duration = 3 })
        else
            game.Lighting.ClockTime = savedClockTime
            Rayfield:Notify({ Title = "☀️ Night Mode Off", Content = "Restored original time.", Duration = 3 })
        end
    end
})

-- 🔘 Visual-Zombie-Neutral
local visualZombieNeutralState = 0
local modelColors = {
    ["Model_Runner"] = Color3.fromRGB(255, 0, 0),
    ["Model_Walker"] = Color3.fromRGB(255, 255, 0),
    ["Model_ZombieSheriff"] = Color3.fromRGB(0, 0, 255),
    ["Zombie"] = Color3.fromRGB(255, 255, 255),
    ["Model_Wolf"] = Color3.fromRGB(255, 255, 255),
    ["Model_Horse"] = Color3.fromRGB(255, 255, 255),
    ["Model_Werewolf"] = Color3.fromRGB(100, 100, 100),
}
local modelLabels = {
    ["Model_Runner"] = "Runner",
    ["Model_Walker"] = "Walker",
    ["Model_ZombieSheriff"] = "Sheriff",
    ["Zombie"] = "Zombie",
    ["Model_Wolf"] = "Wolf",
    ["Model_Horse"] = "Horse",
    ["Model_Werewolf"] = "Werewolf-dangerous",
}

local function createNameTag(model, labelText)
    local primaryPart = model.PrimaryPart
    if not primaryPart then
        for _, part in ipairs(model:GetChildren()) do
            if part:IsA("BasePart") then
                model.PrimaryPart = part
                primaryPart = part
                break
            end
        end
    end
    if not primaryPart or model:FindFirstChild("NameTagGui") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTagGui"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = labelText
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = false
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.Parent = billboard
end

local function highlightModel(model)
    local color = modelColors[model.Name]
    if not color then return end

    if not model:FindFirstChild("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight.FillColor = color
        highlight.OutlineColor = Color3.new(0, 0, 0)
        highlight.FillTransparency = 0.2
        highlight.OutlineTransparency = 0
        highlight.Adornee = model
        highlight.Parent = model
    end

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Neon
            part.Color = color
            if not part:FindFirstChild("Glow") then
                local light = Instance.new("PointLight")
                light.Name = "Glow"
                light.Color = color
                light.Brightness = 2
                light.Range = 10
                light.Shadows = false
                light.Parent = part
            end
        end
    end

    local label = modelLabels[model.Name]
    if label then
        createNameTag(model, label)
    end
end

local function removeHighlight(model)
    local highlight = model:FindFirstChild("Highlight")
    if highlight then highlight:Destroy() end

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Plastic
            part.Color = Color3.fromRGB(163, 162, 165)
            local light = part:FindFirstChild("Glow")
            if light then light:Destroy() end
        end
    end

    local tag = model:FindFirstChild("NameTagGui")
    if tag then tag:Destroy() end
end

local function scanAndHighlightModels(parent)
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("Model") and modelColors[obj.Name] then
            highlightModel(obj)
        elseif obj:IsA("Folder") or obj:IsA("Model") then
            scanAndHighlightModels(obj)
        end
    end
end

local function removeAllHighlights(parent)
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("Model") and modelColors[obj.Name] then
            removeHighlight(obj)
        elseif obj:IsA("Folder") or obj:IsA("Model") then
            removeAllHighlights(obj)
        end
    end
end

Tab:CreateButton({
    Name = "🧟 Visual-Zombie-Neutral",
    Callback = function()
        visualZombieNeutralState = (visualZombieNeutralState + 1) % 3
        if visualZombieNeutralState == 1 then
            scanAndHighlightModels(workspace)
            workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Model") and modelColors[descendant.Name] then
                    highlightModel(descendant)
                end
            end)
            Rayfield:Notify({
                Title = "🧟 Visual-Zombie-Neutral Activated",
                Content = "Enemy models are now highlighted.",
                Duration = 3
            })
        elseif visualZombieNeutralState == 2 then
            removeAllHighlights(workspace)
            Rayfield:Notify({
                Title = "🧟 Visual-Zombie-Neutral Deactivated",
                Content = "Enemy model highlights removed.",
                Duration = 3
            })
        else
            scanAndHighlightModels(workspace)
            Rayfield:Notify({
                Title = "🧟 Visual-Zombie-Neutral Reactivated",
                Content = "Enemy models are highlighted again.",
                Duration = 3
            })
        end
    end
})

-- Инфо
Tab:CreateParagraph({
    Title = "📌 Info",
    Content = "Script by @STAVRAPOL_CREAL\nJoin Discord: https://discord.gg/pyRSZ5E5"
})

-- Лейблы в интерфейсе
task.spawn(function()
    repeat task.wait() until game:GetService("CoreGui"):FindFirstChild("Rayfield")
    local gui = game:GetService("CoreGui"):FindFirstChild("Rayfield")
    if gui then
        local toggleLabel = gui:FindFirstChild("ToggleKeybindText", true)
        if toggleLabel and toggleLabel:IsA("TextLabel") then
            toggleLabel.Text = "🔥 Made by STAVRAPOL_CREAL 🔥"
        end
        local titleLabel = gui:FindFirstChild("Topbar", true)
        if titleLabel and titleLabel:FindFirstChildOfClass("TextLabel") then
            titleLabel:FindFirstChildOfClass("TextLabel").Text = "🔥 Made by STAVRAPOL_CREAL 🔥"
        end
    end
end)
