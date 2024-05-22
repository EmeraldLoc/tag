
---@param m MarioState
local function mario_update(m)
    if  gGlobalSyncTable.modifier ~= MODIFIER_HARD_SURFACE
    and gPlayerSyncTable[m.playerIndex].state ~= SPECTATOR
    and (gPlayerSyncTable[m.playerIndex].state ~= WILDCARD_ROLE
    or gGlobalSyncTable.gamemode == FREEZE_TAG) then return end

    if m.floor.type ~= SURFACE_DEATH_PLANE
    and (m.floor.type ~= SURFACE_BURNING or not gGlobalSyncTable.hazardSurfaces) then
        m.floor.type = SURFACE_HARD_NOT_SLIPPERY
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)