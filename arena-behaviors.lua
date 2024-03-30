
---@param o Object
function arena_spawn_init(o)
    -- if we find a flag, delete this object
    if obj_get_first_with_behavior_id(id_bhvArenaFlag) ~= nil then
        obj_mark_for_deletion(o)
        return
    end

    -- set level spawn data and mario's pos if it doesn't exist
    if levels[gGlobalSyncTable.selectedLevel].spawnLocation == nil then
        levels[gGlobalSyncTable.selectedLevel].spawnLocation = {x = o.oPosX, y = o.oPosY, z = o.oPosZ}
        vec3f_copy(gMarioStates[0].pos, levels[gGlobalSyncTable.selectedLevel].spawnLocation)
    end
    -- delete this spawn
    obj_mark_for_deletion(o)
end

---@param o Object
function arena_flag_spawn_init(o)
    -- set level spawn data and mario's pos if it doesn't exist
    if levels[gGlobalSyncTable.selectedLevel].spawnLocation == nil then
        levels[gGlobalSyncTable.selectedLevel].spawnLocation = {x = o.oPosX, y = o.oPosY, z = o.oPosZ}
        vec3f_copy(gMarioStates[0].pos, levels[gGlobalSyncTable.selectedLevel].spawnLocation)
    end
    -- delete object
    obj_mark_for_deletion(o)
end

id_bhvArenaSpawn =      hook_behavior(nil, OBJ_LIST_LEVEL, false, arena_spawn_init, nil, "bhvArenaSpawn")
id_bhvArenaFlag =       hook_behavior(nil, OBJ_LIST_LEVEL, false, arena_flag_spawn_init, nil, "bhvArenaFlag")

-- get rid of all these behaviors (no better way of doing it then this block of text)
id_bhvArenaSpring =     hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaSpring")
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
