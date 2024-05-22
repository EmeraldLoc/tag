-- constants
local ELIMINATED = 2

local function update()
    if gGlobalSyncTable.gamemode ~= ASSASSINS then return end

    if gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- get target index
        local targetIndex = network_local_index_from_global(gPlayerSyncTable[0].assassinTarget)

        -- reset target index if its invalid
        if targetIndex >= 0 and targetIndex <= MAX_PLAYERS then
            if gPlayerSyncTable[targetIndex].state ~= TAGGER or not gNetworkPlayers[targetIndex].connected then
                targetIndex = -1
            end
        end

        local numberOfAssassins = 0
        for i = 1, MAX_PLAYERS - 1 do
            local np = gNetworkPlayers[i]
            local s = gPlayerSyncTable[i]

            if np.connected and s.state == TAGGER then
                numberOfAssassins = numberOfAssassins + 1
            end
        end

        if (targetIndex < 0 or targetIndex > MAX_PLAYERS)
        and gPlayerSyncTable[0].state == TAGGER
        and numberOfAssassins > 0 then
            ::selectindex::
            targetIndex = math.random(1, 15)

            if not gNetworkPlayers[targetIndex].connected
                or gPlayerSyncTable[targetIndex].state == ELIMINATED
                or gPlayerSyncTable[targetIndex].state == SPECTATOR
            then
                goto selectindex
            end
        end

        gPlayerSyncTable[0].assassinTarget = network_global_index_from_local(targetIndex)
    end
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

local function hud_side_panel_render()
    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local textMaxWidth = djui_hud_measure_text("-------------------")

    local x = djui_hud_get_screen_width() - textMaxWidth + 3
    local y = djui_hud_get_screen_height() / 2 - 30

    djui_hud_set_color(20, 20, 22, 255 / 1.4)
    djui_hud_render_rect_rounded_outlined(x, y + 1, djui_hud_measure_text("-------------------") + 3, 60, 35, 35, 35, 4, 255 / 1.4)

    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text("Target:", x + 10, y, 1)

    local targetIndex = network_local_index_from_global(gPlayerSyncTable[0].assassinTarget)

    if targetIndex >= 0 and targetIndex <= MAX_PLAYERS then
        djui_hud_print_colored_text(get_player_name_without_title(targetIndex), x + 10, y + 28, 1)
    end
end

local function hud_render()
    if gGlobalSyncTable.gamemode ~= ASSASSINS then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    -- render side panel
    if gGlobalSyncTable.roundState == ROUND_ACTIVE
    and gPlayerSyncTable[0].state ~= ELIMINATED
    and gPlayerSyncTable[0].state ~= SPECTATOR then
        hud_side_panel_render()
    end

    -- check that we dont have the modifier MODIFIER_NO_RADAR enabled
    if gGlobalSyncTable.modifier ~= MODIFIER_NO_RADAR then
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- loop thru all connnected players
                if gPlayerSyncTable[i].state == TAGGER and gPlayerSyncTable[0].state == TAGGER and network_local_index_from_global(gPlayerSyncTable[0].assassinTarget) == i then -- check if we meet the checks to render the radar
                    render_radar(gMarioStates[i], icon_radar[i], false)                                                                                                          -- render radar on player
                end
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
    if v.playerIndex ~= 0 then return end

    assassins_handle_pvp(a.playerIndex, v.playerIndex)
end

---@param aI number
---@param vI number
function assassins_handle_pvp(aI, vI)
    local a = gPlayerSyncTable[aI]
    local v = gPlayerSyncTable[vI]

    -- check if tagger tagged runner
    if v.state == TAGGER and a.state == TAGGER
        and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- send packet to attacker, since he has the target
        local p = create_packet(PACKET_TYPE_ASSASSINS_TARGET, network_global_index_from_local(vI))
        send_packet(network_global_index_from_local(aI), p)
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
