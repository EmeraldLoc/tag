
ACT_CUSTOM_WIND = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_ATTACKING)

---@param m MarioState
local function act_vertical_wind(m)

    local intendedDYaw = m.intendedYaw - m.faceAngle.y
    local intendedMag = m.intendedMag / 32

    play_character_sound_if_no_flag(m, CHAR_SOUND_HERE_WE_GO, MARIO_MARIO_SOUND_PLAYED)
    set_character_animation(m, CHAR_ANIM_AIRBORNE_ON_STOMACH)

    update_air_without_turn(m)

    local step = perform_air_step(m, 0)

    if step == AIR_STEP_LANDED then
        set_mario_action(m, ACT_DIVE_SLIDE, 0)
    elseif step == AIR_STEP_HIT_WALL then
        mario_set_forward_vel(m, -16.0)
    end

    m.marioObj.header.gfx.angle.x = 6144.0 * intendedMag * coss(intendedDYaw)
    m.marioObj.header.gfx.angle.z = -4096.0 * intendedMag * sins(intendedDYaw)
    return 0
end

---@param m MarioState
local function on_set_mario_action(m)
    if m.action == ACT_VERTICAL_WIND then
        set_mario_action(m, ACT_CUSTOM_WIND, m.actionArg)
    end
end

hook_event(HOOK_ON_SET_MARIO_ACTION, on_set_mario_action)

hook_mario_action(ACT_CUSTOM_WIND, act_vertical_wind)