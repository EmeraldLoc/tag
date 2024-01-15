
---@param m MarioState
local function before_phys_step(m)
    if gGlobalSyncTable.modifier ~= MODIFIER_HIGH_GRAVITY then return end

    if m.vel.y > 0 then
        m.vel.y = m.vel.y / 1.06
    else
        m.vel.y = m.vel.y * 1.06
    end
end

hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)
