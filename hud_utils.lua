
SPRITE_INDEX_START_CHAR = string.byte('!')

randomDidYouKnow = 0

-- dw I didnt spend a lifetime doing this, I just copied it from
-- the source code lol. Thats why it's so ugly
local font_normal_widths = {
--        !        "        #        $        %        &        '        (        )        *        +        ,        -        .        /       
            7,      12,      14,      12,      14,      16,       8,      10,      10,      12,      14,       8,      12,       8,      10,
--        0        1        2        3        4        5        6        7        8        9        */
            14,      12,      13,      14,      14,      14,      14,      13,      14,      14,
--        :        ;        <        =        >        ?        @         */
            6,       8,      10,      12,      10,      11,      18,
--        A        B        C        D        E        F        G        H        I        J        K        L        M        N        O        P        Q        R        S        T        U        V        W        X        Y        Z        */
            12,      12,      12,      12,      11,      10,      12,      12,       9,      12,      12,      10,      16,      16,      12,      11,      12,      12,      12,      10,      12,      10,      16,      14,      12,      12,
--        [        \        ]        ^        _        `        */
            10,      10,      10,      12,      12,       8,
--        a        b        c        d        e        f        g        h        i        j        k        l        m        n        o        p        q        r        s        t        u        v        w        x        y        z        */
            10,      10,      10,      10,       9,       8,      12,      10,       7,       9,      10,       4,      13,      10,       9,       9,      10,       9,      10,       9,      10,       9,      14,      12,      10,      10,
--        {        |        }        ~      DEL        */
            10,       8,      10,      16,      10,
}

if SM64COOPDX_VERSION ~= nil then
    -- do you think I care about formatting?
    -- no, I dont
    -- this is what you get
    -- I cant  be bothered
    -- I had to remove f
    -- from every letter
    -- help
    font_normal_widths = {
    --        !        "        #        $        %        &        '        (        )        *        +        ,        -        .        /        */
        0.3125, 0.3750, 0.4375, 0.3750, 0.4375, 0.5000, 0.2500, 0.3125, 0.3125, 0.3750, 0.4375, 0.2500, 0.3750, 0.2500, 0.3125,
    --        0        1        2        3        4        5        6        7        8        9        */
        0.4375, 0.4375, 0.4375, 0.4375, 0.4375, 0.4375, 0.4375, 0.4375, 0.4375, 0.4375,
    --        :        ;        <        =        >        ?        @         */
        0.2500, 0.2500, 0.3125, 0.3750, 0.3125, 0.4375, 0.5750,
    --        A        B        C        D        E                G        H        I        J        K        L        M        N        O        P        Q        R        S        T        U        V        W        X        Y        Z        */
            0.3750, 0.3750, 0.3750, 0.3750, 0.3750, 0.3750, 0.3750, 0.3750, 0.3125, 0.3750, 0.3750, 0.3125, 0.5000, 0.5000, 0.3750, 0.3750, 0.3750, 0.3750, 0.3750, 0.3125, 0.3750, 0.3750, 0.5000, 0.4375, 0.3750, 0.3750,
    --        [        \        ]        ^        _        `        */
        0.3125, 0.3125, 0.3125, 0.3750, 0.3750, 0.2500,
    --        a        b        c        d        e      f          g        h        i        j        k        l        m        n        o        p        q        r        s        t        u        v        w        x        y        z        */
        0.3750, 0.3125, 0.3125, 0.3750, 0.3125, 0.3125, 0.3750, 0.3125, 0.2500, 0.3125, 0.3125, 0.1875, 0.4375, 0.3125, 0.3125, 0.3125, 0.3750, 0.3125, 0.3125, 0.3125, 0.3125, 0.3125, 0.4375, 0.4375, 0.3125, 0.3125,
    --        {        |        }        ~      DEL        */
        0.3125, 0.2500, 0.3125, 0.5000, 0.5000
    }
end

-- recreated from source code
---@param text string
---@return integer
function count_bytes_for_char(text)
    local bytes = 0
    local mask = 1 << 7
    while text & mask ~= 0 do
        bytes = bytes + 1
        mask = mask >> 1
    end
    if bytes then return bytes else return 1 end
end

---@param text string
---@return integer
function convert_unicode_char_to_u64(text)
    local bytes = count_bytes_for_char(text)
    local value = text:byte()

    -- HACK: we only support up to 4 bytes per character
    if bytes > 4 then return 0 end

    bytes = bytes - 1
    while bytes > 0 do
        value = value << 8;
        value = value | text:sub(2):byte()
        bytes = bytes - 1
        text = text:sub(2)
    end
    return value
end

---@param text string
---@param font_widths table
---@return integer
function djui_unicode_get_sprite_width(text, font_widths)
    if text == nil then return 0 end

    -- rambling incoming:
    -- coopdx why do you do this
    -- there was no purpose
    -- it was nicer dividing it by 32
    local coopdxMultiplier = 1
    if usingCoopDX then
        coopdxMultiplier = 32
    end

    -- check for ASCI
    if text:byte() < 128 then
        -- override for space char
        if text:sub(1, 1) == " " then
            if usingCoopDX then return 0.30 * 32 end
            return 6
        end

        -- make sure it's in the valid range
        if (text:byte() < SPRITE_INDEX_START_CHAR) then
            return font_widths[(string.byte("?") - SPRITE_INDEX_START_CHAR) + 1] * coopdxMultiplier
        end

        -- output the ASCII width
        return font_widths[(text:byte() - SPRITE_INDEX_START_CHAR) + 1] * coopdxMultiplier
    end

    -- return default value
    return font_widths[(string.byte('?') - SPRITE_INDEX_START_CHAR) + 1] * coopdxMultiplier
end

function select_random_did_you_know()
    randomDidYouKnow = math.random(1, 29)
end

function hud_did_you_know(fade)

    local text = ""
    local text2 = ""
    local text3 = ""
    local text4 = ""

    -- I had way too much fun with this
    if randomDidYouKnow == 1 then
        text = "Did you know that Taggers can use a Boost?"
        text2 = "To do this, while you're a tagger, make sure the blue bar is filled up, then hit Y."
        text3 = "Once you do this, you will be tagging runners left and right!"
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
        text2 = "It's EmeraldLockdown, a modder who's been modding since 2022 (dang time moves fast)!"
        text3 = "EmeraldLockdown, also known as Emerald, has made many contributions to the project, and modding community."
        text4 = "If your wondering, yes, this is a plug to my other mods :D"
    elseif randomDidYouKnow == 6 then
        text = "Did you know that you suck at the game?"
    elseif randomDidYouKnow == 7 then
        text = "I find it weird that whenever your not online, my productivity increases tenfold."
    elseif randomDidYouKnow == 8 then
        text = "Honestly, I just find stuff to put in here, I really don't know what, there's like 5"
        text2 = "actually helpful \"Did you know's,\" but hey just know a guy typed this stuff out"
        text3 = "at 6:06 on January 13 2024"
    elseif randomDidYouKnow == 9 then
        text = "Did you know that your great at this game?"
    elseif randomDidYouKnow == 10 then
        text = "Ever checked out Geometry Dash? Pretty cool game, 2.2 just came out, 2.21 will be out in"
        text2 = "another 7 years, can't wait honestly."
    elseif randomDidYouKnow == 11 then
        text = "If your playing this mod with cheats, what are you even doing?"
    elseif randomDidYouKnow == 12 then
        text = "Shoutouts to Simpleflips."
    elseif randomDidYouKnow == 13 then
        text = "In the game code, the index of this random did you know is 13, I don't know why you need"
        text2 = "to know that, but now you do"
    elseif randomDidYouKnow == 14 then
        text = "Wanna contribute? Search \"tag mod sm64 github,\" it'll be like the 3rd result. Help get it"
        text2 = "to the top, or no cookie for you >:("
    elseif randomDidYouKnow == 15 then
        text = "As of January 23 2024, 6:11 pm, I'm having good fun writing these."
    elseif randomDidYouKnow == 16 then
        text = "I am not responsible for any grammer mistakes found in this text, dangit you're."
    elseif randomDidYouKnow == 17 then
        text = "When next tag version?!?!?!?"
    elseif randomDidYouKnow == 18 then
        text = "When coop v" .. VERSION_NUMBER + 1
    elseif randomDidYouKnow == 19 then
        text = "Ya know what, a great mod you should download is MarioHunt. Really good mod, made by EmilyEmmi."
    elseif randomDidYouKnow == 20 then
        text = "sm64.us.f3dex2e"
    elseif randomDidYouKnow == 21 then
        text = "Here's a tip, if your ever asked to tip a company, you might not see a \"Nothing\" button, but"
        text2 = "don't worry, it's somewhere there!"
        text4 = "No i'm not a villian to society, it's just that I don't want to tip people... in a AIRPORT"
    elseif randomDidYouKnow == 22 then
        text = "There are 25 random tips/me ranting for no good reason. Anyways I love geography, really"
        text2 = "cool stuff. Just learning about random things about countries and how their borders make"
        text3 = "those things happen is great. I mean just yesterday (today being Tuesday Jan 23 2024) I"
        text4 = "watched a video about how the U.S. transports its nukes, and it... crap ran out of room"
    elseif randomDidYouKnow == 23 then
        text = "I did say there were 25 random tips, if you didn't see that, ignore this."
        text2 = "contains people who can take your house away at any time, lovely!"
        text3 = "They've only had a few accidents"
        text4 = "Also there's 26 random tips, although i'm not gonna update this, so yea..."
    elseif randomDidYouKnow == 24 then
        text = "You should really go check out Flood, super cool gamemode, made by Agent X."
    elseif randomDidYouKnow == 25 then
        text = "Can't wait to become an anarchist. Idk why I said that."
    elseif randomDidYouKnow == 26 then
        text = "I'm 24 of this in, doing 2 more, hope you enjoy. Make sure to like and subscribe,"
        text2 = "only a small percentage of my viewers are subscribed, so if you hit that button,"
        text3 = "it will really help out a ton. It's completely free, and you can change your mind"
        text4 = "at anytime. Thanks! Now enjoy the video! (5 seconds later) Make sure to like and su..."
    elseif randomDidYouKnow == 27 then
        text = "Hate campers? Use this 1 simple trick: diving! Here's how it works:"
        text2 = "1. Hit B"
        text3 = "2. There is no step 2, it's that easy!!!"
    elseif randomDidYouKnow == 28 then
        text = "Don't like the auto hide hud feature? Turn it off in the settings!"
    elseif randomDidYouKnow == 28 then
        text = "Hate romhack cam? Turn it off in the settings!"
    elseif randomDidYouKnow == 28 then
        text = "Think I'm an idiot for picking Y as the button for boosts? Configure it in the settings!"
    elseif randomDidYouKnow == 29 then
        text = "You might wonder when I'm gonna add good romhack support."
        text2 = "The thing is I'm wondering when YOU'RE gonna do it! The tools are there!"
        text3 = "It's simple to add full romhack support, go to romhacks.lua for information."
        text4 = "And yes it's simple, I'm just waay too lazy to do it, plus it's time consuming."
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

---@param text string
---@param x integer
---@param y integer
---@param scale integer
function djui_hud_print_colored_text(text, x, y, scale, opacity)
    local s = ''
	local inSlash = false
    local hex = ""
    if opacity == nil then opacity = 255 end

	-- loop thru each character in the string and render that char
	for i = 1, #text do
        -- get character
		local c = text:sub(i,i)
        -- if character is a backslash, then switch inslash
		if c == "\\" then
			-- we are now in (or out) of the slash, set variable accordingly
			inSlash = not inSlash
            -- reset hex if needed
            if inSlash then
                hex = ""
            end
        elseif inSlash then
            -- set hex var
            hex = hex .. c
		elseif not inSlash then
            if hex:len() == 7 then
                -- get rgb
                local r, g, b = hex_to_rgb(hex)
                -- set color to rgb
                djui_hud_set_color(r, g, b, opacity)
            end
            -- print character
            djui_hud_print_text(c, x, y, scale)
            -- increase position
            x = x + djui_unicode_get_sprite_width(c, font_normal_widths)
		end
	end
end