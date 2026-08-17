--==================================================
-- EVIL MORTY PORTAL GUN (БЕЗ ЭФФЕКТОВ ТЕЛЕПОРТАЦИИ)
-- FULL LOCAL SCRIPT
--
-- ПОРТАЛ С ИЗМЕНЯЕМЫМ ЦВЕТОМ (ползунок + кнопки)
-- ОРИЕНТАЦИЯ ПО НОРМАЛИ ПОВЕРХНОСТИ
-- ПРИВЯЗКА К ДВИЖУЩИМСЯ ОБЪЕКТАМ
-- ЖИВАЯ ПУЛЬСАЦИЯ ПОРТАЛА
-- СЛЕДЫ НА СТЕНАХ ПОСЛЕ ЗАКРЫТИЯ
-- УСКОРЕНИЕ ПРИ ВЫХОДЕ ИЗ ПОРТАЛА
-- БЕЗ ВСПЫШЕК И ЧАСТИЦ ПРИ ТЕЛЕПОРТАЦИИ
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
-- BLOOM EFFECT
--==================================================

local bloom = Lighting:FindFirstChild("PortalBloom")
if not bloom then
    bloom = Instance.new("BloomEffect")
    bloom.Name = "PortalBloom"
    bloom.Intensity = 0.15
    bloom.Threshold = 0.7
    bloom.Size = 5
    bloom.Parent = Lighting
end

--==================================================
-- НАСТРОЙКИ (ЦВЕТ ПО УМОЛЧАНИЮ - ЗОЛОТОЙ)
--==================================================

local PORTAL_TEXTURE = "rbxassetid://77878374203347"

-- Динамические цвета портала
local portalColor = Color3.fromRGB(255, 195, 35)
local portalColorLight = Color3.fromRGB(255, 225, 90)
local portalColorDark = Color3.fromRGB(210, 145, 10)

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
-- MODEL (оригинальная модель Evil Morty)
--==================================================

local PARTS = {
	{ Name = "Part", Size = Vector3.new(0.272445,0.197322,0.227038),
		CFrame = CFrame.new(1.11402,1.00547,-10.9034, 1,0,0, 0,0,-1, 0,1,0),
		Color = Color3.fromRGB(99,95,98), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.272445,0.24273,0.454076),
		CFrame = CFrame.new(1.06861,1.119,-11.1986, 1,0,0, 0,0,-1, 0,1,0),
		Color = Color3.fromRGB(213,115,61), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.272445,0.197322,0.227038),
		CFrame = CFrame.new(1.06861,1.119,-10.6442, 1,0,0, 0,0,-1, 0,1,0),
		Color = Color3.fromRGB(99,95,98), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.454076,2.13416,0.36326),
		CFrame = CFrame.new(1.06861,0.823826,-10.5174, 1,0,0, 0,0,-1, 0,1,0),
		Color = Color3.fromRGB(255,176,0), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.590298,0.908151,0.0908151),
		CFrame = CFrame.new(1.06861,1.20982,-10.3371, 0,1,0, 0.707107,0,0.707107, 0.707107,0,-0.707107),
		Color = Color3.fromRGB(213,115,61), Shape = "Cylinder" },
	{ Name = "Handle", Size = Vector3.new(0.454076,0.908151,0.454077),
		CFrame = CFrame.new(1.06861,0.454076,-10.8823, 1,0,0, 0,0.707107,-0.707107, 0,0.707107,0.707107),
		Color = Color3.fromRGB(255,176,0), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.23219,0.136223,0.0454076),
		CFrame = CFrame.new(0.932386,0.560068,-10.3782, 0,0,-1, -0.707107,0.707107,0, 0.707107,0.707107,0),
		Color = Color3.fromRGB(255,176,0), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.908151,0.908151,0.227038),
		CFrame = CFrame.new(1.02154,1.20982,-10.0633, 0,1,0, 0.965926,0,-0.258819, -0.258819,0,-0.965926),
		Color = Color3.fromRGB(255,255,0), Shape = "Cylinder" },
	{ Name = "Part", Size = Vector3.new(0.0537722,0.908151,0.358481),
		CFrame = CFrame.new(1.02154,1.62249,-10.1739, 0,1,0, 0.965926,0,-0.258819, -0.258819,0,-0.965926),
		Color = Color3.fromRGB(255,255,0), Shape = "Cylinder" },
	{ Name = "Part", Size = Vector3.new(0.795168,0.726521,0.862743),
		CFrame = CFrame.new(1.06861,0.993849,-9.58647, -0,0,-1, -1,0,0, 0,1,0),
		Color = Color3.fromRGB(255,176,0), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.317853,0.317853,0.317853),
		CFrame = CFrame.new(0.728048,0.993849,-9.54345, 1,0,0, 0,1,0, 0,0,1),
		Color = Color3.fromRGB(13,105,172), Shape = "Ball" },
	{ Name = "Part", Size = Vector3.new(0.317853,0.317853,0.317853),
		CFrame = CFrame.new(1.09131,0.993845,-9.2459, 1,0,0, 0,1,0, 0,0,1),
		Color = Color3.fromRGB(255,255,0), Shape = "Ball" },
	{ Name = "Part", Size = Vector3.new(0.795168,0.862743,0.136223),
		CFrame = CFrame.new(0.705344,0.993846,-9.51836, -0,0,-1, -1,0,0, 0,1,0),
		Color = Color3.fromRGB(255,176,0), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.114055,0.862743,0.862743),
		CFrame = CFrame.new(1.06873,0.653257,-9.51836, -0,0,-1, -1,0,0, 0,1,0),
		Color = Color3.fromRGB(255,176,0), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.795168,0.862743,0.136223),
		CFrame = CFrame.new(1.43186,0.993846,-9.51836, 0,0,-1, -1,0,0, 0,1,0),
		Color = Color3.fromRGB(255,176,0), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.114055,0.862743,0.862743),
		CFrame = CFrame.new(1.06873,1.33495,-9.51836, 0,0,-1, -1,0,0, 0,1,0),
		Color = Color3.fromRGB(255,176,0), Shape = "Block" },
	{ Name = "Part", Size = Vector3.new(0.454076,0.375442,0.5),
		CFrame = CFrame.new(1.06861,0.817736,-11.8345, 0,0,1, 0,1,0, -1,0,0),
		Color = Color3.fromRGB(255,176,0), Shape = "Wedge" },
}

--==================================================
-- BACKPACK
--==================================================

local function getBackpack()
	Backpack = LocalPlayer:WaitForChild("Backpack")
	return Backpack
end

--==================================================
-- REMOVE OLD GUNS
--==================================================

local function removeOldGuns()
	local backpack = getBackpack()
	for _, container in ipairs({ backpack, LocalPlayer.Character }) do
		if container then
			for _, obj in ipairs(container:GetChildren()) do
				if obj:IsA("Tool") and (obj.Name == "Portal_Gun" or obj.Name == "EVIL_MORTY_PORTAL_GUN") then
					obj:Destroy()
				end
			end
		end
	end
end

removeOldGuns()

--==================================================
-- CLEAR GUI
--==================================================

local oldGui = PlayerGui:FindFirstChild("evil_morty_portal_GUI")
if oldGui then oldGui:Destroy() end
local oldRickGui = PlayerGui:FindFirstChild("rick_portal_GUI")
if oldRickGui then oldRickGui:Destroy() end

--==================================================
-- PORTAL CLEANUP
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
-- СЛЕДЫ НА СТЕНАХ
--==================================================

local function createWallMark(position, normal, color)
    local mark = Instance.new("Part")
    mark.Name = "PortalWallMark"
    mark.Size = Vector3.new(4, 4, 0.05)
    mark.Material = Enum.Material.Neon
    mark.Color = color
    mark.Transparency = 0.4
    mark.Anchored = true
    mark.CanCollide = false
    mark.CanTouch = false
    mark.CanQuery = false
    mark.CastShadow = false
    mark.CFrame = CFrame.lookAt(position + normal * 0.03, position + normal) * CFrame.Angles(math.rad(90), 0, 0)
    mark.Parent = workspace

    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = 0.3
    light.Range = 3
    light.Parent = mark

    local fadeStart = tick()
    local fadeDuration = 5

    RunService.Heartbeat:Connect(function(dt)
        if not mark.Parent then return end
        local elapsed = tick() - fadeStart
        if elapsed >= fadeDuration then
            mark:Destroy()
            return
        end
        local progress = elapsed / fadeDuration
        mark.Transparency = 0.4 + progress * 0.6
        light.Brightness = 0.3 * (1 - progress)
    end)
end

--==================================================
-- CREATE GUN
--==================================================

local function createGun()
	if portal_gun and portal_gun.Parent then
		return portal_gun
	end

	portal_gun = nil
	Handle = nil
	portal_sound = nil

	portal_gun = Instance.new("Tool")
	portal_gun.Name = "EVIL_MORTY_PORTAL_GUN"
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

	local liquidBase
	for _, obj in ipairs(portal_gun:GetChildren()) do
		if obj:IsA("Part") and obj ~= Handle and obj.Shape == Enum.PartType.Cylinder then
			if obj.Color == Color3.fromRGB(255, 255, 0) then
				liquidBase = obj
				break
			end
		end
	end

	if liquidBase then
		local liquid = Instance.new("Part")
		liquid.Name = "AnimatedEvilMortyLiquid"
		liquid.Shape = Enum.PartType.Cylinder
		liquid.Size = Vector3.new(0.12, 0.22, 0.12)
		liquid.Color = portalColor
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
		liquidLight.Color = portalColorLight
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
	flash.Color = portalColorLight
	flash.Size = Vector3.new(0.35, 0.35, 0.35)
	flash.Transparency = 0
	flash.CanCollide = false
	flash.CanTouch = false
	flash.CanQuery = false
	flash.Anchored = true
	flash.CFrame = Handle.CFrame * CFrame.new(0, 0, -0.9)
	flash.Parent = workspace

	local light = Instance.new("PointLight")
	light.Color = portalColorLight
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
	beam.Color = portalColor
	beam.Size = Vector3.new(0.18, 0.18, distance)
	beam.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
	beam.Parent = workspace

	local light = Instance.new("PointLight")
	light.Color = portalColorLight
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
-- CREATE PORTAL (ЖИВОЙ ПОРТАЛ С ПУЛЬСАЦИЕЙ)
--==================================================

local function create_portal(position, lookDirection, surfaceNormal, hitPart)
	local portal = Instance.new("Part")
	portal.Name = "EvilMortyGoldenPortal"
	portal.Size = Vector3.new(0.6, 0.6, 0.6)
	portal.Transparency = 1
	portal.Anchored = (hitPart == nil)
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

	if hitPart then
		local weld = Instance.new("Weld")
		weld.Name = "PortalAttachmentWeld"
		weld.Part0 = hitPart
		weld.Part1 = portal
		local relativeCF = hitPart.CFrame:Inverse() * portal.CFrame
		weld.C0 = relativeCF
		weld.Parent = portal
	end

	local surface = Instance.new("Part")
	surface.Name = "PortalTextureSurface"
	surface.Transparency = 1
	surface.Anchored = true
	surface.CanCollide = false
	surface.CanTouch = false
	surface.CanQuery = false
	surface.CastShadow = false
	surface.CFrame = portal.CFrame
	surface.Parent = portal

	local FULL_SIZE = Vector3.new(9.3, 9.3, 0.06)
	surface.Size = Vector3.new(0.15, 0.15, 0.04)
	surface.Parent = portal

	local front = Instance.new("Decal")
	front.Name = "PortalTextureFront"
	front.Face = Enum.NormalId.Front
	front.Texture = PORTAL_TEXTURE
	front.Color3 = portalColor
	front.Transparency = 0
	front.Parent = surface

	local back = Instance.new("Decal")
	back.Name = "PortalTextureBack"
	back.Face = Enum.NormalId.Back
	back.Texture = PORTAL_TEXTURE
	back.Color3 = portalColor
	back.Transparency = 0
	back.Parent = surface

	local light = Instance.new("PointLight")
	light.Name = "SoftPortalLight"
	light.Color = portalColorLight
	light.Brightness = 0.2
	light.Range = 8
	light.Shadows = false
	light.Parent = surface

	local attachment = Instance.new("Attachment")
	attachment.Name = "EvilMortyPortalAttachment"
	attachment.Parent = surface

	local particles = Instance.new("ParticleEmitter")
	particles.Name = "PortalParticles"
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Color = ColorSequence.new(portalColor)
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

	-- ЖИВАЯ ПУЛЬСАЦИЯ (размер + яркость)
	local pulseTime = 0
	local initialSize = FULL_SIZE
	local initialBrightness = 1.8

	task.spawn(function()
		while portal and portal.Parent do
			pulseTime += 0.03
			local pulse = (math.sin(pulseTime * 2.5) + 1) / 2  -- 0..1
			local scale = 0.92 + pulse * 0.08  -- 0.92..1.0
			local newSize = Vector3.new(initialSize.X * scale, initialSize.Y * scale, initialSize.Z)
			surface.Size = newSize
			light.Brightness = initialBrightness * (0.8 + pulse * 0.2)
			front.Transparency = 0.02 + pulse * 0.06
			back.Transparency = 0.02 + pulse * 0.06
			task.wait(0.03)
		end
	end)

	rotationConnection = RunService.RenderStepped:Connect(function(dt)
		if not portal or not portal.Parent then
			if rotationConnection then rotationConnection:Disconnect() end
			return
		end
		rotation += dt * 0.65
		surface.CFrame = portal.CFrame * CFrame.Angles(0, 0, rotation)
	end)

	playPortalSpawnSound(portal)
	return portal
end

--==================================================
-- TWO WAY TELEPORT (БЕЗ ЭФФЕКТОВ, С УСКОРЕНИЕМ И СЛЕДАМИ)
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

		-- Создаём след на входе
		if entrance.Parent then
			local entrancePos = entrance.Position
			local entranceNormal = entrance.CFrame.LookVector
			createWallMark(entrancePos, entranceNormal, portalColor)
		end

		-- Телепортируем
		local destinationCF = destination.CFrame
		hrp.CFrame = destinationCF * CFrame.new(0, 0, -4)

		-- УСКОРЕНИЕ ПРИ ВЫХОДЕ (импульс в направлении портала)
		local impulseDirection = destination.CFrame.LookVector
		local impulseStrength = 30
		hrp.AssemblyLinearVelocity = impulseDirection * impulseStrength
		hrp.AssemblyAngularVelocity = Vector3.zero

		-- Создаём след на выходе
		if destination.Parent then
			local destPos = destination.Position
			local destNormal = destination.CFrame.LookVector
			createWallMark(destPos, destNormal, portalColor)
		end

		task.delay(0.7, function()
			teleportDebounce = false
		end)
	end)
end

--==================================================
-- PORTAL PAIR (с передачей hitPart)
--==================================================

local function createPortalPair(pointDataA, pointDataB)
	clearAllPortals()

	portalA = create_portal(pointDataA.Position, nil, pointDataA.Normal, pointDataA.HitPart)
	portalB = create_portal(pointDataB.Position, nil, pointDataB.Normal, pointDataB.HitPart)

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
-- ФУНКЦИЯ ПРОВЕРКИ ЭКИПИРОВКИ ПУШКИ
--==================================================

local function isGunEquipped()
    return portal_gun and portal_gun.Parent == LocalPlayer.Character
end

--==================================================
-- GUI (горизонтальный, сверху)
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "evil_morty_portal_GUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

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

-- Кнопки режимов
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

--==================================================
-- ПОЛЗУНОК ВЫБОРА ЦВЕТА
--==================================================

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0, 500, 0, 8)
sliderBg.Position = UDim2.new(0.5, -250, 0, 65)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderBg.BackgroundTransparency = 0.3
sliderBg.BorderSizePixel = 0
sliderBg.Parent = frame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 4)
sliderCorner.Parent = sliderBg

local sliderIndicator = Instance.new("Frame")
sliderIndicator.Size = UDim2.new(0, 16, 0, 16)
sliderIndicator.Position = UDim2.new(0, 0, 0.5, -8)
sliderIndicator.BackgroundColor3 = portalColor
sliderIndicator.BorderSizePixel = 0
sliderIndicator.Parent = sliderBg

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(1, 0)
indicatorCorner.Parent = sliderIndicator

local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(0, 80, 0, 20)
colorLabel.Position = UDim2.new(1, -90, 0.5, -10)
colorLabel.BackgroundTransparency = 1
colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
colorLabel.Text = "#FFC323"
colorLabel.TextScaled = true
colorLabel.Font = Enum.Font.Gotham
colorLabel.Parent = sliderBg

--==================================================
-- ЛОГИКА ПОЛЗУНКА
--==================================================

local dragging = false
local sliderValue = 0.12

local function updateColorFromSlider(value)
    sliderValue = math.clamp(value, 0, 1)
    local hue = sliderValue * 0.85
    local color = Color3.fromHSV(hue, 1, 1)
    portalColor = color
    portalColorLight = Color3.fromHSV(hue, 1, 0.9)
    portalColorDark = Color3.fromHSV(hue, 1, 0.4)

    sliderIndicator.BackgroundColor3 = portalColor
    colorLabel.Text = string.format("#%02X%02X%02X", portalColor.R*255, portalColor.G*255, portalColor.B*255)
    input.BorderColor3 = portalColor
    fireButton.BackgroundColor3 = portalColorDark
    hud.TextColor3 = portalColorLight
end

updateColorFromSlider(0.12)

sliderIndicator.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

sliderIndicator.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position
        local sliderAbsPos = sliderBg.AbsolutePosition
        local sliderSize = sliderBg.AbsoluteSize
        local relativeX = math.clamp((mousePos.X - sliderAbsPos.X) / sliderSize.X, 0, 1)
        updateColorFromSlider(relativeX)
        sliderIndicator.Position = UDim2.new(relativeX, -8, 0.5, -8)
    end
end)

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mousePos = input.Position
        local sliderAbsPos = sliderBg.AbsolutePosition
        local sliderSize = sliderBg.AbsoluteSize
        local relativeX = math.clamp((mousePos.X - sliderAbsPos.X) / sliderSize.X, 0, 1)
        updateColorFromSlider(relativeX)
        sliderIndicator.Position = UDim2.new(relativeX, -8, 0.5, -8)
    end
end)

--==================================================
-- КНОПКИ БЫСТРОГО ВЫБОРА ЦВЕТА
--==================================================

local function createColorButton(text, color, posX, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 28)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = UDim2.new(0.5, -10, 0.5, -10)
    circle.BackgroundColor3 = color
    circle.BorderSizePixel = 0
    circle.Parent = btn
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    end)

    btn.Activated:Connect(function()
        portalColor = color
        portalColorLight = Color3.new(
            math.min(1, color.R * 1.2),
            math.min(1, color.G * 1.2),
            math.min(1, color.B * 1.2)
        )
        portalColorDark = Color3.new(
            color.R * 0.6,
            color.G * 0.6,
            color.B * 0.6
        )
        sliderIndicator.BackgroundColor3 = portalColor
        colorLabel.Text = string.format("#%02X%02X%02X", portalColor.R*255, portalColor.G*255, portalColor.B*255)
        input.BorderColor3 = portalColor
        fireButton.BackgroundColor3 = portalColorDark
        hud.TextColor3 = portalColorLight

        local h, s, v = Color3.toHSV(portalColor)
        local sliderPos = h / 0.85
        sliderValue = math.clamp(sliderPos, 0, 1)
        sliderIndicator.Position = UDim2.new(sliderValue, -8, 0.5, -8)
    end)

    return btn
end

local greenColor = Color3.fromRGB(0, 255, 65)
local yellowColor = Color3.fromRGB(255, 195, 35)
local blueColor = Color3.fromRGB(0, 120, 255)

createColorButton("", greenColor, 10, 95)
createColorButton("", yellowColor, 80, 95)
createColorButton("", blueColor, 150, 95)

--==================================================
-- POINT SELECTION
--==================================================

local function startPointSelection()
	if currentMode ~= "POINT" then return end

	clearPointSelection()
	pointSelecting = true
	pointStage = 1

	hud.Text = "TAP / CLICK → SET POINT A"
end

local function setPoint(position, normal, hitPart)
	if currentMode ~= "POINT" then return end
	if not pointSelecting then return end

	if pointStage == 1 then
		pointA = { Position = position, Normal = normal, HitPart = hitPart }
		pointStage = 2

		local muzzlePos = muzzleFlash()
		if muzzlePos then
			createBeam(muzzlePos, position)
		end
		if portal_sound then portal_sound:Play() end

		hud.Text = "POINT A SET → TAP / CLICK POINT B"
		return
	end

	if pointStage == 2 then
		pointB = { Position = position, Normal = normal, HitPart = hitPart }

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

		hud.Text = "PORTALS READY → ENTER ONE"
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

	local entrance = create_portal(frontPosition, hrp.CFrame.LookVector, nil, nil)
	local destination = create_portal(targetPosition, -targetHRP.CFrame.LookVector, nil, nil)

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
	local portal = create_portal(position, hrp.CFrame.LookVector, nil, nil)
	portalA = portal

	portal.Touched:Connect(function(hit)
		if teleportDebounce then return end

		local currentCharacter = LocalPlayer.Character
		if not currentCharacter then return end
		if not hit:IsDescendantOf(currentCharacter) then return end

		teleportDebounce = true
		if portal_sound then portal_sound:Play() end

		-- Убираем эффект, только перемещаем
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
		hud.Text = "POINT: FIRE → A → B"
		input.PlaceholderText = "Point mode"
	elseif mode == "PLAYER" then
		hud.Text = "PLAYER: ENTER NAME → FIRE"
		input.PlaceholderText = "Player name"
	elseif mode == "PLACE" then
		hud.Text = "PLACE: ENTER ID → FIRE"
		input.PlaceholderText = "Place ID"
	end
end

--==================================================
-- FIRE
--==================================================

local function fire()
	if currentMode == "PLAYER" then
		if input.Text == "" then
			hud.Text = "ENTER PLAYER NAME"
			return
		end

		local success = firePlayerPortal(input.Text)
		hud.Text = success and "ENTER THE PORTAL" or "PLAYER NOT FOUND"
		return
	end

	if currentMode == "PLACE" then
		if input.Text == "" then
			hud.Text = "ENTER PLACE ID"
			return
		end

		local success = firePlacePortal(input.Text)
		hud.Text = success and "ENTER THE PORTAL" or "INVALID PLACE ID"
		return
	end

	if currentMode == "POINT" then
		if not pointSelecting then
			startPointSelection()
		else
			hud.Text = "TAP / CLICK SCREEN TO SET POINT"
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
	mobileButton.BackgroundColor3 = portalColorDark
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
-- MOBILE POINT
--==================================================

if UserInputService.TouchEnabled then
	UserInputService.TouchTap:Connect(function(touchPositions, processed)
		if processed then return end
		if currentMode ~= "POINT" then return end
		if not pointSelecting then return end

		if not isGunEquipped() then
			hud.Text = "EQUIP THE GUN TO PLACE PORTAL"
			return
		end

		local touch = touchPositions[1]
		if not touch then return end

		local result = raycastFromScreen(touch)
		if not result then
			hud.Text = "NO TARGET"
			return
		end

		setPoint(result.Position, result.Normal, result.Instance)
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

		if not isGunEquipped() then
			hud.Text = "EQUIP THE GUN TO PLACE PORTAL"
			return
		end

		local mousePosition = UserInputService:GetMouseLocation()
		local result = raycastFromScreen(mousePosition)
		if not result then
			hud.Text = "NO TARGET"
			return
		end

		setPoint(result.Position, result.Normal, result.Instance)
	end)
end

--==================================================
-- УЛУЧШЕННЫЙ ПРИЦЕЛ (ЛИНИЯ + МАРКЕР, БЕЗ КРУГА)
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
		aimLine.Color = portalColor
		aimLine.Size = Vector3.new(0.06, 0.06, distance)
		aimLine.CFrame = CFrame.lookAt(origin, targetPos) * CFrame.new(0, 0, -distance / 2)
		aimLine.Transparency = 0.3
		aimLine.Parent = workspace

		local light = Instance.new("PointLight")
		light.Color = portalColorLight
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
	aimMarker.Color = portalColor
	aimMarker.Size = Vector3.new(0.2, 0.2, 0.2)
	aimMarker.Transparency = 0.2
	aimMarker.CFrame = CFrame.new(targetPos + normal * 0.02)
	aimMarker.Parent = workspace

	local markerLight = Instance.new("PointLight")
	markerLight.Color = portalColorLight
	markerLight.Brightness = 1.5
	markerLight.Range = 4
	markerLight.Parent = aimMarker
end

RunService.RenderStepped:Connect(function()
	updateAimVisuals()
end)

--==================================================
-- RESET
--==================================================

resetButton.Activated:Connect(function()
	clearAllPortals()
	hud.Text = "PORTALS RESET"
end)

--==================================================
-- GIVE GUN
--==================================================

local function giveGun()
	local backpack = getBackpack()

	for _, obj in ipairs(backpack:GetChildren()) do
		if obj:IsA("Tool") and obj.Name == "EVIL_MORTY_PORTAL_GUN" and obj ~= portal_gun then
			obj:Destroy()
		end
	end

	if LocalPlayer.Character then
		for _, obj in ipairs(LocalPlayer.Character:GetChildren()) do
			if obj:IsA("Tool") and obj.Name == "EVIL_MORTY_PORTAL_GUN" and obj ~= portal_gun then
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
-- RESPAWN SAFE
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

	hud.Text = "POINT: FIRE → TAP A → TAP B"
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
        hud.Visible = menuOpen
        menuToggle.Text = menuOpen and "✕" or "☰"
    end
end)

--==================================================
-- ВЫГРУЗКА ПО F1
--==================================================

local unloadKey = Enum.KeyCode.F1
local shouldUnload = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == unloadKey then
        shouldUnload = true
        clearAllPortals()
        if gui then gui:Destroy() end
        if portal_gun then portal_gun:Destroy() end
        if portal_sound then portal_sound:Destroy() end
        Handle = nil
        print("Portal gun unloaded. Press F1 again to reload script.")
    end
end)

--==================================================
-- ТЕНЕВОЙ ШАГ (по нажатию Q)
-- Телепорт за спину ближайшему игроку
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode ~= Enum.KeyCode.Q then return end  -- клавиша Q

    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Ищем ближайшего игрока (кроме себя)
    local nearestPlayer = nil
    local minDist = 30  -- радиус поиска

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local pHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if pHRP then
                local dist = (pHRP.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearestPlayer = player
                end
            end
        end
    end

    if not nearestPlayer then
        -- Можно добавить сообщение в HUD, если хотите
        return
    end

    local attackerHRP = nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not attackerHRP then return end

    -- Позиция за спиной атакующего (в 3 стопах позади)
    local behindPos = attackerHRP.Position - attackerHRP.CFrame.LookVector * 3
    behindPos = Vector3.new(behindPos.X, hrp.Position.Y, behindPos.Z)  -- сохраняем высоту

    -- Визуальный эффект (вспышка в точке ухода)
    local flash1 = Instance.new("Part")
    flash1.Shape = Enum.PartType.Ball
    flash1.Size = Vector3.new(2, 2, 2)
    flash1.Material = Enum.Material.Neon
    flash1.Color = Color3.fromRGB(80, 80, 255)  -- тёмно-синий
    flash1.Transparency = 0.3
    flash1.Anchored = true
    flash1.CanCollide = false
    flash1.CFrame = hrp.CFrame
    flash1.Parent = workspace
    TweenService:Create(flash1, TweenInfo.new(0.4), {Transparency = 1, Size = Vector3.new(5, 5, 5)}):Play()
    task.delay(0.5, function() flash1:Destroy() end)

    -- Телепортируем
    hrp.CFrame = CFrame.new(behindPos, behindPos + attackerHRP.CFrame.LookVector)

    -- Визуальный эффект в точке появления
    local flash2 = Instance.new("Part")
    flash2.Shape = Enum.PartType.Ball
    flash2.Size = Vector3.new(2, 2, 2)
    flash2.Material = Enum.Material.Neon
    flash2.Color = Color3.fromRGB(100, 100, 255)
    flash2.Transparency = 0.2
    flash2.Anchored = true
    flash2.CanCollide = false
    flash2.CFrame = hrp.CFrame
    flash2.Parent = workspace
    TweenService:Create(flash2, TweenInfo.new(0.4), {Transparency = 1, Size = Vector3.new(5, 5, 5)}):Play()
    task.delay(0.5, function() flash2:Destroy() end)

    -- Звук
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://1013378689"  -- можно заменить
    sound.Volume = 1.5
    sound.Parent = hrp
    sound:Play()
    task.delay(1, function() sound:Destroy() end)
end)

while not shouldUnload do
    task.wait()
end

return
