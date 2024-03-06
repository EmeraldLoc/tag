-- name: \\#316BE8\\Tag\\#dcdcdc\\ (v2.2 R.C 1)
-- description: All Tag Related Gamemodes!\n\nThis mod contains Freeze Tag, Infection, Hot Potato, Juggernaut, Assassins, and the good'ol Tag, with modifiers, and full romhack support!\n\nThis mod includes a blacklist command to blacklist bad levels in romhacks\n\nHave fun playing Tag!\n\nDeveloped by \\#a5ae8f\\EmeraldLockdown\\#dcdcdc\\\n\nSnippets of code taken from \\#f79cf0\\EmilyEmmi\\#dcdcdc\\ and\\#ff7f00\\ Agent X\\#dcdcdc\\.
-- incompatible: gamemode tag

-- if your trying to learn this code, I hope i've done a good job.
-- This file is pretty much (other than misc.lua) the most unorganized file of them all
-- threw so much crap in here that isn't even apart of the actual game loop or anything
-- anyways other than that, everything should be good, so
-- wish you luck on your journey!

-- constants

-- round states
ROUND_WAIT_PLAYERS = 0
ROUND_ACTIVE = 1
ROUND_WAIT = 2
ROUND_TAGGERS_WIN = 3
ROUND_RUNNERS_WIN = 4
ROUND_HOT_POTATO_INTERMISSION = 5
ROUND_VOTING = 6

-- roles (gamemode-specific roles specified in designated gamemode files)
RUNNER = 0
TAGGER = 1
ELIMINATED_OR_FROZEN = 2
SPECTATOR = 3

-- gamemodes
MIN_GAMEMODE = 1
TAG = 1
FREEZE_TAG = 2
INFECTION = 3
HOT_POTATO = 4
JUGGERNAUT = 5
ASSASSINS = 6
MAX_GAMEMODE = 6

-- spectator states
SPECTATOR_STATE_MARIO = 0
SPECTATOR_STATE_FREECAM = 1
SPECTATOR_STATE_FOLLOW = 2

-- players needed (it's only 2 if your on the tag gamemode, otherwise this variable is 3)
PLAYERS_NEEDED = 2

-- modifiers
MODIFIER_MIN = 0
MODIFIER_NONE = 0
MODIFIER_BOMBS = 1
MODIFIER_LOW_GRAVITY = 2
MODIFIER_NO_RADAR = 3
MODIFIER_NO_BOOST = 4
MODIFIER_ONE_TAGGER = 5
MODIFIER_FOG = 6
MODIFIER_SPEED = 7
MODIFIER_INCOGNITO = 8
MODIFIER_HIGH_GRAVITY = 9
MODIFIER_MAX = 9

-- paintings found in vote screen, this is for all vanilla levels.
TEXTURE_CG_PAINTING    = get_texture_info("cg_painting")
TEXTURE_BOB_PAINTING   = get_texture_info("bob_painting")
TEXTURE_WF_PAINTING    = get_texture_info("wf_painting")
TEXTURE_JRB_PAINTING   = get_texture_info("jrb_painting")
TEXTURE_CCM_PAINTING   = get_texture_info("ccm_painting")
TEXTURE_BITDW_PAINTING = get_texture_info("bitdw_painting")
TEXTURE_BITFS_PAINTING = get_texture_info("bitfs_painting")
TEXTURE_LLL_PAINTING   = get_texture_info("lll_painting")
TEXTURE_SSL_PAINTING   = get_texture_info("ssl_painting")
TEXTURE_ISSL_PAINTING  = get_texture_info("issl_painting")
TEXTURE_RR_PAINTING    = get_texture_info("rr_painting")
TEXTURE_THI_PAINTING   = get_texture_info("thi_painting")
TEXTURE_ITHI_PAINTING  = get_texture_info("ithi_painting")
TEXTURE_TTM_PAINTING   = get_texture_info("ttm_painting")
TEXTURE_SL_PAINTING    = get_texture_info("sl_painting")
TEXTURE_WDW_PAINTING   = get_texture_info("wdw_painting")
TEXTURE_TTC_PAINTING   = get_texture_info("ttc_painting")

-- globals and sync tables
-- this is the round state, this variable tells you what current round it is
gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS
-- this is the currently selected modifier. If random modifiers are off (as in you've selected
-- one manually) then MODIFIER_NONE = Disabled
gGlobalSyncTable.modifier = MODIFIER_NONE
-- dictates wether or not modifiers and gamemodes are random
gGlobalSyncTable.randomModifiers = true
gGlobalSyncTable.randomGamemode = true
-- what the gamemode is
gGlobalSyncTable.gamemode = TAG
-- toggles for bljs, cnanons, and water
gGlobalSyncTable.bljs = false
gGlobalSyncTable.cannons = false
gGlobalSyncTable.water = false
-- display timer, used for all sorts of timers, timers from the top
-- of the screen, to timers in the vote menu
gGlobalSyncTable.displayTimer = 1
-- the current selected level. When romhacks are enabled, this is set to the actual level
-- number (i.e LEVEL_BOB), otherwise, it's set to the level in the levels table (found below here)
gGlobalSyncTable.selectedLevel = 1
-- juggernaut tags required. Since this changes depending on player count, make it a global variable
gGlobalSyncTable.juggernautTagsReq = 15
-- amount of time left in a round
gGlobalSyncTable.amountOfTime = 120 * 30
-- ttc speed, because ttc syncing sucks
gGlobalSyncTable.ttcSpeed = 0
-- toggles elimination on death
gGlobalSyncTable.eliminateOnDeath = true
-- toggles vote level system
gGlobalSyncTable.doVoting = true
-- all gamemode active timers
gGlobalSyncTable.tagActiveTimer = 120 * 30
gGlobalSyncTable.freezeTagActiveTimer = 180 * 30
gGlobalSyncTable.infectionActiveTimer = 120 * 30
gGlobalSyncTable.hotPotatoActiveTimer = 60 * 30
gGlobalSyncTable.juggernautActiveTimer = 120 * 30
gGlobalSyncTable.assassinsActiveTimer = 120 * 30
-- auto mode
gGlobalSyncTable.autoMode = true
-- enable tagger boosts or not
gGlobalSyncTable.boosts = true
for i = 0, MAX_PLAYERS - 1 do -- set all states for every player on init if we are the server
    if network_is_server() then
        -- the player's role
        gPlayerSyncTable[i].state = RUNNER
        -- the player's invinc timer, I forgot why I use the player sync table, think for
        -- syincing it or something, anyways that's what it is so
        gPlayerSyncTable[i].invincTimer = 0
        -- amount of tags a player has gotten, and the amount of time a runner has
        -- been a runner, this is for the leaderboard
        gPlayerSyncTable[i].amountOfTags = 0
        gPlayerSyncTable[i].amountOfTimeAsRunner = 0
        -- juggernaut lives/tags
        gPlayerSyncTable[i].juggernautTags = 0
        -- the assassins's target and stun timer (stun as the shock action)
        gPlayerSyncTable[i].assassinTarget = -1
        gPlayerSyncTable[i].assassinStunTimer = -1
        -- what number you voted for in the level voting system
        gPlayerSyncTable[i].votingNumber = 0
        -- whether or not your boosting
        gPlayerSyncTable[i].boosting = false
        -- spectator state
        gPlayerSyncTable[i].spectatorState = SPECTATOR_STATE_MARIO
    end
end

-- server settings
gServerSettings.playerInteractions = PLAYER_INTERACTIONS_SOLID -- force player attacks to be on
gServerSettings.bubbleDeath = 0 -- just.... no

-- variables
-- this is the local server timer used to set gGlobalSyncTable.displayTimer and other variables
timer = 0
-- if we are a romhack or not (checked in check_mods function)
isRomhack = false
-- if nametags are enabled or not (checked in check_mods function)
nametagsEnabled = false
-- the name
blacklistedCourses = {}
-- the join timer, this is what gives it time to sync
joinTimer = 6 * 30
-- the previous level, used for when the server selects levels to pick
prevLevel = 1 -- make it the same as the selected level so it selects a new level
-- These are levels that are failed to be warped to for romhacks
badLevels = {}
-- the global sound source, used for audio
gGlobalSoundSource = {x = 0, y = 0, z = 0}
-- if we are paused or not, for custom pause menu
isPaused = false
-- whether or not to use romhack cam
useRomhackCam = true
if mod_storage_load("useRomhackCam") == "false" then useRomhackCam = false end
-- speed boost timer handles boosting
local speedBoostTimer = 0
-- hot potato timer multiplier is when the timer is faster if there's more people in
-- hot potato
local hotPotatoTimerMultiplier = 1
-- pipe invinc vars
local pipeTimer = 0
local pipeUse = 0

-- just some global variables, honestly idk why the second one is there but it is so.....
_G.tagExists = true
_G.tagSettingsOpen = false

-- just a action we can use, used for when the round ends and mario freezes
ACT_NOTHING = allocate_mario_action(ACT_FLAG_IDLE)

-- this is the table for levels, pretty self explanitory.
levels = {
    {name = "cg",    level = LEVEL_CASTLE_GROUNDS, painting = TEXTURE_CG_PAINTING,    act = 0, area = 1, pipes = true, pipe1Pos = {x = -5979, y = 378, z = -1371},  pipe2Pos = {x = 1043, y = 3174, z = -5546}},
    {name = "bob",   level = LEVEL_BOB,            painting = TEXTURE_BOB_PAINTING,   act = 0, area = 1, pipes = true, pipe1Pos = {x = -4694, y = 0, z = 6699},     pipe2Pos = {x = 5079, y = 3072, z = 655}},
    {name = "rr",    level = LEVEL_RR,             painting = TEXTURE_RR_PAINTING,    act = 0, area = 1, pipes = true, pipe1Pos = {x = -4221, y = 6451, z = -5885}, pipe2Pos = {x = 2125, y = -1833, z = 2079}},
    {name = "ccm",   level = LEVEL_CCM,            painting = TEXTURE_CCM_PAINTING,   act = 0, area = 1, pipes = true, pipe1Pos = {x = -1352, y = 2560, z = -1824}, pipe2Pos = {x = 5628, y = -4607, z = -28}},
    {name = "issl",  level = LEVEL_SSL,            painting = TEXTURE_ISSL_PAINTING,  act = 0, area = 2, pipes = true, pipe1Pos = {x = -460, y = 0, z = 4247},      pipe2Pos = {x = 997, y = 3942, z = 1234}},
    {name = "bitfs", level = LEVEL_BITFS,          painting = TEXTURE_BITFS_PAINTING, act = 0, area = 1, pipes = true, pipe1Pos = {x = -154, y = -2866, z = -102},  pipe2Pos = {x = 1205, y = 5478, z = 58}},
    {name = "ttm",   level = LEVEL_TTM,            painting = TEXTURE_TTM_PAINTING,   act = 0, area = 1, pipes = true, pipe1Pos = {x = -1080, y = -4634, z = 4176}, pipe2Pos = {x = 1031, y = 2306, z = -198}},
    {name = "ttc",   level = LEVEL_TTC,            painting = TEXTURE_TTC_PAINTING,   act = 0, area = 1, pipes = true, pipe1Pos = {x = 1361, y = -4822, z = 176},   pipe2Pos = {x = 1594, y = 5284, z = 1565}},
    {name = "jrb",   level = LEVEL_JRB,            painting = TEXTURE_JRB_PAINTING,   act = 0, area = 1, pipes = true, pipe1Pos = {x = 3000, y = -5119, z = 2688},  pipe2Pos = {x = -6398, y = 1126, z = 191}},
    {name = "wdw",   level = LEVEL_WDW,            painting = TEXTURE_WDW_PAINTING,   act = 0, area = 1, pipes = true, pipe1Pos = {x = 3346, y = 154, z = 2918},    pipe2Pos = {x = -3342, y = 3584, z = -3353}},
    {name = "wf",    level = LEVEL_WF,             painting = TEXTURE_WF_PAINTING,    act = 0, area = 1, pipes = false},
    {name = "lll",   level = LEVEL_LLL,            painting = TEXTURE_LLL_PAINTING,   act = 0, area = 1, pipes = false},
    {name = "ssl",   level = LEVEL_SSL,            painting = TEXTURE_SSL_PAINTING,   act = 0, area = 1, pipes = false},
    {name = "thi",   level = LEVEL_THI,            painting = TEXTURE_THI_PAINTING,   act = 0, area = 1, pipes = false},
    {name = "ithi",  level = LEVEL_THI,            painting = TEXTURE_ITHI_PAINTING,  act = 0, area = 3, pipes = false},
    {name = "sl",    level = LEVEL_SL,             painting = TEXTURE_SL_PAINTING,    act = 0, area = 1, pipes = false},
    {name = "arena", level = LEVEL_BOWSER_1,       painting = TEXTURE_BITDW_PAINTING, act = 0, area = 1, pipes = false},
}

local function server_update()
    -- set some basic sync table vars
    for i = 0, MAX_PLAYERS - 1 do
        if not gNetworkPlayers[i].connected then
            gPlayerSyncTable[i].state = -1
            gPlayerSyncTable[i].amountOfTimeAsRunner = 0
            gPlayerSyncTable[i].amountOfTags = 0
            gPlayerSyncTable[i].juggernautTags = 0
        end
    end

    -- get number of players
    local numPlayers = 0

    for i = 0, MAX_PLAYERS - 1 do
        -- don't include spectators
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
            gGlobalSyncTable.amountOfTime = gGlobalSyncTable.tagActiveTimer

            PLAYERS_NEEDED = 2

            log_to_console("Tag: Attempted to keep tag going by setting the gamemode to tag")
        end
    elseif gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS then
        -- if we aren't in auto mode, then don't run this code, and run designated code in the if statemnt
        if not gGlobalSyncTable.autoMode then
            if timer >= 16 * 30 then
                for i = 0, MAX_PLAYERS - 1 do
                    if gPlayerSyncTable[i].state ~= SPECTATOR then
                        gPlayerSyncTable[i].state = RUNNER
                    end
                end
            end

            goto ifend
        end

        timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16

        -- this long while loop is just to select a random level, ik, extremely hard to read
        ---@diagnostic disable-next-line: param-type-mismatch
        while ((level_is_vanilla_level(gGlobalSyncTable.selectedLevel) or table.contains(blacklistedCourses, level_to_course(gGlobalSyncTable.selectedLevel)) or table.contains(badLevels, gGlobalSyncTable.selectedLevel) or level_to_course(gGlobalSyncTable.selectedLevel) > COURSE_RR or level_to_course(gGlobalSyncTable.selectedLevel) < COURSE_MIN) and isRomhack) or prevLevel == gGlobalSyncTable.selectedLevel or gGlobalSyncTable.selectedLevel <= 0 or table.contains(blacklistedCourses, gGlobalSyncTable.selectedLevel) do
            if isRomhack then
                gGlobalSyncTable.selectedLevel = course_to_level(math.random(COURSE_MIN, COURSE_RR))
            else
                gGlobalSyncTable.selectedLevel = math.random(1, #levels) -- select a random level

                if levels[gGlobalSyncTable.selectedLevel].level == LEVEL_TTC and not isRomhack then
                    gGlobalSyncTable.ttcSpeed = math.random(0, 3)
                end
            end
        end

        prevLevel = gGlobalSyncTable.selectedLevel
        gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state

        log_to_console("Tag: Round State is now ROUND_WAIT")

        ::ifend::
    end

    if gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS then
        -- force state to be runner, so long as they aren't a spectator, and we are in auto mode
        for i = 0, MAX_PLAYERS - 1 do
            if gPlayerSyncTable[i].state ~= SPECTATOR and gGlobalSyncTable.autoMode then
                gPlayerSyncTable[i].state = RUNNER
            end
        end

        -- set timer to 15 seconds to prevent state being set constantly
        timer = 15 * 30
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

                    if gGlobalSyncTable.gamemode == JUGGERNAUT
                    and (gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER
                    or gGlobalSyncTable.modifier == MODIFIER_INCOGNITO) then
                        goto selectmodifier
                    end

                    if gGlobalSyncTable.gamemode == ASSASSINS
                    and (gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER
                    or gGlobalSyncTable.modifier == MODIFIER_INCOGNITO) then
                        goto selectmodifier
                    end

                    if (levels[gGlobalSyncTable.selectedLevel].name == "ithi"
                    or levels[gGlobalSyncTable.selectedLevel].name == "lll"
                    or levels[gGlobalSyncTable.selectedLevel].name == "bitfs")
                    and not isRomhack
                    and gGlobalSyncTable.modifier == MODIFIER_FOG then
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
            end

            -- set the amount of time var and players needed var
            if gGlobalSyncTable.gamemode == FREEZE_TAG then
                -- set freeze tag timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.freezeTagActiveTimer

                PLAYERS_NEEDED = 3
            elseif gGlobalSyncTable.gamemode == TAG then
                -- set tag timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.tagActiveTimer

                PLAYERS_NEEDED = 2
            elseif gGlobalSyncTable.gamemode == INFECTION then
                 -- set infection timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.infectionActiveTimer

                PLAYERS_NEEDED = 3
            elseif gGlobalSyncTable.gamemode == HOT_POTATO then
                -- set hot potato timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.hotPotatoActiveTimer

                PLAYERS_NEEDED = 3
            elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
                -- set juggernaut timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.juggernautActiveTimer

                PLAYERS_NEEDED = 3
            elseif gGlobalSyncTable.gamemode == ASSASSINS then
                -- set assassins timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.assassinsActiveTimer

                PLAYERS_NEEDED = 3
            end

            log_to_console("Tag: Modifier is set to " .. get_modifier_text_without_hex() .. " and the gamemode is set to " .. get_gamemode_without_hex())
        end

        for i = 0, MAX_PLAYERS - 1 do
            if gPlayerSyncTable[i].state ~= SPECTATOR and gGlobalSyncTable.autoMode then
                gPlayerSyncTable[i].state = RUNNER -- set everyone's state to runner
            end

            local m = gMarioStates[i]

            if m.action == ACT_NOTHING then
                set_mario_action(m, ACT_IDLE, 0)
            end

            gPlayerSyncTable[i].juggernautTags = 0 -- reset juggernaut tags
            gPlayerSyncTable[i].assassinTarget = -1 -- reset assassin target
            gPlayerSyncTable[i].amountOfTags = 0 -- reset amount of tags
            gPlayerSyncTable[i].amountOfTimeAsRunner = 0 -- reset amount of time as runner
        end

        timer = timer - 1 -- subtract timer by one
        gGlobalSyncTable.displayTimer = timer -- set display timer to timer

        if timer <= 0 then
            -- set the amount of time var and players needed var
            if gGlobalSyncTable.gamemode == FREEZE_TAG then
                -- set freeze tag timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.freezeTagActiveTimer
            elseif gGlobalSyncTable.gamemode == TAG then
                -- set tag timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.tagActiveTimer
            elseif gGlobalSyncTable.gamemode == INFECTION then
                 -- set infection timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.infectionActiveTimer
            elseif gGlobalSyncTable.gamemode == HOT_POTATO then
                -- set hot potato timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.hotPotatoActiveTimer
            elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
                -- set juggernaut timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.juggernautActiveTimer
            elseif gGlobalSyncTable.gamemode == ASSASSINS then
                -- set assassins timer
                gGlobalSyncTable.amountOfTime = gGlobalSyncTable.assassinsActiveTimer
            end

            timer = gGlobalSyncTable.amountOfTime -- set timer to amount of time in a round

            -- if we have custom roles, skip straight to actually starting the round
            local skipTaggerSelection = false
            for i = 0, MAX_PLAYERS - 1 do
                if gNetworkPlayers[i].connected then
                    if gPlayerSyncTable[i].state ~= RUNNER and gPlayerSyncTable[i].state ~= SPECTATOR then
                        skipTaggerSelection = true
                    end
                end
            end

            local amountOfTaggersNeeded = math.floor(numPlayers / PLAYERS_NEEDED) -- always have the amount of the players needed, rounding down, be taggers

            if not skipTaggerSelection then
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
            end

            gGlobalSyncTable.juggernautTagsReq = math.floor(numPlayers * 2.5)

            if gGlobalSyncTable.juggernautTagsReq > 20 then gGlobalSyncTable.juggernautTagsReq = 20 end

            if gGlobalSyncTable.gamemode == HOT_POTATO then
                hotPotatoTimerMultiplier = amountOfTaggersNeeded

                if hotPotatoTimerMultiplier > 2.3 then hotPotatoTimerMultiplier = 2.3 end
            else
                hotPotatoTimerMultiplier = 1
            end

            if gGlobalSyncTable.gamemode == ASSASSINS then
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

                if gGlobalSyncTable.gamemode == ASSASSINS then
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
            if gGlobalSyncTable.doVoting and gGlobalSyncTable.autoMode then
                gGlobalSyncTable.roundState = ROUND_VOTING
                timer = 20 * 30
                log_to_console("Tag: Settings round state to ROUND_VOTING...")
            else
                if not gGlobalSyncTable.autoMode then
                    for i = 0, MAX_PLAYERS - 1 do
                        if gPlayerSyncTable[i].state ~= SPECTATOR then
                            gPlayerSyncTable[i].state = RUNNER
                        end
                    end

                    gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS

                    goto ifend
                end

                timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16

                ---@diagnostic disable-next-line: param-type-mismatch
                while ((level_is_vanilla_level(gGlobalSyncTable.selectedLevel) or table.contains(blacklistedCourses, level_to_course(gGlobalSyncTable.selectedLevel)) or table.contains(badLevels, gGlobalSyncTable.selectedLevel) or level_to_course(gGlobalSyncTable.selectedLevel) > COURSE_RR or level_to_course(gGlobalSyncTable.selectedLevel) < COURSE_MIN) and isRomhack) or (voteRandomLevels[voteResult] == nil and gGlobalSyncTable.selectedLevel == prevLevel) do
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

                log_to_console("Tag: Settings round state to ROUND_WAIT...")

                ::ifend::
            end
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
    elseif gGlobalSyncTable.roundState == ROUND_VOTING then
        timer = timer - 1
        if timer >= 0 then
            gGlobalSyncTable.displayTimer = timer
        end

        if timer <= -3 * 30 then
            timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16
            local voteResult = -1
            local maxVotes = -1
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

                if votes > maxVotes then
                    voteResult = i
                    maxVotes = votes
                end
            end

            if voteRandomLevels[voteResult] ~= nil then
                gGlobalSyncTable.selectedLevel = voteRandomLevels[voteResult]
            end

            ---@diagnostic disable-next-line: param-type-mismatch
            while ((level_is_vanilla_level(gGlobalSyncTable.selectedLevel) or table.contains(blacklistedCourses, level_to_course(gGlobalSyncTable.selectedLevel)) or table.contains(badLevels, gGlobalSyncTable.selectedLevel) or level_to_course(gGlobalSyncTable.selectedLevel) > COURSE_RR or level_to_course(gGlobalSyncTable.selectedLevel) < COURSE_MIN) and isRomhack) or (voteRandomLevels[voteResult] == nil and gGlobalSyncTable.selectedLevel == prevLevel) do
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
        end
    end
end

local function update()
    -- server update
    if network_is_server() then server_update() end

    if joinTimer <= 0 then -- check this so the user has time to sync up
        if gPlayerSyncTable[0].invincTimer > 0 then
            gPlayerSyncTable[0].invincTimer = gPlayerSyncTable[0].invincTimer - 1
        end
    end

    -- handle speed boost
    if speedBoostTimer < 20 * 30 and gPlayerSyncTable[0].state == TAGGER and boosts_enabled() then
        speedBoostTimer = speedBoostTimer + 1
    elseif gPlayerSyncTable[0].state ~= TAGGER or not boosts_enabled() then
        speedBoostTimer = 5 * 30 -- 5 seconds
    end

    -- set some variables if we are a spectator
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
            -- love the color of this, idk why I like it so much but it's such a nice gray.
            network_player_set_description(gNetworkPlayers[i], "Incognito", 103, 103, 103, 255)
        end
    end
end

---@param m MarioState
local function mario_update(m)
    -- get rid of water
    if not gGlobalSyncTable.water then
        for i = 1, 6 do
            set_environment_region(i, -10000)
        end
    end

    -- disable special triple jump
    m.specialTripleJump = 0

    -- this ensures bljs are a no good, but hey, you can go as fast as a dive so
    if not gGlobalSyncTable.bljs and m.forwardVel <= -48 and (m.action == ACT_LONG_JUMP or m.action == ACT_LONG_JUMP_LAND or m.action == ACT_LONG_JUMP_LAND_STOP) then
        m.forwardVel = -48 -- this is the dive speed
    end

    m.peakHeight = m.pos.y -- disables fall damage

    -- disable hangable ceilings
    if m.ceil.type == SURFACE_HANGABLE then
        m.ceil.type = SURFACE_DEFAULT
    end

    -- set player that just joined to be invisible (-1 is not a valid state so)
    if gPlayerSyncTable[m.playerIndex].state == -1 then
        obj_set_model_extended(m.marioObj, E_MODEL_NONE)
    end

    -- this is for bowser stages
    if m.statusForCamera.cameraEvent == CAM_EVENT_BOWSER_INIT then
        m.statusForCamera.cameraEvent = 0
        m.area.camera.cutscene = 0
    end

    -- don't lose cap permanently (thanks shine thief)
    m.cap = 0

    -- this sets cap flags
    -- guide:
    -- | = add
    -- & ~ = subtract
    if gPlayerSyncTable[m.playerIndex].state ~= SPECTATOR then
        m.flags = m.flags & ~MARIO_WING_CAP
        m.flags = m.flags & ~MARIO_METAL_CAP
        m.flags = m.flags & ~MARIO_VANISH_CAP
    elseif gPlayerSyncTable[m.playerIndex].state == SPECTATOR then
        m.flags = m.flags | MARIO_WING_CAP
        m.flags = m.flags & ~MARIO_METAL_CAP
        m.flags = m.flags | MARIO_VANISH_CAP
    end

    -- set model state according to state
    if gPlayerSyncTable[m.playerIndex].state == TAGGER
    and gGlobalSyncTable.gamemode ~= ASSASSINS
    and ((gGlobalSyncTable.modifier ~= MODIFIER_INCOGNITO
    or gPlayerSyncTable[0].state == TAGGER)
    or m.playerIndex == 0) then
        m.marioBodyState.modelState = MODEL_STATE_METAL
    elseif gPlayerSyncTable[m.playerIndex].state == SPECTATOR then
        m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA -- vanish cap mario
    elseif gPlayerSyncTable[m.playerIndex].state == RUNNER
    or (gGlobalSyncTable.modifier == MODIFIER_INCOGNITO
    and gPlayerSyncTable[m.playerIndex].state ~= ELIMINATED_OR_FROZEN) then
        m.marioBodyState.modelState = 0 -- normal
    end

    -- sync invinc timer to sync table invinc timer
    if joinTimer <= 0 then
        m.invincTimer = gPlayerSyncTable[m.playerIndex].invincTimer
    end

    if m.playerIndex == 0 then
        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        local selectedLevel = levels[gGlobalSyncTable.selectedLevel] -- get currently selected level

        -- check if mario is in the proper level, act, and area, if not, rewarp mario
        -- this is all warp shenenagins, and i'm waaay too lazy to do in depth comments, so, just wing it i guess
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
                        while ((level_is_vanilla_level(gGlobalSyncTable.selectedLevel) or table.contains(blacklistedCourses, level_to_course(gGlobalSyncTable.selectedLevel)) or table.contains(badLevels, gGlobalSyncTable.selectedLevel) or level_to_course(gGlobalSyncTable.selectedLevel) > COURSE_RR or level_to_course(gGlobalSyncTable.selectedLevel) < COURSE_MIN) and isRomhack) or prevLevel == gGlobalSyncTable.selectedLevel or gGlobalSyncTable.selectedLevel < 0 do
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
        elseif gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS and not gGlobalSyncTable.autoMode then
            if np.currLevelNum ~= LEVEL_CASTLE_GROUNDS then
                warp_to_level(LEVEL_CASTLE_GROUNDS, 1, 0)
            end
        end

        -- spawn pipes
        if not isRomhack then
            -- make sure the level has pipes (found in level table), then check if they aren't spawned
            if selectedLevel.pipes and obj_get_first_with_behavior_id(id_bhvWarpPipe) == nil then
                -- spawn pipes
                spawn_non_sync_object(id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, selectedLevel.pipe1Pos.x, selectedLevel.pipe1Pos.y, selectedLevel.pipe1Pos.z, function (o)
                    o.oBehParams = 1
                end)

                spawn_non_sync_object(id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, selectedLevel.pipe2Pos.x, selectedLevel.pipe2Pos.y, selectedLevel.pipe2Pos.z, function (o)
                    o.oBehParams = 2
                end)
            end
        end

        -- delete unwanted pipes in Tiny Huge Island
        if gNetworkPlayers[0].currLevelNum == LEVEL_THI and obj_get_first_with_behavior_id(id_bhvWarpPipe) ~= nil and not isRomhack then
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvWarpPipe))
        end

        -- handle pipe invinc timers and such, too lazy to write what this does
        pipeTimer = pipeTimer + 1
        if pipeTimer > 3 * 30 then
            pipeUse = 0
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
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvSpawnedStar))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvKoopaShell))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvWingCap))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvMetalCap))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvVanishCap))

        -- water level diamond breaks water being disabled, so just get rid of it
        if not gGlobalSyncTable.water then
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvWaterLevelDiamond))
        end

        -- delete objects depending if we are in a romhack or not
        if not isRomhack then
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvActivatedBackAndForthPlatform))
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvExclamationBox))
        else
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvWarpPipe))
        end

        -- handle speed boost, this is a fun if statement
        if m.controller.buttonPressed & Y_BUTTON ~= 0 and speedBoostTimer >= 20 * 30 and gPlayerSyncTable[0].state == TAGGER and boosts_enabled() then
            speedBoostTimer = 0
        end

        -- handle if just join
        if joinTimer == 2 * 30 and not network_is_server() then
            -- this here sets our initial state
            if gGlobalSyncTable.roundState == ROUND_ACTIVE or gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION then
                if gGlobalSyncTable.gamemode == TAG or gGlobalSyncTable.gamemode == INFECTION or gGlobalSyncTable.gamemode == HOT_POTATO or gGlobalSyncTable.gamemode == ASSASSINS then
                    gPlayerSyncTable[0].state = ELIMINATED_OR_FROZEN
                else
                    gPlayerSyncTable[0].state = TAGGER
                end
            else
                gPlayerSyncTable[0].state = RUNNER
            end

            m.freeze = 1
        -- some m.freeze stuff and join timer shenenagins
        elseif joinTimer > 0 and not network_is_server() then
            m.freeze = 1
        elseif network_is_server() then
            joinTimer = 0
        end

        -- desync timer
        if desyncTimer <= 0 then
            m.freeze = 1
        end

        -- handle leaderboard and desync timer
        if gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN or gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
            m.freeze = 1
            set_mario_action(m, ACT_NOTHING, 0)
        elseif (joinTimer <= 0 and desyncTimer > 0) or network_is_server() then
            -- yea idk what this is this looks awful, not changing it though since it somehow works
            if showSettings or isPaused then
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
        -- goodbye mario speed
        if m.action ~= ACT_BACKWARD_AIR_KB and m.action ~= ACT_FORWARD_AIR_KB then
            m.vel.x = m.vel.x * 1.25
            m.vel.z = m.vel.z * 1.25
        else
            m.vel.x = m.vel.x * 1.05
            m.vel.z = m.vel.z * 1.05
        end

        -- tells other players we are boosting
        gPlayerSyncTable[0].boosting = true
    else
        -- we aren't boosting, so set boosting var to false
        gPlayerSyncTable[0].boosting = false
    end

    -- this function handles boost trail
    generate_boost_trail()
end

local function hud_round_status()

    -- if you want comments on the hud stuff, you ain't getting it, I barely undestand it
    -- but I understand it just enough to make the huds I make

    local text = ""

    -- set text
    if gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS then
        if gGlobalSyncTable.autoMode then
            text = "Waiting for Players"
        else
            text = "Waiting for Host"
        end
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
    if not boosts_enabled() then return end

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

    -- if we are hiding the hud as a spectator, don't render the hud
    if spectatorHideHud then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    -- render hud
    if gGlobalSyncTable.roundState ~= ROUND_RUNNERS_WIN
    and gGlobalSyncTable.roundState ~= ROUND_TAGGERS_WIN then
        hud_round_status()
        hud_gamemode()
        hud_modifier()
        hud_boost()
        hud_bombs()
    end

    -- hide hud
    hud_hide()
end

---@param a MarioState
---@param v MarioState
local function allow_pvp(a, v)
    -- check if 2 runners are trying to attack eachother
    if gPlayerSyncTable[v.playerIndex].state == RUNNER and gPlayerSyncTable[a.playerIndex].state == RUNNER then return false end
    -- check if 2 taggers are trying to attack eachother
    if gPlayerSyncTable[v.playerIndex].state == TAGGER and gPlayerSyncTable[a.playerIndex].state == TAGGER and gGlobalSyncTable.gamemode ~= ASSASSINS then return false end
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

    -- check if we interacted with a pipe, if we did, do pipe shenenagins
    if intee == INTERACT_WARP and o.behavior == get_behavior_from_id(id_bhvWarpPipe) and not isRomhack then
        -- here we ensure our state isn't set to frozen
        if (gGlobalSyncTable.gamemode == FREEZE_TAG and gPlayerSyncTable[m.playerIndex].state ~= ELIMINATED_OR_FROZEN) or gGlobalSyncTable.gamemode ~= FREEZE_TAG then
            -- get second pipe
            local o2 = obj_get_first_with_behavior_id(id_bhvWarpPipe)
            while o2 ~= nil do
                if o2 == o then
                    o2 = obj_get_next_with_same_behavior_id(o2)
                else
                    -- pretty much teleport to the pipe and set invincibility
                    m.pos.x = o2.oPosX
                    m.pos.y = o2.oPosY + 200
                    m.pos.z = o2.oPosZ

                    set_mario_action(m, ACT_JUMP, 0)

                    m.vel.y = 60
                    m.forwardVel = 15

                    if m.invincTimer < 2 * 30 and pipeUse < 3 then
                        gPlayerSyncTable[m.playerIndex].invincTimer = 2 * 30 -- 2 seconds
                        pipeUse = pipeUse + 1
                    end

                    pipeTimer = 0

                    reset_camera(m.area.camera) -- reset camera

                    play_sound(SOUND_MENU_EXIT_PIPE, m.pos) -- play pipe sounds

                    break
                end
            end
        end

        return false
    elseif intee == INTERACT_WARP then
        -- disable warp interaction
        return false
    end

    -- dont allow spectator to interact with objects, L
    -- they are allowed to interact with pipes because that is handled above, so that's awesome!
    if gPlayerSyncTable[m.playerIndex].state == SPECTATOR then return false end
end

---@param m MarioState
local function act_nothing(m)
    -- great action am I right
    m.forwardVel = 0
    m.vel.x = 0
    m.vel.y = 0
    m.vel.z = 0
    m.slideVelX = 0
    m.slideVelZ = 0
    -- this is to freeze mario's animation btw
    m.marioObj.header.gfx.animInfo.animFrame = m.marioObj.header.gfx.animInfo.animFrame - 1
end

function check_mods()
    -- check thru 50 mods (if you have more than 50 mods enabled your crazy)
    for i = 0, 50 do
        if gActiveMods[i] ~= nil then
            if gActiveMods[i].incompatible ~= nil then
                -- check if it is a romhack by checking the incompatible tag
                if string.match(gActiveMods[i].incompatible, "romhack") then
                    -- set romhack to true and water by default to true
                    isRomhack = true

                    gGlobalSyncTable.water = true
                -- check for nametags mod by looking at incompatible tag
                elseif string.match(gActiveMods[i].incompatible, "nametags") then
                    -- set nametagsEnabled to true
                    nametagsEnabled = true
                end
            end
        end
    end
end

hook_on_sync_table_change(gGlobalSyncTable, 'randomGamemode', gGlobalSyncTable.randomGamemode, function (tag, oldVal, newVal)
    -- the only one of these awful sync table changes you will see, enjoy.
    if oldVal ~= newVal then
        local text = ""

        if gGlobalSyncTable.randomGamemode then text = "random"
        else text = "not random" end

        if text ~= "" then
            djui_chat_message_create("Gamemode is " .. text)
        end
    end
end)

-- runs once per frame (all game logic runs at 30fps)
hook_event(HOOK_UPDATE, update)
-- runs when the hud is rendered
hook_event(HOOK_ON_HUD_RENDER, hud_render)
-- runs when mario is updated
hook_event(HOOK_MARIO_UPDATE, mario_update)
-- runs before mario's physic step
hook_event(HOOK_BEFORE_PHYS_STEP, before_phys)
-- runs right before mario is about to attack
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp)
-- runs right before mario is about to interact with an object
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
-- runs right before mario sets his action
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)
-- make sure the user can never pause exit
hook_event(HOOK_ON_PAUSE_EXIT, function() return false end)
-- this is for romhacks
hook_event(HOOK_USE_ACT_SELECT, function() return false end)
-- this hook allows us to walk on lava and quicksand
hook_event(HOOK_ALLOW_HAZARD_SURFACE, function ()
   return false
end)

-- make ACT_NOTHING do something, wild ain't it
---@diagnostic disable-next-line: missing-parameter
hook_mario_action(ACT_NOTHING, act_nothing)

-- check for mods
check_mods()

-- Good job, you made it to the end of your file. I'd suggest heading over to tag.lua next!