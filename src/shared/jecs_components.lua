local rs = game:GetService("ReplicatedStorage")
local shared = rs:WaitForChild("Shared")
local jecs = require(rs:WaitForChild("Pkgs").jecs_nightly)
local world = require(shared.jecs_world)

local components = {}

components.CFrame = world:component() :: jecs.Entity<CFrame>
components.Velocity = world:component() :: jecs.Entity<vector>
components.MaxSpeed = world:component() :: jecs.Entity<number>

-- Fish only attribs
components.growth = world:component() :: jecs.Entity<number>
components.growthTime = world:component() :: jecs.Entity<number>
components.weight = world:component() :: jecs.Entity<number>

-- Common type
components.fish = world:component() :: jecs.Entity

-- Each type of fish has its own component tag [DOD]
components.tuna = world:component() :: jecs.Entity
components.salmon = world:component() :: jecs.Entity
components.cod = world:component() :: jecs.Entity

return components