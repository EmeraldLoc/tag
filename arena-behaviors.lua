
E_MODEL_SPRING_TOP    = smlua_model_util_get_id("spring_top_geo")
E_MODEL_SPRING_BOTTOM = smlua_model_util_get_id("spring_bottom_geo")

define_custom_obj_fields({
    oArenaSpringSprung = 'u32',
})

---@param o Object
function arena_spawn_init(o)
    -- if we find a flag, delete this object
    if obj_get_first_with_behavior_id(id_bhvArenaFlag) ~= nil then
        obj_mark_for_deletion(o)
        return
    end

    -- set level spawn data and mario's pos if it doesn't exist
    if levels[gGlobalSyncTable.selectedLevel].spawnLocation == nil then
        levels[gGlobalSyncTable.selectedLevel].spawnLocation = {x = o.oPosX, y = o.oFloorHeight, z = o.oPosZ}
        vec3f_copy(gMarioStates[0].pos, levels[gGlobalSyncTable.selectedLevel].spawnLocation)
    end
    -- delete this spawn
    obj_mark_for_deletion(o)
end

---@param o Object
function arena_flag_spawn_init(o)

    local team = (o.oBehParams >> 24) & 0xFF

    -- set level spawn data and mario's pos if it doesn't exist
    -- use flag tag flag specifically
    if  levels[gGlobalSyncTable.selectedLevel].spawnLocation == nil
    and team == 0
    and collision_find_floor(o.oPosX, o.oPosY, o.oPosZ) ~= nil
    and collision_find_floor(o.oPosX, o.oPosY, o.oPosZ).type ~= SURFACE_DEATH_PLANE then
        levels[gGlobalSyncTable.selectedLevel].spawnLocation = {x = o.oPosX, y = find_floor_height(o.oPosX, o.oPosY, o.oPosZ), z = o.oPosZ}
        vec3f_copy(gMarioStates[0].pos, levels[gGlobalSyncTable.selectedLevel].spawnLocation)
    elseif team == 1 then
        if levels[gGlobalSyncTable.selectedLevel].pipes == nil then
            levels[gGlobalSyncTable.selectedLevel].pipes = { { { x = 0, y = 0, z = 0, }, { x = 0, y = 0, z = 0, } } }
        end
        vec3f_set(levels[gGlobalSyncTable.selectedLevel].pipes[1][1], o.oPosX, find_floor_height(o.oPosX, o.oPosY, o.oPosZ), o.oPosZ)
    elseif team == 2 then
        if levels[gGlobalSyncTable.selectedLevel].pipes == nil then
            levels[gGlobalSyncTable.selectedLevel].pipes = { { { x = 0, y = 0, z = 0, }, { x = 0, y = 0, z = 0, } } }
        end
        vec3f_set(levels[gGlobalSyncTable.selectedLevel].pipes[1][2], o.oPosX, find_floor_height(o.oPosX, o.oPosY, o.oPosZ), o.oPosZ)
    end
    -- delete object
    obj_mark_for_deletion(o)
end

-- taken from arena with minor modifications

local interactedWithSpring = false

local function bhv_arena_spring_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj.oOpacity = 255
    obj_set_model_extended(obj, E_MODEL_SPRING_BOTTOM)
    spawn_non_sync_object(id_bhvArenaSpringChild, E_MODEL_SPRING_TOP, obj.oPosX, obj.oPosY, obj.oPosZ,  function(c)
        c.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
        c.parentObj = obj
        c.oOpacity = 255
        c.oFaceAnglePitch = obj.oFaceAnglePitch
        c.oFaceAngleYaw = obj.oFaceAngleYaw
        c.oFaceAngleRoll = obj.oFaceAngleRoll
    end)
    network_init_object(obj, false, {
        'oArenaSpringSprung'
    })
end

local function bhv_arena_spring_launch(obj)
    local m = gMarioStates[0]
    local behParams = obj.oBehParams
    local strength = behParams & 0xFF
    local pitchAdjust = ((behParams >> 8) & 0xFF) * 0.01
    if pitchAdjust == 0 then pitchAdjust = 1 end

    local opitch = obj.oFaceAnglePitch
    local pitch = opitch * pitchAdjust + 0x4000
    local yaw = obj.oFaceAngleYaw + 0x8000

    local vel = {
        x = coss(pitch) * sins(yaw),
        y = sins(pitch),
        z = coss(pitch) * coss(yaw),
    }

    vec3f_normalize(vel)
    vec3f_mul(vel, 300)

    spawn_non_sync_object(id_bhvTriangleParticleSpawner, E_MODEL_NONE,
        obj.oPosX + vel.x,
        obj.oPosY + vel.y,
        obj.oPosZ + vel.z,
        nil)

    vec3f_normalize(vel)
    vec3f_mul(vel, strength)

    if math.abs(opitch) >= 2500 then
        set_mario_action(m, ACT_SHOT_FROM_CANNON, 0)
        m.vel.y = vel.y
        m.faceAngle.y = yaw
        m.forwardVel = math.sqrt((vel.x * vel.x) + vel.z * vel.z)
    else
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
        m.vel.y = vel.y
        m.forwardVel = 0
        interactedWithSpring = true
    end
    obj.oArenaSpringSprung = 15

    network_send_object(obj, false)
end

local function bhv_arena_spring_loop(obj)
    local player = gMarioStates[0].marioObj
    local dist = dist_between_objects(obj, player)
    if dist < 160 and mario_health_float(gMarioStates[0]) > 0 then
        bhv_arena_spring_launch(obj)
    end
    if obj.oArenaSpringSprung > 0 then
        obj.oArenaSpringSprung = obj.oArenaSpringSprung - 1
    end
    local sprung = obj.oArenaSpringSprung
    local sx = 15 - sprung
    scale = 0

    if sx == 1 then
        cur_obj_play_sound_2(SOUND_GENERAL_POUND_ROCK)
    end

    if sx < 3 then
        scale = (sx/5) + 2/5
    else
        scale = 1 - ((sx - 3) / 12)
        scale = scale * scale
    end
    obj.header.gfx.scale.y = scale * scale + 0.1
end


local function bhv_arena_spring_child_loop(obj)
    local p = obj.parentObj
    if p == nil then
        return
    end

    local pitch = obj.oFaceAnglePitch + 16384
    local yaw = obj.oFaceAngleYaw + 32768

    local vel = {
        x = coss(pitch) * sins(yaw),
        y = sins(pitch),
        z = coss(pitch) * coss(yaw),
    }

    vec3f_normalize(vel)
    vec3f_mul(vel, 110 * p.header.gfx.scale.y)

    obj.oPosX = obj.oHomeX + vel.x
    obj.oPosY = obj.oHomeY + vel.y
    obj.oPosZ = obj.oHomeZ + vel.z
end

---@param m MarioState
local function mario_update(m)
    if  interactedWithSpring
    and m.action == ACT_TRIPLE_JUMP then
        m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x400, 0x400)
    elseif m.action & ACT_FLAG_AIR ~= 0 then
        interactedWithSpring = false
    end
end

id_bhvArenaSpawn =      hook_behavior(nil, OBJ_LIST_LEVEL, false, arena_spawn_init, nil, "bhvArenaSpawn")
id_bhvArenaFlag =       hook_behavior(nil, OBJ_LIST_LEVEL, false, arena_flag_spawn_init, nil, "bhvArenaFlag")

id_bhvArenaSpringChild = hook_behavior(nil, OBJ_LIST_DEFAULT, true, nil, bhv_arena_spring_child_loop, 'id_bhvArenaSpringChild')
id_bhvArenaSpring = hook_behavior(nil, OBJ_LIST_DEFAULT, true, bhv_arena_spring_init, bhv_arena_spring_loop, 'id_bhvArenaSpring')

hook_event(HOOK_MARIO_UPDATE, mario_update)

-- get rid of all these behaviors (no better way of doing it then this block of text)
id_bhvArenaItem =       hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaItem")
id_bhvArenaKoth =       hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaKoth")
id_bhvArenaItemHeld =   hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaItemHeld")
id_bhvArenaKothActive = hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaKothActive")
id_bhvArenaBobomb =     hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaBobomb")
id_bhvArenaCannonBall = hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCannonBall")
id_bhvArenaChildFlame = hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaChildFlame")
id_bhvArenaFlame =      hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaFlame")
id_bhvArenaSparkle =    hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaSparkle")
id_bhvArenaCustom001 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom001")
id_bhvArenaCustom002 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom002")
id_bhvArenaCustom003 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom003")
id_bhvArenaCustom004 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom004")
id_bhvArenaCustom005 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom005")
id_bhvArenaCustom006 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom006")
id_bhvArenaCustom007 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom007")
id_bhvArenaCustom008 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom008")
id_bhvArenaCustom009 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom009")
id_bhvArenaCustom010 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom010")
id_bhvArenaCustom011 =  hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom011")
