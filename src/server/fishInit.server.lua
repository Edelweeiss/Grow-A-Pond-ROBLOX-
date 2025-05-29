local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")
local players = game:GetService("Players")

local shared = rs:WaitForChild("Shared")
local pkgs = rs:WaitForChild("Pkgs")
local networkStructs = require(shared.networkStructs)
local network = require(shared.network)
local squash = require(pkgs.squash)
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

local MAX_FISHES = 100
local BATCH_SIZE = math.floor(MAX_FISHES)

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
local lastRender = os.clock()
local simulationInterval = 0.01
local renderingInterval = 3

local cursor = squash.cursor()

rns.PostSimulation:Connect(function(dt)
    if os.clock() - lastSim < simulationInterval then return end
    lastSim = os.clock()

    fishGroupSystem.solve(components.tuna, dt)
end)

rns.PostSimulation:Connect(function(dt)
    if os.clock() - lastRender < renderingInterval then return end
    lastRender = os.clock()

    local fishes = {}
    local count = 0

    cursor.Pos = 0

    for fish, fishCFrame in world:query(components.CFrame, components.Velocity):with(components.fish):with(components.tuna):iter() do
        local position, yaw8 = network.CompressCFrame(fishCFrame)

        table.insert(fishes, {
            id = fish,
            position = position,
            yaw8 = yaw8
        })

        count += 1

        if count >= BATCH_SIZE then
            for _, data in fishes do
                networkStructs.fishSerdes.ser(cursor, {
                    id = data.id,
                    position = data.position,
                    yaw8 = data.yaw8
                })
            end

            remotes.UpdateFish:FireAllClients(squash.tobuffer(cursor))
            cursor.Pos = 0
            table.clear(fishes)
            count = 0
        end
    end
end)