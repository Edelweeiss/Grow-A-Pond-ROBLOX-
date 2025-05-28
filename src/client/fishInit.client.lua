local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("Remotes")
local pkgs = rs:WaitForChild("Pkgs")
local shared = rs:WaitForChild("Shared")

local networkStructs = require(shared.networkStructs)
local squash = require(pkgs.squash)
local systems = script.Parent.systems
local fishAssetBuilder = require(systems.fishAssetBuilder)

remotes.CreateFish.OnClientEvent:Connect(function(fishData, entityID)
    fishAssetBuilder.create(fishData, entityID)
end)

remotes.UpdateFish.OnClientEvent:Connect(function(buf : buffer)
    local cursor = squash.frombuffer(buf)
    local data = networkStructs.fishSerdes.des(cursor)
    fishAssetBuilder.updateFish(data.fishType, data.id, data.cframe)
end)