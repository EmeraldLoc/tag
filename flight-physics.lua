
local speed = 20
local maxSpeed = 100
local gunCooldown = 1 * 30

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
            speed = speed - 0.2
        end

        speed = clampf(speed, 20, maxSpeed)

        m.forwardVel = speed

        -- it's gun time
        if  m.controller.buttonPressed & binds[BIND_GUN].btn ~= 0
        and gunCooldown >= 1 * 30 then
            spawn_sync_object(id_bhvBullet, E_MODEL_BOOST_TRAIL, m.pos.x, m.pos.y, m.pos.z, function (o)
                o.oBulletOwner = m.playerIndex
                obj_scale(o, 0.25)
            end)

            gunCooldown = 0
        end

        gunCooldown = gunCooldown + 1
    else
        speed = 20
    end

    gunCooldown = gunCooldown + 1

    gunCooldown = clampf(gunCooldown, 0, 1 * 30)
end

local function hud_bullet()
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local scale        = 1
    local width        = 128 * scale
    local height       = 16 * scale
    local x            = math.floor((screenWidth - width) / 2)
    local y            = math.floor(screenHeight - height - 4 * scale)
    local gunTime      = gunCooldown / 30

    if gPlayerSyncTable[0].state == TAGGER
    and boosts_enabled() then
        y = y - 32
    end

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x, y, width, height)

    x = x + 2 * scale
    y = y + 2 * scale
    width = width - 4 * scale
    height = height - 4 * scale
    width = math.floor(width * gunTime)

    djui_hud_set_color(0, 137, 237, 128)
    djui_hud_render_rect(x, y, width, height)

    if gunCooldown < 1 * 30 then
        text = "Recharging"
    else
        text = "Shoot (" .. button_to_text(binds[BIND_GUN].btn) .. ")"
    end

    scale = 0.25
    width = djui_hud_measure_text(text) * scale
    height = 32 * scale
    x = (screenWidth - width) / 2
    y = screenHeight - 28

    if gPlayerSyncTable[0].state == TAGGER
    and boosts_enabled() then
        y = y - 32
    end

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - 6, y, width + 12, height)

    djui_hud_set_color(0, 162, 255, 128)
    djui_hud_print_text(text, x, y, scale)
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
    djui_hud_render_rect(x, y, width, height + 20)

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_text("A & B", x + 6.25, y + height - 10, 0.75)

    width = 25
    height = linear_interpolation(speed, 0, 275, 20, maxSpeed)
    x = screenWidth - width - 62.5
    y = screenHeight / 2 - height + 150 - 12.5

    djui_hud_set_color(220, 220, 220, 200)
    djui_hud_render_rect(x, y, width, height)

    hud_bullet()
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)