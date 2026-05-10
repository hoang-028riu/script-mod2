-- LocalScript (StarterPlayerScripts hoặc StarterGui)
-- Menu UI: draggable, resizable, minimize, close, tabs, keybind, multi-language, info popup, search bar, mobile block

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ==========================================
-- 1. CHẶN ĐIỆN THOẠI (MOBILE BLOCKER)
-- ==========================================
if UIS.TouchEnabled and not UIS.KeyboardEnabled then
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MobileBlockerGui"
	screenGui.IgnoreGuiInset = true
	
	pcall(function() screenGui.Parent = CoreGui end)
	if not screenGui.Parent then screenGui.Parent = PG end

	local bg = Instance.new("Frame")
	bg.Parent = screenGui
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	bg.BackgroundTransparency = 0.2

	local alertBox = Instance.new("Frame")
	alertBox.Parent = bg
	alertBox.Size = UDim2.fromOffset(300, 150)
	alertBox.Position = UDim2.new(0.5, -150, 0.5, -75)
	alertBox.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
	alertBox.BorderSizePixel = 2
	alertBox.BorderColor3 = Color3.fromRGB(255, 0, 0)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = alertBox

	local txtVi = Instance.new("TextLabel")
	txtVi.Parent = alertBox
	txtVi.Size = UDim2.new(1, 0, 0.5, 0)
	txtVi.BackgroundTransparency = 1
	txtVi.Font = Enum.Font.GothamBold
	txtVi.TextSize = 18
	txtVi.TextColor3 = Color3.fromRGB(255, 50, 50)
	txtVi.Text = "CẢNH BÁO: Không áp dụng cho Điện Thoại!"

	local txtEn = Instance.new("TextLabel")
	txtEn.Parent = alertBox
	txtEn.Size = UDim2.new(1, 0, 0.5, 0)
	txtEn.Position = UDim2.fromScale(0, 0.5)
	txtEn.BackgroundTransparency = 1
	txtEn.Font = Enum.Font.GothamBold
	txtEn.TextSize = 18
	txtEn.TextColor3 = Color3.fromRGB(255, 150, 50)
	txtEn.Text = "WARNING: Not supported on Mobile devices!"

	task.spawn(function()
		while task.wait(0.5) do
			TS:Create(alertBox, TweenInfo.new(0.2), {Size = UDim2.fromOffset(320, 170), Position = UDim2.new(0.5, -160, 0.5, -85)}):Play()
			task.wait(0.2)
			TS:Create(alertBox, TweenInfo.new(0.2), {Size = UDim2.fromOffset(300, 150), Position = UDim2.new(0.5, -150, 0.5, -75)}):Play()
			txtVi.TextColor3 = (txtVi.TextColor3 == Color3.fromRGB(255, 50, 50)) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 50, 50)
		end
	end)
	return
end

-- ==========================================
-- 2. HỆ THỐNG ĐA NGÔN NGỮ (LANGUAGES)
-- ==========================================
local currentLang = "VI"
local Lang = {
	VI = {
		Title = "Menu Tổng Hợp", Scripts = "Tính Năng", Menu = "Cài Đặt",
		Run = "Chạy", Del = "Xóa UI", Running = "Đang chạy..", Done = "Hoàn tất", Err = "Lỗi",
		Removed = "Đã xóa!", NoGUI = "Không có UI",
		Search = "Tìm kiếm tên, thông tin, cách dùng...",
		KeyTitle = "Phím tắt Tắt/Mở (hỗ trợ Alt / Alt+Key)",
		KeyHint = "Hiện tại: ", KeyErr = "Sai phím: ",
		LangBtn = "Ngôn Ngữ: Tiếng Việt",
		PopupInfo = "Thông Tin", PopupUsage = "Cách Dùng", Close = "Đóng"
	},
	EN = {
		Title = "Unified Menu Hub", Scripts = "Scripts", Menu = "Settings",
		Run = "Run", Del = "Del UI", Running = "Running..", Done = "Done", Err = "Error",
		Removed = "Removed!", NoGUI = "No GUI",
		Search = "Search name, info, usage...",
		KeyTitle = "Toggle keybind (Alt / Alt+Key supported)",
		KeyHint = "Current: ", KeyErr = "Invalid key: ",
		LangBtn = "Language: English",
		PopupInfo = "Information", PopupUsage = "Usage", Close = "Close"
	}
}

local translatableUI = {}
local function registerTrans(uiElement, key)
	table.insert(translatableUI, {element = uiElement, key = key})
	uiElement.Text = Lang[currentLang][key]
end

local function updateLanguage()
	for _, item in ipairs(translatableUI) do
		if item.element and item.element.Parent then
			if item.element:IsA("TextBox") then
				item.element.PlaceholderText = Lang[currentLang][item.key]
			elseif item.key == "KeyHint" then
				item.element.Text = Lang[currentLang].KeyHint .. (item.extraData or "")
			else
				item.element.Text = Lang[currentLang][item.key]
			end
		end
	end
end

-- ==========================================
-- 3. GIAO DIỆN CHÍNH (GUI ROOT)
-- ==========================================
local DEFAULT_SIZE = UDim2.fromOffset(400, 300)
local MIN_SIZE = Vector2.new(320, 220)
local MAX_SIZE = Vector2.new(800, 600)

local bind = { altOnly = false, requireAlt = false, key = Enum.KeyCode.RightShift, display = "RightShift" }

local gui = Instance.new("ScreenGui")
gui.Name = "UnifiedMenu"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = PG end

local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = gui
main.Size = DEFAULT_SIZE
main.Position = UDim2.new(0.5, -DEFAULT_SIZE.X.Offset/2, 0.5, -DEFAULT_SIZE.Y.Offset/2)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = main
local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(60, 60, 70) stroke.Thickness = 1 stroke.Parent = main

local top = Instance.new("Frame")
top.Parent = main
top.Size = UDim2.new(1, 0, 0, 38)
top.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
local topCorner = Instance.new("UICorner") topCorner.CornerRadius = UDim.new(0, 10) topCorner.Parent = top

local title = Instance.new("TextLabel")
title.Parent = top
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(12, 0)
title.Size = UDim2.new(1, -120, 1, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(240, 240, 245)
registerTrans(title, "Title")

local function makeTopButton(txt, x, color)
	local b = Instance.new("TextButton")
	b.Parent = top
	b.Size = UDim2.fromOffset(30, 26)
	b.Position = UDim2.new(1, x, 0.5, -13)
	b.BackgroundColor3 = color or Color3.fromRGB(45, 45, 52)
	b.BorderSizePixel = 0
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextColor3 = Color3.fromRGB(235, 235, 240)
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 7) c.Parent = b
	return b
end

local btnMin = makeTopButton("—", -70)
local btnClose = makeTopButton("X", -35, Color3.fromRGB(140, 50, 55))

local body = Instance.new("Frame")
body.Parent = main
body.Position = UDim2.fromOffset(0, 38)
body.Size = UDim2.new(1, 0, 1, -38)
body.BackgroundTransparency = 1

local tabs = Instance.new("Frame")
tabs.Parent = body
tabs.Size = UDim2.new(1, 0, 0, 36)
tabs.BackgroundTransparency = 1
local tabList = Instance.new("UIListLayout")
tabList.Parent = tabs
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.Padding = UDim.new(0, 8)

local content = Instance.new("Frame")
content.Parent = body
content.Position = UDim2.fromOffset(0, 36)
content.Size = UDim2.new(1, 0, 1, -36)
content.BackgroundTransparency = 1

local function makeTabButton(transKey)
	local b = Instance.new("TextButton")
	b.Parent = tabs
	b.Size = UDim2.fromOffset(100, 32)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 13
	b.TextColor3 = Color3.fromRGB(220, 220, 228)
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = b
	registerTrans(b, transKey)
	return b
end

local function makePage()
	local p = Instance.new("Frame")
	p.Parent = content
	p.Size = UDim2.new(1, 0, 1, 0)
	p.BackgroundTransparency = 1
	p.Visible = false
	return p
end

local function makeScroller(parent, yOffset)
	local s = Instance.new("ScrollingFrame")
	s.Parent = parent
	s.Size = UDim2.new(1, -16, 1, -(yOffset + 8))
	s.Position = UDim2.fromOffset(8, yOffset)
	s.BackgroundTransparency = 1
	s.ScrollBarThickness = 4
	s.AutomaticCanvasSize = Enum.AutomaticSize.Y
	s.CanvasSize = UDim2.new()
	local l = Instance.new("UIListLayout")
	l.Parent = s
	l.Padding = UDim.new(0, 8)
	return s
end

local tabScriptsBtn = makeTabButton("Scripts")
local tabMenuBtn = makeTabButton("Menu")

local pageScripts = makePage()
local pageMenu = makePage()

local searchBox = Instance.new("TextBox")
searchBox.Parent = pageScripts
searchBox.Size = UDim2.new(1, -16, 0, 30)
searchBox.Position = UDim2.fromOffset(8, 8)
searchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Text = ""
local searchCorner = Instance.new("UICorner") searchCorner.CornerRadius = UDim.new(0, 6) searchCorner.Parent = searchBox
local searchStroke = Instance.new("UIStroke") searchStroke.Color = Color3.fromRGB(60,60,70) searchStroke.Parent = searchBox
registerTrans(searchBox, "Search")

local scriptsScroll = makeScroller(pageScripts, 46)
local menuScroll = makeScroller(pageMenu, 8)

local currentPage = nil
local function showPage(p, activeBtn)
	if currentPage then currentPage.Visible = false end
	currentPage = p
	currentPage.Visible = true
	for _, b in ipairs(tabs:GetChildren()) do
		if b:IsA("TextButton") then
			b.BackgroundColor3 = (b == activeBtn) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 46)
		end
	end
end

tabScriptsBtn.MouseButton1Click:Connect(function() showPage(pageScripts, tabScriptsBtn) end)
tabMenuBtn.MouseButton1Click:Connect(function() showPage(pageMenu, tabMenuBtn) end)
showPage(pageScripts, tabScriptsBtn)

-- ==========================================
-- 4. BẢNG THÔNG TIN (INFO POPUP)
-- ==========================================
local popupFrame = Instance.new("Frame")
popupFrame.Parent = main
popupFrame.Size = UDim2.new(1, -20, 1, -50)
popupFrame.Position = UDim2.fromOffset(10, 40)
popupFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
popupFrame.Visible = false
popupFrame.ZIndex = 10
local popCorner = Instance.new("UICorner") popCorner.CornerRadius = UDim.new(0, 10) popCorner.Parent = popupFrame
local popStroke = Instance.new("UIStroke") popStroke.Color = Color3.fromRGB(0, 135, 255) popStroke.Thickness = 2 popStroke.Parent = popupFrame

local popTitle = Instance.new("TextLabel")
popTitle.Parent = popupFrame
popTitle.Size = UDim2.new(1, 0, 0, 30)
popTitle.Position = UDim2.fromOffset(0, 5)
popTitle.BackgroundTransparency = 1
popTitle.Font = Enum.Font.GothamBold
popTitle.TextSize = 16
popTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popTitle.ZIndex = 11

local popScroll = Instance.new("ScrollingFrame")
popScroll.Parent = popupFrame
popScroll.Size = UDim2.new(1, -20, 1, -80)
popScroll.Position = UDim2.fromOffset(10, 40)
popScroll.BackgroundTransparency = 1
popScroll.ScrollBarThickness = 4
popScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
popScroll.CanvasSize = UDim2.new()
popScroll.ZIndex = 11

local popLayout = Instance.new("UIListLayout")
popLayout.Parent = popScroll
popLayout.Padding = UDim.new(0, 10)

local popInfoTitle = Instance.new("TextLabel")
popInfoTitle.Parent = popScroll
popInfoTitle.Size = UDim2.new(1, 0, 0, 20)
popInfoTitle.BackgroundTransparency = 1
popInfoTitle.Font = Enum.Font.GothamBold
popInfoTitle.TextSize = 14
popInfoTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
popInfoTitle.TextXAlignment = Enum.TextXAlignment.Left
popInfoTitle.ZIndex = 11
registerTrans(popInfoTitle, "PopupInfo")

local popInfoText = Instance.new("TextLabel")
popInfoText.Parent = popScroll
popInfoText.Size = UDim2.new(1, 0, 0, 0)
popInfoText.AutomaticSize = Enum.AutomaticSize.Y
popInfoText.BackgroundTransparency = 1
popInfoText.Font = Enum.Font.Gotham
popInfoText.TextSize = 13
popInfoText.TextColor3 = Color3.fromRGB(220, 220, 220)
popInfoText.TextXAlignment = Enum.TextXAlignment.Left
popInfoText.TextWrapped = true
popInfoText.ZIndex = 11

local popUsageTitle = Instance.new("TextLabel")
popUsageTitle.Parent = popScroll
popUsageTitle.Size = UDim2.new(1, 0, 0, 20)
popUsageTitle.BackgroundTransparency = 1
popUsageTitle.Font = Enum.Font.GothamBold
popUsageTitle.TextSize = 14
popUsageTitle.TextColor3 = Color3.fromRGB(0, 255, 100)
popUsageTitle.TextXAlignment = Enum.TextXAlignment.Left
popUsageTitle.ZIndex = 11
registerTrans(popUsageTitle, "PopupUsage")

local popUsageText = Instance.new("TextLabel")
popUsageText.Parent = popScroll
popUsageText.Size = UDim2.new(1, 0, 0, 0)
popUsageText.AutomaticSize = Enum.AutomaticSize.Y
popUsageText.BackgroundTransparency = 1
popUsageText.Font = Enum.Font.Gotham
popUsageText.TextSize = 13
popUsageText.TextColor3 = Color3.fromRGB(220, 220, 220)
popUsageText.TextXAlignment = Enum.TextXAlignment.Left
popUsageText.TextWrapped = true
popUsageText.ZIndex = 11

local popCloseBtn = Instance.new("TextButton")
popCloseBtn.Parent = popupFrame
popCloseBtn.Size = UDim2.new(0, 100, 0, 30)
popCloseBtn.Position = UDim2.new(0.5, -50, 1, -35)
popCloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
popCloseBtn.Font = Enum.Font.GothamBold
popCloseBtn.TextSize = 13
popCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
popCloseBtn.ZIndex = 11
local popCloseCorner = Instance.new("UICorner") popCloseCorner.CornerRadius = UDim.new(0, 6) popCloseCorner.Parent = popCloseBtn
registerTrans(popCloseBtn, "Close")

popCloseBtn.MouseButton1Click:Connect(function()
	popupFrame.Visible = false
	body.Visible = true
end)

local function openPopup(scriptData)
	popTitle.Text = scriptData.Name
	popInfoText.Text = scriptData["Desc_" .. currentLang] or "N/A"
	popUsageText.Text = scriptData["Usage_" .. currentLang] or "N/A"
	body.Visible = false
	popupFrame.Visible = true
end

-- ==========================================
-- 5. TẠO CARD SCRIPT
-- ==========================================
local function makeCard(parent, height)
	local f = Instance.new("Frame")
	f.Parent = parent
	f.Size = UDim2.new(1, 0, 0, height or 56)
	f.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 10) c.Parent = f
	local s = Instance.new("UIStroke") s.Color = Color3.fromRGB(55, 55, 65) s.Parent = f
	return f
end

local function makeActionRow(parent, scriptData)
	local card = makeCard(parent, 56)

	local lab = Instance.new("TextLabel")
	lab.Parent = card
	lab.BackgroundTransparency = 1
	lab.Position = UDim2.fromOffset(12, 0)
	lab.Size = UDim2.new(1, -180, 1, 0)
	lab.Font = Enum.Font.GothamSemibold
	lab.TextSize = 13
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.TextColor3 = Color3.fromRGB(235, 235, 240)
	lab.Text = scriptData.Name

	local infoBtn = Instance.new("TextButton")
	infoBtn.Parent = card
	infoBtn.Size = UDim2.fromOffset(30, 32)
	infoBtn.Position = UDim2.new(1, -165, 0.5, -16)
	infoBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	infoBtn.Text = "v"
	infoBtn.Font = Enum.Font.GothamBold
	infoBtn.TextSize = 14
	infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	local c0 = Instance.new("UICorner") c0.CornerRadius = UDim.new(0, 8) c0.Parent = infoBtn
	infoBtn.MouseButton1Click:Connect(function() openPopup(scriptData) end)

	local runBtn = Instance.new("TextButton")
	runBtn.Parent = card
	runBtn.Size = UDim2.fromOffset(55, 32)
	runBtn.Position = UDim2.new(1, -130, 0.5, -16)
	runBtn.BackgroundColor3 = Color3.fromRGB(0, 135, 255)
	runBtn.Font = Enum.Font.GothamBold
	runBtn.TextSize = 12
	runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0, 8) c1.Parent = runBtn
	registerTrans(runBtn, "Run")

	local delBtn = Instance.new("TextButton")
	delBtn.Parent = card
	delBtn.Size = UDim2.fromOffset(55, 32)
	delBtn.Position = UDim2.new(1, -70, 0.5, -16)
	delBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	delBtn.Font = Enum.Font.GothamBold
	delBtn.TextSize = 12
	delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 8) c2.Parent = delBtn
	registerTrans(delBtn, "Del")

	return { card = card, runBtn = runBtn, delBtn = delBtn }
end

-- ==========================================
-- 6. MENU CÀI ĐẶT (TAB MENU)
-- ==========================================
local cardLang = makeCard(menuScroll, 56)
local langBtn = Instance.new("TextButton")
langBtn.Parent = cardLang
langBtn.Size = UDim2.new(1, -24, 0, 36)
langBtn.Position = UDim2.fromOffset(12, 10)
langBtn.BackgroundColor3 = Color3.fromRGB(0, 135, 255)
langBtn.Font = Enum.Font.GothamBold
langBtn.TextSize = 13
langBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(0, 8) lc.Parent = langBtn
registerTrans(langBtn, "LangBtn")

langBtn.MouseButton1Click:Connect(function()
	currentLang = (currentLang == "VI") and "EN" or "VI"
	updateLanguage()
end)

local cardKey = makeCard(menuScroll, 92)
local keyTitle = Instance.new("TextLabel")
keyTitle.Parent = cardKey
keyTitle.BackgroundTransparency = 1
keyTitle.Position = UDim2.fromOffset(12, 10)
keyTitle.Size = UDim2.new(1, -24, 18)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 13
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
registerTrans(keyTitle, "KeyTitle")

local keyBox = Instance.new("TextBox")
keyBox.Parent = cardKey
keyBox.Position = UDim2.fromOffset(12, 36)
keyBox.Size = UDim2.new(1, -24, 0, 34)
keyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
keyBox.Font = Enum.Font.GothamSemibold
keyBox.TextSize = 13
keyBox.TextColor3 = Color3.fromRGB(240, 240, 245)
keyBox.Text = bind.display
local kc = Instance.new("UICorner") kc.CornerRadius = UDim.new(0, 8) kc.Parent = keyBox

local keyHint = Instance.new("TextLabel")
keyHint.Parent = cardKey
keyHint.BackgroundTransparency = 1
keyHint.Position = UDim2.fromOffset(12, 72)
keyHint.Size = UDim2.new(1, -24, 16)
keyHint.Font = Enum.Font.Gotham
keyHint.TextSize = 12
keyHint.TextXAlignment = Enum.TextXAlignment.Left
keyHint.TextColor3 = Color3.fromRGB(170, 170, 180)
registerTrans(keyHint, "KeyHint")
for _, item in ipairs(translatableUI) do
	if item.element == keyHint then item.extraData = bind.display end
end

local function normalizeKeyName(s) return (s or ""):gsub("%s+", ""):lower() end
local function parseKeybind(text)
	local raw = (text or "")
	local s = normalizeKeyName(raw)
	if s == "" then return nil, "Empty" end

	local parts = {}
	for token in s:gmatch("[^%+]+") do table.insert(parts, token) end

	local hasAlt, other = false, nil
	for _, p in ipairs(parts) do
		if p == "alt" or p == "lalt" or p == "leftalt" or p == "ralt" or p == "rightalt" then hasAlt = true else other = p end
	end

	if hasAlt and not other then return { altOnly = true, requireAlt = false, key = nil, display = "Alt" } end

	local function toKeyCode(token)
		local alias = { rshift = "RightShift", lshift = "LeftShift", rctrl = "RightControl", lctrl = "LeftControl", esc = "Escape", del = "Delete", space = "Space", enter = "Return", tab = "Tab"}
		token = alias[token] or token
		if #token == 1 then
			local c = token:upper()
			if c:match("%a") then return Enum.KeyCode[c] end
			if c:match("%d") then return Enum.KeyCode["One"] end
		end
		for _, kc in ipairs(Enum.KeyCode:GetEnumItems()) do
			if kc.Name:lower() == token:lower() then return kc end
		end
		return nil
	end

	local keyCode = other and toKeyCode(other) or nil
	if not keyCode then return nil, "Unknown key" end

	local display = hasAlt and ("Alt+" .. keyCode.Name) or keyCode.Name
	return { altOnly = false, requireAlt = hasAlt, key = keyCode, display = display }
end

keyBox.FocusLost:Connect(function()
	local parsed, err = parseKeybind(keyBox.Text)
	if not parsed then
		keyBox.Text = bind.display
		keyHint.Text = Lang[currentLang].KeyErr .. (err or "")
		task.delay(1.2, function() keyHint.Text = Lang[currentLang].KeyHint .. bind.display end)
		return
	end
	bind = parsed
	keyBox.Text = bind.display
	keyHint.Text = Lang[currentLang].KeyHint .. bind.display
	for _, item in ipairs(translatableUI) do
		if item.element == keyHint then item.extraData = bind.display end
	end
end)

local function isAltDown() return UIS:IsKeyDown(Enum.KeyCode.LeftAlt) or UIS:IsKeyDown(Enum.KeyCode.RightAlt) end
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

	if bind.altOnly then
		if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then gui.Enabled = not gui.Enabled end
		return
	end

	if bind.key and input.KeyCode == bind.key then
		if bind.requireAlt and not isAltDown() then return end
		gui.Enabled = not gui.Enabled
	end
end)

-- ==========================================
-- 7. RESIZE / MINIMIZE
-- ==========================================
local resize = Instance.new("TextButton")
resize.Parent = main
resize.Size = UDim2.fromOffset(18, 18)
resize.Position = UDim2.new(1, -22, 1, -22)
resize.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
resize.Text = ""
local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(0, 6) rc.Parent = resize

local resizing, startMouse, startSize = false, nil, nil
local function clamp(n, a, b) return math.max(a, math.min(b, n)) end

resize.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true; startMouse = UIS:GetMouseLocation(); startSize = main.AbsoluteSize
	end
end)
UIS.InputChanged:Connect(function(input)
	if not resizing then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	local m = UIS:GetMouseLocation()
	local delta = m - startMouse
	main.Size = UDim2.fromOffset(clamp(startSize.X + delta.X, MIN_SIZE.X, MAX_SIZE.X), clamp(startSize.Y + delta.Y, MIN_SIZE.Y, MAX_SIZE.Y))
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end)

local minimized = false
local lastSize = main.Size
btnMin.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		lastSize = main.Size
		main.Size = UDim2.fromOffset(main.AbsoluteSize.X, 38)
		body.Visible = false; resize.Visible = false; popupFrame.Visible = false
	else
		main.Size = lastSize
		body.Visible = true; resize.Visible = true
	end
end)
btnClose.MouseButton1Click:Connect(function() gui.Enabled = false end)

-- ==========================================
-- 8. DANH SÁCH TẤT CẢ SCRIPTS VÀ TÌM KIẾM
-- ==========================================
local myScripts = {
	{ Name = "Aim+ESP Menu", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/aim%2Besp%20menu", Desc_VI = "Menu tổng hợp tự động nhắm (Aim) và nhìn xuyên tường (ESP).", Usage_VI = "Bấm Run để mở Menu, sau đó tick chọn chức năng.", Desc_EN = "A menu featuring Auto-Aim and Wallhack (ESP).", Usage_EN = "Click Run to open the GUI, then toggle the features you want." },
	{ Name = "Anti Sit (Band Sit)", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/anti%20sit", Desc_VI = "Ngăn chặn nhân vật tự động ngồi xuống ghế hoặc xe.", Usage_VI = "Bấm Run để kích hoạt. Reset nhân vật để tắt.", Desc_EN = "Prevents your character from sitting on seats or vehicles.", Usage_EN = "Click Run to activate. Reset character to disable." },
	{ Name = "E + Click = Tele", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/press%20e%2Bclick", Desc_VI = "Dịch chuyển đến vị trí click chuột.", Usage_VI = "Bấm Run. Giữ phím E và click chuột trái vào điểm muốn đến.", Desc_EN = "Teleport to mouse click location.", Usage_EN = "Click Run. Hold E and left-click where you want to go." },
	{ Name = "Auto Ghim Moving (Chuột)", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/aim%20head%20chu%E1%BB%99t", Desc_VI = "Tự động ghim tâm chuột vào đầu kẻ địch đang di chuyển.", Usage_VI = "Bấm Run để chạy ngầm tính năng hỗ trợ ngắm.", Desc_EN = "Auto locks mouse cursor to moving enemy heads.", Usage_EN = "Click Run to start the aim assist in the background." },
	{ Name = "Auto Đâm", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/auto%20%C4%91%C3%A2m", Desc_VI = "Tự động tấn công/đâm mục tiêu gần nhất.", Usage_VI = "Bấm Run. Chức năng sẽ tự động tấn công người chơi/quái gần bạn.", Desc_EN = "Automatically attacks/stabs the nearest target.", Usage_EN = "Click Run. Automatically hits nearby players or mobs." },
	{ Name = "Auto Click", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/autoclick", Desc_VI = "Tự động click chuột liên tục với tốc độ cao.", Usage_VI = "Bấm Run mở bảng, chỉnh tốc độ và bật/tắt bằng nút.", Desc_EN = "Automatically clicks the mouse at high speed.", Usage_EN = "Click Run, adjust speed and toggle start/stop." },
	{ Name = "Auto Tele", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/auto%20%C4%91%C3%A2m", Desc_VI = "Tự động dịch chuyển (Auto Teleport).", Usage_VI = "Bấm Run để mở/kích hoạt chức năng tự động dịch chuyển.", Desc_EN = "Auto Teleport script.", Usage_EN = "Click Run to activate auto teleport functionality." },
	{ Name = "Fly + Noclip", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/fly%2Bnoclip", Desc_VI = "Bay lượn và đi xuyên vật thể.", Usage_VI = "Bấm Run, sau đó dùng phím tắt trên màn hình để bật tắt bay.", Desc_EN = "Allows flying and walking through walls.", Usage_EN = "Click Run. Use on-screen toggles to fly." },
	{ Name = "Boost", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/boost", Desc_VI = "Buff tốc độ / sức mạnh di chuyển cho nhân vật.", Usage_VI = "Bấm Run để áp dụng ngay lập tức.", Desc_EN = "Boosts character speed or abilities.", Usage_EN = "Click Run to apply instantly." },
	{ Name = "Menu Coil", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/menu%20coil", Desc_VI = "Cung cấp các loại lò xo (Coil) như Speed, Jump, Gravity.", Usage_VI = "Bấm Run để lấy trang bị lò xo vào hành trang.", Desc_EN = "Provides Coils (Speed, Jump, Gravity, etc).", Usage_EN = "Click Run to spawn coils into your inventory." },
	{ Name = "Free Fire 1", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/ff1", Desc_VI = "Script hỗ trợ phong cách/kĩ năng bắn súng.", Usage_VI = "Bấm Run để kích hoạt các tính năng liên quan đến bắn súng.", Desc_EN = "Shooter game assist script.", Usage_EN = "Click Run to enable gun/combat features." },
	{ Name = "ESP Textbox", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/esp%20textbox", Desc_VI = "Hiển thị thông tin người chơi (ESP) dưới dạng khung Text.", Usage_VI = "Bấm Run để nhìn thấy thông tin xuyên tường.", Desc_EN = "Displays player ESP info in a textbox format.", Usage_EN = "Click Run to see players through walls." },
	{ Name = "Fling", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/fling", Desc_VI = "Xoay vòng siêu nhanh để hất văng người khác khi chạm vào.", Usage_VI = "Bấm Run và chạy lại chạm vào người chơi khác để hất họ.", Desc_EN = "Spins rapidly to fling other players upon touch.", Usage_EN = "Click Run, then walk into players to fling them." },
	{ Name = "Loop Key", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/loop%20key", Desc_VI = "Tự động lặp lại thao tác bấm phím.", Usage_VI = "Bấm Run và cài đặt phím cần spam tự động.", Desc_EN = "Automatically loops key presses.", Usage_EN = "Click Run and set the key you want to spam." },
	{ Name = "Ghim Hitbox", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/ghim%20hitbox", Desc_VI = "Ghim mục tiêu (Hitbox) để đánh trúng 100%.", Usage_VI = "Bấm Run để bật ngầm tính năng hỗ trợ.", Desc_EN = "Locks onto enemy hitboxes for 100% accuracy.", Usage_EN = "Click Run to start in the background." },
	{ Name = "Giữ Nguyên Vị Trí", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/gi%E1%BB%AF%20nguy%C3%AAn%20v%E1%BB%8B%20tr%C3%AD", Desc_VI = "Đóng băng (Freeze) vị trí hiện tại của bạn.", Usage_VI = "Bấm Run để neo nhân vật lại. Nhấn lại hoặc gỡ băng để di chuyển.", Desc_EN = "Freezes your current position in place.", Usage_EN = "Click Run to anchor your character." },
	{ Name = "Hitbox Head", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/hitbox%20head", Desc_VI = "Mở rộng kích thước vùng đầu (Head) của kẻ địch.", Usage_VI = "Bấm Run. Đầu của người chơi khác sẽ to ra để dễ bắn.", Desc_EN = "Expands the head hitbox of enemies.", Usage_EN = "Click Run. Enemies' heads will become huge." },
	{ Name = "ESP VIP", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/espvip", Desc_VI = "Phiên bản nhìn xuyên tường cao cấp, rõ nét.", Usage_VI = "Bấm Run. Sẽ có menu riêng để bạn chỉnh màu sắc/khoảng cách.", Desc_EN = "Premium Wallhack/ESP script.", Usage_EN = "Click Run. Includes a menu to adjust colors and range." },
	{ Name = "Infinity Jump", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/infinty%20jump", Desc_VI = "Nhảy vô hạn, đạp không khí bay lên trời.", Usage_VI = "Bấm Run. Sau đó nhấn phím Space liên tục để bay lên cao.", Desc_EN = "Infinite jumping mid-air.", Usage_EN = "Click Run. Press Spacebar continuously to fly up." },
	{ Name = "Plane", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/plane", Desc_VI = "Khả năng lái hoặc mô phỏng máy bay.", Usage_VI = "Bấm Run và sử dụng các phím điều hướng để lái.", Desc_EN = "Fly or spawn a plane.", Usage_EN = "Click Run and use navigation keys to fly." },
	{ Name = "Rejoin Server", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/control%20sever", Desc_VI = "Thoát và tự động vào lại đúng Server hiện tại.", Usage_VI = "Bấm Run. Game sẽ văng và load lại vào server này ngay lập tức.", Desc_EN = "Leaves and automatically rejoins the same server.", Usage_EN = "Click Run. You will instantly rejoin the game." },
	{ Name = "Noclip", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/noclip", Desc_VI = "Tắt va chạm, đi xuyên qua tường và mọi đồ vật.", Usage_VI = "Bấm Run để kích hoạt. Xuyên qua được mọi bức tường.", Desc_EN = "Walk through solid objects and walls.", Usage_EN = "Click Run to activate." },
	{ Name = "Tele Sau Press Q", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/tele%20sau%20press%20q", Desc_VI = "Dịch chuyển tức thời đến vị trí chuột.", Usage_VI = "Bấm Run. Chỉ chuột tới điểm muốn đến và bấm phím Q.", Desc_EN = "Teleports you to your mouse cursor.", Usage_EN = "Click Run. Point mouse and press Q to teleport." },
	{ Name = "TASUYA", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/TASUYA", Desc_VI = "Lướt siêu nhanh về phía trước (Kĩ năng Tatsuya).", Usage_VI = "Bấm Run để sử dụng kĩ năng lướt nhanh.", Desc_EN = "Super fast dash forward (Tatsuya ability).", Usage_EN = "Click Run to dash instantly." },
	{ Name = "Xóa Đồ", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/x%C3%B3a%20%C4%91%E1%BB%93", Desc_VI = "Xóa đồ vật đang cầm trên tay hoặc đồ rác.", Usage_VI = "Bấm Run. Chú ý cầm đúng đồ muốn xóa trên tay.", Desc_EN = "Deletes the tool currently in your hand.", Usage_EN = "Click Run. Make sure you hold the item you want to delete." },
	{ Name = "Ngồi (Sit)", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/sit", Desc_VI = "Ép nhân vật ngồi bệt xuống đất ở bất kì đâu.", Usage_VI = "Bấm Run để kích hoạt hoạt ảnh ngồi.", Desc_EN = "Forces your character to sit anywhere.", Usage_EN = "Click Run to trigger sit animation." },
	{ Name = "Laser Gun", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/laser%20gun", Desc_VI = "Súng bắn tia Laser hủy diệt.", Usage_VI = "Bấm Run để nhận súng vào túi đồ.", Desc_EN = "Provides a destructive Laser Gun.", Usage_EN = "Click Run to equip the laser gun." },
	{ Name = "Speed + Jump", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/speed%2Bjump", Desc_VI = "Buff tốc độ chạy và sức nhảy cực cao.", Usage_VI = "Bấm Run. Có bảng chỉnh thông số tùy thích.", Desc_EN = "Extremely high walkspeed and jumppower.", Usage_EN = "Click Run to open the stat modifier menu." },
	{ Name = "Tele Vật", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/tele%20v%E1%BA%ADt", Desc_VI = "Hút/Dịch chuyển vật phẩm (Tools) rớt dưới đất về phía bạn.", Usage_VI = "Bấm Run, mọi vật phẩm sẽ tự chui vào người bạn.", Desc_EN = "Teleports dropped items/tools to you.", Usage_EN = "Click Run, all unanchored items fly to you." },
	{ Name = "Save + Tele", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/save%2Btele%2Blight", Desc_VI = "Lưu lại vị trí hiện tại và dịch chuyển lại khi cần.", Usage_VI = "Bấm Run, dùng bảng điều khiển để Save và Load vị trí.", Desc_EN = "Save your location and teleport back later.", Usage_EN = "Click Run. Use the GUI to Save and Teleport back." },
	{ Name = "X2 Item, Press B", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/x2%20item%2C%20press%20B", Desc_VI = "Nhân đôi vật phẩm đang cầm khi bấm B.", Usage_VI = "Bấm Run. Cầm vật phẩm lên tay và bấm phím B để nhân bản.", Desc_EN = "Duplicates the item in your hand when pressing B.", Usage_EN = "Click Run. Hold an item and press B to dupe." },
	{ Name = "Thông Báo Player", Url = "https://raw.githubusercontent.com/hoang-028riu/script-mod2/refs/heads/main/th%C3%B4ng%20b%C3%A1o%20player", Desc_VI = "Thông báo khi có người mới vào phòng hoặc ra đi.", Usage_VI = "Bấm Run để bật hệ thống chat log.", Desc_EN = "Notifies when players join or leave.", Usage_EN = "Click Run to enable chat logs." },
	{ Name = "Infinite Yield", Url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", Desc_VI = "Admin Command mạnh nhất với hàng trăm lệnh (Fly, Noclip, Fling...).", Usage_VI = "Bấm Run. Gõ lệnh vào thanh dưới cùng màn hình (VD: ;fly).", Desc_EN = "The most popular Admin Commands script.", Usage_EN = "Click Run. Type commands in the bottom bar (e.g., ;fly)." },
	{ Name = "Bloxfruit Script", Url = "https://raw.githubusercontent.com/FOGOTY/foggy-bloxfruit/refs/heads/main/script", Desc_VI = "Menu Auto Farm, Auto Quest... xịn xò cho game Blox Fruits.", Usage_VI = "Bấm Run, Menu sẽ hiện ra giữa màn hình.", Desc_EN = "Auto Farm Hub for Blox Fruits.", Usage_EN = "Click Run, the Hub GUI will appear." },
	{ Name = "God Mode", Url = "https://raw.githubusercontent.com/mascaracathub/Test-Script/refs/heads/main/godmodev1.lua.txt", Desc_VI = "Bất tử, không thể bị nhận sát thương.", Usage_VI = "Bấm Run. Máu sẽ không bị tụt khi bị đánh.", Desc_EN = "Invincibility. Take no damage.", Usage_EN = "Click Run. Your health will not drop." },
	{ Name = "Slap Tower", Url = "https://raw.githubusercontent.com/Valak542/SlapTower/refs/heads/main/SlapTowerV1.lua", Desc_VI = "Bản Script hỗ trợ tự động đánh/farm trong Slap Tower.", Usage_VI = "Bấm Run để mở Menu Slap Tower.", Desc_EN = "Auto farm script for Slap Tower.", Usage_EN = "Click Run to open the Slap Tower GUI." },
	{ Name = "Fake Lag", Url = "https://raw.githubusercontent.com/venux83h/Universal/refs/heads/main/Universal%20Lag%20Switch", Desc_VI = "Tạo hiệu ứng giật lag ảo để kẻ địch không bắn trúng.", Usage_VI = "Bấm Run và bật nút Lag Switch.", Desc_EN = "Creates a fake lag effect to dodge attacks.", Usage_EN = "Click Run and toggle Lag Switch." },
}

-- Điền dữ liệu mặc định cho những cái nhỡ thiếu
for _, scriptData in ipairs(myScripts) do
	if not scriptData.Desc_VI then scriptData.Desc_VI = "Chưa có thông tin cụ thể." end
	if not scriptData.Desc_EN then scriptData.Desc_EN = "No info provided." end
	if not scriptData.Usage_VI then scriptData.Usage_VI = "Bấm Run để khởi chạy." end
	if not scriptData.Usage_EN then scriptData.Usage_EN = "Click Run to execute." end
end

local function trackScriptGuis(action)
	local newGuis, connections = {}, {}
	local function onChildAdded(child)
		if child:IsA("ScreenGui") and child.Name ~= gui.Name then table.insert(newGuis, child) end
	end
	pcall(function() table.insert(connections, CoreGui.ChildAdded:Connect(onChildAdded)) end)
	pcall(function() table.insert(connections, PG.ChildAdded:Connect(onChildAdded)) end)
	pcall(function() if gethui then table.insert(connections, gethui().ChildAdded:Connect(onChildAdded)) end end)
	
	local ok, err = pcall(action)
	task.wait(1.5)
	for _, conn in ipairs(connections) do conn:Disconnect() end
	return ok, err, newGuis
end

local generatedRows = {}

for _, scriptData in ipairs(myScripts) do
	local elements = makeActionRow(scriptsScroll, scriptData)
	local runBtn, delBtn = elements.runBtn, elements.delBtn
	local trackedGuis = {}

	table.insert(generatedRows, { card = elements.card, data = scriptData })

	runBtn.MouseButton1Click:Connect(function()
		if runBtn.Text == Lang[currentLang].Running then return end
		runBtn.Text = Lang[currentLang].Running
		
		task.spawn(function()
			local ok, err, newGuis = trackScriptGuis(function() loadstring(game:HttpGet(scriptData.Url))() end)
			if ok then
				for _, g in ipairs(newGuis) do table.insert(trackedGuis, g) end
				runBtn.Text = Lang[currentLang].Done
				task.wait(1.5); if runBtn then runBtn.Text = Lang[currentLang].Run end
			else
				warn("[Menu Hub Error - " .. scriptData.Name .. "]", err)
				runBtn.Text = Lang[currentLang].Err
				task.wait(2); if runBtn then runBtn.Text = Lang[currentLang].Run end
			end
		end)
	end)

	delBtn.MouseButton1Click:Connect(function()
		local count = 0
		for i = #trackedGuis, 1, -1 do
			local targetGui = trackedGuis[i]
			if targetGui and targetGui.Parent then pcall(function() targetGui:Destroy() end); count = count + 1 end
			table.remove(trackedGuis, i)
		end
		delBtn.Text = count > 0 and Lang[currentLang].Removed or Lang[currentLang].NoGUI
		task.delay(1.5, function() if delBtn then delBtn.Text = Lang[currentLang].Del end end)
	end)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local query = searchBox.Text:lower()
	for _, row in ipairs(generatedRows) do
		local textToSearch = (row.data.Name .. " " .. 
			row.data.Desc_VI .. " " .. row.data.Usage_VI .. " " .. 
			row.data.Desc_EN .. " " .. row.data.Usage_EN):lower()
		
		row.card.Visible = (query == "" or textToSearch:find(query) ~= nil)
	end
end)
