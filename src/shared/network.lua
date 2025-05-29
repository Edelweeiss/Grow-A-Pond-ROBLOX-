local system = {}

local WORLD_MIN = Vector3.new(-512, 0, -512)
local RESOLUTION = 0.1

function system.CompressCFrame(cf : CFrame) : (vector, number)
    local pos = cf.Position
	local yaw = math.atan2(-cf.LookVector.X, -cf.LookVector.Z)

	local x = math.floor((pos.X - WORLD_MIN.X) / RESOLUTION)
	local y = math.floor((pos.Y - WORLD_MIN.Y) / RESOLUTION)
	local z = math.floor((pos.Z - WORLD_MIN.Z) / RESOLUTION)

	local yaw8 = math.floor((yaw % (2 * math.pi)) / (2 * math.pi) * 256 + 0.5)

	return vector.create(x, y, z), yaw8
end

function system.DecompressCFrame(posVec: vector, yaw8: number): CFrame
	local pos = vector.create(
		posVec.x * RESOLUTION + WORLD_MIN.X,
		posVec.y * RESOLUTION + WORLD_MIN.Y,
		posVec.z * RESOLUTION + WORLD_MIN.Z
	)

	local yaw = (yaw8 / 256) * (2 * math.pi)
	local rot = CFrame.Angles(0, yaw, 0)

	return rot + pos
end

return system