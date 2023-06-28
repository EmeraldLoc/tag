
PACKET_TYPE_DESYNCED = 0
PACKET_TYPE_DESYNCED_INITIATE_RESYNC = 1

---@param data any
function send_packet_to_server(data)
	if data.packetType ~= nil and not network_is_server() then -- make sure the packet is valid and the server is not sending the packet
		-- send the packet to the sever
        network_send_to(1, true, data) -- 1 is always the server according to network_local_index_from_global()
        print("Tag: Sent packet to the server with packet type " .. data.packetType)
    elseif network_is_server() then
        print("Tag: Tried to send packet to the server when we are the server")
    else
        print("Tag: Tried to send a invalid packet to the server")
	end
end

---@param globalIndex integer
---@param data any
function send_packet(globalIndex, data)
    if data.packetType ~= nil and network_local_index_from_global(globalIndex) ~= 0 then -- make sure the packet is valid and were not sending a packet to ourselves
        -- send the packet
        network_send_to(network_local_index_from_global(globalIndex), true, data)
    elseif network_local_index_from_global(globalIndex) == 0 then
        print("Tag: Tried to send packet to the same player")
    else
        print("Tag: Tried to send a invalid packet")
    end
end

---@param data any
local function recieve_packet(data)
    if data.packetType ~= nil then -- make sure the packet is valid
        if data.packetType == PACKET_TYPE_DESYNCED then
            -- send the level to the desynced player to resync them
            send_packet(data.globalIndex, {level = gGlobalSyncTable.selectedLevel, packetType = PACKET_TYPE_DESYNCED_INITIATE_RESYNC})
            print("Tag: Sent the ok to resync")
        elseif data.packetType == PACKET_TYPE_DESYNCED_INITIATE_RESYNC then
            -- resync
            gGlobalSyncTable.selectedLevel = data.level
            print("Tag: Resynced the player")
        end
    end
end

hook_event(HOOK_ON_PACKET_RECEIVE, recieve_packet)