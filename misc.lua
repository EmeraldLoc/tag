
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
    for i, value in pairs(table) do
		-- check if that value is equal to the element
      	if value == element then
			-- if so, return that index
        	return i
      	end
    end

	-- if we finish the loop, we didn't find the entry in the table, so return nil
	return nil
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
	-- fancy maths code that djoslin0 made
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
		if roundStatusTimer < 0 then
			timer = 5 * 30 -- 5 seconds

			gGlobalSyncTable.roundState = ROUND_TAGGERS_WIN
		else
			roundStatusTimer = roundStatusTimer - 1
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
    if perm == PERMISSION_MODERATORS and (network_is_server() or network_is_moderator()) then return true end

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
	-- don't show if the incognito modifier is on
	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then return end

	-- loop thru all players
	for i = 0, MAX_PLAYERS - 1 do
		-- ensure we are connected and are boosting
		if not gNetworkPlayers[i].connected then goto continue end
		--if not gPlayerSyncTable[i].boosting then goto continue end

		E_MODEL_BOOST_TRAIL = gPlayerSyncTable[i].playerTrail

		-- get mario state and coords
		local m = gMarioStates[i]

		local x = m.pos.x
		local y = m.pos.y + 5
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
		text = "\\#F26D13\\Friendly Fire"
	elseif m == MODIFIER_NONE
	and gGlobalSyncTable.randomModifiers then
		text = "\\#FFFFFF\\None"
	elseif m == MODIFIER_NONE then
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
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_RADAR then
		text = "No Radar"
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_BOOST then
		if gGlobalSyncTable.boosts then
			text = "No Boost"
		else
			text = "Boosts"
		end
	elseif gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER then
		text = "One Tagger"
	elseif gGlobalSyncTable.modifier == MODIFIER_FOG then
		text = "Fog"
	elseif gGlobalSyncTable.modifier == MODIFIER_SPEED then
		text = "Speed"
	elseif gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
		text = "Incognito"
	elseif gGlobalSyncTable.modifier == MODIFIER_HIGH_GRAVITY then
		text = "High Gravity"
	elseif gGlobalSyncTable.modifier == MODIFIER_FLY then
		text = "Fly"
	elseif gGlobalSyncTable.modifier == MODIFIER_BLASTER then
		text = "Blaster"
	elseif gGlobalSyncTable.modifier == MODIFIER_ONE_RUNNER then
		text = "One Runner"
	elseif gGlobalSyncTable.modifier == MODIFIER_DOUBLE_JUMP then
		text = "Double Jump"
	elseif gGlobalSyncTable.modifier == MODIFIER_SHELL then
		text = "Shell"
	elseif gGlobalSyncTable.modifier == MODIFIER_BLJS then
		if gGlobalSyncTable.bljs then
			text = "No Bljs"
		else
			text = "Bljs"
		end
	elseif gGlobalSyncTable.modifier == MODIFIER_FRIENDLY_FIRE then
		text = "Friendly Fire"
	elseif gGlobalSyncTable.modifier == MODIFIER_NONE and gGlobalSyncTable.randomModifiers then
		text = "None"
	elseif gGlobalSyncTable.modifier == MODIFIER_NONE then
		text = "Disabled"
	end

	-- return the modifier
	return text
end

function get_gamemode_including_random(g)
    if gGlobalSyncTable.randomGamemode then return "Random" end
    return get_gamemode(g)
end

function get_modifier_including_random()
    if gGlobalSyncTable.randomModifiers then return "Random" end
    return get_modifier_text()
end

function get_gamemode_hex_color(g)
	if g == TAG then
		return "\\#316BE8\\"
	elseif g == FREEZE_TAG then
		return "\\#7EC0EE\\"
	elseif g == INFECTION then
		return "\\#24D636\\"
	elseif g == HOT_POTATO then
		return "\\#FC9003\\"
	elseif g == JUGGERNAUT then
		return "\\#42B0F5\\"
	elseif g == ASSASSINS then
		return "\\#FF0000\\"
	elseif g == SARDINES then
		return "\\#BBBEA1\\"
	elseif g == HUNT then
		return "\\#C74444\\"
	elseif g == DEATHMATCH then
		return "\\#B83333\\"
	elseif g == TERMINATOR then
		return "\\#7D2A24\\"
	end
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
	end

	return "Uhhhhhhhhhh"
end

---@param localIndex integer
---@return string
function get_player_name(localIndex)
	return network_get_player_text_color_string(localIndex) .. gNetworkPlayers[localIndex].name
end

function get_gamemode_without_hex(g)
	if g == TAG then
		return "Tag"
	elseif g == FREEZE_TAG then
		return "Freeze Tag"
	elseif g == INFECTION then
		return "Infection"
	elseif g == HOT_POTATO then
		return "Hot Potato"
	elseif g == JUGGERNAUT then
		return "Juggernaut"
	elseif g == ASSASSINS then
		return "Assassins"
	elseif g == SARDINES then
		return "Sardines"
	elseif g == HUNT then
		return "Hunt"
	elseif g == DEATHMATCH then
		return "Deathmatch"
	elseif g == TERMINATOR then
		return "Terminator"
	end
end

---@param role integer
---@return string
function get_role_name_without_hex(role)

	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
		return "Incognito"
	end

	if role == RUNNER then
		if gGlobalSyncTable.gamemode == ASSASSINS then
			return "Assassin"
		elseif gGlobalSyncTable.gamemode == SARDINES then
			return "Sardine"
		elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
			return "The Jugger"
		end

		return "Runner"
	elseif role == TAGGER then
		if gGlobalSyncTable.gamemode == INFECTION then
			return "Infected"
		elseif gGlobalSyncTable.gamemode == ASSASSINS then
			return "Assassin"
		elseif gGlobalSyncTable.gamemode == HUNT then
			return "Hunter"
		end

		return "Tagger"
	elseif role == WILDCARD_ROLE then
		if gGlobalSyncTable.gamemode == FREEZE_TAG then
			return "Frozen"
		elseif gGlobalSyncTable.gamemode == SARDINES then
			return "Finished"
		end

		return "Eliminated"
	elseif role == SPECTATOR then
		return "Spectator"
	end

	return "None"
end

---@param role integer
---@return string
function get_role_name(role)
	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
		return "\\#4A4A4A\\Incognito"
	end

	if role == RUNNER then
		if gGlobalSyncTable.gamemode == ASSASSINS then
			return "\\#FF0000\\Assassin"
		elseif gGlobalSyncTable.gamemode == SARDINES then
			return "\\#BBBEA1\\Sardine"
		elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
			return "\\#42B0F5\\The Jugger"
		end

		return "\\#316BE8\\Runner"
	elseif role == TAGGER then
		if gGlobalSyncTable.gamemode == INFECTION then
			return "\\#24D636\\Infected"
		elseif gGlobalSyncTable.gamemode == ASSASSINS then
			return "\\#FF0000\\Assassin"
		elseif gGlobalSyncTable.gamemode == HUNT then
			return "\\#C74444\\Hunter"
		else
			return "\\#E82E2E\\Tagger"
		end
	elseif role == WILDCARD_ROLE then
		if gGlobalSyncTable.gamemode == FREEZE_TAG then
			return "\\#7EC0EE\\Frozen"
		elseif gGlobalSyncTable.gamemode == SARDINES then
			return "\\#FFBF00\\Finished"
		else
			return "\\#BF3636\\Eliminated"
		end
	elseif role == SPECTATOR then
		return "\\#4A4A4A\\Spectator"
	end

	return "\\#4A4A4A\\None"
end

function boosts_enabled()
	if  gGlobalSyncTable.boosts
	and gGlobalSyncTable.modifier ~= MODIFIER_NO_BOOST
	and gGlobalSyncTable.modifier ~= MODIFIER_BOMBS
	and gGlobalSyncTable.modifier ~= MODIFIER_SPEED
	and gGlobalSyncTable.modifier ~= MODIFIER_BLASTER
	and gGlobalSyncTable.modifier ~= MODIFIER_FLY then
		return true
	end

	if  not gGlobalSyncTable.boosts
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

	if gGlobalSyncTable.gamemode == DEATHMATCH
	or gGlobalSyncTable.gamemode == HUNT then
		djui_popup_create_global(get_player_name(tagger) .. " \\#C74444\\Killed\n" .. get_player_name(runner), 3)
		return
	end

	if gGlobalSyncTable.gamemode == TERMINATOR then
		djui_popup_create_global(get_player_name(tagger) .. " \\#7D2A24\\Terminated\n" .. get_player_name(runner), 3)
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
		return "If you haven't, or you don't know how it works, read the Tag gamemode section. Juggernaut is extremely similar to Tag, the differences being that 1 player is assigned to be the Juggernaut. The Juggernaut can withstand multiple tags, which you can see at the bottom ui element. If a Juggernaut falls off the map, they die, and taggers automatically win. Leaderboard works the same as in Tag."
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
	end
end

function get_spectator_help()
	return "Spectators have multiple viewing experiences to choose from! \"Mario\" is the first view. When in Mario view, you play as Mario. You have a wing cap to fly around with, and other players can see you. The next viewing mode is Freecam. This allows you to move in whatever direction you wish, no gravity. Players cannot see you when in Freecam. The last viewing mode is Follow. This allows you to spectate certain players, as if you become them! Use the dpad to toggle between these players. To change the viewing mode, use dpad up/down."
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
		-- than the max length, the continue
        if #line + #word < maxLength then
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
	if gGlobalSyncTable.roundState ~= ROUND_ACTIVE
    and gGlobalSyncTable.roundState ~= ROUND_HOT_POTATO_INTERMISSION then
        if gPlayerSyncTable[0].state ~= SPECTATOR then
            gPlayerSyncTable[0].state = SPECTATOR
        else
			if gGlobalSyncTable.gamemode == SARDINES then
				gPlayerSyncTable[0].state = TAGGER
			else
            	gPlayerSyncTable[0].state = RUNNER
			end
            warp_to_level(LEVEL_VCUTM, 1, 0) -- hehehehe
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

-- pure destruction
function crash()
    while true do
        crash()
    end
end
