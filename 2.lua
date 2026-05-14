-- blox fruit test auto farm EZZZ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local flags = { auto_quest = true, auto_farm = true }
local is_running = true
local connections = {}

local function get_nearest_enemy(name)
    local nearest = nil
    local last_dist = math.huge

    for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
        if enemy.Name == name
            and enemy:FindFirstChild("Humanoid")
            and enemy.Humanoid.Health > 0
            and enemy:FindFirstChild("HumanoidRootPart") then -- credit to @sub2mikael if you use this

            local dist = (enemy.HumanoidRootPart.Position
                - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

            if dist < last_dist then
                nearest = enemy
                last_dist = dist
            end
        end
    end

    return nearest
end

local function equip_weapon()
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            LocalPlayer.Character.Humanoid:EquipTool(tool)
            break
        end
    end
end

task.spawn(function()
    while is_running do
        if flags.auto_quest then
            local quest_ui = LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
            if quest_ui and not quest_ui.Visible then
                local npc = workspace.NPCs:FindFirstChild("Bandit Quest Giver")
                if npc and npc:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame
                        * CFrame.new(0, 0, 3)
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                end
            end
        end

        if flags.auto_farm then
            local target = get_nearest_enemy("Bandit")
            if target then
                equip_weapon()
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
                    * CFrame.new(0, 5, 0)
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end
        end

        task.wait()
    end
end)

local function toggle_ui(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        for _, obj in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if obj:FindFirstChild("Main") and obj.Main:IsA("Frame") then
                obj.Enabled = not obj.Enabled
            end
        end
    end
end

table.insert(connections, UserInputService.InputBegan:Connect(toggle_ui))

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)
