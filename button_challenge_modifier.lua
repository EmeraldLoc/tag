
---@param m MarioState
local function before_mario_update(m)
    if gGlobalSyncTable.modifier ~= MODIFIER_BUTTON_CHALLENGE then return end

    if m.freeze > 0 then return end

    m.controller.buttonPressed = m.controller.buttonPressed & ~gGlobalSyncTable.buttonChallengeButton
    m.controller.buttonDown = m.controller.buttonDown & ~gGlobalSyncTable.buttonChallengeButton
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)