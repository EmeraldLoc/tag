
---@param m MarioState
local function mario_update(m)
    if gGlobalSyncTable.gamemode ~= HUNT then return end

    m.health = 0x880 -- set mario's health to full
end

local function hud_bottom_render()
    if gPlayerSyncTable[0].state == RUNNER and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        local screenWidth  = djui_hud_get_screen_width()
        local screenHeight = djui_hud_get_screen_height()

        local scale = 1
        local width = 128 * scale
        local height = 16 * scale
        local x = math.floor((screenWidth - width) / 2)
        local y = math.floor(screenHeight - height - 4 * scale)
        local tagLives = linear_interpolation(gPlayerSyncTable[0].tagLives, 0, 1, 0, gGlobalSyncTable.tagMaxLives)

        djui_hud_set_color(0, 0, 0, 128)
        djui_hud_render_rect(x, y, width, height)

        x = x + 2 * scale
        y = y + 2 * scale
        width = width - 4 * scale
        height = height - 4 * scale
        width = math.floor(width * tagLives)
        djui_hud_set_color(66, 176, 245, 128)
        djui_hud_render_rect(x, y, width, height)

        local text = "Lives Remaining: " .. tostring(gPlayerSyncTable[0].tagLives)

        scale = 0.25
        width = djui_hud_measure_text(text) * scale
        height = 32 * scale
        x = (screenWidth - width) / 2
        y = screenHeight - 28

        djui_hud_set_color(0, 0, 0, 128)
        djui_hud_render_rect(x - 6, y, width + 12, height)

        djui_hud_set_color(66, 176, 245, 128)
        djui_hud_print_text(text, x, y, scale)
    end
end

local function hud_render()
    if gGlobalSyncTable.gamemode ~= HUNT then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    hud_bottom_render()

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

---@param m MarioState
local function on_death(m)

    if gGlobalSyncTable.gamemode ~= HUNT then return end
    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end
    if not gGlobalSyncTable.eliminateOnDeath then return end
    if m.playerIndex ~= 0 then return end

    -- set lives to 1
    if gPlayerSyncTable[0].state == RUNNER then
        gPlayerSyncTable[0].tagLives = 1
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
            -- set attacker lives
            a.tagLives = 3
            -- create popup
            tagged_popup(aI, vI)
        end
        -- increase amount of tags and set invincibility timer to 1 second
        a.amountOfTags = a.amountOfTags + 1
        a.invincTimer = 1 * 30
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ON_DEATH, on_death)