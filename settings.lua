
showSettings = false
blacklistAddRequest = false

-- inputs
INPUT_A = 0
INPUT_JOYSTICK = 1

local scrollOffset = 0
local joystickCooldown = 0
local screenHeight = djui_hud_get_screen_height()
local bgWidth = 525
local selection = 1
local awaitingInput = nil

local function on_off_text(bool)
    if bool then return "On" else return "Off" end
end

local function get_r_from(r, g, b)
    return r
end

local function get_g_from(r, g, b)
    return g
end

local function get_b_from(r, g, b)
    return b
end

local function get_gamemode_including_random()
    if gGlobalSyncTable.randomGamemode then return "Random" end
    return get_gamemode_without_hex()
end

local function get_gamemode_rgb_inc_random()
    if gGlobalSyncTable.randomGamemode then
        return 220, 220, 220
    end

    return get_gamemode_rgb_color()
end

local function get_modifier_including_random()
    if gGlobalSyncTable.randomModifiers then return "Random" end
    return get_modifier_text_without_hex()
end

local function get_modifier_rgb_inc_random()
    if gGlobalSyncTable.randomModifiers then
        return 220, 220, 220
    end

    return get_modifier_rgb()
end

-- click functions
local function set_gamemode()
    if (gMarioStates[0].controller.buttonPressed & R_JPAD ~= 0
    or (gMarioStates[0].controller.stickX > 0.5 and joystickCooldown <= 0)) then

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
    else
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
    end
end

local function set_modifier()
    if (gMarioStates[0].controller.buttonPressed & R_JPAD ~= 0
    or (gMarioStates[0].controller.stickX > 0.5 and joystickCooldown <= 0)) then
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
    else
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
    end
end

local function toggle_bljs()
    gGlobalSyncTable.bljs = not gGlobalSyncTable.bljs
    entries[selection].valueText = on_off_text(gGlobalSyncTable.bljs)
end

local function toggle_cannons()
    gGlobalSyncTable.cannons = not gGlobalSyncTable.cannons
    entries[selection].valueText = on_off_text(gGlobalSyncTable.cannons)
end

local function toggle_water()
    gGlobalSyncTable.water = not gGlobalSyncTable.water
    entries[selection].valueText = on_off_text(gGlobalSyncTable.water)
end

local function toggle_eliminate_on_death()
    gGlobalSyncTable.eliminateOnDeath = not gGlobalSyncTable.eliminateOnDeath
    entries[selection].valueText = on_off_text(gGlobalSyncTable.eliminateOnDeath)
end

local function toggle_voting()
    gGlobalSyncTable.doVoting = not gGlobalSyncTable.doVoting
    entries[selection].valueText = on_off_text(gGlobalSyncTable.doVoting)
end

local function toggle_auto_mode()
    gGlobalSyncTable.autoMode = not gGlobalSyncTable.autoMode
    entries[selection].valueText = on_off_text(gGlobalSyncTable.autoMode)
end

local function toggle_boost()
    gGlobalSyncTable.boosts = not gGlobalSyncTable.boosts
    entries[selection].valueText = on_off_text(gGlobalSyncTable.boosts)
end

local function toggle_hazards()
    gGlobalSyncTable.hazardSurfaces = not gGlobalSyncTable.hazardSurfaces
    entries[selection].valueText = on_off_text(gGlobalSyncTable.hazardSurfaces)
end

local function toggle_romhack_cam()
    useRomhackCam = not useRomhackCam
    entries[selection].valueText = on_off_text(useRomhackCam)
    mod_storage_save("useRomhackCam", tostring(useRomhackCam))
end

local function set_time_limit(gamemode)
    -- get which direction we are facing
    local m = gMarioStates[0]
    local direction = CONT_LEFT

    if m.controller.buttonPressed & R_JPAD ~= 0
    or m.controller.stickX > 0.5 then direction = CONT_RIGHT end

    -- get speed
    local speed = 1

    if m.controller.buttonPressed & R_JPAD ~= 0
    or m.controller.buttonPressed & L_JPAD ~= 0 then
        speed = 10
    end

    -- TODO: Make this way cleaner (if your reading this then chances are i've released the mod
    -- and past me is not proud of myself, but hey SCREW PAST ME THAT GUY SUCKS HAHAHAH)
    -- seriously though don't take this as an example for your mods, please, please make
    -- it organized and compressed, and don't underlook functions, they are HUGE

    -- New developments: Future me here. What the heck is the abomination of junky code
    -- What the hell was past me thinking, holy crap, this code SUCKS
    -- I aint redoing it, cuz it works, but this is the most crappy piece of junk
    -- i've seen all day

    -- Future me, it's March 10th, tag v2.2 is released, and i'm getting ready
    -- to release 2.21. What the hell is this. This could've been optimized heavily.
    -- I don't think the ranting I did above is justified, its not thaat bad.
    -- If it ain't broke, don't fix it

    -- set variable based off of dir and speed
    if gamemode == TAG then
        if direction == CONT_LEFT then
            gGlobalSyncTable.tagActiveTimer = gGlobalSyncTable.tagActiveTimer - (30 * speed)

            if gGlobalSyncTable.tagActiveTimer <= 30 * 30 then
                gGlobalSyncTable.tagActiveTimer = 30 * 30
            end
        else
            gGlobalSyncTable.tagActiveTimer = gGlobalSyncTable.tagActiveTimer + (30 * speed)
        end

        entries[selection].valueText = tostring(math.floor(gGlobalSyncTable.tagActiveTimer / 30)) .. "s"
    elseif gamemode == FREEZE_TAG then
        if direction == CONT_LEFT then
            gGlobalSyncTable.freezeTagActiveTimer = gGlobalSyncTable.freezeTagActiveTimer - (30 * speed)

            if gGlobalSyncTable.freezeTagActiveTimer <= 30 * 30 then
                gGlobalSyncTable.freezeTagActiveTimer = 30 * 30
            end
        else
            gGlobalSyncTable.freezeTagActiveTimer = gGlobalSyncTable.freezeTagActiveTimer + (30 * speed)
        end

        entries[selection].valueText = tostring(math.floor(gGlobalSyncTable.freezeTagActiveTimer / 30)) .. "s"
    elseif gamemode == INFECTION then
        if direction == CONT_LEFT then
            gGlobalSyncTable.infectionActiveTimer = gGlobalSyncTable.infectionActiveTimer - (30 * speed)

            if gGlobalSyncTable.infectionActiveTimer <= 30 * 30 then
                gGlobalSyncTable.infectionActiveTimer = 30 * 30
            end
        else
            gGlobalSyncTable.infectionActiveTimer = gGlobalSyncTable.infectionActiveTimer + (30 * speed)
        end

        entries[selection].valueText = tostring(math.floor(gGlobalSyncTable.infectionActiveTimer / 30)) .. "s"
    elseif gamemode == HOT_POTATO then
        if direction == CONT_LEFT then
            gGlobalSyncTable.hotPotatoActiveTimer = gGlobalSyncTable.hotPotatoActiveTimer - (30 * speed)

            if gGlobalSyncTable.hotPotatoActiveTimer <= 30 * 30 then
                gGlobalSyncTable.hotPotatoActiveTimer = 30 * 30
            end
        else
            gGlobalSyncTable.hotPotatoActiveTimer = gGlobalSyncTable.hotPotatoActiveTimer + (30 * speed)
        end

        entries[selection].valueText = tostring(math.floor(gGlobalSyncTable.hotPotatoActiveTimer / 30)) .. "s"
    elseif gamemode == JUGGERNAUT then
        if direction == CONT_LEFT then
            gGlobalSyncTable.juggernautActiveTimer = gGlobalSyncTable.juggernautActiveTimer - (30 * speed)

            if gGlobalSyncTable.juggernautActiveTimer <= 30 * 30 then
                gGlobalSyncTable.juggernautActiveTimer = 30 * 30
            end
        else
            gGlobalSyncTable.juggernautActiveTimer = gGlobalSyncTable.juggernautActiveTimer + (30 * speed)
        end

        entries[selection].valueText = tostring(math.floor(gGlobalSyncTable.juggernautActiveTimer / 30)) .. "s"
    elseif gamemode == ASSASSINS then
        if direction == CONT_LEFT then
            gGlobalSyncTable.assassinsActiveTimer = gGlobalSyncTable.assassinsActiveTimer - (30 * speed)

            if gGlobalSyncTable.assassinsActiveTimer <= 30 * 30 then
                gGlobalSyncTable.assassinsActiveTimer = 30 * 30
            end
        else
            gGlobalSyncTable.assassinsActiveTimer = gGlobalSyncTable.assassinsActiveTimer + (30 * speed)
        end

        entries[selection].valueText = tostring(math.floor(gGlobalSyncTable.assassinsActiveTimer / 30)) .. "s"
    end
end

local function set_frozen_health_drain()

    -- get which direction we are facing
    local m = gMarioStates[0]
    local direction = CONT_LEFT

    if m.controller.buttonPressed & R_JPAD ~= 0
    or m.controller.stickX > 0.5 then direction = CONT_RIGHT end

    -- get speed
    local speed = 1

    if m.controller.buttonPressed & R_JPAD ~= 0
    or m.controller.buttonPressed & L_JPAD ~= 0 then
        speed = 10
    end

    if direction == CONT_LEFT then
        gGlobalSyncTable.freezeHealthDrain = gGlobalSyncTable.freezeHealthDrain - speed

        if gGlobalSyncTable.freezeHealthDrain <= 0 then
            gGlobalSyncTable.freezeHealthDrain = 0
        end
    else
        gGlobalSyncTable.freezeHealthDrain = gGlobalSyncTable.freezeHealthDrain + speed
    end

    entries[selection].valueText = tostring(gGlobalSyncTable.freezeHealthDrain / 10)
end


local function stop_round()
    gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS

    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
            gPlayerSyncTable[i].state = RUNNER
        end
    end
end

local function stop_round_disabled()
    if gGlobalSyncTable.autoMode then return true end
    return false
end

local function set_player_role(i)
    -- get which direction we are facing
    local m = gMarioStates[0]
    local direction = CONT_LEFT

    if m.controller.buttonPressed & R_JPAD ~= 0
    or m.controller.stickX > 0.5 then direction = CONT_RIGHT end
    if direction == CONT_LEFT then
        gPlayerSyncTable[i].state = gPlayerSyncTable[i].state - 1
        if gPlayerSyncTable[i].state < 0 then gPlayerSyncTable[i].state = 3 end
        if gPlayerSyncTable[i].state == 2 then gPlayerSyncTable[i].state = 1 end
    else
        gPlayerSyncTable[i].state = gPlayerSyncTable[i].state + 1
        if gPlayerSyncTable[i].state > 3 then gPlayerSyncTable[i].state = 0 end
        if gPlayerSyncTable[i].state == 2 then gPlayerSyncTable[i].state = 3 end
    end
end

local function get_rules(gamemode)
    if gamemode ~= nil then
        local text = get_rules_for_gamemode(gamemode)
        entries = {
            {text = text},
            {name = "Back",
            permission = PERMISSION_NONE,
            input = INPUT_A,
            func = function ()
                entries = helpEntries
                selection = 1
            end}}
        selection = 1
    else
        local text = get_general_rules()
        entries = {
            {text = text},
            {name = "Back",
            permission = PERMISSION_NONE,
            input = INPUT_A,
            func = function ()
                entries = helpEntries
                selection = 1
            end}}
        selection = 1
    end
end

local function wait_for_button(bindIndex)
    if binds[bindIndex] == nil then return end

    awaitingInput = bindIndex
end

-- default selections
settingsEntries = {}
-- gamemode entries
gamemodeEntries = {}
-- start round selections
startEntries = {}
-- players
playerEntries = {}
-- blacklisted levels
blacklistEntries = {}
-- binds
bindsEntries = {}

-- help entries
-- generate it here as it is never changed
helpEntries = {
    {name = "General",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        get_rules(nil)
    end,},

    {name = "Tag",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        get_rules(TAG)
    end},

    {name = "Freeze Tag",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        get_rules(FREEZE_TAG)
    end},

    {name = "Infection",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        get_rules(INFECTION)
    end},

    {name = "Hot Potato",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        get_rules(HOT_POTATO)
    end},

    {name = "Juggernaut",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        get_rules(JUGGERNAUT)
    end},

    {name = "Assassins",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        get_rules(ASSASSINS)
    end},

    {name = "Spectating",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        local text = get_spectator_help()
        entries = {
            {text = text},
            {name = "Back",
            permission = PERMISSION_NONE,
            input = INPUT_A,
            func = function ()
                entries = helpEntries
                selection = 1
            end}}
        selection = 1
    end},

    {name = "Back",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        entries = settingsEntries
        selection = 1
    end,}
}

entries = settingsEntries

local function background()
    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(0, 0, bgWidth, screenHeight)
end

local function settings_text()
    local text = "Tag Settings"
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text(text, (bgWidth / 2) - djui_hud_measure_text(text), 50 - scrollOffset, 2)
end

local function reset_settings_selection()

    local resetSettingsEntries = false

    if entries == settingsEntries then
        resetSettingsEntries = true
    end

    settingsEntries = {
        -- start selection
        {name = "Start",
        permission = PERMISSION_NONE,
        input = INPUT_A,
        func = function ()
            entries = startEntries
            selection = 1
        end,
        valueText = ">",},
        -- gamemode selection
        {name = "Gamemode",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = set_gamemode,
        valueText = get_gamemode_including_random(),
        valueTextColor = {
            r = get_r_from(get_gamemode_rgb_inc_random()),
            g = get_g_from(get_gamemode_rgb_inc_random()),
            b = get_b_from(get_gamemode_rgb_inc_random())}
        },
        -- modifier selection
        {name = "Modifiers",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = set_modifier,
        valueText = get_modifier_including_random(),
        valueTextColor = {
            r = get_r_from(get_modifier_rgb_inc_random()),
            g = get_g_from(get_modifier_rgb_inc_random()),
            b = get_b_from(get_modifier_rgb_inc_random())}
        },
        -- blj selection
        {name = "Bljs",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = toggle_bljs,
        valueText = on_off_text(gGlobalSyncTable.bljs),},
        -- cannon selection
        {name = "Cannons",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = toggle_cannons,
        valueText = on_off_text(gGlobalSyncTable.cannons),},
        -- water selection
        {name = "Water",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = toggle_water,
        valueText = on_off_text(gGlobalSyncTable.water),},
        -- eliminate on death selection
        {name = "Eliminate On Death",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = toggle_eliminate_on_death,
        valueText = on_off_text(gGlobalSyncTable.eliminateOnDeath),},
        -- vote selection
        {name = "Voting",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = toggle_voting,
        valueText = on_off_text(gGlobalSyncTable.doVoting),},
        -- auto mode selection
        {name = "Auto Mode",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = toggle_auto_mode,
        valueText = on_off_text(gGlobalSyncTable.autoMode),},
        -- boost mode selection
        {name = "Boost",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = toggle_boost,
        valueText = on_off_text(gGlobalSyncTable.boosts),},
        -- hazard selection
        {name = "Hazardous Surfaces",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = toggle_hazards,
        valueText = on_off_text(gGlobalSyncTable.hazardSurfaces),},
        -- romhack camera selection
        {name = "Romhack Camera",
        permission = PERMISSION_NONE,
        input = INPUT_JOYSTICK,
        func = toggle_romhack_cam,
        valueText = on_off_text(useRomhackCam),},
        -- gamemode settings selection
        {name = "Gamemode Settings",
        permission = PERMISSION_NONE,
        input = INPUT_A,
        func = function ()
            entries = gamemodeEntries
            selection = 1
        end,
        valueText = ">",},
        -- players selection
        {name = "Players",
        permission = PERMISSION_NONE,
        input = INPUT_A,
        func = function ()
            entries = playerEntries
            selection = 1
        end,
        valueText = ">",},
        -- blacklist selection
        {name = "Blacklist",
        permission = PERMISSION_SERVER,
        input = INPUT_A,
        func = function ()
            entries = blacklistEntries
            selection = 1
        end,
        valueText = ">",},
        -- binds selection
        {name = "Bindings",
        permission = PERMISSION_NONE,
        input = INPUT_A,
        func = function ()
            entries = bindsEntries
            selection = 1
        end,
        valueText = ">",},
        -- help selection
        {name = "Help",
        permission = PERMISSION_NONE,
        input = INPUT_A,
        func = function ()
            entries = helpEntries
            selection = 1
        end,
        valueText = ">",},
        -- done selection
        {name = "Done",
        permission = PERMISSION_NONE,
        input = INPUT_A,
        func = function () showSettings = not showSettings end,
        valueText = nil,},
    }

    if resetSettingsEntries then
        entries = settingsEntries
    end
end

local function reset_gamemode_selection()
    local resetGamemodeEntries = false

    if entries == gamemodeEntries then
        resetGamemodeEntries = true
    end

    -- gamemode entries
    gamemodeEntries = {
        -- time limit selection
        {name = "Time Limit",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = function () set_time_limit(TAG) end,
        valueText = tostring(math.floor(gGlobalSyncTable.tagActiveTimer / 30)) .. "s",
        seperator = "Tag"}, -- this seperator seperates 2 sections. It goes above the button.

        {name = "Time Limit",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = function () set_time_limit(FREEZE_TAG) end,
        valueText = tostring(math.floor(gGlobalSyncTable.freezeTagActiveTimer / 30)) .. "s",
        seperator = "Freeze Tag"},

        {name = "Frozen Health Drain",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = set_frozen_health_drain,
        valueText = tostring(gGlobalSyncTable.freezeHealthDrain / 10),},

        {name = "Time Limit",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = function () set_time_limit(INFECTION) end,
        valueText = tostring(math.floor(gGlobalSyncTable.infectionActiveTimer / 30)) .. "s",
        seperator = "Infection"},

        {name = "Time Limit",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = function () set_time_limit(HOT_POTATO) end,
        valueText = tostring(math.floor(gGlobalSyncTable.hotPotatoActiveTimer / 30)) .. "s",
        seperator = "Hot Potato"},

        {name = "Time Limit",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = function () set_time_limit(JUGGERNAUT) end,
        valueText = tostring(math.floor(gGlobalSyncTable.juggernautActiveTimer / 30)) .. "s",
        seperator = "Juggernaut"},

        {name = "Time Limit",
        permission = PERMISSION_SERVER,
        input = INPUT_JOYSTICK,
        func = function () set_time_limit(ASSASSINS) end,
        valueText = tostring(math.floor(gGlobalSyncTable.assassinsActiveTimer / 30)) .. "s",
        seperator = "Assassins"},

        {name = "Back",
        permission = PERMISSION_NONE,
        input = INPUT_A,
        func = function ()
            entries = settingsEntries
            selection = 1
        end,
        seperator = ""} -- empty seperator is just spacing,
    }

    if resetGamemodeEntries then
        entries = gamemodeEntries
    end
end

local function reset_start_selection()

    local resetEntryVariable = false

    if entries == startEntries then
        resetEntryVariable = true
    end

    startEntries = {
        {name = "Random",
        permission = PERMISSION_SERVER,
        input = INPUT_A,
        func = function () start_command("") end,}
    }

    if not isRomhack then
        for i = 1, #levels do
            if not table.contains(blacklistedCourses, i) then
                table.insert(startEntries,
                {name = name_of_level(levels[i].level, levels[i].area),
                permission = PERMISSION_SERVER,
                input = INPUT_A,
                func = function ()
                    start_command(levels[i].name)
                end})
            end
        end
    else
        for i = COURSE_BOB, COURSE_RR do
            if not level_is_vanilla_level(course_to_level(i)) and not table.contains(blacklistedCourses, i) then
                table.insert(startEntries,
                {name = name_of_level(course_to_level(i), 1),
                permission = PERMISSION_SERVER,
                input = INPUT_A,
                func = function ()
                    start_command(tostring(i))
                end})
            end
        end
    end

    table.insert(startEntries,
    {name = "Stop Round",
    permission = PERMISSION_SERVER,
    input = INPUT_A,
    disabled = stop_round_disabled,
    func = stop_round,
    })

    table.insert(startEntries,
    {name = "Back",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        entries = settingsEntries
        selection = 1
    end,})

    if resetEntryVariable then
        entries = startEntries

        if selection > #entries then selection = #entries end
    end
end

local function reset_player_selection()

    local resetEntryVariable = false

    if entries == playerEntries then
        resetEntryVariable = true
    end

    playerEntries = {}

    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then

            local playerR, playerG, playerB = hex_to_rgb(network_get_player_text_color_string(i))

            table.insert(playerEntries,
            {name = gNetworkPlayers[i].name,
            permission = PERMISSION_SERVER,
            input = INPUT_JOYSTICK,
            func = function() set_player_role(i) end,
            valueText = get_role_name(gPlayerSyncTable[i].state),
            color = {r = playerR, g = playerG, b = playerB},})
        end
    end

    table.insert(playerEntries,
    {name = "Back",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        entries = settingsEntries
        selection = 1
    end,})

    if resetEntryVariable then
        entries = playerEntries

        if selection > #entries then selection = #entries end
    end
end

local function reset_blacklist_entries()

    local resetEntryVariable = false

    if entries == blacklistEntries then
        resetEntryVariable = true
    end

    blacklistEntries = {
        {name = "Add",
        permission = PERMISSION_SERVER,
        input = INPUT_A,
        func = function ()
            blacklistAddRequest = true
            djui_chat_message_create("Please run /tag course_name/course_index. To cancel, exit the blacklist menu")
        end,}}

    for i = 1, #blacklistedCourses do
        if isRomhack then
            table.insert(blacklistEntries,
            {name = name_of_level(course_to_level(blacklistedCourses[i]), 1),
            permission = PERMISSION_SERVER,
            input = INPUT_A,
            func = function ()
                table.remove(blacklistedCourses, i)
            end,
            valueText = tostring(blacklistedCourses[i]),
            seperator = i == 1 and "Courses" or nil,
            })
        else
            table.insert(blacklistEntries,
            {name = name_of_level(levels[blacklistedCourses[i]].level, levels[blacklistedCourses[i]].area),
            permission = PERMISSION_SERVER,
            input = INPUT_A,
            func = function ()
                table.remove(blacklistedCourses, i)
            end,
            valueText = tostring(level_to_course(levels[blacklistedCourses[i]].level))
            })
        end
    end

    table.insert(blacklistEntries,
    {name = "Back",
    permission = PERMISSION_NONE,
    input = INPUT_A,
    func = function ()
        entries = settingsEntries
        selection = 1
    end,})

    if resetEntryVariable then
        entries = blacklistEntries

        if selection > #entries then selection = #entries end
    end
end

local function reset_bind_entries()
    local resetBindEntries = false

    if entries == bindsEntries then
        resetBindEntries = true
    end

    bindsEntries = {}

    for i = 0, BIND_MAX do

        local bind = binds[i]
        local value = ""

        if i == awaitingInput then
            value = "Waiting for Press..."
        else
            value = button_to_text(bind.btn)
        end

        table.insert(bindsEntries,
        {name = bind.name,
        permission = PERMISSION_NONE,
        input = INPUT_A,
        func = function ()
            wait_for_button(i)
        end,
        valueText = value})
    end

    table.insert(bindsEntries,
        {name = "Back",
        permission = PERMISSION_NONE,
        input = INPUT_A,
        func = function ()
            entries = settingsEntries
            selection = 1
        end}
    )

    if resetBindEntries then
        entries = bindsEntries
    end
end

local function hud_render()

    if not showSettings then
        entries = settingsEntries
        selection = 1
        scrollOffset = 0
        return
    end

    screenHeight = djui_hud_get_screen_height()

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    if selection >= 14 then
        scrollOffset = 60 * (selection - 13)
    else
        scrollOffset = 0
    end

    background()
    settings_text()
    -- reconstruct tables
    reset_settings_selection()
    reset_gamemode_selection()
    reset_start_selection()
    reset_player_selection()
    reset_blacklist_entries()
    reset_bind_entries()

    local height = 90

    for i = 1, #entries do
        if entries[i].seperator ~= nil then
            height = height + 45

            djui_hud_set_color(220, 220, 220, 255)
            djui_hud_print_text(entries[i].seperator, 30, height + 4, 1)

            height = height + 45
        else
            height = height + 60
        end

        if entries[i].text ~= nil then
            -- appreciate the free labor chatgpt (ok I did a little bit of cleanup)
            local wrappedTextLines = warp_text(entries[i].text, 53)

            for j, line in ipairs(wrappedTextLines) do
                if selection == i then
                    djui_hud_set_color(240, 240, 240, 255)
                else
                    djui_hud_set_color(200, 200, 200, 255)
                end

                djui_hud_print_text(line, 20, height - scrollOffset + (j - 1) * 28, 1)
            end

            for _ = 1, #wrappedTextLines do
                height = height + 25
            end

            goto continue
        end

        if selection == i then
            djui_hud_set_color(32, 32, 34, 225)
        else
            djui_hud_set_color(32, 32, 34, 128)
        end

        djui_hud_render_rect(20, height - scrollOffset, bgWidth - 40, 40)

        if (not has_permission(entries[i].permission)
        or (entries[i].disabled ~= nil and entries[i].disabled()))
        and entries[i].color == nil then
            djui_hud_set_color(150, 150, 150, 255)
        else
            if entries[i].color == nil then
                djui_hud_set_color(220, 220, 220, 255)
            else
                djui_hud_set_color(entries[i].color.r, entries[i].color.g, entries[i].color.b, 255)
            end
        end

        djui_hud_print_text(entries[i].name, 30, height + 4 - scrollOffset, 1)

        if entries[i].valueTextColor ~= nil then
            djui_hud_set_color(entries[i].valueTextColor.r, entries[i].valueTextColor.g, entries[i].valueTextColor.b, 255)
        else
            djui_hud_set_color(220, 220, 220, 255)
        end

        if entries[i].valueText ~= nil then
            djui_hud_print_text(entries[i].valueText, bgWidth - 30 - djui_hud_measure_text(entries[i].valueText), height + 4 - scrollOffset, 1)
        end

        ::continue::
    end
end

---@param m MarioState
local function mario_update(m)

    if m.playerIndex ~= 0 then return end
    if not showSettings then return end

    -- if our stick is at 0, then set joystickCooldown to 0
    if m.controller.stickX == 0 and m.controller.stickY == 0 then joystickCooldown = 0 end

    if m.controller.buttonPressed & U_JPAD ~= 0
    or (m.controller.stickY > 0.5 and joystickCooldown <= 0) then
        selection = selection - 1
        if selection < 1 then selection = #entries end
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        joystickCooldown = 0.2 * 30
        awaitingInput = nil
    elseif m.controller.buttonPressed & D_JPAD ~= 0
    or (m.controller.stickY < -0.5 and joystickCooldown <= 0) then
        selection = selection + 1
        if selection > #entries then selection = 1 end
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        joystickCooldown = 0.2 * 30
        awaitingInput = nil
    end

    if (m.controller.buttonPressed & R_JPAD ~= 0 or (m.controller.stickX > 0.5
    and joystickCooldown <= 0))
    and entries[selection].input == INPUT_JOYSTICK then
        if has_permission(entries[selection].permission) then
            entries[selection].func()
            play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        else
            play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        end

        joystickCooldown = 0.2 * 30
    elseif (m.controller.buttonPressed & L_JPAD ~= 0 or (m.controller.stickX < -0.5
    and joystickCooldown <= 0))
    and entries[selection].input == INPUT_JOYSTICK then
        if has_permission(entries[selection].permission) then
            entries[selection].func()
            play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        else
            play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        end

        joystickCooldown = 0.2 * 30
    end

    if joystickCooldown > 0 then joystickCooldown = joystickCooldown - 1 end

    if awaitingInput ~= nil then
        if m.controller.buttonPressed ~= 0 then
            if button_to_text(m.controller.buttonPressed) == "" then return end
            binds[awaitingInput].btn = m.controller.buttonPressed
            mod_storage_save("bind_" .. tostring(awaitingInput), tostring(binds[awaitingInput].btn))

            awaitingInput = nil
        end

        return
    end

    if m.controller.buttonPressed & A_BUTTON ~= 0
    and entries[selection].input == INPUT_A then
        if has_permission(entries[selection].permission)
        and (entries[selection].disabled == nil or
        (entries[selection].disabled ~= nil and not entries[selection].disabled())) then
            entries[selection].func()
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        else
            play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)