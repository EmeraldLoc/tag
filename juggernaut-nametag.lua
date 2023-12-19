-- base by agent x, changes by me

local MAX_SCALE = 0.32

local gStateExtras = {}
for i = 0, (MAX_PLAYERS - 1) do
    gStateExtras[i] = {}
    local e = gStateExtras[i]
    e.prevPos = {}
    e.prevPos.x = 0
    e.prevPos.y = 0
    e.prevPos.z = 0
    e.prevScale = 1
end

--- @param m MarioState
local function active_player(m)
    local np = gNetworkPlayers[m.playerIndex]
    if m.playerIndex == 0 then
        return 1
    end
    if not np.connected then
        return 0
    end
    if np.currCourseNum ~= gNetworkPlayers[0].currCourseNum then
        return 0
    end
    if np.currActNum ~= gNetworkPlayers[0].currActNum then
        return 0
    end
    if np.currLevelNum ~= gNetworkPlayers[0].currLevelNum then
        return 0
    end
    if np.currAreaIndex ~= gNetworkPlayers[0].currAreaIndex then
        return 0
    end
    return is_player_active(m)
end

local function if_then_else(cond, if_true, if_false)
    if cond then return if_true end
    return if_false
end

local function djui_hud_set_adjusted_color(r, g, b, a)
    local multiplier = 1
    if is_game_paused() then multiplier = 0.5 end
    djui_hud_set_color(r * multiplier, g * multiplier, b * multiplier, a)
end

local function djui_hud_print_outlined_text_interpolated(text, prevX, prevY, prevScale, x, y, scale, r, g, b, a, outlineDarkness)
    local offset = 1 * (scale * 2)
    local prevOffset = 1 * (prevScale * 2)

    -- render outline
    djui_hud_set_adjusted_color(r * outlineDarkness, g * outlineDarkness, b * outlineDarkness, a)
    djui_hud_print_text_interpolated(text, prevX - prevOffset, prevY,              prevScale, x - offset, y,          scale)
    djui_hud_print_text_interpolated(text, prevX + prevOffset, prevY,              prevScale, x + offset, y,          scale)
    djui_hud_print_text_interpolated(text, prevX,              prevY - prevOffset, prevScale, x,          y - offset, scale)
    djui_hud_print_text_interpolated(text, prevX,              prevY + prevOffset, prevScale, x,          y + offset, scale)
    -- render text
    djui_hud_set_adjusted_color(r, g, b, 255)
    djui_hud_print_text_interpolated(text, prevX, prevY, prevScale, x, y, scale)
    djui_hud_set_color(255, 255, 255, 255)
end

local function on_hud_render()
    if gGlobalSyncTable.gamemode ~= JUGGERNAUT or gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end

    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_NORMAL)

    for i = 1, MAX_PLAYERS - 1 do
        if gPlayerSyncTable[i].state ~= RUNNER then goto continue end

        local m = gMarioStates[i]
        local out = { x = 0, y = 0, z = 0 }
        local pos = { x = m.marioObj.header.gfx.pos.x, y = m.pos.y + 210, z = m.marioObj.header.gfx.pos.z }
        if djui_hud_world_pos_to_screen_pos(pos, out) and m.marioBodyState.updateTorsoTime == gMarioStates[0].marioBodyState.updateTorsoTime and active_player(m) ~= 0 and m.action ~= ACT_IN_CANNON and (m.playerIndex ~= 0 or (m.playerIndex == 0 and m.action ~= ACT_FIRST_PERSON)) then
            local scale = 0.32
            local dist = vec3f_dist(gLakituState.pos, m.pos)
            scale = 0.5
            scale = scale + dist / 7000
            scale = clampf(1 - scale, 0, 0.32)
            local text = tostring(gGlobalSyncTable.juggernautTagsReq - gPlayerSyncTable[i].juggernautTags) .. " Tags Remaining"
            local color = { r = 162, g = 202, b = 234 }
            network_player_palette_to_color(gNetworkPlayers[i], SHIRT, color)
            color.r = color.r + 20
            color.g = color.g + 20
            color.b = color.b + 20
            if color.r > 255 then color.r = 255 end
            if color.g > 255 then color.g = 255 end
            if color.b > 255 then color.b = 255 end
            local measure = djui_hud_measure_text(text) * scale * 0.5
            local alpha = if_then_else(m.action ~= ACT_CROUCHING and m.action ~= ACT_START_CRAWLING and m.action ~= ACT_CRAWLING and m.action ~= ACT_STOP_CRAWLING, 255, 100)

            local e = gStateExtras[i]

            djui_hud_print_outlined_text_interpolated(text, e.prevPos.x - measure, e.prevPos.y, e.prevScale, out.x - measure, out.y, scale, color.r, color.g, color.b, alpha, 0.25)

            e.prevPos.x = out.x
            e.prevPos.y = out.y
            e.prevPos.z = out.z
            e.prevScale = scale
        end

        ::continue::
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
