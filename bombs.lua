
-- lots of this code is taken from arena
-- I changed bomb physics a lot and
-- revamped a lot of the code.
-- You will see a lot of code snippets from
-- arena however.

local bombCooldown = 0

-- custom obj fields
define_custom_obj_fields({
    oBombOwner = 'u32',
})

---@param i integer
local function can_hold_bomb(i)
    local s = gPlayerSyncTable[i]

    -- check modifier
    if gGlobalSyncTable.modifier ~= MODIFIER_BOMBS then return end

    -- check if we can hold a bomb
    if s.state ~= RUNNER and gGlobalSyncTable.gamemode == JUGGERNAUT then return false end
    if s.state ~= TAGGER and gGlobalSyncTable.gamemode ~= JUGGERNAUT then return false end

    return true
end

-- handle bomb pvp
---@param aI integer
---@param vI integer
local function handle_bomb_pvp(aI, vI)
    -- run handle pvp function based off of gamemode (if we run anything at all)
    if gGlobalSyncTable.gamemode == TAG then
        tag_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == FREEZE_TAG then
        freeze_tag_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == INFECTION then
        infection_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == HOT_POTATO then
        hot_potato_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
        -- do nothing, purely for kb and protection
    elseif gGlobalSyncTable.gamemode == ASSASSINS then
        assassins_handle_pvp(aI, vI) -- TODO: maybe better networking?
    elseif gGlobalSyncTable.gamemode == SARDINES then
        -- do nothing, purely for chaos
    elseif gGlobalSyncTable.gamemode == HUNT then
        hunt_handle_pvp(aI, vI)
    end
end

-- bomb explosion
---@param o Object
local function bomb_explosion_init(o)
    -- set basic flags
    o.oFlags = OBJ_FLAG_COMPUTE_DIST_TO_MARIO | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    -- set hitbox stuff
    o.oInteractType = INTERACT_DAMAGE
    o.oIntangibleTimer = 0
    o.hitboxRadius = 400
    o.hitboxHeight = 400
    o.hitboxDownOffset = 400
    o.oAnimState = -1
    -- make object a billboard
    obj_set_billboard(o)
    -- play explosion sound
    cur_obj_play_sound_2(SOUND_GENERAL2_BOBOMB_EXPLOSION)
end

---@param o Object
local function bomb_explosion_loop(o)
    -- increase anim state
    o.oAnimState = o.oAnimState + 1

    if o.oTimer == 9 then
        --- if we are in water, spawn a explosion buble, otherwise do normal death smoke
        if (find_water_level(o.oPosX, o.oPosZ) > o.oPosY) then
            for _ = 0, 40 do
                spawn_non_sync_object(id_bhvBobombExplosionBubble, E_MODEL_WHITE_PARTICLE_SMALL, o.oPosX, o.oPosY, o.oPosZ, nil)
            end
        else
            spawn_non_sync_object(id_bhvBobombBullyDeathSmoke, E_MODEL_SMOKE, o.oPosX, o.oPosY, o.oPosZ, nil)
        end

        o.activeFlags = ACTIVE_FLAG_DEACTIVATED
    end

    -- get nearest mario
    local m = nearest_mario_state_to_object(o)
    local localBombOwner = network_local_index_from_global(o.oBombOwner)

    -- if we interacted...
    if o.oInteractStatus & INT_STATUS_INTERACTED ~= 0 then
        if m.playerIndex == localBombOwner then goto interactset end
        -- run handle_player_pvp for designated gamemode
        handle_bomb_pvp(localBombOwner, m.playerIndex)

        ::interactset::

        -- set interact status to 0 to not run this again
        o.oInteractStatus = 0
    end

    -- reduce opacity over time
    o.oOpacity = o.oOpacity - 14

    -- scale object over time
    cur_obj_scale((o.oTimer / 9) + 1)
end

---@param o Object
local function bomb_explode(o)
    -- spawn explosion
    spawn_sync_object(id_bhvBombExplosion, E_MODEL_EXPLOSION, o.oPosX, o.oPosY, o.oPosZ, function (obj)
        obj.oBombOwner = o.oBombOwner
    end)
    -- delete bomb
    obj_mark_for_deletion(o)
end

---@param o Object
---@param rad integer
local function bobomb_intersects_player(o, rad)
    -- get owner network player
    local ownerNp = network_player_from_global_index(o.oBombOwner)
    -- return value
    local ret = false
    for i = 0, MAX_PLAYERS - 1 do
        local np = gNetworkPlayers[i]
        if not np.connected
        or not np.currAreaSyncValid then goto continue end

        local m = gMarioStates[i]
        -- get lag compensation mario state
        if m.playerIndex == 0 and ownerNp.localIndex ~= 0 then
            m = lag_compensation_get_local_state(ownerNp)
        end

        -- convert positions to vec3f
        local pos =   { x = o.oPosX, y = o.oPosY,       z = o.oPosZ }
        local mPos = { x = m.pos.x, y = m.pos.y + 50,  z = m.pos.z }
        -- get return value
        ret = vec3f_dist(pos, mPos) < rad

        if ret then
            -- goto return ending
            goto ending
        end

        ::continue::
    end

    ::ending::

    -- return that value
    return ret
end

---@param o Object
local function bomb_init(o)
    -- set basic flags
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW
    -- set hitbox and gravity vars
    o.hitboxRadius = 50
    o.hitboxHeight = 50
    o.oGravity = 5
    o.oVelY = 40
    -- set animation to bomb walking animation
    o.oAnimations = gObjectAnimations.bobomb_seg8_anims_0802396C
    -- initialize that animation
    cur_obj_init_animation(0)
    -- scale the object down
    obj_scale(o, 0.75)
    -- init sync object
    network_init_object(o, true, {
        "activeFlags",
        "oVelY",
        "oPosX",
        "oPosY",
        "oPosZ",
    })
end

---@param o Object
local function bomb_loop(o)
    -- step object
    local step = object_step_without_floor_orient()

    -- explode if we hit a wall or land
    if step & AIR_STEP_HIT_WALL ~= 0
    or step & AIR_STEP_LANDED ~= 0
    or bobomb_intersects_player(o, 100) then
        bomb_explode(o)
    end

    -- explode if we touch water
    if o.oPosY < find_water_level(o.oPosX, o.oPosZ) then
        bomb_explode(o)
    end
end

---@param o Object
local function bomb_held_init(o)
    -- set basic object flags
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    -- set animation to bomb walking animation
    o.oAnimations = gObjectAnimations.bobomb_seg8_anims_0802396C
    -- initialize that animation
    cur_obj_init_animation(0)
    -- scale object down
    cur_obj_scale(0.4)
end

---@param o Object
local function bomb_held_loop(o)
    -- get network player and mario state
    local np = gNetworkPlayers[o.oBombOwner]
    local m = gMarioStates[np.localIndex]

    -- check wether or not this bomb should be rendered
    if np.currLevelNum ~= gNetworkPlayers[0].currLevelNum
    or not np.connected or not np.currAreaSyncValid
    or not can_hold_bomb(o.oBombOwner) then
        cur_obj_disable_rendering()
    else
        cur_obj_enable_rendering()
    end

    -- set position
    o.oPosX = get_hand_foot_pos_x(m, 0)
    o.oPosY = get_hand_foot_pos_y(m, 0) - 25
    o.oPosZ = get_hand_foot_pos_z(m, 0)

    -- set face angle
    o.oFaceAnglePitch = m.faceAngle.x
    o.oFaceAngleYaw = m.faceAngle.y
    o.oFaceAngleRoll = m.faceAngle.z

    -- forward offset
    o.oPosX = o.oPosX + sins(m.faceAngle.y) * 25
    o.oPosZ = o.oPosZ + coss(m.faceAngle.y) * 25

    -- if mario is currently not being rendered, set the objects
    -- position to that mario's position instead of his hand position
    if m.marioBodyState.updateTorsoTime ~= gMarioStates[0].marioBodyState.updateTorsoTime then
        o.oPosX = m.pos.x
        o.oPosY = m.pos.y
        o.oPosZ = m.pos.z
    end
end

local function spawn_bomb()
    local m = gMarioStates[0]
    local np = gNetworkPlayers[0]
    -- spawn bomb
    spawn_sync_object(id_bhvBomb, E_MODEL_BLACK_BOBOMB, m.pos.x, m.pos.y + 167, m.pos.z, function (o)
        o.oForwardVel = m.forwardVel + 60
        if o.oForwardVel < 75 then
            o.oForwardVel = 75
        end
        o.oMoveAngleYaw = m.faceAngle.y
        o.oBombOwner = np.globalIndex
    end)

    -- set mario's action
    if m.floorHeight == m.pos.y and m.forwardVel == 0 then
        set_mario_action(m, ACT_PUNCHING, 0)
    elseif m.floorHeight == m.pos.y and m.forwardVel ~= 0 then
        set_mario_action(m, ACT_JUMP_KICK, 0)
    elseif m.pos.y < m.waterLevel then
        set_mario_action(m, ACT_WATER_PUNCH, 0)
    else
        set_mario_action(m, ACT_DIVE, 0)
    end
end

---@param m MarioState
local function mario_update(m)

    if m.playerIndex ~= 0 then return end

    if can_hold_bomb(0) then
        bombCooldown = bombCooldown + 1

        if  m.controller.buttonPressed & binds[BIND_BOMBS].btn ~= 0
        and bombCooldown >= 2 * 30 then
            bombCooldown = 0

            spawn_bomb()
        end
    else
        bombCooldown = 0
    end

    bombCooldown = clampf(bombCooldown, 0, 2 * 30)
end

local function hud_bombs()
    if not can_hold_bomb(0) then return end

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local scale        = 1
    local width        = 128 * scale
    local height       = 16 * scale
    local x            = math.floor((screenWidth - width) / 2)
    local y            = math.floor(screenHeight - height - 4 * scale)
    local bombTime     = bombCooldown / 30 / 2

    if gGlobalSyncTable.gamemode == JUGGERNAUT then
        y = y + 20
    end

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x, y, width, height)

    x = x + 2 * scale
    y = y + 2 * scale
    width = width - 4 * scale
    height = height - 4 * scale
    width = math.floor(width * bombTime)
    djui_hud_set_color(242, 143, 36, 128)
    djui_hud_render_rect(x, y, width, height)

    if bombCooldown < 2 * 30 then
        text = "Reloading"
    else
        text = "Throw Bomb (" .. button_to_text(binds[BIND_BOMBS].btn) .. ")"
    end
    text = "Throw Bomb (" .. button_to_text(binds[BIND_BOMBS].btn) .. ")"

    scale = 0.25
    width = djui_hud_measure_text(text) * scale
    height = 32 * scale
    x = (screenWidth - width) / 2
    y = screenHeight - 28

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - 6, y, width + 12, height)

    djui_hud_set_color(242, 143, 36, 128)
    djui_hud_print_text(text, x, y, scale)
end

local function on_render()
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    hud_bombs()
end

local function level_init()
    for i = 0, MAX_PLAYERS - 1 do
        local m = gMarioStates[i]
        spawn_non_sync_object(id_bhvBombItem, E_MODEL_BLACK_BOBOMB, m.pos.x, m.pos.y, m.pos.z, function (o)
            o.oBombOwner = i
        end)
    end
end

id_bhvBombExplosion = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, false, bomb_explosion_init, bomb_explosion_loop, nil)
id_bhvBomb = hook_behavior(nil, OBJ_LIST_DEFAULT, false, bomb_init, bomb_loop, nil)
id_bhvBombItem = hook_behavior(nil, OBJ_LIST_DEFAULT, false, bomb_held_init, bomb_held_loop, nil)

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_render)
hook_event(HOOK_ON_LEVEL_INIT, level_init)