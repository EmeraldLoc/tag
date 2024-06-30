-- based on arena, code taken from MarioHunt by EmilyEmmi (thanks), texture by EmeraldLockdown

TEX_RAD = get_texture_info('runner-mark')
icon_radar = {}
for i = 0, MAX_PLAYERS - 1 do
  	icon_radar[i] = { tex = TEX_RAD, prevX = 0, prevY = 0 }
end

---@param m any
---@param isObj boolean
function render_radar(m, hudIcon, isObj)
	if gGlobalSyncTable.roundState ~= ROUND_ACTIVE then return end

	djui_hud_set_resolution(RESOLUTION_N64)
	local pos = {}
    -- isObj is technically unused, however if it ever exists, it's here
	if not isObj then
        -- set pos to mario's pos
		pos = { x = m.pos.x, y = m.pos.y + 80, z = m.pos.z } -- mario is 161 units tall
	else
        -- set pos to objects pos
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
		r, g, b = hex_to_rgb(network_get_player_text_color_string(m.playerIndex))
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
	if dY > screenHeight - 20 then
        dY = screenHeight - 20
	elseif dY < 0 then
		dY = 0
	end

	djui_hud_set_color(r, g, b, alpha)

	djui_hud_render_texture_interpolated(hudIcon.tex, hudIcon.prevX, hudIcon.prevY, 0.6, 0.6, dX, dY, 0.6, 0.6)
	--djui_hud_render_texture(hudIcon.tex, dX, dY, 0.6, 0.6)
	hudIcon.prevX = dX
	hudIcon.prevY = dY
end