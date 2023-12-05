
-- constants
local FROZEN = 2

-- global vars
gGlobalSyncTable.freezeHealthDrain = 2.5

local function update()

    if gGlobalSyncTable.gamemode ~= FREEZE_TAG then return end

    -- set network descriptions
    for i = 0, MAX_PLAYERS - 1 do
        if gPlayerSyncTable[i].state == TAGGER then
            network_player_set_description(gNetworkPlayers[i], "Tagger", 232, 46, 46, 255)
        elseif gPlayerSyncTable[i].state == RUNNER then
            network_player_set_description(gNetworkPlayers[i], "Runner", 49, 107, 232, 255)
        elseif gPlayerSyncTable[i].state == FROZEN then
            network_player_set_description(gNetworkPlayers[i], "Frozen", 126, 192, 238, 255)
        end
    end
end

---@param m MarioState
local function mario_update(m)

    if gGlobalSyncTable.gamemode ~= FREEZE_TAG then return end

    if gPlayerSyncTable[m.playerIndex].state == FROZEN then
        -- set model state and action and velocity
        m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
        set_mario_action(m, ACT_SHIVERING, 0)
        m.forwardVel = 0
        m.vel.y = 0

        -- snap mario to the floor
        m.pos.y = m.floorHeight

        -- cheeck if terrain is snow
        local terrainIsSnow = (m.area.terrainType & TERRAIN_MASK) == TERRAIN_SNOW;

        if gGlobalSyncTable.roundState == ROUND_ACTIVE then
            -- see if were swimming and tangible
            if m.action & ACT_FLAG_SWIMMING ~= 0 and m.action & ACT_FLAG_INTANGIBLE == 0 then
                -- check current water level
                if m.pos.y >= (m.waterLevel - 140) and not terrainIsSnow then
                    -- subtract mario's health to compensate for mario's healing in water
                    m.health = m.health - 0x1A;
                else
                    if terrainIsSnow then
                        -- add mario's health to compensate for mario taking damage when under water
                        m.health = m.health + 3;
                    else
                        -- add mario's health to compensate for mario taking damage when under water
                        m.health = m.health + 1;
                    end
                end
            end


            -- if mario's health is greater than 0 then subtract his health by 2.5
            if m.health > 0 then
                m.health = m.health - gGlobalSyncTable.freezeHealthDrain
            end
        end
    else
        m.health = 0x880 -- set mario's health to full
    end
end

local function hud_health_render()
    if gPlayerSyncTable[0].state ~= FROZEN then return end

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    -- create variables
    local scale = 1
    local width = 128 * scale
    local height = 16 * scale
    local x = math.floor((screenWidth - width) / 2)
    local y = math.floor(screenHeight - height - 4 * scale)

    -- set the color to a transparent black, and render the rectangle
    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x, y, width, height)

    x = x + 2 * scale -- add 2 to x to  to compensate for smaller size
    y = y + 2 * scale -- add 2 to y to  to compensate for smaller size
    width = width - 4 * scale
    height = height - 4 * scale
    local health = mario_health_float(gMarioStates[0]) -- get mario's health between 0 and 1
    width = width * health
    djui_hud_set_color(126, 192, 238, 128)
    djui_hud_render_rect(x, y, width, height)

    local text = "Dying of the Cold" -- create text variable

    scale = 0.25
    width = djui_hud_measure_text(text) * scale
    height = 32 * scale
    x = (screenWidth - width) / 2
    y = screenHeight - 28

    -- render rectangle and text
    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - 6, y, width + 12, height)

    djui_hud_set_color(126, 192, 238, 128)
    djui_hud_print_text(text, x, y, scale)
end

local function hud_render()

    if gGlobalSyncTable.gamemode ~= FREEZE_TAG then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)
    
    -- render frozen health
    hud_health_render()

    -- render radar
    if gGlobalSyncTable.modifier ~= MODIFIER_NO_RADAR then
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                if gPlayerSyncTable[i].state == RUNNER and gPlayerSyncTable[0].state == TAGGER then
                    render_radar(gMarioStates[i], icon_radar[i], false)
                elseif gPlayerSyncTable[i].state == FROZEN and gPlayerSyncTable[0].state == RUNNER then
                    render_radar(gMarioStates[i], icon_radar[i], false)
                end
            end
        end
    end
end

---@param m MarioState
local function on_death(m)

    if gGlobalSyncTable.gamemode ~= FREEZE_TAG then return end

    if gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- become tagger on death, wether frozen or runner
        if m.playerIndex == 0 then
            if gPlayerSyncTable[0].state == RUNNER and gGlobalSyncTable.roundState == ROUND_ACTIVE then
                gPlayerSyncTable[0].state = TAGGER

                tagger_popup(0)
            end

            if gPlayerSyncTable[0].state == FROZEN and gGlobalSyncTable.roundState == ROUND_ACTIVE then
                gPlayerSyncTable[m.playerIndex].state = TAGGER

                tagger_popup(0)
            end
        end
    end
end

---@param a MarioState
---@param v MarioState
local function allow_pvp(a, v)
    if gGlobalSyncTable.gamemode == FREEZE_TAG then
        -- check if frozen player is trying to perform a pvp attack
        if gPlayerSyncTable[a.playerIndex].state == FROZEN then return false end
        -- check if a tagger is trying to attack a frozen player
        if gPlayerSyncTable[a.playerIndex].state == TAGGER and gPlayerSyncTable[v.playerIndex].state == FROZEN then return false end
    end
end

---@param m MarioState
---@param o Object
---@param intee InteractionType
local function allow_interact(m, o, intee)
    if gGlobalSyncTable.gamemode == FREEZE_TAG then
        -- check if player interacts with another player
        if intee == INTERACT_PLAYER then
            for i = 0, MAX_PLAYERS - 1 do
                if gNetworkPlayers[i].connected then
                    -- find the other player and check his state
                    if (gPlayerSyncTable[i].state == TAGGER and gPlayerSyncTable[m.playerIndex].state == FROZEN) or (gPlayerSyncTable[i].state == FROZEN and gPlayerSyncTable[m.playerIndex].state == TAGGER) then
                        return false
                    end
                end
            end
        elseif gPlayerSyncTable[m.playerIndex].state == FROZEN then
            return false
        end
    end
end

local function on_pvp(a, v)

    if gGlobalSyncTable.gamemode ~= FREEZE_TAG then return end

    -- check if tagger tagged runner
    if gPlayerSyncTable[v.playerIndex].state == RUNNER and gPlayerSyncTable[a.playerIndex].state == TAGGER and gPlayerSyncTable[v.playerIndex].invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE and v.playerIndex == 0 then
        gPlayerSyncTable[a.playerIndex].amountOfTags = gPlayerSyncTable[a.playerIndex].amountOfTags + 1
        gPlayerSyncTable[v.playerIndex].state = FROZEN
        freezed_popup(a.playerIndex, v.playerIndex)
    end

    -- check if runner attacked frozen
    if gPlayerSyncTable[v.playerIndex].state == FROZEN and gPlayerSyncTable[a.playerIndex].state == RUNNER and gPlayerSyncTable[v.playerIndex].invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE and v.playerIndex == 0 then
        gPlayerSyncTable[v.playerIndex].state = RUNNER
        gPlayerSyncTable[v.playerIndex].invincTimer = 2 * 30
        set_mario_action(gMarioStates[v.playerIndex], ACT_IDLE, 0)
        unfreezed_popup(a.playerIndex, v.playerIndex)
    end
end

hook_event(HOOK_UPDATE, update)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
