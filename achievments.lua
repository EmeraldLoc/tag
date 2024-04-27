
---@class Reward
---@field public title     string|nil
---@field public trail     ModelExtendedId|nil
---@field public banner    string|nil

---@class Achievement
---@field public name      string
---@field public guide     string
---@field public reward    Reward
---@field public initFunc  function
---@field public loopFunc  function

achievements = {
    ---@type Achievement
    {
        name = "Welcome to Tag",
        description = "Play Your First Game of Tag",
        reward = {
            title = "Noob",
            trail = nil,
            banner = nil,
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
}

local completedAchievements = {}
local initializedAchievements = false

local function completed_achievement(i)
    completedAchievements[i] = true

    local text = "\\#FFD700\\Achievement Unlocked\n" .. achievements[i].name

    djui_popup_create(text, 2)
end

local function mario_update(m)
    if m.playerIndex ~= 0 then return end

    -- loop thru all achievements
    for i, achievement in pairs(achievements) do

        if completedAchievements[i] then goto continue end

        if not initializedAchievements then
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