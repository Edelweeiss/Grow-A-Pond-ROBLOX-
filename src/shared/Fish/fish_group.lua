local rs = game:GetService("ReplicatedStorage")
local jecs = require(rs:WaitForChild("Pkgs").jecs_nightly)
local shared = rs:WaitForChild("Shared")
local world = require(shared.jecs_world)
local components = require(shared.jecs_components)
local utils = require(shared.Fish.utils)

local system = {}

local ALIGMENT_COEFFCIENT = 3
local COHESION_COEFFCIENT = 2
local SEPRATION_COEFFCIENT = 6
local TARGET_COEFFCIENT = 0.5
local OBSTACLE_COEFFCIENT = 100

local MAX_SPERATION_DIST = 6
local MAX_STEERING_SPEED = 30
local MAX_VIEW_RANGE = 7

local RAY_PARAMS = RaycastParams.new()
RAY_PARAMS.FilterType = Enum.RaycastFilterType.Exclude
RAY_PARAMS.FilterDescendantsInstances = {workspace.Fishes}

local target = Vector3.new(0,10,0)
local DIRECTIONS = utils.GetDirections(60)

function SteerTowards(v : vector, currVelocity : vector, maxSpeed : number)
    local newV = vector.normalize(v) * maxSpeed - currVelocity
    return utils.ClampMagnitude(newV, MAX_STEERING_SPEED)
end

function FindUnobstructedDirection(fishCFrame : CFrame) : (Vector3, boolean?)
    local bestDir = fishCFrame.LookVector
    local foundBest = false

    for i, _dir in DIRECTIONS do
        local dir : Vector3 = fishCFrame:VectorToWorldSpace(_dir)
        if fishCFrame.LookVector:Dot(dir) > 0.5 then continue end

        local res = workspace:Raycast(fishCFrame.Position, _dir.Unit * MAX_VIEW_RANGE, RAY_PARAMS)
        local isPathObstructed = res and res.Instance

        if isPathObstructed then continue end
        
        bestDir = dir
        foundBest = true
        break
    end

    return bestDir, foundBest
end

function CheckForObstruction(fishCFrame : CFrame, currVelocity : vector, maxSpeed : number) : Vector3
    local ray = workspace:Raycast(fishCFrame.Position, fishCFrame.LookVector * MAX_VIEW_RANGE, RAY_PARAMS)
    if not ray then return Vector3.zero end
    
    local unobstructedDir, foundBest = FindUnobstructedDirection(fishCFrame)
    local unobstructedForce = SteerTowards(unobstructedDir, currVelocity, maxSpeed) * OBSTACLE_COEFFCIENT
    if not foundBest or unobstructedForce ~= unobstructedForce then return Vector3.zero end
    
    return unobstructedForce
end

function system.solve(fishType :  jecs.Entity, dt : number)
    for fish, fishCFrame : CFrame, fishVelocity : vector, fishMaxSpeed : number in world:query(components.CFrame, components.Velocity, components.MaxSpeed):with(fishType) do
        local acceleration = vector.zero
        local direction = vector.zero

        local avgAdjPos = vector.zero
        local avgAdjDir = vector.zero
        local adjFishes = 0

        for adjFish, adjFishCFrame : CFrame, adjFishVelocity : vector in world:query(components.CFrame, components.Velocity):with(fishType) do
            if fish == adjFish then continue end

            local disp = adjFishCFrame.Position - fishCFrame.Position
            if vector.magnitude(disp) <= MAX_SPERATION_DIST then
                direction -= disp.Unit
            end

            adjFishes += 1
            avgAdjPos += adjFishCFrame.Position
            avgAdjDir += adjFishVelocity
        end

        if target then
            local disp = target - fishCFrame.Position
            local targetForce = SteerTowards(disp, fishVelocity, fishMaxSpeed) / (adjFishes+1) * TARGET_COEFFCIENT

            if targetForce == targetForce then
                acceleration += targetForce
            end
        end

        acceleration += CheckForObstruction(fishCFrame, fishVelocity, fishMaxSpeed)

        if adjFishes > 0 then
            avgAdjPos /= adjFishes
            avgAdjDir /= adjFishes

            local offsetFromCenter = avgAdjPos - fishCFrame.Position

            local alignmentForce = SteerTowards(avgAdjDir, fishVelocity, fishMaxSpeed) * ALIGMENT_COEFFCIENT
            local cohesionForce = SteerTowards(offsetFromCenter, fishVelocity, fishMaxSpeed) * COHESION_COEFFCIENT
            local seprationForce = SteerTowards(direction, fishVelocity, fishMaxSpeed) * SEPRATION_COEFFCIENT

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

        local vel = utils.ClampMagnitude(fishVelocity + (acceleration * dt), fishMaxSpeed)
        local newPos = fishCFrame.Position + vel * dt
        local newCFrame = CFrame.lookAt(newPos, newPos + vel:Lerp(fishVelocity, 0.8))
        world:set(fish, components.Velocity, vel)
        world:set(fish, components.CFrame, newCFrame)
    end
end

return system