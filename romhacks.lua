
local initializedRomhacks = false

romhacks = {
    {
        -- name of the hack
        name = "Vanilla",
        shortName = "vanilla",
        water = false,
        -- level data
        levels = {
            -- name is the abbreviated level name, level is the level, painting is the image file, act is the act, area is the area, pipe stuff is for pipe positions
            {
                name = "cg",
                level = LEVEL_CASTLE_GROUNDS,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -5979, y = 363, z = -1371 },
                        { x = 1043, y = 3174, z = -5546 }
                    }
                }
            },
            {
                name = "bob",
                level = LEVEL_BOB,
                painting = get_texture_info("bob_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -4694, y = 0, z = 6699 },
                        { x = 5079, y = 3072, z = 655 }
                    }
                }
            },
            {
                name = "wf",
                level = LEVEL_WF,
                painting = get_texture_info("wf_painting"),
                area = 1,
                pipes = {
                    {
                        { x = 4623, y = 300, z = 129 },
                        { x = -618, y = 3584, z = 1154 }
                    }
                }
            },
            {
                name = "jrb",
                level = LEVEL_JRB,
                painting = get_texture_info("jrb_painting"),
                area = 1,
                pipes = {
                    {
                        { x = 3000, y = -5119, z = 2688 },  { x = -6398, y = 1126, z = 191 }
                    }
                },
                unwantedBhvs = { id_bhvUnagi, id_bhvUnagiSubobject }
            },
            {
                name = "ccm",
                level = LEVEL_CCM,
                painting = get_texture_info("ccm_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -1352, y = 2560, z = -1824 },
                        { x = 5628, y = -4607, z = -28 }
                    }
                }
            },
            {
                -- level added by Murioz
                name = "cc",
                level = LEVEL_CASTLE_COURTYARD,
                painting = get_texture_info("cc_painting"),
                area = 1,
                pipes = nil,
                unwantedBhvs = { id_bhvBooCage }
            },
            {
                -- ported by Murioz, painting by jzzle
                name = "bbh",
                level = LEVEL_BBH,
                painting = get_texture_info("bbh_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -3291, y = -204, z = 4997 },
                        { x = 946, y = -2457, z = 1799 }
                    },
                    {
                        { x = -403, y = -204, z = 2436 },
                        { x = 657, y = 2867, z = 1568 }
                    }
                }
            },
            {
                name = "lll",
                level = LEVEL_LLL,
                painting = get_texture_info("lll_painting"),
                area = 1,
                pipes = nil
            },
            {
                name = "vol",
                level = LEVEL_LLL,
                painting = get_texture_info("vol_painting"),
                area = 2,
                pipes = {
                    {
                        { x = 2525, y = 3591, z = -899 },
                        { x = -1515, y = 96, z = 610 },
                    }
                },
                overrideName = "Into the Volcano",
                overrideWater = true
            },
            {
                name = "ssl",
                level = LEVEL_SSL,
                painting = get_texture_info("ssl_painting"),
                area = 1,
                pipes = nil
            },
            {
                name = "itp",
                level = LEVEL_SSL,
                painting = get_texture_info("itp_painting"),
                area = 2,
                pipes = {
                    {
                        { x = -460, y = 0, z = 4247 },
                        { x = 997, y = 3942, z = 1234 }
                    }
                }, overrideName = "Inside The Pyramid"
            },
            {
                name = "rhmc",
                level = LEVEL_HMC,
                painting = get_texture_info("rhmc_painting"),
                area = 1,
                pipes = nil,
                spawnLocation = { x = 4050, y = 0, z = 4981 },
                overrideName = "Red's In HMC",
                room = 2,
                unwantedBhvs = { id_bhvHmcElevatorPlatform },
                disabledBhvs = { id_bhvDoor }
            },
            {
                name = "tm",
                level = LEVEL_HMC,
                painting = get_texture_info("tm_painting"),
                area = 1,
                pipes = nil,
                spawnLocation = { x = 1988, y = -1023, z = 454 },
                overrideName = "Toxic Maze",
                room = 3,
                unwantedBhvs = { id_bhvHmcElevatorPlatform },
                disabledBhvs = { id_bhvDoor },
            },
            {
                name = "dd",
                level = LEVEL_HMC,
                painting = get_texture_info("dd_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -3718, y = -4279, z = 3058 },
                        { x = -133, y = -4689, z = 3327 }
                    }
                },
                spawnLocation = { x = -3547, y = -2559, z = -6975 },
                overrideName = "Dorrie's Domain",
                room = 6,
                unwantedBhvs = { id_bhvHmcElevatorPlatform },
                disabledBhvs = { id_bhvDoor },
            },
            {
                name = "br",
                level = LEVEL_HMC,
                painting = get_texture_info("br_painting"),
                area = 1,
                pipes = nil,
                spawnLocation = { x = -6152, y = 1536, z = 1084 },
                overrideName = "Boulder Rush",
                room = 4,
                unwantedBhvs = { id_bhvHmcElevatorPlatform },
                disabledBhvs = { id_bhvDoor },
            },
            {
                name = "bs",
                level = LEVEL_DDD,
                painting = get_texture_info("bs_painting"),
                area = 2,
                pipes = {
                    {
                        { x = 3390, y = -3319, z = -525 },
                        { x = 1283, y = 110, z = 4037 },
                    }
                },
                overrideName = "Bowser's Sub",
                spawnLocation = { x = 3899, y = 571, z = -1295 }
            },
            {
                name = "bitfs",
                level = LEVEL_BITFS,
                painting = get_texture_info("bitfs_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -154, y = -2866, z = -102 },
                        { x = 1205, y = 5478, z = 58 }
                    }
                }
            },
            {
                name = "wdw",
                level = LEVEL_WDW,
                painting = get_texture_info("wdw_painting"),
                area = 1,
                pipes = {
                    {
                        { x = 3346, y = 154, z = 2918 },
                        { x = -3342, y = 3584, z = -3353 }
                    }
                }
            },
            {
                name = "wdt",
                level = LEVEL_WDW,
                painting = get_texture_info("twdw_painting"),
                area = 2,
                pipes = nil,
                spawnLocation = { x = -773, y = -2559, z = 220 },
                overrideName = "Wet-Dry Town"
            },
            {
                name = "ttm",
                level = LEVEL_TTM,
                painting = get_texture_info("ttm_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -1080, y = -4634, z = 4176 },
                        { x = 1031, y = 2306, z = -198 }
                    }
                }
            },
            {
                name = "thi",
                level = LEVEL_THI,
                painting = get_texture_info("thi_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -5675, y = -2969, z = 7611 },
                        { x = 0, y = 3891, z = -1521 },
                    }
                }
            },
            {
                name = "ithi",
                level = LEVEL_THI,
                painting = get_texture_info("ithi_painting"),
                area = 3,
                pipes = nil,
                overrideName = "Wiggler's Cave"
            },
            {
                name = "sl",
                level = LEVEL_SL,
                painting = get_texture_info("sl_painting"),
                area = 1,
                pipes = nil
            },
            {
                name = "ttc",
                level = LEVEL_TTC,
                painting = get_texture_info("ttc_painting"),
                area = 1,
                 pipes = {
                    {
                        { x = 1361, y = -4822, z = 176 },
                        { x = 1594, y = 5284, z = 1565 }
                    }
                }
            },
            {
                name = "rr",
                level = LEVEL_RR,
                painting = get_texture_info("rr_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -4221, y = 6451, z = -5885 },
                        { x = 2125, y = -1833, z = 2079 }
                    },
                    {
                        { x = 5545, y = 3322, z = -2345 },
                        { x = 4487, y = 3819, z = 4060 }
                    },
                },
                overrideSurfaceType = { [SURFACE_DEFAULT] = SURFACE_HARD_NOT_SLIPPERY }
            },
            {
                name = "b1",
                level = LEVEL_BOWSER_1,
                painting = get_texture_info("b1_painting"),
                area = 1,
                pipes = nil,
                overrideName = "Bowser's Dark Domain"
            },
            {
                name = "b3",
                level = LEVEL_BOWSER_3,
                painting = get_texture_info("b3_painting"),
                area = 1,
                pipes = nil,
                unwantedBhvs = { id_bhvFallingBowserPlatform },
                overrideName = "Bowser's Sky Domain"
            },
            {
                -- level added by Murioz
                name = "vcutm",
                level = LEVEL_VCUTM,
                painting = get_texture_info("vcutm_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -3560, y = 5734, z = -6142 },
                        { x = 4500, y = 0, z = -5529 }
                    }
                },
                overrideName = "Under The Moat"
            },
        },
    },
    {
        name = "Unknown Hack",
        shortName = "unknown",
        water = true,
        levels = {
            {
                name = "cg",
                level = LEVEL_CASTLE_GROUNDS,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "bob",
                level = LEVEL_BOB,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "wf",
                level = LEVEL_WF,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "jrb",
                level = LEVEL_JRB,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "ccm",
                level = LEVEL_CCM,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "bbh",
                level = LEVEL_BBH,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "lll",
                level = LEVEL_LLL,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "ssl",
                level = LEVEL_SSL,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "hmc",
                level = LEVEL_HMC,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "ddd",
                level = LEVEL_DDD,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "wdw",
                level = LEVEL_WDW,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "ttm",
                level = LEVEL_TTM,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "thi",
                level = LEVEL_THI,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "sl",
                level = LEVEL_SL,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "ttc",
                level = LEVEL_TTC,
                painting = nil,
                area = 1,
                pipes = nil
            },
            {
                name = "rr",
                level = LEVEL_RR,
                painting = nil,
                area = 1,
                pipes = nil
            }
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
            {
                name = "mm",
                level = LEVEL_BOB,
                painting = get_texture_info("painting_sapphire_mm"),
                area = 1,
                pipes = {
                    {
                        { x = 81, y = 793, z = -5259 },
                        { x = 3275, y = 4456, z = -3997 }
                    },
                    {
                        { x = 6041, y = 3656, z = -5866 },
                        { x = 5840, y = 518, z = -3149 }
                    },
                    {
                        { x = 1250, y = 2098, z = -11382 },
                        { x = -3388, y = -4007, z = -12408 }
                    }
                }
            },
            {
                name = "pp",
                level = LEVEL_WF,
                painting = get_texture_info("painting_sapphire_pp"),
                area = 1,
                pipes = nil
            },
            {
                name = "ll",
                level = LEVEL_JRB,
                painting = get_texture_info("painting_sapphire_ll"),
                area = 1,
                pipes = {
                    {
                        { x = 4594, y = 243, z = -5992 },
                        { x = 12881, y = 114, z = -7182 }
                    }
                }
            },
            {
                name = "tt",
                level = LEVEL_CCM,
                painting = get_texture_info("painting_sapphire_tt"),
                area = 1,
                pipes = {
                    {
                        { x = 155, y = -350, z = -18718 },
                        { x = 4434, y = -350, z = -8335 }
                    }
                }
            },
            {
                name = "bga",
                level = LEVEL_BOWSER_3,
                painting = get_texture_info("painting_sapphire_bga"),
                area = 1,
                pipes = nil,
                overrideName = "Bowser's Gloomy Arena"
            }
        }
    },
    {
        -- ported to tag by Murioz
        name = "Super Mario 74 (+EE)",
        shortName = "sm74",
        water = false,
        levels = {
            {
                name = "tc",
                level = LEVEL_CASTLE_COURTYARD,
                painting = get_texture_info("painting_74_tc"),
                area = 1,
                pipes = {
                    {
                        { x = -1701, y = -441, z = 825 },
                        { x = 3957, y = 1147, z = -5545 }
                    }
                },
                overrideName = "The Courtyard"
            },
            {
                name = "tt",
                level = LEVEL_CASTLE,
                painting = get_texture_info("painting_74_cmf"),
                area = 1,
                pipes = {
                    {
                        { x = -132, y = 2088, z = 3645 },
                        { x = 2130, y = -942, z = -2502 }
                    }
                },
                overrideName = "The Temple",
                unwantedBhvs = { id_bhvExclamationBox }
            },
            {
                name = "tote",
                level = LEVEL_WMOTR,
                painting = get_texture_info("painting_74_tote"),
                area = 1,
                pipes = {
                    {
                        { x = -3279, y = -1578, z = 2961 },
                        { x = 5533, y = 3503, z = 3982 }
                    }
                }
            },
            {
                name = "df",
                level = LEVEL_BOB,
                painting = get_texture_info("painting_74_df"),
                area = 1,
                pipes = {
                    {
                        { x = 4066, y = -1014, z = -1968 },
                        { x = -1061, y = 1742, z = -1475 }
                    }
                },
                unwantedBhvs = { id_bhvExclamationBox }
            },
            {
                name = "moj",
                level = LEVEL_WF,
                painting = get_texture_info("painting_74_moj"),
                area = 1,
                pipes = {
                    {
                        { x = -4770, y = 2571, z = 830 },
                        { x = 466, y = -3174, z = -1439 }
                    }
                }
            },
            {
                name = "tmss",
                level = LEVEL_CCM,
                painting = get_texture_info("painting_74_tmss"),
                area = 1,
                pipes = {
                    {
                        { x = 4271, y = -894, z = -4988 },
                        { x = -5825, y = 737, z = -1065 }
                    }
                }
            },
            {
                name = "tsod",
                level = LEVEL_COTMC,
                painting = get_texture_info("painting_74_tsod"),
                area = 1,
                pipes = {
                    {
                        { x = -3489, y = -468, z = 2831 },
                        { x = -3374, y = 1226, z = -2423 }
                    }
                }
            },
            {
                name = "cc",
                level = LEVEL_SA,
                painting = get_texture_info("painting_74_cc"),
                area = 1,
                pipes = {
                    {
                        { x = 119, y = 1778, z = -1989 },
                        { x = 2082, y = -1640, z = 1542 }
                    }
                }
            },
            {
                name = "thr",
                level = LEVEL_BBH,
                painting = get_texture_info("painting_74_thr"),
                area = 1,
                pipes = {
                    {
                        { x = 2376, y = -1094, z = 1838 },
                        { x = 88, y = 3458, z = 345 }
                    }
                }
            },
            {
                name = "bbb",
                level = LEVEL_BITDW,
                painting = get_texture_info("painting_74_bbb"),
                area = 1,
                pipes = {
                    {
                        { x = 4437, y = -963, z = -3643 },
                        { x = 2405, y = 3966, z = 1787 }
                    }
                }
            },
            {
                name = "dlss",
                level = LEVEL_LLL,
                painting = get_texture_info("painting_74_dlss"),
                area = 1,
                pipes = {
                    {
                        { x = -1068, y = -2779, z = -5432 },
                        { x = 1091, y = 11934, z = 579 }
                    }
                }
            },
            {
                name = "tpss",
                level = LEVEL_SSL,
                painting = get_texture_info("painting_74_tpss"),
                area = 1,
                pipes = {
                    {
                        { x = -1467, y = 3763, z = 5607 },
                        { x = -5109, y = -1298, z = -1876 }
                    }
                }
            },
            {
                name = "sc",
                level = LEVEL_HMC,
                painting = get_texture_info("painting_74_sc"),
                area = 1,
                pipes = {
                    {
                        { x = 2636, y = 243, z = 3280 },
                        { x = 177, y = 2672, z = 4133 }
                    },
                    {
                        { x = -448, y = -7166, z = -2908 },
                        { x = -2713, y = -278, z = -6712 }
                    }
                }
            },
            {
                name = "fg",
                level = LEVEL_DDD,
                painting = get_texture_info("painting_74_fg"),
                area = 1,
                pipes = {
                    {
                        { x = -3957, y = 1908, z = -4284 },
                        { x = -397, y = -856, z = 2018 }
                    },
                    {
                        { x = 4315, y = -58, z = 5617 },
                        { x = 2894, y = 1676, z = -3565 }
                    }
                }
            },
            {
                name = "bac",
                level = LEVEL_BITFS,
                painting = get_texture_info("painting_74_bac"),
                area = 1,
                pipes = {
                    {
                        { x = 1534, y = -2455, z = -28 },
                        { x = 1610, y = 1399, z = 2051 }
                    }
                }
            },
            {
                name = "cof",
                level = LEVEL_TTM,
                painting = get_texture_info("painting_74_cof"),
                area = 1,
                pipes = {
                    {
                        { x = -2405, y = 2944, z = -593 },
                        { x = 1189, y = -2197, z = 996 }
                    }
                }
            },
            {
                name = "ss",
                level = LEVEL_SL,
                painting = get_texture_info("painting_74_ss"),
                area = 1,
                pipes = {
                    {
                        { x = -5908, y = 3391, z = 4342 },
                        { x = -3111, y = -1704, z = -2754 }
                    }
                }
            },
            {
                name = "sb",
                level = LEVEL_WDW,
                painting = get_texture_info("painting_74_sb"),
                area = 1,
                pipes = {
                    {
                        { x = 3180, y = -558, z = 300 },
                        { x = 4198, y = 3231, z = -4779 }
                    }
                }
            }
        }
    },
    {
        -- ported to tag by Murioz
        name = "Star Road",
        shortName = "sr",
        water = false,
        levels = {
            {
                name = "cg",
                level = LEVEL_CASTLE_GROUNDS,
                painting = get_texture_info("painting_sr_cg"),
                area = 1,
                pipes = {
                    {
                        { x = -7517, y = 1784, z = 2992 },
                        { x = 2948, y = 6385, z = -891 }
                    }
                },
                spawnLocation = { x = -6743, y = 2031, z = 2626 },
                overrideSurfaceType = {[SURFACE_DEFAULT] = SURFACE_HARD_NOT_SLIPPERY}
            },
            {
                name = "sew",
                level = LEVEL_CASTLE_COURTYARD,
                painting = get_texture_info("painting_sr_sew"),
                area = 1,
                pipes = nil,
                spawnLocation = { x = 2289, y = -3284, z = 6310 },
                overrideName = "The Sewers",
            },
            {
                name = "fhub",
                level = LEVEL_CASTLE,
                painting = get_texture_info("painting_sr_castle"),
                area = 1,
                pipes = {
                    {
                        { x = -7754, y = 571, z = -6663 },
                        { x = 3299, y = 125, z = -2633 }
                    }
                },
                overrideName = "The Final Hub"
            },
            {
                name = "boi",
                level = LEVEL_BOB,
                painting = get_texture_info("painting_sr_boi"),
                area = 1,
                pipes = {
                    {
                        { x = 5157, y = 1623, z = 4206 },
                        { x = -831, y = -1807, z = -3773 }
                    }
                }
            },
            {
                name = "slr",
                level = LEVEL_WF,
                painting = get_texture_info("painting_sr_slr"),
                area = 1,
                pipes = {
                    {
                        { x = 1386, y = -2166, z = -1005 },
                        { x = 394, y = 2448, z = -2257 }
                    }
                }
            },
            {
                name = "ppp",
                level = LEVEL_JRB,
                painting = get_texture_info("painting_sr_ppp"),
                area = 1,
                pipes = {
                    {
                        { x = -820, y = -151, z = -81 },
                        { x = 5756, y = 2633, z = 4822 }
                    }
                }
            },
            {
                name = "ch",
                level = LEVEL_CCM,
                painting = get_texture_info("painting_sr_ch"),
                area = 1,
                pipes = {
                    {
                        { x = 4540, y = 701, z = 4291 },
                        { x = 3393, y = 3501, z = -3721 }
                    },
                    {
                        { x = 2032, y = -4163, z = 1834 },
                        { x = 1435, y = 329, z = 101 }
                    }
                }
            },
            {
                name = "mm",
                level = LEVEL_PSS,
                painting = get_texture_info("painting_sr_mm"),
                area = 1,
                pipes = {
                    {
                        { x = 3874, y = -679, z = -4063 },
                        { x = -4269, y = 4585, z = 2805 }
                    }
                }
            },
            {
                name = "sss",
                level = LEVEL_SA,
                painting = get_texture_info("painting_sr_sss"),
                area = 1,
                pipes = {
                    {
                        { x = 4227, y = 3532, z = 2296 },
                        { x = 5688, y = -6010, z = -5545 }
                    },
                    {
                        { x = -4812, y = 1267, z = 3239 },
                        { x = 6144, y = 1123, z = -3292 }
                    },
                    {
                        { x = -2300, y = -2344, z = -242 },
                        { x = 1104, y = -3944, z = 1930 }
                    }
                }
            },
            {
                name = "gg",
                level = LEVEL_BBH,
                painting = get_texture_info("painting_sr_gg"),
                area = 1,
                pipes = {
                    {
                        { x = -6790, y = -751, z = 2655 },
                        { x = 4376, y = 2632, z = -4535 }
                    }
                },
            },
            {
                name = "bss",
                level = LEVEL_BITDW,
                painting = get_texture_info("painting_sr_bss"),
                area = 1,
                pipes = {
                    {
                        { x = 3252, y = -890, z = 1743 },
                        { x = 414, y = 2324, z = 226 }
                    }
                }
            },
            {
                name = "b1",
                level = LEVEL_BOWSER_1,
                painting = get_texture_info("painting_sr_b1"),
                area = 1,
                pipes = nil
            },
            {
                name = "b3",
                level = LEVEL_BOWSER_3,
                painting = get_texture_info("painting_sr_b3"),
                area = 1,
                pipes = nil
            },
            {
                name = "kc",
                level = LEVEL_LLL,
                painting = get_texture_info("painting_sr_kc"),
                area = 1,
                pipes = {
                    {
                        { x = -1117, y = -1996, z = -4614 },
                        { x = 1087, y = 2133, z = 3941 }
                    }
                }
            },
            {
                name = "llf",
                level = LEVEL_SSL,
                painting = get_texture_info("painting_sr_llf"),
                area = 1,
                pipes = {
                    {
                        { x = 1158, y = 3336, z = 3333 },
                        { x = 3, y = -529, z = -4816 }
                    },
                    {
                        { x = -259, y = -2213, z = 2789 },
                        { x = 654, y = -751, z = 893 }
                    }
                },
                unwantedBhvs = { id_bhvMips }
            },
            {
                name = "mmm",
                level = LEVEL_DDD,
                painting = get_texture_info("painting_sr_mmm"),
                area = 1,
                pipes = {
                    {
                        { x = 361, y = 2235, z = -3679 },
                        { x = -1347, y = -2299, z = 4495 }
                    }
                }
            },
            {
                name = "rrc",
                level = LEVEL_BITFS,
                painting = get_texture_info("painting_sr_bitfs"),
                area = 1,
                pipes = {
                    {
                        { x = 3928, y = -415, z = -39 },
                        { x = 3076, y = 584, z = 4523 }
                    }
                },
                overrideSurfaceType = { [SURFACE_DEFAULT] = SURFACE_HARD_NOT_SLIPPERY }
            },
            {
                name = "ccc",
                level = LEVEL_WDW,
                painting = get_texture_info("painting_sr_ccc"),
                area = 1,
                pipes = {
                    {
                        { x = -4430, y = -485, z = -5427 },
                        { x = 5091, y = 2900, z = 3727 }
                    },
                    {
                        { x = -1304, y = -1596, z = -331 },
                        { x = 1207, y = 4253, z = -863 }
                    }
                }
            },
            {
                name = "msp",
                level = LEVEL_SL,
                painting = get_texture_info("painting_sr_msp"),
                area = 1,
                pipes = {
                    {
                        { x = -4713, y = 1778, z = 518 },
                        { x = 4505, y = 3709, z = 3203 }
                    }
                },
                unwantedBhvs = { id_bhvBigChillBully }
            },
            {
                name = "fff",
                level = LEVEL_THI,
                painting = get_texture_info("painting_sr_fff"),
                area = 1,
                pipes = {
                    {
                        { x = 3818, y = -1310, z = -192 },
                        { x = -4810, y = 1115, z = -192 }
                    }
                }
            },
            {
                name = "bobf",
                level = LEVEL_TTC,
                painting = get_texture_info("painting_sr_bobf"),
                area = 1,
                pipes = {
                    {
                        { x = 1673, y = -1224, z = 5004 },
                        { x = 1688, y = 3425, z = 2016 }
                    }
                }
            },
            {
                name = "sr",
                level = LEVEL_RR,
                painting = get_texture_info("painting_sr_sr"),
                area = 1,
                pipes = {
                    {
                        { x = 3162, y = -5767, z = -6163 },
                        { x = -1549, y = -1255, z = -5164 }
                    },
                    {
                        { x = 4902, y = 11056, z = 428 },
                        { x = -2196, y = 2344, z = -5477 }
                    }
                }
            },
            {
                name = "totwc",
                level = LEVEL_TOTWC,
                painting = get_texture_info("painting_sr_totwc"),
                area = 1,
                pipes = {
                    {
                        { x = -4199, y = 4635, z = 1886 },
                        { x = 2564, y = -1947, z = -1647 }
                    }
                }
            },
            {
                name = "potvc",
                level = LEVEL_VCUTM,
                painting = get_texture_info("painting_sr_potvc"),
                area = 1,
                pipes = {
                    {
                        { x = 6972, y = 422, z = -3110 },
                        { x = -5155, y = -77, z = 545 }
                    }
                }
            },
            {
                name = "hpf",
                level = LEVEL_WMOTR,
                painting = get_texture_info("painting_sr_hpf"),
                area = 1,
                pipes = {
                    {
                        { x = 1360, y = -1135, z = -2636 },
                        { x = 4994, y = 3989, z = 701 }
                    }
                }
            }
        }
    },
    {
        -- ported to tag by Bear
        name = "SM64: The Green Stars",
        shortName = "green stars",
        water = false,
        levels = {
            {
                name = "ow1",
                level = LEVEL_CASTLE_GROUNDS,
                painting = get_texture_info("painting_gs_ow1"),
                area = 1,
                pipes = nil,
                springs = {
                    { x = -333, y = -556, z = 259, pitch = 0, yaw = 0, strength = 120 },
                },
                unwantedBhvs = { id_bhvToadMessage },
                spawnLocation = { x = -1500, y = -509, z = 2102 },
                overrideName = "Overworld"
            },
            {
                name = "bop",
                level = LEVEL_BOB,
                painting = get_texture_info("painting_gs_bop"),
                area = 1,
                pipes = {
                    {
                        { x = -470, y = -1036, z = 647 },
                        { x = -2979, y = 1455, z = -3408 }
                    }
                },
                overrideName = "Bob-omb Plains"
            },
            {
                name = "wforest",
                level = LEVEL_WF,
                painting = get_texture_info("painting_gs_wforest"),
                area = 1,
                pipes = {
                    {
                        { x = -3019, y = -1139, z = -1877 },
                        { x = 2394, y = 2038, z = -493 }
                    },
                    {
                        { x = 2969, y = -1314, z = 4302 },
                        { x = 6228, y = -3071, z = 6125 }
                    }
                }

            },
            {
                name = "sspeaks",
                level = LEVEL_CCM,
                painting = get_texture_info("painting_gs_sspeaks"),
                area = 1,
                pipes = {
                    {
                        { x = 3080, y = -2147, z = 951 },
                        { x = 1411, y = 1808, z = -2782 }
                    },
                    {
                        { x = -1536, y = -690, z = 1076 },
                        { x = 4522, y = 5028, z = -1194 }
                    }
                },
                springs = {
                    { x = -1193, y = -2692, z = -3216, pitch = 0, yaw = 0, strength = 680 },
                    { x = -3747, y = -2106, z = 7425, pitch = -10000, yaw = -6000, strength = 110 },
                    { x = -4830, y = -1402, z = 4068, pitch = -10000, yaw = 0x8000 + 1000, strength = 60 },
                }
            },
            {
                name = "fiery",
                level = LEVEL_BBH,
                painting = get_texture_info("painting_gs_fiery"),
                area = 1,
                pipes = {
                    {
                        { x = -269, y = -2433, z = 1433 },
                        { x = 1420, y = 723, z = 5108 }
                    }
                },
                springs = {
                    { x = -4301, y = -1026, z = 6008, pitch = 0, yaw = 0, strength = 375 },
                },
                unwantedBhvs = { id_bhvExclamationBox }
             },
             {
                name = "btt",
                level = LEVEL_HMC,
                painting = get_texture_info("painting_gs_btt"),
                area = 1,
                pipes = {
                    {
                        { x = -2669, y = -3479, z = 353 },
                        { x = 1839, y = 6824, z = -715 }
                    }
                },
                springs = {
                    { x = 4400, y = -4179, z = -663, pitch = -4000, yaw = 16000, strength = 100 },
                },
                unwantedBhvs = { id_bhvBalconyBigBoo },
             },
             {
                name = "wcp",
                level = LEVEL_TOTWC,
                painting = get_texture_info("painting_gs_wcp"),
                area = 1,
                pipes = {
                    {
                        { x = 1113, y = -3003, z = -4057 },
                        { x = -377, y = 2808, z = 514 }
                    },
                },
                unwantedBhvs = { id_bhvCapSwitch, id_bhvCapSwitchBase }
            },
            {
                name = "sd",
                level = LEVEL_SSL,
                painting = get_texture_info("painting_gs_sd"),
                area = 1,
                pipes = {
                    {
                        { x = -4095, y = 324, z = 888 },
                        { x = 4827, y = 3180, z = -4556 }
                    }
                },
                unwantedBhvs = { id_bhvPurpleSwitchHiddenBoxes }
            },
            {
                name = "gog",
                level = LEVEL_LLL,
                painting = get_texture_info("painting_gs_gog"),
                area = 1,
                pipes = nil,
                springs = {
                    { x = 4955, y = -583, z = 260, pitch = 0, yaw = 0, strength = 145 },
                    { x = -1245, y = -933, z = -2011, pitch = 0, yaw = 0, strength = 120 },
                    { x = -1127, y = -583, z = 5589, pitch = 0, yaw = 0, strength = 120 },
                },
                unwantedBhvs = { id_bhvFirePiranhaPlant },
            },
            {
                name = "seasidebay",
                level = LEVEL_DDD,
                painting = get_texture_info("painting_gs_seasidebay"),
                area = 1,
                pipes = {
                    {
                        { x = 5333, y = -666, z = -3070 },
                        { x = 6435, y = -4866, z = -6210 }
                    },
                },
                unwantedBhvs = { id_bhvWigglerBody, id_bhvWigglerHead },
            },
            {
                name = "mmg",
                level = LEVEL_SL,
                painting = get_texture_info("painting_gs_mmg"),
                area = 1,
                pipes = nil,
                unwantedBhvs = { id_bhvBigBullyWithMinions },
            },
            {
                name = "blazing",
                level = LEVEL_BITFS,
                painting = get_texture_info("painting_gs_blazing"),
                area = 1,
                pipes =  {
                    {
                        { x = 3991, y = -3442, z = -839 },
                        { x = 223, y = 3891, z = 118 }
                    }
                },
                springs = {
                    { x = -3751, y = -6669, z = 72, pitch = 0, yaw = 0, strength = 185 },
                },
            },
            {
                name = "pc",
                level = LEVEL_TTM,
                painting = get_texture_info("painting_gs_pc"),
                area = 1,
                pipes = {
                    {
                        { x = -5942, y = 281, z = -2224 },
                        { x = -4740, y = 5009, z = 4794 }
                    }
                },
                springs = {
                    { x = 562, y = 293, z = -1026, pitch = -4500, yaw = 13000, strength = 90 },
                    { x = 2080, y = -712, z = -5417, pitch = -6000, yaw = 5000, strength = 80 },
                    { x = -3885, y = 281, z = -1902, pitch = -4000, yaw = -17000, strength = 90 },
                    { x = 7014, y = -2144, z = 5971, pitch = 0, yaw = 0, strength = 700 },
                 },
                 unwantedBhvs = { id_bhvChuckya },
            },
            {
                name = "cq",
                level = LEVEL_TTC,
                painting = get_texture_info("painting_gs_cq"),
                area = 1,
                pipes = {
                    {
                        { x = -4222, y = -2180, z = 1997 },
                        { x = -184, y = 5985, z = -5033 }
                    },
                },
                unwantedBhvs = { id_bhvThwomp, id_bhvThwomp2, id_bhvExclamationBox },
            },
            {
                name = "ns",
                level = LEVEL_PSS,
                painting = get_texture_info("painting_gs_ns"),
                area = 1,
                pipes = {
                    {
                        { x = -8752, y = 6304, z = 12219 },
                        { x = 4317, y = -4545, z = 7889 }
                    },
                },
                springs = {
                    { x = -8719, y = -1745, z = 13389, pitch = 0, yaw = 0, strength = -770 },
                    { x = 4196, y = -4545, z = 8441, pitch = 0, yaw = 0, strength = 140 },
                 },
            },
            {
                name = "bc",
                level = LEVEL_CASTLE,
                painting = get_texture_info("painting_gs_bc"),
                area = 1,
                pipes = {
                    {
                        { x = -3037, y = 1261, z = 40 },
                        { x = 576, y = -1846, z = 56 }
                    }
                },
                springs = {
                    { x = -71, y = 955, z = -2295, pitch = 0, yaw = 0, strength = 80 }
                },
                overrideName = "Bowser's Castle"
            },
        }
    },
    {
        -- ported to tag by EmeraldLockdown
        name = "Royal Legacy",
        shortName = "rl",
        water = false,
        levels = {
            {
                name = "bb",
                level = LEVEL_BOB,
                painting = get_texture_info("painting_rl_bb"),
                area = 1,
                pipes = {
                    {
                        { x = 4203, y = 92, z = -1896 },
                        { x = 4523, y = -3369, z = -5704 }
                    }
                }
            },
            {
                name = "tt",
                level = LEVEL_WF,
                painting = get_texture_info("painting_rl_tt"),
                area = 1,
                pipes = {
                    {
                        { x = -7891, y = 4210, z = -1108 },
                        { x = -13667, y = 3727, z = -3591 }
                    },
                    {
                        { x = -4494, y = 2320, z = 2478 },
                        { x = -5700, y = 4215, z = 805 }
                    },
                    {
                        { x = -1851, y = 2977, z = -1312 },
                        { x = -3371, y = 2320, z = 1840 }
                    }
                },
                unwantedBhvs = { id_bhvBreakableBox }
            },
            {
                name = "bbanks",
                level = LEVEL_JRB,
                painting = get_texture_info("painting_rl_bbanks"),
                area = 1,
                pipes = {
                    {
                        { x = 9381, y = 486, z = -4980 },
                        { x = -1006, y = 3852, z = -1382 }
                    }
                }
            },
            {
                name = "dd",
                level = LEVEL_CCM,
                painting = get_texture_info("painting_rl_dd"),
                area = 1,
                pipes = {
                    {
                        { x = 263, y = 600, z = -3725 },
                        { x = 232, y = 600, z = -10796 }
                    }
                }
            }
        }
    },
    {
        -- ported to tag by EmeraldLockdown
        name = "Super Mario 64 Trouble Town",
        shortName = "ttown",
        water = false,
        levels = {
            {
                name = "cg",
                level = LEVEL_CASTLE_GROUNDS,
                painting = get_texture_info("painting_ttown_cg"),
                area = 1,
                pipes = nil,
                spawnLocation = { x = 3058, y = -87, z = 5127 }
            },
            {
                name = "mmh",
                level = LEVEL_BOB,
                painting = get_texture_info("painting_ttown_mmh"),
                area = 1,
                pipes = nil,
                spawnLocation = { x = 48, y = 1215, z = -537 }
            },
            {
                name = "sod",
                level = LEVEL_WF,
                painting = get_texture_info("painting_ttown_sod"),
                area = 1,
                pipes = nil,
                spawnLocation = { x = 3787, y = 0, z = -19 }
            },
            {
                name = "hcc",
                level = LEVEL_JRB,
                painting = get_texture_info("painting_ttown_hcc"),
                area = 1,
                pipes = nil,
                spawnLocation = { x = 3774, y = 0, z = 7290 }
            },
            {
                name = "eoo",
                level = LEVEL_CCM,
                painting = get_texture_info("painting_ttown_eoo"),
                area = 1,
                pipes = nil,
                spawnLocation = { x = 22, y = 0, z = 10009 }
            }
        }
    },
    {
        -- ported to tag by Murioz
        name = "Super Mario Rainbow Road",
        shortName = "rr",
        water = true,
        levels = {
            {
                name = "cg",
                level = LEVEL_CASTLE_GROUNDS,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -6847, y = -848, z = 977 },
                        { x = 4075, y = -848, z = 1343 }
                    },
                },
                spawnLocation = { x = -3821, y = -743, z = 3926 },
            },
            {
                name = "bob",
                level = LEVEL_BOB,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = {
                    {
                        { x = 4811, y = -342, z = 457 },
                        { x = -603, y = -3302, z = -2905 }
                    },
                    {
                        { x = 4559, y = 4919, z = -2642 },
                        { x = 308, y = -3942, z = 5444 }
                    }
                }
            },
            {
                name = "wf",
                level = LEVEL_WF,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = {
                    {
                        { x = 4407, y = -1492, z = 782 },
                        { x = 538, y = 4307, z = 5150 }
                    },
                    {
                        { x = 2092, y = -1492, z = 4441 },
                        { x = -4976, y = 5667, z = -3535 }
                    }
                }
            },
            {
                name = "ccm",
                level = LEVEL_CCM,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = {
                    {
                        { x = 6074, y = -2344, z = -5702 },
                        { x = 813, y = 2455, z = -5864 }
                    },
                    {
                        { x = 4240, y = -2344, z = 4557 },
                        { x = -6545, y = 855, z = 4898 }
                    },
                    {
                        { x = -5889, y = -3944, z = 696 },
                        { x = -5174, y = 3335, z = -5847 }
                    }
                }
            },
            {
                name = "jrb",
                level = LEVEL_JRB,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = {
                    {
                        { x = 1482, y = -1415, z = 963 },
                        { x = 1112, y = 1884, z = 1804 }
                    }
                }
            },
            {
                name = "lll",
                level = LEVEL_LLL,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -5277, y = 4016, z = 2523 },
                        { x = 4137, y = -1183, z = 3234 }
                    },
                    {
                        { x = 3328, y = 1216, z = -1451 },
                        { x = -5911, y = -1183, z = -3381 }
                    }
                }
            },
            {
                name = "hmc",
                level = LEVEL_HMC,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = {
                    {
                        { x = 5919, y = -537, z = 5195 },
                        { x = 2248, y = 3212, z = -3930 }
                    },
                    {
                        { x = 5387, y = 2937, z = 511 },
                        { x = -5195, y = 2582, z = 5539 }
                    }
                }
            },
            {
                name = "pss",
                level = LEVEL_PSS,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = {
                    {
                        { x = 570, y = 1291, z = -1449 },
                        { x = 23, y = -458, z = -1349 }
                    }
                }
            },
            {
                name = "bitdw",
                level = LEVEL_BITDW,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = {
                    {
                        { x = -2178, y = 4029, z = -407 },
                        { x = -453, y = 529, z = 6235 }
                    },
                    {
                        { x = 3639, y = -3810, z = 6356 },
                        { x = 4011, y = -1220, z = -2345 }
                    },
                    {
                        { x = -5620, y = 2805, z = -5933 },
                        { x = 155, y = 1229, z = -5131 }
                    }
                }
            },
            {
                name = "sa",
                level = LEVEL_SA,
                painting = get_texture_info("cg_painting"),
                area = 1,
                pipes = nil,
            },
        },
    },
    {
        -- ported to tag by jzzle and TheMan
        name = "Lug's Delightful Dioramas",
        shortName = "ldd",
        water = false,
        levels = {
            {
                name = "gh",
                level = LEVEL_CASTLE,
                painting = get_texture_info("painting_ldd_gh"),
                area = 1,
                pipes = nil,
                overrideName = "Grassy Hub"
            },
            {
                name = "sh",
                level = LEVEL_CASTLE_COURTYARD,
                painting = get_texture_info("painting_ldd_sh"),
                area = 1,
                pipes = nil,
                overrideName = "Sandy Hub"
            },
            {
                name = "lh",
                level = LEVEL_CASTLE,
                painting = get_texture_info("painting_ldd_lh"),
                area = 2,
                pipes = nil,
                overrideName = "Lava Hub"
            },
            {
                name = "asd",
                level = LEVEL_BITS,
                painting = get_texture_info("painting_ldd_asd"),
                area = 1,
                pipes = nil
            },
            {
                name = "cp",
                level = LEVEL_BOB,
                painting = get_texture_info("painting_ldd_cp"),
                area = 1,
                pipes = {
                    {
                        { x = -1967, y = 1014, z = 2300 },
                        { x = 1229, y = 2848, z = -807 }
                    }
                },
                spawnLocation = { x = -469, y = 168, z = -2134 }
            },
            {
                name = "lt",
                level = LEVEL_WF,
                painting = get_texture_info("painting_ldd_lt"),
                area = 1,
                pipes = {
                    {
                        { x = -73, y = 0, z = -24 },
                        { x = -77, y = 2640, z = -19 }
                    },
                    {
                        { x = -90, y = 4617, z = 2379 },
                        { x = -73, y = -1377, z = 2298 }
                    }
                },
                unwantedBhvs = { id_bhvExclamationBox, id_bhvBlueCoinSwitch }
            },
            {
                name = "ssf",
                level = LEVEL_JRB,
                painting = get_texture_info("painting_ldd_ssf"),
                area = 1,
                pipes = {
                    {
                        { x = -31, y = 765, z = 144 },
                        { x = -34, y = 2680, z = 156 }
                    }
                },
                spawnLocation = { x = 2267, y = 2748, z = -2147 },
                unwantedBhvs = { id_bhvBreakableBox, id_bhvBobombBuddy, id_bhvBlueCoinSwitch, id_bhvFloorSwitchHiddenObjects }
            },
            {
                name = "oo",
                level = LEVEL_CCM,
                painting = get_texture_info("painting_ldd_oo"),
                area = 1,
                pipes = {
                    {
                        { x = 2600, y = 570, z = 2026 },
                        { x = 95, y = 2445, z = 3168 }
                    }
                },
                unwantedBhvs = { id_bhvBlueCoinSwitch }
            },
            {
                name = "roat",
                level = LEVEL_BBH,
                painting = get_texture_info("painting_ldd_roat"),
                area = 1,
                pipes = {
                    {
                        { x = 901, y = 94, z = 691 },
                        { x = 1128, y = 1650, z = -1348 }
                    }
                },
                unwantedBhvs = { id_bhvBlueCoinSwitch }
            },
            {
                name = "sj",
                level = LEVEL_HMC,
                painting = get_texture_info("painting_ldd_sj"),
                area = 1,
                pipes = {
                    {
                        { x = -3082, y = 1144, z = -2836 },
                        { x = -3285, y = 2232, z = 526 }
                    },
                    {
                        { x = -30, y = -3468, z = -331 },
                        { x = -83, y = 628, z = 3606 }
                    }
                }
            },
            {
                name = "ss",
                level = LEVEL_BITFS,
                painting = get_texture_info("painting_ldd_ss"),
                area = 1,
                pipes = {
                    {
                        { x = 0, y = 2400, z = -512 },
                        { x = 0, y = 0, z = -512 },
                    }
                }
            },
            {
                name = "ls",
                level = LEVEL_LLL,
                painting = get_texture_info("painting_ldd_ls"),
                area = 1,
                pipes = {
                    {
                        { x = -4949, y = 17025, z = 397 },
                        { x = 1598, y = 6440, z = -1535 }
                    }
                }
            },
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
        -- set level data to vanilla "romhack"
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
                elseif (usingCoopDX and gServerSettings.nametags)
                or string.match(gActiveMods[i].incompatible, "nametags") then
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
        pipes = nil,
        spawnLocation = nil,
    })
    if initializedRomhacks then
        table.insert(levels, {
            name = name,
            level = level,
            painting = nil,
            area = 1,
            pipes = nil,
            spawnLocation = nil,
        })
    end
end

-- tag map api
_G.tag.add_level = function (level, name, painting, area, pipes, spawnLocation)
    -- insert level into the level reg stages
    table.insert(romhacks[3].levels, {
        name = name,
        level = level,
        painting = painting,
        area = area,
        pipes = pipes,
        spawnLocation = spawnLocation,
    })
    if initializedRomhacks then
        table.insert(levels, {
            name = name,
            level = level,
            painting = painting,
            area = area,
            pipes = pipes,
            spawnLocation = spawnLocation,
        })
    end
end

local function level_init()
    if initializedRomhacks then return end
    initializedRomhacks = true
    -- check for mods
    check_mods()
end

local function update()
    local level = levels[gGlobalSyncTable.selectedLevel]

    if level ~= nil and level.levelLoopFunc ~= nil then
        level.levelLoopFunc()
    end
end

hook_event(HOOK_ON_LEVEL_INIT, level_init)
hook_event(HOOK_UPDATE, update)
