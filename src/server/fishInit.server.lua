local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")

local shared = rs:WaitForChild("Shared")
local pkgs = rs:WaitForChild("Pkgs")
local networkStructs = require(shared.networkStructs)
local squash = require(pkgs.squash)
local fishSpawner = require(script.Parent.systems.FishSpawner)
local fishGroupSystem = require(shared.Fish.fish_group)
local components = require(shared.jecs_components)
local world = require(shared.jecs_world)

local remotes = rs:WaitForChild("Remotes")

local MAX_FISHES = 100
local BATCH_SIZE = math.floor(MAX_FISHES/2)

for i=1, MAX_FISHES do
    fishSpawner.Spawn(components.tuna, vector.create(math.random(-10,10),math.random(-10,10),math.random(-10,10)), CFrame.new(0,20,0), math.random(5,25))
end

local lastSim = workspace:GetServerTimeNow()
local lastRender = workspace:GetServerTimeNow()
local simulationInterval = 0.01
local renderingInterval = 3

local cursor = squash.cursor()

rns.PostSimulation:Connect(function(dt)
    if workspace:GetServerTimeNow() - lastSim < simulationInterval then return end
    lastSim = workspace:GetServerTimeNow()

    fishGroupSystem.solve(components.tuna, dt)
    fishGroupSystem.solve(components.cod, dt)
    fishGroupSystem.solve(components.salmon, dt)
end)

rns.PostSimulation:Connect(function(dt)
    if workspace:GetServerTimeNow() - lastRender < renderingInterval then return end
    lastRender = workspace:GetServerTimeNow()

    local fishes = {}
    local count = 0

    cursor.Pos = 0

    for fish, fishCFrame, fishVelocity in world:query(components.CFrame, components.Velocity):with(components.fish):iter() do
        table.insert(fishes, {
            id = fish,
            velocity = fishVelocity,
            cframe = fishCFrame
        })

        count += 1

        if count >= BATCH_SIZE then
            for _, data in fishes do
                networkStructs.fishSerdes.ser(cursor, {
                    id = data.id,
                    velocity = data.velocity,
                    cframe = data.cframe
                })
            end

            remotes.UpdateFish:FireAllClients(squash.tobuffer(cursor))
            cursor.Pos = 0
            table.clear(fishes)
            count = 0
        end
    end
end)