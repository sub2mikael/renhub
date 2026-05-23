local settings = {
    enabled = true,
    maxDistance = 1500,
    teamCheck = false,
    visibleCheck = true,
    textSize = 13,
    box = {enabled = true, outline = true, color = Color3.new(1,1,1)},
    name = {enabled = true},
    dist = {enabled = true},
    hp = {enabled = true},
    hpbar = {enabled = true},

    chams = {
        enabled = false,
        visibleOnly = false,
        fill = Color3.fromRGB(255,0,0),
        outline = Color3.new(1,1,1),
        transparency = .5
    }
}
--// service @ esp
local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local camera = workspace.CurrentCamera
local coregui = game:GetService("CoreGui")

local lp = players.LocalPlayer
local cache = {}

local function create(class, props)
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

local function getColor(hum)
    local hp = hum.Health / hum.MaxHealth

    return Color3.fromRGB(
        255 - (hp * 255),
        hp * 255,
        0
    )
end

local function visible(part)
    local origin = camera.CFrame.Position

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {
        lp.Character,
        camera
    }

    local ray = workspace:Raycast(
        origin,
        (part.Position - origin).Unit * 9999,
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

    local top = camera:WorldToViewportPoint(
        head.Position + Vector3.new(0,.5,0)
    )

    local bottom = camera:WorldToViewportPoint(
        hrp.Position - Vector3.new(0,3,0)
    )

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

local espObject = {}
espObject.__index = espObject

function espObject:hide()
    hide(self.drawings)
end

function espObject:remove()
    for _,v in pairs(self.drawings) do
        if typeof(v) == "Instance" then
            v:Destroy()
        else
            v:Remove()
        end
    end
end

function espObject:update()
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

    if settings.teamCheck then
        if plr.Team == lp.Team then
            return self:hide()
        end
    end

    local vec, onScreen = camera:WorldToViewportPoint(hrp.Position)

    local dist = math.floor(
        (camera.CFrame.Position - hrp.Position).Magnitude
    )

    if not onScreen or dist > settings.maxDistance then
        return self:hide()
    end

    local box = getBox(char)

    if not box then
        return self:hide()
    end

    local isVisible = true

    if settings.visibleCheck then
        isVisible = visible(head)
    end

    local d = self.drawings

    d.box.Size = box.size
    d.box.Position = box.position
    d.box.Color = settings.box.color
    d.box.Visible = settings.box.enabled

    d.outline.Size = box.size
    d.outline.Position = box.position
    d.outline.Visible = settings.box.enabled and settings.box.outline

    d.name.Text = plr.Name
    d.name.Position = Vector2.new(
        box.position.X + box.size.X/2,
        box.position.Y - 16
    )

    d.name.Visible = settings.name.enabled

    d.dist.Text = dist.." studs"
    d.dist.Position = Vector2.new(
        box.position.X + box.size.X/2,
        box.position.Y + box.size.Y + 2
    )

    d.dist.Visible = settings.dist.enabled

    d.hp.Text = tostring(math.floor(hum.Health))
    d.hp.Color = getColor(hum)

    d.hp.Position = Vector2.new(
        box.position.X + box.size.X + 16,
        box.position.Y
    )

    d.hp.Visible = settings.hp.enabled

    local hp = hum.Health / hum.MaxHealth
    local size = box.size.Y * hp

    d.hpbar.Size = Vector2.new(2,size)

    d.hpbar.Position = Vector2.new(
        box.position.X - 6,
        box.position.Y + (box.size.Y - size)
    )

    d.hpbar.Color = getColor(hum)
    d.hpbar.Visible = settings.hpbar.enabled

    d.hpoutline.Size = Vector2.new(4,box.size.Y + 2)

    d.hpoutline.Position = Vector2.new(
        box.position.X - 7,
        box.position.Y - 1
    )

    d.hpoutline.Visible = settings.hpbar.enabled

    if settings.chams.enabled then
        d.highlight.Enabled = true
        d.highlight.Adornee = char

        if settings.chams.visibleOnly then
            d.highlight.FillColor = isVisible and
                Color3.fromRGB(0,255,0)
                or
                Color3.fromRGB(255,0,0)
        else
            d.highlight.FillColor = settings.chams.fill
        end

        d.highlight.OutlineColor = settings.chams.outline
        d.highlight.FillTransparency = settings.chams.transparency
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

    drawings.box = create("Square", {
        Thickness = 1,
        Filled = false,
        Color = Color3.new(1,1,1)
    })

    drawings.outline = create("Square", {
        Thickness = 3,
        Filled = false,
        Color = Color3.new(0,0,0)
    })

    drawings.name = create("Text", {
        Center = true,
        Outline = true,
        Font = 2,
        Size = settings.textSize,
        Color = Color3.new(1,1,1)
    })

    drawings.dist = create("Text", {
        Center = true,
        Outline = true,
        Font = 2,
        Size = settings.textSize,
        Color = Color3.new(1,1,1)
    })

    drawings.hp = create("Text", {
        Center = true,
        Outline = true,
        Font = 2,
        Size = settings.textSize
    })

    drawings.hpbar = create("Square", {
        Filled = true,
        Thickness = 1
    })

    drawings.hpoutline = create("Square", {
        Filled = false,
        Thickness = 1,
        Color = Color3.new(0,0,0)
    })

    drawings.highlight = Instance.new("Highlight")
    drawings.highlight.Parent = coregui
    drawings.highlight.Enabled = false

    cache[plr] = setmetatable({
        player = plr,
        drawings = drawings
    }, espObject)
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

runservice.RenderStepped:Connect(function()
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
