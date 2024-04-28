
---@class Trail
---@field public name      string|nil
---@field public model     integer|ModelExtendedId|nil

---@class Reward
---@field public title     string|nil
---@field public trail     Trail|nil

---@class Achievement
---@field public name      string
---@field public guide     string
---@field public reward    Reward
---@field public initFunc  function
---@field public loopFunc  function

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
            trail = nil,
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
            trail = nil,
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
            trail = nil,
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
        name = "2 days in, you mut be grinding!",
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
            title = "\\#4287f5\\I'm In When I'm In",
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

            if s.amountOfTags > speederPrevAmountOfTags then
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
        name = "Welp, you've mastered the game!",
        description = "Get every achievement in the game!",
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
    if m.playerIndex ~= 0 then return end

    -- loop thru all achievements
    for i, achievement in pairs(achievements) do

        if completedAchievements[i] then goto continue end

        if not initializedAchievements then
            -- load achievement
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

    initializedAchievements = true
end

hook_event(HOOK_MARIO_UPDATE, mario_update)