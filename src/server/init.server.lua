local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")
local shared = rs:WaitForChild("Shared")
local fishSystem = require(shared.Fish.fish)
local fishGroupSystem = require(shared.Fish.fish_group)
local components = require(shared.jecs_components)
local world = require(shared.jecs_world)

local fishParts : {Part} = workspace:FindFirstChild("Fishes")

for i=1,5 do
    local vel = vector.create(math.random(-10,10), math.random(-10,10), math.random(-10,10))
    local id = fishSystem.create(CFrame.identity, vel, math.random(5, 20))
    fishParts[id].CFrame = CFrame.identity
end

rns.PostSimulation:Connect(function(dt)
    fishGroupSystem.solve(dt)

    -- Rendering (TODO: do it on client)
    for fish, fishVelocity : vector in world:query(components.Velocity):with(components.fish) do
        fishParts[fish].Position += fishVelocity * dt
    end
end)