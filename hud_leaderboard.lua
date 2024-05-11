
local hudTimer =  0
local fade = 0
local addedStats = false

local function update()
    if hudTimer > 0 then
        hudTimer = hudTimer - 1
    end
end

local function hud_black_bg()
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    djui_hud_set_color(28, 28, 30, fade)
    djui_hud_render_rect(0, 0, screenWidth, screenHeight)
end

local function hud_winner_group_render()

    local text = "What the heck is happening."

    if gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
        if gGlobalSyncTable.gamemode == FREEZE_TAG and gGlobalSyncTable.freezeHealthDrain > 0 then
            text = "Runners and Frozen Win"
        else
            text = "Runners Win"
        end
    elseif gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
        if gGlobalSyncTable.gamemode == INFECTION then
            text = "Infected Win"
        elseif gGlobalSyncTable.gamemode == HOT_POTATO then
            text = "Potato Wielders Win"
        elseif gGlobalSyncTable.gamemode == ASSASSINS then
            text = "Assassins Win"
        elseif gGlobalSyncTable.gamemode == SARDINES then
            text = "Leaderboards"
        else
            text = "Taggers Win"
        end
    end

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text)

    local x = (screenWidth - width) / 2
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_leaderboard()

    local renderedIndex = 0
    local winners = {}

    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
            if gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
                if gPlayerSyncTable[i].state ~= TAGGER or gPlayerSyncTable[i].amountOfTags <= 0 then goto continue end
            elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
                -- cursed
                if (gPlayerSyncTable[i].state ~= RUNNER
                and gGlobalSyncTable.gamemode ~= SARDINES
                and (gGlobalSyncTable.gamemode ~= FREEZE_TAG
                or gGlobalSyncTable.freezeHealthDrain == 0))
                or (gPlayerSyncTable[i].state ~= WILDCARD_ROLE
                and (gPlayerSyncTable[i].state ~= RUNNER
                or gGlobalSyncTable.gamemode == SARDINES)
                and ((gGlobalSyncTable.gamemode == FREEZE_TAG
                and gGlobalSyncTable.freezeHealthDrain > 0)
                or gGlobalSyncTable.gamemode == SARDINES))
                or gPlayerSyncTable[i].amountOfTimeAsRunner <= 0
                then goto continue end
            end

            table.insert(winners, i)
        end

        ::continue::
    end

    -- sort
    if gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN or gGlobalSyncTable.gamemode == FREEZE_TAG then
        table.sort(winners, function (a, b)
            return gPlayerSyncTable[a].amountOfTags > gPlayerSyncTable[b].amountOfTags
        end)
    elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
        table.sort(winners, function (a, b)
            return gPlayerSyncTable[a].amountOfTimeAsRunner > gPlayerSyncTable[b].amountOfTimeAsRunner
        end)
    end

    -- stats
    if not addedStats then
        addedStats = true
        local stat = stats[gGlobalSyncTable.gamemode]

        -- playTime is handled in main.lua, save it here though
        save_int("stats_" .. gGlobalSyncTable.gamemode .. "_playTime", stat.playTime)
        save_int("stats_global_playTime", stats.globalStats.playTime)

        if  stat.runnerVictories ~= nil
        and gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN
        and winners[1] == 0 then
            stat.runnerVictories = stat.runnerVictories + 1
            save_int("stats_" .. tostring(gGlobalSyncTable.gamemode) .. "_runnerVictories", stat.runnerVictories)
            stats.globalStats.runnerVictories = stats.globalStats.runnerVictories + 1
            save_int("stats_global_runnerVictories", stats.globalStats.runnerVictories)
        elseif stat.taggerVictories ~= nil
        and gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN
        and winners[1] == 0 then
            stat.taggerVictories = stat.taggerVictories + 1
            save_int("stats_" .. tostring(gGlobalSyncTable.gamemode) .. "_taggerVictories", stat.taggerVictories)
            stats.globalStats.taggerVictories = stats.globalStats.taggerVictories + 1
            save_int("stats_global_taggerVictories", stats.globalStats.taggerVictories)
        end

        if stat.totalTimeAsRunner ~= nil then
            stat.totalTimeAsRunner = stat.totalTimeAsRunner + gPlayerSyncTable[0].amountOfTimeAsRunner
            save_int("stats_" .. tostring(gGlobalSyncTable.gamemode) .. "_totalTimeAsRunner", stat.totalTimeAsRunner)
            stats.globalStats.totalTimeAsRunner = stats.globalStats.totalTimeAsRunner + gPlayerSyncTable[0].amountOfTimeAsRunner
            save_int("stats_global_totalTimeAsRunner", stats.globalStats.totalTimeAsRunner)
        end

        if stat.totalTags ~= nil then
            stat.totalTags = stat.totalTags + gPlayerSyncTable[0].amountOfTags
            save_int("stats_" .. tostring(gGlobalSyncTable.gamemode) .. "_totalTags", stat.totalTags)
            stats.globalStats.totalTags = stats.globalStats.totalTags + gPlayerSyncTable[0].amountOfTags
            save_int("stats_global_totalTags", stats.globalStats.totalTags)
        end

        -- if we are in tournament mode, add tournament points to stats
        if gGlobalSyncTable.tournamentMode then
            local addedPoints = 0

            -- per tag we got, add half a point, round down
            addedPoints = addedPoints + math.floor(gPlayerSyncTable[0].amountOfTags / 2)

            -- depending on our placement, add points
            if winners[1] == 0 then
                addedPoints = addedPoints + 5
            elseif winners[2] == 0 then
                addedPoints = addedPoints + 3
            elseif winners[3] == 0 then
                addedPoints = addedPoints + 1
            end

            -- save to global stats
            stats.globalStats.totalTournamentPoints = stats.globalStats.totalTournamentPoints + addedPoints
            save_int("stats_global_totalTournamentPoints", stats.globalStats.totalTournamentPoints)

            -- add to our points
            gPlayerSyncTable[0].tournamentPoints = gPlayerSyncTable[0].tournamentPoints + addedPoints
        end
    end

    local position = 1
    local offsetX = 0

    if #winners > 16 then offsetX = -300 end

    for w = 1, #winners do
        if w > 16 and offsetX ~= 300 then
            offsetX = 300
            renderedIndex = 0
        end
        local i = winners[w]
        if gNetworkPlayers[i].connected then
            local displayName = get_player_name(i)

            local text = displayName

            local screenWidth = djui_hud_get_screen_width()
            local width = 550

            local x = (screenWidth - width) / 2
            local y = 110 + (renderedIndex * 50)

            djui_hud_set_color(32, 32, 32, fade)
            djui_hud_render_rect_outlined(x + offsetX, y - 5, width + 15, 42, 50, 50, 50, 3, fade)

            local r, g, b = hex_to_rgb(network_get_player_text_color_string(i))
            width = djui_hud_measure_text(text)
            x = (screenWidth - 390) / 2

            djui_hud_set_color(r, g, b, fade)
            djui_hud_print_colored_text(text, x + offsetX, y, 1, fade)

            x = (screenWidth - 470) / 2

            render_player_head(i, x + offsetX, y, 1.9, 1.9)

            x = (screenWidth - 530) / 2

            -- decide what position this player should be at. Don't use w variable to allow for ties as shown below
            if (gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN or gGlobalSyncTable.gamemode == FREEZE_TAG) and w > 1 then
                -- check the previous index and see if they tie, if they don't, increase position
                if gPlayerSyncTable[i].amountOfTags ~= gPlayerSyncTable[winners[w - 1]].amountOfTags then
                    position = position + 1
                end
            elseif w > 1 then
                -- check the previous index and see if they tie, if they don't, increase position
                if gPlayerSyncTable[i].amountOfTimeAsRunner ~= gPlayerSyncTable[winners[w - 1]].amountOfTimeAsRunner then
                    position = position + 1
                end
            end

            text = "#" .. position
            if position == 1 then
                djui_hud_set_color(255, 215, 0, 255)
            elseif position == 2 then
                djui_hud_set_color(169, 169, 169, 255)
            elseif position == 3 then
                djui_hud_set_color(205, 127, 50, 255)
            else
                djui_hud_set_color(220, 220, 220, 255)
            end

            djui_hud_print_text(text, x + offsetX, y, 1)

            if gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
                if gGlobalSyncTable.gamemode ~= FREEZE_TAG then
                    text = "Time as runner: " .. math.floor(gPlayerSyncTable[i].amountOfTimeAsRunner / 30) .. "s"
                else
                    text = "Saves: " .. gPlayerSyncTable[i].amountOfTags
                end
            else
                if gGlobalSyncTable.gamemode ~= INFECTION then
                    text = "Tags: " .. gPlayerSyncTable[i].amountOfTags
                else
                    text = "Infections: " .. gPlayerSyncTable[i].amountOfTags
                end
            end

            width = djui_hud_measure_text(text)
            x = ((screenWidth + 550 - ((width * 2))) / 2)

            if gPlayerSyncTable[i].amountOfTimeAsRunner / 30 < gGlobalSyncTable.amountOfTime / 30 or gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
                djui_hud_set_color(255, 255, 255, fade)
            elseif gPlayerSyncTable[i].amountOfTimeAsRunner / 30 >= gGlobalSyncTable.amountOfTime / 30
            and gGlobalSyncTable.gamemode ~= HOT_POTATO and gGlobalSyncTable.gamemode ~= FREEZE_TAG then
                djui_hud_set_color(255, 215, 0, fade)
            else
                djui_hud_set_color(255, 255, 255, fade)
            end

            djui_hud_print_text(text, x + offsetX, y, 1)

            renderedIndex = renderedIndex + 1
        end
    end

    -- get sardine if our gamemode is set to sardines
    if gGlobalSyncTable.gamemode == SARDINES then
        local sardine = nil
        for i = 0, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected and gPlayerSyncTable[i].state == RUNNER then
                sardine = i
            end
        end

        if sardine == nil then goto continue end

        renderedIndex = renderedIndex + 1

        local screenWidth = djui_hud_get_screen_width()
        local width = 550

        local x = (screenWidth - 530) / 2
        local y = 80 + (renderedIndex * 47)

        djui_hud_set_color(255, 255, 255, fade)
        djui_hud_print_text("Sardine", x + offsetX, y, 1)

        renderedIndex = renderedIndex + 1

        local displayName = get_player_name(sardine)

        local text = displayName

        screenWidth = djui_hud_get_screen_width()
        width = 550

        x = (screenWidth - width) / 2
        y = 80 + (renderedIndex * 47)

        djui_hud_set_color(32, 32, 32, fade)
        djui_hud_render_rect_outlined(x + offsetX, y - 5, width + 15, 42, 50, 50, 50, 3, fade)

        local r, g, b = hex_to_rgb(network_get_player_text_color_string(sardine))
        width = djui_hud_measure_text(text)
        x = (screenWidth - 450) / 2

        djui_hud_set_color(r, g, b, fade)
        djui_hud_print_colored_text(text, x + offsetX, y, 1, fade)

        x = (screenWidth - 530) / 2

        render_player_head(sardine, x + offsetX, y, 1.9, 1.9)

        text = "Time as runner: " .. math.floor(gPlayerSyncTable[sardine].amountOfTimeAsRunner / 30) .. "s"

        width = djui_hud_measure_text(text)
        x = ((screenWidth + 550 - ((width * 2))) / 2)

        djui_hud_set_color(255, 255, 255, fade)
        djui_hud_print_text(text, x + offsetX, y, 1)

        ::continue::
    end

    if renderedIndex == 0 then
        local text = ""

        if gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
            if gGlobalSyncTable.gamemode == FREEZE_TAG and gGlobalSyncTable.freezeHealthDrain > 0 then
                text = "No Runners or Frozen Won"
            else
                text = "No Runners Won"
            end
        elseif gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
            if gGlobalSyncTable.gamemode == INFECTION then
                text = "No Infected Players Won"
            elseif gGlobalSyncTable.gamemode == HOT_POTATO then
                text = "No Potato Wielders Win"
            elseif gGlobalSyncTable.gamemode == ASSASSINS then
                text = "No Assassins Win"
            elseif gGlobalSyncTable.gamemode == SARDINES then
                text = "Nobody Wins"
            else
                text = "No Taggers Won"
            end
        end

        local screenWidth = djui_hud_get_screen_width()
        local screenHeight = djui_hud_get_screen_height()
        local width = djui_hud_measure_text(text)

        local x = (screenWidth - width) / 2
        local y = screenHeight / 2

        djui_hud_set_color(255, 255, 255, fade)
        djui_hud_print_text(text, x, y, 1)
    end
end

local function hud_voting_begins_in()
    local text = tostring(math.floor(gGlobalSyncTable.displayTimer / 30) + 1) .. " seconds"

    if gGlobalSyncTable.tournamentMode then
        text = "Tournament Leaderboard in " .. text
    elseif gGlobalSyncTable.doVoting and gGlobalSyncTable.autoMode then
        text = "Voting begins in " .. text
    elseif gGlobalSyncTable.autoMode then
        text = "Next round in " .. text
    else
        text = "Returning to lobby in " .. text
    end

    local x = 40
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_gamemode()
    local text = "Gamemode is set to " .. get_gamemode_including_random(gGlobalSyncTable.gamemode)

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(strip_hex(text))

    local x = screenWidth - width - 40
    local y = 60

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_colored_text(text, x, y, 1, fade)
end

local function hud_modifier()
    local text = "Modifier is set to " .. get_modifier_including_random()

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(strip_hex(text))

    local x = screenWidth - width - 40
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_colored_text(text, x, y, 1, fade)
end

local function hud_render()
    if gGlobalSyncTable.roundState ~= ROUND_RUNNERS_WIN and gGlobalSyncTable.roundState ~= ROUND_TAGGERS_WIN then
        fade = 0
        hudTimer = 5 * 30
        addedStats = false

        return
    end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    -- render stuff
    if hudTimer > 0.5 * 30 then
        if fade < 255 then
            fade = fade + 20
        end
    else
        fade = fade - 20
    end

    fade = clamp(fade, 0, 255)

    hud_black_bg()
    hud_winner_group_render()
    hud_leaderboard()
    hud_voting_begins_in()
    hud_gamemode()
    hud_modifier()
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)