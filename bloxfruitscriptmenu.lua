--[[
    Blox Fruit Support Menu - GEMINI EDITION 🌟 (V4 - ULTIMATE)
    Cập nhật: Anti-Water (Auto ON), Anti-AFK, Rainbow UI, Logo Changer, Anti-Touch (Max 300).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ==========================================
-- CÀI ĐẶT CHUNG VÀ BIẾN
-- ==========================================
local Settings = {
    FlyEnabled = false,
    FlySpeed = 50,
    LoopSpeed = false,
    SpeedValue = 16,
    LoopJump = false,
    JumpValue = 50,
    InfJump = false,
    CurrentTeam = "Pirates",
    AntiWater = true, -- TỰ ĐỘNG BẬT KHI CHẠY SCRIPT
    
    -- PvP
    Aimbot = false,
    HitboxExpander = false,
    HitboxSize = 15,
    AutoClick = false,
    AntiTouch = false,
    AntiTouchRadius = 15,
    
    -- Auto & Farm
    BringMobs = false,
    BringRadius = 100,
    BringOffsetX = 0,
    BringOffsetY = 10,
    AutoMelee = false,
    AutoDefense = false,
    AutoSword = false,
    AutoGun = false,
    AutoFruit = false,
    
    -- ESP & Nhìn
    ESP_Enabled = false,
    ESP_Boxes = true,
    ESP_Names = true,
    ESP_Lines = false,
    Fullbright = false,

    -- Misc
    RainbowUI = false,
    AntiAFK = false
}

local ESP_Objects = {}
local isAutoFlying = false
local Spectating = nil

-- QUẢN LÝ MENU EXTERNAL (MENU TỔNG HỢP)
local ExternalGuis = {}
local function LoadExternalMenu()
    local con1, con2
    
    -- Theo dõi CoreGui để bắt GUI của menu ngoài
    con1 = CoreGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") and child.Name ~= "BloxFruitGeminiHub" then
            table.insert(ExternalGuis, child)
        end
    end)
    
    -- Theo dõi PlayerGui đề phòng menu ngoài load vào đó
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        con2 = playerGui.ChildAdded:Connect(function(child)
            if child:IsA("ScreenGui") and child.Name ~= "BloxFruitGeminiHub" then
                table.insert(ExternalGuis, child)
            end
        end)
    end

    -- Chạy script loadstring
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/menutonghop.lua"))()
        end)
    end)

    -- Ngừng theo dõi sau 3 giây (đảm bảo menu ngoài đã load xong)
    task.delay(3, function()
        if con1 then con1:Disconnect() end
        if con2 then con2:Disconnect() end
    end)
end

local function RemoveExternalMenu()
    -- Lặp qua các UI đã bắt được và xóa chúng
    for _, gui in ipairs(ExternalGuis) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    ExternalGuis = {} -- Xóa trắng danh sách lưu trữ
end

-- TÔNG MÀU GEMINI (MẶC ĐỊNH)
local C_Bg = Color3.fromRGB(15, 15, 22)           
local C_Frame = Color3.fromRGB(24, 24, 34)        
local C_Accent1 = Color3.fromRGB(138, 180, 248)   
local C_Accent2 = Color3.fromRGB(197, 138, 249)   
local C_Text = Color3.fromRGB(240, 240, 245)      
local C_Off = Color3.fromRGB(255, 80, 100)        

-- LƯU TRỮ PHẦN TỬ CHO RAINBOW UI
local RainbowElements = {
    Texts = {},
    Strokes = {},
    ScrollBars = {},
    Fills = {}
}

-- ==========================================
-- ANTI-AFK CHỐNG KICK
-- ==========================================
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ==========================================
-- TẠO GIAO DIỆN (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxFruitGeminiHub"
ScreenGui.ResetOnSpawn = false

local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Hàm kéo thả UI
local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition = nil, nil, nil, nil
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        end
    end)
end

-- ================== LOGO MỞ MENU ==================
local OpenLogo = Instance.new("TextButton")
OpenLogo.Name = "OpenLogo"
OpenLogo.Parent = ScreenGui
OpenLogo.BackgroundColor3 = C_Bg
OpenLogo.BackgroundTransparency = 0.2
OpenLogo.Position = UDim2.new(0, 15, 0, 15)
OpenLogo.Size = UDim2.new(0, 50, 0, 50)
OpenLogo.Text = "✨" 
OpenLogo.TextSize = 26
OpenLogo.Active = true

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = OpenLogo

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = C_Accent1
LogoStroke.Thickness = 2
LogoStroke.Parent = OpenLogo
table.insert(RainbowElements.Strokes, LogoStroke)

MakeDraggable(OpenLogo, OpenLogo)

-- ================== MAIN FRAME ==================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = C_Bg
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.Size = UDim2.new(0, 550, 0, 360)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = C_Accent2
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame
table.insert(RainbowElements.Strokes, MainStroke)

-- Nút thu phóng (Resize)
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Parent = MainFrame
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Position = UDim2.new(1, -25, 1, -25)
ResizeHandle.Size = UDim2.new(0, 25, 0, 25)
ResizeHandle.Font = Enum.Font.GothamBold
ResizeHandle.Text = "↘"
ResizeHandle.TextColor3 = C_Accent1
ResizeHandle.TextSize = 20
ResizeHandle.ZIndex = 10
table.insert(RainbowElements.Texts, ResizeHandle)

local resizing, resizeStart, startSize = false, nil, nil
ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true; resizeStart = input.Position; startSize = MainFrame.Size
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStart
        MainFrame.Size = UDim2.new(0, math.clamp(startSize.X.Offset + delta.X, 450, 900), 0, math.clamp(startSize.Y.Offset + delta.Y, 300, 700))
    end
end)

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Parent = MainFrame
Topbar.BackgroundColor3 = C_Frame
Topbar.Size = UDim2.new(1, 0, 0, 45)
Topbar.ZIndex = 2
Topbar.Active = true

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 12)
TopbarCorner.Parent = Topbar

local TopbarFix = Instance.new("Frame")
TopbarFix.Parent = Topbar
TopbarFix.BackgroundColor3 = C_Frame
TopbarFix.Position = UDim2.new(0, 0, 0.5, 0)
TopbarFix.Size = UDim2.new(1, 0, 0.5, 0)
TopbarFix.BorderSizePixel = 0
TopbarFix.ZIndex = 2

local Title = Instance.new("TextLabel")
Title.Parent = Topbar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "✨ MENU BLOX FRUIT - GEMINI V4"
Title.TextColor3 = C_Accent1
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 5
table.insert(RainbowElements.Texts, Title)

-- Nút Đóng Menu
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Topbar
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 10 
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
OpenLogo.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
MakeDraggable(Topbar, MainFrame)

-- ================== TABS & CONTAINERS ==================
local TabContainer = Instance.new("Frame")
TabContainer.Parent = MainFrame
TabContainer.BackgroundColor3 = C_Frame
TabContainer.Position = UDim2.new(0, 0, 0, 45)
TabContainer.Size = UDim2.new(0, 140, 1, -45)

local TabLine = Instance.new("Frame")
TabLine.Parent = MainFrame 
TabLine.BackgroundColor3 = C_Accent2
TabLine.BackgroundTransparency = 0.5
TabLine.Position = UDim2.new(0, 140, 0, 45)
TabLine.Size = UDim2.new(0, 1, 1, -45)
TabLine.BorderSizePixel = 0

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 150, 0, 55)
ContentContainer.Size = UDim2.new(1, -160, 1, -65)

local Tabs = {}
local function CreateTab(name, id)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = TabContainer
    TabBtn.BackgroundTransparency = 1
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = id
    TabPage.Parent = ContentContainer
    TabPage.BackgroundTransparency = 1
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.ScrollBarThickness = 3
    TabPage.ScrollBarImageColor3 = C_Accent1
    TabPage.Visible = false
    TabPage.Active = true
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    table.insert(RainbowElements.ScrollBars, TabPage)
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = TabPage
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)

    Tabs[id] = {Button = TabBtn, Page = TabPage}

    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Button.TextColor3 = Color3.fromRGB(150, 150, 160)
            tab.Page.Visible = false
        end
        if Settings.RainbowUI then
            -- Let loop handle it
        else
            TabBtn.TextColor3 = C_Accent2
        end
        TabPage.Visible = true
    end)
    return TabPage
end

local TabMain = CreateTab("🏠 Chính", "Main")
local TabAuto = CreateTab("⚡ Tự Động", "Auto")
local TabPvP = CreateTab("⚔️ PvP Hỗ Trợ", "PvP")
local TabPlayers = CreateTab("👥 Người Chơi", "Players")
local TabESP = CreateTab("👁️ ESP & Nhìn", "ESP")
local TabMisc = CreateTab("⚙️ Khác (Misc)", "Misc")

Tabs["Main"].Button.TextColor3 = C_Accent2
Tabs["Main"].Page.Visible = true

-- ================== CÔNG CỤ TẠO UI (UI BUILDERS) ==================
local function CreateLabel(parent, text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Parent = parent
    Lbl.BackgroundTransparency = 1
    Lbl.Size = UDim2.new(1, -15, 0, 20)
    Lbl.Font = Enum.Font.GothamBold
    Lbl.Text = text
    Lbl.TextColor3 = C_Accent2
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(RainbowElements.Texts, Lbl)
end

-- ĐÃ CHỈNH SỬA TÍCH HỢP TRẠNG THÁI MẶC ĐỊNH
local function CreateToggle(parent, text, callback, defaultState)
    local state = defaultState or false
    
    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.BackgroundColor3 = C_Frame
    Frame.Size = UDim2.new(1, -15, 0, 45)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = text
    Label.TextColor3 = C_Text
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = Frame
    ToggleBtn.BackgroundColor3 = state and C_Accent2 or C_Off
    ToggleBtn.Position = UDim2.new(1, -65, 0.5, -12)
    ToggleBtn.Size = UDim2.new(0, 50, 0, 24)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = state and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 11
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            if not Settings.RainbowUI then TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = C_Accent2}):Play() end
            ToggleBtn.Text = "ON"
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = C_Off}):Play()
            ToggleBtn.Text = "OFF"
        end
        callback(state)
    end)
    
    table.insert(RainbowElements.Fills, {Element = ToggleBtn, CheckState = function() return state end})
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.BackgroundColor3 = C_Frame
    Btn.Size = UDim2.new(1, -15, 0, 40)
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = text
    Btn.TextColor3 = C_Accent1
    Btn.TextSize = 13
    table.insert(RainbowElements.Texts, Btn)

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = C_Accent1
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Btn
    table.insert(RainbowElements.Strokes, Stroke)

    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.BackgroundColor3 = C_Frame
    Frame.Size = UDim2.new(1, -15, 0, 55)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.Size = UDim2.new(0.5, 0, 0, 20)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = text
    Label.TextColor3 = C_Text
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = Frame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(0.5, -15, 0, 5)
    ValueLabel.Size = UDim2.new(0.5, 0, 0, 20)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = C_Accent2
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    table.insert(RainbowElements.Texts, ValueLabel)

    local SliderBg = Instance.new("TextButton")
    SliderBg.Parent = Frame
    SliderBg.BackgroundColor3 = C_Bg
    SliderBg.Position = UDim2.new(0, 15, 0, 35)
    SliderBg.Size = UDim2.new(1, -30, 0, 8)
    SliderBg.Text = ""
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBg
    SliderFill.BackgroundColor3 = C_Accent1
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    table.insert(RainbowElements.Fills, {Element = SliderFill, CheckState = function() return true end})

    local dragging = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        ValueLabel.Text = tostring(val)
        callback(val)
    end

    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
    end)
end

-- ==========================================
-- LOGIC & CHỨC NĂNG CỐT LÕI
-- ==========================================

-- Lấy Bounty
local function GetPlayerBounty(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local bounty = leaderstats:FindFirstChild("Bounty") or leaderstats:FindFirstChild("Bounty/Honor") or leaderstats:FindFirstChild("Honor")
        if bounty then return bounty.Value end
    end
    return 0
end

-- Đổi phe
local function SwitchTeam()
    Settings.CurrentTeam = (Settings.CurrentTeam == "Pirates") and "Marines" or "Pirates"
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if Remotes and Remotes:FindFirstChild("CommF_") then
        pcall(function() Remotes.CommF_:InvokeServer("SetTeam", Settings.CurrentTeam) end)
    end
end

-- ANTI-WATER PLATFORM (KHÔNG CHẠM NƯỚC)
local WaterWalk = Instance.new("Part", workspace)
WaterWalk.Size = Vector3.new(200, 5, 200)
WaterWalk.Transparency = 1
WaterWalk.Anchored = true
WaterWalk.CanCollide = false
WaterWalk.Name = "GeminiWaterWalk"

RunService.Heartbeat:Connect(function()
    if Settings.AntiWater and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        WaterWalk.CanCollide = true
        -- Level nước của Blox Fruit thường nằm ở toạ độ Y = 14-15
        WaterWalk.Position = Vector3.new(LocalPlayer.Character.HumanoidRootPart.Position.X, 12.5, LocalPlayer.Character.HumanoidRootPart.Position.Z)
    else
        WaterWalk.CanCollide = false
        WaterWalk.Position = Vector3.new(0, -5000, 0)
    end
end)

-- VÒNG LẶP GLOBAL CƠ BẢN
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    -- Noclip khi bay
    if Settings.FlyEnabled or isAutoFlying then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
    
    -- Chống chạm (Anti-Touch) cho PVP
    if Settings.AntiTouch and char:FindFirstChild("HumanoidRootPart") then
        local myHRP = char.HumanoidRootPart
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local otherHRP = plr.Character.HumanoidRootPart
                local dist = (myHRP.Position - otherHRP.Position).Magnitude
                if dist < Settings.AntiTouchRadius then
                    -- Đẩy nhân vật của mình ra xa người chơi kia
                    local direction = (myHRP.Position - otherHRP.Position).Unit
                    -- Xóa bỏ chiều Y để không bị đẩy bay lên trời quá lố
                    direction = Vector3.new(direction.X, 0, direction.Z).Unit
                    myHRP.CFrame = myHRP.CFrame + (direction * (Settings.AntiTouchRadius - dist))
                end
            end
        end
    end
end)

-- GIAO DIỆN CẦU VỒNG (RAINBOW UI)
RunService.RenderStepped:Connect(function()
    if Settings.RainbowUI then
        local hue = tick() % 5 / 5
        local rgb = Color3.fromHSV(hue, 1, 1)
        
        -- Cập nhật Logo Mở Menu
        LogoStroke.Color = rgb
        OpenLogo.TextColor3 = rgb
        
        -- Cập nhật Tab Đang Bật
        for _, tab in pairs(Tabs) do
            if tab.Page.Visible then
                tab.Button.TextColor3 = rgb
            end
        end

        for _, stroke in pairs(RainbowElements.Strokes) do stroke.Color = rgb end
        for _, textObj in pairs(RainbowElements.Texts) do textObj.TextColor3 = rgb end
        for _, scroll in pairs(RainbowElements.ScrollBars) do scroll.ScrollBarImageColor3 = rgb end
        for _, fillData in pairs(RainbowElements.Fills) do
            if fillData.CheckState() then fillData.Element.BackgroundColor3 = rgb end
        end
    end
end)

-- LOGIC AUTO FLY
local flyTween, autoFlyTarget = nil, nil
local function StopAutoFly()
    isAutoFlying = false; autoFlyTarget = nil
    if flyTween then flyTween:Cancel() end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("TweenFlyBV") then
        char.HumanoidRootPart.TweenFlyBV:Destroy()
    end
end

local function StartAutoFlyTo(targetPlayer)
    if not targetPlayer then return end
    StopAutoFly()
    isAutoFlying = true; autoFlyTarget = targetPlayer
    
    task.spawn(function()
        while isAutoFlying and autoFlyTarget and autoFlyTarget.Character and autoFlyTarget.Character:FindFirstChild("HumanoidRootPart") do
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") or char.Humanoid.Health <= 0 then break end
            
            local myHRP = char.HumanoidRootPart
            local targetHRP = autoFlyTarget.Character.HumanoidRootPart
            local dist = (myHRP.Position - targetHRP.Position).Magnitude
            if dist <= 15 then break end
            
            local bv = myHRP:FindFirstChild("TweenFlyBV") or Instance.new("BodyVelocity")
            bv.Name = "TweenFlyBV"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = myHRP
            
            local speed = Settings.FlySpeed > 50 and Settings.FlySpeed or 250
            flyTween = TweenService:Create(myHRP, TweenInfo.new(dist / speed, Enum.EasingStyle.Linear), {CFrame = targetHRP.CFrame})
            flyTween:Play()
            task.wait(0.2)
        end
        StopAutoFly()
    end)
end

-- LOGIC TỐC ĐỘ, SPECTATE, ESP
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    
    if hum then
        if Settings.LoopSpeed and hum.WalkSpeed ~= Settings.SpeedValue then hum.WalkSpeed = Settings.SpeedValue end
        if Settings.LoopJump then
            hum.UseJumpPower = true
            if hum.JumpPower ~= Settings.JumpValue then hum.JumpPower = Settings.JumpValue end
        end
    end

    if Spectating and Spectating.Character and Spectating.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = Spectating.Character.Humanoid
    elseif Spectating == false and hum then
        Camera.CameraSubject = hum
        Spectating = nil
    end

    if Settings.Fullbright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
    end

    if Settings.Aimbot then
        local nearest, shortestDist = nil, math.huge
        local myPos = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position

        if myPos then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                    local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                    if dist < shortestDist then shortestDist = dist; nearest = plr end
                end
            end
            if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, nearest.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if Settings.AutoClick then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end)
        end
    end
end)

-- GOM QUÁI (Bring Mobs)
RunService.Heartbeat:Connect(function()
    if not Settings.BringMobs then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- Áp dụng offset người dùng chỉnh (X, Y)
    local myPos = char.HumanoidRootPart.CFrame * CFrame.new(Settings.BringOffsetX, Settings.BringOffsetY, -10)
    local Enemies = workspace:FindFirstChild("Enemies")
    if Enemies then
        for _, mob in pairs(Enemies:GetChildren()) do
            if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                local dist = (mob.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if dist <= Settings.BringRadius then 
                    mob.HumanoidRootPart.CFrame = myPos
                    mob.HumanoidRootPart.Size = Vector3.new(5,5,5) 
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if Remotes and Remotes:FindFirstChild("CommF_") then
            if Settings.AutoMelee then Remotes.CommF_:InvokeServer("AddPoint", "Melee", 1) end
            if Settings.AutoDefense then Remotes.CommF_:InvokeServer("AddPoint", "Defense", 1) end
            if Settings.AutoSword then Remotes.CommF_:InvokeServer("AddPoint", "Sword", 1) end
            if Settings.AutoGun then Remotes.CommF_:InvokeServer("AddPoint", "Gun", 1) end
            if Settings.AutoFruit then Remotes.CommF_:InvokeServer("AddPoint", "Demon Fruit", 1) end
        end
    end
end)

-- ==========================================
-- GIAO DIỆN: TAB CHÍNH (MAIN)
-- ==========================================
CreateLabel(TabMain, "✦ DI CHUYỂN & BAY")
CreateToggle(TabMain, "Đi Trên Nước (Anti-Water)", function(state) Settings.AntiWater = state end, true)
CreateToggle(TabMain, "Bay thủ công (Tự Noclip)", function(state) Settings.FlyEnabled = state end)
CreateSlider(TabMain, "Tốc độ bay", 16, 350, 50, function(value) Settings.FlySpeed = value end)

local TeamBtn = CreateButton(TabMain, "Đổi Phe (Đang chọn: Hải Tặc)", function() SwitchTeam() end)
TeamBtn.MouseButton1Click:Connect(function() TeamBtn.Text = (Settings.CurrentTeam == "Pirates") and "Đổi Phe (Đang chọn: Hải Tặc)" or "Đổi Phe (Đang chọn: Hải Quân)" end)

CreateButton(TabMain, "Bay đến người GẦN NHẤT", function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position
    local nearest, shortestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < shortestDist then shortestDist = dist; nearest = plr end
        end
    end
    StartAutoFlyTo(nearest)
end)
CreateButton(TabMain, "Bay đến BOUNTY CAO NHẤT", function()
    local target, highestBounty = nil, -1
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local bounty = GetPlayerBounty(plr)
            if bounty > highestBounty then highestBounty = bounty; target = plr end
        end
    end
    StartAutoFlyTo(target)
end)
CreateButton(TabMain, "🛑 HỦY TỰ ĐỘNG BAY", function() StopAutoFly() end)

CreateLabel(TabMain, "✦ TỐC ĐỘ & NHẢY")
CreateToggle(TabMain, "Chạy siêu tốc", function(state) Settings.LoopSpeed = state; if not state and LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end)
CreateSlider(TabMain, "Tốc độ chạy", 16, 350, 16, function(value) Settings.SpeedValue = value end)

CreateToggle(TabMain, "Nhảy cao", function(state) Settings.LoopJump = state; if not state and LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = 50 end end)
CreateSlider(TabMain, "Lực nhảy", 50, 300, 50, function(value) Settings.JumpValue = value end)
CreateToggle(TabMain, "Nhảy vô hạn (Infinite Jump)", function(state) Settings.InfJump = state end)

-- ==========================================
-- GIAO DIỆN: TAB TỰ ĐỘNG (AUTO)
-- ==========================================
CreateLabel(TabAuto, "✦ AUTO FARM HỖ TRỢ")
CreateToggle(TabAuto, "Gom Quái Lại Gần (Bring Mobs)", function(state) Settings.BringMobs = state end)
CreateSlider(TabAuto, "Bán Kính Gom Quái", 20, 500, 100, function(value) Settings.BringRadius = value end)
CreateSlider(TabAuto, "Độ Cao Gom (Y Offset)", -50, 50, 10, function(value) Settings.BringOffsetY = value end)
CreateSlider(TabAuto, "Khoảng Ngang Gom (X Offset)", -50, 50, 0, function(value) Settings.BringOffsetX = value end)

CreateLabel(TabAuto, "✦ AUTO CỘNG ĐIỂM (STATS)")
CreateToggle(TabAuto, "Cộng Cận Chiến (Melee)", function(state) Settings.AutoMelee = state end)
CreateToggle(TabAuto, "Cộng Phòng Thủ (Defense)", function(state) Settings.AutoDefense = state end)
CreateToggle(TabAuto, "Cộng Kiếm (Sword)", function(state) Settings.AutoSword = state end)
CreateToggle(TabAuto, "Cộng Súng (Gun)", function(state) Settings.AutoGun = state end)
CreateToggle(TabAuto, "Cộng Trái Ác Quỷ (Fruit)", function(state) Settings.AutoFruit = state end)

-- ==========================================
-- GIAO DIỆN: TAB PVP
-- ==========================================
CreateLabel(TabPvP, "✦ HỖ TRỢ CHIẾN ĐẤU & PHÒNG THỦ")
CreateToggle(TabPvP, "Khóa Màn Hình (Aimbot)", function(state) Settings.Aimbot = state end)
CreateToggle(TabPvP, "Tự Động Đánh (Auto Click)", function(state) Settings.AutoClick = state end)

CreateToggle(TabPvP, "Đánh Dễ Trúng (Mở Rộng Hitbox)", function(state)
    Settings.HitboxExpander = state
    if not state then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                plr.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end
end)
CreateSlider(TabPvP, "Độ to của Hitbox", 5, 50, 15, function(value) Settings.HitboxSize = value end)

CreateToggle(TabPvP, "Bật Chống Chạm (Anti-Touch/Repel)", function(state) Settings.AntiTouch = state end)
CreateSlider(TabPvP, "Bán Kính Chống Chạm", 10, 300, 15, function(value) Settings.AntiTouchRadius = value end)

-- ==========================================
-- GIAO DIỆN: TAB KHÁC (MISC)
-- ==========================================
CreateLabel(TabMisc, "✦ CÀI ĐẶT MENU & MÀU SẮC")
CreateToggle(TabMisc, "Chế độ Màu Cầu Vồng (Rainbow UI)", function(state) 
    Settings.RainbowUI = state 
    -- Khôi phục màu gốc nếu tắt
    if not state then
        LogoStroke.Color = C_Accent1
        OpenLogo.TextColor3 = C_Text
        for _, tab in pairs(Tabs) do
            tab.Button.TextColor3 = tab.Page.Visible and C_Accent2 or Color3.fromRGB(150, 150, 160)
        end
        for _, stroke in pairs(RainbowElements.Strokes) do stroke.Color = C_Accent2 end
        for _, textObj in pairs(RainbowElements.Texts) do textObj.TextColor3 = C_Accent1 end
        for _, scroll in pairs(RainbowElements.ScrollBars) do scroll.ScrollBarImageColor3 = C_Accent1 end
        for _, fillData in pairs(RainbowElements.Fills) do
            if fillData.CheckState() then fillData.Element.BackgroundColor3 = C_Accent2 end
        end
    end
end)

CreateLabel(TabMisc, "✦ ĐỔI LOGO KÉO THẢ")
CreateButton(TabMisc, "Logo Tia Sáng (✨)", function() OpenLogo.Text = "✨" end)
CreateButton(TabMisc, "Logo Dải Ngân Hà (🌌)", function() OpenLogo.Text = "🌌" end)
CreateButton(TabMisc, "Logo Ngọn Lửa (🔥)", function() OpenLogo.Text = "🔥" end)
CreateButton(TabMisc, "Logo Hải Tặc (💀)", function() OpenLogo.Text = "💀" end)

CreateLabel(TabMisc, "✦ BẢO VỆ TÀI KHOẢN")
CreateToggle(TabMisc, "Chống Bị Kick Khi Treo (Anti-AFK)", function(state) Settings.AntiAFK = state end)

CreateLabel(TabMisc, "✦ MENU TỔNG HỢP (EXTERNAL)")
CreateButton(TabMisc, "▶️ Chạy Lại Menu Tổng Hợp", function() LoadExternalMenu() end)
CreateButton(TabMisc, "🗑️ Xóa/Đóng Menu Tổng Hợp", function() RemoveExternalMenu() end)

-- ==========================================
-- GIAO DIỆN: TAB NGƯỜI CHƠI
-- ==========================================
local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Parent = TabPlayers
PlayerListFrame.BackgroundTransparency = 1
PlayerListFrame.Size = UDim2.new(1, -15, 0, 0)
PlayerListFrame.AutomaticSize = Enum.AutomaticSize.Y

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Parent = PlayerListFrame
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Padding = UDim.new(0, 5)

local function RefreshPlayerList()
    for _, child in pairs(PlayerListFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local row = Instance.new("Frame")
            row.Parent = PlayerListFrame
            row.BackgroundColor3 = C_Frame
            row.Size = UDim2.new(1, 0, 0, 45)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Parent = row
            NameLabel.BackgroundTransparency = 1
            NameLabel.Position = UDim2.new(0, 10, 0, 0)
            NameLabel.Size = UDim2.new(0.35, 0, 1, 0)
            NameLabel.Font = Enum.Font.GothamSemibold
            NameLabel.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
            NameLabel.TextColor3 = C_Text
            NameLabel.TextSize = 11
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            
            local SpecBtn = Instance.new("TextButton")
            SpecBtn.Parent = row
            SpecBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
            SpecBtn.Position = UDim2.new(1, -60, 0.5, -12)
            SpecBtn.Size = UDim2.new(0, 50, 0, 24)
            SpecBtn.Font = Enum.Font.GothamBold
            SpecBtn.Text = "Xem"
            SpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            SpecBtn.TextSize = 11
            Instance.new("UICorner", SpecBtn).CornerRadius = UDim.new(0, 6)
            SpecBtn.MouseButton1Click:Connect(function()
                if Spectating == plr then Spectating = false; SpecBtn.Text = "Xem"
                else Spectating = plr; SpecBtn.Text = "Dừng" end
            end)

            local FlyBtn = Instance.new("TextButton")
            FlyBtn.Parent = row
            FlyBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            FlyBtn.Position = UDim2.new(1, -115, 0.5, -12)
            FlyBtn.Size = UDim2.new(0, 50, 0, 24)
            FlyBtn.Font = Enum.Font.GothamBold
            FlyBtn.Text = "Bay Tới"
            FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            FlyBtn.TextSize = 11
            Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 6)
            FlyBtn.MouseButton1Click:Connect(function() StartAutoFlyTo(plr) end)
            
            local BountyBtn = Instance.new("TextButton")
            BountyBtn.Parent = row
            BountyBtn.BackgroundColor3 = Color3.fromRGB(45, 105, 200)
            BountyBtn.Position = UDim2.new(1, -200, 0.5, -12)
            BountyBtn.Size = UDim2.new(0, 80, 0, 24)
            BountyBtn.Font = Enum.Font.GothamBold
            BountyBtn.Text = "Bounty"
            BountyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            BountyBtn.TextSize = 11
            Instance.new("UICorner", BountyBtn).CornerRadius = UDim.new(0, 6)
            BountyBtn.MouseButton1Click:Connect(function()
                BountyBtn.Text = tostring(GetPlayerBounty(plr))
                task.delay(3, function() if BountyBtn then BountyBtn.Text = "Bounty" end end)
            end)
        end
    end
end

CreateButton(TabPlayers, "🔄 Làm Mới Danh Sách", function() RefreshPlayerList() end)
CreateButton(TabPlayers, "🛑 Dừng Spectate (Góc nhìn cũ)", function() Spectating = false end)
RefreshPlayerList()

-- ==========================================
-- GIAO DIỆN & LOGIC: TAB ESP
-- ==========================================
CreateLabel(TabESP, "✦ ESP (NHÌN XUYÊN TƯỜNG)")
CreateToggle(TabESP, "Bật ESP Tổng", function(state)
    Settings.ESP_Enabled = state
    if not state then
        for _, obj in pairs(ESP_Objects) do
            if obj.Box then obj.Box:Remove() end
            if obj.Name then obj.Name:Remove() end
            if obj.Line then obj.Line:Remove() end
        end
        ESP_Objects = {}
    end
end)

CreateToggle(TabESP, "Khung (Box)", function(state) Settings.ESP_Boxes = state end)
CreateToggle(TabESP, "Tên (Name)", function(state) Settings.ESP_Names = state end)
CreateToggle(TabESP, "Đường Kẻ (Line)", function(state) Settings.ESP_Lines = state end)
CreateLabel(TabESP, "✦ THỊ GIÁC")
CreateToggle(TabESP, "Sáng Màn Hình (Fullbright)", function(state) Settings.Fullbright = state end)

RunService.RenderStepped:Connect(function()
    if not Settings.ESP_Enabled then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hrp = char.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if not ESP_Objects[plr] then
                    ESP_Objects[plr] = {
                        Box = Drawing.new("Square"), Name = Drawing.new("Text"), Line = Drawing.new("Line")
                    }
                    ESP_Objects[plr].Box.Thickness = 1.5; ESP_Objects[plr].Box.Filled = false
                    ESP_Objects[plr].Name.Size = 15; ESP_Objects[plr].Name.Center = true; ESP_Objects[plr].Name.Outline = true
                    ESP_Objects[plr].Line.Thickness = 1.5; ESP_Objects[plr].Line.Transparency = 1
                end
                
                local espBox, espName, espLine = ESP_Objects[plr].Box, ESP_Objects[plr].Name, ESP_Objects[plr].Line
                
                if onScreen and vector.Z > 0 then
                    local teamColor = Color3.fromRGB(255, 255, 255)
                    if plr.Team then
                        if plr.Team.Name == "Pirates" then teamColor = Color3.fromRGB(255, 60, 60)
                        elseif plr.Team.Name == "Marines" then teamColor = Color3.fromRGB(60, 150, 255)
                        else teamColor = plr.TeamColor.Color end
                    end
                    
                    espBox.Color = teamColor; espName.Color = teamColor; espLine.Color = teamColor
                    local SizeY = 1000 / vector.Z; local SizeX = SizeY * 0.8
                    
                    espBox.Size = Vector2.new(SizeX, SizeY); espBox.Position = Vector2.new(vector.X - SizeX / 2, vector.Y - SizeY / 2)
                    espBox.Visible = Settings.ESP_Boxes
                    
                    espName.Text = plr.Name; espName.Position = Vector2.new(vector.X, vector.Y - SizeY / 2 - 20)
                    espName.Visible = Settings.ESP_Names

                    espLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); espLine.To = Vector2.new(vector.X, vector.Y - SizeY / 2)
                    espLine.Visible = Settings.ESP_Lines
                else
                    espBox.Visible = false; espName.Visible = false; espLine.Visible = false
                end
            else
                if ESP_Objects[plr] then ESP_Objects[plr].Box.Visible = false; ESP_Objects[plr].Name.Visible = false; ESP_Objects[plr].Line.Visible = false end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if ESP_Objects[plr] then
        ESP_Objects[plr].Box:Remove(); ESP_Objects[plr].Name:Remove(); ESP_Objects[plr].Line:Remove()
        ESP_Objects[plr] = nil
    end
end)

-- ==========================================
-- TỰ ĐỘNG CHẠY MENU TỔNG HỢP KHI MỞ SCRIPT NÀY
-- ==========================================
LoadExternalMenu()
