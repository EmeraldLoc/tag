
showSettings = false
blacklistAddRequest = false
local showBlacklistSettings = false
local showGamemodeSettings = false
local showPlayerSettings = false
local showStartSettings = false
local hasSeenAutoInstructions = false
local scrollOffset = 0
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
local AUTO_MODE_SELECTION = 7
local BOOST_SELECTION = 8
local ROMHACK_CAM_SELECTION = 9
local PLAYERS_SELECTION = 10
local GAMEMODE_SETTINGS_SELECTION = 11
local BLACKLIST_SELECTION = 12
local START_SELECTION = 13
local DONE_SELECTION = 14
local MAX_SELECTION = 14
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
-- player settings selections
local MIN_PLAYERS_SELECTION = 0
local PLAYERS_BACK_SELECTION = MAX_PLAYERS
local MAX_PLAYERS_SELECTION = MAX_PLAYERS
-- start settings slections
local MIN_START_SELECTION = 0
local START_RANDOM_LEVEL_SELECTION = 0
local MAX_START_SELECTION = 1
if isRomhack then
    MAX_START_SELECTION = 15
    for i = COURSE_BOB, COURSE_RR do
        ---@diagnostic disable-next-line: param-type-mismatch
        if level_is_vanilla_level(course_to_level(i)) or table.contains(blacklistedCourses, i) then
            MAX_START_SELECTION = MAX_START_SELECTION - 1
        end
    end

    MAX_START_SELECTION = MAX_START_SELECTION + 1
else
    MAX_START_SELECTION = #levels + 1
end
local START_DONE_SELECTION = MAX_START_SELECTION
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
    elseif showPlayerSettings then
        text = "Player Settings"
    elseif showStartSettings then
        text = "Start A Round"
    else
        text = "Tag Settings"
    end
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text(text, (bgWidth / 2) - djui_hud_measure_text(text), 50 + scrollOffset, 2)
end

local function options()

    if selection >= 13 then
        scrollOffset = -(60 * (selection - 12))
    else
        scrollOffset = 0
    end

    local height = 150

    if selection == GAMEMODE_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Gamemode", 30, height + 4 + scrollOffset, 1)
    if gGlobalSyncTable.randomGamemode then
        djui_hud_print_text("Random", bgWidth - 30 - djui_hud_measure_text("Random"), height + 4 + scrollOffset, 1)
    else
        local r, g, b = get_gamemode_rgb_color()
        djui_hud_set_color(r, g, b, 255)
        djui_hud_print_text(get_gamemode_without_hex(), bgWidth - 30 - djui_hud_measure_text(get_gamemode_without_hex()), height + 4 + scrollOffset, 1)
    end

    height = height + 60

    if selection == MODIFIER_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Modifier", 30, height + 4 + scrollOffset, 1)
    if gGlobalSyncTable.randomModifiers then
        djui_hud_print_text("Random", bgWidth - 30 - djui_hud_measure_text("Random"), height + 4 + scrollOffset, 1)
    elseif gGlobalSyncTable.modifier == MODIFIER_NONE then
        djui_hud_print_text("Disabled", bgWidth - 30 - djui_hud_measure_text("Disabled"), height + 4 + scrollOffset, 1)
    else
        local r, g, b = get_modifier_rgb()
        djui_hud_set_color(r, g, b, 255)
        djui_hud_print_text(get_modifier_text_without_hex(), bgWidth - 30 - djui_hud_measure_text(get_modifier_text_without_hex()), height + 4 + scrollOffset, 1)
    end

    height = height + 60

    if selection == BLJS_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Blj", 30, height + 4 + scrollOffset, 1)
    if gGlobalSyncTable.bljs then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4 + scrollOffset, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4 + scrollOffset, 1)
    end

    height = height + 60

    if selection == CANNON_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Cannons", 30, height + 4 + scrollOffset, 1)
    if gGlobalSyncTable.cannons then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4 + scrollOffset, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4 + scrollOffset, 1)
    end

    height = height + 60

    if selection == WATER_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Water", 30, height + 4 + scrollOffset, 1)
    if gGlobalSyncTable.water then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4 + scrollOffset, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4 + scrollOffset, 1)
    end

    height = height + 60

    if selection == ELIMINATE_ON_DEATH_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Eliminate On Death", 30, height + scrollOffset + 4, 1)
    if gGlobalSyncTable.eliminateOnDeath then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4 + scrollOffset, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4 + scrollOffset, 1)
    end

    height = height + 60

    if selection == DO_VOTE_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if gGlobalSyncTable.autoMode and network_is_server() then
        djui_hud_set_color(220, 220, 220, 255)
    else
        djui_hud_set_color(150, 150, 150, 255)
    end
    djui_hud_print_text("Vote For Levels", 30, height + 4 + scrollOffset, 1)
    if gGlobalSyncTable.doVoting then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4 + scrollOffset, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4 + scrollOffset, 1)
    end

    height = height + 60

    if selection == AUTO_MODE_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Auto Mode", 30, height + 4 + scrollOffset, 1)
    if gGlobalSyncTable.autoMode then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4 + scrollOffset, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4 + scrollOffset, 1)
    end

    height = height + 60

    if selection == BOOST_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Boosting", 30, height + 4 + scrollOffset, 1)
    if gGlobalSyncTable.boosts then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4 + scrollOffset, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4 + scrollOffset, 1)
    end

    height = height + 60

    if selection == ROMHACK_CAM_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if isRomhack then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Romhack Camera", 30, height + 4 + scrollOffset, 1)

    if useRomhackCam then
        djui_hud_print_text("On", bgWidth - 30 - djui_hud_measure_text("On"), height + 4 + scrollOffset, 1)
    else
        djui_hud_print_text("Off", bgWidth - 30 - djui_hud_measure_text("Off"), height + 4 + scrollOffset, 1)
    end

    height = height + 60

    if selection == PLAYERS_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if gGlobalSyncTable.autoMode or not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Players", 30, height + 4 + scrollOffset, 1)
    djui_hud_print_text(">", bgWidth - 30 - djui_hud_measure_text(">"), height + 4 + scrollOffset, 1)

    height = height + 60

    if selection == GAMEMODE_SETTINGS_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Gamemode Settings", 30, height + 4 + scrollOffset, 1)
    djui_hud_print_text(">", bgWidth - 30 - djui_hud_measure_text(">"), height + 4 + scrollOffset, 1)

    height = height + 60

    if selection == BLACKLIST_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Blacklist", 30, height + 4 + scrollOffset, 1)
    djui_hud_print_text(">", bgWidth - 30 - djui_hud_measure_text(">"), height + 4 + scrollOffset, 1)

    height = height + 60

    if selection == START_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Start", 30, height + 4 + scrollOffset, 1)
    djui_hud_print_text(">", bgWidth - 30 - djui_hud_measure_text(">"), height + 4 + scrollOffset, 1)

    height = height + 60

    if selection == DONE_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Done", 30, height + 4 + scrollOffset, 1)
end

local function blacklist_options()
    local height = 150

    if selection == BLACKLIST_ADD_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
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
        if not network_is_server() then
            djui_hud_set_color(150, 150, 150, 255)
        else
            djui_hud_set_color(220, 220, 220, 255)
        end
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
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
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
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Time Limit", 30, height + 4, 1)
    djui_hud_print_text(tostring(math.floor(gGlobalSyncTable.freezeTagActiveTimer / 30)) .. "s", bgWidth - 30 - djui_hud_measure_text(tostring(math.floor(gGlobalSyncTable.freezeTagActiveTimer / 30)) .. "s"), height + 4, 1)

    height = height + 60

    if selection == GAMEMODE_FROZEN_HEALTH_DRAIN_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height, bgWidth - 40, 40)
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Frozen Health Drain Speed", 30, height + 4, 1)
    djui_hud_print_text(tostring(gGlobalSyncTable.freezeHealthDrain / 10), bgWidth - 30 - djui_hud_measure_text(tostring(gGlobalSyncTable.freezeHealthDrain / 10)), height + 4, 1)

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
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
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
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
    djui_hud_print_text("Time Limit", 30, height + 4, 1)
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
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
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
    if not network_is_server() then
        djui_hud_set_color(150, 150, 150, 255)
    else
        djui_hud_set_color(220, 220, 220, 255)
    end
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

local function players_options()

    -- set max selection and back selection var
    MAX_PLAYERS_SELECTION = network_player_connected_count()
    PLAYERS_BACK_SELECTION = MAX_PLAYERS_SELECTION

    local height = 150

    -- loop thru all players
    for i = 0, MAX_PLAYERS - 1 do
        if not gNetworkPlayers[i].connected then goto continue end
        if selection == i then
            djui_hud_set_color(32, 32, 34, 225)

            if selection >= 13 then
                scrollOffset = -(60 * (selection - 12))
            else
                scrollOffset = 0
            end
        else
            djui_hud_set_color(32, 32, 34, 128)
        end

        local r, g, b = hex_to_rgb(network_get_player_text_color_string(i))

        djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
        djui_hud_set_color(r, g, b, 255)
        djui_hud_print_text(strip_hex(gNetworkPlayers[i].name), 30, height + 4 + scrollOffset, 1)
        djui_hud_set_color(220, 220, 220, 255)
        djui_hud_print_text(get_role_name(gPlayerSyncTable[i].state), bgWidth - 30 - djui_hud_measure_text(get_role_name(gPlayerSyncTable[i].state)), height + 4 + scrollOffset, 1)

        height = height + 60

        ::continue::
    end

    if selection == PLAYERS_BACK_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)

        if selection >= 13 then
            scrollOffset = -(60 * (selection - 12))
        else
            scrollOffset = 0
        end
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Back", 30, height + scrollOffset + 4, 1)
end

local function start_options()

    if selection >= 13 then
        scrollOffset = -(60 * (selection - 12))
    else
        scrollOffset = 0
    end

    local height = 150

    if selection == START_RANDOM_LEVEL_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Random Level", 30, height + scrollOffset + 4, 1)

    height = height + 60

    local maxStartIndex = 0
    if isRomhack then
        maxStartIndex = COURSE_RR
    else
        maxStartIndex = #levels
    end

    local badIndexCount = 0

    for i = 1, maxStartIndex do

        if isRomhack then
            ---@diagnostic disable-next-line: param-type-mismatch
            if level_is_vanilla_level(course_to_level(i)) or table.contains(blacklistedCourses, i) then
                badIndexCount = badIndexCount + 1
                goto continue
            end
        else
            if table.contains(blacklistedCourses, level_to_course(levels[i].level)) then
                badIndexCount = badIndexCount + 1
                goto continue
            end
        end

        if selection == i - badIndexCount then
            djui_hud_set_color(32, 32, 34, 225)
        else
            djui_hud_set_color(32, 32, 34, 128)
        end

        djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
        djui_hud_set_color(220, 220, 220, 255)
        local text = ""
        if isRomhack then
            text = name_of_level(course_to_level(i), 1)
        else
            text = name_of_level(levels[i].level, levels[i].area)
        end
        djui_hud_print_text(text, 30, height + scrollOffset + 4, 1)

        height = height + 60

        ::continue::
    end

    if selection == START_DONE_SELECTION then
        djui_hud_set_color(32, 32, 34, 225)
    else
        djui_hud_set_color(32, 32, 34, 128)
    end

    djui_hud_render_rect(20, height + scrollOffset, bgWidth - 40, 40)
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("Cancel", 30, height + scrollOffset + 4, 1)
end

local function hud_render()

    if not showSettings then
        if network_is_server() then
            selection = MIN_SELECTION
        end
        showBlacklistSettings = false
        showGamemodeSettings = false
        showPlayerSettings = false
        showStartSettings = false
        scrollOffset = 0
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
    elseif showPlayerSettings then
        players_options()
    elseif showStartSettings then
        start_options()
    else
        options()
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
        elseif showPlayerSettings then
            if selection > MAX_PLAYERS_SELECTION then
                selection = MIN_PLAYERS_SELECTION
            end
        elseif showStartSettings then
            if selection > MAX_START_SELECTION then
                selection = MIN_START_SELECTION
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
        elseif showPlayerSettings then
            if selection < MIN_PLAYERS_SELECTION then
                selection = MAX_PLAYERS_SELECTION
            end
        elseif showStartSettings then
            if selection < MIN_START_SELECTION then
                selection = MAX_START_SELECTION
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
                scrollOffset = 0
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
                scrollOffset = 0
            end
        elseif showPlayerSettings then
            if selection == PLAYERS_BACK_SELECTION then
                showPlayerSettings = false
                selection = PLAYERS_SELECTION
                scrollOffset = 0
            end
        elseif showStartSettings then

            if selection == START_RANDOM_LEVEL_SELECTION then
                start_command("")
            end

            local maxStartIndex = 0
            if isRomhack then
                maxStartIndex = COURSE_RR
            else
                maxStartIndex = #levels
            end

            local badIndexCount = 0

            for i = 1, maxStartIndex do

                if isRomhack then
                    ---@diagnostic disable-next-line: param-type-mismatch
                    if level_is_vanilla_level(course_to_level(i)) or table.contains(blacklistedCourses, i) then
                        badIndexCount = badIndexCount + 1
                        goto continue
                    end
                else
                    if table.contains(blacklistedCourses, level_to_course(levels[i].level)) then
                        badIndexCount = badIndexCount + 1
                        goto continue
                    end
                end

                if selection == i - badIndexCount then
                    if isRomhack then
                        start_command(tostring(i))
                    else
                        start_command(tostring(levels[i].name))
                    end
                end

                ::continue::
            end

            if selection == START_DONE_SELECTION then
                showStartSettings = false
                selection = START_SELECTION
                scrollOffset = 0
            end
        else
            if selection == DONE_SELECTION then
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
                showSettings = false
                _G.tagSettingsOpen = false
            elseif selection == BLACKLIST_SELECTION then
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
                showBlacklistSettings = true
                scrollOffset = 0
                selection = MIN_BLACKLIST_SELECTION
            elseif selection == GAMEMODE_SETTINGS_SELECTION then
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
                showGamemodeSettings = true
                scrollOffset = 0
                selection = MIN_GAMEMODE_SELECTION
            elseif selection == PLAYERS_SELECTION and network_is_server() then
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
                showPlayerSettings = true
                scrollOffset = 0
                selection = MIN_PLAYERS_SELECTION
            elseif selection == START_SELECTION and network_is_server() then
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
                showStartSettings = true
                scrollOffset = 0
                selection = MIN_START_SELECTION
            end
        end
    end

    if (m.controller.buttonPressed & R_JPAD ~= 0 or (m.controller.stickX > 0.5 and joystickCooldown <= 0)) and network_is_server() then
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        if showGamemodeSettings then
            if selection == GAMEMODE_TAG_TIMER_SELECTION then
                if m.controller.buttonPressed & R_JPAD ~= 0 then
                    gGlobalSyncTable.tagActiveTimer = gGlobalSyncTable.tagActiveTimer + (30 * 10)
                else
                    gGlobalSyncTable.tagActiveTimer = gGlobalSyncTable.tagActiveTimer + 30
                end
            elseif selection == GAMEMODE_FREEZE_TAG_TIMER_SELECTION then
                if m.controller.buttonPressed & R_JPAD ~= 0 then
                    gGlobalSyncTable.freezeTagActiveTimer = gGlobalSyncTable.freezeTagActiveTimer + (30 * 10)
                else
                    gGlobalSyncTable.freezeTagActiveTimer = gGlobalSyncTable.freezeTagActiveTimer + 30
                end
            elseif selection == GAMEMODE_FROZEN_HEALTH_DRAIN_SELECTION then
                if m.controller.buttonPressed & R_JPAD ~= 0 then
                    gGlobalSyncTable.freezeHealthDrain = gGlobalSyncTable.freezeHealthDrain + 10
                else
                    gGlobalSyncTable.freezeHealthDrain = gGlobalSyncTable.freezeHealthDrain + 1
                end
            elseif selection == GAMEMODE_INFECTION_TIMER_SELECTION then
                if m.controller.buttonPressed & R_JPAD ~= 0 then
                    gGlobalSyncTable.infectionActiveTimer = gGlobalSyncTable.infectionActiveTimer + (30 * 10)
                else
                    gGlobalSyncTable.infectionActiveTimer = gGlobalSyncTable.infectionActiveTimer + 30
                end
            elseif selection == GAMEMODE_HOT_POTATO_TIMER_SELECTION then
                if m.controller.buttonPressed & R_JPAD ~= 0 then
                    gGlobalSyncTable.hotPotatoActiveTimer = gGlobalSyncTable.hotPotatoActiveTimer + (30 * 10)
                else
                    gGlobalSyncTable.hotPotatoActiveTimer = gGlobalSyncTable.hotPotatoActiveTimer + 30
                end
            elseif selection == GAMEMODE_JUGGERNAUT_TIMER_SELECTION then
                if m.controller.buttonPressed & R_JPAD ~= 0 then
                    gGlobalSyncTable.juggernautActiveTimer = gGlobalSyncTable.juggernautActiveTimer + (30 * 10)
                else
                    gGlobalSyncTable.juggernautActiveTimer = gGlobalSyncTable.juggernautActiveTimer + 30
                end
            elseif selection == GAMEMODE_ASSASSINS_TIMER_SELECTION then
                if m.controller.buttonPressed & R_JPAD ~= 0 then
                    gGlobalSyncTable.assassinsActiveTimer = gGlobalSyncTable.assassinsActiveTimer + (30 * 10)
                else
                    gGlobalSyncTable.assassinsActiveTimer = gGlobalSyncTable.assassinsActiveTimer + 30
                end
            end
        elseif showPlayerSettings then
            if selection ~= PLAYERS_BACK_SELECTION then
                gPlayerSyncTable[selection].state = gPlayerSyncTable[selection].state + 1
                if gPlayerSyncTable[selection].state > 3 then gPlayerSyncTable[selection].state = 0 end
                if gPlayerSyncTable[selection].state == 2 then gPlayerSyncTable[selection].state = 3 end
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
                if gGlobalSyncTable.autoMode then
                    gGlobalSyncTable.doVoting = not gGlobalSyncTable.doVoting
                end
            elseif selection == AUTO_MODE_SELECTION then
                gGlobalSyncTable.autoMode = not gGlobalSyncTable.autoMode

                if not hasSeenAutoInstructions then
                    djui_chat_message_create("Run /start to start a new game.\nTo start in a certain level, run /start (courseNum|abbreviation i.e bob)")
                    if not isRomhack then
                        djui_chat_message_create("The Interior of Shifting Sand Land level is \"issl\", and the Interior of Tiny Huge Island is \"ithi\"")
                    end

                    hasSeenAutoInstructions = true
                end
            elseif selection == BOOST_SELECTION then
                gGlobalSyncTable.boosts = not gGlobalSyncTable.boosts
            elseif selection == ROMHACK_CAM_SELECTION and not isRomhack then
                useRomhackCam = not useRomhackCam
            end
        end

        joystickCooldown = 0.2 * 30
    elseif m.controller.buttonPressed & R_JPAD ~= 0 or (m.controller.stickX > 0.5 and joystickCooldown <= 0) then
        if showGamemodeSettings then
            -- empty
        elseif showPlayerSettings then
            -- empty
        elseif showStartSettings then
            -- empty
        elseif showBlacklistSettings then
            -- empty
        else
            if selection == ROMHACK_CAM_SELECTION and not isRomhack then
                play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
                useRomhackCam = not useRomhackCam
            end
        end
    elseif (m.controller.buttonPressed & L_JPAD ~= 0 or (m.controller.stickX < -0.5 and joystickCooldown <= 0)) and network_is_server() then
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        if showGamemodeSettings then
            if selection == GAMEMODE_TAG_TIMER_SELECTION then
                if m.controller.buttonPressed & L_JPAD ~= 0 then
                    gGlobalSyncTable.tagActiveTimer = gGlobalSyncTable.tagActiveTimer - (30 * 10)
                else
                    gGlobalSyncTable.tagActiveTimer = gGlobalSyncTable.tagActiveTimer - 30
                end
                if gGlobalSyncTable.tagActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.tagActiveTimer = 30 * 30
                end
            elseif selection == GAMEMODE_FREEZE_TAG_TIMER_SELECTION then
                if m.controller.buttonPressed & L_JPAD ~= 0 then
                    gGlobalSyncTable.freezeTagActiveTimer = gGlobalSyncTable.freezeTagActiveTimer - (30 * 10)
                else
                    gGlobalSyncTable.freezeTagActiveTimer = gGlobalSyncTable.freezeTagActiveTimer - 30
                end
                if gGlobalSyncTable.freezeTagActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.freezeTagActiveTimer = 30 * 30
                end
            elseif selection == GAMEMODE_FROZEN_HEALTH_DRAIN_SELECTION then
                if m.controller.buttonPressed & L_JPAD ~= 0 then
                    gGlobalSyncTable.freezeHealthDrain = gGlobalSyncTable.freezeHealthDrain - 10
                else
                    gGlobalSyncTable.freezeHealthDrain = gGlobalSyncTable.freezeHealthDrain - 1
                end

                if gGlobalSyncTable.freezeHealthDrain <= 0 then
                    gGlobalSyncTable.freezeHealthDrain = 0
                end
            elseif selection == GAMEMODE_INFECTION_TIMER_SELECTION then
                if m.controller.buttonPressed & L_JPAD ~= 0 then
                    gGlobalSyncTable.infectionActiveTimer = gGlobalSyncTable.infectionActiveTimer - (30 * 10)
                else
                    gGlobalSyncTable.infectionActiveTimer = gGlobalSyncTable.infectionActiveTimer - 30
                end
                if gGlobalSyncTable.infectionActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.infectionActiveTimer = 30 * 30
                end
            elseif selection == GAMEMODE_HOT_POTATO_TIMER_SELECTION then
                if m.controller.buttonPressed & L_JPAD ~= 0 then
                    gGlobalSyncTable.hotPotatoActiveTimer = gGlobalSyncTable.hotPotatoActiveTimer - (30 * 10)
                else
                    gGlobalSyncTable.hotPotatoActiveTimer = gGlobalSyncTable.hotPotatoActiveTimer - 30
                end
                if gGlobalSyncTable.hotPotatoActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.hotPotatoActiveTimer = 30 * 30
                end
            elseif selection == GAMEMODE_JUGGERNAUT_TIMER_SELECTION then
                if m.controller.buttonPressed & L_JPAD ~= 0 then
                    gGlobalSyncTable.juggernautActiveTimer = gGlobalSyncTable.juggernautActiveTimer - (30 * 10)
                else
                    gGlobalSyncTable.juggernautActiveTimer = gGlobalSyncTable.juggernautActiveTimer - 30
                end
                if gGlobalSyncTable.juggernautActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.juggernautActiveTimer = 30 * 30
                end
            elseif selection == GAMEMODE_ASSASSINS_TIMER_SELECTION then
                if m.controller.buttonPressed & L_JPAD ~= 0 then
                    gGlobalSyncTable.assassinsActiveTimer = gGlobalSyncTable.assassinsActiveTimer - (30 * 10)
                else
                    gGlobalSyncTable.assassinsActiveTimer = gGlobalSyncTable.assassinsActiveTimer - 30
                end
                if gGlobalSyncTable.assassinsActiveTimer <= 30 * 30 then
                    gGlobalSyncTable.assassinsActiveTimer = 30 * 30
                end
            end
        elseif showPlayerSettings then
            if selection ~= PLAYERS_BACK_SELECTION then
                gPlayerSyncTable[selection].state = gPlayerSyncTable[selection].state - 1
                if gPlayerSyncTable[selection].state < 0 then gPlayerSyncTable[selection].state = 3 end
                if gPlayerSyncTable[selection].state == 2 then gPlayerSyncTable[selection].state = 1 end
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
                if gGlobalSyncTable.autoMode then
                    gGlobalSyncTable.doVoting = not gGlobalSyncTable.doVoting
                end
            elseif selection == AUTO_MODE_SELECTION then
                gGlobalSyncTable.autoMode = not gGlobalSyncTable.autoMode

                if not hasSeenAutoInstructions then
                    djui_chat_message_create("Run /start to start a new game.\nTo start in a certain level, run /start (courseNum|abbreviation i.e bob)")
                    if not isRomhack then
                        djui_chat_message_create("The Interior of Shifting Sand Land level is \"issl\", and the Interior of Tiny Huge Island is \"ithi\"")
                    end

                    hasSeenAutoInstructions = true
                end
            elseif selection == BOOST_SELECTION then
                gGlobalSyncTable.boosts = not gGlobalSyncTable.boosts
            elseif selection == ROMHACK_CAM_SELECTION and not isRomhack then
                useRomhackCam = not useRomhackCam
            end
        end

        joystickCooldown = 0.2 * 30
    elseif m.controller.buttonPressed & L_JPAD ~= 0 or (m.controller.stickX < -0.5 and joystickCooldown <= 0) then
        if showGamemodeSettings then
            -- empty
        elseif showPlayerSettings then
            -- empty
        elseif showStartSettings then
            -- empty
        elseif showBlacklistSettings then
            -- empty
        else
            if selection == ROMHACK_CAM_SELECTION and not isRomhack then
                play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
                useRomhackCam = not useRomhackCam
            end
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)