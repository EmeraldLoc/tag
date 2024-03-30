
version = "v2.3"
local finishedChecking = false
local updateFile = nil

local function check_for_updates()
    -- you may take this code for your own mods, no credit is required

    if not finishedChecking then
        finishedChecking = true

        if VERSION_NUMBER < 37 then return end -- only works in v37
        -- attempt to load the current verion's audio file
        local url = "https://github.com/EmeraldLoc/Tag/raw/main/" .. version .. ".mp3"
        updateFile = audio_stream_load_url(url)
        -- if it doesn't load, the file doesn't exist, so assume there's an update
        -- a caviat with this trick is that if you don't have a internet connection,
        -- or fail to retrieve the file, it'll return an update rather than returning
        -- that your up to date, slight downside
        if updateFile == nil or not updateFile.loaded or updateFile.handle == 0 then
            djui_chat_message_create("An update is available for Tag!")
        else
            djui_chat_message_create("Tag is up to date!")
        end
    end
end

hook_event(HOOK_MARIO_UPDATE, check_for_updates)