local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local flags = { auto_quest = false, auto_farm = false }
local is_running = true
local connections = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(12, 12, 25)
header.BorderSizePixel = 0
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "bf"
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local function createToggle(parent, labelText, yPos, flagKey)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 38)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(28, 28, 50)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 22)
    btn.Position = UDim2.new(1, -50, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 11)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = btn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    btn.MouseButton1Click:Connect(function()
        flags[flagKey] = not flags[flagKey]
        local on = flags[flagKey]
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(92, 92, 255) or Color3.fromRGB(60, 60, 80)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.15), {
            Position = on and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
    end)
end

createToggle(frame, "Auto Quest", 38, "auto_quest")
createToggle(frame, "Auto Farm", 82, "auto_farm")

local function getCharacter()
    return LocalPlayer.Character
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function getNearestEnemy(name)
    local nearest, lastDist = nil, math.huge
    local root = getRootPart()
    if not root then return nil end

    for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
        if enemy.Name == name
            and enemy:FindFirstChild("Humanoid")
            and enemy.Humanoid.Health > 0
            and enemy:FindFirstChild("HumanoidRootPart") then

            local dist = (enemy.HumanoidRootPart.Position - root.Position).Magnitude
            if dist < lastDist then
                nearest = enemy
                lastDist = dist
            end
        end
    end
    return nearest
end

local function equipWeapon()
    local humanoid = getHumanoid()
    if not humanoid then return end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            humanoid:EquipTool(tool)
            break
        end
    end
end

local function attackEnemy(target)
    local root = getRootPart()
    local humanoid = getHumanoid()
    if not root or not humanoid then return end
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    equipWeapon()
    local char = getCharacter()
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("RemoteFunction")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer()
        else
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(
                Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2,
                            workspace.CurrentCamera.ViewportSize.Y / 2),
                workspace.CurrentCamera.CFrame
            )
        end
    end
end

task.spawn(function()
    while is_running do
        if flags.auto_quest and getCharacter() then
            local questUi = LocalPlayer.PlayerGui:FindFirstChild("Main")
            if questUi then
                local questFrame = questUi:FindFirstChild("Quest")
                if questFrame and not questFrame.Visible then
                    local npc = workspace.NPCs:FindFirstChild("Bandit Quest Giver")
                    if npc and npc:FindFirstChild("HumanoidRootPart") then
                        local root = getRootPart()
                        if root then
                            root.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            task.wait(0.2)
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                        end
                    end
                end
            end
        end

        if flags.auto_farm and getCharacter() then
            local target = getNearestEnemy("Bandit")
            if target then
                attackEnemy(target)
            end
        end

        task.wait(0.1)
    end
end)

local function toggleUI(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end

table.insert(connections, UserInputService.InputBegan:Connect(toggleUI))

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)
