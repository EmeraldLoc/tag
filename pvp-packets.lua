
local function on_recieve(p)

    -- make sure packet type is good
    if p.packetType ~= PACKET_TYPE_PVP then return end

    -- we are now the server, so reconvert to local indexes (they already should be cuz global indexes are local for server, but whatever :/)
    local aI = network_local_index_from_global(p.aI)
    local vI = network_local_index_from_global(p.vI)

    -- figure out what gamemode we are in, and run that file's designated function
    if gGlobalSyncTable.gamemode == TAG then
        -- if you saw the tag handle pvp function, here this is! This is done for all gamemodes!
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

-- send a pvp interaction packet to the server (this is what you see in files like tag.lua)
function send_pvp_packet(aI, vI)
    -- convert local indexes to global indexes
    aI = network_global_index_from_local(aI)
    vI = network_global_index_from_local(vI)
    -- send both indexes to the server, with the packet type
    local p = {packetType = PACKET_TYPE_PVP, aI = aI, vI = vI}
    -- if we are the server, run the recieve function (above this one), otherwise send to server
    if not network_is_server() then send_packet_to_server(p) else on_recieve(p) end
end

hook_event(HOOK_ON_PACKET_RECEIVE, on_recieve)

-- Now, you should go ahead and check out misc.lua!