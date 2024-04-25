

local selection = 1
local joystickCooldown = 0

local function toggle_paused()
    isPaused = not isPaused
end

pauseEntries = {
    -- resume selection
    {name = "Resume",
    permission = PERMISSION_NONE,
    func = toggle_paused},
    -- spectating selection
    {name = "Toggle Spectating",
    permission = PERMISSION_NONE,
    func = toggle_spectator},
    -- coop settings selection
    {name = "Coop Settings",
    permission = PERMISSION_NONE,
    func = djui_open_pause_menu},
    -- tag settings selection
    {name = "Tag Settings",
    permission = PERMISSION_NONE,
    func = function() showSettings = true end},
}

local function on_render()
    if not isPaused then
        joystickCooldown = 0
        selection = 1
        return
    end

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    --- @type NetworkPlayer
    local np = gNetworkPlayers[0]
    local x = screenWidth / 2
    local y = screenHeight / 2.5

    -- background
    djui_hud_set_color(0, 0, 0, 64)
    djui_hud_render_rect(0, 0, screenWidth + 20, screenHeight + 20)

    -- render course
    local text = "(" .. tostring(np.currCourseNum) .. ") " .. name_of_level(np.currLevelNum, np.currAreaIndex)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text(text, x - djui_hud_measure_text(text), y - 100, 2)

    for i = 1, #pauseEntries do
        local height = y + (i * 100)

        text = pauseEntries[i].name

        if selection == i then
            text = "> " .. text
        end

        djui_hud_set_color(220, 220, 220, 255)
        djui_hud_print_text(text, x - djui_hud_measure_text(text), height, 2)
    end
end

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end

    if joystickCooldown > 0 then
        joystickCooldown = joystickCooldown - 1
    end

    if m.controller.buttonPressed & START_BUTTON ~= 0 then
        toggle_paused()
        showSettings = false
        m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
        play_sound(SOUND_MENU_PAUSE, gGlobalSoundSource)
    end

    if not isPaused then return end
    if showSettings then return end

    if m.controller.buttonPressed & R_TRIG ~= 0 then
        djui_open_pause_menu()
        m.controller.buttonPressed = m.controller.buttonPressed & ~R_TRIG
    end

    -- if our stick is at 0, then set joystickCooldown to 0
    if m.controller.stickY == 0 then joystickCooldown = 0 end

    if m.controller.buttonPressed & U_JPAD ~= 0 or (m.controller.stickY > 0.5 and joystickCooldown <= 0) then
        selection = selection - 1
        if selection < 1 then selection = #pauseEntries end
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
        joystickCooldown = 0.2 * 30
    elseif m.controller.buttonPressed & D_JPAD ~= 0 or (m.controller.stickY < -0.5 and joystickCooldown <= 0) then
        selection = selection + 1
        if selection > #pauseEntries then selection = 1 end
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
        joystickCooldown = 0.2 * 30
    end

    if m.controller.buttonPressed & A_BUTTON ~= 0 then
        if has_permission(pauseEntries[selection].permission) then
            pauseEntries[selection].func()
            m.controller.buttonPressed = m.controller.buttonDown & ~A_BUTTON
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        else
            play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)