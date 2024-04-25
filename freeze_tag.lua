
-- constants
local FROZEN = 2

-- global scope vars
ACT_FROZEN = allocate_mario_action(ACT_FLAG_IDLE)
ACT_FROZEN_SUBMERGED = ACT_GROUP_SUBMERGED | allocate_mario_action(ACT_FLAG_IDLE)

-- global vars
gGlobalSyncTable.freezeHealthDrain = 25

---@param m MarioState
local function mario_update(m)

    if gGlobalSyncTable.gamemode ~= FREEZE_TAG then return end

    if gPlayerSyncTable[m.playerIndex].state == FROZEN then
        -- set model state and action and velocity
        m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
        m.forwardVel = 0
        m.vel.y = 0

        if gGlobalSyncTable.roundState == ROUND_ACTIVE then
            if m.pos.y < m.waterLevel then
                set_mario_action(m, ACT_FROZEN_SUBMERGED, 0)
            else
                set_mario_action(m, ACT_FROZEN, 0)
            end

            -- if mario's health is greater than 0 then subtract his health by 2.5
            if m.health > 0 then
                m.health = m.health - (gGlobalSyncTable.freezeHealthDrain / 10)
            end
        end

        if  m.health <= 0xFF
        and m.playerIndex == 0 then
            gPlayerSyncTable[0].state = TAGGER

            tagger_popup(0)

            m.health = 0x880
            set_mario_action(m, ACT_FREEFALL, 0)
        end
    else
        m.health = 0x880 -- set mario's health to full
    end
end

local function hud_health_render()
    if gPlayerSyncTable[0].state ~= FROZEN then return end
    if gGlobalSyncTable.freezeHealthDrain == 0 then return end

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

    x = x + 2 * scale -- add 2 to x to compensate for smaller size
    y = y + 2 * scale -- add 2 to y to compensate for smaller size
    width = width - 4 * scale
    height = height - 4 * scale
    local health = mario_health_float(gMarioStates[0]) -- get mario's health between 0 and 1
    width = width * health
    djui_hud_set_color(126, 192, 238, 128)
    djui_hud_render_rect(x, y, width, height)

    local text = "Freezing to Death" -- AAA, HELP, IM DYING OF THE COLD, MOM, QUICK, IM DYING, THE SUNS COLD, AAA

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

local function on_warp()

    ---@type MarioState
    local m = gMarioStates[0]

    if gGlobalSyncTable.gamemode ~= FREEZE_TAG then return end
    if not gGlobalSyncTable.eliminateOnDeath then return end
    if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end
    if m.playerIndex ~= 0 then return end

    -- become tagger on death
    if gPlayerSyncTable[0].state == RUNNER or gPlayerSyncTable[0].state == FROZEN then
        gPlayerSyncTable[0].state = TAGGER

        tagger_popup(0)
    end
end

---@param a MarioState
---@param v MarioState
local function allow_pvp(a, v)
    if gGlobalSyncTable.gamemode ~= FREEZE_TAG then return end

    -- check if frozen player is trying to perform a pvp attack
    if gPlayerSyncTable[a.playerIndex].state == FROZEN then return false end
    -- check if a tagger is trying to attack a frozen player
    if gPlayerSyncTable[a.playerIndex].state == TAGGER and gPlayerSyncTable[v.playerIndex].state == FROZEN then return false end
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
    if v.playerIndex ~= 0 then return end
    freeze_tag_handle_pvp(a.playerIndex, v.playerIndex)
end

---@param aI number
---@param vI number
function freeze_tag_handle_pvp(aI, vI)

    local a = gPlayerSyncTable[aI]
    local v = gPlayerSyncTable[vI]

    -- check if tagger tagged runner
    if v.state == RUNNER and a.state == TAGGER and v.invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- freeze runner
        v.state = FROZEN
        -- increase taggers tag count
        a.amountOfTags = a.amountOfTags + 1
        -- create popup
        freezed_popup(aI, vI)
    end

    -- check if runner attacked frozen
    if v.state == FROZEN and a.state == RUNNER and v.invincTimer <= 0 and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- unfreeze freezed player
        v.state = RUNNER
        -- 2 second invincibility
        v.invincTimer = 2 * 30
        -- increase tag count
        a.amountOfTags = a.amountOfTags + 1
        -- create popup
        unfreezed_popup(aI, vI)
        set_mario_action(gMarioStates[vI], ACT_FREEFALL, 0)
        gMarioStates[vI].forwardVel = 0
        gMarioStates[vI].vel.y = 0
    end
end

---@param m MarioState
local function act_frozen(m)
    if gPlayerSyncTable[m.playerIndex].state ~= FROZEN then
        -- prevents being frozen for eternity
        return set_mario_action(m, ACT_IDLE, 0)
    end

    -- set velocity varaibles to none
    m.forwardVel = 0
    m.vel.x = 0
    m.vel.y = 0
    m.vel.z = 0
    m.slideVelX = 0
    m.slideVelZ = 0
    -- freeze mario's animation
    m.marioObj.header.gfx.animInfo.animFrame = m.marioObj.header.gfx.animInfo.animFrame - (m.marioObj.header.gfx.animInfo.animAccel + 1)
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)

hook_mario_action(ACT_FROZEN, act_frozen)
hook_mario_action(ACT_FROZEN_SUBMERGED, act_frozen)