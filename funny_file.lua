-- gl lol
variable1 = false

local function hud_black_bg()
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    djui_hud_set_color(28, 28, 30, 255)
    djui_hud_render_rect(0, 0, screenWidth, screenHeight)
end

local function hud_render()
    if  mod_storage_load("very_hidden") ~= "not_really"
    and network_is_server() then
        -- show anti piracy screen, crash player's game (hehehe)

        -- background
        hud_black_bg()

        local text = "\\#dcdcdc\\Pathetic child, fool, really thought you could outsmart me, " .. get_player_name(0)
        local x = (djui_hud_get_screen_width() - (djui_hud_measure_text(strip_hex(text)) * 2)) / 2
        local y = djui_hud_get_screen_height() / 2

        djui_hud_print_colored_text(text, x, y, 2, 255)

        if gNetworkPlayers[0].currAreaSyncValid then
            crash()
        end
    end

    variable1 = true
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)