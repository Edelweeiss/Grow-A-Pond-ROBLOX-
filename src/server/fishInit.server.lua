local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")
local players = game:GetService("Players")

local shared = rs:WaitForChild("Shared")
local pkgs = rs:WaitForChild("Pkgs")
local networkStructs = require(shared.networkStructs)
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

for i=1,100 do
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
local renderingInterval = 0.08

local dirThreshold = math.cos(math.rad(20))
local velThreshold = 3.0

local cursor = squash.cursor()

function findOrCreateGroup(fishes, cframe : CFrame, velocity : vector)
    for _, group in fishes do
        if cframe.LookVector:Dot(group.LookVector) > (1 - dirThreshold) and (group.velocity - velocity).Magnitude < velThreshold then
            return group
        end
    end

    local newGroup = {
        LookVector = cframe.LookVector,
        velocity = velocity,
        members = {}
    }
    table.insert(fishes, newGroup)
    return newGroup
end

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

        for fish, fishCFrame : CFrame, fishVelocity : vector in world:query(components.CFrame, components.Velocity):with(components.fish):with(components.tuna) do
            local group = findOrCreateGroup(fishes, fishCFrame, fishVelocity)
            table.insert(group.members, {
                id = fish,
                cframe = fishCFrame
            })
        end

        for _, group in fishes do
            local buffers = {}

            for _, fish in group.members do
                networkStructs.fishSerdes.ser(cursor, {
                    id = fish.id,
                    cframe = fish.cframe
                })
                table.insert(buffers, squash.tobuffer(cursor))
                cursor.Pos = 0
            end

            remotes.UpdateFish:FireAllClients(buffers)
        end
    end)
end)