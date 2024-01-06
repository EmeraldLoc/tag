
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
        if gGlobalSyncTable.gamemode == FREEZE_TAG then
            text = "Runners and Frozen Win"
        else
            text = "Runners Win"
        end
    elseif gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
        if gGlobalSyncTable.gamemode == INFECTION then
            text = "Infected Win"
        elseif gGlobalSyncTable.gamemode == HOT_POTATO then
            text = "Potato Wielders Win"
        elseif gGlobalSyncTable.gamemode == ASSASINS then
            text = "Assasins Win"
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

    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
            if gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
                if gPlayerSyncTable[i].state ~= TAGGER or gPlayerSyncTable[i].amountOfTags <= 0 then goto continue end
            elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
                if (gPlayerSyncTable[i].state ~= RUNNER and gGlobalSyncTable.gamemode ~= FREEZE_TAG) or (gPlayerSyncTable[i].state ~= ELIMINATED_OR_FROZEN and gPlayerSyncTable[i].state ~= RUNNER and gGlobalSyncTable.gamemode == FREEZE_TAG) or gPlayerSyncTable[i].amountOfTimeAsRunner <= 0 then goto continue end
            end

            local displayName = strip_hex(gNetworkPlayers[i].name)

            local text = displayName

            local screenWidth = djui_hud_get_screen_width()
            local width = 450

            local x = (screenWidth - width) / 2
            local y = 80 + (renderedIndex * 50)

            djui_hud_set_color(26, 26, 28, fade)
            djui_hud_render_rect(x, y - 5, width + 15, 42)

            local r, g, b = hex_to_rgb(network_get_player_text_color_string(i))
            width = djui_hud_measure_text(text)
            x = (screenWidth - 345) / 2

            djui_hud_set_color(r, g, b, fade)
            djui_hud_print_text(text, x, y, 1)

            x = (screenWidth - 430) / 2

            render_player_head(i, x, y, 1.9, 1.9)

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
            if gGlobalSyncTable.gamemode == FREEZE_TAG then
                text = "No Runners or Frozen Won"
            else
                text = "No Runners Won"
            end
        elseif gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
            if gGlobalSyncTable.gamemode == INFECTION then
                text = "No Infected Players Won"
            elseif gGlobalSyncTable.gamemode == HOT_POTATO then
                text = "No Potato Wielders Win"
            elseif gGlobalSyncTable.gamemode == ASSASINS then
                text = "No Assasins Win"
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

local function hud_render()
    if (gGlobalSyncTable.roundState ~= ROUND_RUNNERS_WIN and gGlobalSyncTable.roundState ~= ROUND_TAGGERS_WIN) or joinTimer > 0 then
        fade = 0
        hudTimer = 15 * 30
        if joinTimer <= 0 and desyncTimer >= 10 * 30 then
            select_random_did_you_know()
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

            if fade >= 255 then fade = 255 end
        end
    else
        fade = fade - 20

        if fade <= 0 then return end
    end

    hud_black_bg()
    hud_winner_group_render()
    hud_leaderboard()
    hud_did_you_know(fade)
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)