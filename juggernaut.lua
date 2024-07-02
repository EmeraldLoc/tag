
local function update()
    if gGlobalSyncTable.gamemode ~= JUGGERNAUT then return end

    if  gPlayerSyncTable[0].state == RUNNER
    and gPlayerSyncTable[0].tagLives <= 0
    and gGlobalSyncTable.roundState == ROUND_ACTIVE then
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
        if  m.action ~= ACT_BACKWARD_AIR_KB
        and m.action ~= ACT_FORWARD_AIR_KB
        and m.action ~= ACT_HARD_BACKWARD_AIR_KB
        and m.action ~= ACT_HARD_FORWARD_AIR_KB
        and m.action ~= ACT_BACKWARD_AIR_KB
        and m.action ~= ACT_FORWARD_AIR_KB
        and m.action ~= ACT_WATER_JUMP then
            -- give juggernaut a constant speed boost
            m.vel.x = m.vel.x * 1.15
            m.vel.z = m.vel.z * 1.15
        end
    end
end

local function hud_bottom_render()
    if gPlayerSyncTable[0].state == RUNNER and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        render_bar("Lives Remaining: " .. tostring(gPlayerSyncTable[0].tagLives), gPlayerSyncTable[0].tagLives, 0, gGlobalSyncTable.tagMaxLives, 66, 176, 245)
    end
end

local function hud_render()

    if gGlobalSyncTable.gamemode ~= JUGGERNAUT then return end

    -- set djui font and resolution
    djui_hud_set_font(djui_menu_get_font())
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

local function on_warp()

    ---@type MarioState
    local m = gMarioStates[0]

    if gGlobalSyncTable.gamemode ~= JUGGERNAUT then return end
    if not gGlobalSyncTable.eliminateOnDeath then return end
    if m.playerIndex ~= 0 then return end
    if gNetworkPlayers[0].currLevelNum ~= levels[gGlobalSyncTable.selectedLevel].level then return end
    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end

    -- end the game if the juggernaut dies
    if gPlayerSyncTable[0].state == RUNNER then
        gPlayerSyncTable[0].state = TAGGER -- end the game
    end
end

---@param a MarioState
---@param v MarioState
local function on_pvp(a, v)
    if gGlobalSyncTable.gamemode ~= JUGGERNAUT then return end
    if v.playerIndex ~= 0 then return end
    juggernaut_handle_pvp(a.playerIndex, v.playerIndex)
end

---@param aI number
---@param vI number
function juggernaut_handle_pvp(aI, vI)

    local a = gPlayerSyncTable[aI]
    local v = gPlayerSyncTable[vI]

    -- check if tagger tagged runner
    if v.state == RUNNER and a.state == TAGGER and v.invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- decrease tag lives
        v.tagLives = v.tagLives - 1
        -- set inviniciblity to 3 seconds, and increase tag count
        v.invincTimer = 3 * 30
        a.amountOfTags = a.amountOfTags + 1
    end
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ON_WARP, on_warp)
