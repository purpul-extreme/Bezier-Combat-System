local CameraShake = {}

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

function CameraShake.Shake(intensity, duration)
	local startTime = tick()
	local connection

	connection = RunService.RenderStepped:Connect(function()
		local elapsed = tick() - startTime
		if elapsed > duration then
			connection:Disconnect()
			return
		end

		local shakeAmount = intensity * ((duration - elapsed) / duration)
		local offset = Vector3.new(
			math.random() - 0.5,
			math.random() - 0.5,
			math.random() - 0.5
		) * 2 * shakeAmount

		camera.CFrame = camera.CFrame * CFrame.new(offset)
	end)
end

--Presets
function CameraShake.Explosion()
	CameraShake.Shake(1.5, 0.5)
end

function CameraShake.Impact()
	CameraShake.Shake(0.7, 0.3)
end

function CameraShake.Earthquake()
	CameraShake.Shake(0.4, 2)
end

return CameraShake
