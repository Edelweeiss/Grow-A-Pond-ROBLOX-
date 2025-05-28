local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("Remotes")

local systems = script.Parent.systems
local fishAssetBuilder = require(systems.fishAssetBuilder)

remotes.CreateFish.OnClientEvent:Connect(function(fishData, entityID)
    fishAssetBuilder.create(fishData, entityID)
end)

remotes.UpdateFish.OnClientEvent:Connect(function(fishCFrame, fishType, entityID)
    fishAssetBuilder.updateFish(fishType, entityID, fishCFrame)
end)