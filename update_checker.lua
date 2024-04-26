
version = "v2.3"
local prevVersion = "v2.21"
local finishedChecking = false
local updateFile = nil
local updateTimer = 0
local fade = 255

local function check_for_updates(m)

    if m.playerIndex ~= 0 then return end

    -- you may take this code for your own mods, no credit is required
    if not finishedChecking then

        if updateTimer < 0.2 * 30 then
            updateTimer = updateTimer + 1
            return
        end

        -- attempt to load the current verion's audio file
        local url = "https://github.com/EmeraldLoc/Tag/raw/main/" .. version .. ".mp3"
        updateFile = audio_stream_load_url(url)
        -- ensure the version we're using actually has this function working
        if not updateFile.isStream then
            finishedChecking = true
            updateTimer = 0
            return
        end
        -- if it doesn't load, the file doesn't exist, so assume there's an update
        -- a caviat with this trick is that if you don't have a internet connection,
        -- or fail to retrieve the file, it'll return an update rather than returning
        -- that you're up to date, slight downside
        if updateFile == nil or not updateFile.loaded or updateFile.handle == 0 then
            -- for beta lobbies, see if we're on a beta by loading the previous version
            url = "https://github.com/EmeraldLoc/Tag/raw/main/" .. prevVersion .. ".mp3"
            updateFile = audio_stream_load_url(url)
            if updateFile == nil or not updateFile.loaded or updateFile.handle == 0 then
                djui_chat_message_create("An update is available for Tag!")
            else
                djui_chat_message_create("You're playing a beta version of Tag, enjoy!")
            end
        end

        finishedChecking = true
        updateTimer = 0
    end
end

local function hud_render()
    if finishedChecking then
        if updateTimer > 0.6 * 30 then
            if fade == 0 then return end
            fade = clampf(fade - 15, 0, 255)
        end
        updateTimer = updateTimer + 1
    end

    local text = "Checking for Updates"
    local scale = 2

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    djui_hud_set_color(28, 28, 30, fade)
    djui_hud_render_rect(0, 0, screenWidth, screenHeight)

    local width = djui_hud_measure_text(text) * scale

    local x = (screenWidth - width) / 2
    local y = screenHeight - 100

    djui_hud_set_color(255, 255, 255, fade);
    djui_hud_print_text(text, x, y, scale)

    scale = 0.5

    x = (screenWidth - (TEXTURE_TAG_LOGO.width * scale)) / 2
    y = ((screenHeight - (TEXTURE_TAG_LOGO.height * scale)) / 2) - 50

    djui_hud_render_texture(TEXTURE_TAG_LOGO, x, y, scale, scale)
end

hook_event(HOOK_MARIO_UPDATE, check_for_updates)
hook_event(HOOK_ON_HUD_RENDER, hud_render)