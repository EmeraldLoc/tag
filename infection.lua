
-- constants
local ELIMINATED = 2

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
    djui_hud_set_font(djui_menu_get_font())
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

local function on_warp()

    ---@type MarioState
    local m = gMarioStates[0]

    if gGlobalSyncTable.gamemode ~= INFECTION then return end
    if not gGlobalSyncTable.eliminateOnDeath then return end
    if m.playerIndex ~= 0 then return end
    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end

    -- become a tagger on death
    if gPlayerSyncTable[0].state == RUNNER then
        gPlayerSyncTable[0].state = TAGGER
        tagger_popup(0)
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
    if v.playerIndex ~= 0 then return end
    infection_handle_pvp(a.playerIndex, v.playerIndex)
end

---@param aI number
---@param vI number
function infection_handle_pvp(aI, vI)

    local a = gPlayerSyncTable[aI]
    local v = gPlayerSyncTable[vI]

    -- check if tagger tagged runner
    if v.state == RUNNER and a.state == TAGGER and v.invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- set runner to tagger/infected
        v.state = TAGGER

        -- create popup
        tagged_popup(aI, vI)
        -- increase amount of tags and set invincibility to a second
        a.amountOfTags = a.amountOfTags + 1
        a.invincTimer = 1 * 30
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

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_ON_WARP, on_warp)
