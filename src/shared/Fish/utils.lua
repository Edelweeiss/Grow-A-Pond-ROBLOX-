local utils = {}

function utils.ClampMagnitude(v : Vector3, maxLength : number)
    local mag = v.Magnitude
    if mag > maxLength then
        return v.Unit * maxLength
    else
        return v
    end
end

-- Gives all possible points the boid can check to go to for avoiding obstacles
function utils.GetDirections(numPoints : number) : {Vector3}
    local points : {Vector3} = {}
	local goldenRatio = (1 + math.sqrt(5)) / 2
	local turnFraction = math.pi * 2 * goldenRatio
    
    for i = 0, numPoints - 1 do
		local t = i / numPoints
		local inclination = math.acos(1 - 2 * t)
		local azimuth = turnFraction * i

		local x = math.sin(inclination) * math.cos(azimuth)
		local y = math.sin(inclination) * math.sin(azimuth)
		local z = math.cos(inclination)

		table.insert(points, Vector3.new(-x, -y, -z))
	end

    return points
end

return utils