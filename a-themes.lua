
---@param r integer|number
---@param g integer|number
---@param b integer|number
local function color(r, g, b)
    return { r = r, g = g, b = b }
end

tagThemes = {
    {
        name = "Modern Dark",
        background = color(20, 20, 22),
        backgroundOutline = color(45, 45, 47),
        rect = color(32, 32, 32),
        rectOutline = color(50, 50, 50),
        hoverRect = color(40, 40, 40),
        hoverRectOutline = color(60, 60, 60),
        confirmedRect = color(83, 153, 77),
        confirmedRectOutline = color(113, 183, 107),
        text = color(220, 220, 220),
        selectedText = color(240, 240, 240),
        disabledText = color(150, 150, 150),
        builtin = true,
    },
    {
        name = "Modern Light",
        background = color(230, 230, 230),
        backgroundOutline = color(195, 195, 195),
        rect = color(195, 195, 195),
        rectOutline = color(220, 220, 220),
        hoverRect = color(210, 210, 210),
        hoverRectOutline = color(225, 225, 225),
        confirmedRect = color(98, 168, 92),
        confirmedRectOutline = color(128, 198, 122),
        text = color(10, 10, 10),
        selectedText = color(0, 0, 0),
        disabledText = color(20, 20, 20),
        builtin = true,
    },
    {
        name = "Midnight",
        background = color(0, 0, 0),
        backgroundOutline = color(30, 30, 30),
        rect = color(20, 20, 20),
        rectOutline = color(30, 30, 30),
        hoverRect = color(30, 30, 30),
        hoverRectOutline = color(40, 40, 40),
        confirmedRect = color(83, 153, 77),
        confirmedRectOutline = color(113, 183, 107),
        text = color(170, 170, 170),
        selectedText = color(200, 200, 200),
        disabledText = color(100, 100, 100),
        builtin = true,
    },
}

function save_theme(themeIndex)
    local function rgb_to_str(rgb)
        return rgb.r .. "_" .. rgb.g .. "_" .. rgb.b .. "_"
    end

    local theme = tagThemes[themeIndex]
    local saveString = ""
    saveString = saveString .. rgb_to_str(theme.background)
    saveString = saveString .. rgb_to_str(theme.backgroundOutline)
    saveString = saveString .. rgb_to_str(theme.rect)
    saveString = saveString .. rgb_to_str(theme.rectOutline)
    saveString = saveString .. rgb_to_str(theme.hoverRect)
    saveString = saveString .. rgb_to_str(theme.hoverRectOutline)
    saveString = saveString .. rgb_to_str(theme.confirmedRect)
    saveString = saveString .. rgb_to_str(theme.confirmedRectOutline)
    saveString = saveString .. rgb_to_str(theme.text)
    saveString = saveString .. rgb_to_str(theme.selectedText)
    saveString = saveString .. rgb_to_str(theme.disabledText)
    saveString = saveString .. theme.name:gsub(" ", "-") .. "_"

    -- get amount of builtin themes
    local builtinThemes = 0
    for _, v in ipairs(tagThemes) do
        if v.builtin then
            builtinThemes = builtinThemes + 1
        end
    end

    save_string("theme_" .. themeIndex - builtinThemes, saveString)
end

function load_theme(themeIndex)
    local function str_to_rgb(str)
        local r, g, b = str:match("(%d+)_(%d+)_(%d+)")
        return color(tonumber(r), tonumber(g), tonumber(b))
    end

    local savedTheme = load_string("theme_" .. themeIndex)
    if savedTheme == nil or savedTheme == "" then return end
    local builtinThemes = 0
    for _, v in ipairs(tagThemes) do
        if v.builtin then
            builtinThemes = builtinThemes + 1
        end
    end
    tagThemes[themeIndex + builtinThemes] = {}
    local theme = tagThemes[themeIndex + builtinThemes]
    local colorStrings = {}

    local function get_three_from_1(i)
        return colorStrings[i] .. "_" .. colorStrings[i + 1] .. "_" .. colorStrings[i + 2]
    end

    for c in savedTheme:gmatch("([^%_]+)%_") do
        table.insert(colorStrings, c)
    end

    theme.name = table.remove(colorStrings):gsub("-", " ")
    theme.background = str_to_rgb(get_three_from_1(1))
    theme.backgroundOutline = str_to_rgb(get_three_from_1(4))
    theme.rect = str_to_rgb(get_three_from_1(7))
    theme.rectOutline = str_to_rgb(get_three_from_1(10))
    theme.hoverRect = str_to_rgb(get_three_from_1(13))
    theme.hoverRectOutline = str_to_rgb(get_three_from_1(16))
    theme.confirmedRect = str_to_rgb(get_three_from_1(19))
    theme.confirmedRectOutline = str_to_rgb(get_three_from_1(22))
    theme.text = str_to_rgb(get_three_from_1(25))
    theme.selectedText = str_to_rgb(get_three_from_1(28))
    theme.disabledText = str_to_rgb(get_three_from_1(31))
    theme.builtin = false
end

local function validate_theme()
    if tagThemes[selectedTheme] == nil then
        if load_int("theme") ~= nil then selectedTheme = load_int("theme") end
        if tagThemes[selectedTheme] == nil then
            selectedTheme = 1
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, validate_theme)