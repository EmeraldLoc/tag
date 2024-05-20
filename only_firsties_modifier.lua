
local function on_set_mario_action(m)
    if gGlobalSyncTable.modifier ~= MODIFIER_ONLY_FIRSTIES then return end
    if m.prevAction == ACT_AIR_HIT_WALL then m.prevAction = ACT_FREEFALL end
end

hook_event(HOOK_ON_SET_MARIO_ACTION, on_set_mario_action)