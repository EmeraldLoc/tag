
sLastPos = {x = 0, y = 0, z = 0} -- dont make this local so it can be used in other files
sDistanceMoved = 0
sDistanceTimer = 0

---@param table table
---@param element any
function table.contains(table, element)
    for _, value in pairs(table) do
      	if value == element then
        	return true
      	end
    end

	return false
end

-- credit to agent x
function name_without_hex(name)
	local s = ''
	local inSlash = false
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

function check_runner_and_tagger_status()
	-- check if we have the avalible players
	local hasTagger = false
	local hasRunner = false

	for i = 0, MAX_PLAYERS - 1 do
        if gNetworkPlayers[i].connected then
			if gPlayerSyncTable[i].state == RUNNER then
				hasRunner = true
			elseif gPlayerSyncTable[i].state == TAGGER then
				hasTagger = true
			end
		end
	end

	if not hasTagger then
		timer = 5 * 30 -- 5 seconds

		gGlobalSyncTable.roundState = ROUND_RUNNERS_WIN

		return
	end

	if not hasRunner then
		timer = 5 * 30 -- 5 seconds

		gGlobalSyncTable.roundState = ROUND_TAGGERS_WIN

		return
	end
end

---@param course integer
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

	return -1
end

---@param level integer
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

	return -1
end

-- taken from freeze tag, this code was made by djoslin0
function camping_detection(m)

	-- This code only runs if the round is active
	if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end
	-- This code only runs if anti camp is enabled
	if not gGlobalSyncTable.antiCamp then return end
	-- This code only runs for the local player
	if m.playerIndex ~= 0 then return end

    local s = gPlayerSyncTable[0]

    -- Track how far the local player has moved recently
    sDistanceMoved = sDistanceMoved - 0.25 + vec3f_dist(sLastPos, m.pos) * 0.02
    vec3f_copy(sLastPos, m.pos)

    -- Clamp between 0 to 100
    if sDistanceMoved < 0   then sDistanceMoved = 0   end
    if sDistanceMoved > 100 then sDistanceMoved = 100 end

    -- If player hasn't moved enough, start a timer
    if sDistanceMoved < 25 and s.state == RUNNER then
        sDistanceTimer = sDistanceTimer + 1
    end

    -- If the player has moved enough, reset the timer
    if sDistanceMoved > 25 then
        sDistanceTimer = 0
    end

    -- If the player is not a runner, reset the timer
    if s.state ~= RUNNER then
        sDistanceTimer = 0
    end

    -- Inform the player that they need to move, or eliminate them
    if sDistanceTimer > gGlobalSyncTable.antiCampTimer then
        s.state = ELIMINATED
    end

    -- Make sound
    if sDistanceTimer > 0 and sDistanceTimer % 30 == 1 then
        play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
    end
end