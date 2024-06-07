
local timer = 0
local slowMotion = false

function slow_motion()
    slowMotion = true
    timer = 3
end

function in_slow_motion()
    return slowMotion
end

local function update()
    if slowMotion then
        if timer ~= 0 then
            enable_time_stop_including_mario()
            timer = timer - 1
        else
            disable_time_stop_including_mario()
            slowMotion = false
        end
    end
end

hook_event(HOOK_UPDATE, update)