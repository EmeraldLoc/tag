
---@class Reward
---@field public title     string|nil
---@field public trail     ModelExtendedId|nil
---@field public banner    string|nil

---@class Achievment
---@field public name      string
---@field public guide     string
---@field public reward    Reward
---@field public initFunc  function
---@field public loopFunc  function

achievements = {
    ---@type Achievment
    {
        name = "Welcome to Tag",
        guide = "Play Your First Game of Tag",
        reward = {
            title = "Noob",
            trail = nil,
            banner = nil,
        },
        initFunc = nil,
        loopFunc = nil
    }
}