
local autoSpectateTimer = 1 * 60 * 30 -- 1 minutes

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    autoSpectateTimer = clamp(autoSpectateTimer - 1, 0, autoSpectateTimer)

    if m.controller.buttonPressed ~= 0
    or m.controller.buttonDown ~= 0
    or m.controller.stickX > 10
    or m.controller.stickX < -10
    or m.controller.stickY > 10
    or m.controller.stickY < -10 then
        autoSpectateTimer = 1 * 60 * 30
    end

    if  autoSpectateTimer <= 0 and gGlobalSyncTable.roundState ~= ROUND_ACTIVE
    and gGlobalSyncTable.roundState ~= ROUND_HOT_POTATO_INTERMISSION
    and gGlobalSyncTable.roundState ~= ROUND_SARDINE_HIDING then
        gPlayerSyncTable[0].state = SPECTATOR
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)