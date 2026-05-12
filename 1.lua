local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ren = 5 * 60

Players.PlayerAdded:Connect(function(player)
    task.delay(ren, function()
        if player.Parent then
            LocalPlayer:Kick("you got kicked for 67 reason")
        end
    end)
end)
