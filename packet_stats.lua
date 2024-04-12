
local function packet_recieve(p)
    if p.packetType == PACKET_TYPE_REQUEST_STATS then
        -- figure out what stats we are sending over
        if p.statIndex < MIN_GAMEMODE then
            -- not a gamemode, assume global
            -- create packet
            local newP = {
                packetType = PACKET_TYPE_RECEIVE_STATS,
                playTime = stats.globalStats.playTime,
                runnerVictories = stats.globalStats.runnerVictories,
                taggerVictories = stats.globalStats.taggerVictories,
                totalTags = stats.globalStats.totalTags,
                totalTimeAsRunner = stats.globalStats.totalTimeAsRunner,
            }
            -- send packet to sender
            network_send_to(network_local_index_from_global(p.globalIndex), true, newP)
        else
            -- packet is a gamemode, act accordingly
            -- create packet
            local newP = {
                packetType = PACKET_TYPE_RECEIVE_STATS,
                playTime = stats[p.statIndex].playTime,
                runnerVictories = stats[p.statIndex].runnerVictories,
                taggerVictories = stats[p.statIndex].taggerVictories,
                totalTags = stats[p.statIndex].totalTags,
                totalTimeAsRunner = stats[p.statIndex].totalTimeAsRunner,
            }
            -- send packet to sender
            network_send_to(network_local_index_from_global(p.globalIndex), true, newP)
        end
    elseif p.packetType == PACKET_TYPE_RECEIVE_STATS then
        -- set remote stats
        remoteStats = {
            playTime = p.playTime,
            runnerVictories = p.runnerVictories,
            taggerVictories = p.taggerVictories,
            totalTags = p.totalTags,
            totalTimeAsRunner = p.totalTimeAsRunner
        }
    end
end

hook_event(HOOK_ON_PACKET_RECEIVE, packet_recieve)