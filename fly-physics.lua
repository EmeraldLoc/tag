
local flyHeight = 0

--- @param m MarioState
local function mario_update(m)

    if m.playerIndex ~= 0 then return end

    -- set flight height
    if m.action == ACT_FLYING_TRIPLE_JUMP then
        flyHeight = m.pos.y + 5000

        if gPlayerSyncTable[0].state == SPECTATOR or gPlayerSyncTable[0].state == ELIMINATED_OR_FROZEN then
            flyHeight = 1000000 -- stupid high number
        end
    end

    -- flight physics
    if m.action == ACT_FLYING then
        if m.forwardVel < 65 and m.pos.y < flyHeight then
            m.forwardVel = m.forwardVel + 2

            if m.forwardVel > 65 then m.forwardVel = 65 end
        end
        if m.forwardVel > 80 and m.pos.y < flyHeight then m.forwardVel = 80 end
        if m.pos.y > flyHeight then
            m.forwardVel = m.forwardVel - 0.5
        end
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
