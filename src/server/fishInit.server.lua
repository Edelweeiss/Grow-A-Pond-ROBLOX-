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
local fishesData = require(shared.Fish.data)
local components = require(shared.jecs_components)
local world = require(shared.jecs_world)

local remotes = rs:WaitForChild("Remotes")

local fishes = {
    [components.tuna] = {},
    [components.salmon] = {},
    [components.cod] = {}
}

local MAX_FISHES = 300
local BATCH_SIZE = math.floor(MAX_FISHES/3)

for i=1,MAX_FISHES do
    local vel = vector.create(math.random(-10,10), math.random(-10,10), math.random(-10,10))
    local cframe = CFrame.new(0,10,0)
    local id = fishSystem.create(components.tuna, cframe, vel, math.random(5, 20))
    table.insert(fishes[components.tuna], id)
    remotes.CreateFish:FireAllClients(fishesData[components.tuna], id) -- Build asset
    task.wait()
end

players.PlayerAdded:Connect(function(player)
    for type, fishTypes in fishes do
        for _, fish in fishTypes do
            remotes.CreateFish:FireAllClients(fishesData[type], fish) -- Build asset
            task.wait()
        end
    end
end)

local lastSim = os.clock()
local lastRender = os.clock()
local simulationInterval = 0.01
local renderingInterval = 0.1

local cursor = squash.cursor()

task.delay(2, function()
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

        for fish, fishCFrame : CFrame in world:query(components.CFrame, components.Velocity):with(components.fish):with(components.tuna) do
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
end)