-- name: Tag
-- description: Just like the childhood game you played when you were a kid!\n\nIf your metal, your a tagger, and you must chase the runners and tag them!\n\nIf your a tagger and the round ends, you lose!\n\nYou can also become eliminated if you die as a runner! If your eliminated, then you lose!\n\n Have fun playing!!
-- incompatible: gamemode tag

-- constants
ROUND_WAIT_PLAYERS = 0
ROUND_ACTIVE = 1
ROUND_WAIT = 2

ROUND_TAGGERS_WIN = 3
ROUND_RUNNERS_WIN = 4

RUNNER = 0
TAGGER = 1
ELIMINATED = 2

-- globals and sync tables
gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS
gGlobalSyncTable.selectedLevel = 1
gGlobalSyncTable.amountOfTime = 120 * 30
gGlobalSyncTable.displayTimer = 0
gGlobalSyncTable.doCaps = false
gGlobalSyncTable.bljs = false
gGlobalSyncTable.cannons = false
gGlobalSyncTable.antiCamp = true
gGlobalSyncTable.antiCampTimer = 10 * 30
for i = 0, MAX_PLAYERS - 1 do -- set all states for every player on init
    gPlayerSyncTable[i].state = RUNNER
end

-- server settings
gServerSettings.playerInteractions = PLAYER_INTERACTIONS_SOLID -- force player attacks to be on
gServerSettings.bubbleDeath = 0

-- variables
timer = 0 -- dont make this local so it can be used in other files
isRomhack = false -- dont make this local so it can be used in other files
blacklistedLevels = {} -- dont make this local so it can be used in other files
local badLevels = {}
local winnerIndexes = {}
local defaultLevels = {}
local prevLevel = -1 -- -1 since -1 is not a level index
local eliminatedTimer = 0
local flashingIndex = 0

-- tables
local levels = {
{level = LEVEL_CASTLE_GROUNDS, act = 0, area = 1, pipes = true, pipe1Pos = {x = -5979, y = 378, z = -1371}, pipe2Pos = {x = 1043, y = 3174, z = -5546}},
{level = LEVEL_BOB, act = 6, area = 1, pipes = true, pipe1Pos = {x = -4694, y = 0, z = 6699}, pipe2Pos = {x = 5079, y = 3072, z = 655}},
{level = LEVEL_WF, act = 6, area = 1, pipes = false},
{level = LEVEL_CCM, act = 6, area = 1, pipes = false},
{level = LEVEL_LLL, act = 6, area = 1, pipes = false},
{level = LEVEL_SSL, act = 1, area = 1, pipes = false},
{level = LEVEL_BITFS, act = 6, area = 1, pipes = true, pipe1Pos = {x = -154, y = -2866, z = -102}, pipe2Pos = {x = 1205, y = 5478, z = 58}},
{level = LEVEL_TTM, act = 6, area = 1, pipes = true, pipe1Pos = {x = -1080, y = -4634, z = 4176}, pipe2Pos = {x = 1031, y = 2306, z = -198}},
{level = LEVEL_THI, act = 6, area = 1, pipes = false},
{level = LEVEL_SL, act = 6, area = 1, pipes = false},
{level = LEVEL_TTC, act = 6, area = 1, pipes = true, pipe1Pos = {x = 1361, y = -4822, z = 176}, pipe2Pos = {x = 1594, y = 5284, z = 1565}},
{level = LEVEL_JRB, act = 1, area = 1, pipes = true, pipe1Pos = {x = 3000, y = -5119, z = 2688}, pipe2Pos = {x = -6398, y = 1126, z = 191}},
}

local badFloorTypes = {
    SURFACE_BURNING,
    SURFACE_QUICKSAND,
    SURFACE_DEEP_QUICKSAND,
    SURFACE_MOVING_QUICKSAND,
    SURFACE_INSTANT_QUICKSAND,
    SURFACE_SHALLOW_QUICKSAND,
    SURFACE_DEEP_MOVING_QUICKSAND,
    SURFACE_INSTANT_MOVING_QUICKSAND,
    SURFACE_SHALLOW_MOVING_QUICKSAND
}

function server_update()

    local numPlayers = network_player_connected_count() -- get current amount of players

    if numPlayers <= 1 then
        gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS -- set round state to waiting for players
    elseif gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS then
        timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16
        math.randomseed(random_f32_around_zero(10000), random_f32_around_zero(10000)) -- set a random seed based off of the random generator provided in super mario 64, since lua's is not very good
        while ((table.contains(defaultLevels, string.upper(get_level_name(level_to_course(gGlobalSyncTable.selectedLevel), gGlobalSyncTable.selectedLevel, 1))) or table.contains(blacklistedLevels, level_to_course(gGlobalSyncTable.selectedLevel)) or table.contains(badLevels, gGlobalSyncTable.selectedLevel) or level_to_course(gGlobalSyncTable.selectedLevel) > COURSE_RR or level_to_course(gGlobalSyncTable.selectedLevel) < COURSE_MIN) and isRomhack) or prevLevel == gGlobalSyncTable.selectedLevel or gGlobalSyncTable.selectedLevel < 0 do
            if isRomhack then
                gGlobalSyncTable.selectedLevel = course_to_level(math.random(COURSE_MIN, COURSE_RR))
            else
                gGlobalSyncTable.selectedLevel = math.random(1, #levels) -- select a random level
            end
        end

        prevLevel = gGlobalSyncTable.selectedLevel
        gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state
    end

    if gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS then
        for i = 0, MAX_PLAYERS - 1 do
            gPlayerSyncTable[i].state = RUNNER -- set everyone's state to runner
        end
    elseif gGlobalSyncTable.roundState == ROUND_WAIT then
        timer = timer - 1 -- subtract timer by one
        gGlobalSyncTable.displayTimer = timer -- set display timer to timer

        for i = 0, MAX_PLAYERS - 1 do
            gPlayerSyncTable[i].state = RUNNER -- set everyone's state to runner
        end

        if timer <= 0 then
            timer = gGlobalSyncTable.amountOfTime -- set timer to amount of time in a round
            local amountOfTaggersNeeded = math.floor(network_player_connected_count() / 2) -- always have half the players, rounding down, be taggers
            local amountOfTaggers = 0

            while amountOfTaggers < amountOfTaggersNeeded do
                -- select taggers
                local randomIndex = math.random(0, MAX_PLAYERS - 1) -- select random index

                if gPlayerSyncTable[randomIndex].state ~= TAGGER and gNetworkPlayers[randomIndex].connected then
                    gPlayerSyncTable[randomIndex].state = TAGGER

                    amountOfTaggers = amountOfTaggers + 1
                end
            end

            gGlobalSyncTable.roundState = ROUND_ACTIVE -- begin round
        end
    elseif gGlobalSyncTable.roundState == ROUND_ACTIVE then

        check_runner_and_tagger_status() -- check current runner and tagger status

        timer = timer - 1 -- subtract timer by one
        gGlobalSyncTable.displayTimer = timer -- set display timer to timer

        if timer <= 0 then
            timer = 5 * 30 -- 5 seconds

            gGlobalSyncTable.roundState = ROUND_RUNNERS_WIN -- end round

            return
        end
    elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN or gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
        timer = timer - 1

        if timer <= 0 then
            gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS
        end
    end
end

function update()
    if network_is_server() then
        server_update()
    end

    -- set network descriptions
    for i = 0, MAX_PLAYERS - 1 do
        if gPlayerSyncTable[i].state == TAGGER then
            network_player_set_description(gNetworkPlayers[i], "Tagger", 232, 46, 46, 255)
        elseif gPlayerSyncTable[i].state == RUNNER then
            network_player_set_description(gNetworkPlayers[i], "Runner", 49, 107, 232, 255)
        elseif gPlayerSyncTable[i].state == ELIMINATED then
            network_player_set_description(gNetworkPlayers[i], "Eliminated", 191, 54, 54, 255)
        end
    end

    -- set eliminated timer
    if eliminatedTimer > 0 then
        eliminatedTimer = eliminatedTimer - 1
    end
end

---@param m MarioState
function mario_update(m)

    if not isRomhack then
        set_environment_region(1, -10000)
        set_environment_region(2, -10000)
        set_environment_region(3, -10000)
        set_environment_region(4, -10000)
        set_environment_region(5, -10000)
        set_environment_region(6, -10000)
    end

    if not gGlobalSyncTable.bljs and m.forwardVel <= -55 then
        m.forwardVel = -55
    end

    m.peakHeight = m.pos.y
    m.health = 0x880 -- set mario's health to full

    -- set model state according to state
    if gPlayerSyncTable[m.playerIndex].state == TAGGER then
        m.marioBodyState.modelState = MODEL_STATE_METAL
    elseif gPlayerSyncTable[m.playerIndex].state == ELIMINATED then
        m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
    end

    --  set floor surface if mario's floor is bad
    if m.floor ~= nil then
        if table.contains(badFloorTypes, m.floor.type) then
            m.floor.type = SURFACE_DEFAULT
        end
    end

    if m.playerIndex == 0 then
        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        local selectedLevel = levels[gGlobalSyncTable.selectedLevel] -- get currently selected level

        -- check if mario is in the proper level, act, and area, if not, rewarp mario
        if gGlobalSyncTable.roundState == ROUND_ACTIVE or gGlobalSyncTable.roundState == ROUND_WAIT then
            if not isRomhack then
                if np.currLevelNum ~= selectedLevel.level or np.currActNum ~= selectedLevel.act or np.currAreaIndex ~= selectedLevel.area then
                    warp_to_level(selectedLevel.level, selectedLevel.area, selectedLevel.act)
                end
            else
                if np.currLevelNum ~= gGlobalSyncTable.selectedLevel or np.currActNum ~= 6 or np.currAreaIndex ~= 1 then

                    local warpSuccesful = warp_to_level(gGlobalSyncTable.selectedLevel, 1, 6)

                    if not warpSuccesful and network_is_server() then

                        -- try a common one
                        if warp_to_warpnode(gGlobalSyncTable.selectedLevel, 1, 6, 10) then
                            return
                        end

                        -- try randomly
                        for i = 1, 100 do
                            if warp_to_warpnode(gGlobalSyncTable.selectedLevel, 1, 6, i) then
                                return
                            end
                        end

                        table.insert(badLevels, gGlobalSyncTable.selectedLevel)

                        while ((table.contains(defaultLevels, string.upper(get_level_name(level_to_course(gGlobalSyncTable.selectedLevel), gGlobalSyncTable.selectedLevel, 1))) or table.contains(blacklistedLevels, level_to_course(gGlobalSyncTable.selectedLevel)) or table.contains(badLevels, gGlobalSyncTable.selectedLevel) or level_to_course(gGlobalSyncTable.selectedLevel) > COURSE_RR or level_to_course(gGlobalSyncTable.selectedLevel) < COURSE_MIN) and isRomhack) or prevLevel == gGlobalSyncTable.selectedLevel or gGlobalSyncTable.selectedLevel < 0 do
                            gGlobalSyncTable.selectedLevel = course_to_level(math.random(COURSE_MIN, COURSE_MAX)) -- select a random level
                        end

                        prevLevel = gGlobalSyncTable.selectedLevel
                    elseif not warpSuccesful then
                        -- try a common one
                        if warp_to_warpnode(gGlobalSyncTable.selectedLevel, 1, 6, 10) then
                            return
                        end

                        -- try randomly
                        for i = 1, 100 do
                            if warp_to_warpnode(gGlobalSyncTable.selectedLevel, 1, 6, i) then
                                return
                            end
                        end
                    end
                end
            end
        end

        -- spawn pipes
        if not isRomhack then
            if selectedLevel.pipes == true and find_object_with_behavior(get_behavior_from_id(id_bhvWarpPipe)) == nil then
                spawn_sync_object(id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, selectedLevel.pipe1Pos.x, selectedLevel.pipe1Pos.y, selectedLevel.pipe1Pos.z, function (o)
                    o.oBehParams = 1
                end)

                spawn_sync_object(id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, selectedLevel.pipe2Pos.x, selectedLevel.pipe2Pos.y, selectedLevel.pipe2Pos.z, function (o)
                    o.oBehParams = 2
                end)
            end
        end

        -- delete unwanted pipes
        if gNetworkPlayers[0].currLevelNum == LEVEL_THI and find_object_with_behavior(get_behavior_from_id(id_bhvWarpPipe)) ~= nil then
            obj_mark_for_deletion(find_object_with_behavior(get_behavior_from_id(id_bhvWarpPipe)))
        end

        if find_object_with_behavior(get_behavior_from_id(id_bhv1Up)) ~= nil then
            obj_mark_for_deletion(find_object_with_behavior(get_behavior_from_id(id_bhv1Up)))
        end

        if find_object_with_behavior(get_behavior_from_id(id_bhvBubba)) ~= nil then
            obj_mark_for_deletion(find_object_with_behavior(get_behavior_from_id(id_bhvBubba)))
        end

        if find_object_with_behavior(get_behavior_from_id(id_bhvOneCoin)) ~= nil then
            obj_mark_for_deletion(find_object_with_behavior(get_behavior_from_id(id_bhvOneCoin)))
        end

        if find_object_with_behavior(get_behavior_from_id(id_bhvRedCoin)) ~= nil then
            obj_mark_for_deletion(find_object_with_behavior(get_behavior_from_id(id_bhvRedCoin)))
        end

        if find_object_with_behavior(get_behavior_from_id(id_bhvRedCoinStarMarker)) ~= nil then
            obj_mark_for_deletion(find_object_with_behavior(get_behavior_from_id(id_bhvRedCoin)))
        end

        if not isRomhack then
            if find_object_with_behavior(get_behavior_from_id(id_bhvActivatedBackAndForthPlatform)) ~= nil then
                obj_mark_for_deletion(find_object_with_behavior(get_behavior_from_id(id_bhvActivatedBackAndForthPlatform)))
            end

            if find_object_with_behavior(get_behavior_from_id(id_bhvExclamationBox)) ~= nil then
                obj_mark_for_deletion(find_object_with_behavior(get_behavior_from_id(id_bhvExclamationBox)))
            end
        end
    end

    camping_detection(m)
end

function hud_top_render()

    local text = ''

    -- set text
    if gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS then
        text = 'Waiting for Players'
    elseif gGlobalSyncTable.roundState == ROUND_ACTIVE then
        text = 'Time Remaining: ' .. math.floor(gGlobalSyncTable.displayTimer / 30) -- divide by 30 for seconds and not frames
    elseif gGlobalSyncTable.roundState == ROUND_WAIT then
        text = 'Starting in ' .. math.floor(gGlobalSyncTable.displayTimer / 30) -- divide by 30 for seconds and not frames
    elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
        text = 'Runners Win'
    elseif gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
        text = 'Taggers Win'
    else
        return
    end

    local scale = 0.50

    -- get width of screen and text
    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text) * scale

    local x = (screenWidth - width) / 2.0
    local y = 0

    local background = 0.0

    -- render rect
    djui_hud_set_color(255 * background, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 16);

    -- render text
    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
end

function hud_bottom_render()

    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end
    if gPlayerSyncTable[0].state ~= ELIMINATED then
        if gGlobalSyncTable.antiCamp and sDistanceTimer > 1 then
            -- taken from djoslin0's hide and seek
            local seconds = math.floor((gGlobalSyncTable.antiCampTimer - sDistanceTimer) / 30)
            if seconds < 0 then seconds = 0 end

            local text = 'Keep moving! (' .. seconds .. ')'
            local scale = 0.50

            -- get width of screen and text
            local screenWidth = djui_hud_get_screen_width()
            local screenHeight = djui_hud_get_screen_height()
            local width = djui_hud_measure_text(text) * scale

            local x = (screenWidth - width) / 2.0
            local y = screenHeight - 16

            local background = (math.sin(flashingIndex / 10.0) * 0.5 + 0.5)
            background = background * background
            background = background * background

            -- render top
            djui_hud_set_color(255 * background, 0, 0, 128);
            djui_hud_render_rect(x - 6, y, width + 12, 16);

            djui_hud_set_color(255, 125, 125, 255);
            djui_hud_print_text(text, x, y, scale);
        end

        return
    end
    if eliminatedTimer <= 0 then return end

    local text = "You are Eliminated. use the tp command to teleport to anyone"

    local scale = 0.50

    -- get width of screen and text
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()
    local width = djui_hud_measure_text(text) * scale

    local x = (screenWidth - width) / 2.0
    local y = screenHeight - 16

    local background = 0.0
    background = background

    -- render top
    djui_hud_set_color(255 * background, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 16);

    djui_hud_set_color(255, 54, 54, 255);
    djui_hud_print_text(text, x, y, scale);
end

function hud_render()
    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    -- render top hud
    hud_top_render()
    hud_bottom_render()

    -- render radar
    for i = 1, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
            if gPlayerSyncTable[i].state == RUNNER and gPlayerSyncTable[0].state == TAGGER then
                render_radar(gMarioStates[i], icon_radar[i], false)
            end
        end
    end

    flashingIndex = flashingIndex + 1
end

---@param m MarioState
function on_death(m)
    if gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- become eliminated on death
        if m.playerIndex == 0 then
            if gPlayerSyncTable[0].state == RUNNER then
                gPlayerSyncTable[0].state = ELIMINATED

                eliminatedTimer = 8 * 30 -- 8 seconds
            end
        end
    end
end

---@param a MarioState
---@param v MarioState
function allow_pvp(a, v)
    -- check if eliminated player is trying to perform a pvp attack
    if gPlayerSyncTable[v.playerIndex].state == ELIMINATED or gPlayerSyncTable[a.playerIndex].state == ELIMINATED then return false end
    -- check if 2 runners are trying to attack eachother
    if gPlayerSyncTable[v.playerIndex].state == RUNNER and gPlayerSyncTable[a.playerIndex].state == RUNNER then return false end
    -- check if 2 taggers are trying to attack eachother
    if gPlayerSyncTable[v.playerIndex].state == TAGGER and gPlayerSyncTable[a.playerIndex].state == TAGGER then return false end

    return true
end

---@param m MarioState
---@param o Object
---@param intee InteractionType
function allow_interact(m, o, intee)
    -- check if player interacts with another player
    if intee == INTERACT_PLAYER then
        for i = 0, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- find the other player and check his state
                if gMarioStates[i].marioObj == o and (gPlayerSyncTable[m.playerIndex].state == ELIMINATED or gPlayerSyncTable[i].state == ELIMINATED) then
                    return false
                end
            end
        end
    end

    -- check if intee is unwanted
    if intee == INTERACT_STAR_OR_KEY or intee == INTERACT_KOOPA_SHELL or intee == INTERACT_WARP_DOOR then
        return false
    end

    if intee == INTERACT_CANNON_BASE and not gGlobalSyncTable.cannons then
        return false
    end

    if intee == INTERACT_WARP and o.behavior == get_behavior_from_id(id_bhvWarpPipe) and not isRomhack then
        local o2 = obj_get_first_with_behavior_id(id_bhvWarpPipe)
        while o2 ~= nil do
            if o2 == o then
                o2 = obj_get_next_with_same_behavior_id(o2)
            else
                m.pos.x = o2.oPosX
                m.pos.y = o2.oPosY + 200
                m.pos.z = o2.oPosZ

                set_mario_action(m, ACT_JUMP, 0)

                m.vel.y = 60
                m.forwardVel = 15
                if m.invincTimer <= 0 then -- this prevents runners at pipes
                    m.invincTimer = 2 * 30 -- 2 seconds. This prevents taggers from camping at pipes
                end

                reset_camera(m.area.camera)

                play_sound(SOUND_MENU_EXIT_PIPE, m.pos)

                break
            end
        end

        return false
    elseif intee == INTERACT_WARP and isRomhack then
        return false
    elseif intee == INTERACT_WARP and levels[gGlobalSyncTable.selectedLevel].level ~= LEVEL_CCM then
        return false
    end

    if not gGlobalSyncTable.doCaps then
        if intee == INTERACT_CAP then
            return false
        end
    end
end

function on_connect(m)
    if gGlobalSyncTable.roundState == ROUND_ACTIVE then
        gPlayerSyncTable[m.playerIndex].state = ELIMINATED
    end
end

function on_pvp(a, v)
    -- check if tagger tagged runner
    if gPlayerSyncTable[v.playerIndex].state == RUNNER and gPlayerSyncTable[a.playerIndex].state == TAGGER then
        gPlayerSyncTable[v.playerIndex].state = TAGGER
        gPlayerSyncTable[a.playerIndex].state = RUNNER
    end
end

function check_if_romhack_enabled()
    -- set default levels
    table.insert(defaultLevels, "BOB-OMB BATTLEFIELD")
    table.insert(defaultLevels, "WHOMP'S FORTRESS")
    table.insert(defaultLevels, "JOLLY ROGER BAY")
    table.insert(defaultLevels, "COOL, COOL MOUNTAIN")
    table.insert(defaultLevels, "BIG BOO'S HAUNT")
    table.insert(defaultLevels, "HAZY MAZE CAVE")
    table.insert(defaultLevels, "LETHAL LAVA LAND")
    table.insert(defaultLevels, "SHIFTING SAND LAND")
    table.insert(defaultLevels, "DIRE, DIRE DOCKS")
    table.insert(defaultLevels, "SNOWMAN'S LAND")
    table.insert(defaultLevels, "WET-DRY WORLD")
    table.insert(defaultLevels, "TALL, TALL MOUNTAIN")
    table.insert(defaultLevels, "TINY-HUGE ISLAND")
    table.insert(defaultLevels, "TICK TOCK CLOCK")
    table.insert(defaultLevels, "RAINBOW RIDE")
    table.insert(defaultLevels, "BOWSER IN THE DARK WORLD")
    table.insert(defaultLevels, "BOWSER IN THE FIRE SEA")
    table.insert(defaultLevels, "BOWSER IN THE SKY")
    table.insert(defaultLevels, "THE PRINCESS'S SECRET SLIDE")
    table.insert(defaultLevels, "CAVERN OF THE METAL CAP")
    table.insert(defaultLevels, "TOWER OF THE WING CAP")
    table.insert(defaultLevels, "VANISH CAP UNDER THE MOAT")
    table.insert(defaultLevels, "WING MARIO OVER THE RAINBOW")
    table.insert(defaultLevels, "THE SECRET AQUARIUM")
    table.insert(defaultLevels, "PEACH'S CASTLE")

    for i=0,50 do
        if gActiveMods[i] ~= nil then
            if gActiveMods[i].incompatible ~= nil then
                if string.match(gActiveMods[i].incompatible, 'romhack') then
                    isRomhack = true

                    return
                end
            end
        end
    end
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_ON_PLAYER_CONNECTED, on_connect)
hook_event(HOOK_ON_PAUSE_EXIT, function() return false end)
hook_event(HOOK_USE_ACT_SELECT, function() return false end)

hook_on_sync_table_change(gGlobalSyncTable, 'roundState', 0, function (tag, oldVal, newVal)
    if oldVal ~= newVal then
        if gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
            for i = 0, MAX_PLAYERS - 1 do
                if gNetworkPlayers[i].connected then
                    if gPlayerSyncTable[i].state == TAGGER then
                        table.insert(winnerIndexes, i)
                    end
                end
            end

            djui_chat_message_create("\\#E82E2E\\Taggers \\#FFD700\\Win! Winners:")

            for _, index in pairs(winnerIndexes) do
                local displayName = network_get_player_text_color_string(index) .. gNetworkPlayers[index].name

                if displayName ~= "" then
                    djui_chat_message_create(displayName)
                end
            end

            winnerIndexes = {}
            gPlayerSyncTable[0].state = RUNNER
        elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN then
            for i = 0, MAX_PLAYERS - 1 do
                if gNetworkPlayers[i].connected then
                    if gPlayerSyncTable[i].state == RUNNER then
                        table.insert(winnerIndexes, i)
                    end
                end
            end

            djui_chat_message_create("\\#316BE8\\Runners \\#FFD700\\Win! Winners:")

            for _, index in pairs(winnerIndexes) do
                local displayName = network_get_player_text_color_string(index) .. gNetworkPlayers[index].name

                if displayName ~= "" then
                    djui_chat_message_create(displayName)
                end
            end

            winnerIndexes = {}
            gPlayerSyncTable[0].state = RUNNER
        end
    end
end)

check_if_romhack_enabled()