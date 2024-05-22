
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
    djui_hud_set_color(255, 255, 255, fade)
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
        local x = (screenWidth - (256 * 4 + 100 * 3)) / 2 + (256 + 100) * (i - 1) -- don't ask
        local y = (screenHeight - 400) / 2

        -- render question mark if there's no painting assigned
        djui_hud_set_color(35, 35, 37, fade)
        djui_hud_render_rect(x, y, 256, 256)

        djui_hud_set_color(220, 220, 220, fade) -- #dcdcdc
        djui_hud_print_text("?", x + ((128 - djui_hud_measure_text("?"))) - 16, y + 32, 5) -- don't ask #2

        djui_hud_set_color(255, 255, 255, fade)
        if i ~= 4 and levels[voteRandomLevels[i]].painting ~= nil then
            local dimensions = levels[voteRandomLevels[i]].painting.width
            djui_hud_render_texture(levels[voteRandomLevels[i]].painting, x, y, 256 / dimensions, 256 / dimensions)
        elseif i == 4 then
            djui_hud_render_texture(TEXTURE_RANDOM_PAINTING, x, y, 1, 1)
        end

        y = (screenHeight + 200) / 2

        local outlineColor = { r = 50, g = 50, b = 50 }

        if gPlayerSyncTable[0].votingNumber == i then
            djui_hud_set_color(83, 153, 77, fade)
            outlineColor.r = 113
            outlineColor.g = 183
            outlineColor.b = 107
        elseif selectedLevel == i then
            djui_hud_set_color(40, 40, 40, fade)
            outlineColor.r = 60
            outlineColor.g = 60
            outlineColor.b = 60
        else
            djui_hud_set_color(32, 32, 32, fade)
        end
        x = (screenWidth - (256 * 4 + 100 * 3)) / 2 + (256 + 100) * (i - 1) - 18.125 -- help me
        djui_hud_render_rect_rounded_outlined(x, y, 290, 50, outlineColor.r, outlineColor.g, outlineColor.b, 3, fade)
        djui_hud_set_color(255, 255, 255, fade)
        if i ~= 4 then
            text = tostring(name_of_level(levels[voteRandomLevels[i]].level, levels[voteRandomLevels[i]].area, levels[voteRandomLevels[i]])) .. ": " .. tostring(votes)
        else
            text = "Random: " .. tostring(votes)
        end
        djui_hud_print_text(text, x + 145 - (djui_hud_measure_text(text) / 2), y + 50 / 8, 1) -- why 50 / 8? idk it works (I hate hud math)
    end

    -- render bottom text
    if math.floor(gGlobalSyncTable.displayTimer / 30) > 7 then
        text = "You may begin voting in " .. math.floor(gGlobalSyncTable.displayTimer / 30) - 7
    elseif math.floor(gGlobalSyncTable.displayTimer / 30) > 2 then
        text = "You have " .. tostring(math.floor(gGlobalSyncTable.displayTimer / 30) - 2) .. " seconds remaining"
    else
        if currentMapWinner == 4 then
            text = "A Random Level has been selected!"
        else
            local level = levels[voteRandomLevels[currentMapWinner]].level
            local area = levels[voteRandomLevels[currentMapWinner]].area
            text = name_of_level(level, area, levels[voteRandomLevels[currentMapWinner]]) .. " has been selected!"
        end
    end
    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, (screenWidth - djui_hud_measure_text(text)) / 2, screenHeight - 50, 1)
end

local function hud_gamemode()
    local text = "Gamemode is set to " .. get_gamemode_including_random(gGlobalSyncTable.gamemode)

    local x = 40
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_colored_text(text, x, y, 1, fade)
end

local function hud_modifier()
    local text = "Modifier is set to " .. get_modifier_including_random()

    local width = djui_hud_measure_text(strip_hex(text))

    local x = screenWidth - width - 40
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_colored_text(text, x, y, 1, fade)
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
                randomLevel = math.random(1, #levels)
                while table.contains(voteRandomLevels, randomLevel) or gGlobalSyncTable.blacklistedCourses[randomLevel] == true or randomLevel == gGlobalSyncTable.selectedLevel do
                    randomLevel = math.random(1, #levels)
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

    screenWidth = djui_hud_get_screen_width()
    screenHeight = djui_hud_get_screen_height()

    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)
    hud_black_bg()
    hud_map_vote()
    hud_modifier()
    hud_gamemode()
end

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 or gGlobalSyncTable.roundState ~= ROUND_VOTING then return end

    joystickCooldown = joystickCooldown - 1

    -- if our stick is at 0, then set joystickCooldown to 0
    if m.controller.stickX == 0 then joystickCooldown = 0 end

    if showSettings then return end
    if isPaused then return end

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

    if m.controller.buttonPressed & A_BUTTON ~= 0
    and math.floor(gGlobalSyncTable.displayTimer / 30) > 2
    and math.floor(gGlobalSyncTable.displayTimer / 30) <= 7 then
        gPlayerSyncTable[0].votingNumber = selectedLevel
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)