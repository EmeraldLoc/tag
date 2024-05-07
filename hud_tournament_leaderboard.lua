
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

local function hud_tournament_leaderboard_text_render()

    local text = "Tournament Leaderboard"

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text)

    local x = (screenWidth - width) / 2
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_leaderboard()

    if hudTimer > 5 * 30 then
        local winners = {}

        for i = 0, MAX_PLAYERS - 1 do
            local np = gNetworkPlayers[i]
            local s = gPlayerSyncTable[i]
            if np.connected and s.tournamentPoints >= gGlobalSyncTable.tournamentPointsReq then
                table.insert(winners, i)
            end
        end

        -- sort winners
        table.sort(winners, function (a, b)
            return gPlayerSyncTable[a].tournamentPoints > gPlayerSyncTable[b].tournamentPoints
        end)

        -- remove any winners that didnt get the max points
        local topPoints = 0
        for w = 1, #winners do
            local i = winners[w]

            if gPlayerSyncTable[i].tournamentPoints > topPoints then
                topPoints = i
            elseif gPlayerSyncTable[i].tournamentPoints < topPoints then
                table.remove(winners, w)
            end
        end

        local winnerText = ""

        for w = 1, #winners do
            local i = winners[w]

            winnerText = winnerText .. get_player_name(i) .. "\\#FFD700\\, and "
        end

        if not addedStats then
            addedStats = true

            if table.contains(winners, 0) then
                stats.globalStats.totalTournamentWins = stats.globalStats.totalTournamentWins + 1
                save_int("stats_global_totalTournamentWins", stats.globalStats.totalTournamentWins)
            end
        end

        winnerText = winnerText:sub(1, #winnerText - 6) .. " won the Tournament!"

        local textWidth = djui_hud_measure_text(winnerText) / 2

        djui_hud_print_colored_text(winnerText, djui_hud_get_screen_width() / 2 - textWidth, djui_hud_get_screen_height() / 2, 1.5, fade)

        return
    end

    local renderedIndex = 0
    local sortedPlayers = {}

    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
            table.insert(sortedPlayers, i)
        end
    end

    -- sort
    table.sort(sortedPlayers, function (a, b)
        return gPlayerSyncTable[a].tournamentPoints > gPlayerSyncTable[b].tournamentPoints
    end)

    local position = 1

    for sp = 1, #sortedPlayers do
        local i = sortedPlayers[sp]
        if gNetworkPlayers[i].connected then
            local displayName = get_player_name(i)

            local text = displayName

            local screenWidth = djui_hud_get_screen_width()
            local width = 550

            local x = (screenWidth - width) / 2
            local y = 80 + (renderedIndex * 50)

            djui_hud_set_color(32, 32, 32, fade)
            djui_hud_render_rect_outlined(x, y - 5, width + 15, 42, 50, 50, 50, 3, fade)

            local r, g, b = hex_to_rgb(network_get_player_text_color_string(i))
            width = djui_hud_measure_text(text)
            x = (screenWidth - 390) / 2

            djui_hud_set_color(r, g, b, fade)
            djui_hud_print_colored_text(text, x, y, 1, fade)

            x = (screenWidth - 470) / 2

            render_player_head(i, x, y, 1.9, 1.9)

            x = (screenWidth - 530) / 2

            -- check the previous index and see if they tie, if they don't, increase position
            if sortedPlayers[sp - 1] ~= nil and gPlayerSyncTable[i].tournamentPoints ~= gPlayerSyncTable[sortedPlayers[sp - 1]].tournamentPoints then
                position = position + 1
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

            djui_hud_print_text(text, x, y, 1)

            text = "Points: " .. gPlayerSyncTable[i].tournamentPoints

            width = djui_hud_measure_text(text)
            x = ((screenWidth + 550 - ((width * 2))) / 2)

            djui_hud_set_color(255, 255, 255, fade)
            djui_hud_print_text(text, x, y, 1)

            renderedIndex = renderedIndex + 1
        end
    end
end

local function hud_voting_begins_in()
    local text = tostring(math.floor(gGlobalSyncTable.displayTimer / 30) + 1) .. " seconds"

    if gGlobalSyncTable.doVoting and gGlobalSyncTable.autoMode then
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
    if gGlobalSyncTable.roundState ~= ROUND_TOURNAMENT_LEADERBOARD then
        fade = 0
        hudTimer = 5 * 30
        -- see if someone has won
        for i = 0, MAX_PLAYERS - 1 do
            if gPlayerSyncTable[i].tournamentPoints >= gGlobalSyncTable.tournamentPointsReq
            and gNetworkPlayers[i].connected then
                hudTimer = 10 * 30
            end
        end
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
    hud_tournament_leaderboard_text_render()
    hud_leaderboard()
    hud_voting_begins_in()
    hud_gamemode()
    hud_modifier()
    hud_did_you_know(fade)
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)