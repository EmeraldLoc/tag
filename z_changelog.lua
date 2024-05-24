
-- TODO: kind of rushed, should come back and improve this. Does the job for now

changelogs = {
    ["v2.4"] = {
        title = "\\#316BE8\\Tag v2.4: Major Update",
        gamemodes = {
            "Added " .. get_gamemode(ODDBALL),
            "Revamped " .. get_gamemode(JUGGERNAUT),
        },
        modifiers = {
            "Added " .. get_modifier_text(MODIFIER_HARD_SURFACE),
            "Added " .. get_modifier_text(MODIFIER_SAND),
            "Readded " .. get_modifier_text(MODIFIER_SWAP),
            "Added " .. get_modifier_text(MODIFIER_BUTTON_CHALLENGE),
            "Added " .. get_modifier_text(MODIFIER_ONLY_FIRSTIES),
        },
        romhacks = {
            "Added Lug's Delightful Dioramas (jzzle and TheMan)",
            "Added Super Mario Rainbow Road (Murioz)",
        },
        levels = {
            "Added Bowser's Sub",
            "Added Dorrie's Domain",
            "Added Bowser 3",
            "Added Vanish Cap Under the Moat",
            "Added Big Boo's Haunt",
        },
        newFeatures = {
            "Added achievements, and rewards. Rewards includes titles and trails",
            "Added a Tournament system (more information in the help menu)",
            "Reorganized settings for the 1000th time",
            "Save gamemode settings",
            "Save modifier settings",
            "Save blacklist settings",
        }
    }
}

showingChangelog = false
selectedChangelog = versions[1]

local firstLaunch = load_bool("firstLaunch")
local changelogVer = load_string("changelogVer")
local bgWidth = djui_hud_get_screen_width() - 400
local bgHeight = djui_hud_get_screen_height() - 30

---@param m MarioState
local function mario_update(m)
    if firstLaunch == nil then firstLaunch = true end
    if firstLaunch then return end
    if m.playerIndex ~= 0 then return end

    if changelogVer ~= versions[1] then
        showingChangelog = true
    end

    if showingChangelog and m.controller.buttonPressed & Y_BUTTON ~= 0 then
        if changelogVer ~= versions[1] then
            changelogVer = versions[1]
            save_string("changelogVer", changelogVer)
        end
        showingChangelog = false
    end
end

local function on_render()
    if firstLaunch == nil then firstLaunch = true end
    if firstLaunch then return end
    if not showingChangelog then return end

    local x = (djui_hud_get_screen_width() / 2) - (bgWidth / 2)
    local y = djui_hud_get_screen_height() - bgHeight
    djui_hud_set_color(20, 20, 22, 250)
    djui_hud_render_rect_rounded_outlined(x, y / 2, bgWidth, bgHeight, 45, 45, 47, 10)

    local changelog = changelogs[selectedChangelog]
    local text = ""
    if changelog == nil then
        text = "No changelog is avaliable for this version"
    else
        text = changelog.title
    end
    -- render title
    x = (djui_hud_get_screen_width() / 2) - (bgWidth / 2)
    y = (djui_hud_get_screen_height() - bgHeight) / 2

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_colored_text(text, x + ((bgWidth / 2) - djui_hud_measure_text(strip_hex(text))), y + 50, 2)

    if changelog == nil then return end

    -- render gamemode header
    y = y + 60
    text = "Gamemodes"
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_colored_text(text, x + 10, y + 50, 1.1)
    y = y + 15

    for _, s in ipairs(changelog.gamemodes) do
        text = "- " .. s
        local wrappedText = wrap_text(text, bgWidth / 4)

        for _, wS in ipairs(wrappedText) do
            y = y + 30

            djui_hud_set_color(220, 220, 220, 255)
            djui_hud_print_colored_text(wS, x + 10, y + 50, 1)
        end
    end

    -- render modifier header
    x = x + bgWidth / 4
    y = (djui_hud_get_screen_height() - bgHeight) / 2 + 60
    text = "Modifiers"
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_colored_text(text, x + 0, y + 50, 1.1)
    y = y + 15

    for _, s in ipairs(changelog.modifiers) do
        text = "- " .. s
        local wrappedText = wrap_text(text, bgWidth / 4)

        for _, wS in ipairs(wrappedText) do
            y = y + 30

            djui_hud_set_color(220, 220, 220, 255)
            djui_hud_print_colored_text(wS, x + 0, y + 50, 1)
        end
    end

    -- render levels header
    x = x + bgWidth / 4
    y = (djui_hud_get_screen_height() - bgHeight) / 2 + 60
    text = "Levels"
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_colored_text(text, x + 0, y + 50, 1.1)
    y = y + 15

    for _, s in ipairs(changelog.levels) do
        text = "- " .. s
        local wrappedText = wrap_text(text, bgWidth / 4)

        for _, wS in ipairs(wrappedText) do
            y = y + 30

            djui_hud_set_color(220, 220, 220, 255)
            djui_hud_print_colored_text(wS, x + 0, y + 50, 1)
        end
    end

    -- render new features
    x = x + bgWidth / 4
    y = (djui_hud_get_screen_height() - bgHeight) / 2 + 60
    text = "New Features"
    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_colored_text(text, x - 10, y + 50, 1.1)
    y = y + 15

    for _, s in ipairs(changelog.newFeatures) do
        text = "- " .. s
        local wrappedText = wrap_text(text, bgWidth / 4)

        for _, wS in ipairs(wrappedText) do
            y = y + 30

            djui_hud_set_color(220, 220, 220, 255)
            djui_hud_print_colored_text(wS, x - 10, y + 50, 1)
        end
    end

    -- render complete text
    text = "Press Y to dismiss"
    -- render title
    x = (djui_hud_get_screen_width() / 2) - (bgWidth / 2)
    y = bgHeight

    djui_hud_set_color(220, 220, 220, 255)
    djui_hud_print_colored_text(text, x + ((bgWidth / 2) - djui_hud_measure_text(strip_hex(text))), y - 50, 2)
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_render)