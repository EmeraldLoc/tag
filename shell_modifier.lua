
local shellTimer = 0

---@param m MarioState
local function mario_update(m)

    if m.playerIndex ~= 0 then return end
    if gGlobalSyncTable.modifier ~= MODIFIER_SHELL then
        if m.action & ACT_FLAG_RIDING_SHELL ~= 0 then
            set_mario_action(m, ACT_IDLE, 0)
            return
        end
    end

    if m.action & ACT_FLAG_RIDING_SHELL == 0
    and shellTimer >= 1 * 30 then
        set_mario_action(m, ACT_RIDING_SHELL_GROUND, 0)
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