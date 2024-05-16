
local randomMarioIndex = nil
local lastSafeCoords = { x = 0, y = 0, z = 0 }

---@param m MarioState
local function mario_update(m)

    if m.playerIndex ~= 0 then return end
    if gGlobalSyncTable.modifier ~= MODIFIER_SWAP then return end
    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then
        gGlobalSyncTable.swapTimer = 20 * 30
        return
    end

    if  gGlobalSyncTable.swapTimer <= 5 * 30
    and gPlayerSyncTable[0].state ~= SPECTATOR
    and gPlayerSyncTable[0].state ~= WILDCARD_ROLE
    and gPlayerSyncTable[0].state ~= -1 then
        -- select a random mario
        if randomMarioIndex == nil then
            randomMarioIndex = math.random(1, MAX_PLAYERS - 1)

            -- if that mario isn't "valid", select another mario
            while not gNetworkPlayers[randomMarioIndex].connected
            or gPlayerSyncTable[randomMarioIndex].state == WILDCARD_ROLE
            or gPlayerSyncTable[randomMarioIndex].state == SPECTATOR
            or gPlayerSyncTable[randomMarioIndex].state == -1 do
                randomMarioIndex = math.random(1, MAX_PLAYERS - 1)
            end
        end

        -- if the remote mario is in a safe position, set lastSafeCoords
        local remoteM = gMarioStates[randomMarioIndex]

        if remoteM.action & ACT_GROUP_MASK ~= ACT_GROUP_AIRBORNE then
            vec3f_copy(lastSafeCoords, remoteM.pos)
        end

        if gGlobalSyncTable.swapTimer <= 0 then
            -- set invinc timer
            gPlayerSyncTable[m.playerIndex].invincTimer = 1 * 30 -- 1 second

            -- set the current pos to the last safe coordinates
            vec3f_copy(m.pos, lastSafeCoords)
        end
    else
        randomMarioIndex = nil
    end

    -- reduce swap timer
    if network_is_server() then
        if gGlobalSyncTable.swapTimer >= 0 then
            gGlobalSyncTable.swapTimer = gGlobalSyncTable.swapTimer - 1
        else
            gGlobalSyncTable.swapTimer = math.random(15 * 30, 30 * 30)
        end
    end
end

function hud_render()

    if gPlayerSyncTable[0].state == SPECTATOR
    or gPlayerSyncTable[0].state == WILDCARD_ROLE then return end
    if gGlobalSyncTable.modifier ~= MODIFIER_SWAP then return end
    if gGlobalSyncTable.swapTimer > 5 * 30 then return end

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local scale        = 1
    local width        = 128 * scale
    local height       = 16 * scale
    local x            = math.floor((screenWidth - width) / 2)
    local y            = math.floor(screenHeight - height - 4 * scale)
    local swapTime     = gGlobalSyncTable.swapTimer / 30 / 5

    if  boosts_enabled()
    or  (gPlayerSyncTable[0].state == RUNNER
    and gGlobalSyncTable.roundState == ROUND_ACTIVE
    and (gGlobalSyncTable.gamemode == JUGGERNAUT
    or  gGlobalSyncTable.gamemode == HUNT)) then
        y = y - 32
    end

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x, y, width, height)

    x = x + 2 * scale
    y = y + 2 * scale
    width = width - 4 * scale
    height = height - 4 * scale
    width = math.floor(width * swapTime)

    djui_hud_set_color(255, 0, 0, 128)
    djui_hud_render_rect(x, y, width, height)

    text = "Swapping in " .. math.floor(gGlobalSyncTable.swapTimer / 30) .. "s"

    scale = 0.25
    width = djui_hud_measure_text(text) * scale
    height = 32 * scale
    x = (screenWidth - width) / 2
    y = screenHeight - 28

    if  boosts_enabled()
    or  (gPlayerSyncTable[0].state == RUNNER
    and gGlobalSyncTable.roundState == ROUND_ACTIVE
    and (gGlobalSyncTable.gamemode == JUGGERNAUT
    or  gGlobalSyncTable.gamemode == HUNT)) then
        y = y - 32
    end

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - 6, y, width + 12, height)

    djui_hud_set_color(255, 0, 0, 128)
    djui_hud_print_text(text, x, y, scale)
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)