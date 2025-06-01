local rs = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")

local assets = rs:WaitForChild("Assets")
local fishes = assets.Fishes

local system = {}

function system.create(fishData, entityID : number, weight : number, growthTime : number)
    if workspace.Fishes:FindFirstChild(entityID) then return end
    local fish : BasePart = fishes[fishData.name]:Clone()
    fish.Name = tostring(entityID)
    fish.Parent = workspace.Fishes

    -- Temp for testing only!
    local scaled = math.clamp(math.log10(weight + 1), 0.5, 3)
    fish.Size = (fish.Size / 1.5) * scaled
    ts:Create(fish, TweenInfo.new(growthTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = fish.Size * 5}):Play()

    local statsGUI = assets.UI.Stats:Clone()
    statsGUI.Parent = fish
    statsGUI.Title.Text = fishData.name
    statsGUI.Growth.Text = "0%"

    task.spawn(function()
        local startTime = tick()
        while tick() - startTime < growthTime do
            local elapsed = tick() - startTime
            local progress = math.clamp(elapsed / growthTime, 0, 1)
            statsGUI.Growth.Text = string.format("%d%%", progress * 100)
            task.wait(0.1)
        end
        statsGUI.Growth.Text = "["..fishData.name.."]"
        statsGUI.Title.Text = "Collect!"
    end)
end

function system.updateFish(entityID : number, cframe : CFrame)
    local fish : BasePart = workspace.Fishes:FindFirstChild(entityID)
    if not fish then
        return
    end

    fish.CFrame = cframe
end

function system.updateFlock(entityIDs : {number}, cframes : {CFrame})
    local parts = {}
    local validCFs = {}

    for i, id in ipairs(entityIDs) do
        local fish : BasePart = workspace.Fishes:FindFirstChild(id)
        if not fish then continue end

        table.insert(parts, fish)
        table.insert(validCFs, cframes[i])
    end

    workspace:BulkMoveTo(parts, validCFs)
end

function system.getFishCFrame(entityID : number) : CFrame
    local fish : BasePart = workspace.Fishes:FindFirstChild(entityID)
    if not fish then
        return CFrame.identity
    end

    return fish.CFrame
end

return system