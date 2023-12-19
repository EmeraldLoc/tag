
local finishedChecking = false
local updateFile = nil

local function check_for_updates()
    if not finishedChecking then
        -- attempt to load the current verion's audio file
        local url = "https://github.com/EmeraldLoc/Tag/raw/main/" .. version .. ".mp3"
        updateFile = audio_stream_load_url(url)
        -- if it doesn't load, the file doesn't exist, so assume there's an update
        if updateFile == nil or not updateFile.loaded or updateFile.handle == 0 then
            djui_chat_message_create("An update is available for Tag!")
        else
            djui_chat_message_create("Tag is up to date!")
        end

        finishedChecking = true
    end
end

hook_event(HOOK_MARIO_UPDATE, check_for_updates)