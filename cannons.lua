
local timeSpentInCannon = 0

---@param m MarioState
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end

    if  m.action == ACT_IN_CANNON
    and m.actionState == 2 then
        timeSpentInCannon = timeSpentInCannon + 1
    else
        timeSpentInCannon = 0
    end

    if timeSpentInCannon >= 5 * 30 then
        m.controller.buttonPressed = m.controller.buttonPressed | A_BUTTON
    end
end

local function allow_interact(m, o, intee, interacted)
    if intee == INTERACT_CANNON_BASE and not gGlobalSyncTable.cannons then
        return false
    end
end

---@param o Object
local function cannon_lid_init(o)
    o.oFlags = OBJ_FLAG_PERSISTENT_RESPAWN | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.collisionData = gGlobalObjectCollisionData.cannon_lid_seg8_collision_08004950
    cur_obj_set_home_once()
end

---@param o Object
local function cannon_lid_loop(o)
    if gGlobalSyncTable.cannons then
        obj_set_model_extended(o, E_MODEL_NONE)
    else
        obj_set_model_extended(o, E_MODEL_DL_CANNON_LID)
        load_object_collision_model()
    end
end

---@param o Object
local function hidden_120_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.collisionData = gGlobalObjectCollisionData.castle_grounds_seg7_collision_cannon_grill
    o.oCollisionDistance = 4000
end

---@param o Object
local function hidden_120_loop(o)
    if gGlobalSyncTable.cannons then
        obj_set_model_extended(o, E_MODEL_NONE)
    else
        obj_set_model_extended(o, E_MODEL_CASTLE_GROUNDS_CANNON_GRILL)
        load_object_collision_model()
    end
end

hook_behavior(id_bhvHiddenAt120Stars, OBJ_LIST_SURFACE, true, hidden_120_init, hidden_120_loop)
id_bhvCannonLid = hook_behavior(nil, OBJ_LIST_SURFACE, false, cannon_lid_init, cannon_lid_loop, "cannonLid")
id_bhvCannonClosed = hook_behavior(id_bhvCannonClosed, OBJ_LIST_SURFACE, false, function (o)
    spawn_non_sync_object(id_bhvCannonLid, E_MODEL_DL_CANNON_LID, o.oPosX, o.oPosY - 5, o.oPosZ, function (obj)
        obj.oFaceAnglePitch = o.oFaceAnglePitch
        obj.oFaceAngleYaw = o.oFaceAngleYaw
        obj.oFaceAngleRoll = o.oFaceAngleRoll
    end)
    o.activeFlags = ACTIVE_FLAG_DEACTIVATED
end, nil, nil)

hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)