
TEXTURE_QUARTER_CIRCLE = get_texture_info("quarter_circle")

local didYouKnowHudRendering = 0
local randomDidYouKnow = 1

---@param m MarioState
local function mario_update(m)
    didYouKnowHudRendering = didYouKnowHudRendering - 1
    if didYouKnowHudRendering <= 0 then
        randomDidYouKnow = math.random(1, 34)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)

function hud_did_you_know(fade)
    didYouKnowHudRendering = 1 * 30

    local text = ""
    local text2 = ""
    local text3 = ""
    local text4 = ""

    -- I have way too much fun with this
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
        text3 = "If you wanna check it out, you may be able to on the sm64ex-coop discord server."
    elseif randomDidYouKnow == 4 then
        text = "Did you know that this mod fully supports romhacks right out the gate?"
        text2 = "Levels can be blacklisted with the blacklist command if theres a bad level you dont want to play on,"
        text3 = "especially if there's water in it..."
    elseif randomDidYouKnow == 5 then
        text = "The author of this mod is EmeraldLockdown."
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
        text = "As of January 23 2024, 6:11 pm CT, I'm having good fun writing these."
    elseif randomDidYouKnow == 16 then
        text = "I am not responsible for any grammer mistakes found in this text, dangit you're."
    elseif randomDidYouKnow == 17 then
        text = "When next tag version?!?!?!?"
    elseif randomDidYouKnow == 18 then
        if usingCoopDX then
            text = "When coopdx v" .. SM64COOPDX_VERSION + 0.1
        else
            text = "When coop v" .. VERSION_NUMBER + 1
        end
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
    elseif randomDidYouKnow == 30 then
        text = "Chances are, if there's something you don't like, you can fix it in the settings"
        text2 = "Some settings may be server/moderator only though, so yeaaa..."
    elseif randomDidYouKnow == 31 then
        text = "Check out Arena Bitforts, a super dope level made by Chilly!"
    elseif randomDidYouKnow == 32 then
        text = "Check out Shine Thief, a Mario Kart style game of Shine Thief, items and all!"
        text2 = "Made by EmilyEmmi"
    elseif randomDidYouKnow == 33 then
        text = "A mod you should check out is Duels. It's pretty much in the title of what the mod does."
        text2 = "Made by EmilyEmmi, the mod is a blast and really test's your skills!"
    elseif randomDidYouKnow == 34 then
        text = "Romhack not showing up? Try going to the tag settings and seeing if the hack is there."
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
            x = x + (djui_hud_measure_text(c) * scale)
		end
	end
end

---@param x number|integer
---@param y number|integer
---@param width number|integer
---@param height number|integer
---@param oR number|integer
---@param oG number|integer
---@param oB number|integer
---@param thickness number|integer
---@param opacity number|integer|nil
function djui_hud_render_rect_outlined(x, y, width, height, oR, oG, oB, thickness, opacity)
    if opacity == nil then opacity = 255 end
    -- render main rect
    djui_hud_render_rect(x, y, width, height)
    -- set outline color to, well, outline color
    djui_hud_set_color(oR, oG, oB, opacity)
    -- render rect outside of each side
    djui_hud_render_rect(x - thickness, y - thickness, thickness, height + thickness * 2)
    djui_hud_render_rect(x + (width - thickness) + thickness, y, thickness, height + thickness)
    djui_hud_render_rect(x, y - thickness, width + thickness, thickness)
    djui_hud_render_rect(x, y + (height - thickness) + thickness, width, thickness)
end

---@param x number|integer
---@param y number|integer
---@param width number|integer
---@param height number|integer
---@param cornerRaidus number|integer
function djui_hud_render_rect_rounded(x, y, width, height, cornerRaidus)
    -- it's called black magic
    djui_hud_render_rect(x + (cornerRaidus / 2), y, width - cornerRaidus, height)
    djui_hud_render_rect(x, y + (cornerRaidus / 2), cornerRaidus / 2, height - cornerRaidus)
    djui_hud_render_rect(x + width - cornerRaidus / 2, y + (cornerRaidus / 2), cornerRaidus / 2, height - cornerRaidus)
    -- render corners
    local circleDimensions = (1 / 64) * cornerRaidus / 2
    -- top left corner
    djui_hud_render_texture(TEXTURE_QUARTER_CIRCLE, x, y, circleDimensions, circleDimensions)
    -- bottom left corner
    djui_hud_set_rotation(0x4000, 0, 0)
    djui_hud_render_texture(TEXTURE_QUARTER_CIRCLE, x, y + height, circleDimensions, circleDimensions)
    -- top right corner
    djui_hud_set_rotation(-0x4000, 0, 0)
    djui_hud_render_texture(TEXTURE_QUARTER_CIRCLE, x + width, y, circleDimensions, circleDimensions)
    -- bottom right corner
    djui_hud_set_rotation(0x8000, 0, 0)
    djui_hud_render_texture(TEXTURE_QUARTER_CIRCLE, x + width, y + height, circleDimensions, circleDimensions)
    djui_hud_set_rotation(0, 0, 0)
end

-- currently only viable with coopdx
---@param x number|integer
---@param y number|integer
---@param width number|integer
---@param height number|integer
---@param oR number|integer
---@param oG number|integer
---@param oB number|integer
---@param thickness number|integer
---@param opacity number|integer|nil
function djui_hud_render_rect_rounded_outlined(x, y, width, height, oR, oG, oB, thickness, opacity)
    if opacity == nil then opacity = 255 end
    local cornerRaidus = thickness
    -- render rounded rect using those saved colors
    djui_hud_render_rect(x, y, width, height)
    -- render rect outside of each side
    djui_hud_set_color(oR, oG, oB, opacity)
    djui_hud_render_rect(x - thickness, y, thickness, height)
    djui_hud_render_rect(x + (width - thickness) + thickness, y, thickness, height)
    djui_hud_render_rect(x, y - thickness, width, thickness)
    djui_hud_render_rect(x, y + (height - thickness) + thickness, width, thickness)
    -- render outline corners
    local circleDimensions = (1 / 64) * cornerRaidus
    -- top left corner
    djui_hud_render_texture(TEXTURE_QUARTER_CIRCLE, x - thickness, y - thickness, circleDimensions, circleDimensions)
    -- bottom left corner
    djui_hud_set_rotation(0x4000, 0, 0)
    djui_hud_render_texture(TEXTURE_QUARTER_CIRCLE, x - thickness, y + height + thickness, circleDimensions, circleDimensions)
    -- top right corner
    djui_hud_set_rotation(-0x4000, 0, 0)
    djui_hud_render_texture(TEXTURE_QUARTER_CIRCLE, x + width + thickness, y - thickness, circleDimensions, circleDimensions)
    -- bottom right corner
    djui_hud_set_rotation(0x8000, 0, 0)
    djui_hud_render_texture(TEXTURE_QUARTER_CIRCLE, x + width + thickness, y + height + thickness, circleDimensions, circleDimensions)
    djui_hud_set_rotation(0, 0, 0)
end

-- this entire snippet for the player head was made by EmilyEmmi (with adjustments for tag made by me :), thanks!
local PART_ORDER = {
    SKIN,
    HAIR,
    CAP,
}

HEAD_HUD = get_texture_info("hud_head_recolor")
WING_HUD = get_texture_info("hud_wing")

-- the actual head render function.
--- @param index integer
--- @param x integer
--- @param y integer
--- @param scaleX number
--- @param scaleY number
--- @param opacity number|nil
function render_player_head(index, x, y, scaleX, scaleY, opacity)
    if opacity == nil then opacity = 255 end
    local m = gMarioStates[index]
    local np = gNetworkPlayers[index]

    local alpha = 255 / (255 / opacity)
    if m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA ~= 0 then
        alpha = 100 / (255 / opacity) -- vanish effect
    end
    local isMetal = false

    local tileY = m.character.type
    for i = 1, #PART_ORDER do
        local color = {r = 255, g = 255, b = 255}
		if m.marioBodyState.modelState & MODEL_STATE_METAL ~= 0 then -- metal
			color = network_player_palette_to_color(np, METAL, color)
			djui_hud_set_color(color.r, color.g, color.b, alpha)
			djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 5 * 16, tileY * 16, 16, 16)
			isMetal = true

			break
		end

		local part = PART_ORDER[i]
		if tileY == 2 and part == HAIR then -- toad doesn't use hair, bald
			part = GLOVES
		end

		network_player_palette_to_color(np, part, color)

        djui_hud_set_color(color.r, color.g, color.b, alpha)
        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (i-1)*16, tileY*16, 16, 16)
    end

    if not isMetal then
        djui_hud_set_color(255, 255, 255, alpha)
        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER) * 16, tileY * 16, 16, 16)

        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER + 1) * 16, tileY * 16, 16, 16) -- hat emblem
        if m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
            djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY) -- wing
        end
    elseif m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
        djui_hud_set_color(109, 170, 173, alpha) -- blueish green
        djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY) -- wing
    end
end

-- end player head code