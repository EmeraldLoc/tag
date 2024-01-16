
local screenWidth = djui_hud_get_screen_width()
local screenHeight = djui_hud_get_screen_height()
local selection = 0
local SELECTION_DONE = 0
local SELECTION_SPECTATE = 1
local SELECTION_COOP_SETTINGS = 2
local SELECTION_TAG_SETTINGS = 3
local SELECTION_MAX = 4
local joystickCooldown = 0

local function hud_pause()
    --- @type NetworkPlayer
    local np = gNetworkPlayers[0]
    local x = screenWidth / 2
    local y = screenHeight / 2.5

    -- background
    djui_hud_set_color(0, 0, 0, 64)
    djui_hud_render_rect(0, 0, screenWidth + 20, screenHeight + 20)

    -- render course
    local text = "(" .. tostring(np.currCourseNum) .. ") " .. get_level_name(np.currCourseNum, np.currLevelNum, np.currAreaIndex)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text(text, x - djui_hud_measure_text(text), y - 100, 2)

    -- render continue button
    text = "Continue"
    if selection == SELECTION_DONE then
        text = "> " .. text
    end

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text(text, x - djui_hud_measure_text(text), y + 100, 2)

    -- render spectate button
    if gPlayerSyncTable[0].state ~= SPECTATOR then
        text = "Spectate"
    else
        text = "Stop Spectating"
    end

    if selection == SELECTION_SPECTATE then
       text = "> " .. text
    end

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text(text, x - djui_hud_measure_text(text), y + 200, 2)

     -- render coop settings button
    text = "Coop Settings"
    if selection == SELECTION_COOP_SETTINGS then
        text = "> " .. text
    end

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text(text, x - djui_hud_measure_text(text), y + 300, 2)

      -- render tag settings button
    text = "Tag Settings"
    if selection == SELECTION_TAG_SETTINGS then
        text = "> " .. text
    end

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text(text, x - djui_hud_measure_text(text), y + 400, 2)
end

local function on_render()
    if not isPaused then return end
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)
    hud_pause()
end

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    if joystickCooldown > 0 then joystickCooldown = joystickCooldown - 1 end
    if m.controller.stickY == 0 then joystickCooldown = 0 end

    if isPaused and not showSettings then
        if m.controller.stickY > 0.5 and joystickCooldown <= 0 then
            selection = selection - 1
            if selection < 0 then selection = 0 end

            joystickCooldown = 0.2 * 30
            play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        end

        if m.controller.stickY < -0.5 and joystickCooldown <= 0 then
            selection = selection + 1
            if selection > SELECTION_MAX then selection = SELECTION_MAX end

            joystickCooldown = 0.2 * 30
            play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        end

        if m.controller.buttonPressed & A_BUTTON ~= 0 then
            if selection == SELECTION_DONE then
                isPaused = not isPaused
            elseif selection == SELECTION_SPECTATE then

                if gPlayerSyncTable[0].state == SPECTATOR then
                    if gGlobalSyncTable.roundState == ROUND_ACTIVE or gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION then
                        djui_chat_message_create("You must wait for the game to end to no longer be a spectator")
                        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
                        return
                    else
                        gPlayerSyncTable[0].state = RUNNER
                        warp_to_level(LEVEL_VCUTM, 1, 0) -- Enter spectator in singleplayer and see what happens >:)
                    end
                else
                    gPlayerSyncTable[0].state = SPECTATOR
                end
            elseif selection == SELECTION_COOP_SETTINGS then
                djui_open_pause_menu()
            elseif selection == SELECTION_TAG_SETTINGS then
                showSettings = not showSettings
				_G.tagSettingsOpen = showSettings
            end

            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        end

        if m.controller.buttonPressed & R_TRIG ~= 0 then
            djui_open_pause_menu()
            m.controller.buttonPressed = m.controller.buttonPressed & ~R_TRIG
        end
    elseif not isPaused and not showSettings then
        selection = 0
    end

    if m.controller.buttonPressed & START_BUTTON ~= 0 then
        m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
        isPaused = not isPaused
        showSettings = false
        play_sound(SOUND_MENU_PAUSE, gGlobalSoundSource)
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)