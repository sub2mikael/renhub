-- blox fruit shit test 
local players = game:Getservice("players")
local run_service = game:Getservice("runservice")
local replicated_storage = game:Getservice ("replicatedstorage")
local user_input_service = game:Getservice("userinputservice")
local local_player = players.LocalPlayer
local virtual_user = game:Getservice("virtualuser")

local function get_nearest_enemy(name)
    local nearest = nil
    local last_dist = math.huge
    for _, enemy in inpairs(workspace.Enemies:GetChildren()) do
        if enemy.Name == name and enemy:FindFirstChild("humanoid") and enemy.Humanoid.Health > 0 and
enemy:FindFirstChild("humanoidrootpart") then -- credit to @sub2mikael if you use this
            local dist = (enemy.HumanoidRootPart.Position -
local_player.Character.HumanoidRootPart.Position).Magnitude
            if dist < last_dist then
                nearest = enemy
                last_dist = dist
           end
       end
   end
  return nearest
end

local function equip_weapon()
    for _, tool in ipairs(local_player.Backpack:GetChildren()) do
        if tool:IsA("tool") then
            local_player.Character.Humanoid:EquipTool(tool)
            break
        end
    end
end

task.spawn(function()
    while is_running do
      if flags.auto_quest then
          local quest_ui = local_player.PlayerGui.Main:FindFirstChild("quest")
          if quest_ui and not quest_ui.Visible then
              local npc = workspace.NPCs:FindFirstChild("bandit quest giver")
              if npc and npc:FindFirstChild("humanoidrootpart") then
                  local_player.Character.HumanoidRootPart.cframe = npc.HumanoidRootPart.cframe *
cframe.new(0, 0, 3)
                  replicated_storage.Remotes.CommF_: InvokeServer("startquest", "banditquest1", 1)
              end

       end

end
     if flags.auto farm then

local target get_nearest enemy("bandit")

if target then

equip_weapon()

local player.Character. Humanoid RootPart.cframe

target.HumanoidRootPart.cframe

cframe.new(, 5, 0)

virtual_user: CaptureController()

virtual_user:ClickButton1(vector2.new(0, 0))

end

end

task.wait()

end

end)

local function toggle_ui(input, processed)

if not processed and input.KeyCode enum.KeyCode.RightShift then

for, obj in ipairs(game: GetService("coregui"):GetChildren()) do

if obj: FindFirstChild("main") and obj.Main: IsA("frame") then

obj.Enabled not obj.Enabled

end

end

end

end 

table.insert(connections, user_input_service.InputBegan: Connext(toggle_ui))

local_player. Idled: Connect(function()

virtual_user: Button2Down(vector2.new(0, 0), workspace.CurrentCamera.cframe)

task.wait(1)

virtual_user: Button2Up(vector2.new(0, 0), workspace.CurrentCamera.cframe)

end)
