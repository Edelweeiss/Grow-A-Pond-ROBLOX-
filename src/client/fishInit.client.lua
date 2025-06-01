local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")

local remotes = rs:WaitForChild("Remotes")
local shared = rs:WaitForChild("Shared")
local pkgs = rs:WaitForChild("Pkgs")

local networkStructs = require(shared.networkStructs)
local squash = require(pkgs.squash)
local systems = script.Parent.systems
local fishAssetBuilder = require(systems.fishAssetBuilder)
local fishSystem = require(shared.Fish.fish)
local fishesData = require(shared.Fish.data)
local components = require(shared.jecs_components)
local fishGroupSystem = require(shared.Fish.fish_group)
local world = require(shared.jecs_world)

remotes.CreateFish.OnClientEvent:Connect(function(fishType, entityID, vel, cframe, maxSpeed, weight, growthRate)
    fishSystem.create(fishType, cframe, vel, maxSpeed)
    fishAssetBuilder.create(fishesData[fishType], entityID, weight, growthRate)
end)

local interpolatingFishes = {}
local interpolationDuration = 0.3
remotes.UpdateFish.OnClientEvent:Connect(function(buf : buffer)
    local cursor = squash.frombuffer(buf)
    while cursor.Pos ~= 0 do
        local data = networkStructs.fishSerdes.des(cursor)

        world:set(data.id, components.CFrame, data.cframe)
        world:set(data.id, components.Velocity, data.velocity)

        interpolatingFishes[data.id] = true
        task.spawn(function()
            local startCFrame = fishAssetBuilder.getFishCFrame(data.id)
            local elapsed = 0

            while elapsed < interpolationDuration do
                elapsed += task.wait()
                local alpha = math.clamp(elapsed / interpolationDuration, 0, 1)
                fishAssetBuilder.updateFish(data.id, startCFrame:Lerp(data.cframe, alpha))
            end

            interpolatingFishes[data.id] = nil
        end)
    end
end)

local lastSim = workspace:GetServerTimeNow()
local simulationInterval = 0.01

rns.PostSimulation:Connect(function(dt)
    if workspace:GetServerTimeNow() - lastSim < simulationInterval then return end
    lastSim = workspace:GetServerTimeNow()

    fishGroupSystem.solve(components.tuna, dt)
    fishGroupSystem.solve(components.cod, dt)
    fishGroupSystem.solve(components.salmon, dt)

    for fish, fishCFrame in world:query(components.CFrame, components.Velocity):with(components.fish):iter() do
        if interpolatingFishes[fish] then continue end
        fishAssetBuilder.updateFish(fish, fishCFrame)
    end
end)