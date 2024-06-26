
---@param m MarioState
local function mario_update(m)
    if gGlobalSyncTable.gamemode ~= HUNT then return end

    m.health = 0x880 -- set mario's health to full
end

local function hud_render()
    if gGlobalSyncTable.gamemode ~= HUNT then return end

    -- set djui font and resolution
    djui_hud_set_font(djui_menu_get_font())
    djui_hud_set_resolution(RESOLUTION_N64)

    if gPlayerSyncTable[0].state == RUNNER and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        render_bar("Lives Remaining: " .. gPlayerSyncTable[0].tagLives, gPlayerSyncTable[0].tagLives, 0, gGlobalSyncTable.tagMaxLives, 66, 176, 245)
    end

    -- check that we dont have the modifier MODIFIER_NO_RADAR enabled
    if gGlobalSyncTable.modifier ~= MODIFIER_NO_RADAR then
        -- render radar for each player
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- make sure the states line up
                if gPlayerSyncTable[i].state == RUNNER and gPlayerSyncTable[0].state == TAGGER then -- check if we meet the checks to render the radar
                    render_radar(gMarioStates[i], icon_radar[i], false) -- render radar on player
                end
            end
        end
    end
end

local function on_warp()

    ---@type MarioState
    local m = gMarioStates[0]

    if gGlobalSyncTable.gamemode ~= HUNT then return end
    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end
    if not gGlobalSyncTable.eliminateOnDeath then return end
    if gNetworkPlayers[0].currLevelNum ~= levels[gGlobalSyncTable.selectedLevel].level then return end
    if m.playerIndex ~= 0 then return end

    -- subtract lives by 1
    if gPlayerSyncTable[0].state == RUNNER then
        gPlayerSyncTable[0].tagLives = gPlayerSyncTable[0].tagLives - 1

        if gPlayerSyncTable[0].tagLives <= 0 then
            -- select random runner
            local randomIndex = math.random(0, MAX_PLAYERS - 1) -- select random index
            local infinityLoopPreventer = 0

            while gPlayerSyncTable[randomIndex].state == RUNNER or gPlayerSyncTable[randomIndex].state == SPECTATOR or gPlayerSyncTable[randomIndex].state == -1 or not gNetworkPlayers[randomIndex].connected do
                randomIndex = math.random(0, MAX_PLAYERS - 1)
                infinityLoopPreventer = infinityLoopPreventer + 1

                if infinityLoopPreventer > 200 then break end
            end

            if infinityLoopPreventer <= 200 then gPlayerSyncTable[randomIndex].state = RUNNER end

            gPlayerSyncTable[0].state = TAGGER
            djui_popup_create_global(get_player_name(0) .. " \\#dcdcdc\\died\n" .. get_player_name(randomIndex).. " is a " .. get_role_name(RUNNER), 3)
        end
    end
end

---@param a MarioState
---@param v MarioState
local function on_pvp(a, v)
    if gGlobalSyncTable.gamemode ~= HUNT then return end

    if v.playerIndex ~= 0 then return end
    -- handle pvp if we are the victim
    hunt_handle_pvp(a.playerIndex, v.playerIndex)
end

---@param aI number
---@param vI number
function hunt_handle_pvp(aI, vI)
    -- this checks and sets our states
    local a = gPlayerSyncTable[aI]
    local v = gPlayerSyncTable[vI]

    -- check if tagger tagged runner
    if v.state == RUNNER and a.state == TAGGER
    and v.invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- reduce lives in runner
        v.tagLives = v.tagLives - 1

        -- if tagLives is set to 0 or less then flip states
        if v.tagLives <= 0 then
            -- flip states
            v.state = TAGGER
            a.state = RUNNER
            a.invincTimer = 1 * 30
            -- set attacker lives
            a.tagLives = gGlobalSyncTable.tagMaxLives
            -- create popup
            tagged_popup(aI, vI)
        else
            v.invincTimer = 3 * 30
        end
        -- increase amount of tags and set invincibility timer to 1 second
        a.amountOfTags = a.amountOfTags + 1
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ON_WARP, on_warp)