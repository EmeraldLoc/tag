---@class Trail
---@field public name        string|nil
---@field public model       integer|ModelExtendedId|nil

---@class Reward
---@field public title       string|nil
---@field public trail       Trail|nil

---@class Achievement
---@field public name        string
---@field public description string
---@field public reward      Reward
---@field public initFunc    function|nil
---@field public loopFunc    function|nil

local marathonTimer = 0
local speedingTimer = 0
local speederPrevAmountOfTags = 0

spectatorAttemptCount = 0

achievements = {
    ---@type Achievement
    {
        name = "Welcome to Tag",
        description = "Launch Tag!",
        ---@type Reward
        reward = {
            title = nil,
            trail = nil,
        },
        initFunc = function ()
            return true
        end,
        loopFunc = nil
    },
    ---@type Achievement
    {
        name = "One match in!",
        description = "Play your first game of Tag!",
        ---@type Reward
        reward = {
            title = "\\#dcdcdc\\Noob",
            trail = nil,
        },
        initFunc = nil,
        loopFunc = function ()
            local s = gPlayerSyncTable[0]
            if (gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN
            or  gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN)
            and s.state ~= SPECTATOR and s.state ~= -1 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Your first tag!",
        description = "Tag A Player!",
        ---@type Reward
        reward = {
            title = "\\#dcdcdc\\Beginner",
            trail = nil,
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.totalTags >= 1 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Tagging away, I see...",
        description = "Get 10 Tags!",
        ---@type Reward
        reward = {
            title = nil,
            trail = nil,
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.totalTags >= 10 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "50 Tags? Keep it up!",
        description = "Get 50 Tags!",
        ---@type Reward
        reward = {
            title = "\\#E82E2E\\Tagger",
            trail = {
                name = "Tagger Trail",
                model = smlua_model_util_get_id("tagger_trail_geo")
            },
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.totalTags >= 50 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "The Big Triple!",
        description = "Get 100 Tags!",
        ---@type Reward
        reward = {
            title = "\\#A62D24\\Aggresive Tagger",
            trail = {
                name = "Aggresive Tagger Trail",
                model = smlua_model_util_get_id("aggresive_tagger_trail_geo")
            },
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.totalTags >= 100 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "4 digits? Chill with the tags!",
        description = "Get 1000 Tags!",
        ---@type Reward
        reward = {
            title = "\\#E82E2E\\Expert Tagger",
            trail = {
                name = "Tagger Ring Trail",
                model = smlua_model_util_get_id("tagger_ring_trail_geo")
            },
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.totalTags >= 1000 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "An hour comes, a hour goes.",
        description = "Play for 1 hour total!",
        ---@type Reward
        reward = {
            title = "\\#dcdcdc\\1 Hour In",
            trail = nil,
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.playTime / 30 / 60 / 60 >= 1 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Half a day in, you're going strong!",
        description = "Play for 12 hours total!",
        ---@type Reward
        reward = {
            title = "\\#999999\\12 Hours In",
            trail = nil,
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.playTime / 30 / 60 / 60 >= 12 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "First day in, enjoy the next!",
        description = "Play for 24 hours total!",
        ---@type Reward
        reward = {
            title = "\\#636363\\24 Hours In",
            trail = nil,
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.playTime / 30 / 60 / 60 >= 24 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "2 days in, you must be grinding!",
        description = "Play for 48 hours total!",
        ---@type Reward
        reward = {
            title = "\\#FFD700\\Grinding Tag",
            trail = nil,
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.playTime / 30 / 60 / 60 >= 48 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Hey, maybe take a break?!",
        description = "Play for 7 hours in a single session!",
        ---@type Reward
        reward = {
            title = "\\#732323\\Always Watching",
            trail = nil,
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.playTime / 30 / 60 / 60 >= 48 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Dang, a half a day, really?!",
        description = "Play for 12 hours in a single session!",
        ---@type Reward
        reward = {
            title = "\\#316BE8\\Running For Days",
            trail = nil,
        },
        initFunc = nil,
        loopFunc = function ()
            local s = gPlayerSyncTable[0]

            if s.state ~= SPECTATOR then
                marathonTimer = marathonTimer + 1
            end
            if marathonTimer / 30 / 60 / 60 >= 12 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Slow down, speeder!",
        description = "Tag 5 players within 30 seconds!",
        ---@type Reward
        reward = {
            title = "\\#316BE8\\Speeding Tagger",
            ---@type Trail
            trail = {
                name = "Speeding Trail",
                model = smlua_model_util_get_id("speeding_trail_geo")
            },
        },
        initFunc = nil,
        loopFunc = function ()
            local s = gPlayerSyncTable[0]

            if  gGlobalSyncTable.roundState ~= ROUND_HOT_POTATO_INTERMISSION
            and gGlobalSyncTable.roundState ~= ROUND_ACTIVE then
                speederPrevAmountOfTags = 0
                speedingTimer = 0
            end

            if s.amountOfTags and s.amountOfTags > speederPrevAmountOfTags then
                speedingTimer = speedingTimer + 1

                if s.amountOfTags - speederPrevAmountOfTags >= 5 then
                    return true
                end

                if speedingTimer > 30 * 30 then
                    speedingTimer = 0
                    speederPrevAmountOfTags = s.amountOfTags
                end
            else
                speedingTimer = 0
            end
        end
    },
    ---@type Achievement
    {
        name = "Welp, you've mastered Tag!",
        description = "Get every achievement in Tag!",
        ---@type Reward
        reward = {
            title = "\\#8D4D8B\\Tag Master",
            trail = {
                name = "The Master Trail",
                model = smlua_model_util_get_id("master_trail_geo"),
            },
        },
        initFunc = nil,
        loopFunc = function ()
            local mastered = true
            for i, achievement in pairs(achievements) do
                if  completedAchievements[i] ~= true
                and achievement.reward.title ~= "Tag Master" then
                    mastered = false
                end
            end

            if mastered then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "You really wanna spectate I see...",
        description = "Hit \"Toggle Spectate\" 100 times while in a match.",
        ---@type Reward
        reward = {
            title = "\\#4A4A4A\\Spectator Lover",
            trail = nil,
        },
        initFunc = nil,
        loopFunc = function ()
            if  gGlobalSyncTable.roundState ~= ROUND_ACTIVE
            and gGlobalSyncTable.roundState ~= ROUND_HOT_POTATO_INTERMISSION then
                spectatorAttemptCount = 0
            end

            if spectatorAttemptCount >= 100 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "You're pretty good at terminating people...",
        description = "Win 10 Times as the Terminator!",
        ---@type Reward
        reward = {
            title = "\\#7D2A24\\Beginner Terminator",
            trail = {
                name = "Terminator Trail",
                model = smlua_model_util_get_id("terminator_trail_geo")
            },
        },
        initFunc = nil,
        loopFunc = function ()
            if stats[TERMINATOR].taggerVictories >= 10 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Wow, you're very good with those terminations!",
        description = "Win 50 Times as the Terminator!",
        ---@type Reward
        reward = {
            title = "\\#7D2A24\\Terminator",
            trail = {
                name = "Terminator Ring Trail",
                model = smlua_model_util_get_id("terminator_ring_trail_geo")
            },
        },
        initFunc = nil,
        loopFunc = function ()
            if stats[TERMINATOR].taggerVictories >= 10 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Potato Wielder victories are just better!",
        description = "Win 5 Times as a Potato Wielder!",
        ---@type Reward
        reward = {
            title = "\\#FC9003\\Potato Wielder",
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats[HOT_POTATO].taggerVictories >= 5 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Juggernaut W",
        description = "Win 5 times as the Juggernaut.",
        ---@type Reward
        reward = {
            title = nil,
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats[JUGGERNAUT].runnerVictories >= 5 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Now that's a Juggernaut",
        description = "Win 20 times as the Juggernaut.",
        ---@type Reward
        reward = {
            title = "\\#42B0F5\\Juggernaut",
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats[JUGGERNAUT].runnerVictories >= 20 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "First Tournament W!",
        description = "Win a Tournament.",
        ---@type Reward
        reward = {
            title = nil,
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.totalTournamentWins >= 1 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "5 Tournament wins, nice!",
        description = "Win 5 Tournaments.",
        ---@type Reward
        reward = {
            title = "Tournament Player",
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.totalTournamentWins >= 5 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "20 Tournament wins, now that's a gamer!",
        description = "Win 20 Tournaments.",
        ---@type Reward
        reward = {
            title = "Tournament Victor",
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats.globalStats.totalTournamentWins >= 20 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "5 Assassins wins, not quite an assassin!",
        description = "Win 5 games of Assassins.",
        ---@type Reward
        reward = {
            title = nil,
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats[ASSASSINS].taggerVictories >= 5 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "15 Assassins wins, now that's an assassin!",
        description = "Win 15 games of Assassins.",
        ---@type Reward
        reward = {
            title = "\\#FF0000\\Assassin",
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats[ASSASSINS].taggerVictories >= 15 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "You're throwing an oddball!",
        description = "Win 1 game of Oddball as the Oddball.",
        ---@type Reward
        reward = {
            title = nil,
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats[ODDBALL].runnerVictories >= 1 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "Now that's an oddball!",
        description = "Win 15 games of Oddball as the Oddball.",
        ---@type Reward
        reward = {
            title = "\\#919AA1\\Oddball",
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats[ODDBALL].runnerVictories >= 15 then
                return true
            end
        end
    },
    ---@type Achievement
    {
        name = "That's a freezer! (or saver)",
        description = "Freeze 50 players in Freeze Tag.",
        ---@type Reward
        reward = {
            title = "\\#7EC0EE\\Freezer",
            trail = nil
        },
        initFunc = nil,
        loopFunc = function ()
            if stats[FREEZE_TAG].totalTags >= 50 then
                return true
            end
        end
    },
}

local initializedAchievements = false

completedAchievements = {}
remoteCompletedAchievements = {}

local function completed_achievement(i)
    completedAchievements[i] = true

    local text = "\\#FFD700\\Achievement Unlocked\n" .. achievements[i].name
    djui_popup_create(text, 2)

    -- save achievement
    save_bool("achievement_" .. tostring(i), true)
end

local function mario_update(m)
    local np = gNetworkPlayers[m.playerIndex]
    if m.playerIndex ~= 0 then return end
    if not np.currAreaSyncValid then return end

    -- loop thru all achievements
    for i, achievement in ipairs(achievements) do
        if completedAchievements[i] then goto continue end

        if not initializedAchievements then
            -- load achievements
            local completed = load_bool("achievement_" .. tostring(i))

            if completed == true then
                completedAchievements[i] = true

                goto continue
            end

            if achievement.initFunc then
                if achievement.initFunc() == true then
                    completed_achievement(i)
                    goto continue
                end
            end
        end

        if achievement.loopFunc then
            if achievement.loopFunc() == true then
                completed_achievement(i)
            end
        end

        ::continue::
    end

    if not initializedAchievements then
        -- load selected player title
        local title = load_int("playerTitle")
        if title ~= nil then
            if (completedAchievements[title] ~= nil or title < 0)
            and achievements[title] ~= nil
            and achievements[title].reward ~= nil
            and achievements[title].reward.title ~= nil then
                gPlayerSyncTable[0].playerTitle = achievements[title].reward.title
            else
                gPlayerSyncTable[0].playerTitle = nil
            end
        end

        -- load selected trail
        local trail = load_int("playerTrail")

        if trail ~= nil then
            if  completedAchievements[trail] ~= nil
            and achievements[trail] ~= nil
            and achievements[trail].reward ~= nil
            and achievements[trail].reward.trail ~= nil then
                gPlayerSyncTable[0].playerTrail = achievements[trail].reward.trail.model
            else
                gPlayerSyncTable[0].playerTrail = E_MODEL_BOOST_TRAIL
            end
        end

        -- set owner and developer vars
        isOwner = achievements[-1] ~= nil
        isDeveloper = achievements[-2] ~= nil

        -- print player's stats
        if stats.globalStats.runnerVictories > 0 then
            djui_chat_message_create_global(get_player_name(0) .. " \\#dcdcdc\\has won \\#FFE557\\" .. stats.globalStats.runnerVictories .. " \\#dcdcdc\\times as a \\#316BE8\\Runner")
        end
        if stats.globalStats.taggerVictories > 0 then
            djui_chat_message_create_global(get_player_name(0) .. " \\#dcdcdc\\has won \\#FFE557\\" .. stats.globalStats.taggerVictories .. " \\#dcdcdc\\times as a \\#E82E2E\\Tagger")
        end
    end

    initializedAchievements = true
end

hook_event(HOOK_MARIO_UPDATE, mario_update)