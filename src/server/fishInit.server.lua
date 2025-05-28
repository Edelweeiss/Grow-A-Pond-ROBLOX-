local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")
local players = game:GetService("Players")

local shared = rs:WaitForChild("Shared")
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
end

players.PlayerAdded:Connect(function(player)
    for type, fishTypes in fishes do
        for _, fish in fishTypes do
            remotes.CreateFish:FireAllClients(fishesData[type], fish) -- Build asset
        end
    end
end)

rns.PostSimulation:Connect(function(dt)
    fishGroupSystem.solve(components.tuna, dt)

    -- Updating client
    for fish, fishCFrame : CFrame in world:query(components.CFrame):with(components.fish) do
        remotes.UpdateFish:FireAllClients(fishCFrame, "Tuna", fish)
    end
end)