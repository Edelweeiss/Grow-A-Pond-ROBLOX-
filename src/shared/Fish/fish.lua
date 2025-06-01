local rs = game:GetService("ReplicatedStorage")
local jecs = require(rs:WaitForChild("Pkgs").jecs_nightly)
local shared = rs:WaitForChild("Shared")
local world = require(shared.jecs_world)
local components = require(shared.jecs_components)
local fishesData = require(shared.Fish.data)

local system = {}

function system.create(fishType : jecs.Entity, intialCFrame : CFrame, initialVelocity : vector, maxSpeed : number, id : jecs.Entity?)
    local fish = world:entity(id)
    world:set(fish, components.CFrame, intialCFrame)
    world:set(fish, components.Velocity, initialVelocity)
    world:set(fish, components.MaxSpeed, maxSpeed)
    world:add(fish, components.fish)
    world:add(fish, fishType)

    local function biasedWeight(minWeight : number, maxWeight : number, biasFactor : number)
        local r = math.random() ^ biasFactor
        return minWeight + (maxWeight - minWeight) * r
    end

    if game:GetService("RunService"):IsServer() then
        world:set(fish, components.growth, 0)
        world:set(fish, components.growthTime, biasedWeight(30, 10000, fishesData[fishType].growthBias))
        world:set(fish, components.weight, biasedWeight(0.1, 200.0, fishesData[fishType].weightBias))
    end

    return fish
end

return system