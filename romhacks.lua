
local initializedRomhacks = false

romhacks = {
    -- don't edit these
    {
        -- name of the hack
        name = "Vanilla",
        shortName = "vanilla",
        water = false,
        -- level data
        levels = {
            -- name is the abbreviated level name, level is the level, painting is the image file, act is the act, area is the area, pipe stuff is for pipe positions
            { name = "cg",       level = LEVEL_CASTLE_GROUNDS, painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = -5979, y = 378, z = -1371 },  { x = 1043, y = 3174, z = -5546 } } } },
            { name = "bob",      level = LEVEL_BOB,            painting = get_texture_info("bob_painting"),   area = 1, pipes = { { { x = -4694, y = 0, z = 6699 },     { x = 5079, y = 3072, z = 655 } } } },
            { name = "rr",       level = LEVEL_RR,             painting = get_texture_info("rr_painting"),    area = 1, pipes = { { { x = -4221, y = 6451, z = -5885 }, { x = 2125, y = -1833, z = 2079 } } } },
            { name = "ccm",      level = LEVEL_CCM,            painting = get_texture_info("ccm_painting"),   area = 1, pipes = { { { x = -1352, y = 2560, z = -1824 }, { x = 5628, y = -4607, z = -28 } } } },
            { name = "itp",      level = LEVEL_SSL,            painting = get_texture_info("itp_painting"),   area = 2, pipes = { { { x = -460, y = 0, z = 4247 },      { x = 997, y = 3942, z = 1234 } } }, overrideName = "Inside The Pyramid"},
            { name = "bitfs",    level = LEVEL_BITFS,          painting = get_texture_info("bitfs_painting"), area = 1, pipes = { { { x = -154, y = -2866, z = -102 },  { x = 1205, y = 5478, z = 58 } } } },
            { name = "ttm",      level = LEVEL_TTM,            painting = get_texture_info("ttm_painting"),   area = 1, pipes = { { { x = -1080, y = -4634, z = 4176 }, { x = 1031, y = 2306, z = -198 } } } },
            { name = "ttc",      level = LEVEL_TTC,            painting = get_texture_info("ttc_painting"),   area = 1, pipes = { { { x = 1361, y = -4822, z = 176 },   { x = 1594, y = 5284, z = 1565 } } } },
            { name = "jrb",      level = LEVEL_JRB,            painting = get_texture_info("jrb_painting"),   area = 1, pipes = { { { x = 3000, y = -5119, z = 2688 },  { x = -6398, y = 1126, z = 191 } } } },
            { name = "wdw",      level = LEVEL_WDW,            painting = get_texture_info("wdw_painting"),   area = 1, pipes = { { { x = 3346, y = 154, z = 2918 },    { x = -3342, y = 3584, z = -3353 } } } },
            { name = "twdw",     level = LEVEL_WDW,            painting = get_texture_info("twdw_painting"),  area = 2, pipes = nil, spawnLocation = { x = -773, y = -2559, z = 220 }, overrideName = "Wet-Dry Town" },
            { name = "wf",       level = LEVEL_WF,             painting = get_texture_info("wf_painting"),    area = 1, pipes = nil },
            { name = "lll",      level = LEVEL_LLL,            painting = get_texture_info("lll_painting"),   area = 1, pipes = nil },
            { name = "ssl",      level = LEVEL_SSL,            painting = get_texture_info("ssl_painting"),   area = 1, pipes = nil },
            { name = "thi",      level = LEVEL_THI,            painting = get_texture_info("thi_painting"),   area = 1, pipes = nil },
            { name = "ithi",     level = LEVEL_THI,            painting = get_texture_info("ithi_painting"),  area = 3, pipes = nil, overrideName = "Inside Tiny-Huge Island" },
            { name = "sl",       level = LEVEL_SL,             painting = get_texture_info("sl_painting"),    area = 1, pipes = nil },
            { name = "bowser 1", level = LEVEL_BOWSER_1,       painting = get_texture_info("bitdw_painting"), area = 1, pipes = nil },
        },
    },
    {
        name = "Unknown",
        shortName = "unknown",
        water = true,
        levels = {
            { name = "cg",  level = LEVEL_CASTLE_GROUNDS, painting = nil, area = 1, pipes = nil },
            { name = "bob", level = LEVEL_BOB,            painting = nil, area = 1, pipes = nil },
            { name = "wf",  level = LEVEL_WF,             painting = nil, area = 1, pipes = nil },
            { name = "jrb", level = LEVEL_JRB,            painting = nil, area = 1, pipes = nil },
            { name = "ccm", level = LEVEL_CCM,            painting = nil, area = 1, pipes = nil },
            { name = "bbh", level = LEVEL_BBH,            painting = nil, area = 1, pipes = nil },
            { name = "lll", level = LEVEL_LLL,            painting = nil, area = 1, pipes = nil },
            { name = "ssl", level = LEVEL_SSL,            painting = nil, area = 1, pipes = nil },
            { name = "hmc", level = LEVEL_HMC,            painting = nil, area = 1, pipes = nil },
            { name = "ddd", level = LEVEL_DDD,            painting = nil, area = 1, pipes = nil },
            { name = "wdw", level = LEVEL_WDW,            painting = nil, area = 1, pipes = nil },
            { name = "ttm", level = LEVEL_TTM,            painting = nil, area = 1, pipes = nil },
            { name = "thi", level = LEVEL_THI,            painting = nil, area = 1, pipes = nil },
            { name = "sl",  level = LEVEL_SL,             painting = nil, area = 1, pipes = nil },
            { name = "ttc", level = LEVEL_TTC,            painting = nil, area = 1, pipes = nil },
            { name = "rr",  level = LEVEL_RR,             painting = nil, area = 1, pipes = nil },
        },
    },
    {
        name = "Registered Levels",
        shortName = "reg levels",
        water = false,
        levels = {} -- empty table as levels are added at the end of the file
    },
    -- romhacks go below this line
    -- you will be added to the credits when you add a hack,
    -- just give me your username and hex code in the pr!
    {
        -- ported to tag by EmeraldLockdown
        name = "SM64 Sapphire",
        shortName = "sapphire",
        water = false,
        levels = {
            { name = "mm",  level = LEVEL_BOB, painting = get_texture_info("painting_sapphire_mm"), area = 1, pipes = { { { x = 81, y = 793, z = -5259 },  { x = 3275, y = 4456, z = -3997 } }, { { x = 6041, y = 3656, z = -5866 },  { x = 5840, y = 518, z = -3149 } }, { { x = 1250, y = 2098, z = -11382 },  { x = -3388, y = -4007, z = -12408  } } } },
            { name = "pp",  level = LEVEL_WF,  painting = get_texture_info("painting_sapphire_pp"), area = 1, pipes = nil },
            { name = "ll",  level = LEVEL_JRB, painting = get_texture_info("painting_sapphire_ll"), area = 1, pipes = { { { x = 4594, y = 243, z = -5992 }, { x = 12881, y = 114, z = -7182 } } } },
            { name = "tt",  level = LEVEL_CCM, painting = get_texture_info("painting_sapphire_tt"), area = 1, pipes = { { { x = 155, y = -350, z = -18718 }, { x = 4434, y = -350, z = -8335 } } } },
        }
    },
    {
        -- ported to tag by Murioz
        name = "Super Mario 74 (+EE)",
        shortName = "sm74",
        water = false,
        levels = {
            { name = "cc",    level = LEVEL_CASTLE_COURTYARD, painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = -1701, y = -441, z = 825 },  { x = 3957, y = 1147, z = -5545 } } } },
            { name = "bob",   level = LEVEL_BOB,              painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = 4066, y = -1014, z = -1968 },  { x = -1061, y = 1742, z = -1475 } } } },
            { name = "wf",    level = LEVEL_WF,               painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = -4770, y = 2571, z = 830 },  { x = 466, y = -3174, z = -1439 } } } },
            { name = "ccm",   level = LEVEL_CCM,              painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = 4271, y = -894, z = -4988 },  { x = -5825, y = 737, z = -1065 } } } },
            { name = "sa",    level = LEVEL_SA,               painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = 119, y = 1778, z = -1989 },  { x = 2082, y = -1640, z = 1542 } } } },
            { name = "bbh",   level = LEVEL_BBH,              painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = 2376, y = -1094, z = 1838 },  { x = 88, y = 3458, z = 345 } } } },
            { name = "bitdw", level = LEVEL_BITDW,            painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = 263, y = 600, z = -3725 }, { x = 232, y = 600, z = -10796 } } } },
            { name = "lll",   level = LEVEL_LLL,              painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = -1068, y = -2779, z = -5432 }, { x = 1091, y = 11934, z = 579 } } } },
            { name = "ssl",   level = LEVEL_SSL,              painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = -1467, y = 3763, z = 5607 }, { x = -5109, y = -1298, z = -1876 } } } },
            { name = "hmc",   level = LEVEL_HMC,              painting = get_texture_info("cg_painting"),    area = 1, pipes = { { { x = 2636, y = 243, z = 3280 }, { x = 177, y = 2672, z = 4133 } } } },
        }
    },
    {
        -- ported to tag by Murioz
        name = "Star Road",
        shortName = "sr",
        water = false,
        levels = {
            { name = "cg",    level = LEVEL_CASTLE_GROUNDS, painting = get_texture_info("painting_sr_cg"),     area = 1, pipes = { { { x = -7517, y = 1784, z = 2992 }, { x = 2948, y = 6385, z = -891 } } }, spawnLocation = { x = -6743, y = 2031, z = 2626 }, overrideSurfaceType = {[SURFACE_DEFAULT] = SURFACE_HARD_NOT_SLIPPERY} },
            { name = "f-hub", level = LEVEL_CASTLE,         painting = get_texture_info("painting_sr_castle"), area = 1, pipes = { { { x = -7754, y = 571, z = -6663 }, { x = 3299, y = 125, z = -2633 } } }, overrideName = "The Final Hub" },
            { name = "boi",   level = LEVEL_BOB,            painting = get_texture_info("painting_sr_boi"),    area = 1, pipes = { { { x = 5157, y = 1623, z = 4206 }, { x = -831, y = -1807, z = -3773 } } } },
            { name = "slr",   level = LEVEL_WF,             painting = get_texture_info("painting_sr_slr"),    area = 1, pipes = { { { x = 1386, y = -2166, z = -1005 }, { x = 394, y = 2448, z = -2257 } } } },
            { name = "ppp",   level = LEVEL_JRB,            painting = get_texture_info("painting_sr_ppp"),    area = 1, pipes = { { { x = -820, y = -151, z = -81 }, { x = 5756, y = 2633, z = 4822 } } } },
            { name = "ch",    level = LEVEL_CCM,            painting = get_texture_info("painting_sr_ch"),     area = 1, pipes = { { { x = 4540, y = 701, z = 4291 }, { x = 3393, y = 3501, z = -3721 } }, { { x = 2032, y = -4163, z = 1834 }, { x = 1435, y = 329, z = 101 } } } },
            { name = "mm",    level = LEVEL_PSS,            painting = get_texture_info("painting_sr_mm"),     area = 1, pipes = { { { x = 3874, y = -679, z = -4063 }, { x = -4269, y = 4585, z = 2805 } } } },
            { name = "sss",   level = LEVEL_SA,             painting = get_texture_info("painting_sr_sss"),    area = 1, pipes = { { { x = 4227, y = 3532, z = 2296 },  { x = 5688, y = -6010, z = -5545 } }, { { x = -4812, y = 1267, z = 3239 }, { x = 6144, y = 1123, z = -3292 } } } },
            { name = "gg",    level = LEVEL_BBH,            painting = get_texture_info("painting_sr_gg"),     area = 1, pipes = { { { x = -6790, y = -751, z = 2655 }, { x = 4376, y = 2632, z = -4535 } } } },
            { name = "bss",   level = LEVEL_BITDW,          painting = get_texture_info("painting_sr_bss"),    area = 1, pipes = { { { x = 3252, y = -890, z = 1743 }, { x = 414, y = 2324, z = 226 } } } },
            { name = "b1",    level = LEVEL_BOWSER_1,       painting = get_texture_info("painting_sr_b1"),     area = 1, pipes = nil },
            { name = "b3",    level = LEVEL_BOWSER_3,       painting = get_texture_info("painting_sr_b3"),     area = 1, pipes = nil },
            { name = "kc",    level = LEVEL_LLL,            painting = get_texture_info("painting_sr_kc"),     area = 1, pipes = { { { x = -1117, y = -1996, z = -4614 }, { x = 1087, y = 2133, z = 3941 } } } },
            { name = "llf",   level = LEVEL_SSL,            painting = get_texture_info("painting_sr_llf"),    area = 1, pipes = { { { x = 1158, y = 3336, z = 3333 }, { x = 3, y = -529, z = -4816 } }, { { x = -259, y = -2213, z = 2789 }, { x = 654, y = -751, z = 893 } } } },
            { name = "mmm",   level = LEVEL_DDD,            painting = get_texture_info("painting_sr_mmm"),    area = 1, pipes = { { { x = 361, y = 2235, z = -3679 }, { x = -1347, y = -2299, z = 4495 } } } },
            { name = "rrc",   level = LEVEL_BITFS,          painting = get_texture_info("painting_sr_bitfs"),  area = 1, pipes = { { { x = 3928, y = -415, z = -39 }, { x = 3076, y = 584, z = 4523 } } } },
            { name = "ccc",   level = LEVEL_WDW,            painting = get_texture_info("painting_sr_ccc"),    area = 1, pipes = { { { x = -4430, y = -485, z = -5427 },  { x = 5091, y = 2900, z = 3727 } }, { { x = -1304, y = -1596, z = -331 }, { x = 1207, y = 4253, z = -863 } } } },
            { name = "msp",   level = LEVEL_SL,             painting = get_texture_info("painting_sr_msp"),    area = 1, pipes = { { { x = -4713, y = 1778, z = 518 }, { x = 4505, y = 3709, z = 3203 } } } },
            { name = "fff",   level = LEVEL_THI,            painting = get_texture_info("painting_sr_fff"),    area = 1, pipes = { { { x = 3818, y = -1310, z = -192 }, { x = -4810, y = 1115, z = -192 } } } },
            { name = "bobf",  level = LEVEL_TTC,            painting = get_texture_info("painting_sr_bobf"),   area = 1, pipes = { { { x = 1673, y = -1224, z = 5004 }, { x = 1688, y = 3425, z = 2016 } } } },
            { name = "sr",    level = LEVEL_RR,             painting = get_texture_info("painting_sr_sr"),     area = 1, pipes = { { { x = 3162, y = -5767, z = -6163 },  { x = -1549, y = -1255, z = -5164 } }, { { x = 4902, y = 11056, z = 428 }, { x = -2196, y = 2344, z = -5477 } } } },
            { name = "totwc", level = LEVEL_TOTWC,          painting = get_texture_info("painting_sr_totwc"),  area = 1, pipes = { { { x = -4199, y = 4635, z = 1886 }, { x = 2564, y = -1947, z = -1647 } } } },
            { name = "potvc", level = LEVEL_VCUTM,          painting = get_texture_info("painting_sr_potvc"),  area = 1, pipes = { { { x = 6972, y = 422, z = -3110 }, { x = -5155, y = -77, z = 545 } } } },
            { name = "hpf",   level = LEVEL_WMOTR,          painting = get_texture_info("painting_sr_hpf"),    area = 1, pipes = { { { x = 1360, y = -1135, z = -2636 }, { x = 4994, y = 3989, z = 701 } } } },
        }
    },
    {
        -- ported to tag by EmeraldLockdown
        name = "Royal Legacy",
        shortName = "rl",
        water = false,
        levels = {
            { name = "bb",     level = LEVEL_BOB, painting = get_texture_info("painting_rl_bb"),     area = 1, pipes = { { { x = 4203, y = 92, z = -1896 }, { x = 4523, y = -3369, z = -5704 } } } },
            { name = "tt",     level = LEVEL_WF,  painting = get_texture_info("painting_rl_tt"),     area = 1, pipes = { { { x = -7891, y = 4210, z = -1108 }, { x = -13667, y = 3727, z = -3591 } }, { { x = -4494, y = 2320, z = 2478 }, { x = -5700, y = 4215, z = 805 } }, { { x = -1851, y = 2977, z = -1312 }, { x = -3371, y = 2320, z = 1840 } } } },
            { name = "bbanks", level = LEVEL_JRB, painting = get_texture_info("painting_rl_bbanks"), area = 1, pipes = { { { x = 9381, y = 486, z = -4980 }, { x = -1006, y = 3852, z = -1382 } } } },
            { name = "dd",     level = LEVEL_CCM, painting = get_texture_info("painting_rl_dd"),     area = 1, pipes = { { { x = 263, y = 600, z = -3725 }, { x = 232, y = 600, z = -10796 } } } },
        }
    },
    {
        -- ported to tag by EmeraldLockdown
        name = "Super Mario 64 Trouble Town",
        shortName = "ttown",
        water = false,
        levels = {
            { name = "cg",     level = LEVEL_CASTLE_GROUNDS, painting = get_texture_info("painting_ttown_cg"),  area = 1, pipes = nil, spawnLocation = { x = 3058, y = -87,  z = 5127 }},
            { name = "mmh",    level = LEVEL_BOB,            painting = get_texture_info("painting_ttown_mmh"), area = 1, pipes = nil, spawnLocation = { x = 48,   y = 1215, z = -537 } },
            { name = "sod",    level = LEVEL_WF,             painting = get_texture_info("painting_ttown_sod"), area = 1, pipes = nil, spawnLocation = { x = 3787, y = 0,    z = -19 } },
            { name = "hcc",    level = LEVEL_JRB,            painting = get_texture_info("painting_ttown_hcc"), area = 1, pipes = nil, spawnLocation = { x = 3774, y = 0,    z = 7290 } },
            { name = "eoo",    level = LEVEL_CCM,            painting = get_texture_info("painting_ttown_eoo"), area = 1, pipes = nil, spawnLocation = { x = 22,   y = 0,    z = 10009 } },
        }
    },
}

local function calculate_romhack_levels()
    levels = romhacks[2].levels -- unknown levels
    gGlobalSyncTable.water = romhacks[2].water -- set water var

    -- loop thru all levels and remove indexes if they are vanilla levels
    -- do it backwards so automatic formatting doesn't affect for loop
    for i = #levels, 1, -1 do
        local level = levels[i]

        if level_is_vanilla_level(level.level) then
            -- delete level from table
            table.remove(levels, i)
        end
    end
end

function configure_romhacks(mod)
    if mod == nil then
        -- vanilla, set level data to vanilla "romhack"
        levels = romhacks[1].levels

        -- level reg override
        if romhacks[3].levels ~= {} then
            for _, level in pairs(romhacks[3].levels) do
                table.insert(levels, level)
            end
        end

        return
    end

    -- see if a romhack has the name of our mod
    for i = 1, #romhacks do
        local romhack = romhacks[i]

        if romhack.name == strip_hex(mod.name) then
            -- match, set our level data to that hack
            levels = romhack.levels
            -- set water var
            gGlobalSyncTable.water = romhack.water

            -- check level reg stages
            if romhacks[3].levels ~= {} then
                for _, level in pairs(romhacks[3].levels) do
                    table.insert(levels, level)
                end
            end

            djui_popup_create("Found romhack " .. romhack.name, 3)

            return
        end
    end

    -- level reg override
    if romhacks[3].levels ~= {} then
        for _, level in pairs(romhacks[3].levels) do
            table.insert(levels, level)
        end
    end

    -- if we don't find a match, then it's a unknown hack, so calculate that
    djui_popup_create("Could not find romhack\nSee if it exists in the Romhacks\nsettings section", 3)
    calculate_romhack_levels()
end

local function check_mods()
    -- check thru 50 mods (if you have more than 50 mods enabled your crazy)
    for i = 0, 50 do
        if gActiveMods[i] ~= nil then
            if gActiveMods[i].incompatible ~= nil then
                -- check if it is a romhack by checking the incompatible tag
                if string.match(gActiveMods[i].incompatible, "romhack") then
                    -- set romhack to true and water by default to true
                    isRomhack = true

                    -- configure romhack
                    configure_romhacks(gActiveMods[i])

                -- check for nametags mod by looking at incompatible tag
                elseif string.match(gActiveMods[i].incompatible, "nametags") then
                    -- set nametagsEnabled to true
                    nametagsEnabled = true
                end
            end
        end
    end

    -- if we aren't using a hack, configure romhacks without inputting index
    if not isRomhack then
        configure_romhacks(nil)
    end
end

-- arena map support
-- recreate arena's add level
_G.Arena = {}
_G.Arena.add_level = function(level, name)
    -- insert level into the level reg stages
    table.insert(romhacks[3].levels, {
        name = name,
        level = level,
        painting = nil,
                area = 1,
        pipes = nil
    })
end

-- tag map api
_G.tag.add_level = function (level, name, painting, area, pipes, spawnLocation)
    -- insert level into the level reg stages
    table.insert(romhacks[3].levels, {
        name = name,
        level = level,
        painting = get_texture_info(painting),
        area = area,
        pipes = pipes,
        spawnLocation = spawnLocation,
    })
end

local function level_init()
    if initializedRomhacks then return end
    initializedRomhacks = true
    -- check for mods
    check_mods()
end

hook_event(HOOK_ON_LEVEL_INIT, level_init)