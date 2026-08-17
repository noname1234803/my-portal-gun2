-- ... (весь код до GUI)

-- Главное меню
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 750, 0, 155)
frame.Position = UDim2.new(0.5, -375, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- HUD (статус)
local hud = Instance.new("TextLabel")
hud.Size = UDim2.new(0, 400, 0, 30)
hud.Position = UDim2.new(0.5, -200, 0, 185)
hud.BackgroundTransparency = 1
hud.TextColor3 = portalColorLight
hud.Text = "POINT: FIRE → A → B"
hud.TextScaled = true
hud.Font = Enum.Font.Gotham
hud.Parent = gui

-- Кнопка переключения меню
local menuToggle = Instance.new("TextButton")
menuToggle.Name = "MenuToggle"
menuToggle.Size = UDim2.new(0, 50, 0, 50)
menuToggle.Position = UDim2.new(0, 15, 1, -65)
menuToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuToggle.BackgroundTransparency = 0.1
menuToggle.BorderSizePixel = 0
menuToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuToggle.Text = "✕"
menuToggle.TextScaled = true
menuToggle.Font = Enum.Font.GothamBold
menuToggle.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = menuToggle

local menuOpen = true
menuToggle.Activated:Connect(function()
    menuOpen = not menuOpen
    frame.Visible = menuOpen
    hud.Visible = menuOpen
    menuToggle.Text = menuOpen and "✕" or "☰"
end)

-- Кнопки режимов (POINT, PLAYER, PLACE) – без изменений
local function makeButton(text, x, y, width, height, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width or 80, 0, height or 40)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    return btn
end

local pointButton = makeButton("POINT", 10, 10, 80, 38, Color3.fromRGB(180, 125, 10))
local playerButton = makeButton("PLAYER", 100, 10, 80, 38, Color3.fromRGB(180, 125, 10))
local placeButton = makeButton("PLACE", 190, 10, 80, 38, Color3.fromRGB(180, 125, 10))

-- Поле ввода
local input = Instance.new("TextBox")
input.Size = UDim2.new(0, 160, 0, 38)
input.Position = UDim2.new(0, 280, 0, 10)
input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
input.BackgroundTransparency = 0.35
input.BorderSizePixel = 1
input.BorderColor3 = portalColor
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
input.PlaceholderText = "Player name / Place ID"
input.Text = ""
input.TextScaled = true
input.Font = Enum.Font.Gotham
input.Parent = frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = input

-- Кнопка FIRE
local fireButton = Instance.new("TextButton")
fireButton.Size = UDim2.new(0, 100, 0, 46)
fireButton.Position = UDim2.new(0, 450, 0, 6)
fireButton.BackgroundColor3 = portalColorDark
fireButton.BorderSizePixel = 0
fireButton.TextColor3 = Color3.fromRGB(255, 255, 255)
fireButton.Text = "FIRE"
fireButton.TextScaled = true
fireButton.Font = Enum.Font.GothamBold
fireButton.Parent = frame

local fireCorner = Instance.new("UICorner")
fireCorner.CornerRadius = UDim.new(0, 10)
fireCorner.Parent = fireButton

-- Кнопка RESET
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0, 100, 0, 38)
resetButton.Position = UDim2.new(0, 560, 0, 10)
resetButton.BackgroundColor3 = Color3.fromRGB(100, 55, 10)
resetButton.BorderSizePixel = 0
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.Text = "RESET"
resetButton.TextScaled = true
resetButton.Font = Enum.Font.GothamBold
resetButton.Parent = frame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetButton

-- ====== НОВЫЕ КНОПКИ УДАЛЕНИЯ ======
local deleteABtn = Instance.new("TextButton")
deleteABtn.Size = UDim2.new(0, 80, 0, 38)
deleteABtn.Position = UDim2.new(0, 670, 0, 10)
deleteABtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
deleteABtn.BorderSizePixel = 0
deleteABtn.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteABtn.Text = "DELETE A"
deleteABtn.TextScaled = true
deleteABtn.Font = Enum.Font.GothamBold
deleteABtn.Parent = frame
local delACorner = Instance.new("UICorner")
delACorner.CornerRadius = UDim.new(0, 6)
delACorner.Parent = deleteABtn

local deleteBBtn = Instance.new("TextButton")
deleteBBtn.Size = UDim2.new(0, 80, 0, 38)
deleteBBtn.Position = UDim2.new(0, 670, 0, 55)
deleteBBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
deleteBBtn.BorderSizePixel = 0
deleteBBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteBBtn.Text = "DELETE B"
deleteBBtn.TextScaled = true
deleteBBtn.Font = Enum.Font.GothamBold
deleteBBtn.Parent = frame
local delBCorner = Instance.new("UICorner")
delBCorner.CornerRadius = UDim.new(0, 6)
delBCorner.Parent = deleteBBtn

-- ... (остальной код: ползунок, кнопки цветов, функции и т.д.)
