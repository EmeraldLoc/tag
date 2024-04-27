
local function packet_recieve(p)
    if p.packetType == PACKET_TYPE_REQUEST_ACHIEVEMENTS then
        local newP = {}
        -- loop thru each completed achievement
        for i, _ in pairs(completedAchievements) do
            newP[i] = true
        end

        newP.packetType = PACKET_TYPE_RECEIVE_ACHIEVEMENTS

        send_packet(p.globalIndex, newP)

        log_to_console("Tag: Recieved Request for Achievements, Sending Achievements To " .. p.globalIndex .. "!")
    elseif p.packetType == PACKET_TYPE_RECEIVE_ACHIEVEMENTS then
        log_to_console("Tag: Retrieved Achievements, setting remote completed achievements!")
        -- loop thru all achievements
        for i, achievement in pairs(achievements) do
            if p[i] == true then
                remoteCompletedAchievements[i] = true
            end
        end
    end
end

hook_event(HOOK_ON_PACKET_RECEIVE, packet_recieve)