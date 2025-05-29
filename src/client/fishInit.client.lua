local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")

local remotes = rs:WaitForChild("Remotes")
local pkgs = rs:WaitForChild("Pkgs")
local shared = rs:WaitForChild("Shared")

local network = require(shared.network)
local networkStructs = require(shared.networkStructs)
local squash = require(pkgs.squash)
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

remotes.UpdateFish.OnClientEvent:Connect(function(buf : buffer)
    local cursor = squash.frombuffer(buf)
    local cframes = {}
    local ids = {}
    while cursor.Pos ~= 0 do
        local data = networkStructs.fishSerdes.des(cursor)
        table.insert(ids, data.id)
        table.insert(cframes, network.DecompressCFrame(data.position, data.yaw8))
    end

    fishAssetBuilder.updateFlock(ids, cframes)
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