
local function update()

    if gGlobalSyncTable.gamemode ~= JUGGERNAUT then return end

    -- set network descriptions
    for i = 0, MAX_PLAYERS - 1 do
        if gPlayerSyncTable[i].state == TAGGER then
            network_player_set_description(gNetworkPlayers[i], "Tagger", 232, 46, 46, 255)
        elseif gPlayerSyncTable[i].state == RUNNER then
            network_player_set_description(gNetworkPlayers[i], "Runner", 49, 107, 232, 255)
        end
    end

    if gPlayerSyncTable[0].state == RUNNER and gPlayerSyncTable[0].juggernautTags > gGlobalSyncTable.juggernautTagsReq then
        gPlayerSyncTable[0].state = TAGGER
    end
end

---@param m MarioState
local function mario_update(m)
    if gGlobalSyncTable.gamemode ~= JUGGERNAUT then return end

    m.health = 0x880 -- set mario's health to full
end

---@param m MarioState
local function before_phys_step(m)
    if gGlobalSyncTable.gamemode ~= JUGGERNAUT then return end

    if gPlayerSyncTable[0].state == RUNNER and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        m.vel.x = m.vel.x * 0.7
        m.vel.z = m.vel.z * 0.7
    end
end

local function hud_bottom_render()
    if gPlayerSyncTable[0].state == RUNNER and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        local text = "You can withstand " .. tostring(gGlobalSyncTable.juggernautTagsReq - gPlayerSyncTable[0].juggernautTags) .. " more tags"
        local scale = 0.5

        -- get width of screen and text
        local screenWidth = djui_hud_get_screen_width()
        local screenHeight = djui_hud_get_screen_height()
        local width = djui_hud_measure_text(text) * scale

        -- get positions
        local x = (screenWidth - width) / 2.0
        local y = screenHeight - 16

        -- render bottom
        djui_hud_set_color(0, 0, 0, 128);
        djui_hud_render_rect(x - 6, y, width + 12, 16);

        djui_hud_set_color(255, 255, 255, 255);
        djui_hud_print_text(text, x, y, scale);
    end
end

local function hud_render()

    if gGlobalSyncTable.gamemode ~= JUGGERNAUT then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    -- render bottom hud
    hud_bottom_render()

    -- check that we dont have the modifier MODIFIER_NO_RADAR enabled
    if gGlobalSyncTable.modifier ~= MODIFIER_NO_RADAR then
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- loop thru all connnected players
                if gPlayerSyncTable[i].state == RUNNER and gPlayerSyncTable[0].state == TAGGER then -- check if we meet the checks to render the radar
                    render_radar(gMarioStates[i], icon_radar[i], false) -- render radar on player
                end
            end
        end
    end
end

---@param m MarioState
local function on_death(m)

    if gGlobalSyncTable.gamemode ~= JUGGERNAUT then return end

    if gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- End the game if the juggernaut dies
        if m.playerIndex == 0 then
            if gPlayerSyncTable[0].state == RUNNER then
                gPlayerSyncTable[0].state = TAGGER -- end the game
            end
        end
    end
end

---@param a MarioState
---@param v MarioState
local function on_pvp(a, v)

    if gGlobalSyncTable.gamemode ~= JUGGERNAUT then return end

    -- check if tagger tagged runner
    if gPlayerSyncTable[v.playerIndex].state == RUNNER and gPlayerSyncTable[a.playerIndex].state == TAGGER and gPlayerSyncTable[v.playerIndex].invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE and v.playerIndex == 0 then
        gPlayerSyncTable[v.playerIndex].juggernautTags = gPlayerSyncTable[v.playerIndex].juggernautTags + 1
        gPlayerSyncTable[a.playerIndex].amountOfTags = gPlayerSyncTable[a.playerIndex].amountOfTags + 1
    end
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ON_DEATH, on_death)
