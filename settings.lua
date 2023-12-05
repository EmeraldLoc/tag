
showSettings = false
blacklistAddRequest = false
local showAntiCampSettings = false
local showBlacklistSettings = false
local noBlacklistTimer = 0
-- default selections
local MIN_SELECTION = 0
local GAMEMODE_SELECTION = 0
local MODIFIER_SELECTION = 1
local BLJS_SELECTION = 2
local CANNON_SELECTION = 3
local WATER_SELECTION = 4
local FROZEN_HEALTH_DRAIN_SELECTION = 5
local ANTI_CAMP_SELECTION = 6
local BLACKLIST_SELECTION = 7
local DONE_SELECTION = 8
local MAX_SELECTION = 8
-- anticamp selections
local MIN_ANTI_CAMP_SELECTION = 0
local ANTI_CAMP_STATUS_SELECTION = 0
local ANTI_CAMP_TIME_SELECTION = 1
local ANTI_CAMP_BACK_SELECTION = 2
local MAX_ANTI_CAMP_SELECTION = 2
-- blacklist selections
local MIN_BLACKLIST_SELECTION = 0
local BLACKLIST_ADD_SELECTION = 0
local BLACKLIST_BACK_SELECTION = 1
local MAX_BLACKLIST_SELECTION = 1
local screenHeight = 0
local bgWidth = 525
local selection = GAMEMODE_SELECTION
local gGlobalSoundSource = {x = 0, y = 0, z = 0}

local function background()
    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(0, 0, bgWidth, screenHeight)
end

local function settings_text()
    local text = ""
    if showAntiCampSettings then
        text = "Anticamp Settings"
    elseif showBlacklistSettings then
        text = "Blacklist Settings"
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
    if gGlobalSyncTable.doModifiers then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4, 1)
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

    if selection == FROZEN_HEALTH_DRAIN_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Frozen Health Drain Speed", 30, height + 4, 1)
    djui_hud_print_text(tostring(gGlobalSyncTable.freezeHealthDrain), bgWidth - 30 - djui_hud_measure_text(tostring(gGlobalSyncTable.freezeHealthDrain)), height + 4, 1)

    height = height + 60

    if selection == ANTI_CAMP_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Anticamp", 30, height + 4, 1)
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

local function anticamp_options()

    local height = 150

    if selection == ANTI_CAMP_STATUS_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Status", 30, height + 4, 1)
    if gGlobalSyncTable.antiCamp then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4, 1)
    end

    height = height + 60

    if selection == ANTI_CAMP_TIME_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Time", 30, height + 4, 1)
    djui_hud_print_text(tostring(math.floor(gGlobalSyncTable.antiCampTimer / 30)), bgWidth - 30 - djui_hud_measure_text(tostring(math.floor(gGlobalSyncTable.antiCampTimer / 30))), height + 4, 1)

    height = height + 60

    if selection == ANTI_CAMP_BACK_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Back", 30, height + 4, 1)
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
        djui_hud_print_text(get_level_name(blacklistedCourses[i], course_to_level(blacklistedCourses[i]), 1), 30, height + 4, 1)
        djui_hud_print_text(tostring(blacklistedCourses[i]), bgWidth - 30 - djui_hud_measure_text(tostring(blacklistedCourses[i])), height + 4, 1)

        height = height + 60
    end
end

local function instructions()
    if noBlacklistTimer > 0 then
        djui_hud_set_color(220, 220, 220, 255)
        djui_hud_print_text("You can't use the blacklist setting without a romhack", 30, screenHeight - 50, 1)
    else
        djui_hud_set_color(220, 220, 220, 255)
        djui_hud_print_text("DPAD Up/Down to move up and down", 30, screenHeight - 150, 1)
        djui_hud_print_text("DPAD Left/Right to change settings", 30, screenHeight - 100, 1)
        djui_hud_print_text("A to select options", 30, screenHeight - 50, 1)
    end
end

local function hud_render()

    if not showSettings then
        if network_is_server() then
            selection = MIN_SELECTION
        else
            selection = ANTI_CAMP_SELECTION
        end
        showAntiCampSettings = false
        showBlacklistSettings = false
        return
    end

    screenHeight = djui_hud_get_screen_height()

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    background()
    settings_text()
    if showAntiCampSettings then
        anticamp_options()
        instructions()
    elseif showBlacklistSettings then
        blacklist_options()
    else
        options()
        instructions()
    end
end

---@param m MarioState
local function mario_update(m)
    if not showSettings then return end
    if m.playerIndex ~= 0 then return end

    if noBlacklistTimer > 0 then
        noBlacklistTimer = noBlacklistTimer - 1
    end

    if m.controller.buttonPressed & D_JPAD ~= 0 then
        selection = selection + 1
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        if showAntiCampSettings then
            if network_is_server() then
                if selection > MAX_ANTI_CAMP_SELECTION then
                    selection = MIN_ANTI_CAMP_SELECTION
                end
            else
                selection = ANTI_CAMP_BACK_SELECTION
            end
        elseif showBlacklistSettings then
            if network_is_server() then
                if selection > MAX_BLACKLIST_SELECTION + #blacklistedCourses then
                    selection = MIN_BLACKLIST_SELECTION
                end
            else
                selection = BLACKLIST_BACK_SELECTION
            end
        else
            if network_is_server() then
                if selection > MAX_SELECTION then
                    selection = MIN_SELECTION
                end
            else
                if selection > MAX_SELECTION then
                    selection = ANTI_CAMP_SELECTION
                end
            end
        end
    elseif m.controller.buttonPressed & U_JPAD ~= 0 then
        selection = selection - 1
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        if showAntiCampSettings then
            if network_is_server() then
                if selection < MIN_ANTI_CAMP_SELECTION then
                    selection = MAX_ANTI_CAMP_SELECTION
                end
            else
                selection = ANTI_CAMP_BACK_SELECTION
            end
        elseif showBlacklistSettings then
            if network_is_server() then
                if selection < MIN_BLACKLIST_SELECTION then
                    selection = MAX_BLACKLIST_SELECTION + #blacklistedCourses
                end
            else
                selection = BLACKLIST_BACK_SELECTION
            end
        else
            if network_is_server() then
                if selection < MIN_SELECTION then
                    selection = MAX_SELECTION
                end
            else
                if selection < ANTI_CAMP_SELECTION then
                    selection = MAX_SELECTION
                end
            end
        end
    end

    if m.controller.buttonPressed & A_BUTTON ~= 0 then
        if showAntiCampSettings then
            if selection == ANTI_CAMP_BACK_SELECTION then
                showAntiCampSettings = false
                selection = ANTI_CAMP_SELECTION
            end
        elseif showBlacklistSettings then
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
        else
            if selection == DONE_SELECTION then
                showSettings = false
                _G.tagSettingsOpen = false
            elseif selection == ANTI_CAMP_SELECTION then
                showAntiCampSettings = true
                selection = MIN_ANTI_CAMP_SELECTION
            elseif selection == BLACKLIST_SELECTION then
                if isRomhack then
                    showBlacklistSettings = true
                    selection = MIN_BLACKLIST_SELECTION
                else
                    noBlacklistTimer = 5 * 30
                end
            end
        end
    end

    if m.controller.buttonPressed & R_JPAD ~= 0 and network_is_server() then
        if showAntiCampSettings then
            if selection == ANTI_CAMP_STATUS_SELECTION then
                gGlobalSyncTable.antiCamp = not gGlobalSyncTable.antiCamp
            elseif selection == ANTI_CAMP_TIME_SELECTION then
                gGlobalSyncTable.antiCampTimer = gGlobalSyncTable.antiCampTimer + 30
            end
        else
            if selection == GAMEMODE_SELECTION then
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
            elseif selection == MODIFIER_SELECTION then
                gGlobalSyncTable.doModifiers = not gGlobalSyncTable.doModifiers
            elseif selection == BLJS_SELECTION then
                gGlobalSyncTable.bljs = not gGlobalSyncTable.bljs
            elseif selection == CANNON_SELECTION then
                gGlobalSyncTable.cannons = not gGlobalSyncTable.cannons
            elseif selection == WATER_SELECTION then
                gGlobalSyncTable.water = not gGlobalSyncTable.water
            elseif selection == FROZEN_HEALTH_DRAIN_SELECTION then
                gGlobalSyncTable.freezeHealthDrain = gGlobalSyncTable.freezeHealthDrain + 0.1
            end
        end
    elseif m.controller.buttonPressed & L_JPAD ~= 0 and network_is_server() then
        if showAntiCampSettings then
            if selection == ANTI_CAMP_STATUS_SELECTION then
                gGlobalSyncTable.antiCamp = not gGlobalSyncTable.antiCamp
            elseif selection == ANTI_CAMP_TIME_SELECTION then
                gGlobalSyncTable.antiCampTimer = gGlobalSyncTable.antiCampTimer - 30
                if gGlobalSyncTable.antiCampTimer < 30 then gGlobalSyncTable.antiCampTimer = 30 end
            end
        else
            if selection == GAMEMODE_SELECTION then
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
            elseif selection == MODIFIER_SELECTION then
                gGlobalSyncTable.doModifiers = not gGlobalSyncTable.doModifiers
            elseif selection == BLJS_SELECTION then
                gGlobalSyncTable.bljs = not gGlobalSyncTable.bljs
            elseif selection == CANNON_SELECTION then
                gGlobalSyncTable.cannons = not gGlobalSyncTable.cannons
            elseif selection == WATER_SELECTION then
                gGlobalSyncTable.water = not gGlobalSyncTable.water
            elseif selection == FROZEN_HEALTH_DRAIN_SELECTION then
                gGlobalSyncTable.freezeHealthDrain = gGlobalSyncTable.freezeHealthDrain - 0.1
                if gGlobalSyncTable.freezeHealthDrain < 0.5 then gGlobalSyncTable.freezeHealthDrain = 0.5 end
            end
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)