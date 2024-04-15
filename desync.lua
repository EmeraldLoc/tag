
DESYNC_REASON_LEVEL = 1
DESYNC_REASON_ROUND_STATE = 2
desyncTimer = 0
desyncReason = DESYNC_REASON_LEVEL
local packetTimer = 10 * 30
---@type NetworkPlayer
local np = gNetworkPlayers[0]

local function update()

    if network_is_server() then return end

    if gGlobalSyncTable.roundState == ROUND_ACTIVE
    or gGlobalSyncTable.roundState == ROUND_WAIT
    or gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION
    or gGlobalSyncTable.roundState == ROUND_HIDING_SARDINES then
        if np.currLevelNum ~= gNetworkPlayers[network_local_index_from_global(0)].currLevelNum or not np.currAreaSyncValid then
            -- a desync happened, begin the desync timer
            desyncTimer = desyncTimer - 1
            -- by using a packet timer, we can resend the packet if it doesn't seem that it went thru
            packetTimer = packetTimer - 1
            -- set the reason for the desync to level
            desyncReason = DESYNC_REASON_LEVEL
        elseif gGlobalSyncTable.roundState == ROUND_WAIT and math.floor(gGlobalSyncTable.displayTimer / 30) > 15 then
            -- a desync happened, begin the desync timer
            desyncTimer = desyncTimer - 1
            -- by using a packet timer, we can resend the packet if it doesn't seem that it went thru
            packetTimer = packetTimer - 1
            -- set the reason for the desync to round state
            desyncReason = DESYNC_REASON_ROUND_STATE
        else goto setvars end
    else goto setvars end

    -- send a packet to the server asking to resync the player
    if packetTimer <= 0 then
        local p = { packetType = PACKET_TYPE_LEVEL_DESYNCED, globalIndex = network_global_index_from_local(0), reason = desyncReason }
        send_packet_to_server(p)
        packetTimer = 10 * 30
    end

    goto exit

    ::setvars::
    desyncTimer = 10 * 30
    packetTimer = 10 * 30

    ::exit::
end

hook_event(HOOK_UPDATE, update)