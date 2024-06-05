
local firstLaunch = load_bool("firstLaunch")
local bgWidth = djui_hud_get_screen_width() - 400
local bgHeight = djui_hud_get_screen_height() - 120

---@param m MarioState
local function mario_update(m)
    if firstLaunch == nil then firstLaunch = true end
    if m.playerIndex ~= 0 then return end
    if firstLaunch then
        m.freeze = 1

        if m.controller.buttonPressed & X_BUTTON ~= 0 then
            firstLaunch = false
            save_bool("firstLaunch", false)
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        end
    end
end

local function hud_render()
    if firstLaunch == nil then firstLaunch = true end
    if not firstLaunch then return end

    local x = (djui_hud_get_screen_width() / 2) - (bgWidth / 2)
    local y = djui_hud_get_screen_height() - bgHeight
    djui_hud_set_color(20, 20, 22, 250)
    djui_hud_render_rect_rounded_outlined(x, y / 2, bgWidth, bgHeight, 45, 45, 47, 10, 250)

    local text = "Welcome to \\#316BE8\\Tag"
    x = (djui_hud_get_screen_width() / 2) - (bgWidth / 2)
    y = (djui_hud_get_screen_height() - bgHeight) / 2

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_colored_text(text, x + ((bgWidth / 2) - djui_hud_measure_text(strip_hex(text))), y + 50, 2)

    text = "\\#316BE8\\Tag\\#dcdcdc\\ is a pack of multiple gamemodes! It contains modifiers to freshen up your game, a tournament system, achievements and rewards, and more!"

    local wrappedText = wrap_text(text, djui_hud_get_screen_width() - 430)

    y = y + 30

    for _, s in ipairs(wrappedText) do
        y = y + 30

        djui_hud_set_color(220, 220, 220, 255)
        djui_hud_print_colored_text(s, x + 10, y + 50, 1)
    end

    text = "The gamemodes for \\#316BE8\\Tag\\#dcdcdc\\ include "

    for i = MIN_GAMEMODE, MAX_GAMEMODE do
        if i < MAX_GAMEMODE then
            text = text .. get_gamemode(i) .. ", "
        else
            text = text .. "and " .. get_gamemode(i) .. ". "
        end
    end

    text = text .. "The amount of gamemodes being added to tag is growing constantly. If you need help knowing how these gamemodes work, go to the Help section, and select the gamemode you're struggling with!"

    wrappedText = wrap_text(text, djui_hud_get_screen_width() - 430)

    y = y + 30

    for _, s in ipairs(wrappedText) do
        y = y + 30

        djui_hud_set_color(220, 220, 220, 255)
        djui_hud_print_colored_text(s, x + 10, y + 50, 1)
    end

    text = "The modifiers for \\#316BE8\\Tag\\#dcdcdc\\ include "

    for i = MODIFIER_MIN, 10 do
        if i < 10 then
            text = text .. get_modifier_text(i) .. "\\#dcdcdc\\, "
        else
            text = text .. get_modifier_text(i) .. "\\#dcdcdc\\, and more! "
        end
    end

    text = text .. "Modifiers are added very frequently, much more often than for gamemodes! If you don't like certain modifiers, you can use the Blacklist section to blacklist them!"

    wrappedText = wrap_text(text, djui_hud_get_screen_width() - 430)

    y = y + 30

    for _, s in ipairs(wrappedText) do
        y = y + 30

        djui_hud_set_color(220, 220, 220, 255)
        djui_hud_print_colored_text(s, x + 10, y + 50, 1)
    end

    text = "Press X to close!"

    wrappedText = wrap_text(text, djui_hud_get_screen_width() - 430)

    y = bgHeight

    for _, s in ipairs(wrappedText) do
        djui_hud_set_color(220, 220, 220, 255)
        djui_hud_print_colored_text(s, x + ((bgWidth / 2) - djui_hud_measure_text(strip_hex(text))), y - 50, 2)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)