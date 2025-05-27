local rs = game:GetService("ReplicatedStorage")
local shared = rs:WaitForChild("Shared")
local jecs = require(rs:WaitForChild("Pkgs").jecs_nightly)
local world = require(shared.jecs_world)

local components = {}

components.CFrame = world:component() :: jecs.Entity<CFrame>
components.Velocity = world:component() :: jecs.Entity<vector>
components.MaxSpeed = world:component() :: jecs.Entity<number>
components.fish = world:component() :: jecs.Entity

return components