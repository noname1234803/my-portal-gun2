--==================================================
-- EVIL MORTY PORTAL GUN (GREEN EDITION)
-- С МОДЕЛЬЮ ПУШКИ ОТ РИКА ПРАЙМА
-- FULL LOCAL SCRIPT
--
-- ЗЕЛЁНЫЙ ПОРТАЛ
-- ТЕКСТУРА + АНИМАЦИЯ РАСШИРЕНИЯ (зелёный)
-- ЭФФЕКТ ЛУЧА (зелёный)
-- ПОЯВЛЯЕТСЯ НА ЛЮБОЙ ПОВЕРХНОСТИ
-- МЕДЛЕННОЕ ВРАЩЕНИЕ
-- ЛОКАЛЬНЫЙ СКРИПТ
-- БЕЗ ReplicatedStorage
-- БЕЗ СЕРВЕРНОГО СКРИПТА
--
-- РЕЖИМЫ: POINT / PLAYER / PLACE
-- ПК + МОБИЛЬНЫЕ
-- БЕЗОПАСНОСТЬ ПРИ РЕСПАВНЕ (порталы не удаляются)
-- ПОСТОЯННЫЙ ИНВЕНТАРЬ
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")

--==================================================
-- BLOOM ЭФФЕКТ (мягкое зелёное свечение)
--==================================================

local bloom = Lighting:FindFirstChild("PortalBloom")
if not bloom then
    bloom = Instance.new("BloomEffect")
    bloom.Name = "PortalBloom"
    bloom.Intensity = 0.18
    bloom.Threshold = 0.65
    bloom.Size = 6
    bloom.Parent = Lighting
end

--==================================================
-- НАСТРОЙКИ (ЗЕЛЁНАЯ ПАЛИТРА)
--==================================================

local PORTAL_TEXTURE = "rbxassetid://77878374203347"

-- Основные цвета (не приторный зелёный)
local PORTAL_GREEN = Color3.fromRGB(0, 255, 65)      -- #00FF41
local PORTAL_GREEN_LIGHT = Color3.fromRGB(80, 255, 130) -- #50FF82
local PORTAL_GREEN_DARK = Color3.fromRGB(0, 180, 40)    -- #00B428

local PORTAL_GUN_SOUND = "rbxassetid://1013378689"
local PORTAL_SPAWN_SOUND = "rbxassetid://756847338"

--==================================================
-- PLAYER PORTAL HEIGHT
--==================================================

local PLAYER_PORTAL_HEIGHT = 1.0

--==================================================
-- PORTAL VARIABLES
--==================================================

local portalA = nil
local portalB = nil

local pointStage = 0
local pointA = nil
local pointB = nil
local pointSelecting = false

local teleportDebounce = false
local currentMode = "POINT"

--==================================================
-- GUN VARIABLES
--==================================================

local portal_gun = nil
local portal_sound = nil
local Handle = nil

--==================================================
-- ФУНКЦИЯ ПОСТРОЕНИЯ МОДЕЛИ ПУШКИ (из файла Рика)
-- ЦВЕТА ПЕРЕДЕЛАНЫ В ЗЕЛЁНЫЕ
--==================================================

local function buildGunParts(gunTool)
    -- Handle (ручка) — тёмно-серая
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.35, 1.1, 0.4)
    handle.BrickColor = BrickColor.new("Dark stone grey")
    handle.Material = Enum.Material.SmoothPlastic
    handle.CanCollide = false
    handle.CanTouch = false
    handle.CanQuery = false
    handle.Massless = true
    handle.Anchored = false
    handle.TopSurface = Enum.SurfaceType.Smooth
    handle.BottomSurface = Enum.SurfaceType.Smooth
    handle.Parent = gunTool

    -- Корпус — светло-серый
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(1.05, 0.42, 2.1)
    body.BrickColor = BrickColor.new("Light stone grey")
    body.Material = Enum.Material.SmoothPlastic
    body.CanCollide = false
    body.CanTouch = false
    body.CanQuery = false
    body.Massless = true
    body.Anchored = false
    body.TopSurface = Enum.SurfaceType.Smooth
    body.BottomSurface = Enum.SurfaceType.Smooth
    body.CFrame = handle.CFrame * CFrame.new(0, 0.55, -0.6) * CFrame.Angles(math.rad(15), 0, 0)
    body.Parent = gunTool

    local w1 = Instance.new("WeldConstraint")
    w1.Part0 = handle
    w1.Part1 = body
    w1.Parent = handle

    -- Колба (неоновая зелёная)
    local bulb = Instance.new("Part")
    bulb.Name = "Bulb"
    bulb.Shape = Enum.PartType.Cylinder
    bulb.Size = Vector3.new(0.82, 0.68, 0.68)
    bulb.BrickColor = BrickColor.new("Lime green")  -- ярко-зелёный
    bulb.Material = Enum.Material.Neon
    bulb.CanCollide = false
    bulb.CanTouch = false
    bulb.CanQuery = false
    bulb.Massless = true
    bulb.Anchored = false
    bulb.TopSurface = Enum.SurfaceType.Smooth
    bulb.BottomSurface = Enum.SurfaceType.Smooth
    bulb.CFrame = body.CFrame * CFrame.new(0, 0.55, -0.25) * CFrame.Angles(0, 0, math.rad(90))
    bulb.Parent = gunTool

    local w2 = Instance.new("WeldConstraint")
    w2.Part0 = body
    w2.Part1 = bulb
    w2.Parent = body

    -- Стекло колбы (полупрозрачное)
    local glass = Instance.new("Part")
    glass.Name = "BulbGlass"
    glass.Shape = Enum.PartType.Cylinder
    glass.Size = Vector3.new(0.88, 0.72, 0.72)
    glass.BrickColor = BrickColor.new("Light blue")
    glass.Material = Enum.Material.Glass
    glass.Transparency = 0.5
    glass.CanCollide = false
    glass.CanTouch = false
    glass.CanQuery = false
    glass.Massless = true
    glass.Anchored = false
    glass.TopSurface = Enum.SurfaceType.Smooth
    glass.BottomSurface = Enum.SurfaceType.Smooth
    glass.CFrame = bulb.CFrame
    glass.Parent = gunTool

    local w3 = Instance.new("WeldConstraint")
    w3.Part0 = bulb
    w3.Part1 = glass
    w3.Parent = bulb

    -- Дуло
    local muzzle = Instance.new("Part")
    muzzle.Name = "Muzzle"
    muzzle.Size = Vector3.new(1.0, 0.38, 0.1)
    muzzle.BrickColor = BrickColor.new("Dark stone grey")
    muzzle.Material = Enum.Material.SmoothPlastic
    muzzle.CanCollide = false
    muzzle.CanTouch = false
    muzzle.CanQuery = false
    muzzle.Massless = true
    muzzle.Anchored = false
    muzzle.TopSurface = Enum.SurfaceType.Smooth
    muzzle.BottomSurface = Enum.SurfaceType.Smooth
    muzzle.CFrame = body.CFrame * CFrame.new(0, 0, -1.05)
    muzzle.Parent = gunTool

    local w4 = Instance.new("WeldConstraint")
    w4.Part0 = body
    w4.Part1 = muzzle
    w4.Parent = body

    -- Три линзы на дуле (зелёные неоновые)
    for i = -1, 1 do
        local lens = Instance.new("Part")
        lens.Shape = Enum.PartType.Cylinder
        lens.Size = Vector3.new(0.1, 0.26, 0.26)
        lens.BrickColor = BrickColor.new("Lime green")
        lens.Material = Enum.Material.Neon
        lens.CanCollide = false
        lens.CanTouch = false
        lens.CanQuery = false
        lens.Massless = true
        lens.Anchored = false
        lens.TopSurface = Enum.SurfaceType.Smooth
        lens.BottomSurface = Enum.SurfaceType.Smooth
        lens.CFrame = muzzle.CFrame * CFrame.new(i * 0.3, 0, -0.02) * CFrame.Angles(0, math.rad(90), 0)
        lens.Parent = gunTool

        local wl = Instance.new("WeldConstraint")
        wl.Part0 = muzzle
        wl.Part1 = lens
        wl.Parent = muzzle
    end

    -- Экран (оставлю красным для контраста)
    local screen = Instance.new("Part")
    screen.Name = "Screen"
    screen.Size = Vector3.new(0.45, 0.04, 0.22)
    screen.BrickColor = BrickColor.new("Bright red")
    screen.Material = Enum.Material.Neon
    screen.CanCollide = false
    screen.CanTouch = false
    screen.CanQuery = false
    screen.Massless = true
    screen.Anchored = false
    screen.TopSurface = Enum.SurfaceType.Smooth
    screen.BottomSurface = Enum.SurfaceType.Smooth
    screen.CFrame = body.CFrame * CFrame.new(0, 0.22, 0.45)
    screen.Parent = gunTool

    local w5 = Instance.new("WeldConstraint")
    w5.Part0 = body
    w5.Part1 = screen
    w5.Parent = body

    -- Цилиндрический регулятор
    local dial = Instance.new("Part")
    dial.Shape = Enum.PartType.Cylinder
    dial.Size = Vector3.new(0.15, 0.35, 0.35)
    dial.BrickColor = BrickColor.new("Dark stone grey")
    dial.Material = Enum.Material.SmoothPlastic
    dial.CanCollide = false
    dial.CanTouch = false
    dial.CanQuery = false
    dial.Massless = true
    dial.Anchored = false
    dial.TopSurface = Enum.SurfaceType.Smooth
    dial.BottomSurface = Enum.SurfaceType.Smooth
    dial.CFrame = body.CFrame * CFrame.new(0, 0.22, 0.85) * CFrame.Angles(0, 0, math.rad(90))
    dial.Parent = gunTool

    local w6 = Instance.new("WeldConstraint")
    w6.Part0 = body
    w6.Part1 = dial
    w6.Parent = body

    -- Переключатель (красная кнопка)
    local switch = Instance.new("Part")
    switch.Size = Vector3.new(0.08, 0.12, 0.18)
    switch.BrickColor = BrickColor.new("Bright red")
    switch.Material = Enum.Material.SmoothPlastic
    switch.CanCollide = false
    switch.CanTouch = false
    switch.CanQuery = false
    switch.Massless = true
    switch.Anchored = false
    switch.TopSurface = Enum.SurfaceType.Smooth
    switch.BottomSurface = Enum.SurfaceType.Smooth
    switch.CFrame = body.CFrame * CFrame.new(0.53, 0, 0.15)
    switch.Parent = gunTool

    local w7 = Instance.new("WeldConstraint")
    w7.Part0 = body
    w7.Part1 = switch
    w7.Parent = body

    return handle, bulb
end

--==================================================
-- CREATE GUN (переработанная версия)
--==================================================

local function createGun()
    if portal_gun and portal_gun.Parent then
        return portal_gun
    end

    portal_gun = nil
    Handle = nil
    portal_sound = nil

    portal_gun = Instance.new("Tool")
    portal_gun.Name = "EVIL_MORTY_PORTAL_GUN_GREEN"
    portal_gun.RequiresHandle = true
    portal_gun.CanBeDropped = false

    local handlePart, bulbPart = buildGunParts(portal_gun)
    if not handlePart then
        warn("Failed to build gun parts")
        portal_gun:Destroy()
        portal_gun = nil
        return nil
    end

    Handle = handlePart
    portal_gun.Grip = CFrame.new(0, -0.3, 0.2) * CFrame.Angles(math.rad(10), 0, 0)

    portal_sound = Instance.new("Sound")
    portal_sound.Name = "PortalGunSound"
    portal_sound.SoundId = PORTAL_GUN_SOUND
    portal_sound.Volume = 2.5
    portal_sound.Parent = Handle

    -- Анимированная жидкость внутри колбы (зелёная)
    if bulbPart then
        local liquid = Instance.new("Part")
        liquid.Name = "AnimatedEvilMortyLiquid"
        liquid.Shape = Enum.PartType.Cylinder
        liquid.Size = Vector3.new(0.12, 0.22, 0.12)
        liquid.Color = PORTAL_GREEN
        liquid.Material = Enum.Material.Neon
        liquid.Transparency = 0.05
        liquid.CanCollide = false
        liquid.CanTouch = false
        liquid.CanQuery = false
        liquid.Massless = true
        liquid.CastShadow = false
        liquid.CFrame = bulbPart.CFrame
        liquid.Parent = portal_gun

        local liquidWeld = Instance.new("Weld")
        liquidWeld.Name = "LiquidAnimationWeld"
        liquidWeld.Part0 = bulbPart
        liquidWeld.Part1 = liquid
        liquidWeld.Parent = bulbPart

        local liquidLight = Instance.new("PointLight")
        liquidLight.Color = PORTAL_GREEN_LIGHT
        liquidLight.Brightness = 3
        liquidLight.Range = 5
        liquidLight.Parent = liquid

        local liquidRotation = 0
        RunService.RenderStepped:Connect(function(dt)
            if not liquidWeld or not liquidWeld.Parent then return end
            liquidRotation += dt * 8
            liquidWeld.C0 = CFrame.Angles(0, liquidRotation, 0)
        end)
    end

    return portal_gun
end

--==================================================
-- MUZZLE FLASH
--==================================================

local function muzzleFlash()
	if not Handle then return end

	local flash = Instance.new("Part")
	flash.Name = "EvilMortyMuzzleFlash"
	flash.Shape = Enum.PartType.Ball
	flash.Material = Enum.Material.Neon
	flash.Color = PORTAL_GREEN_LIGHT
	flash.Size = Vector3.new(0.35, 0.35, 0.35)
	flash.Transparency = 0
	flash.CanCollide = false
	flash.CanTouch = false
	flash.CanQuery = false
	flash.Anchored = true
	flash.CFrame = Handle.CFrame * CFrame.new(0, 0, -0.9)
	flash.Parent = workspace

	local light = Instance.new("PointLight")
	light.Color = PORTAL_GREEN_LIGHT
	light.Brightness = 7
	light.Range = 10
	light.Parent = flash

	TweenService:Create(flash, TweenInfo.new(0.18), {
		Size = Vector3.new(1.3, 1.3, 1.3),
		Transparency = 1
	}):Play()

	task.delay(0.2, function()
		if flash then flash:Destroy() end
	end)

	return flash.CFrame.Position
end

--==================================================
-- MUZZLE BEAM
--==================================================

local function createBeam(startPos, endPos)
	local distance = (endPos - startPos).Magnitude
	if distance < 0.05 then return end

	local beam = Instance.new("Part")
	beam.Name = "EvilMortyPortalBeam"
	beam.Anchored = true
	beam.CanCollide = false
	beam.CanTouch = false
	beam.CanQuery = false
	beam.CastShadow = false
	beam.Material = Enum.Material.Neon
	beam.Color = PORTAL_GREEN
	beam.Size = Vector3.new(0.18, 0.18, distance)
	beam.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
	beam.Parent = workspace

	local light = Instance.new("PointLight")
	light.Color = PORTAL_GREEN_LIGHT
	light.Brightness = 2
	light.Range = 6
	light.Parent = beam

	local tween = TweenService:Create(beam, TweenInfo.new(0.15), {
		Size = Vector3.new(0, 0, distance),
		Transparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		beam:Destroy()
	end)
end

--==================================================
-- PORTAL SOUND
--==================================================

local function playPortalSpawnSound(portal)
	if not portal then return end

	local sound = Instance.new("Sound")
	sound.Name = "EvilMortyPortalSpawnSound"
	sound.SoundId = PORTAL_SPAWN_SOUND
	sound.Volume = 2
	sound.RollOffMode = Enum.RollOffMode.Inverse
	sound.RollOffMaxDistance = 60
	sound.RollOffMinDistance = 8
	sound.Parent = portal
	sound:Play()

	task.delay(8, function()
		if sound and sound.Parent then
			sound:Destroy()
		end
	end)
end

--==================================================
-- CREATE PORTAL (зелёный, увеличен в 1.5 раза)
--==================================================

local function create_portal(position, lookDirection, surfaceNormal)
	local portal = Instance.new("Part")
	portal.Name = "EvilMortyGreenPortal"
	portal.Size = Vector3.new(0.6, 0.6, 0.6)
	portal.Transparency = 1
	portal.Anchored = true
	portal.CanCollide = false
	portal.CanTouch = true
	portal.CanQuery = false
	portal.CastShadow = false

	local center

	if surfaceNormal then
		center = position + (surfaceNormal * 0.05)
		portal.CFrame = CFrame.lookAt(center, center + surfaceNormal)
	else
		local direction = Vector3.new(lookDirection.X, 0, lookDirection.Z)
		if direction.Magnitude < 0.01 then
			direction = Vector3.new(0, 0, -1)
		else
			direction = direction.Unit
		end
		center = position + Vector3.new(0, 2.8, 0)
		portal.CFrame = CFrame.lookAt(center, center + direction)
	end

	portal.Parent = workspace

	local surface = Instance.new("Part")
	surface.Name = "PortalTextureSurface"
	surface.Transparency = 1
	surface.Anchored = true
	surface.CanCollide = false
	surface.CanTouch = false
	surface.CanQuery = false
	surface.CastShadow = false
	surface.CFrame = portal.CFrame

	local FULL_SIZE = Vector3.new(9.3, 9.3, 0.06)
	surface.Size = Vector3.new(0.15, 0.15, 0.04)
	surface.Parent = portal

	local front = Instance.new("Decal")
	front.Name = "PortalTextureFront"
	front.Face = Enum.NormalId.Front
	front.Texture = PORTAL_TEXTURE
	front.Color3 = PORTAL_GREEN
	front.Transparency = 0
	front.Parent = surface

	local back = Instance.new("Decal")
	back.Name = "PortalTextureBack"
	back.Face = Enum.NormalId.Back
	back.Texture = PORTAL_TEXTURE
	back.Color3 = PORTAL_GREEN
	back.Transparency = 0
	back.Parent = surface

	local light = Instance.new("PointLight")
	light.Name = "SoftGreenPortalLight"
	light.Color = PORTAL_GREEN_LIGHT
	light.Brightness = 0.2
	light.Range = 8
	light.Shadows = false
	light.Parent = surface

	local attachment = Instance.new("Attachment")
	attachment.Name = "GreenPortalAttachment"
	attachment.Parent = surface

	local particles = Instance.new("ParticleEmitter")
	particles.Name = "GreenPortalParticles"
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Color = ColorSequence.new(PORTAL_GREEN)
	particles.LightEmission = 0.7
	particles.Rate = 0
	particles.Lifetime = NumberRange.new(0.35, 0.7)
	particles.Speed = NumberRange.new(0.3, 0.8)
	particles.SpreadAngle = Vector2.new(360, 360)
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.10),
		NumberSequenceKeypoint.new(0.5, 0.06),
		NumberSequenceKeypoint.new(1, 0)
	})
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	particles.Parent = attachment

	local expandTween = TweenService:Create(
		surface,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = FULL_SIZE }
	)
	local lightTween = TweenService:Create(
		light,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Brightness = 1.8 }
	)
	expandTween:Play()
	lightTween:Play()
	particles:Emit(24)
	particles.Rate = 6

	local rotation = 0
	local rotationConnection
	rotationConnection = RunService.RenderStepped:Connect(function(dt)
		if not portal or not portal.Parent then
			if rotationConnection then rotationConnection:Disconnect() end
			return
		end
		rotation += dt * 0.65
		surface.CFrame = portal.CFrame * CFrame.Angles(0, 0, rotation)
	end)

	task.spawn(function()
		local pulseTime = 0
		while portal and portal.Parent do
			pulseTime += 0.08
			local pulse = (math.sin(pulseTime * 2) + 1) / 2
			front.Transparency = 0.02 + pulse * 0.06
			back.Transparency = 0.02 + pulse * 0.06
			light.Brightness = 1.5 + pulse * 0.5
			task.wait(0.08)
		end
	end)

	playPortalSpawnSound(portal)
	return portal
end

--==================================================
-- TELEPORT EFFECT
--==================================================

local function spawnTeleportEffect(position)
    local flash = Instance.new("Part")
    flash.Name = "TeleportFlash"
    flash.Shape = Enum.PartType.Ball
    flash.Material = Enum.Material.Neon
    flash.Color = PORTAL_GREEN_LIGHT
    flash.Size = Vector3.new(2, 2, 2)
    flash.Transparency = 0.3
    flash.Anchored = true
    flash.CanCollide = false
    flash.CFrame = CFrame.new(position)
    flash.Parent = workspace

    local light = Instance.new("PointLight")
    light.Color = PORTAL_GREEN_LIGHT
    light.Brightness = 8
    light.Range = 20
    light.Parent = flash

    local att = Instance.new("Attachment")
    att.Parent = flash

    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new(PORTAL_GREEN)
    particles.LightEmission = 0.8
    particles.Rate = 0
    particles.Lifetime = NumberRange.new(0.2, 0.5)
    particles.Speed = NumberRange.new(1, 3)
    particles.SpreadAngle = Vector2.new(360, 360)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    particles.Parent = att
    particles:Emit(40)

    TweenService:Create(flash, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(8, 8, 8),
        Transparency = 1
    }):Play()

    task.delay(0.7, function()
        if flash then flash:Destroy() end
    end)
end

--==================================================
-- TWO WAY TELEPORT
--==================================================

local function connectPortalTeleport(entrance, destination)
	if not entrance or not destination then return end

	entrance.Touched:Connect(function(hit)
		if teleportDebounce then return end

		local character = LocalPlayer.Character
		if not character then return end
		if not hit:IsDescendantOf(character) then return end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		if not destination or not destination.Parent then return end

		teleportDebounce = true
		if portal_sound then portal_sound:Play() end

		spawnTeleportEffect(hrp.Position)

		local destinationCF = destination.CFrame
		hrp.CFrame = destinationCF * CFrame.new(0, 0, -4)
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero

		task.wait(0.1)
		spawnTeleportEffect(hrp.Position)

		task.delay(0.7, function()
			teleportDebounce = false
		end)
	end)
end

--==================================================
-- PORTAL PAIR
--==================================================

local function createPortalPair(pointDataA, pointDataB)
	clearAllPortals()

	portalA = create_portal(pointDataA.Position, nil, pointDataA.Normal)
	portalB = create_portal(pointDataB.Position, nil, pointDataB.Normal)

	connectPortalTeleport(portalA, portalB)
	connectPortalTeleport(portalB, portalA)
end

--==================================================
-- SCREEN RAYCAST
--==================================================

local function raycastFromScreen(screenPosition)
	local camera = workspace.CurrentCamera
	if not camera then return nil end

	local ray = camera:ViewportPointToRay(screenPosition.X, screenPosition.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	local exclusions = {}
	local character = LocalPlayer.Character
	if character then table.insert(exclusions, character) end
	if portal_gun then table.insert(exclusions, portal_gun) end
	if portalA then table.insert(exclusions, portalA) end
	if portalB then table.insert(exclusions, portalB) end
	params.FilterDescendantsInstances = exclusions

	return workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
end

--==================================================
-- GUI (ЗЕЛЁНАЯ ТЕМА, НО СТИЛЬ EVIL MORTY)
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "evil_morty_portal_GUI_green"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

-- Прицел (круг)
local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 24, 0, 24)
crosshair.Position = UDim2.new(0.5, -12, 0.5, -12)
crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshair.BackgroundTransparency = 0.5
crosshair.BorderSizePixel = 0
crosshair.Parent = gui

local crosshairCorner = Instance.new("UICorner")
crosshairCorner.CornerRadius = UDim.new(1, 0)
crosshairCorner.Parent = crosshair

local crosshairOutline = Instance.new("Frame")
crosshairOutline.Name = "Outline"
crosshairOutline.Size = UDim2.new(0, 28, 0, 28)
crosshairOutline.Position = UDim2.new(0.5, -14, 0.5, -14)
crosshairOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
crosshairOutline.BackgroundTransparency = 0.7
crosshairOutline.BorderSizePixel = 0
crosshairOutline.Parent = gui

local outlineCorner = Instance.new("UICorner")
outlineCorner.CornerRadius = UDim.new(1, 0)
outlineCorner.Parent = crosshairOutline

-- Главное меню
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 350)
frame.Position = UDim2.new(0.5, -170, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = PORTAL_GREEN
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local menuToggle = Instance.new("TextButton")
menuToggle.Name = "MenuToggle"
menuToggle.Size = UDim2.new(0, 60, 0, 60)
menuToggle.Position = UDim2.new(0, 15, 1, -80)
menuToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuToggle.BackgroundTransparency = 0.1
menuToggle.BorderSizePixel = 1
menuToggle.BorderColor3 = PORTAL_GREEN
menuToggle.TextColor3 = PORTAL_GREEN
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
	menuToggle.Text = menuOpen and "✕" or "☰"
end)

local function makeButton(text, x, color)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 100, 0, 38)
	button.Position = UDim2.new(0, x, 0, 10)
	button.BackgroundColor3 = color
	button.BorderSizePixel = 1
	button.BorderColor3 = PORTAL_GREEN
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Text = text
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Parent = frame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = button

	return button
end

local pointButton = makeButton("POINT", 10, PORTAL_GREEN_DARK)
local playerButton = makeButton("PLAYER", 120, PORTAL_GREEN_DARK)
local placeButton = makeButton("PLACE", 230, PORTAL_GREEN_DARK)

local input = Instance.new("TextBox")
input.Size = UDim2.new(0, 320, 0, 45)
input.Position = UDim2.new(0, 10, 0, 60)
input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
input.BackgroundTransparency = 0.35
input.BorderSizePixel = 1
input.BorderColor3 = PORTAL_GREEN
input.TextColor3 = Color3.fromRGB(200, 255, 200)
input.PlaceholderColor3 = Color3.fromRGB(100, 150, 100)
input.PlaceholderText = "Player name / Place ID"
input.Text = ""
input.TextScaled = true
input.Font = Enum.Font.Gotham
input.Parent = frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = input

local fireButton = Instance.new("TextButton")
fireButton.Size = UDim2.new(0, 320, 0, 55)
fireButton.Position = UDim2.new(0, 10, 0, 115)
fireButton.BackgroundColor3 = PORTAL_GREEN
fireButton.BorderSizePixel = 2
fireButton.BorderColor3 = PORTAL_GREEN_LIGHT
fireButton.TextColor3 = Color3.fromRGB(0, 0, 0)
fireButton.Text = "FIRE"
fireButton.TextScaled = true
fireButton.Font = Enum.Font.GothamBold
fireButton.Parent = frame

local fireCorner = Instance.new("UICorner")
fireCorner.CornerRadius = UDim.new(0, 10)
fireCorner.Parent = fireButton

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 320, 0, 45)
status.Position = UDim2.new(0, 10, 0, 180)
status.BackgroundTransparency = 1
status.TextColor3 = PORTAL_GREEN_LIGHT
status.Text = "POINT: FIRE → A → B"
status.TextScaled = true
status.Font = Enum.Font.Gotham
status.Parent = frame

local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0, 320, 0, 45)
resetButton.Position = UDim2.new(0, 10, 0, 235)
resetButton.BackgroundColor3 = PORTAL_GREEN_DARK
resetButton.BorderSizePixel = 1
resetButton.BorderColor3 = PORTAL_GREEN
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.Text = "RESET PORTALS"
resetButton.TextScaled = true
resetButton.Font = Enum.Font.GothamBold
resetButton.Parent = frame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 8)
resetCorner.Parent = resetButton

--==================================================
-- POINT SELECTION
--==================================================

local function startPointSelection()
	if currentMode ~= "POINT" then return end

	clearPointSelection()
	pointSelecting = true
	pointStage = 1

	status.Text = "TAP / CLICK → SET POINT A"
end

local function setPoint(position, normal)
	if currentMode ~= "POINT" then return end
	if not pointSelecting then return end

	if pointStage == 1 then
		pointA = { Position = position, Normal = normal }
		pointStage = 2

		local muzzlePos = muzzleFlash()
		if muzzlePos then
			createBeam(muzzlePos, position)
		end
		if portal_sound then portal_sound:Play() end

		status.Text = "POINT A SET → TAP / CLICK POINT B"
		return
	end

	if pointStage == 2 then
		pointB = { Position = position, Normal = normal }

		local muzzlePos = muzzleFlash()
		if muzzlePos then
			createBeam(muzzlePos, position)
		end
		if portal_sound then portal_sound:Play() end

		createPortalPair(pointA, pointB)

		pointStage = 0
		pointSelecting = false
		pointA = nil
		pointB = nil

		status.Text = "PORTALS READY → ENTER ONE"
	end
end

--==================================================
-- FIND PLAYER
--==================================================

local function findPlayer(name)
	name = string.lower(string.gsub(name, "^%s*(.-)%s*$", "%1"))

	for _, player in ipairs(Players:GetPlayers()) do
		if string.lower(player.Name) == name or string.lower(player.DisplayName) == name then
			return player
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if string.lower(player.Name):sub(1, #name) == name then
			return player
		end
	end

	return nil
end

--==================================================
-- PLAYER PORTAL
--==================================================

local function firePlayerPortal(playerName)
	local target = findPlayer(playerName)
	if not target then return false end
	if not target.Character then return false end

	local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
	local character = LocalPlayer.Character
	if not targetHRP or not character then return false end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	muzzleFlash()
	if portal_sound then portal_sound:Play() end

	clearAllPortals()

	local frontPosition = hrp.Position + hrp.CFrame.LookVector * 5 + Vector3.new(0, PLAYER_PORTAL_HEIGHT - 2.8, 0)
	local targetPosition = targetHRP.Position + Vector3.new(0, PLAYER_PORTAL_HEIGHT - 2.8, 0)

	local entrance = create_portal(frontPosition, hrp.CFrame.LookVector)
	local destination = create_portal(targetPosition, -targetHRP.CFrame.LookVector)

	portalA = entrance
	portalB = destination

	connectPortalTeleport(entrance, destination)
	connectPortalTeleport(destination, entrance)

	return true
end

--==================================================
-- PLACE PORTAL
--==================================================

local function firePlacePortal(placeId)
	placeId = tonumber(placeId)
	if not placeId then return false end

	local character = LocalPlayer.Character
	if not character then return false end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	muzzleFlash()
	if portal_sound then portal_sound:Play() end

	clearAllPortals()

	local position = hrp.Position + hrp.CFrame.LookVector * 5
	local portal = create_portal(position, hrp.CFrame.LookVector)
	portalA = portal

	portal.Touched:Connect(function(hit)
		if teleportDebounce then return end

		local currentCharacter = LocalPlayer.Character
		if not currentCharacter then return end
		if not hit:IsDescendantOf(currentCharacter) then return end

		teleportDebounce = true
		if portal_sound then portal_sound:Play() end

		spawnTeleportEffect(hrp.Position)

		local success = pcall(function()
			TeleportService:Teleport(placeId, LocalPlayer)
		end)

		if not success then
			teleportDebounce = false
		end
	end)

	return true
end

--==================================================
-- MODE
--==================================================

local function setMode(mode)
	clearAllPortals()
	currentMode = mode

	if mode == "POINT" then
		status.Text = "POINT: FIRE → A → B"
		input.PlaceholderText = "Point mode"
	elseif mode == "PLAYER" then
		status.Text = "PLAYER: ENTER NAME → FIRE"
		input.PlaceholderText = "Player name"
	elseif mode == "PLACE" then
		status.Text = "PLACE: ENTER ID → FIRE"
		input.PlaceholderText = "Place ID"
	end
end

--==================================================
-- FIRE
--==================================================

local function fire()
	if currentMode == "PLAYER" then
		if input.Text == "" then
			status.Text = "ENTER PLAYER NAME"
			return
		end

		local success = firePlayerPortal(input.Text)
		status.Text = success and "ENTER THE GREEN PORTAL" or "PLAYER NOT FOUND"
		return
	end

	if currentMode == "PLACE" then
		if input.Text == "" then
			status.Text = "ENTER PLACE ID"
			return
		end

		local success = firePlacePortal(input.Text)
		status.Text = success and "ENTER THE GREEN PORTAL" or "INVALID PLACE ID"
		return
	end

	if currentMode == "POINT" then
		if not pointSelecting then
			startPointSelection()
		else
			status.Text = "TAP / CLICK SCREEN TO SET POINT"
		end
	end
end

--==================================================
-- BUTTON CONNECTIONS
--==================================================

pointButton.Activated:Connect(function() setMode("POINT") end)
playerButton.Activated:Connect(function() setMode("PLAYER") end)
placeButton.Activated:Connect(function() setMode("PLACE") end)
fireButton.Activated:Connect(function() fire() end)

--==================================================
-- TOOL
--==================================================

local function connectTool()
	if not portal_gun then return end
	portal_gun.Activated:Connect(function() fire() end)
end

--==================================================
-- MOBILE FIRE
--==================================================

if UserInputService.TouchEnabled then
	local mobileButton = Instance.new("TextButton")
	mobileButton.Size = UDim2.new(0, 80, 0, 80)
	mobileButton.Position = UDim2.new(1, -100, 1, -130)
	mobileButton.BackgroundColor3 = PORTAL_GREEN_DARK
	mobileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	mobileButton.Text = "FIRE"
	mobileButton.TextScaled = true
	mobileButton.Font = Enum.Font.GothamBold
	mobileButton.BorderSizePixel = 1
	mobileButton.BorderColor3 = PORTAL_GREEN
	mobileButton.Parent = gui

	local mobileCorner = Instance.new("UICorner")
	mobileCorner.CornerRadius = UDim.new(1, 0)
	mobileCorner.Parent = mobileButton

	mobileButton.Activated:Connect(function() fire() end)
end

--==================================================
-- MOBILE POINT
--==================================================

if UserInputService.TouchEnabled then
	UserInputService.TouchTap:Connect(function(touchPositions, processed)
		if processed then return end
		if currentMode ~= "POINT" then return end
		if not pointSelecting then return end

		local touch = touchPositions[1]
		if not touch then return end

		local result = raycastFromScreen(touch)
		if not result then
			status.Text = "NO TARGET"
			return
		end

		setPoint(result.Position, result.Normal)
	end)
end

--==================================================
-- PC MOUSE
--==================================================

if UserInputService.MouseEnabled then
	UserInputService.InputBegan:Connect(function(inputObject, processed)
		if processed then return end
		if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if currentMode ~= "POINT" then return end
		if not pointSelecting then return end

		local mousePosition = UserInputService:GetMouseLocation()
		local result = raycastFromScreen(mousePosition)
		if not result then
			status.Text = "NO TARGET"
			return
		end

		setPoint(result.Position, result.Normal)
	end)
end

--==================================================
-- УЛУЧШЕННЫЙ ПРИЦЕЛ: ЛИНИЯ + МАРКЕР
--==================================================

local aimLine = nil
local aimMarker = nil

local function updateAimVisuals()
	if aimLine and aimLine.Parent then aimLine:Destroy() end
	if aimMarker and aimMarker.Parent then aimMarker:Destroy() end
	aimLine = nil
	aimMarker = nil

	if currentMode ~= "POINT" or not pointSelecting then return end

	local mousePos = UserInputService:GetMouseLocation()
	local result = raycastFromScreen(mousePos)
	if not result then return end

	local camera = workspace.CurrentCamera
	if not camera then return end

	local origin = camera.CFrame.Position
	local targetPos = result.Position
	local normal = result.Normal

	local distance = (targetPos - origin).Magnitude
	if distance > 0.1 then
		aimLine = Instance.new("Part")
		aimLine.Name = "AimLine"
		aimLine.Anchored = true
		aimLine.CanCollide = false
		aimLine.CanTouch = false
		aimLine.CanQuery = false
		aimLine.CastShadow = false
		aimLine.Material = Enum.Material.Neon
		aimLine.Color = PORTAL_GREEN
		aimLine.Size = Vector3.new(0.06, 0.06, distance)
		aimLine.CFrame = CFrame.lookAt(origin, targetPos) * CFrame.new(0, 0, -distance / 2)
		aimLine.Transparency = 0.3
		aimLine.Parent = workspace

		local light = Instance.new("PointLight")
		light.Color = PORTAL_GREEN_LIGHT
		light.Brightness = 0.5
		light.Range = 3
		light.Parent = aimLine
	end

	aimMarker = Instance.new("Part")
	aimMarker.Name = "AimMarker"
	aimMarker.Shape = Enum.PartType.Ball
	aimMarker.Anchored = true
	aimMarker.CanCollide = false
	aimMarker.CanTouch = false
	aimMarker.CanQuery = false
	aimMarker.CastShadow = false
	aimMarker.Material = Enum.Material.Neon
	aimMarker.Color = PORTAL_GREEN
	aimMarker.Size = Vector3.new(0.2, 0.2, 0.2)
	aimMarker.Transparency = 0.2
	aimMarker.CFrame = CFrame.new(targetPos + normal * 0.02)
	aimMarker.Parent = workspace

	local markerLight = Instance.new("PointLight")
	markerLight.Color = PORTAL_GREEN_LIGHT
	markerLight.Brightness = 1.5
	markerLight.Range = 4
	markerLight.Parent = aimMarker
end

RunService.RenderStepped:Connect(function()
	if currentMode == "POINT" and pointSelecting then
		local mousePos = UserInputService:GetMouseLocation()
		local result = raycastFromScreen(mousePos)
		if result then
			crosshair.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			crosshair.BackgroundTransparency = 0.3
		else
			crosshair.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			crosshair.BackgroundTransparency = 0.3
		end
	else
		crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		crosshair.BackgroundTransparency = 0.5
	end

	updateAimVisuals()
end)

--==================================================
-- RESET
--==================================================

resetButton.Activated:Connect(function()
	clearAllPortals()
	status.Text = "PORTALS RESET"
end)

--==================================================
-- GIVE GUN
--==================================================

local function giveGun()
	local backpack = getBackpack()

	for _, obj in ipairs(backpack:GetChildren()) do
		if obj:IsA("Tool") and obj.Name == "EVIL_MORTY_PORTAL_GUN_GREEN" and obj ~= portal_gun then
			obj:Destroy()
		end
	end

	if LocalPlayer.Character then
		for _, obj in ipairs(LocalPlayer.Character:GetChildren()) do
			if obj:IsA("Tool") and obj.Name == "EVIL_MORTY_PORTAL_GUN_GREEN" and obj ~= portal_gun then
				obj:Destroy()
			end
		end
	end

	if not portal_gun or portal_gun.Parent == nil then
		portal_gun = nil
		Handle = nil
		portal_sound = nil
		createGun()
		connectTool()
	end

	if portal_gun and portal_gun.Parent ~= backpack and portal_gun.Parent ~= LocalPlayer.Character then
		portal_gun.Parent = backpack
	end
end

--==================================================
-- INITIAL GIVE
--==================================================

createGun()

if portal_gun then
	connectTool()
	portal_gun.Parent = getBackpack()
end

--==================================================
-- RESPAWN SAFE (порталы НЕ удаляются)
--==================================================

LocalPlayer.CharacterAdded:Connect(function(character)
	task.wait(0.5)

	local newBackpack = LocalPlayer:WaitForChild("Backpack")
	Backpack = newBackpack

	portal_gun = nil
	Handle = nil
	portal_sound = nil

	task.wait(0.5)

	createGun()

	if portal_gun then
		connectTool()
		portal_gun.Parent = newBackpack
	end

	status.Text = "POINT: FIRE → TAP A → TAP B"
end)

--==================================================
-- BACKPACK MONITOR
--==================================================

Backpack.ChildRemoved:Connect(function(child)
	if child ~= portal_gun then return end

	task.delay(0.2, function()
		local currentBackpack = getBackpack()

		if not portal_gun then return end

		if portal_gun.Parent == nil then
			portal_gun = nil
			Handle = nil
			portal_sound = nil
			createGun()

			if portal_gun then
				connectTool()
				portal_gun.Parent = currentBackpack
			end
		end
	end)
end)

--==================================================
-- ОТКРЫТИЕ/ЗАКРЫТИЕ GUI ПО ALT
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
        menuOpen = not menuOpen
        frame.Visible = menuOpen
        menuToggle.Text = menuOpen and "✕" or "☰"
    end
end)

--==================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (необходимые для работы)
--==================================================

local function getBackpack()
	Backpack = LocalPlayer:WaitForChild("Backpack")
	return Backpack
end

local function clearAllPortals()
	if portalA then destroyPortal(portalA) end
	if portalB then destroyPortal(portalB) end
	portalA = nil
	portalB = nil
	clearPointSelection()
	teleportDebounce = false
end

local function destroyPortal(portal)
	if portal and portal.Parent then
		portal:Destroy()
	end
end

local function clearPointSelection()
	pointStage = 0
	pointA = nil
	pointB = nil
	pointSelecting = false
end

--==================================================
-- START
--==================================================

setMode("POINT")
