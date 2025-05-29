local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")
local players = game:GetService("Players")

local shared = rs:WaitForChild("Shared")
local fishSystem = require(shared.Fish.fish)
local fishGroupSystem = require(shared.Fish.fish_group)
local components = require(shared.jecs_components)
local world = require(shared.jecs_world)

local remotes = rs:WaitForChild("Remotes")

local fishes = {
    [components.tuna] = {},
    [components.salmon] = {},
    [components.cod] = {}
}

local MAX_FISHES = 300

for i=1,MAX_FISHES do
    local vel = vector.create(math.random(-10,10), math.random(-10,10), math.random(-10,10))
    local cframe = CFrame.new(0,10,0)
    local maxSpeed = math.random(5, 20)
    local id = fishSystem.create(components.tuna, cframe, vel, maxSpeed)
    table.insert(fishes[components.tuna], id)
    remotes.CreateFish:FireAllClients(components.tuna, id, vel, cframe, maxSpeed) -- Build asset
end

players.PlayerAdded:Connect(function(player)
    for fishType, fishTypes in fishes do
        for _, fish in fishTypes do
            local vel = world:get(fish, components.Velocity)
            local cframe = world:get(fish, components.CFrame)
            local maxSpeed = world:get(fish, components.MaxSpeed)
            remotes.CreateFish:FireAllClients(fishType, fish, vel, cframe, maxSpeed) -- Build asset
            task.wait()
        end
    end
end)

local lastSim = os.clock()
local simulationInterval = 0.01

rns.PostSimulation:Connect(function(dt)
    if os.clock() - lastSim < simulationInterval then return end
    lastSim = os.clock()

    fishGroupSystem.solve(components.tuna, dt)
end)