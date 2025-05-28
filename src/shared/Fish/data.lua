local rs = game:GetService("ReplicatedStorage")
local shared = rs:WaitForChild("Shared")
local components = require(shared.jecs_components)

return table.freeze({
    [components.tuna] = {
        name = "Tuna"
    },
    [components.salmon] = {
        name = "Salmon"
    },
    [components.cod] = {
        name = "Cod"
    }
})