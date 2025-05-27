local rs = game:GetService("ReplicatedStorage")
local shared = rs:WaitForChild("Shared")
local world = require(shared.jecs_world)
local components = require(shared.jecs_components)

local system = {}

local ALIGMENT_COEFFCIENT = 7
local COHESION_COEFFCIENT = 5
local SEPRATION_COEFFCIENT = 10

local MAX_SPERATION_DIST = 6
local MAX_STEERING_SPEED = 30

function ClampMagnitude(v : Vector3, maxLength : number)
    local mag = v.Magnitude
    if mag > maxLength then
        return v.Unit * maxLength
    else
        return v
    end
end

function SteerTowards(v : vector, currVelocity : vector, maxSpeed : number, maxSteeringSpeed : number)
    local newV = vector.normalize(v) * maxSpeed - currVelocity
    return ClampMagnitude(newV, maxSteeringSpeed)
end

function system.solve(dt : number)
    for fish, fishCFrame : CFrame, fishVelocity : vector, fishMaxSpeed : number in world:query(components.CFrame, components.Velocity, components.MaxSpeed):with(components.fish) do
        local acceleration = vector.zero
        local direction = vector.zero

        local avgAdjPos = vector.zero
        local avgAdjDir = vector.zero
        local adjFishes = 0

        for adjFish, adjFishCFrame : CFrame, adjFishVelocity : vector in world:query(components.CFrame, components.Velocity):with(components.fish) do
            if fish == adjFish then continue end

            local disp = adjFishCFrame.Position - fishCFrame.Position
            if vector.magnitude(disp) <= MAX_SPERATION_DIST then
                direction -= disp.Unit
            end

            adjFishes += 1
            avgAdjPos += adjFishCFrame.Position
            avgAdjDir += adjFishVelocity
        end

        if adjFishes > 0 then
            avgAdjPos /= adjFishes
            avgAdjDir /= adjFishes

            local offsetFromCenter = avgAdjPos - fishCFrame.Position

            local alignmentForce = SteerTowards(avgAdjDir, fishVelocity, fishMaxSpeed, MAX_STEERING_SPEED) * ALIGMENT_COEFFCIENT
            local cohesionForce = SteerTowards(offsetFromCenter, fishVelocity, fishMaxSpeed, MAX_STEERING_SPEED) * COHESION_COEFFCIENT
            local seprationForce = SteerTowards(direction, fishVelocity, fishMaxSpeed, MAX_STEERING_SPEED) * SEPRATION_COEFFCIENT

            if alignmentForce == alignmentForce then
                acceleration += alignmentForce
            end
            if cohesionForce == cohesionForce then
                acceleration += cohesionForce
            end
            if seprationForce == seprationForce then
                acceleration += seprationForce
            end
        end

        local randomJitter = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 0.2
        acceleration += randomJitter

        world:set(fish, components.Velocity, ClampMagnitude(fishVelocity + (acceleration * dt), fishMaxSpeed))
    end
end

return system