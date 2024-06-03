
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
    },
}

customThemes = {}