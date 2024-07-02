
local yOffset = 0

---@param text string
---@param input integer|number
---@param minInput integer|number
---@param maxInput integer|number
---@param r integer
---@param g integer
---@param b integer
function render_bar(text, input, minInput, maxInput, r, g, b)

    djui_hud_set_font(djui_menu_get_font())
    djui_hud_set_resolution(RESOLUTION_N64)

    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local scale = 1
    local width = 128 * scale
    local height = 16 * scale
    local x = math.floor((screenWidth - width) / 2)
    local y = math.floor(screenHeight - height - 4 * scale) - yOffset
    local barFillValue = linear_interpolation(input, 0, 1, minInput, maxInput)

    djui_hud_set_color(20, 20, 22, 255 / 1.4)
    djui_hud_render_rect_rounded(x, y, width, height, 8)

    x = x + 2 * scale
    y = y + 2 * scale
    width = width - 4 * scale
    height = height - 4 * scale
    width = math.floor(width * barFillValue)
    djui_hud_set_color(r, g, b, 128)
    djui_hud_render_rect_rounded(x, y, width, height, 4)

    scale = 0.25
    width = djui_hud_measure_text(text) * scale
    height = 32 * scale
    x = (screenWidth - width) / 2
    y = screenHeight - 28 - yOffset

    djui_hud_set_color(20, 20, 22, 255 / 1.4)
    djui_hud_render_rect_rounded_ignore_bottom(x - 6, y, width + 12, height, 4)

    djui_hud_set_color(r, g, b, 128)
    djui_hud_print_text(text, x, y, scale)

    yOffset = yOffset + 32
end

hook_event(HOOK_ON_HUD_RENDER, function () yOffset = 0 end)
