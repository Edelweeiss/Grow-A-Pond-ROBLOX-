local rs = game:GetService("ReplicatedStorage")
local pkgs = rs:WaitForChild("Pkgs")
local squash = require(pkgs.squash)

local structs = {}

structs.fishSerdes = squash.record {
    position = squash.T(squash.Vector3int16()),
    yaw8 = squash.T(squash.uint(1)),
    id = squash.T(squash.uint(2))
}

return structs