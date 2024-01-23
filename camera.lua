-- forces romhack camera

---@param m MarioState
local function mario_update(m)

    if m.area.camera.mode ~= CAMERA_MODE_ROM_HACK and m.area.camera.mode ~= CAMERA_MODE_C_UP then
        set_camera_mode(m.area.camera, CAMERA_MODE_ROM_HACK, 0)
    end

    camera_set_use_course_specific_settings(0)
end

hook_event(HOOK_MARIO_UPDATE, mario_update)