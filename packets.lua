
PACKET_TYPE_DESYNCED = 0
PACKET_TYPE_DESYNCED_INITIATE_RESYNC = 1

--[[
Developer Notes when copying this system:
This system is developed by EmeraldLockdown, however no
credit is needed if your using it in your mod because it's simple.

HOW TO USE:
First, create your packet types (seen above these comments)
It should be pretty straight forward, you just set a packet
type for..... well.... different type of packets

To create a packet, use the create packet function.
Example:
`local p = create_packet(PACKET_TYPE_DESYNCED, network_global_index_from_local(0))`

In this example we set the packet type to PACKET_TYPE_DESYNCED,
and set the data to our global index

To send a packet to the server, you can use the
send_packet_to_server function, here's an example
using our previously made packet

`send_packet_to_server(p)`

Now we sent a packet to the server.... but what if we want to send a packet
to someone else? Well you can do this pretty easily by using the
send_packet function. Here's an example:

`send_packet(network_global_index_from_local(2), p)`

Now that player will recieve the packet, note that the send_packet
function uses the global index, not local.

Goto the file desync-packet.lua to learn how to recieve packets

You cannot send another table within the
data param in the create_packet function. I assume because you
can't have more than 1 table in a packet. I'm not so sure, so if you
can find something ,that would be great!
--]]

---@param packetType integer
---@param data any
function create_packet(packetType, data)
    return {packetType = packetType, data = data}
end

---@param p any
function send_packet_to_server(p)
	if p.packetType ~= nil and not network_is_server() then -- make sure the packet is valid and the server is not sending the packet
		-- send the packet to the sever
        network_send_to(1, true, p) -- 1 is always the server
        print("Tag: Sent packet to the server with packet type " .. p.packetType)
    elseif network_is_server() then
        print("Tag: Tried to send packet to the server when we are the server")
    else
        print("Tag: Tried to send a invalid packet to the server")
	end
end

---@param globalIndex integer
---@param p any
function send_packet(globalIndex, p)
    if p.packetType ~= nil and network_local_index_from_global(globalIndex) ~= 0 then -- make sure the packet is valid and were not sending a packet to ourselves
        -- send the packet
        network_send_to(network_local_index_from_global(globalIndex), true, p)
    elseif network_local_index_from_global(globalIndex) == 0 then
        print("Tag: Tried to send packet to the same player")
    else
        print("Tag: Tried to send a invalid packet")
    end
end
