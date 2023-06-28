
---@diagnostic disable: param-type-mismatch

local version = "v2.1"

---@param msg string
function start_command(msg)

	if network_player_connected_count() < PLAYERS_NEEDED then
		djui_chat_message_create("Not enough players to start the round")

		return true
	end

	if tonumber(msg) ~= nil then
		if not isRomhack then
			for i, level in pairs(levels) do
				if level_to_course(level.level) == tonumber(msg) then
					timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16
					gGlobalSyncTable.selectedLevel = i
					prevLevel = gGlobalSyncTable.selectedLevel
					gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state

					djui_chat_message_create("Starting game in level " .. get_level_name(level_to_course(level.level), level.level, 1))

					return true
				end
			end
		else
			for i = COURSE_MIN, COURSE_MAX do
				if tonumber(msg) == i then
					timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16
					gGlobalSyncTable.selectedLevel = course_to_level(i)
					prevLevel = gGlobalSyncTable.selectedLevel
					gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state

					djui_chat_message_create("Starting game in level " .. get_level_name(i, course_to_level(i), 1))

					return true
				end
			end
		end
	else
		if isRomhack then
			for i = COURSE_MIN, COURSE_MAX do
				if msg:lower() == get_level_name(i, course_to_level(i), 1):lower() and (not table.contains(defaultLevels, string.upper(get_level_name(level_to_course(gGlobalSyncTable.selectedLevel), gGlobalSyncTable.selectedLevel, 1))) and level_to_course(gGlobalSyncTable.selectedLevel) < COURSE_RR and level_to_course(gGlobalSyncTable.selectedLevel) > COURSE_MIN - 1) then
					timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16
					gGlobalSyncTable.selectedLevel = course_to_level(i)
					prevLevel = gGlobalSyncTable.selectedLevel
					gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state

					djui_chat_message_create("Starting game in level " .. get_level_name(i, course_to_level(i), 1))

					return true
				end
			end
		else
			for i, level in pairs(levels) do
				if msg:lower() == level.name or msg:lower() == get_level_name(level_to_course(level.level), level.level, 1):lower() then
					timer = 16 * 30 -- 16 seconds, 16 so the 15 shows, you probably won't see the 16
					gGlobalSyncTable.selectedLevel = i
					prevLevel = gGlobalSyncTable.selectedLevel
					gGlobalSyncTable.roundState = ROUND_WAIT -- set round state to the intermission state
	
					if level.level ~= LEVEL_CASTLE_GROUNDS then
						djui_chat_message_create("Starting game in level " .. get_level_name(level_to_course(level.level), level.level, 1))
					else
						djui_chat_message_create("Starting game in level Castle Grounds") -- since castle grounds doesnt have a course, manually set it
					end
	
					return true
				end
			end
		end
	end

	gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS

	djui_chat_message_create("Starting round")

	return true

end

---@param msg string
function do_caps_command(msg)
	-- create text
	local text = ""

	-- check message
	if msg == "yes" or msg == "on" or msg == "enable" then
		text = "You can now use caps"

		gGlobalSyncTable.doCaps = true
	elseif msg == "no" or msg == "off" or msg == "disable" then
		text = "You can no longer use caps"

		gGlobalSyncTable.doCaps = false
	else
		if gGlobalSyncTable.doCaps then
			text = "Current cap status: enabled"
		else
			text = "Current cap status: disabled"
		end
	end

	-- show message in chat
	djui_chat_message_create(text)

	return true
end

---@param msg string
function cannons_command(msg)
	-- create text
	local text = ""

	-- check message
	if msg == "yes" or msg == "on" or msg == "enable" then
		text = "You can now use cannons"

		gGlobalSyncTable.cannons = true
	elseif msg == "no" or msg == "off" or msg == "disable" then
		text = "You can no longer use cannons"

		gGlobalSyncTable.cannons = false
	else
		if gGlobalSyncTable.cannons then
			text = "Current cannon status: enabled"
		else
			text = "Current cannon status: disabled"
		end
	end

	-- show message in chat
	djui_chat_message_create(text)

	return true
end

---@param msg string
function bljs_command(msg)
	-- create text
	local text = ""

	-- check message
	if msg == "yes" or msg == "on" or msg == "enable" then
		text = "You can now blj"

		gGlobalSyncTable.bljs = true
	elseif msg == "no" or msg == "off" or msg == "disable" then
		text = "You can no longer blj"

		gGlobalSyncTable.bljs = false
	else
		if gGlobalSyncTable.bljs then
			text = "Current blj status: enabled"
		else
			text = "Current blj status: disabled"
		end
	end

	-- show message in chat
	djui_chat_message_create(text)

	return true
end

---@param msg string
function on_time_command(msg)
    if tonumber(msg) ~= nil then
    	djui_chat_message_create("Set amount of time to " .. msg .. " seconds")

		-- convert from frames to seconds by multiplying by 30
		gGlobalSyncTable.amountOfTime = tonumber(msg) * 30
    else
        djui_chat_message_create("Current time is " .. gGlobalSyncTable.amountOfTime .. " seconds")
    end

	return true
end

---@param msg string
function on_tp_command(msg)

	if gGlobalSyncTable.gamemode ~= TAG and gPlayerSyncTable[0].state ~= SPECTATOR then
		djui_chat_message_create("This command only works in the tag gamemode or if your a spectator")
	end

	if gPlayerSyncTable[0].state ~= ELIMINATED_OR_FROZEN and gPlayerSyncTable[0].state ~= SPECTATOR then
		djui_chat_message_create("You must be eliminated or a spectator to run this command")

		return true
	end

	if tonumber(msg) ~= nil then

		local index = tonumber(msg)

		if index > MAX_PLAYERS then
			djui_chat_message_create("Please type a number under " .. tostring(MAX_PLAYERS + 1))

			return true
		end

		if index <= 0 then
			djui_chat_message_create("Please type a number greater than 0")

			return true
		end

		if gNetworkPlayers[index].connected then
			local m = gMarioStates[0]
			local t = gMarioStates[index]

			m.pos.x = t.pos.x
			m.pos.y = t.pos.y
			m.pos.z = t.pos.z

			djui_chat_message_create("Teleported to " .. network_get_player_text_color_string(index) .. gNetworkPlayers[index].name)
		else
			djui_chat_message_create("This player is not online")

			return true
		end
	else
		for i = 0, network_player_connected_count() do
			if msg:lower() == strip_hex(gNetworkPlayers[i].name):lower() and msg ~= "" then
				local m = gMarioStates[0]
				local t = gMarioStates[i]

				m.pos.x = t.pos.x
				m.pos.y = t.pos.y
				m.pos.z = t.pos.z

				djui_chat_message_create("Teleported to " .. network_get_player_text_color_string(i) .. gNetworkPlayers[i].name)

				return true
			end
		end

		djui_chat_message_create("Player not found")

		return true
	end
end

---@param msg string
function on_version_command(msg)
	djui_chat_message_create("Current \\#316BE8\\Tag \\#FFFFFF\\Version: " .. version)

	return true
end

---@param msg string
function blacklist_course_command(msg)

	if not isRomhack then
		djui_chat_message_create("This only works for romhacks")

		return true
	end

	if string.match(msg, "add ") then
		local course = msg:gsub("add ", "")
		if tonumber(course) ~= nil then
			for i = COURSE_MIN, COURSE_MAX do
				if tonumber(course) == i then
					table.insert(blacklistedLevels, i)

					djui_chat_message_create("Blacklisted " .. get_level_name(i, course_to_level(i), 1))

					return true
				end
			end

			djui_chat_message_create("Course " .. course .. " not found")
			
			return true
		else
			for i = COURSE_MIN, COURSE_MAX do
				if course:lower() == get_level_name(i, course_to_level(i), 1):lower() then
					table.insert(blacklistedLevels, i)

					djui_chat_message_create("Blacklisted " .. get_level_name(i, course_to_level(i), 1))

					return true
				end
			end

			djui_chat_message_create("Course " .. course .. " not found")

			return true
		end
	elseif string.match(msg, "remove ") then
		local course = msg:gsub("remove ", "")
		if tonumber(course) ~= nil then
			if table.contains(blacklistedLevels, tonumber(course)) then
				table.remove(blacklistedLevels, tonumber(course))

				djui_chat_message_create("Removed course " .. get_level_name(tonumber(course), course_to_level(tonumber(course)), 1) .. " from blacklist")

				return true
			end

			djui_chat_message_create("Course " .. course .. " not found")

			return true
		else
			for i = 1, #blacklistedLevels do
				if course:lower() == get_level_name(blacklistedLevels[i], course_to_level(blacklistedLevels[i]), 1):lower() then
					table.remove(blacklistedLevels, i)

					djui_chat_message_create("Removed course " .. get_level_name(i, course_to_level(i), 1) .. " from blacklist")

					return true
				end
			end

			djui_chat_message_create("Course " .. course .. " not found")

			return true
		end
	elseif string.match(msg, "list ") then
		local option = msg:gsub("list ", "")

		if option == "names" then
			djui_chat_message_create("Blacklisted Levels:")

			for i = 1, #blacklistedLevels do
				djui_chat_message_create(get_level_name(blacklistedLevels[i], course_to_level(blacklistedLevels[i]), 1))
			end

			return true
		elseif option == "indexes" then
			djui_chat_message_create("Blacklisted Levels:")

			for i = 1, #blacklistedLevels do
				djui_chat_message_create(tostring(blacklistedLevels[i]))
			end

			return true
		end

		djui_chat_message_create("Options:")
		djui_chat_message_create("indexes	List blacklist entries as indexes")
		djui_chat_message_create("names	List blacklist entries as names")

		return true
	end

	djui_chat_message_create("Options:")
	djui_chat_message_create("add       Add to blacklist")
	djui_chat_message_create("remove    Remove from blacklist")
	djui_chat_message_create("list      List items in blacklist")

	return true
end

---@param msg string
function anti_camp_command(msg)

		if string.match(msg, "time") then
			local time = msg:gsub("time ", "")

			if tonumber(time) ~= nil then
				-- convert from seconds to frames by multiplying by 30
				gGlobalSyncTable.antiCampTimer = tonumber(time) * 30
				djui_chat_message_create("Set anti camp timer to " .. time .. " seconds")
			else
				-- convert from frames to seconds by dividing by 30
				djui_chat_message_create("Current anti camp timer is " .. gGlobalSyncTable.antiCampTimer / 30 .. " seconds")
			end

			return true
		elseif string.match(msg, "status") then
			local status = msg:gsub("status ", "")

			if status == "on" or status == "enable" then
				gGlobalSyncTable.antiCamp = true
				djui_chat_message_create("Set anti camp status to enabled")
			elseif status == "off" or status == "disable" then
				gGlobalSyncTable.antiCamp = false
				djui_chat_message_create("Set anti camp status to disabled")
			else
				if gGlobalSyncTable.antiCampTimer then
					djui_chat_message_create("Current status is on")
				else
					djui_chat_message_create("Current status is off")
				end
			end

			return true
		end

	djui_chat_message_create("Options:")
	djui_chat_message_create("time      [none|number] Get or set time")
	djui_chat_message_create("status    [none|on|off] Get or set status")

	return true
end

---@param msg string
function on_gamemode_command(msg)
	if network_is_server() then
		if msg:lower() == "tag" then
			if gGlobalSyncTable.gamemode ~= TAG or gGlobalSyncTable.randomGamemode then
				-- set gamemode
				djui_chat_message_create("Set gamemode to \\#316BE8\\Tag")
				gGlobalSyncTable.gamemode = -1 -- force popup to show
				gGlobalSyncTable.gamemode = TAG

				-- default tag timer
				if gGlobalSyncTable.amountOfTime == (180 * 30) or gGlobalSyncTable.amountOfTime == (60 * 30) then
					gGlobalSyncTable.amountOfTime = 120 * 30
				end

				-- set players needed
				PLAYERS_NEEDED = 2

				-- disable random gamemode
				gGlobalSyncTable.randomGamemode = false

				-- restart round
				gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS

				return true
			else
				djui_chat_message_create("Gamemode is already set to \\#316BE8\\Tag")

				return true
			end
		elseif msg:lower() == "freeze tag" or msg:lower() == "freeze" then
			if gGlobalSyncTable.gamemode ~= FREEZE_TAG or gGlobalSyncTable.randomGamemode then
				-- set gamemode
				djui_chat_message_create("Set gamemode to Freeze Tag")
				gGlobalSyncTable.gamemode = -1 -- force popup to show
				gGlobalSyncTable.gamemode = FREEZE_TAG

				-- default freeze tag timer
				if gGlobalSyncTable.amountOfTime == (120 * 30) or gGlobalSyncTable.amountOfTime == (60 * 30) then
					gGlobalSyncTable.amountOfTime = 180 * 30
				end

				-- set players needed
				PLAYERS_NEEDED = 3

				-- disable random gamemode
				gGlobalSyncTable.randomGamemode = false

				-- restart round
				gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS

				return true
			else
				djui_chat_message_create("Gamemode is already set to Freeze Tag")

				return true
			end
		elseif msg:lower() == "infection" then
			if gGlobalSyncTable.gamemode ~= INFECTION or gGlobalSyncTable.randomGamemode then
				-- set gamemode
				djui_chat_message_create("Set gamemode to Infection")
				gGlobalSyncTable.gamemode = -1 -- force popup to show
				gGlobalSyncTable.gamemode = INFECTION

				-- default infection timer
				if gGlobalSyncTable.amountOfTime == (180 * 30) or gGlobalSyncTable.amountOfTime == (60 * 30) then
					gGlobalSyncTable.amountOfTime = 120 * 30
				end

				-- set players needed
				PLAYERS_NEEDED = 3

				-- disable random gamemode
				gGlobalSyncTable.randomGamemode = false

				-- restart round
				gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS

				return true
			else
				djui_chat_message_create("Gamemode is already set to Infection")

				return true
			end
		elseif msg:lower() == "hot potato" or msg:lower() == "hot" then
			if gGlobalSyncTable.gamemode ~= HOT_POTATO or gGlobalSyncTable.randomGamemode then
				-- set gamemode
				djui_chat_message_create("Set gamemode to Hot Potato")
				gGlobalSyncTable.gamemode = -1 -- force popup to show
				gGlobalSyncTable.gamemode = HOT_POTATO

				-- default hot potato timer
				if gGlobalSyncTable.amountOfTime == (180 * 30) or gGlobalSyncTable.amountOfTime == 120 * 30 then
					gGlobalSyncTable.amountOfTime = 60 * 30
				end

				-- set players needed
				PLAYERS_NEEDED = 3

				-- disable random gamemode
				gGlobalSyncTable.randomGamemode = false

				-- restart round
				gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS

				return true
			else
				djui_chat_message_create("Gamemode is already set to Hot Potato")

				return true
			end
		elseif msg:lower() == "random" then
			if not gGlobalSyncTable.randomGamemode then
				-- enable random gamemode
				djui_chat_message_create("Gamemodes are now selected at random")
				gGlobalSyncTable.randomGamemode = true

				-- restart round
				gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS

				return true
			else
				djui_chat_message_create("Gamemodes are already selected at random")

				return true
			end
		end
	end

	if gGlobalSyncTable.randomGamemode then
		djui_chat_message_create("Gamemode is set to random, current gamemode is " .. get_gamemode())
	else
		djui_chat_message_create(get_gamemode())
	end

	return true
end

function on_modifier_command(msg)

	if not network_is_server() then
		if gGlobalSyncTable.doModifiers then
			show_modifiers()
		else
			djui_chat_message_create("Modifiers are disabled")
		end

		return true
	end

	if (msg == "yes" or msg == "on" or msg == "enable") then
		djui_chat_message_create("Modifiers are now enabled")
		gGlobalSyncTable.doModifiers = true
	elseif (msg == "no" or msg == "off" or msg == "disable") then
		djui_chat_message_create("Modifiers are now disabled")
		gGlobalSyncTable.doModifiers = false
	end

	if msg:lower() == "bombs" then
		gGlobalSyncTable.modifier = -1
		gGlobalSyncTable.modifier = MODIFIER_BOMBS
	elseif msg:lower() == "low gravity" then
		gGlobalSyncTable.modifier = -1
		gGlobalSyncTable.modifier = MODIFIER_LOW_GRAVITY
	elseif msg:lower() == "swap" then
		gGlobalSyncTable.modifier = -1
		gGlobalSyncTable.modifier = MODIFIER_SWAP
	elseif msg:lower() == "no radar" then
		gGlobalSyncTable.modifier = -1
		gGlobalSyncTable.modifier = MODIFIER_NO_RADAR
	elseif msg:lower() == "no boost" then
		gGlobalSyncTable.modifier = -1
		gGlobalSyncTable.modifier = MODIFIER_NO_BOOST
	elseif msg:lower() == "one tagger" then
		gGlobalSyncTable.modifier = -1
		gGlobalSyncTable.modifier = MODIFIER_ONE_TAGGER
	elseif msg:lower() == "fly" then
		gGlobalSyncTable.modifier = -1
		gGlobalSyncTable.modifier = MODIFIER_FLY
	elseif msg:lower() == "speed" then
		gGlobalSyncTable.modifier = -1
		gGlobalSyncTable.modifier = MODIFIER_SPEED
	elseif msg:lower() == "none" then
		gGlobalSyncTable.modifier = -1
		gGlobalSyncTable.modifier = MODIFIER_NONE
	else
		if gGlobalSyncTable.doModifiers then
			show_modifiers()
		else
			djui_chat_message_create("Modifiers are disabled")
		end
	end

	return true
end

function water_command(msg)
	if msg == "yes" or msg == "on" or msg == "enable" then
		djui_chat_message_create("Water is now enabled")
		gGlobalSyncTable.water = true
		return true
	elseif msg == "no" or msg == "off" or msg == "disable" then
		djui_chat_message_create("Water is now disabled")
		gGlobalSyncTable.water = false
		return true
	else
		if gGlobalSyncTable.water then
			djui_chat_message_create("Water is enabled")
		else
			djui_chat_message_create("Water is disabled")
		end
	end

	return true
end

function spectator_command(msg)
	if msg == "yes" or msg == "on" or msg == "enable" then
		djui_chat_message_create("You are now a spectator")
		gPlayerSyncTable[0].state = SPECTATOR
		return true
	elseif (msg == "no" or msg == "off" or msg == "disable") and gGlobalSyncTable.roundState ~= ROUND_ACTIVE then
		djui_chat_message_create("You are no longer a spectator")
		gPlayerSyncTable[0].state = RUNNER
		return true
	elseif msg == "no" or msg == "off" or msg == "disable" then
		djui_chat_message_create("You must wait for the game to end to no longer be a spectator")
	else
		if gPlayerSyncTable[0].state == SPECTATOR then
			djui_chat_message_create("You are a spectator")
		else
			djui_chat_message_create("You are not a spectator")
		end
	end

	return true
end

function freeze_health_drain_command(msg)
	if tonumber(msg) ~= nil then
		local number = tonumber(msg)

		if number <= 0 then
			djui_chat_message_create("Please type a number greater than 0")
		else
			gGlobalSyncTable.freezeHealthDrain = number
			djui_chat_message_create("Set health drain when frozen to " .. msg)
		end
	else
		djui_chat_message_create("Current health drain when frozen is " .. tostring(gGlobalSyncTable.freezeHealthDrain))
	end

	return true
end

if network_is_server() or network_is_moderator() then
	hook_chat_command("start", "[name|index] Starts round in a random or specific level", start_command)
	hook_chat_command("do-caps", "[yes|no] Enable or disable caps, default: \\#FF0000\\off", do_caps_command)
	hook_chat_command("cannons", "[on|off]Enable or disable cannons", cannons_command)
	hook_chat_command("time", "[number] Amount of time per round in seconds, default: 120s", on_time_command)
	hook_chat_command("anticamp", "Anti Camp Settings", anti_camp_command)
	hook_chat_command("bljs", "[on|off] Enable or disable bljs, default: \\#FF0000\\off", bljs_command)
	hook_chat_command("blacklist", "Blacklist a course or level", blacklist_course_command)
	hook_chat_command("water", "[on|off] Enable or disable water", water_command)
	hook_chat_command("freeze-health-drain", "[number] Set or get frozen health drain", freeze_health_drain_command)
end

hook_chat_command("tp", "[name|index] Teleports to a player if your eliminated, only works in the tag gamemode", on_tp_command)
hook_chat_command("gamemode", "[tag|freeze tag|infection|hot potato|random] Get or set gamemode to freeze tag or tag", on_gamemode_command)
hook_chat_command("modifiers", "[on|off ] Get current modifier or enable or disable modifiers", on_modifier_command)
hook_chat_command("spectate", "[on|off] Be a spectator", spectator_command)
hook_chat_command("version", "Get current version of \\#316BE8\\Tag", on_version_command)