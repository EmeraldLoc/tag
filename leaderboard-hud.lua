
local hudTimer =  0
local fade = 0

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

    local text = ""

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
                if (gPlayerSyncTable[i].state ~= RUNNER and (gGlobalSyncTable.gamemode ~= FREEZE_TAG or gGlobalSyncTable.freezeHealthDrain == 0)) or (gPlayerSyncTable[i].state ~= ELIMINATED_OR_FROZEN and gPlayerSyncTable[i].state ~= RUNNER and (gGlobalSyncTable.gamemode == FREEZE_TAG and gGlobalSyncTable.freezeHealthDrain > 0)) or gPlayerSyncTable[i].amountOfTimeAsRunner <= 0 then goto continue end
            end

            table.insert(winners, i)
        end

        ::continue::
    end

    -- sort
    if gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
        table.sort(winners, function (a, b)
            return gPlayerSyncTable[a].amountOfTags > gPlayerSyncTable[b].amountOfTags
        end)
    elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
        table.sort(winners, function (a, b)
            return gPlayerSyncTable[a].amountOfTimeAsRunner > gPlayerSyncTable[b].amountOfTimeAsRunner
        end)
    end

    local position = 1

    for w = 1, #winners do
        local i = winners[w]
        if gNetworkPlayers[i].connected then
            if gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
                if gPlayerSyncTable[i].state ~= TAGGER or gPlayerSyncTable[i].amountOfTags <= 0 then goto continue end
            elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
                if (gPlayerSyncTable[i].state ~= RUNNER and (gGlobalSyncTable.gamemode ~= FREEZE_TAG or gGlobalSyncTable.freezeHealthDrain == 0)) or (gPlayerSyncTable[i].state ~= ELIMINATED_OR_FROZEN and gPlayerSyncTable[i].state ~= RUNNER and (gGlobalSyncTable.gamemode == FREEZE_TAG and gGlobalSyncTable.freezeHealthDrain > 0)) or gPlayerSyncTable[i].amountOfTimeAsRunner <= 0 then goto continue end
            end

            local displayName = strip_hex(gNetworkPlayers[i].name)

            local text = displayName

            if text:len() > 17 then
                text = string.sub(text, 1, 17)

                text = text .. "..."
            end

            local screenWidth = djui_hud_get_screen_width()
            local width = 450

            local x = (screenWidth - width) / 2
            local y = 80 + (renderedIndex * 50)

            djui_hud_set_color(26, 26, 28, fade)
            djui_hud_render_rect(x, y - 5, width + 15, 42)

            local r, g, b = hex_to_rgb(network_get_player_text_color_string(i))
            width = djui_hud_measure_text(text)
            x = (screenWidth - 265) / 2

            djui_hud_set_color(r, g, b, fade)
            djui_hud_print_text(text, x, y, 1)

            x = (screenWidth - 350) / 2

            render_player_head(i, x, y, 1.9, 1.9)

            x = (screenWidth - 430) / 2

            -- decide what position this player should be at. Don't use w variable to allow for ties as shown below
            if gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN and w > 1 then
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

            djui_hud_print_text(text, x, y, 1)

            if gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
                text = "Time as runner: " .. math.floor(gPlayerSyncTable[i].amountOfTimeAsRunner / 30) .. "s"
            else
                if gGlobalSyncTable.gamemode ~= INFECTION then
                    text = "Tags: " .. gPlayerSyncTable[i].amountOfTags
                else
                    text = "Infections: " .. gPlayerSyncTable[i].amountOfTags
                end
            end

            width = djui_hud_measure_text(text)
            x = ((screenWidth + 450 - ((width * 2))) / 2)

            if gPlayerSyncTable[i].amountOfTimeAsRunner / 30 < gGlobalSyncTable.amountOfTime / 30 or gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
                djui_hud_set_color(255, 255, 255, fade)
            elseif gPlayerSyncTable[i].amountOfTimeAsRunner / 30 >= gGlobalSyncTable.amountOfTime / 30 and gGlobalSyncTable.gamemode ~= HOT_POTATO then
                djui_hud_set_color(255, 215, 0, fade)
            else
                djui_hud_set_color(255, 255, 255, fade)
            end

            djui_hud_print_text(text, x, y, 1)

            renderedIndex = renderedIndex + 1
        end

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
    local text = tostring(math.floor(gGlobalSyncTable.displayTimer / 30)) .. " seconds"

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
    local text = "Gamemode is set to " .. get_gamemode_including_random()

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text)

    local x = screenWidth - width - 40
    local y = 60

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_modifier()
    local text = "Modifier is set to " .. get_modifier_including_random()

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text)

    local x = screenWidth - width - 40
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end


local function hud_render()
    if (gGlobalSyncTable.roundState ~= ROUND_RUNNERS_WIN and gGlobalSyncTable.roundState ~= ROUND_TAGGERS_WIN) or joinTimer > 0 then
        fade = 0
        hudTimer = 15 * 30
        if joinTimer <= 0 and desyncTimer >= 10 * 30 then
            select_random_did_you_know()
        end

        --return
    end

    fade = 255

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    -- render stuff
    if hudTimer > 0.5 * 30 then
        if fade < 255 then
            fade = fade + 20

            if fade >= 255 then fade = 255 end
        end
    else
        fade = fade - 20

        if fade <= 0 then return end
    end

    hud_black_bg()
    hud_winner_group_render()
    hud_leaderboard()
    hud_voting_begins_in()
    hud_gamemode()
    hud_modifier()
    hud_did_you_know(fade)
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)