
define_custom_obj_fields({
    oTagHeldItemOwner = 'u32',
})

---@param o Object
function held_bobomb_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oAnimations = gObjectAnimations.bobomb_seg8_anims_0802396C
    obj_scale(o, 0.5)
    cur_obj_play_sound_2(SOUND_AIR_BOBOMB_LIT_FUSE)
    cur_obj_init_animation(1)
end

---@param o Object
function held_bobomb_loop(o)
    -- always be intangible
    cur_obj_become_intangible()

    -- enable or disable rendering depending on state and modifier
    if gPlayerSyncTable[o.oTagHeldItemOwner].state ~= TAGGER or gGlobalSyncTable.modifier ~= MODIFIER_BOMBS or not gNetworkPlayers[o.oTagHeldItemOwner].connected then
        cur_obj_disable_rendering()
    else
        cur_obj_enable_rendering()
    end

    local m = gMarioStates[o.oTagHeldItemOwner]

    -- taken from arena with bomb values
    o.oFaceAngleYaw = m.faceAngle.y
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0

    o.oPosX = get_hand_foot_pos_x(m, 0)
    o.oPosY = get_hand_foot_pos_y(m, 0) - 25
    o.oPosZ = get_hand_foot_pos_z(m, 0)

    o.oPosX = o.oPosX + sins(m.faceAngle.y) * 25
    o.oPosZ = o.oPosZ + coss(m.faceAngle.y) * 25
end

local function level_init()
    -- spawn bombs on all players on init
    for i = 0, (MAX_PLAYERS - 1) do
        spawn_non_sync_object(id_bhvHeldBobomb, E_MODEL_BLACK_BOBOMB, 0, 0, 0,
            function(o)
                o.oTagHeldItemOwner = i
            end)
    end
end

id_bhvHeldBobomb = hook_behavior(nil, OBJ_LIST_DEFAULT, false, held_bobomb_init, held_bobomb_loop, "held_item")

hook_event(HOOK_ON_LEVEL_INIT, level_init)