
---@param p any
local function recieve_packet(p)
    if p.packetType ~= nil then -- make sure the packet is valid
        -- check the packet type we specified when using the create_packet function
        if p.packetType == PACKET_TYPE_LEVEL_DESYNCED then
            if p.data.reason == DESYNC_REASON_LEVEL then
                -- send the level to the desynced player to resync them
                -- use the create packet function to create a packet with the packet type Desynced Initiate Resync
                local desyncPacket = create_packet(PACKET_TYPE_LEVEL_DESYNCED_INITIATE_RESYNC, gGlobalSyncTable.selectedLevel)
                -- send the packet to the global index that we set when the desynced player sent their global index
                send_packet(p.data.globalIndex, desyncPacket)
                print("Tag: Sent the ok to resync, desync reason is " .. p.data.reason)
            elseif p.data.reason == DESYNC_REASON_ROUND_STATE then
                -- send the round state to the desynced player to resync them
                -- use the create packet function to create a packet with the packet type Desynced Initiate Resync
                local desyncPacket = create_packet(PACKET_TYPE_LEVEL_DESYNCED_INITIATE_RESYNC, gGlobalSyncTable.roundState)
                -- send the packet to the global index that we set when the desynced player sent their global index
                send_packet(p.data.globalIndex, desyncPacket)
                print("Tag: Sent the ok to resync, desync reason is " .. p.data.reason)
            end
        elseif p.packetType == PACKET_TYPE_LEVEL_DESYNCED_INITIATE_RESYNC then
            -- Resync the player by setting the selected level to the server's selected level
            if desyncReason == DESYNC_REASON_LEVEL then
                gGlobalSyncTable.selectedLevel = p.data
            elseif desyncReason == DESYNC_REASON_ROUND_STATE then
                gGlobalSyncTable.roundState = p.data
            end
            print("Tag: Resynced the player")
        end
    end
end

-- here we recieve the packet using a hook
hook_event(HOOK_ON_PACKET_RECEIVE, recieve_packet)