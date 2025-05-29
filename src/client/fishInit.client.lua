local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")

local remotes = rs:WaitForChild("Remotes")
local pkgs = rs:WaitForChild("Pkgs")
local shared = rs:WaitForChild("Shared")

local networkStructs = require(shared.networkStructs)
local squash = require(pkgs.squash)
local systems = script.Parent.systems
local fishAssetBuilder = require(systems.fishAssetBuilder)

local fishStates = {}

remotes.CreateFish.OnClientEvent:Connect(function(fishData, entityID)
    fishAssetBuilder.create(fishData, entityID)
end)

remotes.UpdateFish.OnClientEvent:Connect(function(buf : buffer)
    local cursor = squash.frombuffer(buf)
    local cframes = {}
    local ids = {}
    while cursor.Pos ~= 0 do
        local data = networkStructs.fishSerdes.des(cursor)
        table.insert(ids, data.id)
        table.insert(cframes, data.cframe)

        -- if not fishStates[data.id] then
        --     fishStates[data.id] = {
        --         current = data.cframe,
        --         target = data.cframe
        --     }
        -- else
        --     fishStates[data.id].current = fishAssetBuilder.getFishCFrame(data.id)
        --     fishStates[data.id].target = data.cframe
        -- end
    end

    fishAssetBuilder.updateFlock(ids, cframes)
end)

rns.RenderStepped:Connect(function(dt)
    for id, state in fishStates do
        fishAssetBuilder.updateFish(id, state.target)
    end
end)