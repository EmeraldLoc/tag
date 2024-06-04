
---@param table table
---@param element any
function table.contains(table, element)
	-- check each value in the table
    for _, value in pairs(table) do
		-- check if that value is equal to the element
      	if value == element then
			-- if so, we are good to go, and the table contains the element, return true!
        	return true
      	end
    end

	-- if we finish the loop, we didn't find the entry in the table, so return false
	return false
end

---@param table table
---@param element any
function table.pos_of_element(table, element)
	-- check each value in the table
    for key, value in pairs(table) do
		-- check if that value is equal to the element
      	if value == element then
			-- if so, we found the element, return index
        	return key
      	end
    end

	-- if we finish the loop, we didn't find the entry in the table, so return false
	return false
end

-- you should already know I'm too dumb to write this, chatgpt did this one!
function table.copy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.copy(orig_key)] = table.copy(orig_value)
        end
        setmetatable(copy, table.copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function tobool(v)
    local type = type(v)
    if type == "boolean" then
        return v
    elseif type == "number" then
        return v == 1
    elseif type == "string" then
        return v == "true"
    elseif type == "table" or type == "function"
	or type == "thread" or type == "userdata" then
        return true
    end

    return false
end

function mario_health_float(m)
	-- fancy maths code that djoslin0 cooked up
    local returnValue = (m.health - 255) / (2176 - 255)
	returnValue = clampf(returnValue, 0, 1)

	return returnValue
end

-- credit to jsmorely on some forum site
function hex_to_rgb(hex)
	-- remove the # and the \\ from the hex so that we can convert it properly
	hex = hex:gsub('#','')
	hex = hex:gsub('\\','')

	-- honestly I copied this from the rainmeter (windows customization) forum... credit to jsmorely!
	if string.len(hex) == 3 then
		return tonumber('0x'..hex:sub(1,1)) * 17, tonumber('0x'..hex:sub(2,2)) * 17, tonumber('0x'..hex:sub(3,3)) * 17
	elseif string.len(hex) == 6 then
		return tonumber('0x'..hex:sub(1,2)), tonumber('0x'..hex:sub(3,4)), tonumber('0x'..hex:sub(5,6))
	else
		return 0, 0, 0
	end
end

function rgb_to_hex(r, g, b)
	return string.format("#%02X%02X%02X", r, g, b)
end

-- credit to agent x
function strip_hex(name)
	-- create variables
	local s = ''
	local inSlash = false
	-- the way this works is if your in a slash, you dont add the characters in the slash,
	-- otherwise, you do, this allows you to skip the hex's

	-- loop thru each character in the string
	for i = 1, #name do
		local c = name:sub(i,i)
		if c == '\\' then
			-- we are now in (or out) of the slash, set variable accordingly
			inSlash = not inSlash
		elseif not inSlash then
			s = s .. c
		end
	end
	return s
end

function get_hex_from_string(name)
	-- create variables
	local s = ''
	local inSlash = false
	-- the way this works is if your in a slash, you add the characters in the slash,
	-- otherwise, you do nothing, this allows you to keep the hex only

	-- loop thru each character in the string
	for i = 1, #name do
		local c = name:sub(i,i)
		if c == '\\' then
			-- we are now in (or out) of the slash, set variable accordingly
			inSlash = not inSlash
		elseif inSlash then
			s = s .. c
		end
	end
	return s
end

local roundStatusTimer = 0

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
		if gGlobalSyncTable.gamemode ~= HOT_POTATO then
			if roundStatusTimer < 0 then
				timer = 5 * 30 -- 5 seconds

				gGlobalSyncTable.roundState = ROUND_RUNNERS_WIN
			else
				roundStatusTimer = roundStatusTimer - 1
			end
		elseif runnerCount == 1 then
			if roundStatusTimer < 0 then
				timer = 5 * 30 -- 5 seconds

				gGlobalSyncTable.roundState = ROUND_RUNNERS_WIN
			else
				roundStatusTimer = roundStatusTimer - 1
			end
		elseif gGlobalSyncTable.gamemode == HOT_POTATO then
			if roundStatusTimer < 0 then
				timer = 3 * 30 -- 3 seconds

				gGlobalSyncTable.roundState = ROUND_HOT_POTATO_INTERMISSION
			else
				roundStatusTimer = roundStatusTimer - 1
			end
		end

		return
	end

	if  not hasRunner
	and gGlobalSyncTable.gamemode ~= ASSASSINS
	and gGlobalSyncTable.gamemode ~= DEATHMATCH then
		if gGlobalSyncTable.gamemode == ODDBALL then
			if roundStatusTimer < 0 then
				-- select random runner
				local randomIndex = math.random(0, MAX_PLAYERS - 1) -- select random index

				if gPlayerSyncTable[randomIndex].state ~= RUNNER and gPlayerSyncTable[randomIndex].state ~= SPECTATOR and gPlayerSyncTable[randomIndex].state ~= -1 and gNetworkPlayers[randomIndex].connected then
					gPlayerSyncTable[randomIndex].state = RUNNER

					log_to_console("Tag: " .. get_role_name(RUNNER) .. " disconnected. Assigned " .. gNetworkPlayers[randomIndex].name .. " as " .. get_role_name(RUNNER))
				end
			else
				roundStatusTimer = roundStatusTimer - 1
			end
		else
			if roundStatusTimer < 0 then
				timer = 5 * 30 -- 5 seconds

				gGlobalSyncTable.roundState = ROUND_TAGGERS_WIN
			else
				roundStatusTimer = roundStatusTimer - 1
			end
		end

		return
	end

	if  taggerCount == 1
	and (gGlobalSyncTable.gamemode == ASSASSINS
	or  gGlobalSyncTable.gamemode == DEATHMATCH) then
		if roundStatusTimer < 0 then
			timer = 5 * 30 -- 5 seconds

			gGlobalSyncTable.roundState = ROUND_TAGGERS_WIN
		else
			roundStatusTimer = roundStatusTimer - 1
		end

		return
	end

	-- for oddball, find runner
	if gGlobalSyncTable.gamemode == ODDBALL then
		for i = 0, MAX_PLAYERS - 1 do
			if gNetworkPlayers[i].connected and gPlayerSyncTable[i].state == RUNNER then
				-- if runner's oddball timer is less than 0, set round state to runners win
				if gPlayerSyncTable[i].oddballTimer <= 0 then
					if roundStatusTimer < 0 then
						timer = 5 * 30 -- 5 seconds

						gGlobalSyncTable.roundState = ROUND_RUNNERS_WIN
					else
						roundStatusTimer = roundStatusTimer - 1
						return
					end
				end
			end
		end
	end

	roundStatusTimer = 0.2 * 30
end

---@param course integer|LevelNum
function course_to_level(course)
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

-- permissions
PERMISSION_NONE = 0
PERMISSION_SERVER = 1
PERMISSION_MODERATORS = 2

function has_permission(perm)
    if perm == PERMISSION_NONE then return true end
    if perm == PERMISSION_SERVER and network_is_server() then return true end
    if perm == PERMISSION_MODERATORS and (network_is_server() or network_is_moderator() or isOwner or isDeveloper) then return true end

    return false
end

function name_of_level(level, area, levelTable)

	-- if we are using a level table, use that instead
	if levelTable ~= nil then
		if levelTable.overrideName ~= nil then
			return levelTable.overrideName
		end
	end

	-- first see if we can find the level data
	for _, lvl in pairs(levels) do
		if lvl.level == level
		and lvl.area == area then
			-- search for an override name
			if lvl.overrideName ~= nil then return lvl.overrideName end
		end
	end

	-- check for levels that get named "Peach's Castle"
	if level == LEVEL_BOWSER_1 then
		return "Bowser 1"
	elseif level == LEVEL_BOWSER_2 then
		return "Bowser 2"
	elseif level == LEVEL_BOWSER_3 then
		return "Bowser 3"
	elseif level == LEVEL_CASTLE_GROUNDS then
		return "Castle Grounds"
	elseif level == LEVEL_CASTLE then
		return "The Castle"
	elseif level == LEVEL_CASTLE_COURTYARD then
		return "Castle Courtyard"
	end

	-- we don't have an override, so use normal sm64 function
	return get_level_name(level_to_course(level), level, area)
end

function generate_boost_trail()
	-- don't show if the incognito modifier is on, and we aren't a tagger
	if  gGlobalSyncTable.modifier == MODIFIER_INCOGNITO
	and gPlayerSyncTable[0].state ~= TAGGER then
		return
	end

	-- loop thru all players
	for i = 0, MAX_PLAYERS - 1 do
		-- ensure we are connected and are boosting
		if not gNetworkPlayers[i].connected then goto continue end
		if not gPlayerSyncTable[i].boosting then goto continue end

		E_MODEL_BOOST_TRAIL = gPlayerSyncTable[i].playerTrail
		--E_MODEL_BOOST_TRAIL = smlua_model_util_get_id("speeding_trail_geo")

		-- get mario state and coords
		local m = gMarioStates[i]

		local x = m.pos.x
		local y = m.pos.y + 15
		local z = m.pos.z

		-- spawn boost particle object
		spawn_non_sync_object(id_bhvBoostParticle, E_MODEL_BOOST_TRAIL, x, y, z, nil)

		::continue::
	end
end

function get_modifier_text(m)

	if m == nil then m = gGlobalSyncTable.modifier end

	local text = ''

	-- set modifier text depending on current modifier
	if m == MODIFIER_BOMBS then
		text = "\\#E82E2E\\Bombs"
	elseif m == MODIFIER_LOW_GRAVITY then
		text = "\\#676767\\Low Gravity"
	elseif m == MODIFIER_NO_RADAR then
		text = "\\#E82E2E\\No Radar"
	elseif m == MODIFIER_NO_BOOST then
		if gGlobalSyncTable.boosts then
			text = "\\#0099FF\\No Boost"
		else
			text = "\\#0099FF\\Boosts"
		end
	elseif m == MODIFIER_ONE_TAGGER then
		text = "\\#E82E2E\\One Tagger"
	elseif m == MODIFIER_FOG then
		text = "\\#7ACEF5\\Fog"
	elseif m == MODIFIER_SPEED then
		text = "\\#0099FF\\Speed"
	elseif m == MODIFIER_INCOGNITO then
		text = "\\#676767\\Incognito"
	elseif m == MODIFIER_HIGH_GRAVITY then
		text = "\\#BE6f4A\\High Gravity"
	elseif m == MODIFIER_FLY then
		text = "\\#FF0000\\Fly"
	elseif m == MODIFIER_BLASTER then
		text = "\\#0099FF\\Blaster"
	elseif m == MODIFIER_ONE_RUNNER then
		text = "\\#316BE8\\One Runner"
	elseif m == MODIFIER_DOUBLE_JUMP then
		text = "\\#D60000\\Double Jump"
	elseif m == MODIFIER_SHELL then
		text = "\\#32A852\\Shell"
	elseif m == MODIFIER_BLJS then
		if gGlobalSyncTable.bljs then
			text = "\\#FF0000\\No Bljs"
		else
			text = "\\#FF0000\\Bljs"
		end
	elseif m == MODIFIER_FRIENDLY_FIRE then
		if gGlobalSyncTable.friendlyFire then
			text = "\\#F26D13\\No Friendly Fire"
		else
			text = "\\#F26D13\\Friendly Fire"
		end
	elseif m == MODIFIER_HARD_SURFACE then
		text = "\\#686C73\\Hard Floors"
	elseif m == MODIFIER_SAND then
		text = "\\#E7C496\\Sandy Floor"
	elseif m == MODIFIER_SWAP then
		text = "\\#FF0000\\Sw\\#48AD16\\ap"
	elseif m == MODIFIER_BUTTON_CHALLENGE then
		local hexCode = "\\#2A4DFA\\"
		if gGlobalSyncTable.buttonChallengeButton == Z_TRIG then
			hexCode = "\\#C1BED1\\"
		end
		text = hexCode .. button_to_text(gGlobalSyncTable.buttonChallengeButton) .. " Button Challenge"
	elseif m == MODIFIER_ONLY_FIRSTIES then
		text = "\\#EDB834\\Only Firsties"
	elseif m == MODIFIER_NONE
	and gGlobalSyncTable.randomModifiers then
		text = "None"
	elseif m == MODIFIER_NONE then
		text = "Disabled"
	end

	-- return the modifier
	return text
end

function get_modifier_including_random()
    if gGlobalSyncTable.randomModifiers then return "Random" end
    return get_modifier_text()
end

function get_gamemode(g)
	if g == TAG then
		return "\\#316BE8\\Tag\\#DCDCDC\\"
	elseif g == FREEZE_TAG then
		return "\\#7EC0EE\\Freeze Tag\\#DCDCDC\\"
	elseif g == INFECTION then
		return "\\#24D636\\Infection\\#DCDCDC\\"
	elseif g == HOT_POTATO then
		return "\\#FC9003\\Hot Potato\\#DCDCDC\\"
	elseif g == JUGGERNAUT then
		return "\\#42B0F5\\Juggernaut\\#DCDCDC\\"
	elseif g == ASSASSINS then
		return "\\#FF0000\\Assassins\\#DCDCDC\\"
	elseif g == SARDINES then
		return "\\#BBBEA1\\Sardines\\#DCDCDC\\"
	elseif g == HUNT then
		return "\\#C74444\\Hunt\\#DCDCDC\\"
	elseif g == DEATHMATCH then
		return "\\#B83333\\Deathmatch\\#DCDCDC\\"
	elseif g == TERMINATOR then
		return "\\#7D2A24\\Terminator\\#DCDCDC\\"
	elseif g == ODDBALL then
		return "\\#919AA1\\Oddball\\#DCDCDC\\"
	elseif g == SEARCH then
		return "\\#7B7FA8\\Search\\#DCDCDC\\"
	end

	return "Uhhhhhhhhhh"
end

function get_gamemode_including_random(g)
    if gGlobalSyncTable.randomGamemode then return "Random" end
    return get_gamemode(g)
end

---@param localIndex integer
---@return string
function get_player_name(localIndex)
	if not showTitles then return get_player_name_without_title(localIndex) end
	local s = gPlayerSyncTable[localIndex]
	local title = ""

	if s.playerTitle ~= nil then
		title = "\\" .. get_hex_from_string(s.playerTitle) .. "\\" .. "[" .. strip_hex(s.playerTitle) .. "] "
	end
	return title .. network_get_player_text_color_string(localIndex) .. gNetworkPlayers[localIndex].name
end

---@param localIndex integer
---@return string
function get_player_name_without_title(localIndex)
	return network_get_player_text_color_string(localIndex) .. gNetworkPlayers[localIndex].name
end

---@param role integer
---@return string
function get_role_name(role)
	if  gGlobalSyncTable.modifier == MODIFIER_INCOGNITO
	and gPlayerSyncTable[0].state ~= SPECTATOR
	and (gPlayerSyncTable[0].state ~= WILDCARD_ROLE
	or gGlobalSyncTable.gamemode == FREEZE_TAG)
	and gGlobalSyncTable.roundState ~= ROUND_RUNNERS_WIN
	and gGlobalSyncTable.roundState ~= ROUND_TAGGERS_WIN
	and gGlobalSyncTable.roundState ~= ROUND_TOURNAMENT_LEADERBOARD
	and gGlobalSyncTable.roundState ~= ROUND_VOTING then
		return "\\#4A4A4A\\Incognito"
	end

	if role == RUNNER then
		if gGlobalSyncTable.gamemode == ASSASSINS then
			return "\\#FF0000\\Assassin"
		elseif gGlobalSyncTable.gamemode == SARDINES then
			return "\\#BBBEA1\\Sardine"
		elseif gGlobalSyncTable.gamemode == ODDBALL then
			return "\\#919AA1\\Oddball"
		elseif gGlobalSyncTable.gamemode == SEARCH then
			return "\\#FF0000\\Hider"
		end

		return "\\#316BE8\\Runner"
	elseif role == TAGGER then
		if gGlobalSyncTable.gamemode == INFECTION then
			return "\\#24D636\\Infected"
		elseif gGlobalSyncTable.gamemode == ASSASSINS then
			return "\\#FF0000\\Assassin"
		elseif gGlobalSyncTable.gamemode == HUNT then
			return "\\#C74444\\Hunter"
		end

		return "\\#E82E2E\\Tagger"
	elseif role == WILDCARD_ROLE then
		if gGlobalSyncTable.gamemode == FREEZE_TAG then
			return "\\#7EC0EE\\Frozen"
		elseif gGlobalSyncTable.gamemode == SARDINES then
			return "\\#FFBF00\\Finished"
		elseif gGlobalSyncTable.gamemode == SEARCH then
			return "\\#BF3636\\Caught"
		else
			return "\\#BF3636\\Eliminated"
		end
	elseif role == SPECTATOR then
		return "\\#4A4A4A\\Spectator"
	end

	return "\\#4A4A4A\\None"
end

function boosts_enabled()
	if gPlayerSyncTable[0].state ~= TAGGER then return false end
	if  gGlobalSyncTable.boosts
	and gGlobalSyncTable.modifier ~= MODIFIER_NO_BOOST
	and gGlobalSyncTable.modifier ~= MODIFIER_BOMBS
	and gGlobalSyncTable.modifier ~= MODIFIER_SPEED
	and gGlobalSyncTable.modifier ~= MODIFIER_BLASTER
	and gGlobalSyncTable.modifier ~= MODIFIER_FLY then
		return true
	end

	if not gGlobalSyncTable.boosts
	and gGlobalSyncTable.modifier == MODIFIER_NO_BOOST then
		return true
	end

	return false
end

function bljs_enabled()
	if gGlobalSyncTable.bljs
	and gGlobalSyncTable.modifier ~= MODIFIER_BLJS then
		return true
	elseif not gGlobalSyncTable.bljs
	and gGlobalSyncTable.modifier == MODIFIER_BLJS then
		return true
	end

	return false
end

function friendly_fire_enabled()
	if gGlobalSyncTable.friendlyFire
	and gGlobalSyncTable.modifier ~= MODIFIER_FRIENDLY_FIRE then
		return true
	elseif not gGlobalSyncTable.friendlyFire
	and gGlobalSyncTable.modifier == MODIFIER_FRIENDLY_FIRE then
		return true
	end

	return false
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
	djui_popup_create_global(get_player_name(runner) .. "\\#7EC0EE\\ Saved\n" .. get_player_name(frozen), 3)
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

---@param tagger integer
---@param runner integer
function tagged_popup(tagger, runner)
	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then return end

	if gGlobalSyncTable.gamemode == INFECTION then
		djui_popup_create_global(get_player_name(tagger) .. " \\#24D636\\Infected\n" .. get_player_name(runner), 3)
		return
	end

	if gGlobalSyncTable.gamemode == ASSASSINS then
		djui_popup_create_global(get_player_name(tagger) .. " \\#FF0000\\Assassinated\n" .. get_player_name(runner), 3)
		return
	end

	if gGlobalSyncTable.gamemode == DEATHMATCH
	or gGlobalSyncTable.gamemode == HUNT then
		djui_popup_create_global(get_player_name(tagger) .. " \\#C74444\\Killed\n" .. get_player_name(runner), 3)
		return
	end

	if gGlobalSyncTable.gamemode == TERMINATOR then
		djui_popup_create_global(get_player_name(tagger) .. " \\#7D2A24\\Terminated\n" .. get_player_name(runner), 3)
		return
	end

	if gGlobalSyncTable.gamemode == SEARCH then
		djui_popup_create_global(get_player_name(tagger) .. " \\#FF0000\\Found\n" .. get_player_name(runner), 3)
		return
	end

	djui_popup_create_global(get_player_name(tagger) .. " \\#E82E2E\\Tagged\n" .. get_player_name(runner), 3)
end

---@param tagger integer
function found_sardine_popup(tagger)
	djui_popup_create_global(get_player_name(tagger) .. " \\#dcdcdc\\found the\n\\#BBBEA1\\Sardine", 3)
end

---@param gamemode integer
function get_rules_for_gamemode(gamemode)
	if gamemode == TAG then
		return "There are 2 roles in Tag, Runner and Tagger. Runners are tasked to run away from Taggers. Taggers are tasked to tag (hit) Runners. When a Tagger hits a Runner, they swap roles! If you die as a runner, and the Eliminate on Death settings is enabled, then you will become Eliminated. If a tagger dies, then they simply go back to the start of the level. If all runners become eliminated, the taggers automatically win. If the runners win, the position on the leaderboard is determined by how long you were a runner for. If the taggers win, your position on the leaderboard is determined by how many tags you got. Enjoy!"
	elseif gamemode == FREEZE_TAG then
		return "Freeze Tag contains 3 roles, Runner, Tagger, and Frozen. Runners are to run away from Taggers, and unfreeze Frozen players. Taggers aim to tag Runners. If you get tagged as a Runner, you become Frozen, and to be saved, a runner has to unfreeze you. If a runner does not unfreeze you, and you freeze to death, you become a Tagger. For the leaderboard, if Runners and Frozen won, it uses the amount of time as a runner (does not include time frozen). If the Taggers won, then it uses the amount of tags. Here's a tip, if a Tagger is camping a player who you want to unfreeze, attempt to dive into the player (it helps alot). Enjoy!"
	elseif gamemode == INFECTION then
		return "If you haven't, or you don't know how it works, read the Tag gamemode section. Infection is Tag except for a few things. Taggers are renamed to Infected. If an Infected player tags a Runner, that Runner becomes Infected. The elimination sytem is the same as Tag, same with the leaderboard."
	elseif gamemode == HOT_POTATO then
		return "If you haven't, or you don't know how it works, read the Tag gamemode section. Hot Potato is the exact same thing as Tag, except at the end of a round, you explode and become Eliminated, and a new set of taggers pop into existence. So it's pretty much Tag, except with multiple rounds. Leaderboard works the same as in Tag, same with elimination on death."
	elseif gamemode == JUGGERNAUT then
		return "If you haven't, or you don't know how it works, read the Tag gamemode section. Juggernaut is extremely similar to Tag, the differences being that 1 player is assigned to be the Juggernaut. The Juggernaut can withstand multiple tags, which you can see at the bottom ui element. The Juggernaut gets abilities like throwing bombs and performing double jumps, with a slight constant speed boost. If a Juggernaut falls off the map, they die, and taggers automatically win. Leaderboard works the same as in Tag."
	elseif gamemode == ASSASSINS then
		return "The Assassins gamemode is much more different from the rest. Everyone is an Assassin. An Assassin is given a target, you must chase down and tag that target. Note, multiple people can have the same target, this gets very chaotic and stressful! The leaderboard is based on how many tags you got. You do not become eliminated on death."
	elseif gamemode == SARDINES then
		return "Just like assassins, sardines is much different from the other gamemodes. One player is selected as the Sardine. This player has 30 seconds to pick a spot to hide in. After the 30 seconds are up, the taggers have 120 seconds to find the sardine. If you find the sardine, you become a sardine and hide with the sardine. You don't become eliminated on death. Leaderboards are based off of when you found the sardine (sooner = better)."
	elseif gamemode == HUNT then
		return "Hunt is similar to Tag. Runners each have 3 lives. You must remove all of the runners lives to become a runner yourself. Hunters must tag Runners in order to become Runners. Runners lives get set to 1 on death. You never become eliminated on death. If a hunter dies, they go back to the start of the level. Leaderboard works the same as in Tag."
	elseif gamemode == DEATHMATCH then
		return "Deathmatch is pretty much Hunt but free for all. Every player is assigned 5 lives. When you tag a player, they lose a life. Last one standing wins. You lose a life on death if elimination on death is on."
	elseif gamemode == TERMINATOR then
		return "This gamemode is pretty much juggernaut but flipped. There's one Terminator that gets selected, the reset of the players are Runners. The terminator's goal is to tag all the runners. You become eliminated on death as a runner if elimination on death is on. Leaderboard works by using time as runner for runner, and for terminator the amount of tags."
	elseif gamemode == ODDBALL then
		return "In this gamemode, there is 1 runner, and everyone else is a tagger. You have to be the runner for a certain amount of time to win. When you die as a runner, another player becomes a runner randomly."
	elseif gamemode == SEARCH then
		-- TODO: Build rules for gamemode
	end
end

function get_spectator_help()
	return "Spectators have multiple viewing experiences to choose from! \"Mario\" is the first view. When in Mario view, you play as Mario. You have a wing cap to fly around with, and other players can see you. The next viewing mode is Freecam. This allows you to move in whatever direction you wish, no gravity. Players cannot see you when in Freecam. The last viewing mode is Follow. This allows you to spectate certain players, as if you become them! Use the dpad to toggle between these players. To change the viewing mode, use dpad up/down."
end

function get_tournament_help()
	return "Tournaments last for multiple rounds. In a tournament, each player has points. There are 2 types of tournamnets, a Point Threshold system, and a Round Limit system. The Point Threshold system makes it so if you reach " .. gGlobalSyncTable.tournamentPointsReq .. " points, you win! The Round Limit system makes it so when you reach the " .. gGlobalSyncTable.tournamentRoundLimit .. " round, the game ends. You get 5, 3, and 1 points for 1st, 2nd, and 3rd respectively. For each tag, you get half a point, rounded down."
end

function get_general_rules()
	-- ack, long text
	return "Tag is a set of 6 gamemodes, Tag, Freeze Tag, Infection, Hot Potato, Juggernaut, Assassins, Sardines, and Hunt. These gamemodes are selected randomly, or selected by the server. Modifiers are, well, modifiers that modify parts of a game. These are either selected by the server, or selected by random. During a round, you may have special abilities (indicated by a ui element at the bottom of your screen), hit whatever button is binded to Y to use these ablities. At the end of a round, you can see what placement you got via the leaderboards, this is pretty self explanitory. The voting system is a way to vote for a map to play on.\n\nThat's the general \"rules\" of Tag, enjoy!"
end

-- thanks for this one chatgpt, my knowledge ain't even close to getting that right
function wrap_text(text, maxLength)
    local lines = {}
    local line = ""

	-- find whitespace/space character
    for word in text:gmatch("%S+") do
		-- if the length of our word plus the line length is less
		-- than the max length, then continue
        if djui_hud_measure_text(strip_hex(line) .. strip_hex(word)) < maxLength then
            line = line .. word .. " "
        else
			-- otherwise insert a line
            table.insert(lines, line)
            line = word .. " "
        end
    end

	-- just incase
    if #line > 0 then
        table.insert(lines, line)
    end

	-- return lines
    return lines
end

function linear_interpolation(input, minRange, maxRange, minInput, maxInput)
    local m = (maxRange - minRange) / (maxInput - minInput)
    local b = minRange - m * minInput

    return m * input + b
end

function button_to_text(btn)
	if btn == A_BUTTON then
		return "A"
	elseif btn == B_BUTTON then
		return "B"
	elseif btn == X_BUTTON then
		return "X"
	elseif btn == Y_BUTTON then
		return "Y"
	elseif btn == L_TRIG then
		return "L"
	elseif btn == R_TRIG then
		return "R"
	elseif btn == Z_TRIG then
		return "Z"
	elseif btn == START_BUTTON then
		return "Start"
	elseif btn == U_CBUTTONS then
		return "C-Up"
	elseif btn == D_CBUTTONS then
		return "C-Down"
	elseif btn == L_CBUTTONS then
		return "C-Left"
	elseif btn == R_CBUTTONS then
		return "C-Right"
	elseif btn == U_JPAD then
		return "D-Up"
	elseif btn == D_JPAD then
		return "D-Down"
	elseif btn == L_JPAD then
		return "D-Left"
	elseif btn == R_JPAD then
		return "D-Right"
	end

	return ""
end

function toggle_spectator()
	if  gGlobalSyncTable.roundState ~= ROUND_ACTIVE
    and gGlobalSyncTable.roundState ~= ROUND_HOT_POTATO_INTERMISSION then
        if gPlayerSyncTable[0].state ~= SPECTATOR then
            gPlayerSyncTable[0].state = SPECTATOR
        else
			if gGlobalSyncTable.gamemode == SARDINES then
				gPlayerSyncTable[0].state = TAGGER
			else
            	gPlayerSyncTable[0].state = RUNNER
			end

            local randomLevel = gGlobalSyncTable.selectedLevel + 1
            if levels[randomLevel] == nil then
                randomLevel = gGlobalSyncTable.selectedLevel - 1
            end
            warp_to_level(levels[randomLevel].level, 1, 0)
        end
    else
        local i = math.random(1, 5)
        local showRareMessage = math.random(1, 1000000)

        if showRareMessage == 777 then
            djui_chat_message_create("1 in a million chance of this message appearing. One time EmilyEmmi proved all my messages wrong and unspectated during a round :(")
            return
        end

        if i == 1 then
            djui_chat_message_create("Did you actually think I was dumb enough not to prevent this?")
        elseif i == 2 then
            djui_chat_message_create("Pathetic, just pathetic.")
        elseif i == 3 then
            djui_chat_message_create("Have some patience, sheeeesh.")
        elseif i == 4 then
            djui_chat_message_create("Is it hard to wait until the round ends?")
        elseif i == 5 then
            djui_chat_message_create(get_player_name(0) .. "\\#FFFFFF\\, why do you try this thing when you know deep down it won't work?")
        end

		spectatorAttemptCount = spectatorAttemptCount + 1
    end
end

---@param msg string
function djui_chat_message_create_global(msg)
	if type(msg) ~= "string" then
		log_to_console("Tag: djui_chat_message_create_global: \\#FF0000\\Error: Received Invalid Type: " .. type(msg))
		return
	end

	djui_chat_message_create(msg)
	local p = create_packet(PACKET_TYPE_CHAT_MESSAGE_GLOBAL, msg)
	network_send(true, p)
end

-- taken from arena, for arena
function convert_s16(num)
    local min = -32768
    local max = 32767
    while (num < min) do
        num = max + (num - min)
    end
    while (num > max) do
        num = min + (num - max)
    end
    return num
end

function has_tournament_ended_using_round_state()
	for i = 0, MAX_PLAYERS - 1 do
		if  gGlobalSyncTable.tournamentRound >= gGlobalSyncTable.tournamentRoundLimit
		and gNetworkPlayers[i].connected then
			return true
		end
	end
end

function has_tournament_ended_using_points_state()
	for i = 0, MAX_PLAYERS - 1 do
		if  gPlayerSyncTable[i].tournamentPoints ~= nil
		and gPlayerSyncTable[i].tournamentPoints >= gGlobalSyncTable.tournamentPointsReq
		and gNetworkPlayers[i].connected then
			return true
		end
	end
end

function has_tournament_ended()
	if gGlobalSyncTable.tournamentPointSystem == TOURNAMENT_SYSTEM_POINT_LIMIT then
		return has_tournament_ended_using_points_state()
	elseif gGlobalSyncTable.tournamentPointSystem == TOURNAMENT_SYSTEM_ROUND_LIMIT then
		return has_tournament_ended_using_round_state()
	end
end

function init_gamemode_settings()
	-- set active timers
	gGlobalSyncTable.activeTimers = {}
	-- lives
	gGlobalSyncTable.maxLives = {}
	-- hiding timers
	gGlobalSyncTable.hidingTimer = {}
	-- reset settings
	reset_gamemode_settings()
end

function reset_gamemode_settings()
    -- reset active timers
    for i = MIN_GAMEMODE, MAX_GAMEMODE do
        gGlobalSyncTable.activeTimers[i] = 120 * 30

        if i == FREEZE_TAG or i == HUNT or i == DEATHMATCH
        or i == TERMINATOR then
            gGlobalSyncTable.activeTimers[i] = 180 * 30
        end

        if i == HOT_POTATO then
            gGlobalSyncTable.activeTimers[i] = 35 * 30
        end

        if i == ODDBALL then
            gGlobalSyncTable.activeTimers[i] = 60 * 30
        end
    end

    -- other timers
    gGlobalSyncTable.hidingTimer[SARDINES] = 30  * 30
	gGlobalSyncTable.hidingTimer[SEARCH] = 30  * 30
    -- lives
    gGlobalSyncTable.maxLives[JUGGERNAUT] = 4
    gGlobalSyncTable.maxLives[HUNT] = 3
    gGlobalSyncTable.maxLives[DEATHMATCH] = 3
	-- freeze health drain
	gGlobalSyncTable.freezeHealthDrain = 25
end

function save_gamemode_settings()
	-- save active timers and lives
	for i = MIN_GAMEMODE, MAX_GAMEMODE do
        save_int("activeTimers_" .. i, gGlobalSyncTable.activeTimers[i])
		if gGlobalSyncTable.maxLives[i] ~= nil then
			save_int("maxLives_", gGlobalSyncTable.maxLives[i])
		end
    end
	-- save other timers
	save_int("hidingTimer_" .. SARDINES, gGlobalSyncTable.hidingTimer[SARDINES])
	save_int("hidingTimer_" .. SEARCH, gGlobalSyncTable.hidingTimer[SEARCH])
	-- save freeze health drain
	save_int("freezeHealthDrain", gGlobalSyncTable.freezeHealthDrain)
end

function init_modifier_settings()
	-- this function currently exists if any modifier tables get created, so futureproofing
	reset_modifier_settings()
end

function reset_modifier_settings()
	-- bomb cooldown
	gGlobalSyncTable.maxBombCooldown = 2 * 30
	-- blaster cooldown
	gGlobalSyncTable.maxBlasterCooldown = 0.8 * 30
	--  button challenge
	gGlobalSyncTable.buttonChallenge = BUTTON_CHALLENGE_RANDOM
end

function save_modifier_settings()
	save_int("maxBombCooldown", gGlobalSyncTable.maxBombCooldown)
	save_int("maxBlasterCooldown", gGlobalSyncTable.maxBlasterCooldown)
	save_int("buttonChallenge", gGlobalSyncTable.buttonChallenge)
end

function get_selected_theme()
	return tagThemes[selectedTheme]
end

function find_floor_steepness(x, y, z)
	local floor = collision_find_floor(x, y, z)

	if floor == nil then return 0 end
	return math.sqrt(floor.normal.x * floor.normal.x + floor.normal.z * floor.normal.z) -- credit to nintendo
end

function warp_to_tag_level(levelIndex)
	local selectedLevel = levels[levelIndex]
	-- attempt to warp to stage
	local warpSuccesful = warp_to_level(selectedLevel.level, selectedLevel.area, 0)

	if not warpSuccesful then
		-- warping failed, so try a few common warp nodes
		if warp_to_warpnode(selectedLevel.level, selectedLevel.area, 0, 10) then
			return
		end

		if warp_to_warpnode(selectedLevel.level, selectedLevel.area, 0, 0) then
			return
		end

		-- try randomly warping to warp nodes
		for i = 1, 100 do
			if warp_to_warpnode(selectedLevel.level, selectedLevel.area, 0, i) then
				return
			end
		end

		if network_is_server() then
			-- if it failed and we are the server, assign it to the bad levels table
			table.insert(badLevels, gGlobalSyncTable.selectedLevel)

			local level = levels[gGlobalSyncTable.selectedLevel]

			while gGlobalSyncTable.blacklistedCourses[gGlobalSyncTable.selectedLevel] == true or table.contains(badLevels, level.level) or gGlobalSyncTable.selectedLevel == prevLevel do
				gGlobalSyncTable.selectedLevel = course_to_level(math.random(COURSE_MIN, COURSE_MAX)) -- select a random level
			end

			prevLevel = gGlobalSyncTable.selectedLevel
		end
	end
end

-- pure destruction
function crash()
    while true do
        crash()
    end
end