
-- the way fog works in sm64 is not reproducable with lua mods, so instead opt for models.
-- this uses a fog model, whih uses anim states to decide the color and transparency.
-- there are 5 transparent sphere's in this model for a smooth "opaquining" (thats not a word) effect
-- spawn in an opaque object as some objects ignore transparent objects opacity being solid

local E_MODEL_FOG = smlua_model_util_get_id("fog_geo")
local warpTimer = 0.2 * 30

local STATE_NORMAL = 0
local STATE_SAND = 1
local STATE_BLACK = 2
local STATE_GREEN = 3
local STATE_PURPLE = 4
local STATE_HAUNTED = 5
local STATE_FIRE = 6

local skyboxInfo = {
    [BACKGROUND_OCEAN_SKY]       = {anim = STATE_NORMAL , color = {r = 000, g = 047, b = 100}},
    [BACKGROUND_SNOW_MOUNTAINS]  = {anim = STATE_NORMAL , color = {r = 000, g = 047, b = 100}},
    [BACKGROUND_ABOVE_CLOUDS]    = {anim = STATE_NORMAL , color = {r = 000, g = 047, b = 100}},
    [BACKGROUND_BELOW_CLOUDS]    = {anim = STATE_NORMAL , color = {r = 000, g = 047, b = 100}},
    [BACKGROUND_UNDERWATER_CITY] = {anim = STATE_NORMAL , color = {r = 000, g = 047, b = 100}},
    [BACKGROUND_FLAMING_SKY]     = {anim = STATE_FIRE   , color = {r = 235, g = 077, b = 066}},
    [BACKGROUND_GREEN_SKY]       = {anim = STATE_GREEN  , color = {r = 004, g = 044, b = 048}},
    [BACKGROUND_HAUNTED]         = {anim = STATE_HAUNTED, color = {r = 013, g = 003, b = 138}},
    [BACKGROUND_DESERT]          = {anim = STATE_SAND   , color = {r = 171, g = 171, b = 116}},
    [BACKGROUND_PURPLE_SKY]      = {anim = STATE_PURPLE , color = {r = 147, g = 004, b = 199}},
    [BACKGROUND_CUSTOM]          = {anim = STATE_NORMAL , color = {r = 000, g = 000, b = 000}},
}

---@param o Object
local function fog_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.header.gfx.skipInViewCheck = true
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oOpacity = 75
    obj_scale(o, 3.5)
    set_override_far(1000000)
end

---@param o Object
local function fog_loop(o)
    local m = gMarioStates[0]

    skybox = get_skybox()
    if skyboxInfo[skybox] then
        o.oAnimState = skyboxInfo[skybox].anim
    else
        o.oAnimState = STATE_BLACK
    end

    if gGlobalSyncTable.modifier ~= MODIFIER_FOG then
        obj_mark_for_deletion(o)
    end

    o.oPosX, o.oPosY, o.oPosZ = m.pos.x, m.pos.y, m.pos.z
    o.oFaceAngleYaw = m.faceAngle.y
end

---@param m MarioState
local function mario_update(m)

    if m.playerIndex ~= 0 then return end

    if warpTimer > 0 then
        warpTimer = warpTimer - 1
    end
    if not obj_get_first_with_behavior_id(id_bhvFog) and gGlobalSyncTable.modifier == MODIFIER_FOG and warpTimer <= 0 then
        spawn_non_sync_object(id_bhvFog, E_MODEL_FOG, 0, 0, 0, nil)
    end
end

local function on_render()
    if not obj_get_first_with_behavior_id(id_bhvFog) then return end

    ---@type MarioState
    local m = gMarioStates[0]

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local skybox = get_skybox()
    local r, g, b = 0, 0, 0

    if skybox >= 0 then
        r, g, b = skyboxInfo[skybox].color.r, skyboxInfo[skybox].color.g, skyboxInfo[skybox].color.b
    end

    -- check skybox to determine the color of the fog
    if get_skybox() == BACKGROUND_CUSTOM then
        -- custom skybox, use terrain type instead
        if m.area.terrainType == TERRAIN_SAND then
            r, g, b = 171, 147, 116
        elseif m.area.terrainType == TERRAIN_SPOOKY then
            r, g, b = 14, 3, 138
        else
            r, g, b = 0, 47, 100
        end
    end

    djui_hud_set_color(r, g, b, 100)
    djui_hud_render_rect(0, 0, screenWidth + 20, screenHeight + 20)
end

local function on_level_init()
    warpTimer = 0.2 * 30
end

id_bhvFog = hook_behavior(nil, OBJ_LIST_DEFAULT, false, fog_init, fog_loop)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_render)
hook_event(HOOK_ON_LEVEL_INIT, on_level_init)