
ACT_SHELL_GROUND_CUSTOM = allocate_mario_action(ACT_FLAG_RIDING_SHELL | ACT_FLAG_ATTACKING)

local shellTimer = 0

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    if  gGlobalSyncTable.modifier ~= MODIFIER_SHELL
    or (gGlobalSyncTable.roundState ~= ROUND_ACTIVE
    and gGlobalSyncTable.roundState ~= ROUND_WAIT
    and gGlobalSyncTable.roundState ~= ROUND_HOT_POTATO_INTERMISSION)
    or  gPlayerSyncTable[0].state == WILDCARD_ROLE
    or  gPlayerSyncTable[0].state == SPECTATOR then
        if m.action & ACT_FLAG_RIDING_SHELL ~= 0 then
            set_mario_action(m, ACT_IDLE, 0)
        end
        return
    end

    if (m.action & ACT_FLAG_RIDING_SHELL == 0
    and shellTimer >= 1 * 30
    and m.action ~= ACT_IN_CANNON
    and m.action ~= ACT_SHOT_FROM_CANNON
    and m.action & ACT_FLAG_ON_POLE == 0)
    or m.action == ACT_RIDING_SHELL_GROUND then
        if m.action == ACT_RIDING_SHELL_GROUND then
            set_mario_action(m, ACT_SHELL_GROUND_CUSTOM, m.actionArg)
        else
            set_mario_action(m, ACT_SHELL_GROUND_CUSTOM, 0)
        end
    elseif m.action & ACT_FLAG_RIDING_SHELL == 0 then
        shellTimer = shellTimer + 1
    else
        shellTimer = 0
    end
end

local function level_init()
    for i = 0, MAX_PLAYERS - 1 do
        local m = gMarioStates[i]
        spawn_non_sync_object(id_bhvCustomShell, E_MODEL_KOOPA_SHELL, m.pos.x, m.pos.y, m.pos.z, function (o)
            o.heldByPlayerIndex = i
        end)
    end
end

local function act_riding_shell_ground(m)
    local startYaw = m.faceAngle.y

    if m.input & INPUT_A_PRESSED ~= 0 then
        return set_mario_action(m, ACT_RIDING_SHELL_JUMP, 0)
    end

    update_shell_speed(m)
    local anim = CHAR_ANIM_START_RIDING_SHELL
    if m.actionArg ~= 0 then
        anim = CHAR_ANIM_RIDING_SHELL
    end
    set_character_animation(m, anim)

    local step = perform_ground_step(m)

    if step == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_RIDING_SHELL_FALL, 0)
    elseif step == GROUND_STEP_HIT_WALL then
        m.forwardVel = 0
    end

    tilt_body_ground_shell(m, startYaw)
    if m.floor and m.floor.type == SURFACE_BURNING then
        play_sound(SOUND_MOVING_RIDING_SHELL_LAVA, m.marioObj.header.gfx.cameraToObject)
    else
        play_sound(SOUND_MOVING_TERRAIN_RIDING_SHELL + m.terrainSoundAddend,
                   m.marioObj.header.gfx.cameraToObject)
    end

    adjust_sound_for_speed(m)

    reset_rumble_timers(m)
    return false
end

hook_mario_action(ACT_SHELL_GROUND_CUSTOM, act_riding_shell_ground)

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_LEVEL_INIT, level_init)

local function bhv_koopa_shell_flame_spawn(o)
    for _ = 0, 1 do
        spawn_non_sync_object(id_bhvKoopaShellFlame, E_MODEL_RED_FLAME, o.oPosX, o.oPosY, o.oPosZ, nil)
    end
end

local function koopa_shell_spawn_sparkles(o, a)
    local sparkle = spawn_non_sync_object(id_bhvSparkleSpawn, E_MODEL_NONE, o.oPosX, o.oPosY, o.oPosZ, nil)
    sparkle.oPosY = sparkle.oPosY + a
end

---@param o Object
local function custom_shell_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end

---@param o Object
local function custom_shell_loop(o)
    local m = gMarioStates[o.heldByPlayerIndex]

    if m.action & ACT_FLAG_RIDING_SHELL ~= 0 then
        cur_obj_unhide()

        o.oPosX = m.pos.x
        o.oPosY = m.pos.y
        o.oPosZ = m.pos.z
        o.oFaceAngleYaw = m.faceAngle.y

        local floor = cur_obj_update_floor_height_and_get_floor()

        if floor ~= nil
        and floor.type == SURFACE_BURNING
        and 5 > math.abs(o.oPosY - o.oFloorHeight) then
            bhv_koopa_shell_flame_spawn(o)
        else
            koopa_shell_spawn_sparkles(o, 10)
        end
    else
        cur_obj_hide()
    end
end

id_bhvCustomShell = hook_behavior(nil, OBJ_LIST_DEFAULT, false, custom_shell_init, custom_shell_loop, "bhvCustomShell")