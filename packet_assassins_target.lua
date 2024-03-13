
local function packet_recieve(p)
    if p.packetType ~= PACKET_TYPE_ASSASSINS_TARGET then return end

    local s = gPlayerSyncTable[0]
    local target = network_local_index_from_global(gPlayerSyncTable[0].assassinTarget)
    local vI = network_local_index_from_global(p.data)
    local v = gPlayerSyncTable[vI]

    -- check that the assassins target is the victim
    if target == vI then
        -- kill the target
        v.state = WILDCARD_ROLE
        -- create popup
        tagged_popup(0, vI)
        -- increase amount of tags and set assassinTarget to -1 (none)
        s.amountOfTags = s.amountOfTags + 1
        s.assassinTarget = -1
        -- stop
        return
    end

    -- set the assassin's stun timer
    s.assassinStunTimer = 1 * 30
end

hook_event(HOOK_ON_PACKET_RECEIVE, packet_recieve)