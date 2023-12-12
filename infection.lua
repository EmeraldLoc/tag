
-- constants
local ELIMINATED = 2

local function update()

    if gGlobalSyncTable.gamemode ~= INFECTION then return end

    -- set network descriptions
    for i = 0, MAX_PLAYERS - 1 do
        if gPlayerSyncTable[i].state == TAGGER and gGlobalSyncTable.modifier ~= MODIFIER_INCOGNITO then
            network_player_set_description(gNetworkPlayers[i], "Infected", 36, 214, 54, 255)
        elseif gPlayerSyncTable[i].state == RUNNER and gGlobalSyncTable.modifier ~= MODIFIER_INCOGNITO then
            network_player_set_description(gNetworkPlayers[i], "Runner", 49, 107, 232, 255)
        elseif gPlayerSyncTable[i].state == ELIMINATED then
            network_player_set_description(gNetworkPlayers[i], "Eliminated", 191, 54, 54, 255)
        end
    end
end

---@param m MarioState
local function mario_update(m)

    if gGlobalSyncTable.gamemode ~= INFECTION then return end

    m.health = 0x880 -- set mario's health to full

    if gPlayerSyncTable[m.playerIndex].state == ELIMINATED then
        m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
        m.flags = m.flags | MARIO_VANISH_CAP
        m.flags = m.flags | MARIO_WING_CAP
    end
end

local function hud_render()

    if gGlobalSyncTable.gamemode ~= INFECTION then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    -- render radar
    if gGlobalSyncTable.modifier ~= MODIFIER_NO_RADAR then
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                if gPlayerSyncTable[i].state == RUNNER and gPlayerSyncTable[0].state == TAGGER then
                    render_radar(gMarioStates[i], icon_radar[i], false)
                end
            end
        end
    end
end

---@param m MarioState
local function on_death(m)

    if gGlobalSyncTable.gamemode ~= INFECTION then return end

    if gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- become a tagger on death
        if m.playerIndex == 0 then
            if gPlayerSyncTable[0].state == RUNNER then
                gPlayerSyncTable[0].state = TAGGER
            end
        end
    end
end

---@param a MarioState
---@param v MarioState
local function allow_pvp(a, v)
    if gGlobalSyncTable.gamemode == INFECTION then
         -- check if eliminated player is trying to perform a pvp attack
         if gPlayerSyncTable[v.playerIndex].state == ELIMINATED or gPlayerSyncTable[a.playerIndex].state == ELIMINATED then return false end
    end
end

---@param a MarioState
---@param v MarioState
local function on_pvp(a, v)

    if gGlobalSyncTable.gamemode ~= INFECTION then return end

    -- check if tagger tagged runner
    if gPlayerSyncTable[v.playerIndex].state == RUNNER and gPlayerSyncTable[a.playerIndex].state == TAGGER and gPlayerSyncTable[v.playerIndex].invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE  and v.playerIndex == 0 then
        gPlayerSyncTable[v.playerIndex].state = TAGGER

        tagged_popup(a.playerIndex, v.playerIndex)
        gPlayerSyncTable[a.playerIndex].amountOfTags = gPlayerSyncTable[a.playerIndex].amountOfTags + 1
        gPlayerSyncTable[a.playerIndex].invincTimer = 1 * 30
    end
end

---@param m MarioState
---@param o Object
---@param intee InteractionType
local function allow_interact(m, o, intee)

    if gGlobalSyncTable.gamemode ~= INFECTION then return end

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
