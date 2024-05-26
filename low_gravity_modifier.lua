
---@param m MarioState
local function before_phys_step(m)
    if gGlobalSyncTable.modifier ~= MODIFIER_LOW_GRAVITY then return end

    if m.vel.y > 0 then
        -- check if action is a certain action because some actions have a high velocity acceleration
        if  m.action ~= ACT_TWIRLING
        and m.action ~= ACT_GETTING_BLOWN
        and m.action ~= ACT_FLYING_TRIPLE_JUMP
        and m.action ~= ACT_SHOT_FROM_CANNON
        and m.action ~= ACT_LAVA_BOOST
        and not interactedWithSpring  then
            m.vel.y = m.vel.y * 1.05
        end
    else
        m.vel.y = m.vel.y / 1.05
    end
end

hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)
