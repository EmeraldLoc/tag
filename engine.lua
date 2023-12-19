-- constants
ROUND_WAIT_PLAYERS = 0
ROUND_ACTIVE = 1
ROUND_WAIT = 2
ROUND_TAGGERS_WIN = 3
ROUND_RUNNERS_WIN = 4
ROUND_HOT_POTATO_INTERMISSION = 5

RUNNER = 0
TAGGER = 1
ELIMINATED_OR_FROZEN = 2
SPECTATOR = 3

MIN_GAMEMODE = 1
TAG = 1
FREEZE_TAG = 2
INFECTION = 3
HOT_POTATO = 4
JUGGERNAUT = 5
ASSASINS = 6
MAX_GAMEMODE = 6

PLAYERS_NEEDED = 2

MODIFIER_MIN = 0
MODIFIER_NONE = 0
MODIFIER_BOMBS = 1
MODIFIER_LOW_GRAVITY = 2
MODIFIER_SWAP = 3
MODIFIER_NO_RADAR = 4
MODIFIER_NO_BOOST = 5
MODIFIER_ONE_TAGGER = 6
MODIFIER_FLY = 7
MODIFIER_SPEED = 8
MODIFIER_INCOGNITO = 9
MODIFIER_MAX = 9

-- globals and sync tables
gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS
gGlobalSyncTable.modifier = MODIFIER_NONE
gGlobalSyncTable.randomModifiers = true
gGlobalSyncTable.randomGamemode = true
gGlobalSyncTable.gamemode = TAG
gGlobalSyncTable.bljs = false
gGlobalSyncTable.cannons = false
gGlobalSyncTable.water = false
gGlobalSyncTable.swapTimer = 1
gGlobalSyncTable.displayTimer = 1
gGlobalSyncTable.selectedLevel = 1
gGlobalSyncTable.juggernautTagsReq = 15
gGlobalSyncTable.amountOfTime = 120 * 30
gGlobalSyncTable.ttcSpeed = 0
for i = 0, MAX_PLAYERS - 1 do -- set all states for every player on init
    if network_is_server() then
        gPlayerSyncTable[i].state = RUNNER
        gPlayerSyncTable[i].invincTimer = 0
        gPlayerSyncTable[i].amountOfTags = 0
        gPlayerSyncTable[i].amountOfTimeAsRunner = 0
        gPlayerSyncTable[i].juggernautTags = 0
        gPlayerSyncTable[i].assasinTarget = -1
        gPlayerSyncTable[i].assasinStunTimer = -1
    end
end

-- server settings
gServerSettings.playerInteractions = PLAYER_INTERACTIONS_SOLID -- force player attacks to be on
gServerSettings.bubbleDeath = 0

-- variables
timer = 0 -- dont make this local so it can be used in other files
flashingIndex = 0 -- dont make this local so it can be used in other files
isRomhack = false -- dont make this local so it can be used in other files
blacklistedCourses = {} -- dont make this local so it can be used in other files
winnerIndexes = {} -- dont make this local so it can be used in other files
defaultLevels = {} -- dont make this local so it can be used in other files
joinTimer = 6 * 30 -- dont make this local so it can be used in other files
prevLevel = 1 -- make it the same as the selected level so it selects a new level
badLevels = {} -- dont make this local so it can be used in other files
gGlobalSoundSource = {x = 0, y = 0, z = 0} -- dont make this local so it can be used in other files
local speedBoostTimer = 0
local hotPotatoTimerMultiplier = 1

_G.tagExists = true
_G.tagSettingsOpen = false

ACT_NOTHING = allocate_mario_action(ACT_FLAG_IDLE)

-- tables
levels = {
    {name = "cg",    level = LEVEL_CASTLE_GROUNDS, act = 0, area = 1, pipes = true, pipe1Pos = {x = -5979, y = 378, z = -1371},  pipe2Pos = {x = 1043, y = 3174, z = -5546}},
    {name = "bob",   level = LEVEL_BOB,            act = 0, area = 1, pipes = true, pipe1Pos = {x = -4694, y = 0, z = 6699},     pipe2Pos = {x = 5079, y = 3072, z = 655}},
    {name = "rr",    level = LEVEL_RR,             act = 0, area = 1, pipes = true, pipe1Pos = {x = -4221, y = 6451, z = -5885}, pipe2Pos = {x = 2125, y = -1833, z = 2079}},
    {name = "ccm",   level = LEVEL_CCM,            act = 0, area = 1, pipes = true, pipe1Pos = {x = -1352, y = 2560, z = -1824}, pipe2Pos = {x = 5628, y = -4607, z = -28}},
    {name = "issl",  level = LEVEL_SSL,            act = 0, area = 2, pipes = true, pipe1Pos = {x = -460, y = 0, z = 4247},      pipe2Pos = {x = 997, y = 3942, z = 1234}},
    {name = "bitfs", level = LEVEL_BITFS,          act = 0, area = 1, pipes = true, pipe1Pos = {x = -154, y = -2866, z = -102},  pipe2Pos = {x = 1205, y = 5478, z = 58}},
    {name = "ttm",   level = LEVEL_TTM,            act = 0, area = 1, pipes = true, pipe1Pos = {x = -1080, y = -4634, z = 4176}, pipe2Pos = {x = 1031, y = 2306, z = -198}},
    {name = "ttc",   level = LEVEL_TTC,            act = 0, area = 1, pipes = true, pipe1Pos = {x = 1361, y = -4822, z = 176},   pipe2Pos = {x = 1594, y = 5284, z = 1565}},
    {name = "jrb",   level = LEVEL_JRB,            act = 0, area = 1, pipes = true, pipe1Pos = {x = 3000, y = -5119, z = 2688},  pipe2Pos = {x = -6398, y = 1126, z = 191}},
    {name = "wf",    level = LEVEL_WF,             act = 0, area = 1, pipes = false},
    {name = "lll",   level = LEVEL_LLL,            act = 0, area = 1, pipes = false},
    {name = "ssl",   level = LEVEL_SSL,            act = 0, area = 1, pipes = false},
    {name = "thi",   level = LEVEL_THI,            act = 0, area = 1, pipes = false},
    {name = "sl",    level = LEVEL_SL,             act = 0, area = 1, pipes = false},
    {name = "arena", level = LEVEL_BOWSER_1,       act = 0, area = 1, pipes = false},
}

local function server_update()
    for i = 0, MAX_PLAYERS - 1 do
        if not gNetworkPlayers[i].connected then
            gPlayerSyncTable[i].state = -1
            gPlayerSyncTable[i].amountOfTimeAsRunner = 0
            gPlayerSyncTable[i].amountOfTags = 0
            gPlayerSyncTable[i].juggernautTags = 0
        end
    end

    local numPlayers = 0

    for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected and gPlayerSyncTable[i].state ~= SPECTATOR then
            numPlayers = numPlayers + 1
        end
    end

    if numPlayers < PLAYERS_NEEDED then
        gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS -- set round state to waiting for players

        if gGlobalSyncTable.randomGamemode and PLAYERS_NEEDED > 2 then
            -- set gamemode to tag so the game keeps going
            gGlobalSyncTable.gamemode = TAG

            -- default tag timer
            if gGlobalSyncTable.amountOfTime == (180 * 30) then
                gGlobalSyncTable.amountOfTime = 120 * 30
            end

            PLAYERS_NEEDED = 2

            log_to_console("Tag: Attempted to keep tag going by setting the gamemode to tag")
        end
    elseif gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS then
        timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16
        ---@diagnostic disable-next-line: param-type-mismatch
        while ((level_is_vanilla_level(gGlobalSyncTable.selectedLevel) or table.contains(blacklistedCourses, level_to_course(gGlobalSyncTable.selectedLevel)) or table.contains(badLevels, gGlobalSyncTable.selectedLevel) or level_to_course(gGlobalSyncTable.selectedLevel) > COURSE_RR or level_to_course(gGlobalSyncTable.selectedLevel) < COURSE_MIN) and isRomhack) or prevLevel == gGlobalSyncTable.selectedLevel or gGlobalSyncTable.selectedLevel <= 0 do
            if isRomhack then
                gGlobalSyncTable.selectedLevel = course_to_level(math.random(COURSE_MIN, COURSE_RR))
            else
                gGlobalSyncTable.selectedLevel = math.random(1, #levels) -- select a random level

                if levels[gGlobalSyncTable.selectedLevel].level == LEVEL_TTC then
                    gGlobalSyncTable.ttcSpeed = math.random(0, 3)
                end
            end
        end

        prevLevel = gGlobalSyncTable.selectedLevel
        gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state
        log_to_console("Tag: Round State is now ROUND_WAIT")
    end

    if gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS then
        for i = 0, MAX_PLAYERS - 1 do
            if gPlayerSyncTable[i].state ~= SPECTATOR then
                gPlayerSyncTable[i].state = RUNNER -- set everyone's state to runner
            end
        end
    elseif gGlobalSyncTable.roundState == ROUND_WAIT then
        -- select a modifier and gamemode if timer is at its highest point
        if timer == 16 * 30 then
            if gGlobalSyncTable.randomModifiers then
                -- see if we should use a modifier modifiers or not
                local selectModifier = math.random(1, 2) -- 50% chance

                if selectModifier == 2 then
                    ::selectmodifier::
                    -- select a random modifier
                    gGlobalSyncTable.modifier = math.random(MODIFIER_MIN + 1 , MODIFIER_MAX) -- select random modifier, exclude MODIFIER_NONE

                    if gGlobalSyncTable.gamemode == JUGGERNAUT and gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER then
                        goto selectmodifier
                    end

                    if gGlobalSyncTable.gamemode == ASSASINS and (gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER or gGlobalSyncTable.modifier == MODIFIER_FLY or gGlobalSyncTable.modifier == MODIFIER_INCOGNITO) then
                        goto selectmodifier
                    end
                else
                    gGlobalSyncTable.modifier = MODIFIER_NONE -- set the modifier to none
                end
            end

            -- if we select a random gamemode, select that random gamemode now
            if gGlobalSyncTable.randomGamemode then
                if numPlayers >= 3 then -- 3 is the minimum player count for random gamemodes
                    gGlobalSyncTable.gamemode = -1 -- force popup to show
                    gGlobalSyncTable.gamemode = math.random(MIN_GAMEMODE, MAX_GAMEMODE)
                else
                    gGlobalSyncTable.gamemode = TAG -- set to tag explicitly
                end

                if gGlobalSyncTable.gamemode == FREEZE_TAG then
                    -- set freeze tag timer
                    gGlobalSyncTable.amountOfTime = 180 * 30

                    PLAYERS_NEEDED = 3
                elseif gGlobalSyncTable.gamemode == TAG then
                    -- set tag timer
                    gGlobalSyncTable.amountOfTime = 120 * 30

                    PLAYERS_NEEDED = 2
                elseif gGlobalSyncTable.gamemode == INFECTION then
                     -- set infection timer
                    gGlobalSyncTable.amountOfTime = 120 * 30

                    PLAYERS_NEEDED = 3
                elseif gGlobalSyncTable.gamemode == HOT_POTATO then
                    -- set hot potato timer
                    gGlobalSyncTable.amountOfTime = 60 * 30

                    PLAYERS_NEEDED = 3
                elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
                    -- set juggernaut timer
                    gGlobalSyncTable.amountOfTime = 120 * 30

                    PLAYERS_NEEDED = 3
                elseif gGlobalSyncTable.gamemode == ASSASINS then
                    -- set assasins timer
                    gGlobalSyncTable.amountOfTime = 120 * 30

                    PLAYERS_NEEDED = 3
                end
            end

            log_to_console("Tag: Modifier is set to " .. get_modifier_text_without_hex() .. " and the gamemode is set to " .. get_gamemode_without_hex())
        end

        timer = timer - 1 -- subtract timer by one
        gGlobalSyncTable.displayTimer = timer -- set display timer to timer

        for i = 0, MAX_PLAYERS - 1 do
            if gPlayerSyncTable[i].state ~= SPECTATOR then
                gPlayerSyncTable[i].state = RUNNER -- set everyone's state to runner
                gPlayerSyncTable[i].juggernautTags = 0
                gPlayerSyncTable[i].assasinTarget = -1
            end

            gPlayerSyncTable[i].amountOfTags = 0 -- reset amount of tags
            gPlayerSyncTable[i].amountOfTimeAsRunner = 0 -- reset amount of time as runner
        end

        if timer <= 0 then
            timer = gGlobalSyncTable.amountOfTime -- set timer to amount of time in a round

            local amountOfTaggersNeeded = math.floor(numPlayers / PLAYERS_NEEDED) -- always have the amount of the players needed, rounding down, be taggers
            if gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER then
                amountOfTaggersNeeded = 1 -- set amount of taggers to one if the modifier is one tagger
            end
            if gGlobalSyncTable.gamemode == JUGGERNAUT then
                amountOfTaggersNeeded = numPlayers - 1
            end

            log_to_console("Tag: Assigning Players")

            local amountOfTaggers = 0

            while amountOfTaggers < amountOfTaggersNeeded do
                -- select taggers
                local randomIndex = math.random(0, MAX_PLAYERS - 1) -- select random index

                if gPlayerSyncTable[randomIndex].state ~= TAGGER and gPlayerSyncTable[randomIndex].state ~= SPECTATOR and gPlayerSyncTable[randomIndex].state ~= -1 and gNetworkPlayers[randomIndex].connected then
                    gPlayerSyncTable[randomIndex].state = TAGGER

                    log_to_console("Tag: Assigned " .. gNetworkPlayers[randomIndex].name .. " as Tagger or Infector")

                    amountOfTaggers = amountOfTaggers + 1
                end
            end

            gGlobalSyncTable.juggernautTagsReq = numPlayers * 3

            if gGlobalSyncTable.gamemode == HOT_POTATO then
                hotPotatoTimerMultiplier = amountOfTaggersNeeded

                if hotPotatoTimerMultiplier > 2.3 then hotPotatoTimerMultiplier = 2.3 end
            else
                hotPotatoTimerMultiplier = 1
            end

            if gGlobalSyncTable.gamemode == ASSASINS then
                for i = 0, MAX_PLAYERS-1 do
                    if gPlayerSyncTable[i].state ~= SPECTATOR then
                        gPlayerSyncTable[i].state = TAGGER
                    end
                end
            end

            gGlobalSyncTable.roundState = ROUND_ACTIVE -- begin round

            log_to_console("Tag: Started the game")
        end
    elseif gGlobalSyncTable.roundState == ROUND_ACTIVE then
        if timer > 0 then
            timer = timer - (1 * hotPotatoTimerMultiplier) -- subtract timer by one multiplied by hot potato multiplyer
            gGlobalSyncTable.displayTimer = timer -- set display timer to timer
        end

        for i = 0, MAX_PLAYERS - 1 do
            if gPlayerSyncTable[i].state == RUNNER and gGlobalSyncTable.roundState == ROUND_ACTIVE then
                gPlayerSyncTable[i].amountOfTimeAsRunner = gPlayerSyncTable[i].amountOfTimeAsRunner + 1 -- increase amount of time as runner
            end
        end

        if timer <= 0 then
            if gGlobalSyncTable.gamemode ~= HOT_POTATO then
                timer = 15 * 30 -- 15 seconds

                if gGlobalSyncTable.gamemode == ASSASINS then
                    gGlobalSyncTable.roundState = ROUND_TAGGERS_WIN -- end round
                else
                    gGlobalSyncTable.roundState = ROUND_RUNNERS_WIN -- end round
                end

                log_to_console("Tag: Runners Won")

                return
            else
                for i = 0, MAX_PLAYERS - 1 do
                    if gNetworkPlayers[i].connected then
                        if gPlayerSyncTable[i].state == TAGGER then
                            gMarioStates[i].health = 0
                            spawn_sync_object(id_bhvExplosion, E_MODEL_EXPLOSION, gMarioStates[i].pos.x, gMarioStates[i].pos.y, gMarioStates[i].pos.z, function() end)
                            gPlayerSyncTable[i].state = ELIMINATED_OR_FROZEN
                            explosion_popup(i)
                        end
                    end
                end
            end
        end

        check_round_status() -- check current round status
    elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN or gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
        timer = timer - 1

        if timer <= 0 then
            gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS
            log_to_console("Tag: Starting a new round...")
        end
    elseif gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION then
        timer = timer - 1
        gGlobalSyncTable.displayTimer = timer

        if timer <= 0 then

            local currentConnectedCount = 0

            for i = 0, MAX_PLAYERS - 1 do
                if gNetworkPlayers[i].connected then
                    if gPlayerSyncTable[i].state ~= SPECTATOR and gPlayerSyncTable[i].state ~= ELIMINATED_OR_FROZEN then
                        currentConnectedCount = currentConnectedCount + 1
                    end
                end
            end

            local amountOfTaggersNeeded = math.floor(currentConnectedCount / PLAYERS_NEEDED) -- always have the amount of the players needed, rounding down, be taggers
            if amountOfTaggersNeeded < 1 then amountOfTaggersNeeded = 1 end
            if gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER then
                amountOfTaggersNeeded = 1 -- set amount of taggers to one if the modifier is one tagger
            end

            timer = 60 * 30

            log_to_console("Tag: Assigning Players")

            local amountOfTaggers = 0

            while amountOfTaggers < amountOfTaggersNeeded do
                -- select taggers
                local randomIndex = math.random(0, MAX_PLAYERS - 1) -- select random index

                if gPlayerSyncTable[randomIndex].state ~= TAGGER and gPlayerSyncTable[randomIndex].state ~= SPECTATOR and gPlayerSyncTable[randomIndex].state ~= ELIMINATED_OR_FROZEN and gPlayerSyncTable[randomIndex].state ~= -1 and gNetworkPlayers[randomIndex].connected then
                    gPlayerSyncTable[randomIndex].state = TAGGER

                    log_to_console("Tag: Assigned " .. gNetworkPlayers[randomIndex].name .. " as Tagger or Infector")

                    amountOfTaggers = amountOfTaggers + 1
                end
            end

            hotPotatoTimerMultiplier = amountOfTaggersNeeded

            if hotPotatoTimerMultiplier > 2.3 then hotPotatoTimerMultiplier = 2.3 end

            gGlobalSyncTable.roundState = ROUND_ACTIVE
        end
    end
end

local function update()
    if network_is_server() then server_update() end

    if joinTimer <= 0 then -- check this so the user has time to sync up
        if gPlayerSyncTable[0].invincTimer > 0 then
            gPlayerSyncTable[0].invincTimer = gPlayerSyncTable[0].invincTimer - 1
        end
    end

    -- handle speed boost
    if speedBoostTimer < 20 * 30 and gPlayerSyncTable[0].state == TAGGER and gGlobalSyncTable.modifier ~= MODIFIER_NO_BOOST and gGlobalSyncTable.modifier ~= MODIFIER_BOMBS and gGlobalSyncTable.modifier ~= MODIFIER_FLY and gGlobalSyncTable.modifier ~= MODIFIER_SPEED then
        speedBoostTimer = speedBoostTimer + 1
    elseif gPlayerSyncTable[0].state ~= TAGGER or gGlobalSyncTable.modifier == MODIFIER_NO_BOOST or gGlobalSyncTable.modifier == MODIFIER_BOMBS or gGlobalSyncTable.modifier == MODIFIER_FLY or gGlobalSyncTable.modifier == MODIFIER_SPEED then
        speedBoostTimer = 5 * 30 -- 5 seconds
    end

    if gPlayerSyncTable[0].state == SPECTATOR then
        gPlayerSyncTable[0].amountOfTimeAsRunner = 0
        gPlayerSyncTable[0].amountOfTags = 0
    end

    if joinTimer > 0 then
        joinTimer = joinTimer - 1 -- this is done to ensure that all globals sync beforehand
    end

    -- set network descriptions
    for i = 0, MAX_PLAYERS - 1 do
        if gPlayerSyncTable[i].state == SPECTATOR then
            network_player_set_description(gNetworkPlayers[i], "Spectator", 100, 100, 100, 255)
        elseif gPlayerSyncTable[i].state == -1 then
            network_player_set_description(gNetworkPlayers[i], "None", 50, 50, 50, 255)
        elseif gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
            network_player_set_description(gNetworkPlayers[i], "Incognito", 103, 103, 103, 255)
        end
    end
end

---@param m MarioState
local function mario_update(m)
    if not gGlobalSyncTable.water then
        for i = 1, 6 do
            set_environment_region(i, -10000)
        end
    end

    m.squishTimer = 0
    m.specialTripleJump = 0

    if not gGlobalSyncTable.bljs and m.forwardVel <= -48 and (m.action == ACT_LONG_JUMP or m.action == ACT_LONG_JUMP_LAND or m.action == ACT_LONG_JUMP_LAND_STOP) then
        m.forwardVel = -48 -- this is the dive speed
    end

    m.peakHeight = m.pos.y

    if gPlayerSyncTable[m.playerIndex].state == -1 then
        obj_set_model_extended(m.marioObj, E_MODEL_NONE)
    end

    if m.statusForCamera.cameraEvent == CAM_EVENT_BOWSER_INIT then
        m.statusForCamera.cameraEvent = 0
        m.area.camera.cutscene = 0
    end

    if gPlayerSyncTable[m.playerIndex].state ~= SPECTATOR and gGlobalSyncTable.modifier ~= MODIFIER_FLY and gGlobalSyncTable.gamemode ~= ASSASINS then
        m.flags = m.flags & ~MARIO_WING_CAP
        m.flags = m.flags & ~MARIO_METAL_CAP
        m.flags = m.flags & ~MARIO_VANISH_CAP
    elseif gPlayerSyncTable[m.playerIndex].state == SPECTATOR then
        m.flags = m.flags | MARIO_WING_CAP
        m.flags = m.flags & ~MARIO_METAL_CAP
        m.flags = m.flags | MARIO_VANISH_CAP
    elseif gGlobalSyncTable.modifier == MODIFIER_FLY then
        m.flags = m.flags | MARIO_WING_CAP
        m.flags = m.flags & ~MARIO_METAL_CAP
        m.flags = m.flags & ~MARIO_VANISH_CAP
    end

    -- set model state according to state
    if gPlayerSyncTable[m.playerIndex].state == TAGGER and gGlobalSyncTable.gamemode ~= ASSASINS and gGlobalSyncTable.modifier ~= MODIFIER_INCOGNITO then
        m.marioBodyState.modelState = MODEL_STATE_METAL
    elseif gPlayerSyncTable[m.playerIndex].state == SPECTATOR then
        m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
    elseif gPlayerSyncTable[m.playerIndex].state == RUNNER or (gGlobalSyncTable.modifier == MODIFIER_INCOGNITO and gPlayerSyncTable[m.playerIndex].state ~= ELIMINATED_OR_FROZEN) then
        m.marioBodyState.modelState = 0
    end

    if joinTimer <= 0 then
        m.invincTimer = gPlayerSyncTable[m.playerIndex].invincTimer
    end

    if m.playerIndex == 0 then
        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        local selectedLevel = levels[gGlobalSyncTable.selectedLevel] -- get currently selected level

        -- check if mario is in the proper level, act, and area, if not, rewarp mario
        if gGlobalSyncTable.roundState == ROUND_ACTIVE or gGlobalSyncTable.roundState == ROUND_WAIT or gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION then
            if not isRomhack then
                if np.currLevelNum ~= selectedLevel.level or np.currActNum ~= selectedLevel.act or np.currAreaIndex ~= selectedLevel.area then
                    ---@diagnostic disable-next-line: param-type-mismatch
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

                        ---@diagnostic disable-next-line: param-type-mismatch
                        while ((table.contains(defaultLevels, string.upper(get_level_name(level_to_course(gGlobalSyncTable.selectedLevel), gGlobalSyncTable.selectedLevel, 1))) or table.contains(blacklistedCourses, level_to_course(gGlobalSyncTable.selectedLevel)) or table.contains(badLevels, gGlobalSyncTable.selectedLevel) or level_to_course(gGlobalSyncTable.selectedLevel) > COURSE_RR or level_to_course(gGlobalSyncTable.selectedLevel) < COURSE_MIN) and isRomhack) or prevLevel == gGlobalSyncTable.selectedLevel or gGlobalSyncTable.selectedLevel < 0 do
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
            if selectedLevel.pipes == true and obj_get_first_with_behavior_id(id_bhvWarpPipe) == nil then
                spawn_sync_object(id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, selectedLevel.pipe1Pos.x, selectedLevel.pipe1Pos.y, selectedLevel.pipe1Pos.z, function (o)
                    o.oBehParams = 1
                end)

                spawn_sync_object(id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, selectedLevel.pipe2Pos.x, selectedLevel.pipe2Pos.y, selectedLevel.pipe2Pos.z, function (o)
                    o.oBehParams = 2
                end)
            end
        end

        -- delete unwanted pipes
        if gNetworkPlayers[0].currLevelNum == LEVEL_THI and obj_get_first_with_behavior_id(id_bhvWarpPipe) ~= nil then
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvWarpPipe))
        end

        -- get rid of unwated behaviors
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhv1Up))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvBubba))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvOneCoin))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvRedCoin))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvRedCoinStarMarker))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvHeaveHo))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvHeaveHoThrowMario))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvWhompKingBoss))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvSmallWhomp))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvMoneybag))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvMoneybagHidden))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvSpindrift))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvYoshi))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvBulletBill))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvHoot))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvTweester))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvBowser))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvBowserBodyAnchor))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvBowserTailAnchor))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvKingBobomb))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvStar))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvStarSpawnCoordinates))

        if not isRomhack then
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvActivatedBackAndForthPlatform))
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvExclamationBox))
        else
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvWarpPipe))
        end

        -- handle speed boost
        if m.controller.buttonPressed & Y_BUTTON ~= 0 and speedBoostTimer >= 20 * 30 and gPlayerSyncTable[0].state == TAGGER and gGlobalSyncTable.modifier ~= MODIFIER_NO_BOOST and gGlobalSyncTable.modifier ~= MODIFIER_BOMBS and gGlobalSyncTable.modifier ~= MODIFIER_FLY and gGlobalSyncTable.modifier ~= MODIFIER_SPEED then
            speedBoostTimer = 0
        end

        -- handle if just join
        if joinTimer == 2 * 30 then
            if gGlobalSyncTable.roundState == ROUND_ACTIVE or gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION then
                if gGlobalSyncTable.gamemode == TAG or gGlobalSyncTable.gamemode == INFECTION or gGlobalSyncTable.gamemode == HOT_POTATO or gGlobalSyncTable.gamemode == ASSASINS then
                    gPlayerSyncTable[0].state = ELIMINATED_OR_FROZEN
                else
                    gPlayerSyncTable[0].state = TAGGER
                end
            else
                gPlayerSyncTable[0].state = RUNNER
            end

            m.freeze = 1
        elseif network_is_server() then
            joinTimer = 0
        elseif joinTimer > 0 then
            m.freeze = 1
        end

        -- handle desync timer
        if desyncTimer <= 0 then
            m.freeze = 1
        end

        -- handle leaderboard and desync timer
        if gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN or gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
            m.freeze = 1
            m.action = ACT_NOTHING
        elseif (joinTimer <= 0 and desyncTimer > 0) or network_is_server() then
            if showSettings then
                m.freeze = 1
            elseif (_G.swearExists and not _G.swearSettingsOpened) or _G.swearExists == nil then
                m.freeze = 0
            end
        end

        -- sync tick tock clock speed
        if get_ttc_speed_setting() ~= gGlobalSyncTable.ttcSpeed then
            set_ttc_speed_setting(gGlobalSyncTable.ttcSpeed)
        end
    end
end

local function before_set_mario_action(m, action)
    if m.playerIndex == 0 then
        -- cancel any unwanted action
        if action == ACT_WAITING_FOR_DIALOG or action == ACT_READING_SIGN or action == ACT_READING_AUTOMATIC_DIALOG or action == ACT_READING_NPC_DIALOG or action == ACT_JUMBO_STAR_CUTSCENE or action == ACT_LAVA_BOOST or action == ACT_QUICKSAND_DEATH or action == ACT_BURNING_FALL or action == ACT_BURNING_JUMP then
            return 1
        end
    end
end

---@param m MarioState
local function before_phys(m)

    if m.playerIndex ~= 0 then return end

    -- handle speed boost
    if speedBoostTimer < 5 * 30 and gPlayerSyncTable[0].state == TAGGER then -- this allows for 5 seconds of speedboost
        if m.action ~= ACT_BACKWARD_AIR_KB and m.action ~= ACT_FORWARD_AIR_KB then
            m.vel.x = m.vel.x * 1.25
            m.vel.z = m.vel.z * 1.25
        else
            m.vel.x = m.vel.x * 1.05
            m.vel.z = m.vel.z * 1.05
        end

        generate_boost_trail(m)
    end

    -- handle fly speed reduction
    if gGlobalSyncTable.modifier == MODIFIER_FLY and gPlayerSyncTable[0].state == RUNNER and m.action == ACT_FLYING then
        m.vel.x = m.vel.x * 0.8
        m.vel.z = m.vel.z * 0.8
    end
end

local function hud_round_status()

    local text = ""

    -- set text
    if gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS then
        text = "Waiting for Players"
    elseif gGlobalSyncTable.roundState == ROUND_ACTIVE then
        text = "Time Remaining: " .. math.floor(gGlobalSyncTable.displayTimer / 30) -- divide by 30 for seconds and not frames (all game logic runs at 30fps)
    elseif gGlobalSyncTable.roundState == ROUND_WAIT then
        text = "Starting in " .. math.floor(gGlobalSyncTable.displayTimer / 30) -- divide by 30 for seconds and not frames (all game logic runs at 30fps)
    elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN or gGlobalSyncTable.state == ROUND_TAGGERS_WIN then
        text = "Starting new round"
    elseif gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION then
        text = "Intermission: " .. math.floor(gGlobalSyncTable.displayTimer / 30) -- divide by 30 for seconds and not frames (all game logic runs at 30fps)
    else
        return
    end

    local scale = 1.5

    -- get width of screen and text
    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text) * scale

    local x = (screenWidth - width) / 2.0
    local y = 0

    -- render rect
    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - (12 * scale), y, width + (24 * scale), (32 * scale))

    -- render text
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(text, x, y, scale)
end

local function hud_gamemode()
    local text = get_gamemode_without_hex()
    local scale = 1

    -- get width of screen and text
    local width = djui_hud_measure_text(text) * scale

    local x = 12 * scale
    local y = 0

    local r, g, b = get_gamemode_rgb_color()

    -- render rect
    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - (12 * scale), y, width + (24 * scale), (32 * scale))

    -- render text
    djui_hud_set_color(r, g, b, 255)
    djui_hud_print_text(text, x, y, scale)
end

local function hud_modifier()
    local text = get_modifier_text_without_hex()
    local scale = 1

    -- get width of screen and text
    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text) * scale

    local x = screenWidth - width - (12 * scale)
    local y = 0

    local r, g, b = get_modifier_rgb()

    -- render rect
    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x, y, width + (24 * scale), (32 * scale))

    -- render text
    djui_hud_set_color(r, g, b, 255)
    djui_hud_print_text(text, x + (8 * scale), y, scale)
end

local function hud_boost()

    if gPlayerSyncTable[0].state ~= TAGGER then return end
    if gGlobalSyncTable.modifier == MODIFIER_NO_BOOST or gGlobalSyncTable.modifier == MODIFIER_FLY or gGlobalSyncTable.modifier == MODIFIER_SPEED or gGlobalSyncTable.modifier == MODIFIER_BOMBS then return end

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local scale = 1
    local width = 128 * scale
    local height = 16 * scale
    local x = math.floor((screenWidth - width) / 2)
    local y = math.floor(screenHeight - height - 4 * scale)
    local boostTime = speedBoostTimer / 30 / 20

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x, y, width, height)

    x = x + 2 * scale
    y = y + 2 * scale
    width = width - 4 * scale
    height = height - 4 * scale
    width = math.floor(width * boostTime)
    djui_hud_set_color(0, 137, 237, 128)
    djui_hud_render_rect(x, y, width, height)

    if speedBoostTimer < 5 * 30 then
        text = "Boosting"
    elseif speedBoostTimer >= 5 * 30 and speedBoostTimer < 20 * 30 then
        text = "Recharging"
    else
        text = "Boost (Y)"
    end

    scale = 0.25
    width = djui_hud_measure_text(text) * scale
    height = 32 * scale
    x = (screenWidth - width) / 2
    y = screenHeight - 28

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - 6, y, width + 12, height)

    djui_hud_set_color(0, 162, 255, 128)
    djui_hud_print_text(text, x, y, scale)
end

local function hud_bombs()

    if gPlayerSyncTable[0].state ~= TAGGER then return end
    if gGlobalSyncTable.modifier ~= MODIFIER_BOMBS then return end

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local scale = 1
    local width = 128 * scale
    local height = 16 * scale
    local x = math.floor((screenWidth - width) / 2)
    local y = math.floor(screenHeight - height - 4 * scale)
    local bombTime = bombCooldown / 30 / 2

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x, y, width, height)

    x = x + 2 * scale
    y = y + 2 * scale
    width = width - 4 * scale
    height = height - 4 * scale
    width = math.floor(width * bombTime)
    djui_hud_set_color(242, 143, 36, 128)
    djui_hud_render_rect(x, y, width, height)

    if bombCooldown < 2 * 30 then
        text = "Reloading"
    else
        text = "Throw Bomb (Y)"
    end

    scale = 0.25
    width = djui_hud_measure_text(text) * scale
    height = 32 * scale
    x = (screenWidth - width) / 2
    y = screenHeight - 28

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - 6, y, width + 12, height)

    djui_hud_set_color(242, 143, 36, 128)
    djui_hud_print_text(text, x, y, scale)
end

local function hud_render()
    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    -- render hud
    hud_round_status()
    hud_gamemode()
    hud_modifier()
    hud_boost()
    hud_bombs()

    -- hide hud
    hud_hide()

    flashingIndex = flashingIndex + 1
end

---@param a MarioState
---@param v MarioState
local function allow_pvp(a, v)
    -- check if 2 runners are trying to attack eachother
    if gPlayerSyncTable[v.playerIndex].state == RUNNER and gPlayerSyncTable[a.playerIndex].state == RUNNER then return false end
    -- check if 2 taggers are trying to attack eachother
    if gPlayerSyncTable[v.playerIndex].state == TAGGER and gPlayerSyncTable[a.playerIndex].state == TAGGER and gGlobalSyncTable.gamemode ~= ASSASINS then return false end
    -- don't allow spectators to attack players, vice versa
    if gPlayerSyncTable[v.playerIndex].state == SPECTATOR or gPlayerSyncTable[a.playerIndex].state == SPECTATOR then return false end
end

---@param m MarioState
---@param o Object
---@param intee InteractionType
local function allow_interact(m, o, intee)

    -- check if intee is unwanted
    if intee == INTERACT_STAR_OR_KEY or intee == INTERACT_KOOPA_SHELL or intee == INTERACT_WARP_DOOR then
        return false
    end

    if intee == INTERACT_WARP and o.behavior == get_behavior_from_id(id_bhvWarpPipe) and not isRomhack then
        if (gGlobalSyncTable.gamemode == FREEZE_TAG and gPlayerSyncTable[m.playerIndex].state ~= ELIMINATED_OR_FROZEN) or gGlobalSyncTable.gamemode ~= FREEZE_TAG then
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

                    if m.invincTimer <= 0 then
                        gPlayerSyncTable[m.playerIndex].invincTimer = 2 * 30 -- 2 seconds
                    end

                    reset_camera(m.area.camera) -- reset camera

                    play_sound(SOUND_MENU_EXIT_PIPE, m.pos) -- play pipe sounds

                    break
                end
            end
        end

        return false
    elseif intee == INTERACT_WARP then
        return false
    end

    -- dont allow spectator to interact with objects
    if gPlayerSyncTable[m.playerIndex].state == SPECTATOR then return false end
end

---@param m MarioState
local function act_nothing(m)
    m.forwardVel = 0
    m.vel.x = 0
    m.vel.y = 0
    m.vel.z = 0
    m.slideVelX = 0
    m.slideVelZ = 0
    m.marioObj.header.gfx.animInfo.animFrame = m.marioObj.header.gfx.animInfo.animFrame - 1
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

    -- check thru 50 mods (if you have more than 50 mods enabled your crazy)
    for i=0,50 do
        if gActiveMods[i] ~= nil then
            if gActiveMods[i].incompatible ~= nil then
                -- check if it is a romhack by checking the incompatible tag
                if string.match(gActiveMods[i].incompatible, 'romhack') then
                    -- set romhack to true and water by default to true
                    isRomhack = true

                    gGlobalSyncTable.water = true

                    return
                end
            end
        end
    end
end

hook_on_sync_table_change(gGlobalSyncTable, 'randomGamemode', gGlobalSyncTable.randomGamemode, function (tag, oldVal, newVal)
    if oldVal ~= newVal then
        local text = ""

        if gGlobalSyncTable.randomGamemode then text = "random"
        else text = "not random" end

        if text ~= "" then
            djui_chat_message_create("Gamemode is " .. text)
        end
    end
end)

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_PHYS_STEP, before_phys)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)
-- make sure the user can never pause exit
hook_event(HOOK_ON_PAUSE_EXIT, function() return false end)
-- this is for romhacks
hook_event(HOOK_USE_ACT_SELECT, function() return false end)
-- this hook allows us to walk on lava and quicksand
hook_event(HOOK_ALLOW_HAZARD_SURFACE, function ()
   return false
end)

---@diagnostic disable-next-line: missing-parameter
hook_mario_action(ACT_NOTHING, act_nothing)

-- check if romhack is enabled
check_if_romhack_enabled()