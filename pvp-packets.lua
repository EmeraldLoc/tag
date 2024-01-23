
local function on_recieve(p)
    -- make sure pvp type is good
    if p.packetType ~= PACKET_TYPE_PVP then return end

    -- convert to local (they already should be cuz global indexes are local for server, but whatever :/)
    local aI = network_local_index_from_global(p.aI)
    local vI = network_local_index_from_global(p.vI)

    -- figure out what gamemode we are in, and run that file's designated function
    if gGlobalSyncTable.gamemode == TAG then
        tag_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == FREEZE_TAG then
        freeze_tag_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == INFECTION then
        infection_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == HOT_POTATO then
        hot_potato_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
        juggernaut_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == ASSASSINS then
        assassins_handle_pvp(aI, vI)
    end
end

-- send a pvp interaction packet to the server
function send_pvp_packet(aI, vI)
    -- convert to global
    aI = network_global_index_from_local(aI)
    vI = network_global_index_from_local(vI)
    -- send both indexes to the server, with the packet type
    local p = {packetType = PACKET_TYPE_PVP, aI = aI, vI = vI}
    -- if we are the server, run the recieve function, otherwise send
    if not network_is_server() then send_packet_to_server(p) else on_recieve(p) end
end

hook_event(HOOK_ON_PACKET_RECEIVE, on_recieve)