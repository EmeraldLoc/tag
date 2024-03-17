
local speed = 20
local maxSpeed = 100

--- @param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    if gPlayerSyncTable[0].state == RUNNER then
        maxSpeed = 70
    else
        maxSpeed = 100
    end

    -- flight physics
    if m.action == ACT_FLYING then
        if m.controller.buttonDown & A_BUTTON ~= 0 then
            speed = speed + 1
        elseif m.controller.buttonDown & B_BUTTON ~= 0 then
            speed = speed - 1
        else
            speed = speed - 0.6
        end

        speed = clampf(speed, 20, maxSpeed)

        m.forwardVel = speed
    else
        speed = 20
    end
end

local function hud_render()

    if gMarioStates[0].action ~= ACT_FLYING then return end

    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local width = 50
    local height = 300
    local x = screenWidth - width - 50
    local y = screenHeight / 2 - (height / 2)

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x, y, width, height)

    width = 25
    height = linear_interpolation(speed, 0, 275, 20, maxSpeed)
    x = screenWidth - width - 62.5
    y = screenHeight / 2 - height + 150 - 12.5

    djui_hud_set_color(220, 220, 220, 200)
    djui_hud_render_rect(x, y, width, height)
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)