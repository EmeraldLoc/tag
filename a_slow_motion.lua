
local timer = 0
local slowMotion = false

function enable_slow_motion()
    slowMotion = true
end

function disable_slow_motion()
    slowMotion = false
end

function is_slow_motion_on()
    return slowMotion
end

local function update()
    if slowMotion then
        if timer ~= 0 then
            enable_time_stop_including_mario()
            timer = timer - 1
        else
            disable_time_stop_including_mario()
            timer = 3
        end
    else
        disable_time_stop_including_mario()
    end
end

hook_event(HOOK_UPDATE, update)