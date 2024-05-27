
---@param text string
---@param input integer|number
---@param minInput integer|number
---@param maxInput integer|number
function render_bar(text, input, minInput, maxInput)
    local screenWidth  = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local scale = 1
    local width = 128 * scale
    local height = 16 * scale
    local x = math.floor((screenWidth - width) / 2)
    local y = math.floor(screenHeight - height - 4 * scale)
    local barFillValue = linear_interpolation(input, 0, 1, minInput, maxInput)

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x, y, width, height)

    x = x + 2 * scale
    y = y + 2 * scale
    width = width - 4 * scale
    height = height - 4 * scale
    width = math.floor(width * barFillValue)
    djui_hud_set_color(66, 176, 245, 128)
    djui_hud_render_rect(x, y, width, height)

    scale = 0.25
    width = djui_hud_measure_text(text) * scale
    height = 32 * scale
    x = (screenWidth - width) / 2
    y = screenHeight - 28

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - 6, y, width + 12, height)

    djui_hud_set_color(66, 176, 245, 128)
    djui_hud_print_text(text, x, y, scale)
end
