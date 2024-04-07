
local fade = 255

local function hud_black_bg()

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    djui_hud_set_color(28, 28, 30, fade)
    djui_hud_render_rect(0, 0, screenWidth, screenHeight)
end

local function hud_join_text()
    local text = "Joining..."

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text)

    local x = (screenWidth - width) / 2
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_status()

    local text = ""

    if joinTimer > 4 * 30 then
        text = "Synchronizing..."
    else
        text = "Enjoy Tag!"
    end

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
end

local function hud_current_gamemode()
    local text = "Current Gamemode is " .. get_gamemode_without_hex(gGlobalSyncTable.gamemode)

    if gGlobalSyncTable.randomGamemode then
        text = text .. " (Random)"
    end

    local x = 40
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_current_modifier()
    local text = "Current Modifier is " .. get_modifier_text_without_hex()

    if gGlobalSyncTable.randomModifiers then
        text = text .. " (Random)"
    end

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text)

    local x = screenWidth - width - 40
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_render()

    if joinTimer <= 0 then return end

    if joinTimer > (6 * 30) - 2 then
        select_random_did_you_know()
    end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    if joinTimer > 2 * 30 then
        if fade < 255 then
            fade = fade + 20

            if fade >= 255 then fade = 255 end
        end
    else
        fade = fade - 20

        if fade <= 0 then return end
    end

    hud_black_bg()
    hud_join_text()
    hud_status()
    hud_current_gamemode()
    hud_current_modifier()
    hud_did_you_know(fade)
end

if not network_is_server() then
    hook_event(HOOK_ON_HUD_RENDER, hud_render)
end