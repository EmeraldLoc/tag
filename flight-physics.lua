
--- @param m MarioState
local function mario_update(m)

    if m.playerIndex ~= 0 then return end

    -- flight physics
    if m.action == ACT_FLYING then
        if m.forwardVel < 65 then
            m.forwardVel = m.forwardVel + 2
        end

        if m.forwardVel > 80 then m.forwardVel = 80 end
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)