local settings = {
    enabled = true,
    maxDistance = 1500,
    teamCheck = false,
    visCheck = true,
    box = true,
    boxOutline = true,
    boxColor = Color3.new(1,1,1),
    name = true,
    dist = true,
    hp = true,
    hpbar = true,
    hpbarOutline = true,
    textSize = 13,
    font = 2,
    chams = false,
    visOnly = false,
    chamFill = Color3.fromRGB(255,0,0),
    chamOutline = Color3.new(1,1,1),
    chamTransparency = .5
}

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local coreGui = game:GetService("CoreGui")

local lp = players.LocalPlayer
local cache = {}

local function newDrawing(class, props)
    local obj = Drawing.new(class)

    for i,v in pairs(props) do
        obj[i] = v
    end

    return obj
end

local function hide(tbl)
    for _,v in pairs(tbl) do
        if typeof(v) == "Instance" then
            if v:IsA("Highlight") then
                v.Enabled = false
            end
        else
            v.Visible = false
        end
    end
end

local function getHpColor(hum)
    local hp = hum.Health / hum.MaxHealth

    return Color3.fromRGB(
        255 - (hp * 255),
        hp * 255,
        0
    )
end

local function isVisible(part)
    local params = RaycastParams.new()

    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {
        lp.Character,
        camera
    }

    local ray = workspace:Raycast(
        camera.CFrame.Position,
        (part.Position - camera.CFrame.Position).Unit * 9999,
        params
    )

    if ray then
        return ray.Instance:IsDescendantOf(part.Parent)
    end

    return false
end

local function getBox(char)
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not head or not hrp then
        return
    end

    local top = camera:WorldToViewportPoint(head.Position + Vector3.new(0,.5,0))
    local bottom = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))

    local height = math.abs(top.Y - bottom.Y)
    local width = height / 1.8

    return {
        size = Vector2.new(width,height),

        position = Vector2.new(
            top.X - width/2,
            top.Y
        )
    }
end

local esp = {}
esp.__index = esp

function esp:hide()
    hide(self.drawings)
end

function esp:remove()
    for _,v in pairs(self.drawings) do
        if typeof(v) == "Instance" then
            v:Destroy()
        else
            v:Remove()
        end
    end
end

function esp:update()
    local plr = self.player
    local char = plr.Character

    if not char then
        return self:hide()
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")

    if not hum or not hrp or not head then
        return self:hide()
    end

    if hum.Health <= 0 then
        return self:hide()
    end

    if settings.teamCheck and plr.Team == lp.Team then
        return self:hide()
    end

    local vec, onScreen = camera:WorldToViewportPoint(hrp.Position)

    local dist = math.floor((camera.CFrame.Position - hrp.Position).Magnitude)

    if not onScreen or dist > settings.maxDistance then
        return self:hide()
    end

    local box = getBox(char)

    if not box then
        return self:hide()
    end

    local visible = true

    if settings.visCheck then
        visible = isVisible(head)
    end

    local d = self.drawings

    d.box.Size = box.size
    d.box.Position = box.position
    d.box.Color = settings.boxColor
    d.box.Visible = settings.box

    d.outline.Size = box.size
    d.outline.Position = box.position
    d.outline.Visible = settings.box and settings.boxOutline

    d.name.Text = plr.Name

    d.name.Position = Vector2.new(
        box.position.X + box.size.X/2,
        box.position.Y - 16
    )

    d.name.Visible = settings.name

    d.dist.Text = dist.." studs"

    d.dist.Position = Vector2.new(
        box.position.X + box.size.X/2,
        box.position.Y + box.size.Y + 2
    )

    d.dist.Visible = settings.dist

    d.hp.Text = tostring(math.floor(hum.Health))
    d.hp.Color = getHpColor(hum)

    d.hp.Position = Vector2.new(
        box.position.X + box.size.X + 16,
        box.position.Y
    )

    d.hp.Visible = settings.hp

    local hp = hum.Health / hum.MaxHealth
    local size = box.size.Y * hp

    d.hpbar.Size = Vector2.new(2,size)

    d.hpbar.Position = Vector2.new(
        box.position.X - 6,
        box.position.Y + (box.size.Y - size)
    )

    d.hpbar.Color = getHpColor(hum)
    d.hpbar.Visible = settings.hpbar

    d.hpoutline.Size = Vector2.new(4,box.size.Y + 2)

    d.hpoutline.Position = Vector2.new(
        box.position.X - 7,
        box.position.Y - 1
    )

    d.hpoutline.Visible = settings.hpbar and settings.hpbarOutline

    if settings.chams then
        d.highlight.Enabled = true
        d.highlight.Adornee = char

        if settings.visOnly then
            d.highlight.FillColor = visible and
                Color3.fromRGB(0,255,0)
                or
                Color3.fromRGB(255,0,0)
        else
            d.highlight.FillColor = settings.chamFill
        end

        d.highlight.OutlineColor = settings.chamOutline
        d.highlight.FillTransparency = settings.chamTransparency
    else
        d.highlight.Enabled = false
    end
end

local function add(plr)
    if plr == lp then
        return
    end

    if cache[plr] then
        cache[plr]:remove()
    end

    local drawings = {}

    drawings.box = newDrawing("Square", {
        Thickness = 1,
        Filled = false,
        Color = settings.boxColor
    })

    drawings.outline = newDrawing("Square", {
        Thickness = 3,
        Filled = false,
        Color = Color3.new(0,0,0)
    })

    drawings.name = newDrawing("Text", {
        Center = true,
        Outline = true,
        Font = settings.font,
        Size = settings.textSize,
        Color = Color3.new(1,1,1)
    })

    drawings.dist = newDrawing("Text", {
        Center = true,
        Outline = true,
        Font = settings.font,
        Size = settings.textSize,
        Color = Color3.new(1,1,1)
    })

    drawings.hp = newDrawing("Text", {
        Center = true,
        Outline = true,
        Font = settings.font,
        Size = settings.textSize
    })

    drawings.hpbar = newDrawing("Square", {
        Filled = true,
        Thickness = 1
    })

    drawings.hpoutline = newDrawing("Square", {
        Filled = false,
        Thickness = 1,
        Color = Color3.new(0,0,0)
    })

    drawings.highlight = Instance.new("Highlight")
    drawings.highlight.Parent = coreGui
    drawings.highlight.Enabled = false

    cache[plr] = setmetatable({
        player = plr,
        drawings = drawings
    }, esp)
end

for _,plr in ipairs(players:GetPlayers()) do
    add(plr)
end

players.PlayerAdded:Connect(add)

players.PlayerRemoving:Connect(function(plr)
    if cache[plr] then
        cache[plr]:remove()
        cache[plr] = nil
    end
end)

runService.RenderStepped:Connect(function()
    if not settings.enabled then
        for _,obj in pairs(cache) do
            obj:hide()
        end

        return
    end

    for _,obj in pairs(cache) do
        obj:update()
    end
end)
