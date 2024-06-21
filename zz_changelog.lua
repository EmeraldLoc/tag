
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
            "Added " .. get_modifier_text(MODIFIER_Z_BUTTON_CHALLENGE),
            "Added " .. get_modifier_text(MODIFIER_ONLY_FIRSTIES),
        },
        romhacks = {
            "Added Lug's Delightful Dioramas (jzzle and TheMan)",
            "Added Super Mario Rainbow Road (Murioz)",
            "Added SM64: The Green Stars (Bear)",
            "Improved Star Road",
        },
        levels = {
            "Added Bowser's Sub",
            "Added Dorrie's Domain",
            "Added Boulder's Rush",
            "Added Bowser Sky Domain",
            "Added Vanish Cap Under the Moat",
            "Added Big Boo's Haunt",
            "Added Pipes to Tiny Huge Island",
            "Added Pipes to Whomp's Fortress"
        },
        newFeatures = {
            "Added achievements, and rewards. Rewards includes titles and trails",
            "Added a Tournament system (more information in the help menu)",
            "Added hud themes",
            "Reorganized settings for the 1000th time",
            "Save gamemode settings",
            "Save modifier settings",
            "Save blacklist settings",
        }
    },
    ["v2.32"] = {
        title = "\\#316BE8\\Tag v2.32: Minor Update",
        gamemodes = {
            "Added " .. get_gamemode(TERMINATOR),
        },
        modifiers = {
            "No modifier changes"
        },
        romhacks = {
            "No romhack changes"
        },
        levels = {
            "No level changes"
        },
        newFeatures = {
            "No new features"
        }
    },
    ["v2.31"] = {
        title = "\\#316BE8\\Tag v2.31: Minor Update",
        gamemodes = {
            "No gamemodes added"
        },
        modifiers = {
            "Added " .. get_modifier_text(MODIFIER_FRIENDLY_FIRE)
        },
        romhacks = {
            "No romhack changes"
        },
        levels = {
            "No level changes"
        },
        newFeatures = {
            "Added dust particles to double jump",
            "Allow sardines to see other sardines",
            "Fixed sardine constantly playing a stomping sound"
        }
    },
    ["v2.3"] = {
        title = "\\#316BE8\\Tag v2.3: Major Update",
        gamemodes = {
            "Added " .. get_gamemode(SARDINES),
            "Added " .. get_gamemode(HUNT),
            "Added " .. get_gamemode(DEATHMATCH),
        },
        modifiers = {
            "Readded " .. get_modifier_text(MODIFIER_FLY),
            "Added " .. get_modifier_text(MODIFIER_BLASTER),
            "Added " .. get_modifier_text(MODIFIER_DOUBLE_JUMP),
            "Added " .. get_modifier_text(MODIFIER_SHELL),
            "Added " .. get_modifier_text(MODIFIER_BLJS),
            "Added " .. get_modifier_text(MODIFIER_ONE_RUNNER),
            "Heavily improve " .. get_modifier_text(MODIFIER_FOG) .. " \\#dcdcdc\\(\\#F2F3AE\\B\\#EDD382\\l\\#FC9E4F\\o\\#F4442E\\c\\#9B1D20\\ky\\#dcdcdc\\)",
        },
        romhacks = {
            "Added Star Road (Murioz)",
            "Added Super Mario 74 (Murioz)",
            "Added SM64 Sapphire",
            "Added Royal Legacy",
            "Added SM64 Trouble Town",
        },
        levels = {
            "Added Wet-dry Town",
            "Added Red's in HMC Town",
            "Added Toxic Maze Town",
        },
        newFeatures = {
            "Add Stats",
            "Added Auto Hide Hud",
            "Redesigned center ui",
            "Allowed gamemodes and modifiers to be blacklisted",
            "Hud Redesign",
            "Added level api",
            "Added support for arena stages",
            "Make hazards toggleable",
            "Remove join screen",
            "Revamp bomb physics",
            "Use saves instead of time as runner in Freeze Tag",
        }
    },
    ["v2.21"] = {
        title = "\\#316BE8\\Tag v2.21: Minor Update",
        gamemodes = {
            "No gamemode changes"
        },
        modifiers = {
            "No modifier changes"
        },
        romhacks = {
            "No romhack changes"
        },
        levels = {
            "No level changes"
        },
        newFeatures = {
            "Added Binds",
            "Fixed clients not being able to see server settings",
        }
    },
    ["v2.2"] = {
        title = "\\#316BE8\\Tag v2.2: Major Update",
        gamemodes = {
            "No gamemode changes"
        },
        modifiers = {
            "Added " .. get_modifier_text(MODIFIER_HIGH_GRAVITY),
            "Added " .. get_modifier_text(MODIFIER_FOG),
            "Improved " .. get_modifier_text(MODIFIER_INCOGNITO),
            "Removed " .. get_modifier_text(MODIFIER_FLY),
        },
        romhacks = {
            "No romhack changes"
        },
        levels = {
            "Added Wet-Dry World",
            "Added Inside of Tiny Huge Island (now known as Wiggler's Cave)",
        },
        newFeatures = {
            "Added a new voting system",
            "Added a custom pause menu",
            "Added positions to the leaderboard",
            "Added gamemode time limit customizations",
            "Added elimination on death option",
            "Added help menu to settings",
            "Added blacklists to vanilla sm64",
            "Added non-auto mode",
        }
    },
    ["v2.1"] = {
        title = "\\#316BE8\\Tag v2.1: Major Update",
        gamemodes = {
            "Added " .. get_gamemode(JUGGERNAUT),
            "Added " .. get_gamemode(ASSASSINS),
        },
        modifiers = {
            "Added " .. get_modifier_text(MODIFIER_INCOGNITO),
            "Improved " .. get_modifier_text(MODIFIER_FLY),
        },
        romhacks = {
            "No romhack changes"
        },
        levels = {
            "No level changes"
        },
        newFeatures = {
            "Added icon next to leaderboard",
            "Added update notifier",
        }
    }
}

showingChangelog = false
selectedChangelog = versions[1]

local firstLaunch = load_bool("firstLaunch")
local changelogVer = load_string("changelogVer")
local bgWidth = djui_hud_get_screen_width() - 400
local bgHeight = djui_hud_get_screen_height() - 30
local scrollOffset = 0
local joystickCooldown = 0
local scrollOffsetClamp = 0

---@param m MarioState
local function mario_update(m)
    if firstLaunch == nil then firstLaunch = true end
    if firstLaunch then return end
    if m.playerIndex ~= 0 then return end
    if not isPaused then showingChangelog = false end

    if changelogVer ~= versions[1] then
        showingChangelog = true
    end

    if showingChangelog then
        if m.controller.buttonPressed & Y_BUTTON ~= 0 then
            if changelogVer ~= versions[1] then
                changelogVer = versions[1]
                save_string("changelogVer", changelogVer)
            end
            showingChangelog = false
        end

        joystickCooldown = joystickCooldown - 1

        if (m.controller.stickY > 0.5 and joystickCooldown <= 0)
        or m.controller.buttonPressed & U_JPAD ~= 0 then
            scrollOffset = scrollOffset + 30
            joystickCooldown = 0.2 * 30
        end

        if (m.controller.stickY < -0.5 and joystickCooldown <= 0)
        or m.controller.buttonPressed & D_JPAD ~= 0 then
            scrollOffset = scrollOffset - 30
            joystickCooldown = 0.2 * 30
        end
        -- clamp
        scrollOffset = clamp(scrollOffset, scrollOffsetClamp, 0)
    else
        scrollOffset = 0
    end
end

local function is_within_view(y)
    if y + 50 + scrollOffset > bgHeight - 110 then return false end
    if y + 50 + scrollOffset < 120 then return false end
    return true
end

local function hud_render()
    if firstLaunch == nil then firstLaunch = true end
    if firstLaunch then return end
    if not showingChangelog then return end

    local theme = get_selected_theme()

    local x = (djui_hud_get_screen_width() / 2) - (bgWidth / 2)
    local y = djui_hud_get_screen_height() - bgHeight
    djui_hud_set_color(theme.background.r, theme.background.g, theme.background.b, 250)
    djui_hud_render_rect_rounded_outlined(x, y / 2, bgWidth, bgHeight, theme.backgroundOutline.r, theme.backgroundOutline.g, theme.backgroundOutline.b, 10, 250)

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

    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
    djui_hud_print_colored_text(text, x + ((bgWidth / 2) - djui_hud_measure_text(strip_hex(text))), y + 50, 2)

    if changelog == nil then return end

    -- render gamemode header
    x = x + 10
    y = y + 60
    if not is_within_view(y) then goto endgamemodeheader end
    text = "Gamemodes"
    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
    djui_hud_print_colored_text(text, x, y + 50 + scrollOffset, 1.1)
    ::endgamemodeheader::
    y = y + 15

    for _, s in ipairs(changelog.gamemodes) do
        text = "- " .. s
        local wrappedText = wrap_text(text, bgWidth - 30)

        for _, wS in ipairs(wrappedText) do
            y = y + 30
            if not is_within_view(y) then goto continue end

            djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
            djui_hud_print_colored_text(wS, x, y + 50 + scrollOffset, 1)
            ::continue::
        end
    end

    -- render modifier header
    y = y + 45
    if not is_within_view(y) then goto endmodifierheader end
    text = "Modifiers"
    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
    djui_hud_print_colored_text(text, x, y + 50 + scrollOffset, 1.1)
    ::endmodifierheader::
    y = y + 15

    for _, s in ipairs(changelog.modifiers) do
        text = "- " .. s
        local wrappedText = wrap_text(text, bgWidth - 30)

        for _, wS in ipairs(wrappedText) do
            y = y + 30
            if not is_within_view(y) then goto continue end

            djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
            djui_hud_print_colored_text(wS, x, y + 50 + scrollOffset, 1)
            ::continue::
        end
    end

    -- render romhack header
    y = y + 45
    if not is_within_view(y) then goto endromhackheader end
    text = "Romhacks"
    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
    djui_hud_print_colored_text(text, x, y + 50 + scrollOffset, 1.1)
    ::endromhackheader::
    y = y + 15

    for _, s in ipairs(changelog.romhacks) do
        text = "- " .. s
        local wrappedText = wrap_text(text, bgWidth - 30)

        for _, wS in ipairs(wrappedText) do
            y = y + 30
            if not is_within_view(y) then goto continue end

            djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
            djui_hud_print_colored_text(wS, x, y + 50 + scrollOffset, 1)
            ::continue::
        end
    end

    -- render levels header
    y = y + 45
    if not is_within_view(y) then goto endlevelsheader end
    text = "Levels"
    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
    djui_hud_print_colored_text(text, x, y + 50 + scrollOffset, 1.1)
    ::endlevelsheader::
    y = y + 15

    for _, s in ipairs(changelog.levels) do
        text = "- " .. s
        local wrappedText = wrap_text(text, bgWidth - 30)

        for _, wS in ipairs(wrappedText) do
            y = y + 30
            if not is_within_view(y) then goto continue end

            djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
            djui_hud_print_colored_text(wS, x, y + 50 + scrollOffset, 1)
            ::continue::
        end
    end

    -- render new features
    y = y + 45
    if not is_within_view(y) then goto endnewfeaturesheader end
    text = "New Features"
    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
    djui_hud_print_colored_text(text, x, y + 50 + scrollOffset, 1.1)
    ::endnewfeaturesheader::
    y = y + 15

    for _, s in ipairs(changelog.newFeatures) do
        text = "- " .. s
        local wrappedText = wrap_text(text, bgWidth - 30)

        for _, wS in ipairs(wrappedText) do
            y = y + 30
            if not is_within_view(y) then goto continue end

            djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
            djui_hud_print_colored_text(wS, x, y + 50 + scrollOffset, 1)
            ::continue::
        end
    end

    -- render scrollbar based off of current y pos and scrollOffset
    x = (djui_hud_get_screen_width() / 2) + (bgWidth / 2 - 8) - 4
    local scrollY = djui_hud_get_screen_height() / 2 - bgHeight / 2 + 6
    -- set height to the max amount you can scroll
    local height = bgHeight
    height = height - clamp(y + 50 - (bgHeight - 110), 0, y + 50 - (bgHeight - 110)) - 16
    -- increment y counter
    scrollY = scrollY - scrollOffset
    -- set scroll offset clamp
    scrollOffsetClamp = -clamp(y + 50 - (bgHeight - 110), 0, y + 50 - (bgHeight - 110))

    djui_hud_set_color(theme.backgroundOutline.r, theme.backgroundOutline.g, theme.backgroundOutline.b, 250)
    djui_hud_render_rect_rounded(x, scrollY, 8, height, 8)

    -- render complete text
    text = "Press Y to dismiss"
    -- render title
    x = (djui_hud_get_screen_width() / 2) - (bgWidth / 2)
    y = bgHeight

    djui_hud_set_color(theme.text.r, theme.text.g, theme.text.b, 255)
    djui_hud_print_colored_text(text, x + ((bgWidth / 2) - djui_hud_measure_text(strip_hex(text))), y - 50, 2)
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)