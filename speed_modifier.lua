
---@param m MarioState
local function before_phys_step(m)

    if gGlobalSyncTable.modifier ~= MODIFIER_SPEED then return end

    if  m.action ~= ACT_BACKWARD_AIR_KB
    and m.action ~= ACT_FORWARD_AIR_KB
    and m.action ~= ACT_HARD_BACKWARD_AIR_KB
    and m.action ~= ACT_HARD_FORWARD_AIR_KB
    and m.action ~= ACT_BACKWARD_AIR_KB
    and m.action ~= ACT_FORWARD_AIR_KB
    and m.action ~= ACT_WATER_JUMP then
        -- speed multiplication by 1.3
        m.vel.x = m.vel.x * 1.3
        m.vel.z = m.vel.z * 1.3
    end
end

hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)