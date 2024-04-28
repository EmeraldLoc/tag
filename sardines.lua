
-- constants
-- this is another player role, a custom one, you will notice it's set to the same thing
-- as main.lua's WILDCARD_ROLE variable, this is intentional
local FINISHED = 2

-- variables
local fade = 0
local hidingPos = { x = 0, y = 0, z = 0 }

---@param m MarioState
local function mario_update(m)

    if gGlobalSyncTable.gamemode ~= SARDINES then return end
    if m.playerIndex ~= 0 then return end

    m.health = 0x880 -- set mario's health to full

    if gPlayerSyncTable[m.playerIndex].state == FINISHED then
        -- set model state
        m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA -- vanish cap style
        -- make mario have vanish cap and wing cap (wait so why did I do the line above? Idk)
        m.flags = m.flags | MARIO_VANISH_CAP
        m.flags = m.flags | MARIO_WING_CAP
    end

    if gGlobalSyncTable.roundState == ROUND_HIDING_SARDINES
    and gPlayerSyncTable[0].state ~= RUNNER then
        m.freeze = 1
    elseif gGlobalSyncTable.roundState == ROUND_HIDING_SARDINES
    and gPlayerSyncTable[0].state == RUNNER then
        if m.action & ACT_GROUP_MASK ~= ACT_GROUP_AIRBORNE then
            vec3f_copy(hidingPos, m.pos)
        end
    end

    if gGlobalSyncTable.roundState == ROUND_ACTIVE
    and gPlayerSyncTable[0].state == RUNNER then
        m.freeze = 1
        if m.pos ~= hidingPos then
            vec3f_copy(m.pos, hidingPos)
        end

        if  m.action ~= ACT_FREEFALL
        and m.action ~= ACT_FREEFALL_LAND
        and m.action ~= ACT_FREEFALL_LAND_STOP
        and m.action ~= ACT_IDLE
        and m.action ~= ACT_LEDGE_GRAB then
            set_mario_action(m, ACT_FREEFALL, 0)
        end

        m.vel.x = 0
        m.vel.y = 0
        m.vel.z = 0
        m.slideVelX = 0
        m.slideVelZ = 0
        m.forwardVel = 0
    end
end

local function hud_black_bg()
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    djui_hud_set_color(28, 28, 30, fade)
    djui_hud_render_rect(0, 0, screenWidth, screenHeight)
end

local function hud_waiting()

    local text = "Time Remaining: " .. math.floor(gGlobalSyncTable.displayTimer / 30)

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text)

    local x = (screenWidth - width) / 2
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)

    text = "The Sardine is Hiding..."

    -- get width of screen and text
    local screenHeight = djui_hud_get_screen_height()
    local height = 32

    width = djui_hud_measure_text(text)
    x = (screenWidth - width) * 0.5
    y = (screenHeight - height) * 0.5

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_gamemode()
    local text = "Gamemode is set to " .. get_gamemode_including_random(gGlobalSyncTable.gamemode)

    local x = 40
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_colored_text(text, x, y, 1, fade)
end

local function hud_current_sardine()

    local sardine = 0
    for i = 1, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected and gPlayerSyncTable[i].state == RUNNER then
            sardine = i
            break
        end
    end

    local text = "The Sardine is " .. get_player_name(sardine)

    local x = 40
    local y = 60

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_colored_text(text, x, y, 1, fade)
end

local function hud_level()
    local text = "Level is " .. name_of_level(gNetworkPlayers[0].currLevelNum, gNetworkPlayers[0].currAreaIndex, levels[gGlobalSyncTable.selectedLevel])

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text)

    local x = screenWidth - width - 40
    local y = 60

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_text(text, x, y, 1)
end

local function hud_modifier()
    local text = "Modifier is set to " .. get_modifier_including_random()

    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(strip_hex(text))

    local x = screenWidth - width - 40
    local y = 20

    djui_hud_set_color(255, 255, 255, fade)
    djui_hud_print_colored_text(text, x, y, 1, fade)
end

local function hud_render()
    if gGlobalSyncTable.gamemode ~= SARDINES then return end

    -- set djui font and resolution
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    -- check that we dont have the modifier MODIFIER_NO_RADAR enabled
    if gGlobalSyncTable.modifier ~= MODIFIER_NO_RADAR then
        -- render radar for each player
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- make sure the states line up
                if gPlayerSyncTable[0].state == RUNNER and gPlayerSyncTable[i].state == TAGGER then -- check if we meet the checks to render the radar
                    render_radar(gMarioStates[i], icon_radar[i], false) -- render radar on player
                end
            end
        end
    end

    if gGlobalSyncTable.roundState == ROUND_HIDING_SARDINES
    and gPlayerSyncTable[0].state ~= RUNNER then
        fade = fade + 20
    else
        fade = fade - 20
    end

    fade = clampf(fade, 0, 255)

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    hud_black_bg()
    hud_waiting()
    hud_gamemode()
    hud_current_sardine()
    hud_level()
    hud_modifier()
    hud_did_you_know(fade)
end

---@param a MarioState
---@param v MarioState
local function allow_pvp(a, v)
    if gGlobalSyncTable.gamemode ~= SARDINES then return end

    -- use allow pvp instead of on pvp so that the sardine never takes kb (pvp hit reg isn't that important here)
    if v.playerIndex ~= 0 then return false end
    -- handle pvp if we are the victim
    sardines_handle_pvp(a.playerIndex, v.playerIndex)

    return false
end

---@param aI number
---@param vI number
function sardines_handle_pvp(aI, vI)
    -- this checks and sets our states
    local a = gPlayerSyncTable[aI]
    local v = gPlayerSyncTable[vI]

    -- check if tagger tagged runner
    if v.state == RUNNER and a.state == TAGGER and v.invincTimer <= 0
    and gGlobalSyncTable.roundState == ROUND_ACTIVE then
        -- set us to be finished
        a.state = FINISHED

        -- create popup
        found_sardine_popup(aI)
        -- increase amount of tags and set invincibility timer to 1 second
        a.amountOfTags = a.amountOfTags + 1
        a.invincTimer = 1 * 30
    end
end

---@param m MarioState
---@param o Object
---@param intee InteractionType
local function allow_interact(m, o, intee)
    if gGlobalSyncTable.gamemode ~= SARDINES then return end

    -- check if player interacts with another player
    if intee == INTERACT_PLAYER then
        for i = 0, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected then
                -- find the other player and check his state
                if gMarioStates[i].marioObj == o and (gPlayerSyncTable[m.playerIndex].state == FINISHED or gPlayerSyncTable[i].state == FINISHED) then
                    -- don't allow the interaction
                    return false
                end
            end
        end
    end
end

---@param m MarioState
local function character_sound(m)

    if gGlobalSyncTable.gamemode ~= SARDINES then return end

    local s = gPlayerSyncTable[m.playerIndex]

    if  s.state == FINISHED or s.state == RUNNER
    and m.playerIndex ~= 0 then
        return 0
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_CHARACTER_SOUND, character_sound)