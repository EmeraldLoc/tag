
-- not optimal, if there's a better way, please make an issue at https://github.com/EmeraldLoc/tag

local E_MODEL_FOG_OPAQUE = smlua_model_util_get_id("fog_opaque_geo")
local E_MODEL_FOG_TRANSPARENT = smlua_model_util_get_id("fog_transparent_geo")

---@param o Object
local function fog_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE

    -- spawn buddies
    if obj_count_objects_with_behavior_id(id_bhvFog) == 1 then
        -- 6 total objects, not too bad (not good either),
        -- altohugh very good compared to skin swapper mods particle effects, so
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
    -- spawn fog
    if not obj_get_first_with_behavior_id(id_bhvFog) and gGlobalSyncTable.modifier == MODIFIER_FOG then
        spawn_non_sync_object(id_bhvFog, E_MODEL_FOG_OPAQUE, m.pos.x, m.pos.y, m.pos.z, function (o)
            obj_scale(o, 20)
        end)
    elseif gGlobalSyncTable.modifier ~= MODIFIER_FOG then
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvFog))
    end
end

local function on_render()
    if not obj_get_first_with_behavior_id(id_bhvFog) then return end

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    djui_hud_set_color(0, 47, 100, 100)
    djui_hud_render_rect(0, 0, screenWidth + 20, screenHeight + 20)
end

id_bhvFog = hook_behavior(nil, OBJ_LIST_DEFAULT, false, fog_init, fog_loop)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_render)