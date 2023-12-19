
local finishedChecking = false
local updateFile = nil

local function check_for_updates()
    if not finishedChecking then
        -- attempt to load the current verion's audio file
        updateFile = audio_stream_load_url("https://github.com/EmeraldLoc/tag/" .. version .. ".mp3")
        -- if it doesn't load, the file doesn't exist, so assume there's an update
        if not updateFile.loaded then
            djui_chat_message_create("An update is available for Tag")
        else
            audio_stream_destroy(updateFile)
        end

        finishedChecking = true
    end
end

hook_event(HOOK_MARIO_UPDATE, check_for_updates)