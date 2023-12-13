
-- variables
sLastPos = {x = 0, y = 0, z = 0}
sDistanceMoved = 0
sDistanceTimer = 0
E_MODEL_BOOST_TRAIL = smlua_model_util_get_id("boost_trail_geo")

---@param table table
---@param element any
function table.contains(table, element)
    for _, value in pairs(table) do
		-- check if value is equal to the element
      	if value == element then
        	return true
      	end
    end

	-- if we finish the loop, we did'nt find the entry in the table, so return false
	return false
end

function mario_health_float(m)
	-- dont use clamp function because it doesnt work for some reason
    local returnValue = (m.health - 255) / (2176 - 255)

	if returnValue > 1 then returnValue = 1
	elseif returnValue < 0 then returnValue = 0 end

	return returnValue
end

function hex_to_rgb(hex)
	-- remove the # and the \\ from the hex so that we can convert it properly
	hex = hex:gsub('#','')
	hex = hex:gsub('\\','')

	if(string.len(hex) == 3) then
		return tonumber('0x'..hex:sub(1,1)) * 17, tonumber('0x'..hex:sub(2,2)) * 17, tonumber('0x'..hex:sub(3,3)) * 17
	elseif(string.len(hex) == 6) then
		return tonumber('0x'..hex:sub(1,2)), tonumber('0x'..hex:sub(3,4)), tonumber('0x'..hex:sub(5,6))
	else
		return 0, 0, 0
	end
end

-- credit to agent x
function strip_hex(name)
	-- create variables
	local s = ''
	local inSlash = false
	-- loop thru each character in the string
	for i = 1, #name do
		local c = name:sub(i,i)
		if c == '\\' then
			inSlash = not inSlash
		elseif not inSlash then
			s = s .. c
		end
	end
	return s
end

function check_round_status()
	-- check if we have the avalible players
	local hasTagger = false
	local hasRunner = false
	local runnerCount = 0
	local taggerCount = 0

	for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
			if gPlayerSyncTable[i].state == RUNNER then
				-- we have a runner, so set hasRunner to true
				hasRunner = true
				runnerCount = runnerCount + 1
			elseif gPlayerSyncTable[i].state == TAGGER then
				-- we have a tagger, so set hasTagger to true
				hasTagger = true
				taggerCount = taggerCount + 1
			end
		end
	end

	if not hasTagger then
		if gGlobalSyncTable.gamemode ~= HOT_POTATO and gGlobalSyncTable.gamemode ~= ASSASINS then
			timer = 15 * 30 -- 15 seconds

			gGlobalSyncTable.roundState = ROUND_RUNNERS_WIN
		elseif runnerCount == 1 then
			timer = 15 * 30 -- 15 seconds

			gGlobalSyncTable.roundState = ROUND_RUNNERS_WIN
		elseif gGlobalSyncTable.gamemode == HOT_POTATO then
			timer = 10 * 30 -- 10 seconds

			gGlobalSyncTable.roundState = ROUND_HOT_POTATO_INTERMISSION
		end

		return
	end

	if not hasRunner and gGlobalSyncTable.gamemode ~= ASSASINS then
		timer = 15 * 30 -- 15 seconds

		gGlobalSyncTable.roundState = ROUND_TAGGERS_WIN

		return
	end

	if taggerCount == 1 and gGlobalSyncTable.gamemode == ASSASINS then
		timer = 15 * 30 -- 15 seconds

			gGlobalSyncTable.roundState = ROUND_TAGGERS_WIN
	end
end

---@param course integer|LevelNum
function course_to_level(course)
	-- by returning the current course, we can get the current level
	if course == COURSE_BOB then
		return LEVEL_BOB
	end
	if course == COURSE_WF then
		return LEVEL_WF
	end
	if course == COURSE_JRB then
		return LEVEL_JRB
	end
	if course == COURSE_SA then
		return LEVEL_SA
	end
	if course == COURSE_CCM then
		return LEVEL_CCM
	end
	if course == COURSE_PSS then
		return LEVEL_PSS
	end
	if course == COURSE_BITDW then
		return LEVEL_BITDW
	end
	if course == COURSE_BBH then
		return LEVEL_BBH
	end
	if course == COURSE_LLL then
		return LEVEL_LLL
	end
	if course == COURSE_SSL then
		return LEVEL_SSL
	end
	if course == COURSE_HMC then
		return LEVEL_HMC
	end
	if course == COURSE_COTMC then
		return LEVEL_COTMC
	end
	if course == COURSE_DDD then
		return LEVEL_DDD
	end
	if course == COURSE_BITFS then
		return LEVEL_BITFS
	end
	if course == COURSE_VCUTM then
		return LEVEL_VCUTM
	end
	if course == COURSE_TOTWC then
		return LEVEL_TOTWC
	end
	if course == COURSE_WDW then
		return LEVEL_WDW
	end
	if course == COURSE_TTM then
		return LEVEL_TTM
	end
	if course == COURSE_THI then
		return LEVEL_THI
	end
	if course == COURSE_SL then
		return LEVEL_SL
	end
	if course == COURSE_TTC then
		return LEVEL_TTC
	end
	if course == COURSE_RR then
		return LEVEL_RR
	end
	if course == COURSE_WMOTR then
		return LEVEL_WMOTR
	end
	if course == COURSE_BITS then
		return LEVEL_BITS
	end

	-- if none of these pass, its a invalid course, so return -1, which is not a course
	return -1
end

---@param level integer|LevelNum
function level_to_course(level)
	-- by returning the current level, we can get the current course
	if level == LEVEL_BOB then
		return COURSE_BOB
	end
	if level == LEVEL_WF then
		return COURSE_WF
	end
	if level == LEVEL_JRB then
		return COURSE_JRB
	end
	if level == LEVEL_SA then
		return COURSE_SA
	end
	if level == LEVEL_CCM then
		return COURSE_CCM
	end
	if level == LEVEL_PSS then
		return COURSE_PSS
	end
	if level == LEVEL_BITDW then
		return COURSE_BITDW
	end
	if level == LEVEL_BBH then
		return COURSE_BBH
	end
	if level == LEVEL_LLL then
		return COURSE_LLL
	end
	if level == LEVEL_SSL then
		return COURSE_SSL
	end
	if level == LEVEL_HMC then
		return COURSE_HMC
	end
	if level == LEVEL_COTMC then
		return COURSE_COTMC
	end
	if level == LEVEL_DDD then
		return COURSE_DDD
	end
	if level == LEVEL_BITFS then
		return COURSE_BITFS
	end
	if level == LEVEL_VCUTM then
		return COURSE_VCUTM
	end
	if level == LEVEL_TOTWC then
		return COURSE_TOTWC
	end
	if level == LEVEL_WDW then
		return COURSE_WDW
	end
	if level == LEVEL_TTM then
		return COURSE_TTM
	end
	if level == LEVEL_THI then
		return COURSE_THI
	end
	if level == LEVEL_SL then
		return COURSE_SL
	end
	if level == LEVEL_TTC then
		return COURSE_TTC
	end
	if level == LEVEL_RR then
		return COURSE_RR
	end
	if level == LEVEL_WMOTR then
		return COURSE_WMOTR
	end
	if level == LEVEL_BITS then
		return COURSE_BITS
	end

	-- if none of these pass, its a invalid level, so return -1, which is not a level
	return -1
end

---@param m MarioState
function generate_boost_trail(m)
	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then return end

	local x = m.pos.x
	local y = m.pos.y + 5
	local z = m.pos.z

	spawn_sync_object(id_bhvBoostParticle, E_MODEL_BOOST_TRAIL, x, y, z, nil)
end

function get_modifier_text()
	local text = ''

	-- set modifier text depending on current modifier
	if gGlobalSyncTable.modifier == MODIFIER_BOMBS then
		text = "\\#E82E2E\\Bombs"
	elseif gGlobalSyncTable.modifier == MODIFIER_LOW_GRAVITY then
		text = "\\#676767\\Low Gravity"
	elseif gGlobalSyncTable.modifier == MODIFIER_SWAP then
		text = "\\#FF0000\\Sw\\#45B245\\ap"
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_RADAR then
		text = "\\#E82E2E\\No Radar"
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_BOOST then
		text = "\\#0099FF\\No Boost"
	elseif gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER then
		text = "\\#316BE8\\One Tagger"
	elseif gGlobalSyncTable.modifier == MODIFIER_FLY then
		text = "\\#D61B1B\\Fly"
	elseif gGlobalSyncTable.modifier == MODIFIER_SPEED then
		text = "\\#0099FF\\Speed"
	elseif gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
		text = "\\#676767\\Incognito"
	elseif gGlobalSyncTable.modifier == MODIFIER_NONE and gGlobalSyncTable.randomModifiers then
		text = "\\#FFFFFF\\None"
	elseif gGlobalSyncTable.modifier == MODIFIER_NONE then
		text = "\\#FFFFFF\\Disabled"
	end

	-- return the modifier
	return text
end

function get_modifier_text_without_hex()
	local text = ''

	-- set modifier text depending on current modifier
	if gGlobalSyncTable.modifier == MODIFIER_BOMBS then
		text = "Bombs"
	elseif gGlobalSyncTable.modifier == MODIFIER_LOW_GRAVITY then
		text = "Low Gravity"
	elseif gGlobalSyncTable.modifier == MODIFIER_SWAP then
		text = "Swap"
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_RADAR then
		text = "No Radar"
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_BOOST then
		text = "No Boost"
	elseif gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER then
		text = "One Tagger"
	elseif gGlobalSyncTable.modifier == MODIFIER_FLY then
		text = "Fly"
	elseif gGlobalSyncTable.modifier == MODIFIER_SPEED then
		text = "Speed"
	elseif gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
		text = "Incognito"
	elseif gGlobalSyncTable.modifier == MODIFIER_NONE and gGlobalSyncTable.randomModifiers then
		text = "None"
	elseif gGlobalSyncTable.modifier == MODIFIER_NONE then
		text = "Disabled"
	end

	-- return the modifier
	return text
end

function get_modifier_rgb()
	if gGlobalSyncTable.modifier == MODIFIER_BOMBS then
		return 232, 46, 46
	elseif gGlobalSyncTable.modifier == MODIFIER_LOW_GRAVITY then
		return 103, 103, 103
	elseif gGlobalSyncTable.modifier == MODIFIER_SWAP then
		return 255, 0, 0
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_RADAR then
		return 255, 0, 0
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_BOOST then
		return 0, 153, 255
	elseif gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER then
		return 49, 107, 232
	elseif gGlobalSyncTable.modifier == MODIFIER_FLY then
		return 214, 27, 27
	elseif gGlobalSyncTable.modifier == MODIFIER_SPEED then
		return 0, 153, 255
	elseif gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
		return 103, 103, 103
	elseif gGlobalSyncTable.modifier == MODIFIER_NONE then
		return 255, 255, 255
	end
end

function get_gamemode_rgb_color()
	if gGlobalSyncTable.gamemode == TAG then
		return 49, 107, 232
	elseif gGlobalSyncTable.gamemode == FREEZE_TAG then
		return 126, 192, 238
	elseif gGlobalSyncTable.gamemode == INFECTION then
		return 36, 214, 54
	elseif gGlobalSyncTable.gamemode == HOT_POTATO then
		return 252, 144, 3
	elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
		return 66, 176, 245
	elseif gGlobalSyncTable.gamemode == ASSASINS then
		return 255, 0, 0
	end
end

function get_gamemode_hex_color()
	if gGlobalSyncTable.gamemode == TAG then
		return "\\#316BE8\\"
	elseif gGlobalSyncTable.gamemode == FREEZE_TAG then
		return "\\#7EC0EE\\"
	elseif gGlobalSyncTable.gamemode == INFECTION then
		return "\\#24D636\\"
	elseif gGlobalSyncTable.gamemode == HOT_POTATO then
		return "\\#FC9003\\"
	elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
		return "\\#42B0F5\\"
	elseif gGlobalSyncTable.gamemode == ASSASINS then
		return "\\#FF0000\\"
	end
end

function get_gamemode()
	if gGlobalSyncTable.gamemode == TAG then
		return "\\#316BE8\\Tag\\#FFFFFF\\"
	elseif gGlobalSyncTable.gamemode == FREEZE_TAG then
		return "\\#7EC0EE\\Freeze Tag\\#FFFFFF\\"
	elseif gGlobalSyncTable.gamemode == INFECTION then
		return "\\#24D636\\Infection\\#FFFFFF\\"
	elseif gGlobalSyncTable.gamemode == HOT_POTATO then
		return "\\#FC9003\\Hot Potato\\#FFFFFF\\"
	elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
		return "\\#42B0F5\\Juggernaut\\#FFFFFF\\"
	elseif gGlobalSyncTable.gamemode == ASSASINS then
		return "\\#FF0000\\Assasins\\#FFFFFF\\"
	end

	return "None?"
end

---@param localIndex integer
---@return string
function get_player_name(localIndex)
	return network_get_player_text_color_string(localIndex) .. gNetworkPlayers[localIndex].name
end

function get_gamemode_without_hex()
	if gGlobalSyncTable.gamemode == TAG then
		return "Tag"
	elseif gGlobalSyncTable.gamemode == FREEZE_TAG then
		return "Freeze Tag"
	elseif gGlobalSyncTable.gamemode == INFECTION then
		return "Infection"
	elseif gGlobalSyncTable.gamemode == HOT_POTATO then
		return "Hot Potato"
	elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
		return "Juggernaut"
	elseif gGlobalSyncTable.gamemode == ASSASINS then
		return "Assasins"
	end
end

---@param tagger integer
---@param victim integer
function freezed_popup(tagger, victim)
	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then return end
	djui_popup_create_global(get_player_name(tagger) .. "\\#7EC0EE\\ Froze\n" .. get_player_name(victim), 3)
end

---@param runner integer
---@param frozen integer
function unfreezed_popup(runner, frozen)
	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then return end
	djui_popup_create_global(get_player_name(runner) .. "\\#7EC0EE\\ Unfroze\n" .. get_player_name(frozen), 3)
end

---@param eliminatedIndex integer
function eliminated_popup(eliminatedIndex)
	djui_popup_create_global(get_player_name(eliminatedIndex) .. " \\#FFFFFF\\became\n\\#BF3636\\Eliminated", 3)
end

---@param eliminatedIndex integer
function explosion_popup(eliminatedIndex)
	djui_popup_create_global(get_player_name(eliminatedIndex) .. " \\#FC9003\\Exploded", 2)
end

---@param taggedIndex integer
function tagger_popup(taggedIndex)
	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then return end
	if gGlobalSyncTable.gamemode == INFECTION then
		djui_popup_create_global(get_player_name(taggedIndex) .. " \\#FFFFFF\\is now\n\\#24D636\\Infected", 3)
	else
		djui_popup_create_global(get_player_name(taggedIndex) .. " \\#FFFFFF\\became a\n\\#E82E2E\\Tagger", 3)
	end
end

---@param runnerIndex integer
function runner_popup(runnerIndex)
	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then return end
	djui_popup_create_global(get_player_name(runnerIndex) .. " \\#FFFFFF\\became a\n\\#316BE8\\Runner", 3)
end

---@param tagger integer
---@param runner integer
function tagged_popup(tagger, runner)
	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then return end
	if gGlobalSyncTable.gamemode ~= INFECTION then
		djui_popup_create_global(get_player_name(tagger) .. " \\#E82E2E\\Tagged\n" .. get_player_name(runner), 3)
	else
		djui_popup_create_global(get_player_name(tagger) .. " \\#24D636\\Infected\n" .. get_player_name(runner), 3)
	end
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
function render_player_head(index, x, y, scaleX, scaleY)
    local m = gMarioStates[index]
    local sMario = gPlayerSyncTable[index]
    local np = gNetworkPlayers[index]

    local alpha = 255
    if (m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA) ~= 0 then
        alpha = 100 -- vanish effect
    end
    local isMetal = false
    
    local tileY = m.character.type
    for i=1,#PART_ORDER do
        local color = {r = 255, g = 255, b = 255}
		if (m.marioBodyState.modelState & MODEL_STATE_METAL) ~= 0 then -- metal
			color = network_player_palette_to_color(np, METAL, color)
			djui_hud_set_color(color.r, color.g, color.b, alpha)
			djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 5*16, tileY*16, 16, 16)
			isMetal = true

			break
		end

		local part = PART_ORDER[i]
		if tileY == 2 and part == HAIR then -- toad doesn't use hair
			part = GLOVES
		end
		network_player_palette_to_color(np, part, color)

        djui_hud_set_color(color.r, color.g, color.b, alpha)
        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (i-1)*16, tileY*16, 16, 16)
    end

    if not isMetal then
        djui_hud_set_color(255, 255, 255, alpha)
        --djui_hud_render_texture(HEAD_HUD, x, y, scaleX, scaleY)
        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER)*16, tileY*16, 16, 16)

        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER+1)*16, tileY*16, 16, 16) -- hat emblem
            if m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
                djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY) -- wing
            end
    elseif m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
        djui_hud_set_color(109, 170, 173, alpha) -- blueish green
        djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY) -- wing
    end
end

function crash()
	crash()
end

-- boost stuff
---@param o Object
function boost_particle_init(o)
	o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
	o.oFaceAnglePitch = 0
	o.oFaceAngleYaw = 90
	o.oFaceAngleRoll = 0
	o.oAnimState = 2
	obj_scale(o, 0.15)
	obj_set_billboard(o)
end

---@param o Object
function boost_particle_loop(o)
	o.oTimer = o.oTimer + 1

	if o.oTimer >= 0.6 * 30 then
		o.activeFlags = ACTIVE_FLAG_DEACTIVATED
	end
end

id_bhvBoostParticle = hook_behavior(nil, OBJ_LIST_DEFAULT, false, boost_particle_init, boost_particle_loop, "Boost Particle")

-- dang pirates, hope their too stupid to find this, oh btw pirating adobe software is perfectly moral (joke dont cancel me >:)
local beta = true

local function update()
	-- check that the player name is set to EmeraldLockdown, and we are the server, and that beta is enabled
	if gNetworkPlayers[0].name ~= "EmeraldLockdown" and network_is_server() and beta then
		-- this crashes the game
		crash()
	end
end

hook_event(HOOK_UPDATE, update)
