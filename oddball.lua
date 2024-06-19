
---@param m MarioState
local function mario_update(m)
    if gGlobalSyncTable.gamemode ~= ODDBALL then return end

    m.health = 0x880 -- set mario's health to full

    if gPlayerSyncTable[0].state == RUNNER and m.playerIndex == 0 then
        gPlayerSyncTable[0].oddballTimer = gPlayerSyncTable[0].oddballTimer - 1
    end
end

local function hud_side_panel_render()

    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end

    local theme = get_selected_theme()

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local textMaxWidth = djui_hud_measure_text("---------------------")

    local x = djui_hud_get_screen_width() - textMaxWidth + 3
    local y = djui_hud_get_screen_height() / 2 - 30

    -- get list of runners
    local runners = {}
    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
            table.insert(runners, i)
        end
    end

    -- sort table
    table.sort(runners, function (a, b)
        return gPlayerSyncTable[a].oddballTimer < gPlayerSyncTable[b].oddballTimer
    end)

    -- get height
    local height = 30 * #runners + 30 + 10

    djui_hud_set_color(20, 20, 22, 255 / 1.4)
    djui_hud_render_rect_rounded_outlined(x, y + 1, textMaxWidth + 3, height, 35, 35, 35, 4, 255 / 1.4)

    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
    djui_hud_print_text("Scores:", x + 10, y, 1)

    for _, i in ipairs(runners) do
        y = y + 30
        local name = get_player_name(i)
        local hasStrippedTitle = false
        while djui_hud_measure_text(strip_hex(name)) > 180 do
            if not hasStrippedTitle then
                hasStrippedTitle = true
                name = get_player_name_without_title(i)
            else
                name = name:sub(1, #name - 1)
            end
        end
        local text = name .. "\\" .. rgb_to_hex(theme.text.r, theme.text.g, theme.text.b) .. "\\" .. ": " .. math.floor(gPlayerSyncTable[i].oddballTimer / 30) + 1
        if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
            text = name .. "\\" .. rgb_to_hex(theme.text.r, theme.text.g, theme.text.b) .. "\\" .. ": ???"
        end
        djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
        djui_hud_print_colored_text(text, x + 10, y, 1)
    end
end

local function hud_render()

    if gGlobalSyncTable.gamemode ~= ODDBALL then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    hud_side_panel_render()

    -- check that we dont have the modifier MODIFIER_NO_RADAR enabled
    if gGlobalSyncTable.modifier ~= MODIFIER_NO_RADAR then
        -- render radar for each player
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- make sure the states line up
                if gPlayerSyncTable[i].state == RUNNER and gPlayerSyncTable[0].state == TAGGER then -- check if we meet the checks to render the radar
                    render_radar(gMarioStates[i], icon_radar[i], false) -- render radar on player
                end
            end
        end
    end
end

local function on_warp()

    ---@type MarioState
    local m = gMarioStates[0]

    if gGlobalSyncTable.gamemode ~= ODDBALL then return end
    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end
    if not gGlobalSyncTable.eliminateOnDeath then return end
    if m.playerIndex ~= 0 then return end

    -- select a random runner
    if gPlayerSyncTable[0].state == RUNNER then
        local newRunner = math.random(1, 16)
        local s = gPlayerSyncTable[newRunner]
        while s.state ~= TAGGER do
            newRunner = math.random(1, 16)
            s = gPlayerSyncTable[newRunner]
        end
        s.state = RUNNER
        gPlayerSyncTable[0].state = TAGGER
        eliminated_popup(0)
    end
end

---@param a MarioState
---@param v MarioState
local function on_pvp(a, v)
    if gGlobalSyncTable.gamemode ~= ODDBALL then return end

    if v.playerIndex ~= 0 then return end
    -- handle pvp if we are the victim
    oddball_handle_pvp(a.playerIndex, v.playerIndex)
end

---@param aI number
---@param vI number
function oddball_handle_pvp(aI, vI)
    -- this checks and sets our states
    local a = gPlayerSyncTable[aI]
    local v = gPlayerSyncTable[vI]

    -- check if tagger tagged runner
    if  v.state == RUNNER and a.state == TAGGER
    and v.invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- flip states
        v.state = TAGGER
        a.state = RUNNER

        -- create popup
        tagged_popup(aI, vI)
        -- increase amount of tags and set invincibility timer to 1 second
        a.amountOfTags = a.amountOfTags + 1
        a.invincTimer = 1 * 30
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ON_WARP, on_warp)