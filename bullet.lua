
-- custom obj fields
define_custom_obj_fields({
    oBulletOwner = 'u32',
})

---@param o Object
local function bullet_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_SET_FACE_ANGLE_TO_MOVE_ANGLE
    o.hitboxRadius = 100
    o.hitboxHeight = 100
    obj_set_billboard(o)
    local localOwner = network_local_index_from_global(o.oBulletOwner)
    local m = gMarioStates[localOwner]
    o.oMoveAnglePitch = m.faceAngle.x
    o.oMoveAngleYaw = m.faceAngle.y
    local speed = m.forwardVel + 150
    o.oVelX = speed * coss(o.oFaceAnglePitch) * sins(o.oFaceAngleYaw)
    o.oVelY = speed * sins(o.oFaceAnglePitch)
    o.oVelY = -o.oVelY
    o.oVelZ = speed * coss(o.oFaceAnglePitch) * coss(o.oFaceAngleYaw)
end

---@param o Object
local function bullet_loop(o)
    if o.oTimer > 1 * 30 then
        obj_mark_for_deletion(o)
    end

    cur_obj_move_using_vel()

    if o.oMoveFlags & OBJ_MOVE_HIT_WALL ~= 0
    or o.oMoveFlags & OBJ_MOVE_LANDED ~= 0 then
        obj_mark_for_deletion(o)
    end

    local localOwner = network_local_index_from_global(o.oBulletOwner)
    local m = nearest_mario_state_to_object(o)

    if dist_between_objects(o, m.marioObj) < 200 and m.playerIndex ~= localOwner then
        handle_projectile_pvp(localOwner, m.playerIndex)

        obj_mark_for_deletion(o)
    end
end

id_bhvBullet = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, false, bullet_init, bullet_loop)