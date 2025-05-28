local rs = game:GetService("ReplicatedStorage")

local assets = rs:WaitForChild("Assets")
local fishes = assets.Fishes

local system = {}

function system.create(fishData, entityID : number)
    if workspace.Fishes[fishData.name]:FindFirstChild(entityID) then return end
    local fish : BasePart = fishes[fishData.name]:Clone()
    fish.Name = tostring(entityID)
    fish.Parent = workspace.Fishes[fishData.name]
end

function system.updateFish(fishType : string, entityID : number, cframe : CFrame)
    local fish : BasePart = workspace.Fishes[fishType]:FindFirstChild(entityID)
    if not fish then
        return
    end

    fish.CFrame = cframe
end

return system