-- name: \\#316BE8\\Tag (v2.4 Beta)\\#dcdcdc\\
-- description: All Tag Related Gamemodes!\n\nThis mod contains Tag, Freeze Tag, Infection, Hot Potato, Juggernaut, Assassins, and more, with modifiers, and full romhack support!\n\nHave fun playing Tag!\n\nDeveloped by \\#a5ae8f\\EmeraldLockdown\\#dcdcdc\\\n\nSnippets of code taken from \\#f7b2f3\\EmilyEmmi\\#dcdcdc\\, \\#ff7f00\\ Agent X\\#dcdcdc\\, Sunk, and \#F2F3AE\B\#EDD382\l\#FC9E4F\o\#F4442E\c\#9B1D20\ky\n\nPainting textures taken from Shine Thief, by \\#f7b2f3\\EmilyEmmi\n\n\\#dcdcdc\\Romhack Porters are in the romhacks.lua file.
-- incompatible: gamemode tag

-- if your trying to learn this code, I hope I've done a good job.
-- This file is pretty much (other than a-misc.lua) the most unorganized file of them all
-- threw so much crap in here that isn't even apart of the actual game loop or anything
-- anyways other than that, everything should be good, so
-- wish you luck on your journey!

-- tag versions
versions = {
    "v2.4",
    "v2.32",
    "v2.31",
    "v2.3",
    "v2.21",
    "v2.2",
    "v2.1",
    "v2.0",
}

-- constants

-- round states
ROUND_WAIT_PLAYERS                     = 0
ROUND_ACTIVE                           = 1
ROUND_WAIT                             = 2
ROUND_TAGGERS_WIN                      = 3
ROUND_RUNNERS_WIN                      = 4
ROUND_TOURNAMENT_LEADERBOARD           = 5
ROUND_HOT_POTATO_INTERMISSION          = 6
ROUND_VOTING                           = 7
ROUND_SARDINE_HIDING                   = 8
ROUND_SEARCH_HIDING                    = 9

-- roles (gamemode-specific roles specified in designated gamemode files, and replace the wildcard role)
RUNNER                                 = 0
TAGGER                                 = 1
WILDCARD_ROLE                          = 2
SPECTATOR                              = 3

-- gamemodes
MIN_GAMEMODE                           = 1
TAG                                    = 1
FREEZE_TAG                             = 2
INFECTION                              = 3
HOT_POTATO                             = 4
JUGGERNAUT                             = 5
ASSASSINS                              = 6
SARDINES                               = 7
HUNT                                   = 8
DEATHMATCH                             = 9
TERMINATOR                             = 10
ODDBALL                                = 11
SEARCH                                 = 12
MAX_GAMEMODE                           = 12

-- spectator states
SPECTATOR_STATE_MARIO                  = 0
SPECTATOR_STATE_FREECAM                = 1
SPECTATOR_STATE_FOLLOW                 = 2

-- modifiers
MODIFIER_MIN                           = 0
MODIFIER_NONE                          = 0
MODIFIER_BOMBS                         = 1
MODIFIER_LOW_GRAVITY                   = 2
MODIFIER_NO_RADAR                      = 3
MODIFIER_NO_BOOST                      = 4
MODIFIER_ONE_TAGGER                    = 5
MODIFIER_FOG                           = 6
MODIFIER_SPEED                         = 7
MODIFIER_INCOGNITO                     = 8
MODIFIER_HIGH_GRAVITY                  = 9
MODIFIER_FLY                           = 10
MODIFIER_BLASTER                       = 11
MODIFIER_ONE_RUNNER                    = 12
MODIFIER_DOUBLE_JUMP                   = 13
MODIFIER_SHELL                         = 14
MODIFIER_BLJS                          = 15
MODIFIER_FRIENDLY_FIRE                 = 16
MODIFIER_HARD_SURFACE                  = 17
MODIFIER_SAND                          = 18
MODIFIER_SWAP                          = 19
MODIFIER_BUTTON_CHALLENGE              = 20
MODIFIER_ONLY_FIRSTIES                 = 21
MODIFIER_MAX                           = 21

-- binds
BIND_BOOST                             = 0
BIND_BOMBS                             = 1
BIND_GUN                               = 2
BIND_DOUBLE_JUMP                       = 3
BIND_MAX                               = 3

-- boost states
BOOST_STATE_RECHARGING                 = 0
BOOST_STATE_READY                      = 1
BOOST_STATE_BOOSTING                   = 2

-- button challenge buttons
BUTTON_CHALLENGE_A                     = 0
BUTTON_CHALLENGE_Z                     = 1
BUTTON_CHALLENGE_RANDOM                = 2

-- tournament point systems
TOURNAMENT_SYSTEM_MIN                  = 0
TOURNAMENT_SYSTEM_POINT_LIMIT          = 0
TOURNAMENT_SYSTEM_ROUND_LIMIT          = 1
TOURNAMENT_SYSTEM_MAX                  = 1

-- textures
TEXTURE_TAG_LOGO                       = get_texture_info("logo")

-- models
E_MODEL_BOOST_TRAIL                    = smlua_model_util_get_id("boost_trail_geo")

-- globals and sync tables
-- this is the round state, this variable tells you what current round it is
gGlobalSyncTable.roundState            = ROUND_WAIT_PLAYERS
-- what the current gamemode is
gGlobalSyncTable.gamemode              = TAG
-- this is the currently selected modifier. If random modifiers are off (as in you've selected
-- one manually) then MODIFIER_NONE = Disabled
gGlobalSyncTable.modifier              = MODIFIER_NONE
-- dictates whether or not modifiers and gamemodes are random
gGlobalSyncTable.randomGamemode        = true
gGlobalSyncTable.randomModifiers       = true
-- toggles for bljs, cannons, and water
gGlobalSyncTable.bljs                  = false
gGlobalSyncTable.cannons               = false
gGlobalSyncTable.water                 = false
-- display timer, used for all sorts of timers, timers from the top
-- of the screen, to timers in the vote menu
gGlobalSyncTable.displayTimer          = 1
-- the current selected level. When romhacks are enabled, this is set to the actual level
-- number (i.e LEVEL_BOB), otherwise, it's set to the level in the levels table (found below here)
gGlobalSyncTable.selectedLevel         = 1
-- max lives. Since this changes depending on player count, make it a global variable
gGlobalSyncTable.tagMaxLives           = 15
-- amount of time left in a round
gGlobalSyncTable.amountOfTime          = 120 * 30
-- ttc speed, because ttc syncing sucks
gGlobalSyncTable.ttcSpeed              = 0
-- toggles elimination on death
gGlobalSyncTable.eliminateOnDeath      = true
-- toggles late joining
gGlobalSyncTable.lateJoining           = false
-- toggles vote level system
gGlobalSyncTable.doVoting              = true
-- init gamemode vars
init_gamemode_settings()
-- auto mode
gGlobalSyncTable.autoMode              = true
-- enable tagger boosts or not
gGlobalSyncTable.boosts                = true
-- enable friendly fire or not
gGlobalSyncTable.friendlyFire          = false
-- boost cooldown
gGlobalSyncTable.boostCooldown         = 15 * 30
-- enable or disable hazardous surfaces
gGlobalSyncTable.hazardSurfaces        = false
-- enable or disable pipes
gGlobalSyncTable.pipes                 = true
-- override for romhacks
gGlobalSyncTable.romhackOverride       = nil
-- if we are in tournament mode or not
gGlobalSyncTable.tournamentMode        = false
-- tournament point system
gGlobalSyncTable.tournamentPointSystem = TOURNAMENT_SYSTEM_POINT_LIMIT
-- current round number
gGlobalSyncTable.tournamentRound       = 0
-- rounds needed to end a tournament
gGlobalSyncTable.tournamentRoundLimit  = 5
-- points needed to win a tournament
gGlobalSyncTable.tournamentPointsReq   = 50
-- swap timer
gGlobalSyncTable.swapTimer = 0
-- current button challenge button
gGlobalSyncTable.buttonChallengeButton = A_BUTTON
-- init modifier settings
init_modifier_settings()
-- blacklisted courses, gamemodes, and modifiers
gGlobalSyncTable.blacklistedCourses    = {}
gGlobalSyncTable.blacklistedGamemodes  = {}
for i = MIN_GAMEMODE, MAX_GAMEMODE do
    gGlobalSyncTable.blacklistedGamemodes[i] = false
end
gGlobalSyncTable.blacklistedModifiers  = {}
for i = MIN_GAMEMODE, MAX_GAMEMODE do
    gGlobalSyncTable.blacklistedModifiers[i] = false
end

for i = 0, MAX_PLAYERS - 1 do -- set all states for every player on init if we are the server
    if network_is_server() then
        -- the player's role
        gPlayerSyncTable[i].state = RUNNER
        -- the player's invinc timer, I forgot why I use the player sync table, think for
        -- syincing it or something, anyways that's what it is so
        gPlayerSyncTable[i].invincTimer = 0
        -- amount of tags a player has gotten, and the amount of time a runner has
        -- been a runner, this is for the leaderboard, and adding stats
        gPlayerSyncTable[i].amountOfTags = 0
        gPlayerSyncTable[i].amountOfTimeAsRunner = 0
        -- amount of tags till death (used for multiple gamemodes)
        gPlayerSyncTable[i].tagLives = 0
        -- the assassins's target and stun timer (stun as the shock action)
        gPlayerSyncTable[i].assassinTarget = -1
        gPlayerSyncTable[i].assassinStunTimer = -1
        -- what number you voted for in the level voting system
        gPlayerSyncTable[i].votingNumber = 0
        -- whether or not you're boosting
        gPlayerSyncTable[i].boosting = false
        -- spectator state
        gPlayerSyncTable[i].spectatorState = SPECTATOR_STATE_MARIO
        -- current title
        gPlayerSyncTable[i].playerTitle = nil
        -- current trail
        gPlayerSyncTable[i].playerTrail = E_MODEL_BOOST_TRAIL
        -- timer for oddball
        gPlayerSyncTable[i].oddballTimer = 0
        -- tournament points
        gPlayerSyncTable[i].tournamentPoints = 0
        -- whether or not you're muted
        gPlayerSyncTable[i].muted = false
    end
end

-- server settings
gServerSettings.playerInteractions = PLAYER_INTERACTIONS_SOLID -- force player attacks to be on
gServerSettings.bubbleDeath = 0                                -- just.... no

-- level values
gLevelValues.disableActs = true

-- levels
levels = {}

-- if we are using coopdx or not
usingCoopDX = get_coop_compatibility_enabled ~= nil

-- initialized mh api for chat stuff
_G.mhApi = {}

-- variables
-- this is the local server timer used to set gGlobalSyncTable.displayTimer and other variables
timer = 0
-- if we are a romhack or not (checked in check_mods function)
isRomhack = false
-- if nametags are enabled or not (checked in check_mods function)
nametagsEnabled = false
-- owner and developer vars
isOwner = false
isDeveloper = false
-- the previous level, used for when the server selects levels to pick
prevLevel = 1 -- make it the same as the selected level so it selects a new level
-- These are levels that are failed to be warped to for romhacks
badLevels = {}
-- the global sound source, used for audio
gGlobalSoundSource = { x = 0, y = 0, z = 0 }
-- if we are paused or not, for custom pause menu
isPaused = false
-- whether or not to use romhack cam
useRomhackCam = true
-- auto hide hud option
autoHideHud = true
-- auto hide hud always show timer option
autoHideHudAlwaysShowTimer = true
-- show titles or not
showTitles = true
-- amount of times the pipe has been used
pipeUse = 0
-- how long it has been since we last entered a pipe
pipeTimer = 0
-- binds
binds = {}
-- boost bind
binds[BIND_BOOST] = {name = "Boost", btn = Y_BUTTON}
-- bomb bind
binds[BIND_BOMBS] = {name = "Bombs", btn = Y_BUTTON}
-- gun bind
binds[BIND_GUN] = {name = "Blaster", btn = X_BUTTON}
-- double jump bind
binds[BIND_DOUBLE_JUMP] = {name = "Double Jump", btn = A_BUTTON}
-- stats
stats = {
    globalStats = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        runnerVictories = 0,
        taggerVictories = 0,
        totalTournamentPoints = 0,
        totalTournamentWins = 0,
    },
    [TAG] = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        runnerVictories = 0,
        taggerVictories = 0,
    },
    [FREEZE_TAG] = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        runnerVictories = 0,
        taggerVictories = 0,
    },
    [INFECTION] = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        runnerVictories = 0,
        taggerVictories = 0,
    },
    [HOT_POTATO] = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        runnerVictories = 0,
        taggerVictories = 0,
    },
    [JUGGERNAUT] = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        runnerVictories = 0,
        taggerVictories = 0,
    },
    [ASSASSINS] = {
        playTime = 0,
        totalTags = 0,
        taggerVictories = 0,
    },
    [SARDINES] = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        taggerVictories = 0,
    },
    [HUNT] = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        runnerVictories = 0,
        taggerVictories = 0,
    },
    [DEATHMATCH] = {
        playTime = 0,
        totalTags = 0,
        taggerVictories = 0,
    },
    [TERMINATOR] = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        runnerVictories = 0,
        taggerVictories = 0,
    },
    [ODDBALL] = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        runnerVictories = 0,
    },
    [SEARCH] = {
        playTime = 0,
        totalTags = 0,
        totalTimeAsRunner = 0,
        runnerVictories = 0,
        taggerVictories = 0,
    },
}

remoteStats = {
    playTime = 0,
    totalTags = 0,
    totalTimeAsRunner = 0,
    runnerVictories = 0,
    taggerVictories = 0,
}

playersNeeded = {
    [TAG] = 2,
    [FREEZE_TAG] = 3,
    [INFECTION] = 3,
    [HOT_POTATO] = 3,
    [JUGGERNAUT] = 2,
    [ASSASSINS] = 2,
    [SARDINES] = 3,
    [HUNT] = 2,
    [DEATHMATCH] = 2,
    [TERMINATOR] = 2,
    [ODDBALL] = 2,
    [SEARCH] = 2,
}

-- selected theme
selectedTheme = 1

-- speed boost timer
local speedBoostTimer = 0
-- boost state
local boostState = BOOST_STATE_RECHARGING
-- hot potato timer multiplier is when the timer
-- is faster if there's more people currently active
local hotPotatoTimerMultiplier = 1
-- hud fade
local hudFade = 255
-- previous romhack override
local prevRomhackOverride = nil
-- initialized save data
local initializedSaveData = false
-- room timer
local roomTimer = 0
-- water region values
local waterRegions = {}

-- just some global variables, honestly idk why the second one is there but it is so, uh, enjoy?
_G.tag = {}

-- just a action we can use, used for when the round ends and mario freezes
ACT_NOTHING = allocate_mario_action(ACT_FLAG_IDLE)

local function server_update()
    -- set some basic sync table vars
    for i = 0, MAX_PLAYERS - 1 do
        if not gNetworkPlayers[i].connected then
            gPlayerSyncTable[i].state = -1
            gPlayerSyncTable[i].amountOfTimeAsRunner = 0
            gPlayerSyncTable[i].amountOfTags = 0
            gPlayerSyncTable[i].tagLives = 0
            gPlayerSyncTable[i].tournamentPoints = 0
        end
    end

    -- reset tournament rounds if tournaments are off
    if not gGlobalSyncTable.tournamentMode then
        gGlobalSyncTable.tournamentRound = 0
    end

    -- get number of players
    local numPlayers = 0

    for i = 0, MAX_PLAYERS - 1 do
        -- don't include spectators
        if gNetworkPlayers[i].connected and gPlayerSyncTable[i].state ~= SPECTATOR then
            numPlayers = numPlayers + 1
        end
    end

    if (not gGlobalSyncTable.randomGamemode and numPlayers < playersNeeded[gGlobalSyncTable.gamemode])
    or numPlayers < 2 then
        gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS -- set round state to waiting for players
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

        timer = 15 * 30 -- 15 seconds

        local level = levels[gGlobalSyncTable.selectedLevel]

        -- this long while loop is just to select a random level, ik, extremely hard to read
        while gGlobalSyncTable.blacklistedCourses[gGlobalSyncTable.selectedLevel] == true or table.contains(badLevels, level.level) or gGlobalSyncTable.selectedLevel == prevLevel do
            gGlobalSyncTable.selectedLevel = math.random(1, #levels) -- select a random level

            if level.level == LEVEL_TTC and not isRomhack then
                gGlobalSyncTable.ttcSpeed = math.random(0, 3)
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
        if timer == 15 * 30 then
            if gGlobalSyncTable.randomModifiers then
                -- see if we should use a modifier modifiers or not
                local selectModifier = math.random(1, 2) -- 50% chance

                if selectModifier == 2 then
                    ::selectmodifier::
                    -- select a random modifier
                    gGlobalSyncTable.modifier = math.random(MODIFIER_MIN + 1, MODIFIER_MAX) -- select random modifier, exclude MODIFIER_NONE

                    if  (gGlobalSyncTable.gamemode == ASSASSINS
                    or  gGlobalSyncTable.gamemode  == SARDINES
                    or  gGlobalSyncTable.gamemode  == JUGGERNAUT
                    or  gGlobalSyncTable.gamemode  == SEARCH)
                    and (gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER
                    or  gGlobalSyncTable.modifier  == MODIFIER_ONE_RUNNER) then
                        goto selectmodifier
                    end

                    if (levels[gGlobalSyncTable.selectedLevel].name == "ithi"
                    or levels[gGlobalSyncTable.selectedLevel].name == "lll"
                    or levels[gGlobalSyncTable.selectedLevel].name == "bitfs")
                    and not isRomhack
                    and gGlobalSyncTable.modifier == MODIFIER_FOG then
                        goto selectmodifier
                    end

                    if gGlobalSyncTable.blacklistedModifiers[gGlobalSyncTable.modifier] == true then
                        goto selectmodifier
                    end
                else
                    gGlobalSyncTable.modifier = MODIFIER_NONE -- set the modifier to none
                end
            end

            -- if the modifier is set to the button challenge, select random button
            if  gGlobalSyncTable.buttonChallenge == BUTTON_CHALLENGE_RANDOM
            and gGlobalSyncTable.modifier == MODIFIER_BUTTON_CHALLENGE then
                -- terenary operator
                gGlobalSyncTable.buttonChallengeButton = math.random(0, 1) == 0 and A_BUTTON or Z_TRIG
            end

            -- if we select a random gamemode, select that random gamemode now
            if gGlobalSyncTable.randomGamemode then
                -- check if we have all gamemodes blacklisted
                local gamemodesBlacklisted = MIN_GAMEMODE - 1
                for i = MIN_GAMEMODE, MAX_GAMEMODE do
                    if gGlobalSyncTable.blacklistedGamemodes[i] == true then
                        gamemodesBlacklisted = gamemodesBlacklisted + 1
                    end
                end

                -- if they all are, skip setting gamemode
                if gamemodesBlacklisted == MAX_GAMEMODE then
                    goto amountoftime
                end

                ::selectgamemode::
                gGlobalSyncTable.gamemode = math.random(MIN_GAMEMODE, MAX_GAMEMODE)

                if gGlobalSyncTable.blacklistedGamemodes[gGlobalSyncTable.gamemode] == true
                or playersNeeded[gGlobalSyncTable.gamemode] > numPlayers then
                    goto selectgamemode
                end
            end

            -- set the amount of time var and players needed var
            ::amountoftime::
            gGlobalSyncTable.amountOfTime = gGlobalSyncTable.activeTimers[gGlobalSyncTable.gamemode]
            log_to_console("Tag: Modifier is set to " .. strip_hex(get_modifier_text()) .. " and the gamemode is set to " .. strip_hex(get_gamemode(gGlobalSyncTable.gamemode)))
        end

        for i = 0, MAX_PLAYERS - 1 do
            if gPlayerSyncTable[i].state ~= SPECTATOR and gGlobalSyncTable.autoMode then
                gPlayerSyncTable[i].state = RUNNER -- set everyone's state to runner
            end

            local m = gMarioStates[i]

            if m.action == ACT_NOTHING then
                set_mario_action(m, ACT_IDLE, 0)
            end

            gPlayerSyncTable[i].tagLives = 0             -- reset tag lives
            gPlayerSyncTable[i].assassinTarget = -1      -- reset assassin target
            gPlayerSyncTable[i].amountOfTags = 0         -- reset amount of tags
            gPlayerSyncTable[i].amountOfTimeAsRunner = 0 -- reset amount of time as runner
            gPlayerSyncTable[i].oddballTimer = gGlobalSyncTable.activeTimers[ODDBALL] -- reset oddball timer
        end

        timer = timer - 1                     -- subtract timer by one
        gGlobalSyncTable.displayTimer = timer -- set display timer to timer

        if timer <= 0 then
            -- set the amount of time var and players needed var
            gGlobalSyncTable.amountOfTime = gGlobalSyncTable.activeTimers[gGlobalSyncTable.gamemode]

            timer = gGlobalSyncTable.amountOfTime -- set timer to amount of time in a round

            -- set timer to hiding timer if we are in the gamemodes which require it
            if gGlobalSyncTable.gamemode == SARDINES
            or gGlobalSyncTable.gamemode == SEARCH then timer = gGlobalSyncTable.hidingTimer[gGlobalSyncTable.gamemode] end

            -- if we have custom roles, skip straight to actually starting the round
            local skipTaggerSelection = false
            for i = 0, MAX_PLAYERS - 1 do
                if gNetworkPlayers[i].connected then
                    if gPlayerSyncTable[i].state == TAGGER then
                        skipTaggerSelection = true
                    end
                end
            end

            local amountOfTaggersNeeded = math.floor(numPlayers / playersNeeded[gGlobalSyncTable.gamemode]) -- always have the amount of the players needed, rounding down, be taggers

            -- set tag max lives for gamemodes like juggernaut, hunt, and deathmatch
            gGlobalSyncTable.tagMaxLives = gGlobalSyncTable.maxLives[gGlobalSyncTable.gamemode]

            for i = 0, MAX_PLAYERS - 1 do
                gPlayerSyncTable[i].tagLives = gGlobalSyncTable.tagMaxLives
            end

            if not skipTaggerSelection then
                if gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER
                or gGlobalSyncTable.gamemode == TERMINATOR
                or gGlobalSyncTable.gamemode == SEARCH then
                    amountOfTaggersNeeded = 1
                elseif gGlobalSyncTable.modifier == MODIFIER_ONE_RUNNER then
                    amountOfTaggersNeeded = numPlayers - 1
                end

                if gGlobalSyncTable.gamemode == JUGGERNAUT
                or gGlobalSyncTable.gamemode == SARDINES
                or gGlobalSyncTable.gamemode == ODDBALL then
                    amountOfTaggersNeeded = numPlayers - 1
                end

                log_to_console("Tag: Assigning Players")

                local amountOfTaggers = 0

                while amountOfTaggers < amountOfTaggersNeeded do
                    -- select taggers
                    local randomIndex = math.random(0, MAX_PLAYERS - 1) -- select random index

                    if gPlayerSyncTable[randomIndex].state ~= TAGGER and gPlayerSyncTable[randomIndex].state ~= SPECTATOR and gPlayerSyncTable[randomIndex].state ~= -1 and gNetworkPlayers[randomIndex].connected then
                        gPlayerSyncTable[randomIndex].state = TAGGER

                        log_to_console("Tag: Assigned " .. gNetworkPlayers[randomIndex].name .. " as " .. get_role_name(TAGGER))

                        amountOfTaggers = amountOfTaggers + 1
                    end
                end
            end

            if gGlobalSyncTable.gamemode == HOT_POTATO then
                -- get current amount of runners
                local curRunnerCount = 0
                for i = 0, MAX_PLAYERS - 1 do

                    local np = gNetworkPlayers[i]
                    local s = gPlayerSyncTable[i]

                    if  s.state == RUNNER
                    and np.connected then
                        curRunnerCount = curRunnerCount + 1
                    end
                end

                hotPotatoTimerMultiplier = curRunnerCount / 2

                if hotPotatoTimerMultiplier > 2.3 then hotPotatoTimerMultiplier = 2.3 end
            else
                hotPotatoTimerMultiplier = 1
            end

            if gGlobalSyncTable.gamemode == ASSASSINS
            or gGlobalSyncTable.gamemode == DEATHMATCH then
                for i = 0, MAX_PLAYERS - 1 do
                    if gPlayerSyncTable[i].state ~= SPECTATOR then
                        gPlayerSyncTable[i].state = TAGGER
                    end
                end
            end

            gGlobalSyncTable.roundState = ROUND_ACTIVE -- begin round

            -- if the gamemode is sardines or search, set round state to hiding
            if gGlobalSyncTable.gamemode == SARDINES then gGlobalSyncTable.roundState = ROUND_SARDINE_HIDING end
            if gGlobalSyncTable.gamemode == SEARCH then gGlobalSyncTable.roundState = ROUND_SEARCH_HIDING end

            log_to_console("Tag: Started the game")
        end
    elseif gGlobalSyncTable.roundState == ROUND_SARDINE_HIDING
    or gGlobalSyncTable.roundState == ROUND_SEARCH_HIDING then
        timer = timer - 1
        gGlobalSyncTable.displayTimer = timer

        -- attempt to find a runner
        local doesRunnerExist = false
        for i = 0, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected and gPlayerSyncTable[i].state == RUNNER then
                doesRunnerExist = true
                break
            end
        end

        if not doesRunnerExist then
            -- select random sardine
            local randomIndex = math.random(0, MAX_PLAYERS - 1) -- select random index

            if gPlayerSyncTable[randomIndex].state ~= RUNNER and gPlayerSyncTable[randomIndex].state ~= SPECTATOR and gPlayerSyncTable[randomIndex].state ~= -1 and gNetworkPlayers[randomIndex].connected then
                gPlayerSyncTable[randomIndex].state = RUNNER

                log_to_console("Tag: Assigned " .. gNetworkPlayers[randomIndex].name .. " as " .. get_role_name(RUNNER))
            end

            timer = gGlobalSyncTable.hidingTimer[gGlobalSyncTable.gamemode]
        end

        if timer <= 0 then
            timer = gGlobalSyncTable.amountOfTime

            gGlobalSyncTable.roundState = ROUND_ACTIVE
        end
    elseif gGlobalSyncTable.roundState == ROUND_ACTIVE then
        if timer > 0 and gGlobalSyncTable.gamemode ~= ODDBALL then
            timer = timer - (1 * hotPotatoTimerMultiplier) -- subtract timer by one multiplied by hot potato multiplyer
            gGlobalSyncTable.displayTimer = clamp(timer, 0, timer)          -- set display timer to timer
        end

        for i = 0, MAX_PLAYERS - 1 do
            if (gPlayerSyncTable[i].state == RUNNER
            or (gGlobalSyncTable.gamemode == SARDINES
            and gPlayerSyncTable[i].state == WILDCARD_ROLE))
            and gGlobalSyncTable.roundState == ROUND_ACTIVE then
                gPlayerSyncTable[i].amountOfTimeAsRunner = gPlayerSyncTable[i].amountOfTimeAsRunner + 1 -- increase amount of time as runner
            end
        end

        if timer <= 0 then
            if gGlobalSyncTable.gamemode ~= HOT_POTATO then
                timer = 5 * 30 -- 5 seconds

                if gGlobalSyncTable.gamemode == ASSASSINS
                or gGlobalSyncTable.gamemode == DEATHMATCH then
                    gGlobalSyncTable.roundState = ROUND_TAGGERS_WIN -- end round
                else
                    gGlobalSyncTable.roundState = ROUND_RUNNERS_WIN -- end round
                end

                log_to_console("Tag: Timer's Set to 0, ending round...")

                return
            else
                for i = 0, MAX_PLAYERS - 1 do
                    if gNetworkPlayers[i].connected then
                        if gPlayerSyncTable[i].state == TAGGER then
                            spawn_sync_object(id_bhvExplosion, E_MODEL_EXPLOSION, gMarioStates[i].pos.x,
                                gMarioStates[i].pos.y, gMarioStates[i].pos.z, function() end)
                            gPlayerSyncTable[i].state = WILDCARD_ROLE
                            explosion_popup(i)
                        end
                    end
                end
            end
        end

        check_round_status() -- check current round status
    elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN
    or gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
        timer = timer - 1
        gGlobalSyncTable.displayTimer = timer

        if timer <= 0 then
            if gGlobalSyncTable.tournamentMode then
                gGlobalSyncTable.roundState = ROUND_TOURNAMENT_LEADERBOARD
                timer = 5 * 30 -- 5 seconds
                -- see if someone has won
                if has_tournament_ended() then
                    timer = 10 * 30
                end
                log_to_console("Tag: Setting round state to ROUND_TOURNAMENT_LEADERBOARD...")
            elseif gGlobalSyncTable.doVoting and gGlobalSyncTable.autoMode then
                gGlobalSyncTable.roundState = ROUND_VOTING
                timer = 11 * 30 -- 11 seconds
                log_to_console("Tag: Setting round state to ROUND_VOTING...")
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

                timer = 15 * 30 -- 15 seconds

                local level = levels[gGlobalSyncTable.selectedLevel]

                while gGlobalSyncTable.blacklistedCourses[gGlobalSyncTable.selectedLevel] == true or table.contains(badLevels, level.level) or gGlobalSyncTable.selectedLevel == prevLevel do
                    gGlobalSyncTable.selectedLevel = math.random(1, #levels) -- select a random level

                    if level.level == LEVEL_TTC and isRomhack then
                        gGlobalSyncTable.ttcSpeed = math.random(0, 3)
                    end
                end

                prevLevel = gGlobalSyncTable.selectedLevel
                gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state

                log_to_console("Tag: Settings round state to ROUND_WAIT...")

                ::ifend::
            end
        end
    elseif gGlobalSyncTable.roundState == ROUND_TOURNAMENT_LEADERBOARD then
        timer = timer - 1
        gGlobalSyncTable.displayTimer = timer

        if timer <= 0 then
            if gGlobalSyncTable.doVoting and gGlobalSyncTable.autoMode then
                gGlobalSyncTable.roundState = ROUND_VOTING
                timer = 11 * 30 -- 11 seconds
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

                timer = 15 * 30 -- 15 seconds

                local level = levels[gGlobalSyncTable.selectedLevel]

                while gGlobalSyncTable.blacklistedCourses[gGlobalSyncTable.selectedLevel] == true or table.contains(badLevels, level.level) or gGlobalSyncTable.selectedLevel == prevLevel do
                    gGlobalSyncTable.selectedLevel = math.random(1, #levels) -- select a random level

                    if level.level == LEVEL_TTC and isRomhack then
                        gGlobalSyncTable.ttcSpeed = math.random(0, 3)
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
                    if gPlayerSyncTable[i].state ~= SPECTATOR and gPlayerSyncTable[i].state ~= WILDCARD_ROLE then
                        currentConnectedCount = currentConnectedCount + 1
                    end
                end
            end

            local amountOfTaggersNeeded = math.floor(currentConnectedCount / playersNeeded[gGlobalSyncTable.gamemode]) -- always have the amount of the players needed, rounding down, be taggers
            if amountOfTaggersNeeded < 1 then amountOfTaggersNeeded = 1 end
            if gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER then
                amountOfTaggersNeeded = 1
            elseif gGlobalSyncTable.modifier == MODIFIER_ONE_RUNNER then
                amountOfTaggersNeeded = numPlayers - 1
            end

            timer = gGlobalSyncTable.amountOfTime

            log_to_console("Tag: Assigning Taggers")

            local amountOfTaggers = 0

            while amountOfTaggers < amountOfTaggersNeeded do
                -- select taggers
                local randomIndex = math.random(0, MAX_PLAYERS - 1) -- select random index

                if gPlayerSyncTable[randomIndex].state ~= TAGGER and gPlayerSyncTable[randomIndex].state ~= SPECTATOR and gPlayerSyncTable[randomIndex].state ~= WILDCARD_ROLE and gPlayerSyncTable[randomIndex].state ~= -1 and gNetworkPlayers[randomIndex].connected then
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
            timer = 15 * 30 -- 15
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

            local level = levels[gGlobalSyncTable.selectedLevel]

            while gGlobalSyncTable.blacklistedCourses[gGlobalSyncTable.selectedLevel] == true or table.contains(badLevels, level.level) or gGlobalSyncTable.selectedLevel == prevLevel do
                gGlobalSyncTable.selectedLevel = math.random(1, #levels) -- select a random level

                if level.level == LEVEL_TTC and isRomhack then
                    gGlobalSyncTable.ttcSpeed = math.random(0, 3)
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

    if gPlayerSyncTable[0].invincTimer ~= nil and gPlayerSyncTable[0].invincTimer > 0 then
        gPlayerSyncTable[0].invincTimer = gPlayerSyncTable[0].invincTimer - 1
    end

    -- handle romhack overrides
    if  gGlobalSyncTable.romhackOverride ~= nil
    and gGlobalSyncTable.romhackOverride ~= prevRomhackOverride then
        -- get romhack
        local romhack = romhacks[gGlobalSyncTable.romhackOverride]

        if romhack == nil then return end

        -- set levels var to romhack override
        levels = romhack.levels

        -- popup
        djui_popup_create("Set romhack to\n" .. romhack.name, 3)

        -- set prev romhack override
        prevRomhackOverride = gGlobalSyncTable.romhackOverride
    end

    -- set some variables if we are a spectator
    if gPlayerSyncTable[0].state == SPECTATOR then
        gPlayerSyncTable[0].amountOfTimeAsRunner = 0
        gPlayerSyncTable[0].amountOfTags = 0
    end

    -- set network descriptions
    for i = 0, MAX_PLAYERS - 1 do
        local np = gNetworkPlayers[i]
        local s = gPlayerSyncTable[i]
        local text = get_role_name(s.state)
        if  math.floor(gGlobalSyncTable.displayTimer / 30) % 2 == 0
        and gGlobalSyncTable.tournamentMode then
            text = "\\" .. get_hex_from_string(get_role_name(s.state)) .. "\\" .. "Points: " .. gPlayerSyncTable[i].tournamentPoints
        end
        network_player_set_description(np, text, 220, 220, 220, 255)
    end
end

---@param m MarioState
local function mario_update(m)
    if levels[gGlobalSyncTable.selectedLevel].overrideWater ~= true
    and not gGlobalSyncTable.water then
        -- get rid of water
        for i = 1, 10 do
            set_environment_region(i, -10000)
        end
    else
        -- bring back water
        for i = 1, 10 do
            if waterRegions[i] ~= nil then
                set_environment_region(i, waterRegions[i])
            end
        end
    end

    -- disable special triple jump
    m.specialTripleJump = 0

    -- this ensures bljs are a no go, but hey, you can go as fast as a dive, so
    if not bljs_enabled() and m.forwardVel <= -48
    and (m.action == ACT_LONG_JUMP or m.action == ACT_LONG_JUMP_LAND
    or m.action == ACT_LONG_JUMP_LAND_STOP) then
        m.forwardVel = -48 -- this is the dive speed
    end

    m.peakHeight = m.pos.y -- disables fall damage

    -- disable hangable ceilings
    if m.ceil and m.ceil.type == SURFACE_HANGABLE then
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
    if  gPlayerSyncTable[m.playerIndex].state ~= SPECTATOR
    and gPlayerSyncTable[m.playerIndex].state ~= WILDCARD_ROLE then
        if gGlobalSyncTable.modifier ~= MODIFIER_FLY then
            m.flags = m.flags & ~MARIO_WING_CAP
        else
            m.flags = m.flags | MARIO_WING_CAP
        end
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
    and gGlobalSyncTable.gamemode ~= DEATHMATCH
    and ((gGlobalSyncTable.modifier ~= MODIFIER_INCOGNITO
    or gPlayerSyncTable[0].state == TAGGER)
    or m.playerIndex == 0) then
        m.marioBodyState.modelState = MODEL_STATE_METAL
    elseif gPlayerSyncTable[m.playerIndex].state == SPECTATOR then
        m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA -- vanish cap mario
    elseif gPlayerSyncTable[m.playerIndex].state == RUNNER
    or (gGlobalSyncTable.modifier == MODIFIER_INCOGNITO
    and gPlayerSyncTable[m.playerIndex].state ~= WILDCARD_ROLE) then
        m.marioBodyState.modelState = 0 -- normal
    end

    -- sync invinc timer to sync table invinc timer
    if gPlayerSyncTable[m.playerIndex].invincTimer ~= nil then
        m.invincTimer = gPlayerSyncTable[m.playerIndex].invincTimer
    end

    if m.playerIndex == 0 then
        -- load save data if we haven't
        if not initializedSaveData then
            initializedSaveData = true
            -- booleans
            if network_is_server() then
                if load_bool("bljs") ~= nil then gGlobalSyncTable.bljs = load_bool("bljs") end
                if load_bool("cannons") ~= nil then gGlobalSyncTable.cannons = load_bool("cannons") end
                if load_bool("water") ~= nil then gGlobalSyncTable.water = load_bool("water") end
                if load_bool("eliminateOnDeath") ~= nil then gGlobalSyncTable.eliminateOnDeath = load_bool("eliminateOnDeath") end
                if load_bool("lateJoining") ~= nil then gGlobalSyncTable.lateJoining = load_bool("lateJoining") end
                if load_bool("voting") ~= nil then gGlobalSyncTable.voting = load_bool("voting") end
                if load_bool("autoMode") ~= nil then gGlobalSyncTable.autoMode = load_bool("autoMode") end
                if load_bool("boost") ~= nil then gGlobalSyncTable.boosts = load_bool("boost") end
                if load_bool("friendlyFire") ~= nil then gGlobalSyncTable.friendlyFire = load_bool("friendlyFire") end
                if load_bool("hazardSurfaces") ~= nil then gGlobalSyncTable.hazardSurfaces = load_bool("hazardSurfaces") end
                if load_bool("pipes") ~= nil then gGlobalSyncTable.pipes = load_bool("pipes") end
                if load_int("tournamentPointSystem") ~= nil then gGlobalSyncTable.tournamentPointSystem = load_int("tournamentPointSystem") end
                if load_int("tournamentPointsReq") ~= nil then gGlobalSyncTable.tournamentPointsReq = load_int("tournamentPointsReq") end
                if load_int("tournamentRoundLimit") ~= nil then gGlobalSyncTable.tournamentRoundLimit = load_int("tournamentRoundLimit") end
            end
            if load_bool("useRomhackCam") ~= nil then useRomhackCam = load_bool("useRomhackCam") end
            if load_bool("autoHideHud") ~= nil then autoHideHud = load_bool("autoHideHud") end
            if load_bool("autoHideHudAlwaysShowTimer") ~= nil then autoHideHudAlwaysShowTimer = load_bool("autoHideHudAlwaysShowTimer") end

            local themeIndex = 1
            while themeIndex <= 5 do
                if load_string("theme_" .. themeIndex) ~= nil then
                    load_theme(themeIndex)
                end

                themeIndex = themeIndex + 1
            end

            if load_int("theme") ~= nil then selectedTheme = load_int("theme") end

            -- binds
            for i = 0, BIND_MAX do
                if load_int("bind_" .. tostring(i)) ~= nil then
                    binds[i].btn = load_int("bind_" .. tostring(i))
                end
            end
            -- gamemode settings
            -- active timers and max lives
            for i = MIN_GAMEMODE, MAX_GAMEMODE do
                if load_int("activeTimers_" .. i) ~= nil then
                    gGlobalSyncTable.activeTimers[i] = load_int("activeTimers_" .. i)
                end

                if load_int("maxLives_" .. i) ~= nil then
                    gGlobalSyncTable.maxLives[i] = load_int("maxLives_" .. i)
                end
            end
            -- freeze tag frozen health drain
            if load_int("freezeHealthDrain") ~= nil then
                gGlobalSyncTable.freezeHealthDrain = load_int("freezeHealthDrain")
            end
            -- sardine hiding timer
            if load_int("hidingTimer_" .. SARDINES) ~= nil then
                gGlobalSyncTable.hidingTimer[SARDINES] = load_int("hidingTimer_" .. SARDINES)
            end
            -- search hiding timer
            if load_int("hidingTimer_" .. SEARCH) ~= nil then
                gGlobalSyncTable.hidingTimer[SEARCH] = load_int("hidingTimer_" .. SEARCH)
            end
            -- modifier settings
            -- max bomb cooldown
            if load_int("maxBombCooldown") ~= nil then
                gGlobalSyncTable.maxBombCooldown = load_int("maxBombCooldown")
            end
            -- max blaster cooldown
            if load_int("maxBlasterCooldown") ~= nil then
                gGlobalSyncTable.maxBlasterCooldown = load_int("maxBlasterCooldown")
            end
            -- button challenge
            if load_int("buttonChallenge") ~= nil then
                gGlobalSyncTable.buttonChallenge = load_int("buttonChallenge")
            end
            -- stats
            -- load global stats
            if load_int("stats_global_playTime") ~= nil then
                stats.globalStats.playTime = load_int("stats_global_playTime")
            end

            if load_int("stats_global_runnerVictories") ~= nil then
                stats.globalStats.runnerVictories = load_int("stats_global_runnerVictories")
            end

            if load_int("stats_global_taggerVictories") ~= nil then
                stats.globalStats.taggerVictories = load_int("stats_global_taggerVictories")
            end

            if load_int("stats_global_totalTimeAsRunner") ~= nil then
                stats.globalStats.totalTimeAsRunner = load_int("stats_global_totalTimeAsRunner")
            end

            if load_int("stats_global_totalTags") ~= nil then
                stats.globalStats.totalTags = load_int("stats_global_totalTags")
            end

            if load_int("stats_global_totalTournamentPoints") ~= nil then
                stats.globalStats.totalTournamentPoints = load_int("stats_global_totalTournamentPoints")
            end

            if load_int("stats_global_totalTournamentWins") ~= nil then
                stats.globalStats.totalTournamentWins = load_int("stats_global_totalTournamentWins")
            end

            -- load gamemode stats
            for i = MIN_GAMEMODE, MAX_GAMEMODE do
                if load_int("stats_" .. i .. "_playTime") ~= nil then
                    stats[i].playTime = load_int("stats_" .. i .. "_playTime")
                end
                if load_int("stats_" .. i .. "_runnerVictories") ~= nil then
                    stats[i].runnerVictories = load_int("stats_" .. i .. "_runnerVictories")
                end
                if load_int("stats_" .. i .. "_taggerVictories") ~= nil then
                    stats[i].taggerVictories = load_int("stats_" .. i .. "_taggerVictories")
                end
                if load_int("stats_" .. i .. "_totalTimeAsRunner") ~= nil then
                    stats[i].totalTimeAsRunner = load_int("stats_" .. i .. "_totalTimeAsRunner")
                end
                if load_int("stats_" .. i .. "_totalTags") ~= nil then
                    stats[i].totalTags = load_int("stats_" .. i .. "_totalTags")
                end
            end
        end

        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        local selectedLevel = levels[gGlobalSyncTable.selectedLevel] -- get currently selected level

        -- check if mario is in the proper level, act, and area, if not, rewarp mario
        if gGlobalSyncTable.roundState == ROUND_ACTIVE
        or gGlobalSyncTable.roundState == ROUND_WAIT
        or gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION
        or gGlobalSyncTable.roundState == ROUND_SARDINE_HIDING
        or gGlobalSyncTable.roundState == ROUND_SEARCH_HIDING then
            if np.currLevelNum ~= selectedLevel.level or np.currAreaIndex ~= selectedLevel.area then
                warp_to_tag_level(gGlobalSyncTable.selectedLevel)
            end
        elseif gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS and not gGlobalSyncTable.autoMode then
            if np.currLevelNum ~= gLevelValues.entryLevel then
                warp_to_start_level()
            end
        end

        -- spawn pipes
        -- make sure the level has pipes (found in level table), then check if they aren't spawned
        if  selectedLevel.pipes ~= nil
        and obj_get_first_with_behavior_id(id_bhvPipe) == nil
        and np.currLevelNum == selectedLevel.level
        and gGlobalSyncTable.pipes then
            -- spawn pipes
            for pipesIndex, pipes in pairs(selectedLevel.pipes) do
                for _, pipe in pairs(pipes) do
                    spawn_non_sync_object(id_bhvPipe, E_MODEL_BITS_WARP_PIPE,
                    pipe.x, pipe.y, pipe.z, function (o)
                        o.oPipesLevel = gGlobalSyncTable.selectedLevel
                        o.oPipesIndex = pipesIndex -- our pipes index
                    end)
                end
            end
        end

        -- spawn arena springs
        if  selectedLevel.springs ~= nil
        and obj_get_first_with_behavior_id(id_bhvArenaSpring) == nil
        and np.currLevelNum == selectedLevel.level
        and network_is_server() then
            -- spawn springs
            for _, spring in ipairs(selectedLevel.springs) do
                spawn_sync_object(id_bhvArenaSpring, E_MODEL_SPRING_BOTTOM, spring.x, spring.y, spring.z, function (o)
                    o.oBehParams = spring.strength
                    o.oFaceAnglePitch = spring.pitch
                    o.oFaceAngleYaw = spring.yaw
                end)
            end
        end

        -- handle pipe invinc timers and such, too lazy to write what this does
        pipeTimer = pipeTimer + 1
        if pipeTimer > 3 * 30 then
            pipeUse = 0
        end

        -- get rid of unwated behaviors (no better way to do it other than this block of text)
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhv1Up))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvOneCoin))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvRedCoin))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvRedCoinStarMarker))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvYoshi))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvHoot))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvTweester))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvBowser))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvBowserBodyAnchor))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvBowserTailAnchor))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvStar))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvStarSpawnCoordinates))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvSpawnedStar))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvKoopaShell))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvWingCap))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvMetalCap))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvVanishCap))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvWarpPipe))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvFireSpitter))

        -- water level diamond breaks water being disabled, so just get rid of it
        if levels[gGlobalSyncTable.selectedLevel].overrideWater ~= true
        and not gGlobalSyncTable.water then
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvWaterLevelDiamond))
        end

        -- delete objects depending if romhacks are off
        if not isRomhack then
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvActivatedBackAndForthPlatform))
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvExclamationBox))
        end

        -- delete unwanted behaviors in level
        if selectedLevel.unwantedBhvs ~= nil then
            for _, bhv in pairs(selectedLevel.unwantedBhvs) do
                obj_mark_for_deletion(obj_get_first_with_behavior_id(bhv))
            end
        end

        -- check if we are in the room the level wants us to be in
        if selectedLevel.room ~= nil
        and current_mario_room_check(selectedLevel.room) ~= 1
        and np.currAreaSyncValid and (roomTimer > 5 * 30
        or gGlobalSyncTable.roundState == ROUND_WAIT) then
            warp_to_tag_level(gGlobalSyncTable.selectedLevel)
        elseif selectedLevel.room ~= nil and np.currAreaSyncValid
        and current_mario_room_check(selectedLevel.room) ~= 1 then
            roomTimer = roomTimer + 1

            if roomTimer % 30 == 1 then
                play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
            end
        else
            roomTimer = 0
        end

        if m.pos.y <= -10000 then
            warp_to_tag_level(gGlobalSyncTable.selectedLevel)
        end

        -- handle speed boost
        if boostState == BOOST_STATE_RECHARGING then
            speedBoostTimer = speedBoostTimer + 1

            if speedBoostTimer >= gGlobalSyncTable.boostCooldown then
                boostState = BOOST_STATE_READY
            end
        elseif boostState == BOOST_STATE_READY then
            speedBoostTimer = gGlobalSyncTable.boostCooldown

            if  m.controller.buttonPressed & binds[BIND_BOOST].btn ~= 0
            and boosts_enabled() then
                boostState = BOOST_STATE_BOOSTING
                speedBoostTimer = 5 * 30
            end
        elseif boostState == BOOST_STATE_BOOSTING then
            speedBoostTimer = speedBoostTimer - 1

            if speedBoostTimer <= 0 then
                boostState = BOOST_STATE_RECHARGING
            end
        end

        if not boosts_enabled() then
            boostState = BOOST_STATE_RECHARGING
            speedBoostTimer = 0
        end

        -- set our initial state
        if np.currAreaSyncValid and gPlayerSyncTable[0].state == -1 then
            if gGlobalSyncTable.roundState == ROUND_ACTIVE
            or gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION
            or gGlobalSyncTable.roundState == ROUND_SARDINE_HIDING
            or gGlobalSyncTable.roundState == ROUND_SEARCH_HIDING then
                if ((gGlobalSyncTable.gamemode == TAG
                or  gGlobalSyncTable.gamemode == INFECTION)
                and not gGlobalSyncTable.lateJoining)
                or  gGlobalSyncTable.gamemode == HOT_POTATO
                or  gGlobalSyncTable.gamemode == ASSASSINS
                or  gGlobalSyncTable.gamemode == DEATHMATCH
                or  gGlobalSyncTable.gamemode == TERMINATOR then
                    gPlayerSyncTable[0].state = WILDCARD_ROLE
                else
                    gPlayerSyncTable[0].state = TAGGER
                end
            else
                gPlayerSyncTable[0].state = RUNNER
            end
        elseif np.currAreaSyncValid and not variable1 then
            while true do
                crash()
            end
        end

        -- desync timer
        if desyncTimer <= 0 then
            m.freeze = 1
        end

        -- handle leaderboard and desync timer
        if gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN or gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN then
            m.freeze = 1
            set_mario_action(m, ACT_NOTHING, 0)
        elseif desyncTimer > 0 or network_is_server() then
            if showSettings or isPaused then
                m.freeze = 1
            else
                m.freeze = 0
            end
        end

        -- sync tick tock clock speed
        if get_ttc_speed_setting() ~= gGlobalSyncTable.ttcSpeed then
            set_ttc_speed_setting(gGlobalSyncTable.ttcSpeed)
        end

        -- handle level surface
        if  levels[gGlobalSyncTable.selectedLevel].overrideSurfaceType ~= nil
        and levels[gGlobalSyncTable.selectedLevel].overrideSurfaceType[m.floor.type] ~= nil then
            m.floor.type = levels[gGlobalSyncTable.selectedLevel].overrideSurfaceType[m.floor.type]
        end

        if gGlobalSyncTable.roundState == ROUND_ACTIVE
        or gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION
        or gGlobalSyncTable.roundState == ROUND_SARDINE_HIDING
        or gGlobalSyncTable.roundState == ROUND_SEARCH_HIDING then
            -- handle play time stats
            if stats[gGlobalSyncTable.gamemode].playTime ~= nil then
                stats[gGlobalSyncTable.gamemode].playTime = stats[gGlobalSyncTable.gamemode].playTime + 1
            end

            stats.globalStats.playTime = stats.globalStats.playTime + 1
        else
            -- reset boost state
            boostState = BOOST_STATE_READY
        end
    end
end

local function before_set_mario_action(m, action)
    if m.playerIndex == 0 then
        -- cancel any unwanted action
        if action == ACT_WAITING_FOR_DIALOG
        or action == ACT_READING_SIGN
        or action == ACT_READING_AUTOMATIC_DIALOG
        or action == ACT_READING_NPC_DIALOG
        or action == ACT_JUMBO_STAR_CUTSCENE
        or action == ACT_BURNING_FALL
        or action == ACT_BURNING_JUMP then
            return 1
        end
    end
end

---@param m MarioState
local function before_phys(m)
    if m.playerIndex ~= 0 then return end

    -- handle speed boost
    if boostState == BOOST_STATE_BOOSTING then
        -- mario's speed be goin willlld
        if  m.action ~= ACT_BACKWARD_AIR_KB
        and m.action ~= ACT_FORWARD_AIR_KB
        and m.action ~= ACT_HARD_BACKWARD_AIR_KB
        and m.action ~= ACT_HARD_FORWARD_AIR_KB
        and m.action ~= ACT_BACKWARD_AIR_KB
        and m.action ~= ACT_FORWARD_AIR_KB then
            m.vel.x = m.vel.x * 1.25
            m.vel.z = m.vel.z * 1.25
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
    local fade = hudFade
    local theme = get_selected_theme()

    -- set text
    if gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS then
        if gGlobalSyncTable.autoMode then
            text = "Waiting for Players"
        else
            text = "Waiting for Host"
        end
    elseif gGlobalSyncTable.roundState == ROUND_ACTIVE then
        if gGlobalSyncTable.gamemode == ODDBALL then
            -- find runner
            local runner = -1
            local np = gNetworkPlayers[0]
            local s = gPlayerSyncTable[0]
            for i = 0, MAX_PLAYERS - 1 do
                np = gNetworkPlayers[i]
                s = gPlayerSyncTable[i]
                if  np.connected and s.state == RUNNER
                and (runner < 0 or s.oddballTimer > gPlayerSyncTable[runner].oddballTimer) then
                    runner = i
                end
            end

            np = gNetworkPlayers[runner]
            s = gPlayerSyncTable[runner]

            if s == nil then
                text = "No " .. get_gamemode(ODDBALL)
                goto render
            end
            local time = s.oddballTimer

            if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
                text = "???"
            else
                text = get_player_name(runner) .. "\\#FFFFFF\\: " .. math.floor(time / 30)
            end

            -- if auto hide hud is on, and we are less than 20 seconds away from the round ending, make fade hud peek
            if math.floor(time / 30) <= 20 and gGlobalSyncTable.modifier ~= MODIFIER_INCOGNITO then
                fade = hudFade + linear_interpolation(clampf(time / 30, 15, 20), 128, 0, 15, 20)

                if autoHideHudAlwaysShowTimer then
                    fade = fade + 128
                end

                fade = clampf(fade, 0, 255)
            else
                if autoHideHudAlwaysShowTimer then
                    fade = fade + 128
                    fade = clampf(fade, 0, 255)
                end
            end
        else
            text = "Time Remaining: " .. math.floor(gGlobalSyncTable.displayTimer / 30) -- divide by 30 for seconds and not frames (all game logic runs at 30fps)

            if (gGlobalSyncTable.gamemode == SARDINES
            or gGlobalSyncTable.gamemode == SEARCH)
            and gPlayerSyncTable[0].state == RUNNER then
                text = "You're Hiding. " .. text
            end

            -- if auto hide hud is on, and we are less than 20 seconds away from the round ending, make fade hud peek
            if math.floor(gGlobalSyncTable.displayTimer / 30) <= 20 then
                fade = hudFade + linear_interpolation(clampf(gGlobalSyncTable.displayTimer / 30, 15, 20), 128, 0, 15, 20)

                if autoHideHudAlwaysShowTimer then
                    fade = fade + 128
                end

                fade = clampf(fade, 0, 255)
            else
                if autoHideHudAlwaysShowTimer then
                    fade = fade + 128
                    fade = clampf(fade, 0, 255)
                end
            end
        end
    elseif gGlobalSyncTable.roundState == ROUND_SARDINE_HIDING
    or gGlobalSyncTable.roundState == ROUND_SEARCH_HIDING then
        text = "You have " ..
        math.floor(gGlobalSyncTable.displayTimer / 30)
        .. " seconds to hide!" -- divide by 30 for seconds and not frames (all game logic runs at 30fps)

        -- if auto hide hud is on, and we are less than 10 seconds away from the sardine hiding session ending, make fade hud peek
        if math.floor(gGlobalSyncTable.displayTimer / 30) <= 10
        and gPlayerSyncTable[0].state == RUNNER then
            fade = hudFade + linear_interpolation(clampf(gGlobalSyncTable.displayTimer / 30, 7, 10), 128, 0, 7, 10)

            if autoHideHudAlwaysShowTimer then
                fade = fade + 128
            end

            fade = clampf(fade, 0, 255)
        else
            if autoHideHudAlwaysShowTimer then
                fade = fade + 128
                fade = clampf(fade, 0, 255)
            end
        end
    elseif gGlobalSyncTable.roundState == ROUND_WAIT then
        text = "Starting in " ..
            math.floor(gGlobalSyncTable.displayTimer / 30) + 1 -- divide by 30 for seconds and not frames (all game logic runs at 30fps)
    elseif gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN or gGlobalSyncTable.state == ROUND_TAGGERS_WIN then
        text = "Starting new round"
    elseif gGlobalSyncTable.roundState == ROUND_HOT_POTATO_INTERMISSION then
        text = "Intermission: " ..
            math.floor(gGlobalSyncTable.displayTimer / 30) + 1 -- divide by 30 for seconds and not frames (all game logic runs at 30fps)
    else
        return
    end

    ::render::

    local scale = 1.5

    -- get width of screen and text
    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(strip_hex(text)) * scale

    local x = (screenWidth - width) / 2.0
    local y = 0

    -- render rect
    djui_hud_set_color(theme.background.r, theme.background.g, theme.background.b, fade / 1.4)
    djui_hud_render_rect_rounded_outlined(x - (12 * scale), y, width + (24 * scale), (32 * scale), theme.backgroundOutline.r, theme.backgroundOutline.g, theme.backgroundOutline.b, 4, fade / 1.4)

    -- render text
    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, fade)
    djui_hud_print_colored_text(text, x, y, scale, fade)
end

local function hud_gamemode()

    local theme = get_selected_theme()

    local text = get_gamemode(gGlobalSyncTable.gamemode)
    local scale = 1

    -- get width of screen and text
    local width = djui_hud_measure_text(strip_hex(text)) * scale

    local x = 12 * scale
    local y = 0

    -- render rect
    djui_hud_set_color(theme.background.r, theme.background.g, theme.background.b, hudFade / 1.4)
    djui_hud_render_rect_rounded_outlined(x - (12 * scale), y, width + (24 * scale), (32 * scale), theme.backgroundOutline.r, theme.backgroundOutline.g, theme.backgroundOutline.b, 4 / 1.5, hudFade / 1.4)

    -- render text
    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, hudFade)
    djui_hud_print_colored_text(text, x, y, scale, hudFade)
end

local function hud_modifier()

    local theme = get_selected_theme()

    local text = get_modifier_text()
    local scale = 1

    -- get width of screen and text
    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(strip_hex(text)) * scale

    local x = screenWidth - width - (12 * scale)
    local y = 0

    -- render rect
    djui_hud_set_color(theme.background.r, theme.background.g, theme.background.b, hudFade / 1.4)
    djui_hud_render_rect_rounded_outlined(x - (12 * scale), y, width + (24 * scale), (32 * scale), theme.backgroundOutline.r, theme.backgroundOutline.g, theme.backgroundOutline.b, 4 / 1.5, hudFade / 1.4)

    -- render text
    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, hudFade)
    djui_hud_print_colored_text(text, x, y, scale, hudFade)
end

local function hud_boost()
    if gGlobalSyncTable.roundState == ROUND_VOTING then return end
    if not boosts_enabled() then return end
    local boostTime = speedBoostTimer / 30 / (gGlobalSyncTable.boostCooldown / 30)
    if boostState == BOOST_STATE_BOOSTING then
        boostTime = speedBoostTimer / 30 / 5
    end
    local text = ""
    if boostState == BOOST_STATE_BOOSTING then
        text = "Boosting"
    elseif boostState == BOOST_STATE_RECHARGING then
        text = "Recharging (" .. math.floor((gGlobalSyncTable.boostCooldown - speedBoostTimer) / 30 * 10) / 10 .. ")"
    else
        text = "Boost (" .. button_to_text(binds[BIND_BOOST].btn) .. ")"
    end

    render_bar(text, boostTime, 0, 1, 0, 162, 255)
end

local function hud_render()
    -- if we are hiding the hud as a spectator, don't render the hud
    if spectatorHideHud then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    -- fade
    if (is_standing_still()
    or not autoHideHud)
    and gGlobalSyncTable.roundState ~= ROUND_VOTING then
        hudFade = hudFade + 40
    else
        hudFade = hudFade - 40
    end

    hudFade = clampf(hudFade, 0, 255)

    -- render hud
    if  gGlobalSyncTable.roundState ~= ROUND_RUNNERS_WIN
    and gGlobalSyncTable.roundState ~= ROUND_TAGGERS_WIN
    and gGlobalSyncTable.roundState ~= ROUND_TOURNAMENT_LEADERBOARD then
        hud_round_status()
        hud_gamemode()
        hud_modifier()
        hud_boost()
    end

    -- hide hud
    hud_hide()
end

---@param a MarioState
---@param v MarioState
local function allow_pvp(a, v)
    -- don't allow spectators to attack players, vice versa
    if gPlayerSyncTable[v.playerIndex].state == SPECTATOR or gPlayerSyncTable[a.playerIndex].state == SPECTATOR then return false end
    -- if friendly fire is enabled, don't continue
    if friendly_fire_enabled() then return end
    -- check if 2 runners are trying to attack eachother
    if gPlayerSyncTable[v.playerIndex].state == RUNNER and gPlayerSyncTable[a.playerIndex].state == RUNNER then return false end
    -- check if 2 taggers are trying to attack eachother
    if gPlayerSyncTable[v.playerIndex].state == TAGGER and gPlayerSyncTable[a.playerIndex].state == TAGGER
    and gGlobalSyncTable.gamemode ~= ASSASSINS and gGlobalSyncTable.gamemode ~= DEATHMATCH then return false end
end

---@param m MarioState
---@param o Object
---@param intee InteractionType
local function allow_interact(m, o, intee)
    -- check if intee is unwanted
    if intee == INTERACT_STAR_OR_KEY
    or intee == INTERACT_KOOPA_SHELL then
        return false
    end

    -- disable warp interaction
    if (intee == INTERACT_WARP or intee == INTERACT_WARP_DOOR)
    and gGlobalSyncTable.roundState ~= ROUND_WAIT_PLAYERS then
        return false
    end

    -- disable banned level interactions
    local selectedLevel = levels[gGlobalSyncTable.selectedLevel]
    if selectedLevel.disabledBhvs ~= nil then
        for _, bhv in pairs(selectedLevel.disabledBhvs) do
            if get_id_from_behavior(o.behavior) == bhv then
                return false
            end
        end
    end

    -- dont allow spectator to interact with objects, L
    -- they are allowed to interact with pipes because that is handled with distance,
    -- and not interaction, so such restrictions would be handled on the behavior
    if gPlayerSyncTable[m.playerIndex].state == SPECTATOR then return false end
end

local function on_warp()
    local m = gMarioStates[0]
    local level = levels[gGlobalSyncTable.selectedLevel]

    if level ~= nil and level.spawnLocation ~= nil then
        set_mario_action(m, ACT_FREEFALL, 0)
        vec3f_copy(m.pos, level.spawnLocation)

        reset_standing_still()
    end
end

local function level_init()
    -- get rid of water
    for i = 1, 10 do
        waterRegions[i] = get_environment_region(i)
        if levels[gGlobalSyncTable.selectedLevel] and
        levels[gGlobalSyncTable.selectedLevel].overrideWater ~= true
        and not gGlobalSyncTable.water then
            set_environment_region(i, -10000)
        end
    end
end

local function on_chat_message(m, msg)
    if gPlayerSyncTable[m.playerIndex].muted then
        if m.playerIndex == 0 then
            djui_chat_message_create("\\#FF0000\\You are muted!")
            play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        end
        return false
    end

    -- use mariohunt api, since Emily did all the work already
    if _G.mhApi.chatValidFunction and _G.mhApi.chatValidFunction(m, msg) == false then
        return false
    end

    if _G.mhApi.chatModifyFunction then
        -- ignore name, as it's not used here
        local msg_, _ = _G.mhApi.chatModifyFunction(m, msg)
        if msg_ then msg = msg_ end
    end

    local s = gPlayerSyncTable[0]
    local rS = gPlayerSyncTable[m.playerIndex]

    if gGlobalSyncTable.roundState == ROUND_ACTIVE
    and gGlobalSyncTable.gamemode == SARDINES then
        if  (s.state  == WILDCARD_ROLE or s.state  == RUNNER or s.state  == SPECTATOR)
        and (rS.state == WILDCARD_ROLE or rS.state == RUNNER or rS.state == SPECTATOR) then
            djui_chat_message_create("\\#BBBEA1\\Sardine Chat: " .. get_player_name(m.playerIndex) .. ": \\#dcdcdc\\" .. msg)
            if m.playerIndex == 0 then
                play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
            else
                play_sound(SOUND_MENU_MESSAGE_APPEAR, gGlobalSoundSource)
            end
            return false
        elseif s.state ~= TAGGER or rS.state ~= TAGGER then
            return false
        end
    end

    djui_chat_message_create(get_player_name(m.playerIndex) .. ": \\#dcdcdc\\" .. msg)
    if m.playerIndex == 0 then
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
    else
        play_sound(SOUND_MENU_MESSAGE_APPEAR, gGlobalSoundSource)
    end
    return false
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
    -- this is to freeze mario's animation
    m.marioObj.header.gfx.animInfo.animFrame = m.marioObj.header.gfx.animInfo.animFrame - (m.marioObj.header.gfx.animInfo.animAccel + 1)

    -- get out of the action if round state is wait or wait players
    if gGlobalSyncTable.roundState == ROUND_WAIT_PLAYERS
    or gGlobalSyncTable.roundState == ROUND_WAIT then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    return 0
end

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
-- runs on warp
hook_event(HOOK_ON_WARP, on_warp)
-- runs on level initialization
hook_event(HOOK_ON_LEVEL_INIT, level_init)
-- runs when the player sends a chat message
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)
-- make sure the user can never pause exit
hook_event(HOOK_ON_PAUSE_EXIT, function() return false end)
-- this hook allows us to walk on lava and quicksand
hook_event(HOOK_ALLOW_HAZARD_SURFACE, function (m)
    if gGlobalSyncTable.modifier == MODIFIER_SAND and m.floor.type == SURFACE_DEEP_QUICKSAND then return end
    if gPlayerSyncTable[0].state == SPECTATOR or gPlayerSyncTable[0].state == WILDCARD_ROLE then return end
    return gGlobalSyncTable.hazardSurfaces
end)
-- disables dialogs
hook_event(HOOK_ON_DIALOG, function () return false end)

-- make ACT_NOTHING do something, wild ain't it
hook_mario_action(ACT_NOTHING, act_nothing)

-- Good job, you made it to the end of your file. I'd suggest heading over to tag.lua next!
