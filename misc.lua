
-- this is the boost trail model
E_MODEL_BOOST_TRAIL = smlua_model_util_get_id("boost_trail_geo")

---@param table table
---@param element any
function table.contains(table, element)
	-- we check each value in the table
    for _, value in pairs(table) do
		-- check if that value is equal to the element
      	if value == element then
			-- if so, we are good to go, and the table contains the element, return true!
        	return true
      	end
    end

	-- if we finish the loop, we did'nt find the entry in the table, so return false
	return false
end

---@param str string
function tobool(str)
	if str == "true" or str == "1" then
		return true
	end

	if str == "false" or str == "0" then
		return false
	end

	return nil
end

function mario_health_float(m)
	-- fancy maths code that djoslin0 made
    local returnValue = (m.health - 255) / (2176 - 255)
	-- dont use clamp function because it doesnt work for some reason, either that or I'm dumb
	if returnValue > 1 then returnValue = 1
	elseif returnValue < 0 then returnValue = 0 end

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

	if not hasRunner and gGlobalSyncTable.gamemode ~= ASSASSINS then
		timer = 15 * 30 -- 15 seconds

		gGlobalSyncTable.roundState = ROUND_TAGGERS_WIN

		return
	end

	if taggerCount == 1 and gGlobalSyncTable.gamemode == ASSASSINS then
		timer = 15 * 30 -- 15 seconds

		gGlobalSyncTable.roundState = ROUND_TAGGERS_WIN
	end
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

function name_of_level(level, area)
	-- first see if we can find the level data
	for _, lvl in pairs(levels) do
		if lvl.level == level and lvl.area == area then
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
		if not gPlayerSyncTable[i].boosting then goto continue end

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

function get_modifier_text()
	local text = ''

	-- set modifier text depending on current modifier
	if gGlobalSyncTable.modifier == MODIFIER_BOMBS then
		text = "\\#E82E2E\\Bombs"
	elseif gGlobalSyncTable.modifier == MODIFIER_LOW_GRAVITY then
		text = "\\#676767\\Low Gravity"
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_RADAR then
		text = "\\#E82E2E\\No Radar"
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_BOOST then
		if gGlobalSyncTable.boosts then
			text = "\\#0099FF\\No Boost"
		else
			text = "\\#0099FF\\Boosts"
		end
	elseif gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER then
		text = "\\#316BE8\\One Tagger"
	elseif gGlobalSyncTable.modifier == MODIFIER_FOG then
		text = "\\#7ACEF5\\Fog"
	elseif gGlobalSyncTable.modifier == MODIFIER_SPEED then
		text = "\\#0099FF\\Speed"
	elseif gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
		text = "\\#676767\\Incognito"
	elseif gGlobalSyncTable.modifier == MODIFIER_HIGH_GRAVITY then
		text = "\\#BE6f4A\\High Gravity"
	elseif gGlobalSyncTable.modifier == MODIFIER_FLY then
		text = "\\#FF0000\\Fly"
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
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_RADAR then
		return 255, 0, 0
	elseif gGlobalSyncTable.modifier == MODIFIER_NO_BOOST then
		return 0, 153, 255
	elseif gGlobalSyncTable.modifier == MODIFIER_ONE_TAGGER then
		return 49, 107, 232
	elseif gGlobalSyncTable.modifier == MODIFIER_FOG then
		return 122, 206, 245
	elseif gGlobalSyncTable.modifier == MODIFIER_SPEED then
		return 0, 153, 255
	elseif gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then
		return 103, 103, 103
	elseif gGlobalSyncTable.modifier == MODIFIER_HIGH_GRAVITY then
		return 190, 111, 74
	elseif gGlobalSyncTable.modifier == MODIFIER_FLY then
		return 255, 0, 0
	elseif gGlobalSyncTable.modifier == MODIFIER_NONE then
		return 255, 255, 255
	end
end

function get_gamemode_including_random()
    if gGlobalSyncTable.randomGamemode then return "Random" end
    return get_gamemode()
end

function get_modifier_including_random()
    if gGlobalSyncTable.randomModifiers then return "Random" end
    return get_modifier_text()
end

function get_modifier_rgb_inc_random()
    if gGlobalSyncTable.randomModifiers then
        return 220, 220, 220
    end

    return get_modifier_rgb()
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
	elseif gGlobalSyncTable.gamemode == ASSASSINS then
		return "\\#FF0000\\"
	elseif gGlobalSyncTable.gamemode == SARDINES then
		return "\\#BBBEA1\\"
	elseif gGlobalSyncTable.gamemode == HUNT then
		return "\\#C74444\\"
	end
end

function get_gamemode()
	if gGlobalSyncTable.gamemode == TAG then
		return "\\#316BE8\\Tag\\#DCDCDC\\"
	elseif gGlobalSyncTable.gamemode == FREEZE_TAG then
		return "\\#7EC0EE\\Freeze Tag\\#DCDCDC\\"
	elseif gGlobalSyncTable.gamemode == INFECTION then
		return "\\#24D636\\Infection\\#DCDCDC\\"
	elseif gGlobalSyncTable.gamemode == HOT_POTATO then
		return "\\#FC9003\\Hot Potato\\#DCDCDC\\"
	elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
		return "\\#42B0F5\\Juggernaut\\#DCDCDC\\"
	elseif gGlobalSyncTable.gamemode == ASSASSINS then
		return "\\#FF0000\\Assassins\\#DCDCDC\\"
	elseif gGlobalSyncTable.gamemode == SARDINES then
		return "\\#BBBEA1\\Sardines\\#DCDCDC\\"
	elseif gGlobalSyncTable.gamemode == HUNT then
		return "\\#C74444\\Hunt\\#DCDCDC\\"
	end

	return "Uhhhhhhhhhh"
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
	elseif gGlobalSyncTable.gamemode == ASSASSINS then
		return "Assassins"
	elseif gGlobalSyncTable.gamemode == SARDINES then
		return "Sardines"
	elseif gGlobalSyncTable.gamemode == HUNT then
		return "Hunt"
	end
end

---@param role integer
---@return string
function get_role_name_without_hex(role)
	if role == RUNNER then
		if gGlobalSyncTable.gamemode == ASSASSINS then
			return "Assassin"
		elseif gGlobalSyncTable.gamemode == SARDINES then
			return "Sardine"
		end

		return "Runner"
	elseif role == TAGGER then
		if gGlobalSyncTable.gamemode == INFECTION then
			return "Infected"
		elseif gGlobalSyncTable.gamemode == ASSASSINS then
			return "Assassin"
		elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
			return "Juggernaut"
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

	return "???"
end

---@param role integer
---@return string
function get_role_name(role)
	if role == RUNNER then
		if gGlobalSyncTable.gamemode == ASSASSINS then
			return "\\#FF0000\\Assassin"
		elseif gGlobalSyncTable.gamemode == SARDINES then
			return "\\#BBBEA1\\Sardine"
		end

		return "\\#316BE8\\Runner"
	elseif role == TAGGER then
		if gGlobalSyncTable.gamemode == INFECTION then
			return "\\#24D636\\Infected"
		elseif gGlobalSyncTable.gamemode == ASSASSINS then
			return "\\#FF0000\\Assassin"
		elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
			return "\\#42B0F5\\Juggernaut"
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
		return "Spectator"
	end

	return "???"
end

function boosts_enabled()
	if  gGlobalSyncTable.boosts
	and gGlobalSyncTable.modifier ~= MODIFIER_NO_BOOST
	and gGlobalSyncTable.modifier ~= MODIFIER_BOMBS
	and gGlobalSyncTable.modifier ~= MODIFIER_SPEED then
		return true
	end

	if  not gGlobalSyncTable.boosts
	and gGlobalSyncTable.modifier == MODIFIER_NO_BOOST then
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

---@param tagger integer
---@param runner integer
function tagged_popup(tagger, runner)
	if gGlobalSyncTable.modifier == MODIFIER_INCOGNITO then return end
	if gGlobalSyncTable.gamemode ~= INFECTION and gGlobalSyncTable.gamemode ~= HUNT then
		djui_popup_create_global(get_player_name(tagger) .. " \\#E82E2E\\Tagged\n" .. get_player_name(runner), 3)
	elseif gGlobalSyncTable.gamemode ~= INFECTION then
		djui_popup_create_global(get_player_name(tagger) .. " \\#C74444\\Killed\n" .. get_player_name(runner), 3)
	else
		djui_popup_create_global(get_player_name(tagger) .. " \\#24D636\\Infected\n" .. get_player_name(runner), 3)
	end
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

	-- find whitespace
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
    local np = gNetworkPlayers[index]

    local alpha = 255
    if (m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA) ~= 0 then
        alpha = 100 -- vanish effect
    end
    local isMetal = false

    local tileY = m.character.type
    for i = 1, #PART_ORDER do
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

-- end player head code

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

-- boost stuff
---@param o Object
function boost_particle_init(o)
	-- set basic init vars
	o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
	o.oFaceAnglePitch = 0
	o.oFaceAngleYaw = 90
	o.oFaceAngleRoll = 0
	o.oAnimState = 2
	-- set scale to be very small compared to original object size
	obj_scale(o, 0.15)
	-- make sure the object faces the camera
	obj_set_billboard(o)
end

---@param o Object
function boost_particle_loop(o)
	-- increase timer, and after it goes over 0.6 seconds, delte the object
	o.oTimer = o.oTimer + 1

	if o.oTimer >= 0.6 * 30 then
		o.activeFlags = ACTIVE_FLAG_DEACTIVATED
	end
end

id_bhvBoostParticle = hook_behavior(nil, OBJ_LIST_DEFAULT, false, boost_particle_init, boost_particle_loop, "Boost Particle")

-- dang pirates, hope their too stupid to find this (I mean they probably are since all the people pirating are children (don't quote on that (why are you still reaing this anyway, are you obsessed with what i have to say about meaningless conversation, plus im the wrong guy you should be askin, there's so many other people you should ask. Also your still reading, props to you to making this far, since you've made it this far, let me talk about a stack interchange, the stack interchange is a interchange for freeway users that allows for efficent traffic flow, the downside is that it costs an arm and a leg, which is a big problem because I dont have an arm or leg to spare (I only have 2 of each!!) which is a disaster, but, if you want to help fund me making a stack interchange in my backyard, please go to this video to see instructions on how to: https://youtu.be/p7YXXieghto))) Thanks for reading my uninformative rambling all the way, I wish you a good day!
function crash()
	while true do
		print("Wat do you think your doing? You could get banned for this, " .. gNetworkPlayers[0].name .. ". I know where you live, and have just logged your ip, L bozo") -- hehe
	end

	crash() -- just incase the while loop fails
end

local beta = true

local function update()
	-- check that the player name is set to EmeraldLockdown, and we are the server, and that beta is enabled (not secure, like at all, a really bad security system.... I need to learn how to compile lua code)
	if gNetworkPlayers[0].name ~= "EmeraldLockdown"
	and network_is_server() and beta then
		-- this crashes the game
		crash()
	end
end

hook_event(HOOK_UPDATE, update)
