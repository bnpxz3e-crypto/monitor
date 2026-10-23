local Players = game:GetService("Players")
local player = Players.LocalPlayer

local URL = "https://raw.githubusercontent.com/apiluarmor-hub/CeboScripts-Eggs-Finder/refs/heads/main/.lua"

local pg = player:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("CeboMonitor")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "CeboMonitor"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.fromOffset(340, 300)
frame.Position = UDim2.new(0.5, -170, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, -100, 0, 40)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "CEBO FINDER MONITOR"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton")
close.Parent = frame
close.Size = UDim2.fromOffset(35, 30)
close.Position = UDim2.new(1, -40, 0, 5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
close.TextColor3 = Color3.new(1, 1, 1)

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
scroll.Size = UDim2.new(1, -20, 1, -55)
scroll.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.fromOffset(0, 0)

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0, 5)

local count = 0

local function log(message, color)
    if not gui.Parent then return end

    count = count + 1

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
    line.Text = count .. ". " .. tostring(message)

    task.defer(function()
        if scroll.Parent then
            scroll.CanvasPosition = Vector2.new(
                0, scroll.AbsoluteCanvasSize.Y
            )
        end
    end)
end

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local small = false
minimize.MouseButton1Click:Connect(function()
    small = not small
    frame.Size = small
        and UDim2.fromOffset(340, 40)
        or UDim2.fromOffset(340, 300)
    scroll.Visible = not small
    minimize.Text = small and "+" or "-"
end)

log("Monitor started", Color3.fromRGB(0, 255, 130))
log("Place ID: " .. game.PlaceId)
log("Job ID: " .. game.JobId)

task.spawn(function()
    log("Downloading CeboFinder...")

    local ok, source = pcall(function()
        return game:HttpGet(URL)
    end)

    if not ok then
        log("Download error: " .. tostring(source),
            Color3.fromRGB(255, 70, 70))
        return
    end

    log("Download successful",
        Color3.fromRGB(0, 255, 130))

    log("Source size: " .. #source .. " bytes")

    if source:find("Luraph", 1, true) then
        log("Luraph protection detected",
            Color3.fromRGB(255, 190, 50))
    end

    local compiled, compileError = loadstring(source)

    if not compiled then
        log("Compile error: " .. tostring(compileError),
            Color3.fromRGB(255, 70, 70))
        return
    end

    log("Executing CeboFinder...",
        Color3.fromRGB(255, 220, 100))

    local success, result = pcall(compiled)

    if success then
        log("Loader finished without error",
            Color3.fromRGB(0, 255, 130))
    else
        log("Runtime error: " .. tostring(result),
            Color3.fromRGB(255, 70, 70))
    end
end)