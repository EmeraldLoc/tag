-- forces romhack camera

---@param m MarioState
local function mario_update(m)
    -- don't do anything if freecam is enabled
    if camera_config_is_free_cam_enabled() then return end
    -- if we don't use romhack cam, set the function to 1 and return
    if not useRomhackCam then
        camera_set_use_course_specific_settings(1)
        return
    end

    -- if camera mode is set to something not valid, then set camera mode to romhack cam
    if m.area.camera.mode ~= CAMERA_MODE_ROM_HACK and m.area.camera.mode ~= CAMERA_MODE_C_UP and m.area.camera.mode ~= CAMERA_MODE_WATER_SURFACE and m.area.camera.mode ~= CAMERA_MODE_BEHIND_MARIO then
        set_camera_mode(m.area.camera, CAMERA_MODE_ROM_HACK, 0)
    end

    -- what the function says
    camera_set_use_course_specific_settings(0)
end

hook_event(HOOK_MARIO_UPDATE, mario_update)