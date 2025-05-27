local rs = game:GetService("ReplicatedStorage")
local shared = rs:WaitForChild("Shared")
local world = require(shared.jecs_world)
local compoennts = require(shared.jecs_components)

local system = {}

function system.create(intialCFrame : CFrame, initialVelocity : vector, maxSpeed : number)
    local fish = world:entity()
    world:set(fish, compoennts.CFrame, intialCFrame)
    world:set(fish, compoennts.Velocity, initialVelocity)
    world:set(fish, compoennts.MaxSpeed, maxSpeed)
    world:add(fish, compoennts.fish)

    return fish
end

return system