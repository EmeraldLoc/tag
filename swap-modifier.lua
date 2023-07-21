
local swapTimer = 0

local function update()

    if not network_is_server() then return end

    -- handle swap modifier
    if gGlobalSyncTable.modifier == MODIFIER_SWAP then
        -- dont do the math on the global sync table, since that causes lag for some reason
        swapTimer = swapTimer - 1
        gGlobalSyncTable.swapTimer = swapTimer
    else
        -- reset swap timer for when the swap modifier is enabled
        swapTimer = math.random(15 * 30, 30 * 30)
        gGlobalSyncTable.swapTimer = 30
    end
end

---@param m MarioState
local function mario_update(m)
    -- handle swap modifier
    if gGlobalSyncTable.swapTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE and gGlobalSyncTable.modifier == MODIFIER_SWAP and m.playerIndex == 0 and gPlayerSyncTable[0].state ~= SPECTATOR and gPlayerSyncTable[0].state ~= ELIMINATED_OR_FROZEN and gPlayerSyncTable[0].state ~= -1 then

        -- if we are the server, then set the swap timer back to a higher value
        if network_is_server() then
            swapTimer = math.random(15 * 30, 30 * 30)
        end

        -- select a random mario
        local randomMarioIndex = math.random(1, MAX_PLAYERS - 1)

        -- if that mario isn't connected, select another mario
        while not gNetworkPlayers[randomMarioIndex].connected or gPlayerSyncTable[randomMarioIndex].state == ELIMINATED_OR_FROZEN or gPlayerSyncTable[randomMarioIndex].state == SPECTATOR or gPlayerSyncTable[randomMarioIndex].state == -1 do
            randomMarioIndex = math.random(1, MAX_PLAYERS - 1)
        end

        -- get that mario's position
        local randomMariosPos = gMarioStates[randomMarioIndex].pos

        -- set the invincibility timer to prevent bad tags
        gPlayerSyncTable[m.playerIndex].invincTimer = 1 * 30 -- 1 second

        -- set the current position
        m.pos.x = randomMariosPos.x
        m.pos.y = randomMariosPos.y
        m.pos.z = randomMariosPos.z
    end
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)