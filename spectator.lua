
ACT_FREECAM_SUBMERGED = ACT_GROUP_SUBMERGED | allocate_mario_action(ACT_FLAG_MOVING)
ACT_FREECAM = allocate_mario_action(ACT_FLAG_MOVING)
ACT_FOLLOW_IDLE_SUBMERGED = ACT_GROUP_SUBMERGED | allocate_mario_action(ACT_FLAG_IDLE)
ACT_FOLLOW_IDLE = allocate_mario_action(ACT_FLAG_IDLE)

spectatorHideHud = false

local followTargetIndex = 0

---@param m MarioState
local function freecam(m)

    -- set action to idle if we are not in freecam
    if gPlayerSyncTable[m.playerIndex].spectatorState ~= SPECTATOR_STATE_FREECAM then
        return set_mario_action(m, ACT_IDLE, 0)
    end

    -- set mario's angle to his intended pos
    m.faceAngle.y = m.intendedYaw

    -- drop any held object if we are holding a object
    mario_drop_held_object(m)

    -- set quicksand depth var
    m.quicksandDepth = 0

    -- air steps
    update_air_without_turn(m)
    perform_air_step(m, 0)

    -- y velocity
    if m.controller.buttonDown & Z_TRIG ~= 0 then
        m.vel.y = -50
    elseif m.controller.buttonDown & A_BUTTON ~= 0 then
        m.vel.y = 50
    else
        m.vel.y = 0
    end

    -- set all velocity vars to 0 if we aren't holding the stick
    if m.controller.rawStickX == 0 and m.controller.rawStickY == 0 then
        m.vel.x = 0
        m.vel.z = 0
        m.forwardVel = 0
    end

    local speed = 25

    if m.controller.buttonDown & B_BUTTON ~= 0 then
        speed = 75
    end

    if m.forwardVel > 0 then
        m.forwardVel = speed
    end

    return 0
end

---@param m MarioState
local function follow_idle(m)

    if (gPlayerSyncTable[m.playerIndex].state ~= SPECTATOR
    and (gPlayerSyncTable[m.playerIndex
    ].state ~= ELIMINATED_OR_FROZEN
    or gGlobalSyncTable.gamemode == FREEZE_TAG))
    or gPlayerSyncTable[m.playerIndex].spectatorState ~= SPECTATOR_STATE_FOLLOW then
        return set_mario_action(m, ACT_IDLE, 0)
    end

    perform_air_step(m, 0)

    m.forwardVel = 0
    m.vel.x = 0
    m.vel.y = 0
    m.vel.z = 0
    m.slideVelX = 0
    m.slideVelZ = 0

    if not gNetworkPlayers[followTargetIndex].connected
    or gPlayerSyncTable[followTargetIndex].state == SPECTATOR
    or (gPlayerSyncTable[followTargetIndex].state == ELIMINATED_OR_FROZEN
    and gGlobalSyncTable.gamemode ~= FREEZE_TAG) then return 0 end

    local targetMario = gMarioStates[followTargetIndex]

    m.pos.x = targetMario.pos.x
    m.pos.y = targetMario.pos.y
    m.pos.z = targetMario.pos.z

    return 0
end

---@param m MarioState
local function mario_update(m)

    local s = gPlayerSyncTable[m.playerIndex]

    if (s.state == SPECTATOR
    or (s.state == ELIMINATED_OR_FROZEN and gGlobalSyncTable.gamemode ~= FREEZE_TAG))
    and s.spectatorState ~= SPECTATOR_STATE_MARIO then
        obj_set_model_extended(m.marioObj, E_MODEL_NONE)
    end

    if m.playerIndex ~= 0 then return end

    if s.state ~= SPECTATOR
    and (s.state ~= ELIMINATED_OR_FROZEN
    or gGlobalSyncTable.gamemode == FREEZE_TAG) then
        s.spectatorState = SPECTATOR_STATE_MARIO
        spectatorHideHud = false

        return
    end

    if m.controller.buttonPressed & D_JPAD ~= 0 then
        s.spectatorState = s.spectatorState - 1
        if s.spectatorState < SPECTATOR_STATE_MARIO then s.spectatorState = SPECTATOR_STATE_FOLLOW end
    end

    if m.controller.buttonPressed & U_JPAD ~= 0 then
        s.spectatorState = s.spectatorState + 1
        if s.spectatorState > SPECTATOR_STATE_FOLLOW then s.spectatorState = SPECTATOR_STATE_MARIO end
    end

    if m.controller.buttonPressed & X_BUTTON ~= 0 then
        spectatorHideHud = not spectatorHideHud
    end

    if s.spectatorState == SPECTATOR_STATE_FREECAM then
        -- set action to freecam action depending on if we are submerged or not
        if m.pos.y < m.waterLevel - 50 then
            set_mario_action(m, ACT_FREECAM_SUBMERGED, 0)
        else
            set_mario_action(m, ACT_FREECAM, 0)
        end
    elseif s.spectatorState == SPECTATOR_STATE_FOLLOW then
        -- set action to follow idle action depending on if we are submerged or not
        if m.pos.y < m.waterLevel - 50 then
            set_mario_action(m, ACT_FOLLOW_IDLE_SUBMERGED, 0)
        else
            set_mario_action(m, ACT_FOLLOW_IDLE, 0)
        end

        -- follow index selection
        if m.controller.buttonPressed & R_JPAD ~= 0 or followTargetIndex == 0 then
            local originalIndex = followTargetIndex
            followTargetIndex = followTargetIndex + 1

            while not gNetworkPlayers[followTargetIndex].connected
            or (gPlayerSyncTable[followTargetIndex].state == SPECTATOR
            or (gPlayerSyncTable[followTargetIndex].state == ELIMINATED_OR_FROZEN
            and gGlobalSyncTable.gamemode ~= FREEZE_TAG)) do
                followTargetIndex = followTargetIndex + 1

                if followTargetIndex >= MAX_PLAYERS then
                    followTargetIndex = originalIndex
                    break
                end
            end
        end

        if m.controller.buttonPressed & L_JPAD ~= 0 then
            local originalIndex = followTargetIndex
            followTargetIndex = followTargetIndex - 1

            while not gNetworkPlayers[followTargetIndex].connected
            or gPlayerSyncTable[followTargetIndex].state == SPECTATOR
            or (gPlayerSyncTable[followTargetIndex].state == ELIMINATED_OR_FROZEN
            and gGlobalSyncTable.gamemode ~= FREEZE_TAG) do
                followTargetIndex = followTargetIndex - 1

                if followTargetIndex <= 0 then
                    followTargetIndex = originalIndex
                    break
                end
            end
        end
    end
end

local function hud_bottom_render()

    if spectatorHideHud then return end

    local s = gPlayerSyncTable[0]
    local text = ""

    if s.spectatorState == SPECTATOR_STATE_FREECAM then
        text = "Freecam"
    elseif s.spectatorState == SPECTATOR_STATE_MARIO then
        text = "Mario"
    elseif s.spectatorState == SPECTATOR_STATE_FOLLOW then

        local isPlayerConncted = false
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected
            and gPlayerSyncTable[i].state ~= SPECTATOR
            and (gPlayerSyncTable[i].state ~= ELIMINATED_OR_FROZEN
            or gGlobalSyncTable.gamemode == FREEZE_TAG) then
                isPlayerConncted = true
                break
            end
        end

        if isPlayerConncted then
            text = "< " .. strip_hex(gNetworkPlayers[followTargetIndex].name) .. " (" .. tostring(network_global_index_from_local(followTargetIndex)) .. ")" .. " >"
        else
            text = "Nobody is connected"
        end
    end

    local scale = 1.5

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()
    local width = djui_hud_measure_text(text) * scale

    local x = (screenWidth - width) / 2.0
    local y = screenHeight - (32 * scale)

    -- render rect
    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - (12 * scale), y, width + (24 * scale), (32 * scale))

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
end

local function on_render()
    -- sanity checks
    if gPlayerSyncTable[0].state ~= SPECTATOR
    and (gPlayerSyncTable[0].state ~= ELIMINATED_OR_FROZEN
    or gGlobalSyncTable.gamemode == FREEZE_TAG) then return end
    if gGlobalSyncTable.roundState == ROUND_RUNNERS_WIN
    or gGlobalSyncTable.roundState == ROUND_TAGGERS_WIN
    or gGlobalSyncTable.roundState == ROUND_VOTING then return end

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    hud_bottom_render()
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_render)

hook_mario_action(ACT_FREECAM, freecam)
hook_mario_action(ACT_FREECAM_SUBMERGED, freecam)
hook_mario_action(ACT_FOLLOW_IDLE, follow_idle)
hook_mario_action(ACT_FOLLOW_IDLE_SUBMERGED, follow_idle)