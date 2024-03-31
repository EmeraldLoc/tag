
-- custom obj fields
define_custom_obj_fields({
    oBulletOwner = 'u32',
})

---@param o Object
local function bullet_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_SET_FACE_ANGLE_TO_MOVE_ANGLE
    o.hitboxRadius = 100
    o.hitboxHeight = 100
    o.oDamageOrCoinValue = 2
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

    -- if we get hit, and we are the victim, handle pvp
    if dist_between_objects(o, m.marioObj) < 200
    and m.playerIndex == 0
    and localOwner ~= 0 then
        handle_projectile_pvp(localOwner, m.playerIndex)
        -- kb
        take_damage_and_knock_back(m, o)

        obj_mark_for_deletion(o)
    end
end

function hud_bullet(gunCooldown, maxGunCooldown)

    -- clamp gun cooldown
    gunCooldown = clampf(gunCooldown, 0, maxGunCooldown)

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local scale        = 1
    local width        = 128 * scale
    local height       = 16 * scale
    local x            = math.floor((screenWidth - width) / 2)
    local y            = math.floor(screenHeight - height - 4 * scale)
    local gunTime      = gunCooldown / 30 / (maxGunCooldown / 30)

    if  (gPlayerSyncTable[0].state == TAGGER
    and boosts_enabled())
    or  (gPlayerSyncTable[0].state == RUNNER
    and gGlobalSyncTable.roundState == ROUND_ACTIVE
    and (gGlobalSyncTable.gamemode == JUGGERNAUT
    or  gGlobalSyncTable.gamemode == HUNT)) then
        y = y - 32
    end

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x, y, width, height)

    x = x + 2 * scale
    y = y + 2 * scale
    width = width - 4 * scale
    height = height - 4 * scale
    width = math.floor(width * gunTime)

    djui_hud_set_color(0, 137, 237, 128)
    djui_hud_render_rect(x, y, width, height)

    if gunCooldown < maxGunCooldown then
        text = "Recharging"
    else
        text = "Shoot (" .. button_to_text(binds[BIND_GUN].btn) .. ")"
    end

    scale = 0.25
    width = djui_hud_measure_text(text) * scale
    height = 32 * scale
    x = (screenWidth - width) / 2
    y = screenHeight - 28

    if  (gPlayerSyncTable[0].state == TAGGER
    and boosts_enabled())
    or  (gPlayerSyncTable[0].state == RUNNER
    and gGlobalSyncTable.roundState == ROUND_ACTIVE
    and (gGlobalSyncTable.gamemode == JUGGERNAUT
    or  gGlobalSyncTable.gamemode == HUNT)) then
        y = y - 32
    end

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - 6, y, width + 12, height)

    djui_hud_set_color(0, 162, 255, 128)
    djui_hud_print_text(text, x, y, scale)
end

id_bhvBullet = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, false, bullet_init, bullet_loop)