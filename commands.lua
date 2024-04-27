---@param msg string
function start_command(msg)
    if network_player_connected_count() < PLAYERS_NEEDED then
        djui_chat_message_create("Not enough players to start the round")

        return true
    end

    if msg ~= "" then
        if tonumber(msg) ~= nil then
            for i, level in pairs(levels) do
                if level_to_course(level.level) == tonumber(msg) then
                    timer = 15 * 30 -- 15 seconds
                    gGlobalSyncTable.selectedLevel = i
                    prevLevel = gGlobalSyncTable.selectedLevel
                    gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state

                    djui_chat_message_create("Starting game in level " .. name_of_level(level.level, level.area, level))

                    return true
                end
            end
        else
            for i, level in pairs(levels) do
                if msg:lower() == level.name
                or msg:lower() == name_of_level(level.level, level.area):lower()
                or msg:lower() == level.overrideName then
                    timer = 15 * 30 -- 15 seconds
                    gGlobalSyncTable.selectedLevel = i
                    prevLevel = gGlobalSyncTable.selectedLevel
                    gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state

                    djui_chat_message_create("Starting game in level " .. name_of_level(level.level, level.area, level))

                    return true
                end
            end
        end
    end

    timer = 15 * 30 -- 15 seconds

    local level = levels[gGlobalSyncTable.selectedLevel]

    while blacklistedCourses[gGlobalSyncTable.selectedLevel] == true or table.contains(badLevels, level.level) or gGlobalSyncTable.selectedLevel == prevLevel do
        gGlobalSyncTable.selectedLevel = math.random(1, #levels) -- select a random level
        level = levels[gGlobalSyncTable.selectedLevel]

        if level.level == LEVEL_TTC and not isRomhack then
            gGlobalSyncTable.ttcSpeed = math.random(0, 3)
        end
    end

    prevLevel = gGlobalSyncTable.selectedLevel
    gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state

    log_to_console("Tag: Settings round state to ROUND_WAIT...")

    djui_chat_message_create("Starting round")

    return true
end

function spectator_command(msg)
    toggle_spectator()

    return true
end

function tag_command(msg)
    showSettings = not showSettings
    if not isPaused then
        isPaused = true
        play_sound(SOUND_MENU_PAUSE, gGlobalSoundSource)
    else
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
    end
    return true
end

if network_is_server()
or network_is_moderator() then
    hook_chat_command("start", "[name|index] Starts round in a random or specific level", start_command)
end

hook_chat_command("tag", "View tag options", tag_command)
