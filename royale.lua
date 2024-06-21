
---@param m MarioState
local function mario_update(m)
    if gGlobalSyncTable.gamemode ~= ROYALE then return end

    m.health = 0x880 -- set mario's health to full
end

local function hud_render()

    if gGlobalSyncTable.gamemode ~= ROYALE then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    if gPlayerSyncTable[0].state == TAGGER then
        local theme = get_selected_theme()
        local text = gPlayerSyncTable[0].amountOfTags .. " Tag"
        if gPlayerSyncTable[0].amountOfTags ~= 1 then text = text .. "s" end
        local width = djui_hud_measure_text(text) * 1.5 + 20
        local height = 40 * 1.5
        local x = djui_hud_get_screen_width() / 2 - width / 2
        local y = djui_hud_get_screen_height() - height - 20
        djui_hud_set_color(theme.background.r, theme.background.g, theme.background.b, 255/1.4)
        djui_hud_render_rect_rounded_outlined(x, y, width, height, theme.backgroundOutline.r, theme.backgroundOutline.g, theme.backgroundOutline.b, 4, 255 / 1.4)
        djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
        djui_hud_print_text(text, x + width / 12, y + 5, 1.5)
    end

    djui_hud_set_resolution(RESOLUTION_N64)

    -- check that we dont have the modifier MODIFIER_NO_RADAR enabled
    if gGlobalSyncTable.modifier ~= MODIFIER_NO_RADAR then
        -- render radar for each player
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- make sure the states line up
                if gPlayerSyncTable[i].state == TAGGER and gPlayerSyncTable[0].state == TAGGER then -- check if we meet the checks to render the radar
                    render_radar(gMarioStates[i], icon_radar[i], false) -- render radar on player
                end
            end
        end
    end
end

local function on_warp()

    ---@type MarioState
    local m = gMarioStates[0]

    if gGlobalSyncTable.gamemode ~= ROYALE then return end
    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end
    if not gGlobalSyncTable.eliminateOnDeath then return end
    if m.playerIndex ~= 0 then return end

    -- lose a tag
    if gPlayerSyncTable[0].state == TAGGER then
        gPlayerSyncTable[0].amountOfTags = gPlayerSyncTable[0].amountOfTags - 1
    end
end

---@param a MarioState
---@param v MarioState
local function on_pvp(a, v)
    if gGlobalSyncTable.gamemode ~= ROYALE then return end

    if v.playerIndex ~= 0 then return end
    -- handle pvp if we are the victim
    royale_handle_pvp(a.playerIndex, v.playerIndex)
end

---@param aI number
---@param vI number
function royale_handle_pvp(aI, vI)
    -- this checks and sets our states
    local a = gPlayerSyncTable[aI]
    local v = gPlayerSyncTable[vI]

    -- check if tagger tagged tagger
    if  v.invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE
    and v.state == TAGGER and a.state == TAGGER then
        -- increase amount of tags and set victim's invincibility timer to 1 second
        a.amountOfTags = a.amountOfTags + 1
        v.invincTimer = 1 * 30
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ON_WARP, on_warp)