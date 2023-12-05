-- based on arena, code taken from MarioHunt, texture by EmeraldLockdown

TEX_RAD = get_texture_info('runner-mark')
icon_radar = {}
for i=0,(MAX_PLAYERS-1) do
  icon_radar[i] = {tex = TEX_RAD, prevX = 0, prevY = 0}
end

---@param m any
---@param isObj boolean
function render_radar(m, hudIcon, isObj)
	if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end
	djui_hud_set_resolution(RESOLUTION_N64)
	local pos = {}
	if not isObj then
		pos = { x = m.pos.x, y = m.pos.y + 80, z = m.pos.z } -- mario is 161 units tall
	else
		pos = { x = m.oPosX, y = m.oPosY, z = m.oPosZ }
	end
	local out = { x = 0, y = 0, z = 0 }
	djui_hud_world_pos_to_screen_pos(pos, out)

	if out.z > -260 then
		return
	end

	local alpha = clamp(vec3f_dist(pos, gMarioStates[0].pos), 0, 1200) - 1000
	if alpha <= 0 then
		return
	end

	local dX = out.x - 10
	local dY = out.y - 10

	local r,g,b = 0,0,0
	if not isObj then
		local np = gNetworkPlayers[m.playerIndex]
		local playercolor = network_get_player_text_color_string(np.localIndex)
		r,g,b = convert_color(playercolor)
	else
		r = pos.x % 255 + 1
		g = pos.y % 255 + 1
		b = pos.z % 255 + 1
	end


	local screenWidth = djui_hud_get_screen_width()
	local screenHeight = djui_hud_get_screen_height()
	if dX > (screenWidth - 20) then
		dX = (screenWidth - 20)
	elseif dX < 0 then
		dX = 0
	end
	if dY > (screenHeight - 20) then
		dY = (screenHeight - 20)
	elseif dY < 0 then
		dY = 0
	end

	djui_hud_set_color(r, g, b, alpha)
	djui_hud_render_texture_interpolated(hudIcon.tex, hudIcon.prevX, hudIcon.prevY, 0.6, 0.6, dX, dY, 0.6, 0.6)

	hudIcon.prevX = dX
	hudIcon.prevY = dY
end

function convert_color(text)
	text = text:sub(3,-2)
	local rstring = text:sub(1,2) or "ff"
	local gstring = text:sub(3,4) or "ff"
	local bstring = text:sub(5,6) or "ff"
	local r = 0
	local g = 0
	local b = 0
	for i=1,rstring:len() do
		local char = rstring:sub(i,i)
		local value = tonumber(char)
		if value == nil then
		value = char:byte() - 87
		end
		if i == 1 then
		r = r + value * 16
		else
		r = r + value
		end
	end
	for i=1,gstring:len() do
		local char = gstring:sub(i,i)
		local value = tonumber(char)
		if value == nil then
		value = char:byte() - 87
		end
		if i == 1 then
		g = g + value * 16
		else
		g = g + value
		end
	end
	for i=1,bstring:len() do
		local char = bstring:sub(i,i)
		local value = tonumber(char)
		if value == nil then
		value = char:byte() - 87
		end
		if i == 1 then
		b = b + value * 16
		else
		b = b + value
		end
	end
	return r,g,b
end