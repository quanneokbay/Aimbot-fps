--[[
  Aimbot Universal GUI - Quân Script v4 (REAL 360° Aim Update)
  Modified: Enhanced 360° Aim to use Nearest Player Priority
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

-- CONFIG
local Settings = {
    Aimbot = false,
    TeamCheck = false,
    WallCheck = false,
    FOV = 100,
    Part = "Head",
    FOVVisible = true,
    RGB = true,
    AimStrength = 0.5,
    Aim360 = false, -- Thiết lập mặc định
}

-- SOUNDS
local menuSound = Instance.new("Sound")
menuSound.SoundId = "rbxassetid://2556932492"
menuSound.Parent = SoundService

local toggleSound = Instance.new("Sound")
toggleSound.SoundId = "rbxassetid://2556932492"
toggleSound.Parent = SoundService

-- GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local openBtn = Instance.new("TextButton")
openBtn.Text = "Open Quân Menu" -- Đã đổi tên
openBtn.Size = UDim2.new(0, 150, 0, 40)
openBtn.Position = UDim2.new(0, 20, 0.5, -100)
openBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Parent = ScreenGui
openBtn.Active = true
openBtn.Draggable = true

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 250, 0, 360)
menu.Position = UDim2.new(0.5, -125, 0.5, -175)
menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menu.Visible = false
menu.Parent = ScreenGui

local title = Instance.new("TextLabel")
title.Text = "Quân-7p" -- Đã đổi tên
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.TextColor3 = Color3.fromHSV(0, 1, 1)
title.Size = UDim2.new(1, 0, 0, 30)
title.Parent = menu

local scroll = Instance.new("ScrollingFrame", menu)
scroll.Size = UDim2.new(1, 0, 1, -30)
scroll.Position = UDim2.new(0, 0, 0, 30)
scroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", scroll)
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

function createToggle(name, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Text = name .. ": " .. (default and "ON" or "OFF")
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = scroll

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
        toggleSound:Play()
    end)
end

function createOption(name, options, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = scroll

    local index = 1
    btn.Text = name .. ": " .. options[index]

    btn.MouseButton1Click:Connect(function()
        index = index % #options + 1
        btn.Text = name .. ": " .. options[index]
        callback(options[index])
        toggleSound:Play()
    end)
end

function createFOVButtons()
    local fovDown = Instance.new("TextButton")
    local fovUp = Instance.new("TextButton")
    
    fovDown.Size = UDim2.new(0.45, -5, 0, 30)
    fovUp.Size = UDim2.new(0.45, -5, 0, 30)

    fovDown.Text = "- FOV"
    fovUp.Text = "+ FOV"

    fovDown.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    fovUp.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    fovDown.TextColor3 = Color3.new(1, 1, 1)
    fovUp.TextColor3 = Color3.new(1, 1, 1)

    fovDown.Parent = scroll
    fovUp.Parent = scroll

    fovDown.MouseButton1Click:Connect(function()
        Settings.FOV = math.max(10, Settings.FOV - 10)
        toggleSound:Play()
    end)
    fovUp.MouseButton1Click:Connect(function()
        Settings.FOV = math.min(1000, Settings.FOV + 10)
        toggleSound:Play()
    end)
end

function createAimStrengthInput()
    local aimStrengthBtn = Instance.new("TextButton")
    aimStrengthBtn.Size = UDim2.new(1, -10, 0, 30)
    aimStrengthBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    aimStrengthBtn.TextColor3 = Color3.new(1, 1, 1)
    aimStrengthBtn.Text = "Aim Strength: " .. tostring(Settings.AimStrength)
    aimStrengthBtn.Parent = scroll

    local editing = false

    aimStrengthBtn.MouseButton1Click:Connect(function()
        if editing then return end
        editing = true
        aimStrengthBtn.Text = ""
        local inputBox = Instance.new("TextBox")
        inputBox.Size = aimStrengthBtn.Size
        inputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        inputBox.TextColor3 = Color3.new(1, 1, 1)
        inputBox.Text = tostring(Settings.AimStrength)
        inputBox.Parent = aimStrengthBtn

        inputBox.FocusLost:Connect(function()
            local value = tonumber(inputBox.Text)
            if value and value >= 0.1 and value <= 1.0 then
                Settings.AimStrength = value
                aimStrengthBtn.Text = "Aim Strength: " .. tostring(value)
            else
                aimStrengthBtn.Text = "Aim Strength: " .. tostring(Settings.AimStrength)
            end
            inputBox:Destroy()
            editing = false
        end)

        inputBox:CaptureFocus()
    end)
end

-- BUTTONS
createToggle("Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
createToggle("Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
createToggle("Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end)
createToggle("FOV Visible", Settings.FOVVisible, function(v) Settings.FOVVisible = v end)
createToggle("RGB FOV", Settings.RGB, function(v) Settings.RGB = v end)
createToggle("360° Aim (REAL)", Settings.Aim360, function(v) Settings.Aim360 = v end)
createOption("Target Part", {"Head", "Torso"}, function(v) Settings.Part = v end)
createFOVButtons()
createAimStrengthInput()

openBtn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
    menuSound:Play()
end)

-- FOV CIRCLE
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false

local hue = 0

-- RGB HIGHLIGHT
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 1
highlight.OutlineColor = Color3.new(1,0,0)
highlight.Parent = workspace
highlight.Enabled = false

RunService.RenderStepped:Connect(function()
    -- Vô hiệu hóa FOV Circle khi bật 360° Aim để tránh gây rối
    fovCircle.Visible = Settings.FOVVisible and not Settings.Aim360
    fovCircle.Radius = Settings.FOV
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    if Settings.RGB then
        hue = (hue + 1) % 360
        fovCircle.Color = Color3.fromHSV(hue/360, 1, 1)
        highlight.OutlineColor = Color3.fromHSV(hue/360, 1, 1)
    else
        fovCircle.Color = Color3.new(1, 1, 1)
    end

    title.TextColor3 = Settings.RGB and Color3.fromHSV(hue/360, 1, 1)
end)

-- VISIBILITY CHECK
function isVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, raycastParams)
    return not result
end

-- NEW TARGET FUNCTION: Dựa trên ưu tiên
function getClosest()
    local closest = nil
    -- Khởi tạo tiêu chí tìm kiếm lớn nhất có thể
    local smallestDist = math.huge 

    local playerRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return nil end

    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        if p ~= LocalPlayer 
        and char 
        and char:FindFirstChild("Humanoid") 
        and char.Humanoid.Health > 0 
        then

            if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end

            local part = char:FindFirstChild(Settings.Part)
            if not part then continue end

            if Settings.WallCheck and not isVisible(part) then continue end

            local currentDist = math.huge

            if Settings.Aim360 then
                -- THẬT 360° AIM (NEAREST PLAYER PRIORITY): Ưu tiên mục tiêu gần vị trí người chơi nhất
                -- Khoảng cách 3D từ người chơi đến mục tiêu
                currentDist = (part.Position - playerRoot.Position).Magnitude
            else
                -- CHẾ ĐỘ THƯỜNG (NEAREST CROSSHAIR PRIORITY): Ưu tiên mục tiêu gần tâm crosshair nhất và trong FOV
                local screenPos, visible = Camera:WorldToViewportPoint(part.Position)
                if not visible then continue end -- Bắt buộc phải hiển thị trên màn hình

                -- Khoảng cách 2D từ mục tiêu đến tâm màn hình
                local distToCrosshair = (Vector2.new(screenPos.X, screenPos.Y) - 
                                         Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                
                if distToCrosshair > Settings.FOV then continue end

                currentDist = distToCrosshair
            end
            
            if currentDist < smallestDist then
                smallestDist = currentDist
                closest = part
            end
        end
    end

    return closest
end

-- AIMBOT + RGB OUTLINE
RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot then 
        highlight.Enabled = false
        return 
    end

    local target = getClosest()
    if target then
        highlight.Adornee = target.Parent
        highlight.Enabled = true

        local direction = (target.Position - Camera.CFrame.Position).Unit
        local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
        
        -- Sử dụng Lerp để làm mượt chuyển động, ngay cả với 360 độ
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Settings.AimStrength)
    else
        highlight.Enabled = false
    end
end)
