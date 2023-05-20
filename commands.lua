local version = "v2.0"

function restart()
  -- restart the round by setting round state to waiting for players
  gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS

  djui_chat_message_create("Restarted the round")

  return true
end

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

function on_tp_command(msg)

	if gPlayerSyncTable[0].state ~= ELIMINATED then
		djui_chat_message_create("You must be eliminated to run this command")

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
			if msg == name_without_hex(gNetworkPlayers[i].name) then
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

function on_version_command()
	djui_chat_message_create("Current Tag Version: " .. version)

	return true
end

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
				if string.lower(course) == string.lower(get_level_name(i, course_to_level(i), 1)) then
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
				if string.lower(course) == string.lower(get_level_name(blacklistedLevels[i], course_to_level(blacklistedLevels[i]), 1)) then
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

if network_is_server() or network_is_moderator() then
	hook_chat_command("restart", "Restarts the round", restart)
	hook_chat_command("do-caps", "[yes|no] Enable or disable caps, default: \\#FF0000\\off", do_caps_command)
		hook_chat_command("cannons", "[on|off]Enable or disable cannons", cannons_command)
	hook_chat_command("time", "[number] Amount of time per round in seconds, default: 120s", on_time_command)
	hook_chat_command("anticamp", "Anti Camp Settings", anti_camp_command)
	hook_chat_command("bljs", "[on|off] Enable or disable bljs, default: \\#FF0000\\off", bljs_command)
	hook_chat_command("blacklist", "Blacklist a Course or Level", blacklist_course_command)
end

hook_chat_command("tp", "[name|index] Teleports to a player if your eliminated", on_tp_command)
hook_chat_command("version", "Get Current Version of Tag", on_version_command)