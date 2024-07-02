
local speed = 20
local maxSpeed = 100
local gunCooldown = 1 * 30
local maxHeight = 0

--- @param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    if gPlayerSyncTable[0].state == RUNNER then
        maxSpeed = 60
    else
        maxSpeed = 100
    end

    if m.action == ACT_FLYING_TRIPLE_JUMP then
        maxHeight = m.pos.y + 5000
    end

    -- flight physics
    if m.action == ACT_FLYING then
        if m.controller.buttonDown & A_BUTTON ~= 0
        and ((m.pos.y < maxHeight
        or m.faceAngle.x <= 0)
        or gPlayerSyncTable[0].state == SPECTATOR
        or gPlayerSyncTable[0].state == WILDCARD_ROLE) then
            speed = speed + 1
        elseif m.controller.buttonDown & B_BUTTON ~= 0
        and ((m.pos.y < maxHeight
        or m.faceAngle.x <= 0)
        or gPlayerSyncTable[0].state == SPECTATOR
        or gPlayerSyncTable[0].state == WILDCARD_ROLE) then
            speed = speed - 1
        elseif (m.pos.y < maxHeight
        or m.faceAngle.x <= 0)
        or gPlayerSyncTable[0].state == SPECTATOR
        or gPlayerSyncTable[0].state == WILDCARD_ROLE then
            speed = speed - 0.2
        end

        if m.pos.y > maxHeight
        and m.faceAngle.x > 0
        and gPlayerSyncTable[0].state ~= SPECTATOR
        and gPlayerSyncTable[0].state ~= WILDCARD_ROLE then
            speed = speed - 3
            speed = clampf(speed, 0, maxSpeed)
        else
            speed = clampf(speed, 20, maxSpeed)
        end

        m.forwardVel = speed

        -- it's gun time
        if  m.controller.buttonPressed & binds[BIND_GUN].btn ~= 0
        and gunCooldown >= 1 * 30
        and gPlayerSyncTable[0].state ~= WILDCARD_ROLE
        and gPlayerSyncTable[0].state ~= SPECTATOR then
            E_MODEL_BOOST_TRAIL = gPlayerSyncTable[0].playerTrail
            spawn_sync_object(id_bhvBullet, E_MODEL_BOOST_TRAIL, m.pos.x, m.pos.y, m.pos.z, function (o)
                o.oBulletOwner = network_global_index_from_local(m.playerIndex)
                obj_scale(o, 0.25)
            end)

            gunCooldown = 0
        end

        gunCooldown = gunCooldown + 1
    else
        speed = m.forwardVel
    end

    gunCooldown = gunCooldown + 1

    gunCooldown = clampf(gunCooldown, 0, 1 * 30)
end

local function hud_render()
    if gMarioStates[0].action ~= ACT_FLYING then return end

    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(djui_menu_get_font())

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

    if gPlayerSyncTable[0].state == WILDCARD_ROLE or gPlayerSyncTable[0].state == SPECTATOR then return end
    hud_bullet(gunCooldown, 1 * 30)
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)