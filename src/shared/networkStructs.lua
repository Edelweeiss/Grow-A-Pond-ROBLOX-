local rs = game:GetService("ReplicatedStorage")
local pkgs = rs:WaitForChild("Pkgs")
local squash = require(pkgs.squash)

local structs = {}

structs.fishSerdes = squash.record {
    cframe = squash.T(squash.CFrame(squash.int(1))),
    velocity = squash.T(squash.Vector3(squash.int(2))),
    id = squash.T(squash.uint(2))
}

return structs