
-- handle projectile pvp
---@param aI integer
---@param vI integer
---@param o Object|nil
function handle_projectile_pvp(aI, vI, o)

    -- don't allow spectators to attack players, vice versa
    if gPlayerSyncTable[aI].state == SPECTATOR or gPlayerSyncTable[aI].state == SPECTATOR then return end
    -- if the modifier is not friendly fire, check runners and taggers
    if gGlobalSyncTable.modifier ~= MODIFIER_FRIENDLY_FIRE then
        -- check if 2 runners are trying to attack eachother
        if gPlayerSyncTable[vI].state == RUNNER and gPlayerSyncTable[aI].state == RUNNER then return end
        -- check if 2 taggers are trying to attack eachother
        if gPlayerSyncTable[vI].state == TAGGER and gPlayerSyncTable[aI].state == TAGGER
        and gGlobalSyncTable.gamemode ~= ASSASSINS and gGlobalSyncTable.gamemode ~= DEATHMATCH then return end
    end

    -- if we get this far, make mario take kb if o is specified, and if mario's invinc timer is 0
    if gPlayerSyncTable[vI].invincTimer <= 0
    and o ~= nil then
        take_damage_and_knock_back(gMarioStates[vI], o)
    end

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
        sardines_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == HUNT then
        hunt_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == DEATHMATCH then
        deathmatch_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == TERMINATOR then
        terminator_handle_pvp(aI, vI)
    elseif gGlobalSyncTable.gamemode == ODDBALL then
        oddball_handle_pvp(aI, vI)
    end
end
