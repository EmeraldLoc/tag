-- constants
local ELIMINATED = 2

-- variables
local eliminatedTimer = 0

local function update()

    if gGlobalSyncTable.gamemode ~= ASSASSINS then return end

    -- set network descriptions
    for i = 0, MAX_PLAYERS - 1 do
        if gPlayerSyncTable[i].state == TAGGER and gGlobalSyncTable.modifier ~= MODIFIER_INCOGNITO then
            network_player_set_description(gNetworkPlayers[i], "Assassin", 232, 46, 46, 255)
        elseif gPlayerSyncTable[i].state == ELIMINATED then
            network_player_set_description(gNetworkPlayers[i], "Eliminated", 191, 54, 54, 255)
        end
    end

    -- set eliminated timer
    if eliminatedTimer > 0 then
        eliminatedTimer = eliminatedTimer - 1
    end

    local targetIndex = network_local_index_from_global(gPlayerSyncTable[0].assassinTarget)

    if targetIndex >= 0 and targetIndex <= MAX_PLAYERS then
        if gPlayerSyncTable[targetIndex].state == ELIMINATED or gPlayerSyncTable[targetIndex].state == SPECTATOR or not gNetworkPlayers[targetIndex].connected then
            targetIndex = -1
        end
    end

    if (targetIndex < 0 or targetIndex > MAX_PLAYERS) and gPlayerSyncTable[0].state ~= ELIMINATED and gPlayerSyncTable[0].state ~= SPECTATOR then
        local attempts = 0

        ::selectindex::
        attempts = attempts + 1
        targetIndex = math.random(1, 15)

        if attempts > 0.01 * 30 then -- pretty terrible way to fix the host freezing when the host tags the final player
            goto updateend
        end

        if not gNetworkPlayers[targetIndex].connected or gPlayerSyncTable[targetIndex].state == ELIMINATED or gPlayerSyncTable[targetIndex].state == SPECTATOR then goto selectindex end
    end

    ::updateend::

    gPlayerSyncTable[0].assassinTarget = network_global_index_from_local(targetIndex)
end

---@param m MarioState
local function mario_update(m)

    if gGlobalSyncTable.gamemode ~= ASSASSINS then return end

    m.health = 0x880 -- set mario's health to full

    if gPlayerSyncTable[m.playerIndex].state == ELIMINATED then
        -- set model state
        m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
        m.flags = m.flags | MARIO_VANISH_CAP
        m.flags = m.flags | MARIO_WING_CAP
    end

    -- handle being stunned
    if gPlayerSyncTable[0].assassinStunTimer > 0 and m.playerIndex == 0 then
        gPlayerSyncTable[0].assassinStunTimer = gPlayerSyncTable[0].assassinStunTimer - 1
        set_mario_action(m, ACT_SHOCKED, 0)
    end
end

local function hud_bottom_render()

    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end
    if eliminatedTimer <= 0 then return end

    -- set text and scale
    local text = "You are Eliminated. use the tp command to teleport to anyone"
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

    djui_hud_set_color(255, 54, 54, 255);
    djui_hud_print_text(text, x, y, scale);
end

local function hud_side_panel_render()

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local x = djui_hud_get_screen_width() - djui_hud_measure_text("-------------------") + 3
    local y = djui_hud_get_screen_height() / 2 - 30

    djui_hud_set_color(0, 0, 0, 127)
    djui_hud_render_rect(x, y + 1, djui_hud_measure_text("-------------------") + 3, 60)

    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text("Target:", x + 10, y, 1)

    local targetIndex = network_local_index_from_global(gPlayerSyncTable[0].assassinTarget)

    if targetIndex >= 0 and targetIndex <= MAX_PLAYERS then
        local r, g, b = hex_to_rgb(network_get_player_text_color_string(targetIndex))
        djui_hud_set_color(r, g, b, 255)
        djui_hud_print_text(strip_hex(gNetworkPlayers[targetIndex].name), x + 10, y + 28, 1)
    end
end

local function hud_render()

    if gGlobalSyncTable.gamemode ~= ASSASSINS then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    -- render bottom hud
    hud_bottom_render()

    -- render side panel
    if gGlobalSyncTable.roundState == ROUND_ACTIVE and gPlayerSyncTable[0].state ~= ELIMINATED and gPlayerSyncTable[0].state ~= SPECTATOR then
        hud_side_panel_render()
    end

    -- check that we dont have the modifier MODIFIER_NO_RADAR enabled
    if gGlobalSyncTable.modifier ~= MODIFIER_NO_RADAR then
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- loop thru all connnected players
                if gPlayerSyncTable[i].state == TAGGER and gPlayerSyncTable[0].state == TAGGER and network_local_index_from_global(gPlayerSyncTable[0].assassinTarget) == i then -- check if we meet the checks to render the radar
                    render_radar(gMarioStates[i], icon_radar[i], false) -- render radar on player
                end
            end
        end
    end
end

---@param m MarioState
local function on_death(m)

    if gGlobalSyncTable.gamemode ~= ASSASSINS then return end

    if gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- become eliminated on death
        if m.playerIndex == 0 then
            if gPlayerSyncTable[0].state == RUNNER then
                gPlayerSyncTable[0].state = ELIMINATED
                eliminated_popup(0)

                eliminatedTimer = 8 * 30 -- 8 seconds
            end
        end
    end
end

---@param a MarioState
---@param v MarioState
local function allow_pvp(a, v)
    if gGlobalSyncTable.gamemode ~= ASSASSINS then return end

    -- check if eliminated player is trying to perform a pvp attack
    if gPlayerSyncTable[v.playerIndex].state == ELIMINATED or gPlayerSyncTable[a.playerIndex].state == ELIMINATED then return false end
end

---@param a MarioState
---@param v MarioState
local function on_pvp(a, v)
    if gGlobalSyncTable.gamemode ~= ASSASSINS then return end

    if a.playerIndex == 0 then

        local aS = gPlayerSyncTable[a.playerIndex]

        -- send packet to the server giving the server our target for resyncing if needed
        local p = {packetType = PACKET_TYPE_ASSASSINS_TARGET, assassinsTarget = aS.assassinTarget, assassinsIndex = network_global_index_from_local(a.playerIndex)}
        send_packet_to_server(p)

        return
    end

    if v.playerIndex ~= 0 then return end

    send_pvp_packet(a.playerIndex, v.playerIndex)
end

---@param aI number
---@param vI number
function assassins_handle_pvp(aI, vI)

    local a = gPlayerSyncTable[aI]
    local v = gPlayerSyncTable[vI]

    -- check if tagger tagged runner
    if v.state == TAGGER and a.state == TAGGER and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        if network_local_index_from_global(a.assassinTarget) == vI then
            v.state = ELIMINATED
            tagged_popup(aI, vI)
            a.amountOfTags = a.amountOfTags + 1
            a.assassinTarget = -1
        else
            a.assassinStunTimer = 1 * 30
        end
    end
end

---@param m MarioState
---@param o Object
---@param intee InteractionType
local function allow_interact(m, o, intee)

    if gGlobalSyncTable.gamemode ~= ASSASSINS then return end

    -- check if player interacts with another player
    if intee == INTERACT_PLAYER then
        for i = 0, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- find the other player and check his state
                if gMarioStates[i].marioObj == o and (gPlayerSyncTable[m.playerIndex].state == ELIMINATED or gPlayerSyncTable[i].state == ELIMINATED) then
                    return false
                end
            end
        end
    end
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_ON_DEATH, on_death)
