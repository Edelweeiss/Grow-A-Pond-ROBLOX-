local rs = game:GetService("ReplicatedStorage")
local jecs = require(rs:WaitForChild("Pkgs").jecs_nightly)
local shared = rs:WaitForChild("Shared")
local world = require(shared.jecs_world)
local components = require(shared.jecs_components)

local system = {}

function system.create(fishType : jecs.Entity, intialCFrame : CFrame, initialVelocity : vector, maxSpeed : number)
    local fish = world:entity()
    world:set(fish, components.CFrame, intialCFrame)
    world:set(fish, components.Velocity, initialVelocity)
    world:set(fish, components.MaxSpeed, maxSpeed)
    world:add(fish, components.fish)
    world:add(fish, fishType)

    return fish
end

return system