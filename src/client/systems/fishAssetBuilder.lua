local rs = game:GetService("ReplicatedStorage")

local assets = rs:WaitForChild("Assets")
local fishes = assets.Fishes

local system = {}

function system.create(fishData, entityID : number)
    local fish : BasePart = fishes[fishData.name]:Clone()
    fish.Name = tostring(entityID)
    fish.Parent = workspace.Fishes[fishData.name]
end

function system.updateFish(fishType : string, entityID : number, cframe : CFrame)
    workspace.Fishes[fishType][entityID].CFrame = cframe
end

return system