
local function packet_recieve(p)
    if p.packetType ~= PACKET_TYPE_ASSASSINS_TARGET then return end

    local aS = gPlayerSyncTable[p.assassinsIndex]
    local aTarget = gPlayerSyncTable[p.assassinTarget]

    -- check if the indexes are synced
    if aTarget ~= aS.assassinTarget then
        -- they aren't synced, so resync the server
        aS.assassinTarget = aTarget
    end
end

hook_event(HOOK_ON_PACKET_RECEIVE, packet_recieve)