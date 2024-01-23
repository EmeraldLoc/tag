
-- would not recommend taking this code, it's not the best in the world....

TEXTURE_RANDOM_PAINTING = get_texture_info("random_painting")

voteRandomLevels = {}
local fade = 0
local screenWidth = djui_hud_get_screen_width()
local screenHeight = djui_hud_get_screen_height()
local selectedLevel = 1
local joystickCooldown = 0
local justEnabled = true

local function hud_black_bg()
    djui_hud_set_color(28, 28, 30, fade)
    djui_hud_render_rect(0, 0, screenWidth, screenHeight)
end

local function hud_map_vote()

    if voteRandomLevels[1] == nil then
        -- render loading
        local text = "Loading.."
        local x = (screenWidth - djui_hud_measure_text("Loading...")) / 2
        local y = screenHeight / 2

        djui_hud_set_color(220, 220, 220, fade)
        djui_hud_print_text(text, x, y, 1)

        return
    end

    -- render top text
    local text = "Vote for a Map"
    djui_hud_set_color(220, 220, 220, fade)
    djui_hud_print_text(text, (screenWidth - djui_hud_measure_text(text)) / 2, 50, 1)

    local currentMapWinner = -1
    local currentMapHighestVotes = -1

    -- render 4 paintings
    for i = 1, 4 do
        -- get number of votes
        local votes = 0
        for v = 0, MAX_PLAYERS - 1 do
            if gNetworkPlayers[v].connected then
                if gPlayerSyncTable[v].votingNumber == i then
                    votes = votes + 1
                end
            end
        end

        if votes > currentMapHighestVotes then
            currentMapWinner = i
            currentMapHighestVotes = votes
        end

        -- get positions
        local x = (screenWidth - (256 * 4 + 40 * 3)) / 2 + (256 + 40) * (i - 1) -- don't ask
        local y = (screenHeight - 400) / 2

        -- render question mark if there's no painting assigned
        djui_hud_set_color(35, 35, 37, fade)
        djui_hud_render_rect(x, y, 256, 256)

        djui_hud_set_color(220, 220, 220, fade) -- #dcdcdc
        djui_hud_print_text("?", x + ((128 - djui_hud_measure_text("?"))) - 16, y + 32, 5) -- don't ask #2

        if not isRomhack or i == 4 then
            djui_hud_set_color(255, 255, 255, fade)
            if i ~= 4 then
                djui_hud_render_texture(levels[voteRandomLevels[i]].painting, x, y, 4, 4)
            else
                djui_hud_render_texture(TEXTURE_RANDOM_PAINTING, x, y, 1, 1)
            end
        end

        y = (screenHeight + 200) / 2

        if gPlayerSyncTable[0].votingNumber == i then
            djui_hud_set_color(83, 153, 77, fade)
        elseif selectedLevel == i then
            djui_hud_set_color(43, 43, 45, fade)
        else
            djui_hud_set_color(35, 35, 37, fade)
        end
        djui_hud_render_rect(x, y, 256, 35)
        djui_hud_set_color(255, 255, 255, fade)
        if i ~= 4 then
            if not isRomhack then
                if levels[voteRandomLevels[i]].level == LEVEL_SSL and levels[voteRandomLevels[i]].area == 2 then
                    -- override for issl
                    text = "Inside Shifting Sand Land: " .. tostring(votes)
                elseif levels[voteRandomLevels[i]].level == LEVEL_BOWSER_1 then
                    text = "Bowser 1: " .. tostring(votes)
                else
                    text = tostring(name_of_level(levels[voteRandomLevels[i]].level, levels[voteRandomLevels[i]].area)) .. ": " .. tostring(votes)
                end
            else
                text = tostring(name_of_level(voteRandomLevels[i], 1)) .. ": " .. tostring(votes)
            end
        else
            text = "Random: " .. tostring(votes)
        end
        djui_hud_print_text(text, x + 128 - (djui_hud_measure_text(text) / 2), y, 1)
    end

    -- render bottom text
    if math.floor(gGlobalSyncTable.displayTimer / 30) > 15 then
        text = "You may begin voting in " .. math.floor(gGlobalSyncTable.displayTimer / 30) - 15
    elseif math.floor(gGlobalSyncTable.displayTimer / 30) > 5 then
        text = "You have " .. tostring(math.floor(gGlobalSyncTable.displayTimer / 30) - 5) .. " seconds remaining"
    else
        if currentMapWinner == 4 then
            text = "A Random Level has been selected!"
        else
            if not isRomhack then
                local level = levels[voteRandomLevels[currentMapWinner]]

                if level.level == LEVEL_SSL and level.area == 2 then
                    -- override for issl
                    text = "Inside Shifting Sand Land has been selected!"
                elseif level.level == LEVEL_BOWSER_1 then
                    text = "Bowser 1 has been selected!"
                else
                    text = name_of_level(level.level, level.area) .. " has been selected!"
                end
            else
                local level = voteRandomLevels[currentMapWinner]
                text = name_of_level(level, 1) .. " has been selected!"
            end
        end
    end
    djui_hud_set_color(220, 220, 220, fade)
    djui_hud_print_text(text, (screenWidth - djui_hud_measure_text(text)) / 2, screenHeight - 50, 1)
end

local function on_render()
    if gGlobalSyncTable.roundState ~= ROUND_VOTING then
        justEnabled = true
        selectedLevel = 1
        gPlayerSyncTable[0].votingNumber = 0
        fade = 0
        voteRandomLevels = {}
        return
    end

    if justEnabled then
        if network_is_server() then
            while voteRandomLevels[3] == nil do
                local randomLevel = 0
                if isRomhack then randomLevel = course_to_level(math.random(COURSE_MIN, COURSE_RR))
                else randomLevel = math.random(1, #levels) end
                while table.contains(voteRandomLevels, randomLevel) or table.contains(blacklistedCourses, level_to_course(randomLevel)) or (level_is_vanilla_level(randomLevel) and isRomhack) or randomLevel == gGlobalSyncTable.selectedLevel do
                    if isRomhack then randomLevel = course_to_level(math.random(COURSE_MIN, COURSE_RR))
                    else randomLevel = math.random(1, #levels) end
                end
                table.insert(voteRandomLevels, randomLevel)
            end

            -- send over our levels
            for i = 1, MAX_PLAYERS - 1 do
                if gNetworkPlayers[i].connected then
                    -- create packet from scratch instead of using generic method for more slots
                    local p = {packetType = PACKET_TYPE_SEND_LEVELS, level1 = voteRandomLevels[1], level2 = voteRandomLevels[2], level3 = voteRandomLevels[3]}
                    -- send to players
                    send_packet(network_global_index_from_local(i), p)
                end
            end
        end

        justEnabled = false
    end

    if fade < 255 and gGlobalSyncTable.displayTimer > 0 then
        fade = fade + 20
        if fade >= 255 then fade = 255 end
    elseif fade > 0 and gGlobalSyncTable.displayTimer <= 0 then
        fade = fade - 20
        if fade < 0 then fade = 0 end
    end

    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)
    hud_black_bg()
    hud_map_vote()
end

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 or gGlobalSyncTable.roundState ~= ROUND_VOTING then return end

    joystickCooldown = joystickCooldown - 1

    -- if our stick is at 0, then set joystickCooldown to 0
    if m.controller.stickX == 0 then joystickCooldown = 0 end

    if joystickCooldown <= 0 and gPlayerSyncTable[0].votingNumber == 0 then
        -- check where our stick is
        if m.controller.stickX > 0.5 then
            -- moving right, move our selection right
            selectedLevel = selectedLevel + 1
            if selectedLevel > 4 then selectedLevel = 4 end
            joystickCooldown = 0.2 * 30
            play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        end

        if m.controller.stickX < -0.5 then
            -- moving left, move our selection left
            selectedLevel = selectedLevel - 1
            if selectedLevel < 1 then selectedLevel = 1 end
            joystickCooldown = 0.2 * 30
            play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
        end
    end

    if m.controller.buttonPressed & A_BUTTON ~= 0 and gPlayerSyncTable[0].votingNumber == 0 and math.floor(gGlobalSyncTable.displayTimer / 30) > 5 and math.floor(gGlobalSyncTable.displayTimer / 30) <= 15 then
        gPlayerSyncTable[0].votingNumber = selectedLevel
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)