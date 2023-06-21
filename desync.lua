
desyncTimer = 0
local packetSent = false
local blackBgY = djui_hud_get_screen_height()
local prevBlackBgY = djui_hud_get_screen_height()
---@type NetworkPlayer
local np = gNetworkPlayers[0]

local function hud_black_bg()
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    if desyncTimer <= 5 * 30 then
        if blackBgY > 0 then
            blackBgY = blackBgY - 35

            if blackBgY <= 0 then blackBgY = 0 end
        end
    else
        blackBgY = blackBgY - 35
        if blackBgY <= -djui_hud_get_screen_height() then blackBgY = -djui_hud_get_screen_height(); return end
    end

    djui_hud_set_color(28, 28, 30, 255)
    djui_hud_render_rect_interpolated(0, prevBlackBgY, screenWidth, screenHeight, 0, blackBgY, screenWidth, screenHeight)

    prevBlackBgY = blackBgY
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

    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(text, x, y, scale)

    -- send a packet to the server asking to resync the player

    if not packetSent then
        send_packet_to_server({globalIndex = network_global_index_from_local(0), packetType = PACKET_TYPE_DESYNCED})
        packetSent = true
    end
end

local function hud_render()

    if desyncTimer > 5 * 30 then
        if desyncTimer >= (5 * 30) + 1 and desyncTimer <= (5 * 30) + 5 then
            select_random_did_you_know()
        end

        if blackBgY == djui_hud_get_screen_height() or blackBgY == -djui_hud_get_screen_height() then
            return
        end
    end

    if blackBgY ~= djui_hud_get_screen_height() and desyncTimer == 5 * 30 - 1 then
        packetSent = false
        blackBgY = djui_hud_get_screen_height()
        prevBlackBgY = djui_hud_get_screen_height()
    end

    if joinTimer > 0 then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    hud_black_bg()

    if blackBgY ~= 0 then return end

    hud_desync_text()
    hud_did_you_know()
end

local function update()
    if np.currLevelNum ~= gNetworkPlayers[network_local_index_from_global(0)].currLevelNum and gGlobalSyncTable.roundState == ROUND_ACTIVE and desyncTimer > 0 then
        -- a desync may have happened, begin the desync timer
        desyncTimer = desyncTimer - 1
    elseif gNetworkPlayers[0].currLevelNum == gNetworkPlayers[network_local_index_from_global(0)].currLevelNum then
        desyncTimer = 10 * 30
    end
end

-- disable this code until the next version of coop where packets are fixed
--[[hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)--]]