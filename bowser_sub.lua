
---@param o Object
local function bowsers_sub_init(o)
    o.oFlags = OBJ_FLAG_ACTIVE_FROM_AFAR  | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oDrawingDistance = 20000
    o.oCollisionDistance = 20000
    o.collisionData = gGlobalObjectCollisionData.ddd_seg7_collision_submarine
end

---@param o Object
local function bowser_sub_loop(o)
    load_object_collision_model()
end

id_bhvBowsersSub = hook_behavior(id_bhvBowsersSub, OBJ_LIST_SURFACE, true, bowsers_sub_init, bowser_sub_loop, "id_bhvBowsersSub")