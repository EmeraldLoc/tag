
-- custom obj fields
define_custom_obj_fields({
    oBulletOwner = 'u32',
})

---@param o Object
local function bullet_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_SET_FACE_ANGLE_TO_MOVE_ANGLE
    o.hitboxRadius = 200
    o.hitboxHeight = 200
    obj_set_billboard(o)
    local localOwner = network_local_index_from_global(o.oBulletOwner)
    local m = gMarioStates[localOwner]
    if gGlobalSyncTable.modifier == MODIFIER_FLY then
        o.oMoveAnglePitch = m.faceAngle.x
    end
    o.oMoveAngleYaw = m.faceAngle.y
    local speed = m.forwardVel + 150
    -- shoot backwards
    if m.controller.buttonDown & D_JPAD ~= 0 then
        speed = -speed
    end
    -- flip if our action is set to turning around
    if m.action == ACT_SIDE_FLIP
    or m.action == ACT_SIDE_FLIP_LAND then
        speed = -speed
    end
    o.oVelX = speed * coss(o.oFaceAnglePitch) * sins(o.oFaceAngleYaw)
    if gGlobalSyncTable.modifier == MODIFIER_FLY then
        o.oVelY = speed * sins(o.oFaceAnglePitch)
        o.oVelY = -o.oVelY
    end
    o.oVelZ = speed * coss(o.oFaceAnglePitch) * coss(o.oFaceAngleYaw)
end

---@param o Object
local function bullet_loop(o)
    if o.oTimer > 1 * 30 then
        obj_mark_for_deletion(o)
    end

    cur_obj_move_using_vel()

    if collision_find_floor(o.oPosX, o.oPosY, o.oPosZ) == nil then
        obj_mark_for_deletion(o)
    end

    local localOwner = network_local_index_from_global(o.oBulletOwner)
    local m = nearest_mario_state_to_object(o)

    -- if we get hit, and we are the victim, handle pvp
    if dist_between_objects(o, m.marioObj) < 200
    and m.playerIndex == 0
    and m.invincTimer <= 0
    and localOwner ~= 0 then
        handle_projectile_pvp(localOwner, m.playerIndex, o)

        obj_mark_for_deletion(o)
    end
end

function hud_bullet(gunCooldown, maxGunCooldown)
    if gPlayerSyncTable[0].state == SPECTATOR
    or gPlayerSyncTable[0].state == WILDCARD_ROLE then return end

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

    if  boosts_enabled()
    or  (gPlayerSyncTable[0].state == RUNNER
    and gGlobalSyncTable.roundState == ROUND_ACTIVE
    and (gGlobalSyncTable.gamemode == JUGGERNAUT
    or  gGlobalSyncTable.gamemode == HUNT
    or  gGlobalSyncTable.gamemode == DEATHMATCH)) then
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

    if  boosts_enabled()
    or  (gPlayerSyncTable[0].state == RUNNER
    and gGlobalSyncTable.roundState == ROUND_ACTIVE
    and (gGlobalSyncTable.gamemode == JUGGERNAUT
    or  gGlobalSyncTable.gamemode == HUNT
    or  gGlobalSyncTable.gamemode == DEATHMATCH)) then
        y = y - 32
    end

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - 6, y, width + 12, height)

    djui_hud_set_color(0, 162, 255, 128)
    djui_hud_print_text(text, x, y, scale)
end

id_bhvBullet = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, false, bullet_init, bullet_loop)