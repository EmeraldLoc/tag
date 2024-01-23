
randomDidYouKnow = 0

function select_random_did_you_know()
    randomDidYouKnow = math.random(1, 5)
end

function hud_did_you_know(fade)

    local text = ""
    local text2 = ""
    local text3 = ""
    local text4 = ""

    if randomDidYouKnow == 1 then
        text = "Did you know that Taggers can use a Boost?"
        text2 = "To do this, while you're a tagger, make sure the blue bar is filled up, then hit Y."
        text3 = "Once you do this, you will be soaring through runners!"
    elseif randomDidYouKnow == 2 then
        text = "Did you know that modifiers are ways to make tag have more varity?"
        text2 = "The current modifier selected will appear at the start of a round in chat."
        text3 = "There are many modifiers, each with their own unique changes!"
    elseif randomDidYouKnow == 3 then
        text = "Did you know that tag was actually made in 2022 by the same author, EmeraldLockdown, as this mod?"
        text2 = "The old tag mod was much worse and was more buggy than this version."
        text3 = "If you wanna check it out, you can at 'sm64ex-coopmods.com'."
    elseif randomDidYouKnow == 4 then
        text = "Did you know that this mod fully supports romhacks right out the gate?"
        text2 = "Levels can be blacklisted with the blacklist command if theres a bad level you dont want to play on,"
        text3 = "especially if there's water in it..."
    elseif randomDidYouKnow == 5 then
        text = "Do you know who the author of this mod is?"
        text2 = "It's EmeraldLockdown, a modder who's been modding since 1995! *cough 2022 cough*"
        text3 = "EmeraldLockdown, also known as Emerald, has made many contributions to the project, and modding community."
        text4 = "If your wondering, yes, this is a plug to my other mods :D"
    end

    local scale = 1

    -- get width of screen and text
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()
    local width = djui_hud_measure_text(text) * scale

    local x = (screenWidth - width) / 2
    local y = 0
    if text4 == "" then
        y = screenHeight - 100
    else
        y = screenHeight - 150
    end

    djui_hud_set_color(255, 255, 255, fade);
    djui_hud_print_text(text, x, y, scale)

    width = djui_hud_measure_text(text2) * scale
    x = (screenWidth - width) / 2
    y = y + 30
    djui_hud_print_text(text2, x, y, scale)

    width = djui_hud_measure_text(text3) * scale
    x = (screenWidth - width) / 2
    y = y + 30
    djui_hud_print_text(text3, x, y, scale)

    width = djui_hud_measure_text(text4) * scale
    x = (screenWidth - width) / 2
    y = y + 30
    djui_hud_print_text(text4, x, y, scale)
end