
local standingStill = true
local prevPos = {x = 0, y = 0, z = 0}
local distMoved = 0
local initializedLevel = false

---@param m MarioState
local function mario_update(m)

    -- I will be forever grateful for parts of the anticamp code. Thank you dj
    if m.playerIndex ~= 0 then return end

    if initializedLevel then
        vec3f_copy(prevPos, m.pos)
        distMoved = 0
        initializedLevel = false
    end

    -- track how far the local player has moved recently
    distMoved = distMoved - 0.25 + vec3f_dist(prevPos, m.pos) * 0.01
    vec3f_copy(prevPos, m.pos)

    -- clamp between 0 and 20
    distMoved = clampf(distMoved, 0, 20)

    -- if player hasn't moved, then set standing still to true
    if distMoved <= 10 then
        standingStill = true
    else
        standingStill = false
    end
end

local function level_init()
    initializedLevel = true
end

function is_standing_still()
    return standingStill
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_LEVEL_INIT, level_init)