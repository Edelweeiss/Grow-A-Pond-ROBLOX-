local rs = game:GetService("ReplicatedStorage")
local shared = rs:WaitForChild("Shared")
local components = require(shared.jecs_components)

return table.freeze({
    [components.tuna] = {
        name = "Tuna",
        growthBias = 20,
        weightBias = 15
    },
    [components.salmon] = {
        name = "Salmon",
        growthBias = 25,
        weightBias = 13
    },
    [components.cod] = {
        name = "Cod",
        growthBias = 20,
        weightBias = 14
    }
})