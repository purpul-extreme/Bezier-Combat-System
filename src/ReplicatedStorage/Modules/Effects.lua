local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Modules = ReplicatedStorage.Modules
local Assets = ReplicatedStorage.Assets

local Config = require(Modules.Config)
local CameraShake = require(Modules.CameraShake)

local BaseParts = Assets.BaseParts
local Sounds = Assets.Sounds

local Effects = {}

local SHAKE_INTENSITY_DIVISOR = 25

function Effects.CreateTemporarySound(sound: Instance, parent: Instance, destroyAfter: number?)
	local newSound = sound:Clone()
	newSound.Parent = parent

	newSound:Play()
	
	if destroyAfter then
		task.delay(destroyAfter, function()
			newSound:Destroy()
		end)
	else
		newSound.Ended:Once(function()
			newSound:Destroy()
		end)
	end
end

function Effects.CreateExplosion(explosionPart: Instance, distance: number)
	local explosionAttachment = explosionPart.Attachment
	local distanceToShake = SHAKE_INTENSITY_DIVISOR / distance
	
	explosionAttachment.Core:Emit(1)
	explosionAttachment.YellowSpikes:Emit(5)
	explosionAttachment.OrangeSpikes:Emit(5)
	explosionAttachment.ExplosionsBlack:Emit(2)
	explosionAttachment.ExplosionsRed:Emit(4)
	explosionAttachment.ExplosionsOrange:Emit(12)
	explosionAttachment.Fog:Emit(16)
	
	task.delay(0.1, function()
		CameraShake.Shake(distanceToShake, 0.2)
		explosionAttachment.PointLight.Enabled = true
		
		task.delay(0.15, function()
			explosionAttachment.PointLight.Enabled = false
		end)
	end)
	
	for _ = 1, 3 do
		explosionAttachment.Sphere:Emit(1)
		task.wait(0.4)
	end
	
	Debris:AddItem(explosionPart, 4)
end

function Effects.CreateProjectile(path: {Vector3}, distance: number, latency: number, averageFrameTime: number)
	local newProjectilePart = BaseParts.Projectile:Clone()
	newProjectilePart.Position = path[1]
	newProjectilePart.Parent = workspace.Temporary
	
	local newExplosionPart = BaseParts.Explosion:Clone()
	newExplosionPart.Position = path[#path]
	newExplosionPart.Parent = workspace.Temporary
	
	local pathSize = #path
	
	local baseTimeToExplode = distance / Config.PROJECTILE_VELOCITY
	local baseSplitTweenTime = baseTimeToExplode / pathSize
	
	local averageWaitIterationsToComplete = baseSplitTweenTime / averageFrameTime
	local averageWaitingOvershoot = math.abs(averageWaitIterationsToComplete - math.round(averageWaitIterationsToComplete))
	
	local estimatedInaccuaracyTime = latency + averageWaitingOvershoot
	
	local timeToExplode = (distance / Config.PROJECTILE_VELOCITY) - estimatedInaccuaracyTime
	local splitTweenTime = timeToExplode / pathSize
	
	task.spawn(Effects.CreateTemporarySound, Sounds.Projectile, newProjectilePart, timeToExplode)
	task.spawn(Effects.CreateTemporarySound, Sounds.Throw, newProjectilePart)
	
	local actualInacuarracyTime = 0
	
	for index, targetPosition in path do
		local tweenInfo = TweenInfo.new(splitTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
		local tween = TweenService:Create(newProjectilePart, tweenInfo, {Position = targetPosition})
		tween:Play()
		tween.Completed:Wait()
	end
	
	task.spawn(Effects.CreateTemporarySound, Sounds.Explosion, newExplosionPart)
	task.spawn(Effects.CreateExplosion, newExplosionPart, distance)
	
	newProjectilePart:Destroy()
end

return Effects
