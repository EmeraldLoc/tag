---@diagnostic disable: param-type-mismatch

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
                    timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16
                    gGlobalSyncTable.selectedLevel = i
                    prevLevel = gGlobalSyncTable.selectedLevel
                    gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state

                    djui_chat_message_create("Starting game in level " .. name_of_level(level.level, level.area))

                    return true
                end
            end
        else
            for i, level in pairs(levels) do
                if msg:lower() == level.name or msg:lower() == name_of_level(level.level, level.area):lower() then
                    timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16
                    gGlobalSyncTable.selectedLevel = i
                    prevLevel = gGlobalSyncTable.selectedLevel
                    gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state

                    djui_chat_message_create("Starting game in level " .. name_of_level(level.level, level.area))

                    return true
                end
            end
        end
    end

    timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16

    local level = levels[gGlobalSyncTable.selectedLevel]

    ---@diagnostic disable-next-line: param-type-mismatch
    while table.contains(blacklistedCourses, level_to_course(level.level)) or table.contains(badLevels, level.level) or gGlobalSyncTable.selectedLevel == prevLevel do
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

---@param msg string
function on_version_command(msg)
    djui_chat_message_create("Current \\#316BE8\\Tag \\#FFFFFF\\Version: " .. version)

    return true
end

function spectator_command(msg)
    if msg == "yes" or msg == "on" or msg == "enable" then
        djui_chat_message_create("You are now a spectator")
        gPlayerSyncTable[0].state = SPECTATOR
        return true
    elseif (msg == "no" or msg == "off" or msg == "disable") and gGlobalSyncTable.roundState ~= ROUND_ACTIVE and gGlobalSyncTable.roundState ~= ROUND_HOT_POTATO_INTERMISSION then
        djui_chat_message_create("You are no longer a spectator")
        gPlayerSyncTable[0].state = RUNNER
        warp_to_level(LEVEL_VCUTM, 1, 0) -- Enter spectator in singleplayer and see what happens >:)
        return true
    elseif msg == "no" or msg == "off" or msg == "disable" then
        djui_chat_message_create("You must wait for the game to end to no longer be a spectator")
    else
        if gPlayerSyncTable[0].state == SPECTATOR then
            djui_chat_message_create("You are a spectator")
        else
            djui_chat_message_create("You are not a spectator")
        end
    end

    return true
end

function tag_command(msg)
    if blacklistAddRequest then
        if tonumber(msg) ~= nil then
            for i = 1, #levels do
                if tonumber(msg) == level_to_course(levels[i].level) then
                    if not table.contains(blacklistedCourses, i) then
                        table.insert(blacklistedCourses, i)
                    else
                        djui_chat_message_create("Course " ..
                            name_of_level(levels[i].level, levels[i].area) .. " is already blacklisted")
                    end

                    djui_chat_message_create("Blacklisted " .. name_of_level(levels[i].level, levels[i].area))

                    blacklistAddRequest = false

                    return true
                end
            end

            djui_chat_message_create("Course " .. msg .. " not found")

            blacklistAddRequest = false

            return true
        else
            for i = 1, #levels do
                if msg:lower() == levels[i].name then
                    if not table.contains(blacklistedCourses, i) then
                        table.insert(blacklistedCourses, i)
                        djui_chat_message_create("Blacklisted " .. levels[i].name)
                    else
                        djui_chat_message_create("Course " .. levels[i].name .. " is already blacklisted")
                    end

                    blacklistAddRequest = false

                    return true
                end
            end

            djui_chat_message_create("Course " .. msg .. " not found")

            blacklistAddRequest = false

            return true
        end

        blacklistAddRequest = false
    else
        if _G.swearExists then
            if not _G.swearSettingsOpened then
                showSettings = not showSettings
                _G.tagSettingsOpen = showSettings
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
            else
                play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
                djui_chat_message_create("Tag: Swear Filter settings menu is already opened!")
            end
        else
            showSettings = not showSettings
            _G.tagSettingsOpen = showSettings
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        end
    end
    return true
end

if network_is_server() then
    hook_chat_command("tag", "View and change tag settings", tag_command)
    hook_chat_command("start", "[name|index] Starts round in a random or specific level", start_command)
else
    hook_chat_command("tag", "View tag settings", tag_command)
end
hook_chat_command("spectate", "[on|off] Be a spectator", spectator_command)
hook_chat_command("version", "Get current version of Tag", on_version_command)
