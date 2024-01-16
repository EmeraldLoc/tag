
---@diagnostic disable: param-type-mismatch

---@param msg string
function start_command(msg)

	if network_player_connected_count() < PLAYERS_NEEDED then
		djui_chat_message_create("Not enough players to start the round")

		return true
	end

	if msg ~= "" then
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
					if msg:lower() == get_level_name(i, course_to_level(i), 1):lower() and (not level_is_vanilla_level(gGlobalSyncTable.selectedLevel) and level_to_course(gGlobalSyncTable.selectedLevel) < COURSE_RR and level_to_course(gGlobalSyncTable.selectedLevel) > COURSE_MIN - 1) then
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
	end

	gGlobalSyncTable.roundState = ROUND_WAIT_PLAYERS

	djui_chat_message_create("Starting round")

	return true

end

---@param msg string
function on_tp_command(msg)
	if (gPlayerSyncTable[0].state ~= ELIMINATED_OR_FROZEN and gPlayerSyncTable[0].state ~= SPECTATOR) or (gGlobalSyncTable.gamemode == FREEZE_TAG and gPlayerSyncTable[0].state ~= SPECTATOR) then
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

function spectator_command(msg)
	if msg == "yes" or msg == "on" or msg == "enable" then
		djui_chat_message_create("You are now a spectator")
		gPlayerSyncTable[0].state = SPECTATOR
		return true
	elseif (msg == "no" or msg == "off" or msg == "disable") and gGlobalSyncTable.roundState ~= ROUND_ACTIVE and gGlobalSyncTable.roundState ~= ROUND_HOT_POTATO_INTERMISSION then
		djui_chat_message_create("You are no longer a spectator")
		gPlayerSyncTable[0].state = RUNNER
		warp_to_level(LEVEL_VCUTM, 1, 0) -- Enter spectator in singleplayer and see what happens >:)
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

function tag_command(msg)
	if blacklistAddRequest then
		if tonumber(msg) ~= nil then
			if isRomhack then
				for i = COURSE_MIN, COURSE_MAX do
					if tonumber(msg) == i then
						if not table.contains(blacklistedCourses, i) then
							table.insert(blacklistedCourses, i)
						else
							djui_chat_message_create("Course " .. get_level_name(i, course_to_level(i), 1) .. " is already blacklisted")
						end

						djui_chat_message_create("Blacklisted " .. get_level_name(i, course_to_level(i), 1))

						blacklistAddRequest = false

						return true
					end
				end
			else
				for i = 1, #levels do
					if tonumber(msg) == level_to_course(levels[i].level) then
						if not table.contains(blacklistedCourses, i) then
							table.insert(blacklistedCourses, i)
						else
							djui_chat_message_create("Course " .. get_level_name(level_to_course(levels[i].level), levels[i].level, 1) .. " is already blacklisted")
						end

						djui_chat_message_create("Blacklisted " .. get_level_name(level_to_course(levels[i].level), levels[i].level, 1))

						blacklistAddRequest = false

						return true
					end
				end
			end

			djui_chat_message_create("Course " .. msg .. " not found")

			blacklistAddRequest = false

			return true
		else
			if isRomhack then
				for i = COURSE_MIN, COURSE_MAX do
					if msg:lower() == get_level_name(i, course_to_level(i), 1):lower() then
						if not table.contains(blacklistedCourses, i) then
							table.insert(blacklistedCourses, i)
						else
							djui_chat_message_create("Course " .. get_level_name(i, course_to_level(i), 1) .. " is already blacklisted")
						end

						djui_chat_message_create("Blacklisted " .. get_level_name(i, course_to_level(i), 1))

						blacklistAddRequest = false

						return true
					end
				end

				djui_chat_message_create("Course " .. msg .. " not found")

				blacklistAddRequest = false

				return true
			else
				for i = 1, #levels do
					if msg:lower() == levels[i].name then
						if not table.contains(blacklistedCourses, i) then
							table.insert(blacklistedCourses, i)
						else
							djui_chat_message_create("Course " .. levels[i].name .. " is already blacklisted")
						end

						djui_chat_message_create("Blacklisted " .. levels[i].name)

						blacklistAddRequest = false

						return true
					end
				end

				djui_chat_message_create("Course " .. msg .. " not found")

				blacklistAddRequest = false

				return true
			end
		end

		blacklistAddRequest = false
	else
		if _G.swearExists then
			if not _G.swearSettingsOpened then
				showSettings = not showSettings
				_G.tagSettingsOpen = showSettings
				play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
			else
				play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
				djui_chat_message_create("Tag: Swear Filter settings menu is already opened!")
			end
		else
			showSettings = not showSettings
			_G.tagSettingsOpen = showSettings
			play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
		end
	end
	return true
end

if network_is_server() then
	hook_chat_command("tag", "View and change tag settings", tag_command)
	hook_chat_command("start", "[name|index] Starts round in a random or specific level", start_command)
else
	hook_chat_command("tag", "View tag settings", tag_command)
end
hook_chat_command("tp", "[name|index] Teleports to a player if your eliminated or spectating", on_tp_command)
hook_chat_command("spectate", "[on|off] Be a spectator", spectator_command)
hook_chat_command("version", "Get current version of Tag", on_version_command)