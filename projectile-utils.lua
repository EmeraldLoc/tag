
-- handle projectile pvp
---@param aI integer
---@param vI integer
function handle_projectile_pvp(aI, vI)
    -- run handle pvp function based off of gamemode (if we run anything at all)
    if gGlobalSyncTable.gamemode == TAG then
        tag_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == FREEZE_TAG then
        freeze_tag_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == INFECTION then
        infection_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == HOT_POTATO then
        hot_potato_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
        -- do nothing, purely for kb and protection
    elseif gGlobalSyncTable.gamemode == ASSASSINS then
        assassins_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == SARDINES then
        -- do nothing, purely for chaos
    elseif gGlobalSyncTable.gamemode == HUNT then
        hunt_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == DEATHMATCH then
        deathmatch_handle_pvp(aI, vI)
    end
end
