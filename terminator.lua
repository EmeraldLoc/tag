
-- constants
-- this is another player role, a custom one, you will notice it's set to the same thing
-- as main.lua's WILDCARD_ROLE variable, this is intentional
local ELIMINATED = 2

---@param m MarioState
local function mario_update(m)

    if gGlobalSyncTable.gamemode ~= TERMINATOR then return end

    m.health = 0x880 -- set mario's health to full

    if gPlayerSyncTable[m.playerIndex].state == ELIMINATED then
        -- set model state
        m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA -- vanish cap style
        -- make mario have vanish cap and wing cap (wait so why did I do the line above? Idk)
        m.flags = m.flags | MARIO_VANISH_CAP
        m.flags = m.flags | MARIO_WING_CAP
    end
end

local function hud_render()

    if gGlobalSyncTable.gamemode ~= TERMINATOR then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

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

    if gGlobalSyncTable.gamemode ~= TERMINATOR then return end
    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end
    if not gGlobalSyncTable.eliminateOnDeath then return end
    if gPlayerSyncTable[0].state ~= RUNNER then return end
    if m.playerIndex ~= 0 then return end

    -- set us to eliminated
    gPlayerSyncTable[0].state = ELIMINATED
    eliminated_popup(0)
end

---@param a MarioState
---@param v MarioState
local function allow_pvp(a, v)
    if gGlobalSyncTable.gamemode ~= TERMINATOR then return end

    -- check if eliminated player is trying to perform a pvp attack
    if gPlayerSyncTable[v.playerIndex].state == ELIMINATED or gPlayerSyncTable[a.playerIndex].state == ELIMINATED then return false end
end

---@param a MarioState
---@param v MarioState
local function on_pvp(a, v)
    if gGlobalSyncTable.gamemode ~= TERMINATOR then return end

    if v.playerIndex ~= 0 then return end
    -- handle pvp if we are the victim
    terminator_handle_pvp(a.playerIndex, v.playerIndex)
end

---@param aI number
---@param vI number
function terminator_handle_pvp(aI, vI)
    -- this checks and sets our states
    local a = gPlayerSyncTable[aI]
    local v = gPlayerSyncTable[vI]

    -- check if tagger tagged runner
    if  v.state == RUNNER and a.state == TAGGER
    and v.invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- set victim to eliminated
        v.state = ELIMINATED

        -- create popup
        tagged_popup(aI, vI)
        -- increase amount of tags and set invincibility timer to 1 second
        a.amountOfTags = a.amountOfTags + 1
        a.invincTimer = 1 * 30
    end
end

---@param m MarioState
---@param o Object
---@param intee InteractionType
local function allow_interact(m, o, intee)
    if gGlobalSyncTable.gamemode ~= TERMINATOR then return end

    -- check if player interacts with another player
    if intee == INTERACT_PLAYER then
        for i = 0, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- find the other player and check his state
                if gMarioStates[i].marioObj == o and (gPlayerSyncTable[m.playerIndex].state == ELIMINATED or gPlayerSyncTable[i].state == ELIMINATED) then
                    -- don't allow the interaction
                    return false
                end
            end
        end
    end
end

---@param m MarioState
local function before_phys_step(m)
    if gGlobalSyncTable.gamemode ~= TERMINATOR then return end
    if m.playerIndex ~= 0 then return end
    if gPlayerSyncTable[0].state ~= TAGGER then return end
    if gPlayerSyncTable[0].boosting then return end

    if  m.action ~= ACT_BACKWARD_AIR_KB
    and m.action ~= ACT_FORWARD_AIR_KB
    and m.action ~= ACT_HARD_BACKWARD_AIR_KB
    and m.action ~= ACT_HARD_FORWARD_AIR_KB
    and m.action ~= ACT_BACKWARD_AIR_KB
    and m.action ~= ACT_FORWARD_AIR_KB then
        -- give terminator a speed boost
        m.vel.x = m.vel.x * 1.03
        m.vel.z = m.vel.z * 1.03
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)