
showSettings = false
blacklistAddRequest = false
local showBlacklistSettings = false
local showGamemodeSettings = false
local joystickCooldown = 0
-- default selections
local MIN_SELECTION = 0
local GAMEMODE_SELECTION = 0
local MODIFIER_SELECTION = 1
local BLJS_SELECTION = 2
local CANNON_SELECTION = 3
local WATER_SELECTION = 4
local ELIMINATE_ON_DEATH_SELECTION = 5
local DO_VOTE_SELECTION = 6
local GAMEMODE_SETTINGS_SELECTION = 7
local BLACKLIST_SELECTION = 8
local DONE_SELECTION = 9
local MAX_SELECTION = 9
-- blacklist selections
local MIN_BLACKLIST_SELECTION = 0
local BLACKLIST_ADD_SELECTION = 0
local BLACKLIST_BACK_SELECTION = 1
local MAX_BLACKLIST_SELECTION = 1
-- gamemode settings selections
local MIN_GAMEMODE_SELECTION = 0
local GAMEMODE_TAG_TIMER_SELECTION = 0
local GAMEMODE_FREEZE_TAG_TIMER_SELECTION = 1
local GAMEMODE_FROZEN_HEALTH_DRAIN_SELECTION = 2
local GAMEMODE_INFECTION_TIMER_SELECTION = 3
local GAMEMODE_HOT_POTATO_TIMER_SELECTION = 4
local GAMEMODE_JUGGERNAUT_TIMER_SELECTION = 5
local GAMEMODE_ASSASSINS_TIMER_SELECTION = 6
local GAMEMODE_BACK_SELECTION = 7
local MAX_GAMEMODE_SELECTION = 7
-- other
local screenHeight = 0
local bgWidth = 525
local selection = GAMEMODE_SELECTION

local function background()
    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(0, 0, bgWidth, screenHeight)
end

local function settings_text()
    local text = ""
    if showBlacklistSettings then
        text = "Blacklist Settings"
    elseif showGamemodeSettings then
        text = "Gamemode Settings"
    else
        text = "Tag Settings"
    end
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text(text, (bgWidth / 2) - djui_hud_measure_text(text), 50, 2)
end

local function options()

    local height = 150

    if selection == GAMEMODE_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Gamemode", 30, height + 4, 1)
    if gGlobalSyncTable.randomGamemode then
        djui_hud_print_text("Random", bgWidth - 30 - djui_hud_measure_text("Random"), height + 4, 1)
    else
        local r, g, b = get_gamemode_rgb_color()
        djui_hud_set_color(r, g, b, 255)
        djui_hud_print_text(get_gamemode_without_hex(), bgWidth - 30 - djui_hud_measure_text(get_gamemode_without_hex()), height + 4, 1)
    end

    height = height + 60

    if selection == MODIFIER_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Modifier", 30, height + 4, 1)
    if gGlobalSyncTable.randomModifiers then
        djui_hud_print_text("Random", bgWidth - 30 - djui_hud_measure_text("Random"), height + 4, 1)
    elseif gGlobalSyncTable.modifier == MODIFIER_NONE then
        djui_hud_print_text("Disabled", bgWidth - 30 - djui_hud_measure_text("Disabled"), height + 4, 1)
    else
        local r, g, b = get_modifier_rgb()
        djui_hud_set_color(r, g, b, 255)
        djui_hud_print_text(get_modifier_text_without_hex(), bgWidth - 30 - djui_hud_measure_text(get_modifier_text_without_hex()), height + 4, 1)
    end

    height = height + 60

    if selection == BLJS_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Blj", 30, height + 4, 1)
    if gGlobalSyncTable.bljs then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4, 1)
    end

    height = height + 60

    if selection == CANNON_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Cannons", 30, height + 4, 1)
    if gGlobalSyncTable.cannons then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4, 1)
    end

    height = height + 60

    if selection == WATER_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Water", 30, height + 4, 1)
    if gGlobalSyncTable.water then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4, 1)
    end

    height = height + 60

    if selection == ELIMINATE_ON_DEATH_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Eliminate On Death", 30, height + 4, 1)
    if gGlobalSyncTable.eliminateOnDeath then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4, 1)
    end

    height = height + 60

    if selection == DO_VOTE_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Vote For Levels", 30, height + 4, 1)
    if gGlobalSyncTable.doVoting then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4, 1)
    end

    height = height + 60

    if selection == GAMEMODE_SETTINGS_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Gamemode Settings", 30, height + 4, 1)
    djui_hud_print_text(">", bgWidth - 30 - djui_hud_measure_text(">"), height + 4, 1)

    height = height + 60

    if selection == BLACKLIST_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Blacklist", 30, height + 4, 1)
    djui_hud_print_text(">", bgWidth - 30 - djui_hud_measure_text(">"), height + 4, 1)

    height = height + 60

    if selection == DONE_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Done", 30, height + 4, 1)
end

local function blacklist_options()
    local height = 150

    if selection == BLACKLIST_ADD_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Add", 30, height + 4, 1)

    height = height + 60

    if selection == BLACKLIST_BACK_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Back", 30, height + 4, 1)

    height = height + 60

    if blacklistedCourses[1] ~= nil then
        djui_hud_print_text("Courses", 30, height + 4, 1)
    end

    height = height + 60

    for i = 1, #blacklistedCourses do
        if selection == i + MAX_BLACKLIST_SELECTION then
            djui_hud_set_color(32, 32, 34, 225)
        else
            djui_hud_set_color(32, 32, 34, 128)
        end

        djui_hud_render_rect(20, height, bgWidth - 40, 40)
        djui_hud_set_color(220, 220, 220, 255)
        if isRomhack then
            djui_hud_print_text(name_of_level(course_to_level(blacklistedCourses[i]), 1), 30, height + 4, 1)
            djui_hud_print_text(tostring(blacklistedCourses[i]), bgWidth - 30 - djui_hud_measure_text(tostring(blacklistedCourses[i])), height + 4, 1)
        else
            djui_hud_print_text(name_of_level(levels[blacklistedCourses[i]].level, levels[blacklistedCourses[i]].area), 30, height + 4, 1)
            djui_hud_print_text(tostring(level_to_course(levels[blacklistedCourses[i]].level)), bgWidth - 30 - djui_hud_measure_text(tostring(level_to_course(levels[blacklistedCourses[i]].level))), height + 4, 1)
        end

        height = height + 60
    end
end

local function gamemode_options()
    local height = 150

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Tag", 30, height + 4, 1)

    height = height + 45

    if selection == GAMEMODE_TAG_TIMER_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Time Limit", 30, height + 4, 1)
    djui_hud_print_text(tostring(math.floor(gGlobalSyncTable.tagActiveTimer / 30)) .. "s", bgWidth - 30 - djui_hud_measure_text(tostring(math.floor(gGlobalSyncTable.tagActiveTimer / 30)) .. "s"), height + 4, 1)

    height = height + 45

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Freeze Tag", 30, height + 4, 1)

    height = height + 45

    if selection == GAMEMODE_FREEZE_TAG_TIMER_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Time Limit", 30, height + 4, 1)
    djui_hud_print_text(tostring(math.floor(gGlobalSyncTable.freezeTagActiveTimer / 30)) .. "s", bgWidth - 30 - djui_hud_measure_text(tostring(math.floor(gGlobalSyncTable.freezeTagActiveTimer / 30)) .. "s"), height + 4, 1)

    height = height + 60

    if selection == GAMEMODE_FROZEN_HEALTH_DRAIN_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Frozen Health Drain Speed", 30, height + 4, 1)
    djui_hud_print_text(tostring(gGlobalSyncTable.freezeHealthDrain), bgWidth - 30 - djui_hud_measure_text(tostring(gGlobalSyncTable.freezeHealthDrain)), height + 4, 1)

    height = height + 45

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Infection", 30, height + 4, 1)

    height = height + 45

    if selection == GAMEMODE_INFECTION_TIMER_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Time Limit", 30, height + 4, 1)
    djui_hud_print_text(tostring(math.floor(gGlobalSyncTable.infectionActiveTimer / 30)) .. "s", bgWidth - 30 - djui_hud_measure_text(tostring(math.floor(gGlobalSyncTable.infectionActiveTimer / 30)) .. "s"), height + 4, 1)

    height = height + 45

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Hot Potato", 30, height + 4, 1)

    height = height + 45

    if selection == GAMEMODE_HOT_POTATO_TIMER_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Hot Potato", 30, height + 4, 1)
    djui_hud_print_text(tostring(math.floor(gGlobalSyncTable.hotPotatoActiveTimer / 30)) .. "s", bgWidth - 30 - djui_hud_measure_text(tostring(math.floor(gGlobalSyncTable.hotPotatoActiveTimer / 30)) .. "s"), height + 4, 1)

    height = height + 45

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Juggernaut", 30, height + 4, 1)

    height = height + 45

    if selection == GAMEMODE_JUGGERNAUT_TIMER_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Time Limit", 30, height + 4, 1)
    djui_hud_print_text(tostring(math.floor(gGlobalSyncTable.juggernautActiveTimer / 30)) .. "s", bgWidth - 30 - djui_hud_measure_text(tostring(math.floor(gGlobalSyncTable.juggernautActiveTimer / 30)) .. "s"), height + 4, 1)

    height = height + 45

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Assassins", 30, height + 4, 1)

    height = height + 45

    if selection == GAMEMODE_ASSASSINS_TIMER_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Time Limit", 30, height + 4, 1)
    djui_hud_print_text(tostring(math.floor(gGlobalSyncTable.assassinsActiveTimer / 30)) .. "s", bgWidth - 30 - djui_hud_measure_text(tostring(math.floor(gGlobalSyncTable.assassinsActiveTimer / 30)) .. "s"), height + 4, 1)

    height = height + 120

    if selection == GAMEMODE_BACK_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Back", 30, height + 4, 1)
end

local function instructions()
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Up/Down to move up and down", 30, screenHeight - 150, 1)
    djui_hud_print_text("Left/Right to change settings", 30, screenHeight - 100, 1)
    djui_hud_print_text("A to select options", 30, screenHeight - 50, 1)
end

local function hud_render()

    if not showSettings then
        if network_is_server() then
            selection = MIN_SELECTION
        end
        showBlacklistSettings = false
        showGamemodeSettings = false
        return
    end

    screenHeight = djui_hud_get_screen_height()

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    background()
    settings_text()
    if showBlacklistSettings then
        blacklist_options()
    elseif showGamemodeSettings then
        gamemode_options()
    else
        options()
        instructions()
    end
end

---@param m MarioState
local function mario_update(m)
    if not showSettings then return end
    if m.playerIndex ~= 0 then return end
    if joystickCooldown > 0 then joystickCooldown = joystickCooldown - 1 end

    -- if our stick is at 0, then set joystickCooldown to 0
    if m.controller.stickX == 0 and m.controller.stickY == 0 then joystickCooldown = 0 end

    if m.controller.buttonPressed & D_JPAD ~= 0 or (m.controller.stickY < -0.5 and joystickCooldown <= 0) then
        selection = selection + 1
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        if showBlacklistSettings then
            if selection > MAX_BLACKLIST_SELECTION + #blacklistedCourses then
                selection = MIN_BLACKLIST_SELECTION
            end
        elseif showGamemodeSettings then
            if selection > MAX_GAMEMODE_SELECTION then
                selection = MIN_GAMEMODE_SELECTION
            end
        else
            if selection > MAX_SELECTION then
                selection = MIN_SELECTION
            end
        end

        joystickCooldown = 0.2 * 30
    elseif m.controller.buttonPressed & U_JPAD ~= 0 or (m.controller.stickY > 0.5 and joystickCooldown <= 0) then
        selection = selection - 1
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        if showBlacklistSettings then
            if selection < MIN_BLACKLIST_SELECTION then
                selection = MAX_BLACKLIST_SELECTION + #blacklistedCourses
            end
        elseif showGamemodeSettings then
            if selection < MIN_BLACKLIST_SELECTION then
                selection = MAX_GAMEMODE_SELECTION
            end
        else
            if selection < MIN_SELECTION then
                selection = MAX_SELECTION
            end
        end

        joystickCooldown = 0.2 * 30
    end

    if m.controller.buttonPressed & A_BUTTON ~= 0 then
        if showBlacklistSettings then
            if selection == BLACKLIST_BACK_SELECTION then
                showBlacklistSettings = false
                blacklistAddRequest = false
                selection = BLACKLIST_SELECTION
            elseif selection == BLACKLIST_ADD_SELECTION and network_is_server() then
                blacklistAddRequest = true
                djui_chat_message_create("Please run /tag course_name/course_index. To cancel, exit the blacklist menu")
            elseif selection > MAX_BLACKLIST_SELECTION and network_is_server() then
                table.remove(blacklistedCourses, selection - MAX_BLACKLIST_SELECTION)
                if selection > MAX_BLACKLIST_SELECTION + #blacklistedCourses then
                    selection = MAX_BLACKLIST_SELECTION + #blacklistedCourses
                end
            end
        elseif showGamemodeSettings then
            if selection == GAMEMODE_BACK_SELECTION then
                showGamemodeSettings = false
                selection = GAMEMODE_SETTINGS_SELECTION
            end
        else
            if selection == DONE_SELECTION then
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
                showSettings = false
                _G.tagSettingsOpen = false
            elseif selection == BLACKLIST_SELECTION then
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
                showBlacklistSettings = true
                selection = MIN_BLACKLIST_SELECTION
            elseif selection == GAMEMODE_SETTINGS_SELECTION then
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
                showGamemodeSettings = true
                selection = MIN_GAMEMODE_SELECTION
            end
        end
    end

    if (m.controller.buttonPressed & R_JPAD ~= 0 or (m.controller.stickX > 0.5 and joystickCooldown <= 0)) and network_is_server() then
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        if showGamemodeSettings then
            if selection == GAMEMODE_TAG_TIMER_SELECTION then
                gGlobalSyncTable.tagActiveTimer = gGlobalSyncTable.tagActiveTimer + 30
            elseif selection == GAMEMODE_FREEZE_TAG_TIMER_SELECTION then
                gGlobalSyncTable.freezeTagActiveTimer = gGlobalSyncTable.freezeTagActiveTimer + 30
            elseif selection == GAMEMODE_FROZEN_HEALTH_DRAIN_SELECTION then
                gGlobalSyncTable.freezeHealthDrain = gGlobalSyncTable.freezeHealthDrain + 0.1
            elseif selection == GAMEMODE_INFECTION_TIMER_SELECTION then
                gGlobalSyncTable.infectionActiveTimer = gGlobalSyncTable.infectionActiveTimer + 30
            elseif selection == GAMEMODE_HOT_POTATO_TIMER_SELECTION then
                gGlobalSyncTable.hotPotatoActiveTimer = gGlobalSyncTable.hotPotatoActiveTimer + 30
            elseif selection == GAMEMODE_JUGGERNAUT_TIMER_SELECTION then
                gGlobalSyncTable.juggernautActiveTimer = gGlobalSyncTable.juggernautActiveTimer + 30
            elseif selection == GAMEMODE_ASSASSINS_TIMER_SELECTION then
                gGlobalSyncTable.assassinsActiveTimer = gGlobalSyncTable.assassinsActiveTimer + 30
            end
        else
            if selection == GAMEMODE_SELECTION then
                local prevGamemode = gGlobalSyncTable.gamemode

                if gGlobalSyncTable.randomGamemode then
                    gGlobalSyncTable.gamemode = MIN_GAMEMODE
                    gGlobalSyncTable.randomGamemode = false
                else
                    if gGlobalSyncTable.gamemode + 1 > MAX_GAMEMODE then
                        gGlobalSyncTable.randomGamemode = true
                    else
                        gGlobalSyncTable.gamemode = gGlobalSyncTable.gamemode + 1
                    end
                end

                if gGlobalSyncTable.gamemode == 1 then
                    PLAYERS_NEEDED = 2
                else
                    PLAYERS_NEEDED = 3
                end

                if not gGlobalSyncTable.randomGamemode and gGlobalSyncTable.roundState == ROUND_ACTIVE and gGlobalSyncTable.gamemode ~= prevGamemode then
                    gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS
                end
            elseif selection == MODIFIER_SELECTION then
                local prevModifier = gGlobalSyncTable.modifier

                if gGlobalSyncTable.randomModifiers then
                    gGlobalSyncTable.modifier = MODIFIER_MIN
                    gGlobalSyncTable.randomModifiers = false
                else
                    if gGlobalSyncTable.modifier + 1 > MODIFIER_MAX then
                        gGlobalSyncTable.randomModifiers = true
                        if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then
                            gGlobalSyncTable.modifier = MODIFIER_NONE
                        end
                    else
                        gGlobalSyncTable.modifier = gGlobalSyncTable.modifier + 1
                    end
                end

                if not gGlobalSyncTable.randomModifiers and gGlobalSyncTable.roundState == ROUND_ACTIVE and gGlobalSyncTable.modifier ~= prevModifier then
                    gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS
                end
            elseif selection == BLJS_SELECTION then
                gGlobalSyncTable.bljs = not gGlobalSyncTable.bljs
            elseif selection == CANNON_SELECTION then
                gGlobalSyncTable.cannons = not gGlobalSyncTable.cannons
            elseif selection == WATER_SELECTION then
                gGlobalSyncTable.water = not gGlobalSyncTable.water
            elseif selection == ELIMINATE_ON_DEATH_SELECTION then
                gGlobalSyncTable.eliminateOnDeath = not gGlobalSyncTable.eliminateOnDeath
            elseif selection == DO_VOTE_SELECTION then
                gGlobalSyncTable.doVoting = not gGlobalSyncTable.doVoting
            end
        end

        joystickCooldown = 0.2 * 30
    elseif (m.controller.buttonPressed & L_JPAD ~= 0 or (m.controller.stickX < -0.5 and joystickCooldown <= 0)) and network_is_server() then
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        if showGamemodeSettings then
            if selection == GAMEMODE_TAG_TIMER_SELECTION then
                gGlobalSyncTable.tagActiveTimer = gGlobalSyncTable.tagActiveTimer - 30
                if gGlobalSyncTable.tagActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.tagActiveTimer = 30 * 30
                end
            elseif selection == GAMEMODE_FREEZE_TAG_TIMER_SELECTION then
                gGlobalSyncTable.freezeTagActiveTimer = gGlobalSyncTable.freezeTagActiveTimer - 30
                if gGlobalSyncTable.freezeTagActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.freezeTagActiveTimer = 30 * 30
                end
            elseif selection == GAMEMODE_FROZEN_HEALTH_DRAIN_SELECTION then
                gGlobalSyncTable.freezeHealthDrain = gGlobalSyncTable.freezeHealthDrain - 0.1
                if gGlobalSyncTable.freezeHealthDrain <= 0 then
                    gGlobalSyncTable.freezeHealthDrain = 0.1
                end
            elseif selection == GAMEMODE_INFECTION_TIMER_SELECTION then
                gGlobalSyncTable.infectionActiveTimer = gGlobalSyncTable.infectionActiveTimer - 30
                if gGlobalSyncTable.infectionActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.infectionActiveTimer = 30 * 30
                end
            elseif selection == GAMEMODE_HOT_POTATO_TIMER_SELECTION then
                gGlobalSyncTable.hotPotatoActiveTimer = gGlobalSyncTable.hotPotatoActiveTimer - 30
                if gGlobalSyncTable.hotPotatoActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.hotPotatoActiveTimer = 30 * 30
                end
            elseif selection == GAMEMODE_JUGGERNAUT_TIMER_SELECTION then
                gGlobalSyncTable.juggernautActiveTimer = gGlobalSyncTable.juggernautActiveTimer - 30
                if gGlobalSyncTable.juggernautActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.juggernautActiveTimer = 30 * 30
                end
            elseif selection == GAMEMODE_ASSASSINS_TIMER_SELECTION then
                gGlobalSyncTable.assassinsActiveTimer = gGlobalSyncTable.assassinsActiveTimer - 30
                if gGlobalSyncTable.assassinsActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.assassinsActiveTimer = 30 * 30
                end
            end
        else
            if selection == GAMEMODE_SELECTION then

                local prevGamemode = gGlobalSyncTable.gamemode

                if gGlobalSyncTable.randomGamemode then
                    gGlobalSyncTable.gamemode = MAX_GAMEMODE
                    gGlobalSyncTable.randomGamemode = false
                else
                    if gGlobalSyncTable.gamemode - 1 < MIN_GAMEMODE then
                        gGlobalSyncTable.randomGamemode = true
                    else
                        gGlobalSyncTable.gamemode = gGlobalSyncTable.gamemode - 1
                    end
                end

                if gGlobalSyncTable.gamemode == 1 then
                    PLAYERS_NEEDED = 2
                else
                    PLAYERS_NEEDED = 3
                end

                if not gGlobalSyncTable.randomGamemode and gGlobalSyncTable.roundState == ROUND_ACTIVE and gGlobalSyncTable.gamemode ~= prevGamemode then
                    gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS
                end
            elseif selection == MODIFIER_SELECTION then

                local prevModifier = gGlobalSyncTable.modifier

                if gGlobalSyncTable.randomModifiers then
                    gGlobalSyncTable.modifier = MODIFIER_MAX
                    gGlobalSyncTable.randomModifiers = false
                else
                    if gGlobalSyncTable.modifier - 1 < MODIFIER_MIN then
                        gGlobalSyncTable.randomModifiers = true
                    else
                        gGlobalSyncTable.modifier = gGlobalSyncTable.modifier - 1
                    end
                end

                if not gGlobalSyncTable.randomModifiers and gGlobalSyncTable.roundState == ROUND_ACTIVE and gGlobalSyncTable.gamemode ~= prevModifier then
                    gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS
                end
            elseif selection == BLJS_SELECTION then
                gGlobalSyncTable.bljs = not gGlobalSyncTable.bljs
            elseif selection == CANNON_SELECTION then
                gGlobalSyncTable.cannons = not gGlobalSyncTable.cannons
            elseif selection == WATER_SELECTION then
                gGlobalSyncTable.water = not gGlobalSyncTable.water
            elseif selection == ELIMINATE_ON_DEATH_SELECTION then
                gGlobalSyncTable.eliminateOnDeath = not gGlobalSyncTable.eliminateOnDeath
            elseif selection == DO_VOTE_SELECTION then
                gGlobalSyncTable.doVoting = not gGlobalSyncTable.doVoting
            end
        end

        joystickCooldown = 0.2 * 30
    end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)