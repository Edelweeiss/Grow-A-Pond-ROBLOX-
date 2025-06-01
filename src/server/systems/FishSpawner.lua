local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local shared = rs:WaitForChild("Shared")
local fishSystem = require(shared.Fish.fish)
local components = require(shared.jecs_components)
local world = require(shared.jecs_world)

local remotes = rs:WaitForChild("Remotes")

local system = {}

local fishes = {
    [components.tuna] = {},
    [components.salmon] = {},
    [components.cod] = {}
}

function system.Spawn(fishType, vel : vector, cframe : CFrame, maxSpeed : number)
    local id = fishSystem.create(fishType, cframe, vel, maxSpeed)
    table.insert(fishes[fishType], id)
    remotes.CreateFish:FireAllClients(fishType, id, vel, cframe, maxSpeed, world:get(id, components.weight), world:get(id, components.growthTime)) -- Build asset
end

players.PlayerAdded:Connect(function(player)
    for fishType, fishTypes in fishes do
        for _, fish in fishTypes do
            local vel = world:get(fish, components.Velocity)
            local cframe = world:get(fish, components.CFrame)
            local maxSpeed = world:get(fish, components.MaxSpeed)
            local weight = world:get(fish, components.weight)
            local growthTime = world:get(fish, components.growthTime)
            remotes.CreateFish:FireAllClients(fishType, fish, vel, cframe, maxSpeed, weight, growthTime) -- Build asset
            task.wait()
        end
    end
end)

return system