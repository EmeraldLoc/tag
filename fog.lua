
-- not optimal, if there's a better way, please make an issue at https://github.com/EmeraldLoc/tag

-- the way fog works in sm64 is not reproducable with lua mods, so instead opt for models.
-- this uses 6 objects in total. Five transparent objects, 1 opaque object.
-- we spawn 5 transparent object for a smooth "opaquining" (thats not a word) effect (its not smooth)
-- spawn in an opaque object as some objects ignore transparent objects opacity being solid
-- this looks pretty good, but the more you look at it, the worse it gets. I know, your welcome.

local E_MODEL_FOG = smlua_model_util_get_id("normal_fog_opaque_geo")
local E_MODEL_FOG_TRANSPARENT = smlua_model_util_get_id("normal_fog_transparent_geo")
local warpTimer = 0.2 * 30

---@param o Object
local function fog_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE

    -- spawn buddies
    if obj_count_objects_with_behavior_id(id_bhvFog) == 1 then
        -- 6 total objects, not too bad (not good either),
        -- although very good compared to skin swapper mods particle effects, so
        for i = 1, 5 do
            spawn_non_sync_object(id_bhvFog, E_MODEL_FOG_TRANSPARENT, o.oPosX, o.oPosY, o.oPosZ, function (obj)
                obj.oOpacity = 64 * i
                obj_scale(obj, 12 + (i / 2))
            end)
        end
    end
end

---@param o Object
local function fog_loop(o)
    local m = gMarioStates[0]

    o.oPosX = m.pos.x
    o.oPosY = m.pos.y
    o.oPosZ = m.pos.z
end

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end

    if warpTimer > 0 then
        warpTimer = warpTimer - 1
    end

    -- spawn fog
    if not obj_get_first_with_behavior_id(id_bhvFog)
    and gGlobalSyncTable.modifier == MODIFIER_FOG
    and warpTimer <= 0 then

        local style = "normal"
        local skybox = get_skybox()

        if skybox == BACKGROUND_ABOVE_CLOUDS
        or skybox == BACKGROUND_BELOW_CLOUDS
        or skybox == BACKGROUND_OCEAN_SKY
        or skybox == BACKGROUND_SNOW_MOUNTAINS
        or skybox == BACKGROUND_UNDERWATER_CITY then
            -- nothing
        elseif skybox == BACKGROUND_DESERT then
            style = "sand"
        elseif skybox == BACKGROUND_FLAMING_SKY then
            style = "lava"
        elseif skybox == BACKGROUND_GREEN_SKY then
            style = "green"
        elseif skybox == BACKGROUND_HAUNTED then
            style = "haunted"
        elseif skybox == BACKGROUND_PURPLE_SKY then
            style = "purple"
        else
            -- custom skybox, use terrain type instead (if the hack is good this will be configured properly)
            if m.area.terrainType == TERRAIN_SAND then
                style = "sand"
                djui_chat_message_create(tostring("sand"))
            elseif m.area.terrainType == TERRAIN_SPOOKY then
                style = "haunted"
            end
        end

        -- level override
        if not isRomhack
        and levels[gGlobalSyncTable.selectedLevel].name == "issl" then
            style = "sand"
        end

        E_MODEL_FOG = smlua_model_util_get_id(style .. "_fog_opaque_geo")
        E_MODEL_FOG_TRANSPARENT = smlua_model_util_get_id(style .. "_fog_transparent_geo")

        spawn_non_sync_object(id_bhvFog, E_MODEL_FOG, m.pos.x, m.pos.y, m.pos.z, function (o)
            obj_scale(o, 20)
        end)
    elseif gGlobalSyncTable.modifier ~= MODIFIER_FOG then
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvFog))
    end
end

local function on_render()
    if not obj_get_first_with_behavior_id(id_bhvFog) then return end

    ---@type MarioState
    local m = gMarioStates[0]

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local r, g, b = 0, 0, 0
    local skybox = get_skybox()

    -- check skybox to determine the color of the fog
    if skybox == BACKGROUND_ABOVE_CLOUDS
    or skybox == BACKGROUND_BELOW_CLOUDS
    or skybox == BACKGROUND_OCEAN_SKY
    or skybox == BACKGROUND_SNOW_MOUNTAINS
    or skybox == BACKGROUND_UNDERWATER_CITY then
        r, g, b = 0, 47, 100
    elseif skybox == BACKGROUND_DESERT then
        r, g, b = 171, 147, 116
    elseif skybox == BACKGROUND_FLAMING_SKY then
        r, g, b = 194, 38, 33
    elseif skybox == BACKGROUND_GREEN_SKY then
        r, g, b = 4, 44, 48
    elseif skybox == BACKGROUND_HAUNTED then
        r, g, b = 14, 3, 138
    elseif skybox == BACKGROUND_PURPLE_SKY then
        r, g, b = 147, 4, 199
    else
        -- custom skybox, use terrain type instead
        if m.area.terrainType == TERRAIN_SAND then
            r, g, b = 171, 147, 116
        elseif m.area.terrainType == TERRAIN_SPOOKY then
            r, g, b = 14, 3, 138
        else
            r, g, b = 0, 47, 100
        end
    end

    -- level override
    if not isRomhack
    and levels[gGlobalSyncTable.selectedLevel].name == "issl" then
        r, g, b = 171, 147, 116
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