
DESYNC_REASON_LEVEL = 1
DESYNC_REASON_ROUND_STATE = 2
desyncTimer = 0
desyncReason = DESYNC_REASON_LEVEL
local packetTimer = 10 * 30
local fade = 0
---@type NetworkPlayer
local np = gNetworkPlayers[0]

local function hud_black_bg()
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    djui_hud_set_color(28, 28, 30, fade)
    djui_hud_render_rect(0, 0, screenWidth, screenHeight)
end

local function hud_resyncing_text()
    local text = "Resyncing..."

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text)

    local x = (screenWidth - width) / 2
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_desync_text()
    local text = "Woah there, you seem to be desynced, resyncing..."

    -- set scale
    local scale = 1

    -- get width of screen and text
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()
    local width = djui_hud_measure_text(text) * scale
    local height = 32 * scale

    local x = (screenWidth - width) * 0.5
    local y = (screenHeight - height) * 0.5

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, scale)

    -- send a packet to the server asking to resync the player
    if packetTimer <= 0 then
        local p = {packetType = PACKET_TYPE_LEVEL_DESYNCED, globalIndex = network_global_index_from_local(0), reason = desyncReason}
        send_packet_to_server(p)
        packetTimer = 10 * 30
    end
end

local function hud_render()

    if desyncTimer > 0 then
        packetTimer = 3 * 30
        return
    end

    if joinTimer > 0 then return end

    if desyncTimer >= 10 * 30 - 5 and desyncTimer <= 10 * 30 then
        select_random_did_you_know()
    end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    if desyncTimer <= 0 then
        if fade < 255 then
            fade = fade + 20

            if fade >= 255 then fade = 255 end
        end
    else
        fade = fade - 20

        if fade <= 0 then return end
    end

    hud_black_bg()
    hud_resyncing_text()
    hud_desync_text()
    hud_did_you_know(fade)
end

local function update()
    if (gGlobalSyncTable.roundState == ROUND_ACTIVE or gGlobalSyncTable.roundState == ROUND_WAIT or gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION) and desyncTimer > 0 then
        if np.currLevelNum ~= gNetworkPlayers[network_local_index_from_global(0)].currLevelNum or not np.currAreaSyncValid then
            -- a desync happened, begin the desync timer
            desyncTimer = desyncTimer - 1
            -- by using a packet timer, we can resend the packet if it doesn't seem that it went thru
            packetTimer = packetTimer - 1
            -- set the reason for the desync to the level
            desyncReason = DESYNC_REASON_LEVEL
        elseif gGlobalSyncTable.roundState == ROUND_WAIT and math.floor(gGlobalSyncTable.displayTimer / 30) > 15 then
            -- a desync happened, begin the desync timer
            desyncTimer = desyncTimer - 1
            -- by using a packet timer, we can resend the packet if it doesn't seem that it went thru
            packetTimer = packetTimer - 1
            -- set the reason for the desync to the round state
            desyncReason = DESYNC_REASON_ROUND_STATE
        else goto setvars end
    else goto setvars end

    goto exit

    ::setvars::
    desyncTimer = 10 * 30
    packetTimer = 10 * 30

    ::exit::
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)