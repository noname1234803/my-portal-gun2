--==================================================
-- RICK PRIME PORTAL GUN
-- GREEN PORTAL VERSION
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
    bloom.Intensity = 0.2
    bloom.Threshold = 0.6
    bloom.Size = 6
    bloom.Parent = Lighting
end

--==================================================
-- НАСТРОЙКИ
--==================================================

local PORTAL_TEXTURE = "rbxassetid://77878374203347" -- текстура остаётся, цвет задаётся через Decal

-- Зелёная палитра
local PORTAL_GREEN = Color3.fromRGB(0, 255, 65)
local PORTAL_GREEN_LIGHT = Color3.fromRGB(80, 255, 130)
local PORTAL_GREEN_DARK = Color3.fromRGB(0, 180, 40)

local PORTAL_GUN_SOUND = "rbxassetid://1013378689"
local PORTAL_SPAWN_SOUND = "rbxassetid://756847338"

--==================================================
-- ВЫСОТА ПОРТАЛА ДЛЯ PLAYER
--==================================================

local PLAYER_PORTAL_HEIGHT = 1.0

--==================================================
-- ПЕРЕМЕННЫЕ ПОРТАЛОВ
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
-- ПЕРЕМЕННЫЕ ПУШКИ
--==================================================

local portal_gun = nil
local portal_sound = nil
local Handle = nil

--==================================================
-- МОДЕЛЬ ПУШКИ (переработанная под Рика Прайма)
--==================================================

local PARTS = {
	-- Корпус (тёмно-зелёный)
	{ Name = "Part", Size = Vector3.new(0.272445,0.197322,0.227038),
		CFrame = CFrame.new(1.11402,1.00547,-10.9034, 1,0,0, 0,0,-1, 0,1,0),
		Color = Color3.fromRGB(30,60,30), Shape = "Block" },
	-- Деталь (ярко-зелёная)
	{ Name = "Part", Size = Vector3.new(0.272445,0.24273,0.454076),
		CFrame = CFrame.new(1.06861,1.119,-11.1986, 1,0,0, 0,0,-1, 0,1,0),
		Color = Color3.fromRGB(0,200,50), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.272445,0.197322,0.227038),
		CFrame = CFrame.new(1.06861,1.119,-10.6442, 1,0,0, 0,0,-1, 0,1,0),
		Color = Color3.fromRGB(30,60,30), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.454076,2.13416,0.36326),
		CFrame = CFrame.new(1.06861,0.823826,-10.5174, 1,0,0, 0,0,-1, 0,1,0),
		Color = Color3.fromRGB(0,150,30), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.590298,0.908151,0.0908151),
		CFrame = CFrame.new(1.06861,1.20982,-10.3371, 0,1,0, 0.707107,0,0.707107, 0.707107,0,-0.707107),
		Color = Color3.fromRGB(0,200,50), Shape = "Cylinder" },
	-- Ручка (Handle) – чёрная с зелёным отливом
	{ Name = "Handle", Size = Vector3.new(0.454076,0.908151,0.454077),
		CFrame = CFrame.new(1.06861,0.454076,-10.8823, 1,0,0, 0,0.707107,-0.707107, 0,0.707107,0.707107),
		Color = Color3.fromRGB(20,40,20), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.23219,0.136223,0.0454076),
		CFrame = CFrame.new(0.932386,0.560068,-10.3782, 0,0,-1, -0.707107,0.707107,0, 0.707107,0.707107,0),
		Color = Color3.fromRGB(0,200,50), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.908151,0.908151,0.227038),
		CFrame = CFrame.new(1.02154,1.20982,-10.0633, 0,1,0, 0.965926,0,-0.258819, -0.258819,0,-0.965926),
		Color = Color3.fromRGB(0,255,65), Shape = "Cylinder" },
	{ Name = "Part", Size = Vector3.new(0.0537722,0.908151,0.358481),
		CFrame = CFrame.new(1.02154,1.62249,-10.1739, 0,1,0, 0.965926,0,-0.258819, -0.258819,0,-0.965926),
		Color = Color3.fromRGB(0,255,65), Shape = "Cylinder" },
	{ Name = "Part", Size = Vector3.new(0.795168,0.726521,0.862743),
		CFrame = CFrame.new(1.06861,0.993849,-9.58647, -0,0,-1, -1,0,0, 0,1,0),
		Color = Color3.fromRGB(0,150,30), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.317853,0.317853,0.317853),
		CFrame = CFrame.new(0.728048,0.993849,-9.54345, 1,0,0, 0,1,0, 0,0,1),
		Color = Color3.fromRGB(0,255,65), Shape = "Ball" },
	{ Name = "Part", Size = Vector3.new(0.317853,0.317853,0.317853),
		CFrame = CFrame.new(1.09131,0.993845,-9.2459, 1,0,0, 0,1,0, 0,0,1),
		Color = Color3.fromRGB(0,255,65), Shape = "Ball" },
	{ Name = "Part", Size = Vector3.new(0.795168,0.862743,0.136223),
		CFrame = CFrame.new(0.705344,0.993846,-9.51836, -0,0,-1, -1,0,0, 0,1,0),
		Color = Color3.fromRGB(0,150,30), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.114055,0.862743,0.862743),
		CFrame = CFrame.new(1.06873,0.653257,-9.51836, -0,0,-1, -1,0,0, 0,1,0),
		Color = Color3.fromRGB(0,200,50), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.795168,0.862743,0.136223),
		CFrame = CFrame.new(1.43186,0.993846,-9.51836, 0,0,-1, -1,0,0, 0,1,0),
		Color = Color3.fromRGB(0,150,30), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.114055,0.862743,0.862743),
		CFrame = CFrame.new(1.06873,1.33495,-9.51836, 0,0,-1, -1,0,0, 0,1,0),
		Color = Color3.fromRGB(0,200,50), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.454076,0.375442,0.5),
		CFrame = CFrame.new(1.06861,0.817736,-11.8345, 0,0,1, 0,1,0, -1,0,0),
		Color = Color3.fromRGB(0,150,30), Shape = "Wedge" },
}

--==================================================
-- РЮКЗАК
--==================================================

local function getBackpack()
	Backpack = LocalPlayer:WaitForChild("Backpack")
	return Backpack
end

--==================================================
-- УДАЛЕНИЕ СТАРЫХ ПУШЕК
--==================================================

local function removeOldGuns()
	local backpack = getBackpack()
	for _, container in ipairs({ backpack, LocalPlayer.Character }) do
		if container then
			for _, obj in ipairs(container:GetChildren()) do
				if obj:IsA("Tool") and (obj.Name == "Portal_Gun" or obj.Name == "EVIL_MORTY_PORTAL_GUN" or obj.Name == "RICK_PRIME_PORTAL_GUN") then
					obj:Destroy()
				end
			end
		end
	end
end

removeOldGuns()

--==================================================
-- ОЧИСТКА GUI
--==================================================

local oldGui = PlayerGui:FindFirstChild("evil_morty_portal_GUI")
if oldGui then oldGui:Destroy() end
local oldRickGui = PlayerGui:FindFirstChild("rick_portal_GUI")
if oldRickGui then oldRickGui:Destroy() end
local oldPrimeGui = PlayerGui:FindFirstChild("RickPrimePortalGUI")
if oldPrimeGui then oldPrimeGui:Destroy() end

--==================================================
-- ОЧИСТКА ПОРТАЛОВ
--==================================================

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

local function clearAllPortals()
	if portalA then destroyPortal(portalA) end
	if portalB then destroyPortal(portalB) end
	portalA = nil
	portalB = nil
	clearPointSelection()
	teleportDebounce = false
end

--==================================================
-- СОЗДАНИЕ ПУШКИ
--==================================================

local function createGun()
	if portal_gun and portal_gun.Parent then
		return portal_gun
	end

	portal_gun = nil
	Handle = nil
	portal_sound = nil

	portal_gun = Instance.new("Tool")
	portal_gun.Name = "RICK_PRIME_PORTAL_GUN"
	portal_gun.RequiresHandle = true
	portal_gun.CanBeDropped = false

	local handleDefinition
	for _, def in ipairs(PARTS) do
		if def.Name == "Handle" then
			handleDefinition = def
			break
		end
	end

	if not handleDefinition then
		warn("Handle not found")
		portal_gun:Destroy()
		portal_gun = nil
		return nil
	end

	Handle = Instance.new("Part")
	Handle.Name = "Handle"
	Handle.Size = handleDefinition.Size
	Handle.CFrame = handleDefinition.CFrame
	Handle.Color = handleDefinition.Color
	Handle.Material = Enum.Material.Plastic
	Handle.Shape = Enum.PartType[handleDefinition.Shape]
	Handle.Anchored = false
	Handle.CanCollide = false
	Handle.CanTouch = false
	Handle.CanQuery = false
	Handle.Massless = true
	Handle.TopSurface = Enum.SurfaceType.Smooth
	Handle.BottomSurface = Enum.SurfaceType.Smooth
	Handle.Parent = portal_gun

	for _, def in ipairs(PARTS) do
		if def.Name ~= "Handle" then
			local p = Instance.new("Part")
			p.Name = def.Name
			p.Size = def.Size
			p.CFrame = def.CFrame
			p.Color = def.Color
			p.Material = Enum.Material.Plastic
			p.Shape = Enum.PartType[def.Shape]
			p.Anchored = false
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
			p.Massless = true
			p.TopSurface = Enum.SurfaceType.Smooth
			p.BottomSurface = Enum.SurfaceType.Smooth
			p.Parent = portal_gun

			local weld = Instance.new("WeldConstraint")
			weld.Name = "PortalGunWeld"
			weld.Part0 = Handle
			weld.Part1 = p
			weld.Parent = p
		end
	end

	portal_gun.Grip = CFrame.new(
		-0.000491312, -0.31704, -0.182152,
		-0.998248, 0, -0.059161,
		0.044804, 0.653046, -0.755992,
		0.038635, -0.757319, -0.651902
	)

	portal_sound = Instance.new("Sound")
	portal_sound.Name = "PortalGunSound"
	portal_sound.SoundId = PORTAL_GUN_SOUND
	portal_sound.Volume = 2.5
	portal_sound.Parent = Handle

	-- Жидкость внутри (зелёная)
	local liquidBase
	for _, obj in ipairs(portal_gun:GetChildren()) do
		if obj:IsA("Part") and obj ~= Handle and obj.Shape == Enum.PartType.Cylinder then
			if obj.Color == Color3.fromRGB(0, 255, 65) then
				liquidBase = obj
				break
			end
		end
	end

	if liquidBase then
		local liquid = Instance.new("Part")
		liquid.Name = "AnimatedPrimeLiquid"
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
		liquid.CFrame = liquidBase.CFrame
		liquid.Parent = portal_gun

		local liquidWeld = Instance.new("Weld")
		liquidWeld.Name = "LiquidAnimationWeld"
		liquidWeld.Part0 = liquidBase
		liquidWeld.Part1 = liquid
		liquidWeld.Parent = liquidBase

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
	flash.Name = "PrimeMuzzleFlash"
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
	beam.Name = "PrimePortalBeam"
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
-- ЗВУК ПОРТАЛА
--==================================================

local function playPortalSpawnSound(portal)
	if not portal then return end

	local sound = Instance.new("Sound")
	sound.Name = "PrimePortalSpawnSound"
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
-- СОЗДАНИЕ ПОРТАЛА (зелёный, увеличен в 1.5)
--==================================================

local function create_portal(position, lookDirection, surfaceNormal)
	local portal = Instance.new("Part")
	portal.Name = "PrimeGreenPortal"
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
	attachment.Name = "PrimePortalAttachment"
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
-- ЭФФЕКТ ТЕЛЕПОРТАЦИИ
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
-- ДВУСТОРОННЯЯ ТЕЛЕПОРТАЦИЯ
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
-- ПАРА ПОРТАЛОВ
--==================================================

local function createPortalPair(pointDataA, pointDataB)
	clearAllPortals()

	portalA = create_portal(pointDataA.Position, nil, pointDataA.Normal)
	portalB = create_portal(pointDataB.Position, nil, pointDataB.Normal)

	connectPortalTeleport(portalA, portalB)
	connectPortalTeleport(portalB, portalA)
end

--==================================================
-- РЕЙКАСТ С ЭКРАНА
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
-- ГЛАВНОЕ МЕНЮ (GUI) — ЗЕЛЁНАЯ ТЕМА РИКА ПРАЙМА
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "RickPrimePortalGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

-- ====== ФОН МЕНЮ ======
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 420)
frame.Position = UDim2.new(0.5, -210, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 65)
frame.Parent = gui

local glowBorder = Instance.new("Frame")
glowBorder.Size = UDim2.new(1, -6, 1, -6)
glowBorder.Position = UDim2.new(0, 3, 0, 3)
glowBorder.BackgroundTransparency = 1
glowBorder.BorderSizePixel = 1
glowBorder.BorderColor3 = Color3.fromRGB(0, 200, 50)
glowBorder.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- ====== ЗАГОЛОВОК ======
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 65)
title.Text = "RICK PRIME"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 30)
subtitle.Position = UDim2.new(0, 0, 0, 55)
subtitle.BackgroundTransparency = 1
subtitle.TextColor3 = Color3.fromRGB(120, 255, 150)
subtitle.Text = "PORTAL GUN"
subtitle.TextScaled = true
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = frame

-- ====== КНОПКИ РЕЖИМОВ ======
local function makeGreenButton(text, x, y, width, isActive)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, width or 100, 0, 40)
	btn.Position = UDim2.new(0, x, 0, y)
	btn.BackgroundColor3 = isActive and Color3.fromRGB(0, 200, 50) or Color3.fromRGB(0, 40, 20)
	btn.BorderSizePixel = 1
	btn.BorderColor3 = Color3.fromRGB(0, 255, 65)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.Parent = frame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = btn

	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(0, 120, 40)
	end)
	btn.MouseLeave:Connect(function()
		if not isActive then
			btn.BackgroundColor3 = Color3.fromRGB(0, 40, 20)
		else
			btn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
		end
	end)

	return btn
end

local pointBtn = makeGreenButton("POINT", 15, 110, 120, true)
local playerBtn = makeGreenButton("PLAYER", 150, 110, 120, false)
local placeBtn = makeGreenButton("PLACE", 285, 110, 120, false)

-- ====== ПОЛЕ ВВОДА ======
local input = Instance.new("TextBox")
input.Size = UDim2.new(0, 390, 0, 45)
input.Position = UDim2.new(0, 15, 0, 170)
input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
input.BackgroundTransparency = 0.4
input.BorderSizePixel = 1
input.BorderColor3 = Color3.fromRGB(0, 200, 50)
input.TextColor3 = Color3.fromRGB(200, 255, 200)
input.PlaceholderColor3 = Color3.fromRGB(100, 150, 100)
input.PlaceholderText = "Player name / Place ID"
input.Text = ""
input.TextScaled = true
input.Font = Enum.Font.Gotham
input.Parent = frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = input

-- ====== КНОПКА FIRE ======
local fireBtn = Instance.new("TextButton")
fireBtn.Size = UDim2.new(0, 390, 0, 60)
fireBtn.Position = UDim2.new(0, 15, 0, 230)
fireBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
fireBtn.BorderSizePixel = 2
fireBtn.BorderColor3 = Color3.fromRGB(0, 255, 65)
fireBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
fireBtn.Text = "FIRE"
fireBtn.TextScaled = true
fireBtn.Font = Enum.Font.GothamBold
fireBtn.Parent = frame

local fireCorner = Instance.new("UICorner")
fireCorner.CornerRadius = UDim.new(0, 10)
fireCorner.Parent = fireBtn

task.spawn(function()
	while fireBtn and fireBtn.Parent do
		fireBtn.BackgroundColor3 = Color3.fromRGB(0, 200 + math.random(-20, 20), 50)
		task.wait(0.5)
	end
end)

-- ====== СТРОКА СТАТУСА ======
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 390, 0, 40)
status.Position = UDim2.new(0, 15, 0, 305)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(0, 255, 65)
status.Text = "POINT: FIRE → A → B"
status.TextScaled = true
status.Font = Enum.Font.Gotham
status.Parent = frame

-- ====== КНОПКА RESET ======
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0, 390, 0, 40)
resetBtn.Position = UDim2.new(0, 15, 0, 355)
resetBtn.BackgroundColor3 = Color3.fromRGB(0, 30, 15)
resetBtn.BorderSizePixel = 1
resetBtn.BorderColor3 = Color3.fromRGB(0, 120, 40)
resetBtn.TextColor3 = Color3.fromRGB(150, 255, 150)
resetBtn.Text = "RESET PORTALS"
resetBtn.TextScaled = true
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Parent = frame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetBtn

-- ====== ПЕРЕКЛЮЧАТЕЛЬ МЕНЮ (бургер/крестик) ======
local menuToggle = Instance.new("TextButton")
menuToggle.Name = "MenuToggle"
menuToggle.Size = UDim2.new(0, 50, 0, 50)
menuToggle.Position = UDim2.new(0, 15, 1, -65)
menuToggle.BackgroundColor3 = Color3.fromRGB(0, 40, 20)
menuToggle.BorderSizePixel = 1
menuToggle.BorderColor3 = Color3.fromRGB(0, 200, 50)
menuToggle.TextColor3 = Color3.fromRGB(0, 255, 65)
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

-- ====== ЗАКРЫТИЕ ПО ALT ======
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
        menuOpen = not menuOpen
        frame.Visible = menuOpen
        menuToggle.Text = menuOpen and "✕" or "☰"
    end
end)

--==================================================
-- ВЫБОР ТОЧКИ
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
-- ПОИСК ИГРОКА
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
-- ПОРТАЛ К ИГРОКУ
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
-- ПОРТАЛ НА МЕСТО
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
-- УСТАНОВКА РЕЖИМА
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
-- ВЫСТРЕЛ
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
-- ПРИВЯЗКА КНОПОК
--==================================================

pointBtn.Activated:Connect(function() setMode("POINT") end)
playerBtn.Activated:Connect(function() setMode("PLAYER") end)
placeBtn.Activated:Connect(function() setMode("PLACE") end)
fireBtn.Activated:Connect(function() fire() end)

--==================================================
-- ПРИВЯЗКА К ИНСТРУМЕНТУ
--==================================================

local function connectTool()
	if not portal_gun then return end
	portal_gun.Activated:Connect(function() fire() end)
end

--==================================================
-- МОБИЛЬНАЯ КНОПКА FIRE
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
	mobileButton.BorderSizePixel = 0
	mobileButton.Parent = gui

	local mobileCorner = Instance.new("UICorner")
	mobileCorner.CornerRadius = UDim.new(1, 0)
	mobileCorner.Parent = mobileButton

	mobileButton.Activated:Connect(function() fire() end)
end

--==================================================
-- МОБИЛЬНЫЙ ВЫБОР ТОЧКИ (тап)
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
-- ПК МЫШЬ (клик)
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
-- СБРОС
--==================================================

resetBtn.Activated:Connect(function()
	clearAllPortals()
	status.Text = "PORTALS RESET"
end)

--==================================================
-- ВЫДАЧА ПУШКИ
--==================================================

local function giveGun()
	local backpack = getBackpack()

	for _, obj in ipairs(backpack:GetChildren()) do
		if obj:IsA("Tool") and obj.Name == "RICK_PRIME_PORTAL_GUN" and obj ~= portal_gun then
			obj:Destroy()
		end
	end

	if LocalPlayer.Character then
		for _, obj in ipairs(LocalPlayer.Character:GetChildren()) do
			if obj:IsA("Tool") and obj.Name == "RICK_PRIME_PORTAL_GUN" and obj ~= portal_gun then
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
-- ПЕРВИЧНАЯ ВЫДАЧА
--==================================================

createGun()

if portal_gun then
	connectTool()
	portal_gun.Parent = getBackpack()
end

--==================================================
-- БЕЗОПАСНОСТЬ ПРИ РЕСПАВНЕ (порталы не удаляются)
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
-- МОНИТОРИНГ РЮКЗАКА
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
-- ЗАПУСК
--==================================================

setMode("POINT")
