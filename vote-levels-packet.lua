
local function packet_recieve(p)
    if p.packetType == PACKET_TYPE_SEND_LEVELS then
        -- we have retreieved levels from the server, set our variables
        voteRandomLevels[1] = p.level1
        voteRandomLevels[2] = p.level2
        voteRandomLevels[3] = p.level3
    end
end

hook_event(HOOK_ON_PACKET_RECEIVE, packet_recieve)