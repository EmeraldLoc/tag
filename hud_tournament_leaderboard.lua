
local hudTimer =  0
local fade = 0
local addedStats = false

local function update()
    if hudTimer > 0 then
        hudTimer = hudTimer - 1
    end
end

local function hud_black_bg()
    local theme = get_selected_theme()
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    djui_hud_set_color(theme.background.r, theme.background.g, theme.background.b, fade)
    djui_hud_render_rect(0, 0, screenWidth, screenHeight)
end

local function hud_tournament_leaderboard_text_render()

    local theme = get_selected_theme()
    local text = "Tournament Leaderboard"

    if gGlobalSyncTable.tournamentPointSystem == TOURNAMENT_SYSTEM_POINT_LIMIT then
        text = "Points needed to win: " .. gGlobalSyncTable.tournamentPointsReq
    elseif gGlobalSyncTable.tournamentPointSystem == TOURNAMENT_SYSTEM_ROUND_LIMIT then
        text = "Round's Remaining: " .. gGlobalSyncTable.tournamentRoundLimit - gGlobalSyncTable.tournamentRound
    end

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text)

    local x = (screenWidth - width) / 2
    local y = 20

    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_leaderboard()
    local theme = get_selected_theme()
    if hudTimer > 5 * 30 then
        local winners = {}

        for i = 0, MAX_PLAYERS - 1 do
            local np = gNetworkPlayers[i]
            local s = gPlayerSyncTable[i]
            if np.connected then
                if  gGlobalSyncTable.tournamentPointSystem == TOURNAMENT_SYSTEM_POINT_LIMIT
                and s.tournamentPoints >= gGlobalSyncTable.tournamentPointsReq then
                    table.insert(winners, i)
                elseif gGlobalSyncTable.tournamentPointSystem == TOURNAMENT_SYSTEM_ROUND_LIMIT then
                    table.insert(winners, i)
                end
            end
        end

        -- sort winners
        table.sort(winners, function (a, b)
            return gPlayerSyncTable[a].tournamentPoints > gPlayerSyncTable[b].tournamentPoints
        end)

        -- remove any winners that didnt get the highest points
        local topPoints = 0
        local removeAllIndexesAt = 0
        for w = 1, #winners do
            local i = winners[w]
            if gPlayerSyncTable[i].tournamentPoints > topPoints then
                topPoints = i
            elseif gPlayerSyncTable[i].tournamentPoints < topPoints then
                removeAllIndexesAt = w
                break
            end
        end

        while #winners >= removeAllIndexesAt and removeAllIndexesAt > 0 do
            table.remove(winners, removeAllIndexesAt)
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

        local textWidth = djui_hud_measure_text(strip_hex(winnerText)) / 2

        djui_hud_set_color(theme.background.r, theme.background.g, theme.background.b, fade)
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

            local text = get_player_name(i)

            local screenWidth = djui_hud_get_screen_width()
            local width = 550

            local x = (screenWidth - width) / 2
            local y = 110 + (renderedIndex * 50)

            djui_hud_set_color(theme.rect.r, theme.rect.g, theme.rect.b, fade)
            djui_hud_render_rect_rounded_outlined(x, y - 5, width + 15, 42, theme.rectOutline.r, theme.rectOutline.g, theme.rectOutline.b, 3, fade)

            width = djui_hud_measure_text(text)
            x = (screenWidth - 390) / 2

            djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, fade)
            djui_hud_print_colored_text(text, x, y, 1, fade)

            x = (screenWidth - 470) / 2

            render_player_head(i, x, y, 1.9, 1.9, fade)

            x = (screenWidth - 530) / 2

            -- check the previous index and see if they tie, if they don't, increase position
            if sortedPlayers[sp - 1] ~= nil and gPlayerSyncTable[i].tournamentPoints ~= gPlayerSyncTable[sortedPlayers[sp - 1]].tournamentPoints then
                position = position + 1
            end

            text = "#" .. position
            if position == 1 then
                djui_hud_set_color(255, 215, 0, fade)
            elseif position == 2 then
                djui_hud_set_color(169, 169, 169, fade)
            elseif position == 3 then
                djui_hud_set_color(205, 127, 50, fade)
            else
                djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, fade)
            end

            djui_hud_print_text(text, x, y, 1)

            text = "Points: " .. gPlayerSyncTable[i].tournamentPoints

            width = djui_hud_measure_text(text)
            x = ((screenWidth + 550 - ((width * 2))) / 2)

            djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, fade)
            djui_hud_print_text(text, x, y, 1)

            renderedIndex = renderedIndex + 1
        end
    end
end

local function hud_voting_begins_in()
    local theme = get_selected_theme()
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

    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_gamemode()
    local theme = get_selected_theme()
    local text = "Gamemode is set to " .. get_gamemode_including_random(gGlobalSyncTable.gamemode)

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(strip_hex(text))

    local x = screenWidth - width - 40
    local y = 60

    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, fade)
    djui_hud_print_colored_text(text, x, y, 1, fade)
end

local function hud_modifier()
    local theme = get_selected_theme()
    local text = "Modifier is set to " .. get_modifier_including_random()

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(strip_hex(text))

    local x = screenWidth - width - 40
    local y = 20

    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, fade)
    djui_hud_print_colored_text(text, x, y, 1, fade)
end

local function hud_render()
    if gGlobalSyncTable.roundState ~= ROUND_TOURNAMENT_LEADERBOARD then
        fade = 0
        hudTimer = 5 * 30
        -- see if someone has won
        if has_tournament_ended() then
            hudTimer = 10 * 30
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

        if has_tournament_ended() then
            gPlayerSyncTable[0].tournamentPoints = 0
            gGlobalSyncTable.tournamentRound = 0
        end
    end

    fade = clamp(fade, 0, 255)

    hud_black_bg()
    hud_tournament_leaderboard_text_render()
    hud_leaderboard()
    hud_voting_begins_in()
    hud_gamemode()
    hud_modifier()
end

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    if gGlobalSyncTable.roundState ~= ROUND_TOURNAMENT_LEADERBOARD then return end

    m.freeze = 1
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)