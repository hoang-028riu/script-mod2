--[[
    BLOON FRUITS ALL-IN-ONE SCRIPT
    Bao gồm: Speed/Jump GUI + Teleport Manager + Auto Load Scripts
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ================================================================= --
-- PHẦN 1: QUẢN LÝ TELEPORT (GIỮ SCRIPT KHI ĐỔI SERVER)
-- ================================================================= --
if not _G.TeleportQueueManager then
    _G.TeleportQueueManager = {
        QueueFunc = queue_on_teleport or 
                    (syn and syn.queue_on_teleport) or 
                    (fluxus and fluxus.queue_on_teleport) or 
                    (KRNL_LOADED and queue_on_teleport),
        Scripts = {},
        HasHooked = false,
        IsTeleporting = false
    }
end

local Manager = _G.TeleportQueueManager

local function AddToTeleportQueue(scriptString)
    if not Manager.QueueFunc then return end
    table.insert(Manager.Scripts, scriptString)
    if not Manager.HasHooked then
        Manager.HasHooked = true
        LocalPlayer.OnTeleport:Connect(function()
            if Manager.IsTeleporting then return end
            Manager.IsTeleporting = true
            local CombinedScript = ""
            for i, code in ipairs(Manager.Scripts) do
                CombinedScript = CombinedScript .. string.format([[
                    task.spawn(function()
                        pcall(function() %s end)
                    end)
                ]], code)
            end
            Manager.QueueFunc(CombinedScript)
        end)
    end
end

-- ================================================================= --
-- PHẦN 2: CÁC SCRIPT TỰ ĐỘNG LOAD
-- ================================================================= --
local ScriptsToLoad = {
    IY = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()",
    BloxFruits = "loadstring(game:HttpGet('https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/bloxfruitscriptmenu.lua'))()",
    ChestFarm = "loadstring(game:HttpGet('https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/chest%20farm'))()"
}

-- Đăng ký các script vào hàng đợi teleport
for _, code in pairs(ScriptsToLoad) do
    AddToTeleportQueue(code)
end

-- Chạy ngay tại server hiện tại
for _, code in pairs(ScriptsToLoad) do
    task.spawn(function() pcall(function() loadstring(code)() end) end)
end

-- ================================================================= --
-- PHẦN 3: GUI ĐIỀU KHIỂN TỐC ĐỘ & NHẢY (TỪ FILE CỦA BẠN)
-- ================================================================= --
local Settings = {
    LoopSpeed = false,
    SpeedValue = 16,
    LoopJump = false,
    JumpValue = 50
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperStatsGui"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -115)
MainFrame.Size = UDim2.new(0, 250, 0, 230)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "BLOX FRUIT STATS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local Container = Instance.new("Frame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 45)
Container.Size = UDim2.new(1, -20, 1, -55)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.Padding = UDim.new(0, 8)

local function CreateControl(text, defaultVal, maxVal, type)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 75)
    Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    local fc = Instance.new("UICorner"); fc.Parent = Frame
    Frame.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 8, 0, 5)
    Label.Size = UDim2.new(1, 0, 0, 15)
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local TextBox = Instance.new("TextBox")
    TextBox.Parent = Frame
    TextBox.Position = UDim2.new(0, 5, 0, 25)
    TextBox.Size = UDim2.new(0.45, 0, 0, 22)
    TextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TextBox.Text = tostring(defaultVal)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    local tbc = Instance.new("UICorner"); tbc.Parent = TextBox

    local Toggle = Instance.new("TextButton")
    Toggle.Parent = Frame
    Toggle.Position = UDim2.new(0.5, 5, 0, 25)
    Toggle.Size = UDim2.new(0.45, 0, 0, 22)
    Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    local tgc = Instance.new("UICorner"); tgc.Parent = Toggle

    local BtnMax = Instance.new("TextButton")
    BtnMax.Parent = Frame
    BtnMax.Position = UDim2.new(0, 5, 0, 50)
    BtnMax.Size = UDim2.new(0.45, 0, 0, 20)
    BtnMax.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    BtnMax.Text = "Max " .. maxVal
    BtnMax.TextColor3 = Color3.fromRGB(255, 255, 255)
    local bmc = Instance.new("UICorner"); bmc.Parent = BtnMax

    local BtnNormal = Instance.new("TextButton")
    BtnNormal.Parent = Frame
    BtnNormal.Position = UDim2.new(0.5, 5, 0, 50)
    BtnNormal.Size = UDim2.new(0.45, 0, 0, 20)
    BtnNormal.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    BtnNormal.Text = "Normal"
    BtnNormal.TextColor3 = Color3.fromRGB(255, 255, 255)
    local bnc = Instance.new("UICorner"); bnc.Parent = BtnNormal

    -- Logic tương tác
    TextBox.FocusLost:Connect(function()
        local val = tonumber(TextBox.Text)
        if val then
            if type == "Speed" then Settings.SpeedValue = val else Settings.JumpValue = val end
        end
    end)

    Toggle.MouseButton1Click:Connect(function()
        if type == "Speed" then
            Settings.LoopSpeed = not Settings.LoopSpeed
            Toggle.Text = Settings.LoopSpeed and "ON" or "OFF"
            Toggle.BackgroundColor3 = Settings.LoopSpeed and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        else
            Settings.LoopJump = not Settings.LoopJump
            Toggle.Text = Settings.LoopJump and "ON" or "OFF"
            Toggle.BackgroundColor3 = Settings.LoopJump and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        end
    end)

    BtnMax.MouseButton1Click:Connect(function()
        TextBox.Text = tostring(maxVal)
        if type == "Speed" then
            Settings.SpeedValue = maxVal
            Settings.LoopSpeed = true
        else
            Settings.JumpValue = maxVal
            Settings.LoopJump = true
        end
        Toggle.Text = "ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    end)

    BtnNormal.MouseButton1Click:Connect(function()
        TextBox.Text = tostring(defaultVal)
        if type == "Speed" then
            Settings.LoopSpeed = false
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = defaultVal
            end
        else
            Settings.LoopJump = false
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = defaultVal
            end
        end
        Toggle.Text = "OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end)
end

CreateControl("Tốc độ chạy", 16, 350, "Speed")
CreateControl("Lực nhảy", 50, 300, "Jump")

-- Loop xử lý logic chính
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if Settings.LoopSpeed then
            hum.WalkSpeed = Settings.SpeedValue
        end
        if Settings.LoopJump then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpValue
        end
    end
end)

print("Blox Fruits All-In-One Loaded!")
