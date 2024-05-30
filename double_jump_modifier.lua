
local usedDoubleJump = false
local airTimer = 0

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    if gGlobalSyncTable.gamemode == JUGGERNAUT
    and gPlayerSyncTable[0].state == RUNNER
    and gGlobalSyncTable.roundState == ROUND_ACTIVE then goto doublejump end
    if  gGlobalSyncTable.modifier ~= MODIFIER_DOUBLE_JUMP then return end

    ::doublejump::

    if m.action == ACT_SOFT_BONK
    or m.action == ACT_BACKWARD_AIR_KB
    or m.action == ACT_AIR_HIT_WALL
    or m.action == ACT_FLYING then
        airTimer = 0
    end

    if  m.action & ACT_GROUP_MASK == ACT_GROUP_AIRBORNE
    and m.controller.buttonPressed & binds[BIND_DOUBLE_JUMP].btn ~= 0
    and not usedDoubleJump
    and airTimer > 0.2 * 30 then
        usedDoubleJump = true

        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
        m.vel.y = 65
        spawn_mist_particles_variable(5, 0, 15)
    elseif m.action & ACT_GROUP_MASK == ACT_GROUP_AIRBORNE then
        airTimer = airTimer + 1
    elseif m.action & ACT_GROUP_MASK ~= ACT_GROUP_AIRBORNE
    and (find_floor_steepness(m.pos.x, m.pos.y, m.pos.z) <= 45
    or m.floor.type ~= SURFACE_DEFAULT) then
        usedDoubleJump = false
        airTimer = 0
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)