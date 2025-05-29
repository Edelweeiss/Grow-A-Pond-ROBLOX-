local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")

local remotes = rs:WaitForChild("Remotes")
local shared = rs:WaitForChild("Shared")

local systems = script.Parent.systems
local fishAssetBuilder = require(systems.fishAssetBuilder)
local fishSystem = require(shared.Fish.fish)
local fishesData = require(shared.Fish.data)
local components = require(shared.jecs_components)
local fishGroupSystem = require(shared.Fish.fish_group)
local world = require(shared.jecs_world)

remotes.CreateFish.OnClientEvent:Connect(function(fishType, entityID, vel, cframe, maxSpeed)
    fishSystem.create(fishType, cframe, vel, maxSpeed)
    fishAssetBuilder.create(fishesData[fishType], entityID)
end)

local lastSim = os.clock()
local simulationInterval = 0.01

rns.PostSimulation:Connect(function(dt)
    if os.clock() - lastSim < simulationInterval then return end
    lastSim = os.clock()

    fishGroupSystem.solve(components.tuna, dt)

    for fish, fishCFrame in world:query(components.CFrame, components.Velocity):with(components.fish):with(components.tuna):iter() do
        fishAssetBuilder.updateFish(fish, fishCFrame)
    end
end)