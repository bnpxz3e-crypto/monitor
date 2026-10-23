
-- CEBO FINDER MONITOR V2
-- Delta / Roblox
-- Screen Logger + HTTP + Teleport + Error

local Players = game:GetService("Players")
local LogService = game:GetService("LogService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local URL = "https://raw.githubusercontent.com/apiluarmor-hub/CeboScripts-Eggs-Finder/refs/heads/main/.lua"

-- Clean old monitor
local old = pg:FindFirstChild("CeboMonitor")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "CeboMonitor"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.fromOffset(350, 340)
frame.Position = UDim2.new(0.5, -175, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, -100, 0, 40)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "CEBO MONITOR V2"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton")
close.Parent = frame
close.Size = UDim2.fromOffset(35, 30)
close.Position = UDim2.new(1, -40, 0, 5)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(190, 45, 45)

local minimize = Instance.new("TextButton")
minimize.Parent = frame
minimize.Size = UDim2.fromOffset(35, 30)
minimize.Position = UDim2.new(1, -80, 0, 5)
minimize.Text = "-"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.BackgroundColor3 = Color3.fromRGB(65, 70, 85)

local scroll = Instance.new("ScrollingFrame")
scroll.Parent = frame
scroll.Position = UDim2.fromOffset(10, 45)
scroll.Size = UDim2.new(1, -20, 1, -100)
scroll.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.fromOffset(0, 0)

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0, 5)

local clear = Instance.new("TextButton")
clear.Parent = frame
clear.Size = UDim2.new(0.46, 0, 0, 35)
clear.Position = UDim2.new(0.03, 0, 1, -45)
clear.Text = "CLEAR"
clear.TextColor3 = Color3.new(1, 1, 1)
clear.BackgroundColor3 = Color3.fromRGB(65, 70, 85)

local copy = Instance.new("TextButton")
copy.Parent = frame
copy.Size = UDim2.new(0.46, 0, 0, 35)
copy.Position = UDim2.new(0.51, 0, 1, -45)
copy.Text = "COPY LOG"
copy.TextColor3 = Color3.new(1, 1, 1)
copy.BackgroundColor3 = Color3.fromRGB(0, 130, 90)

local logs = {}
local count = 0
local connections = {}
local alive = true

local green = Color3.fromRGB(40, 255, 140)
local yellow = Color3.fromRGB(255, 195, 60)
local red = Color3.fromRGB(255, 80, 80)
local blue = Color3.fromRGB(90, 190, 255)

local function log(message, color)
    if not alive or not gui.Parent then return end

    count = count + 1

    local text = os.date("%X") .. " " .. tostring(message)
    table.insert(logs, text)

    local line = Instance.new("TextLabel")
    line.Parent = scroll
    line.Size = UDim2.new(1, -10, 0, 0)
    line.AutomaticSize = Enum.AutomaticSize.Y
    line.BackgroundTransparency = 1
    line.TextColor3 = color or Color3.new(1, 1, 1)
    line.TextSize = 13
    line.TextWrapped = true
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.TextYAlignment = Enum.TextYAlignment.Top
    line.Text = count .. ". " .. text

    task.defer(function()
        if scroll.Parent then
            scroll.CanvasPosition =
                Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
        end
    end)
end

local function track(connection)
    table.insert(connections, connection)
end

local function shutdown()
    alive = false
    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    gui:Destroy()
end

track(close.MouseButton1Click:Connect(shutdown))

local small = false
track(minimize.MouseButton1Click:Connect(function()
    small = not small
    frame.Size = small
        and UDim2.fromOffset(350, 40)
        or UDim2.fromOffset(350, 340)

    scroll.Visible = not small
    clear.Visible = not small
    copy.Visible = not small
    minimize.Text = small and "+" or "-"
end))

track(clear.MouseButton1Click:Connect(function()
    logs = {}
    count = 0

    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    log("Log cleared", green)
end))

track(copy.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(table.concat(logs, "\n"))
        log("Log copied", green)
    else
        log("Clipboard unavailable", yellow)
    end
end))

-- Monitor Roblox output
track(LogService.MessageOut:Connect(function(message, kind)
    if kind == Enum.MessageType.MessageError then
        log("ERROR: " .. tostring(message), red)
    elseif kind == Enum.MessageType.MessageWarning then
        log("WARNING: " .. tostring(message), yellow)
    end
end))

-- Monitor failed teleports
track(TeleportService.TeleportInitFailed:Connect(
    function(targetPlayer, result, message, placeId)
        if targetPlayer == player then
            log("TELEPORT FAILED: " .. tostring(message), red)
            log("Target Place: " .. tostring(placeId), yellow)
        end
    end
))

-- Monitor current Job ID
local initialJob = game.JobId
task.spawn(function()
    while alive and gui.Parent do
        if game.JobId ~= initialJob then
            log("JOB ID CHANGED", blue)
            log("New Job: " .. tostring(game.JobId), blue)
            initialJob = game.JobId
        end
        task.wait(2)
    end
end)

log("Monitor started", green)
log("Place ID: " .. tostring(game.PlaceId))
log("Job ID: " .. tostring(game.JobId))
log("HTTP monitoring: limited", yellow)
log("Teleport monitoring: failures only", yellow)

-- Download source
task.spawn(function()
    log("Downloading CeboFinder...", blue)

    local ok, source = pcall(function()
        return game:HttpGet(URL)
    end)

    if not ok then
        log("DOWNLOAD ERROR: " .. tostring(source), red)
        return
    end

    log("HTTP GET: " .. URL, blue)
    log("Download successful", green)
    log("Source size: " .. #source .. " bytes")

    if source:find("Luraph", 1, true) then
        log("Luraph protection detected", yellow)
    end

    local compiled, compileError = loadstring(source)

    if not compiled then
        log("COMPILE ERROR: " .. tostring(compileError), red)
        return
    end

    log("Executing CeboFinder...", yellow)

    local success, result = pcall(compiled)

    if success then
        log("Loader finished without error", green)
    else
        log("RUNTIME ERROR: " .. tostring(result), red)
    end
end)
