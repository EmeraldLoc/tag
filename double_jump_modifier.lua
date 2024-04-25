
local usedDoubleJump = false
local airTimer = 0

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    if gGlobalSyncTable.modifier ~= MODIFIER_DOUBLE_JUMP then return end

    if m.action == ACT_SOFT_BONK
    or m.action == ACT_BACKWARD_AIR_KB
    or m.action == ACT_AIR_HIT_WALL then
        airTimer = 0
    end

    if  m.action & ACT_GROUP_MASK == ACT_GROUP_AIRBORNE
    and m.controller.buttonPressed & binds[BIND_DOUBLE_JUMP].btn ~= 0
    and not usedDoubleJump
    and airTimer > 0.2 * 30 then
        usedDoubleJump = true

        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
        m.vel.y = 65
    elseif m.action & ACT_GROUP_MASK == ACT_GROUP_AIRBORNE then
        airTimer = airTimer + 1
    elseif m.action & ACT_GROUP_MASK ~= ACT_GROUP_AIRBORNE then
        usedDoubleJump = false
        airTimer = 0
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)