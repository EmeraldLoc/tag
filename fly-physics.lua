
local flyHeight = 0

--- @param m MarioState
local function mario_update(m)

    if m.playerIndex ~= 0 then return end

    -- set flight height
    if m.action == ACT_FLYING_TRIPLE_JUMP then
        flyHeight = m.pos.y + 5000

        if gPlayerSyncTable[0].state == SPECTATOR or gPlayerSyncTable[0].state == ELIMINATED_OR_FROZEN then
            flyHeight = 1000000 -- stupid high number
        end
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)

-- recreated function from c, with changes
--- @param m MarioState
function recreated_fly_physics(m)
    if m.playerIndex ~= 0 then return end

    -- this is not the right way to do it.... but hey if it aint broke dont fix it
    if m.forwardVel < 65 and m.pos.y < flyHeight then
        m.forwardVel = m.forwardVel + 2

        if m.forwardVel > 65 then m.forwardVel = 65 end
    end
    if m.forwardVel > 80 and m.pos.y < flyHeight then m.forwardVel = 80 end
    if m.pos.y > flyHeight then
        m.forwardVel = m.forwardVel - 0.5
    end

    local startPitch = m.faceAngle.y

    if m.input & INPUT_Z_PRESSED ~= 0 then
        if m.area.camera.mode == CAMERA_MODE_BEHIND_MARIO then
            if not camera_config_is_free_cam_enabled() then
                set_camera_mode(m.area.camera, m.area.camera.defMode, 1)
            else
                m.area.camera.mode = CAMERA_MODE_NEWCAM
                gLakituState.mode = CAMERA_MODE_NEWCAM
            end
        end
        return set_mario_action(m, ACT_GROUND_POUND, 1)
    end

    if m.flags & MARIO_WING_CAP == 0 then
        if m.area.camera.mode == CAMERA_MODE_BEHIND_MARIO then
            if not camera_config_is_free_cam_enabled then
                set_camera_mode(m.area.camera, m.area.camera.defMode, 1)
            else
                m.area.camera.mode = CAMERA_MODE_NEWCAM
                gLakituState.mode = CAMERA_MODE_NEWCAM
            end
        end
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if m.area.camera.mode ~= CAMERA_MODE_BEHIND_MARIO then
        if not camera_config_is_free_cam_enabled() then
            set_camera_mode(m.area.camera, CAMERA_MODE_BEHIND_MARIO, 1)
        else
            m.area.camera.mode = CAMERA_MODE_NEWCAM
            gLakituState.mode = CAMERA_MODE_NEWCAM
        end
    end

    if m.actionState == 0 then
        if m.actionArg == 0 then
            set_mario_animation(m, MARIO_ANIM_FLY_FROM_CANNON)
        else
            set_mario_animation(m, MARIO_ANIM_FORWARD_SPINNING_FLIP)
            if m.marioObj.header.gfx.animInfo.animFrame == 1 then
                play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
            end
        end

        if (is_anim_at_end(m)) then
            if m.actionArg == 2 then
                m.actionArg = 1
            end

            set_mario_animation(m, MARIO_ANIM_WING_CAP_FLY)
            m.actionState = 1
        end
    end

    update_flying(m)

    local airStep = perform_air_step(m, 0)
        if airStep == AIR_STEP_NONE then
            m.marioObj.header.gfx.angle.x = -m.faceAngle.x
            m.marioObj.header.gfx.angle.z = m.faceAngle.z
            m.actionTimer = 0
        elseif airStep == AIR_STEP_LANDED then
            set_mario_action(m, ACT_DIVE_SLIDE, 0)

            set_mario_animation(m, MARIO_ANIM_DIVE)
            set_anim_to_frame(m, 7)

            m.faceAngle.x = 0

            if not camera_config_is_free_cam_enabled then
                set_camera_mode(m.area.camera, m.area.camera.defMode, 1)
            else
                m.area.camera.mode = CAMERA_MODE_NEWCAM
                gLakituState.mode = CAMERA_MODE_NEWCAM
            end
            queue_rumble_data_mario(m, 5, 60)
        elseif airStep == AIR_STEP_HIT_WALL then
            if m.wall ~= nil then
                mario_set_forward_vel(m, -16)
                m.faceAngle.x = 0

                if m.vel.y > 0 then
                    m.vel.y = 0
                end


                -- not needed in tag
                --play_sound((m.flags & MARIO_METAL_CAP) ? SOUND_ACTION_METAL_BONK : SOUND_ACTION_BONK, m.marioObj.header.gfx.cameraToObject)

                set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, 0)
                set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)

                if (m.playerIndex == 0) then
                    if not camera_config_is_free_cam_enabled() then
                        set_camera_mode(m.area.camera, m.area.camera.defMode, 1)
                    else
                        m.area.camera.mode = CAMERA_MODE_NEWCAM
                        gLakituState.mode = CAMERA_MODE_NEWCAM
                    end
                end
            else
                if m.actionTimer + 1 == 0 then
                    play_sound(SOUND_ACTION_HIT, m.marioObj.header.gfx.cameraToObject)
                end

                if m.actionTimer == 30 then
                    m.actionTimer = 0
                end

                m.faceAngle.x = m.faceAngle.x - 0x200
                if (m.faceAngle.x < -0x2AAA) then
                    m.faceAngle.x = -0x2AAA
                end

                m.marioObj.header.gfx.angle.x = -m.faceAngle.x
                m.marioObj.header.gfx.angle.z = m.faceAngle.z
            end

        if airStep == AIR_STEP_HIT_LAVA_WALL then
            lava_boost_on_wall(m)
        end
    end

    if startPitch <= 0 and m.faceAngle.x > 0 and m.forwardVel >= 48.0 then
        play_sound(SOUND_ACTION_FLYING_FAST, m.marioObj.header.gfx.cameraToObject)
        queue_rumble_data_mario(m, 50, 40)
    end

    play_sound(SOUND_MOVING_FLYING, m.marioObj.header.gfx.cameraToObject)
    adjust_sound_for_speed(m)
end

hook_mario_action(ACT_FLYING, recreated_fly_physics)
