
ACT_CUSTOM_LAVA_BOOST = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_ATTACKING)

---@param m MarioState
local function act_lava_boost(m)
    if m.flags & MARIO_MARIO_SOUND_PLAYED == 0 then
        play_character_sound_if_no_flag(m, CHAR_SOUND_ON_FIRE, MARIO_MARIO_SOUND_PLAYED)
        queue_rumble_data_mario(m, 5, 80)
    end
    play_character_sound_if_no_flag(m, CHAR_SOUND_ON_FIRE, MARIO_MARIO_SOUND_PLAYED)

    if m.input & INPUT_NONZERO_ANALOG == 0 then
        m.forwardVel = approach_f32(m.forwardVel, 0.0, 0.35, 0.35)
    end

    update_lava_boost_or_twirling(m)

    local step = perform_air_step(m, 0)

    if step == AIR_STEP_LANDED then
        if m.floor.type == SURFACE_BURNING then
            m.actionState = 0
            m.vel.y = 84
            play_character_sound(m, CHAR_SOUND_ON_FIRE)
            queue_rumble_data_mario(m, 5, 80)
        else
            play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_BODY_HIT_GROUND)
            if m.actionState < 2 and m.vel.y < 0 then
                m.vel.y = -m.vel.y * 0.4
                mario_set_forward_vel(m, m.forwardVel * 0.5)
                m.actionState = m.actionState + 1
            else
                return set_mario_action(m, ACT_LAVA_BOOST_LAND, 0)
            end
        end
    elseif step == AIR_STEP_HIT_WALL then
        mario_bonk_reflection(m, 0)
    elseif step == AIR_STEP_HIT_LAVA_WALL then
        lava_boost_on_wall(m)
    end

    set_character_animation(m, CHAR_ANIM_FIRE_LAVA_BURN)
    if m.area.terrainType & TERRAIN_MASK ~= TERRAIN_SNOW and m.flags & MARIO_METAL_CAP == 0
    and m.vel.y > 0 then
        set_mario_particle_flags(m, PARTICLE_FIRE, 0)
        if m.actionState == 0 then
            play_sound(SOUND_MOVING_LAVA_BURN, m.marioObj.header.gfx.cameraToObject)
        end
    end

    m.marioBodyState.eyeState = MARIO_EYES_DEAD

    reset_rumble_timers(m)
    return 0
end

---@param m MarioState
local function on_set_mario_action(m)
    if m.action == ACT_LAVA_BOOST then
        set_mario_action(m, ACT_CUSTOM_LAVA_BOOST, m.actionArg)
    end
end

hook_event(HOOK_ON_SET_MARIO_ACTION, on_set_mario_action)

hook_mario_action(ACT_CUSTOM_LAVA_BOOST, act_lava_boost)