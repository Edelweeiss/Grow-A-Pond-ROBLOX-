local rs = game:GetService("ReplicatedStorage")

local assets = rs:WaitForChild("Assets")
local fishes = assets.Fishes

local system = {}

function system.create(fishData, entityID : number)
    if workspace.Fishes:FindFirstChild(entityID) then return end
    local fish : BasePart = fishes[fishData.name]:Clone()
    fish.Name = tostring(entityID)
    fish.Parent = workspace.Fishes
end

function system.updateFish(entityID : number, cframe : CFrame)
    local fish : BasePart = workspace.Fishes:FindFirstChild(entityID)
    if not fish then
        return
    end

    fish.CFrame = cframe
end

function system.getFishCFrame(entityID : number)
    local fish : BasePart = workspace.Fishes:FindFirstChild(entityID)
    if not fish then
        return
    end

    return fish.CFrame
end

return system