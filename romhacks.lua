
local initializedRomhacks = false

romhacks = {
    -- don't edit these
    {
        -- name of the hack
        name = "Vanilla",
        -- level data
        levels = {
            -- name is the abbreviated level name, level is the level, painting is the image file, act is the act, area is the area, pipe stuff is for pipe positions (1 pipe per level)
            { name = "cg",       level = LEVEL_CASTLE_GROUNDS, painting = get_texture_info("cg_painting"),    act = 0, area = 1, pipes = true,  pipe1Pos = { x = -5979, y = 378, z = -1371 },  pipe2Pos = { x = 1043, y = 3174, z = -5546 } },
            { name = "bob",      level = LEVEL_BOB,            painting = get_texture_info("bob_painting"),   act = 0, area = 1, pipes = true,  pipe1Pos = { x = -4694, y = 0, z = 6699 },     pipe2Pos = { x = 5079, y = 3072, z = 655 } },
            { name = "rr",       level = LEVEL_RR,             painting = get_texture_info("rr_painting"),    act = 0, area = 1, pipes = true,  pipe1Pos = { x = -4221, y = 6451, z = -5885 }, pipe2Pos = { x = 2125, y = -1833, z = 2079 } },
            { name = "ccm",      level = LEVEL_CCM,            painting = get_texture_info("ccm_painting"),   act = 0, area = 1, pipes = true,  pipe1Pos = { x = -1352, y = 2560, z = -1824 }, pipe2Pos = { x = 5628, y = -4607, z = -28 } },
            { name = "issl",     level = LEVEL_SSL,            painting = get_texture_info("issl_painting"),  act = 0, area = 2, pipes = true,  pipe1Pos = { x = -460, y = 0, z = 4247 },      pipe2Pos = { x = 997, y = 3942, z = 1234 } },
            { name = "bitfs",    level = LEVEL_BITFS,          painting = get_texture_info("bitfs_painting"), act = 0, area = 1, pipes = true,  pipe1Pos = { x = -154, y = -2866, z = -102 },  pipe2Pos = { x = 1205, y = 5478, z = 58 } },
            { name = "ttm",      level = LEVEL_TTM,            painting = get_texture_info("ttm_painting"),   act = 0, area = 1, pipes = true,  pipe1Pos = { x = -1080, y = -4634, z = 4176 }, pipe2Pos = { x = 1031, y = 2306, z = -198 } },
            { name = "ttc",      level = LEVEL_TTC,            painting = get_texture_info("ttc_painting"),   act = 0, area = 1, pipes = true,  pipe1Pos = { x = 1361, y = -4822, z = 176 },   pipe2Pos = { x = 1594, y = 5284, z = 1565 } },
            { name = "jrb",      level = LEVEL_JRB,            painting = get_texture_info("jrb_painting"),   act = 0, area = 1, pipes = true,  pipe1Pos = { x = 3000, y = -5119, z = 2688 },  pipe2Pos = { x = -6398, y = 1126, z = 191 } },
            { name = "wdw",      level = LEVEL_WDW,            painting = get_texture_info("wdw_painting"),   act = 0, area = 1, pipes = true,  pipe1Pos = { x = 3346, y = 154, z = 2918 },    pipe2Pos = { x = -3342, y = 3584, z = -3353 } },
            { name = "twdw",     level = LEVEL_WDW,            painting = get_texture_info("twdw_painting"),  act = 0, area = 2, pipes = false, spawnLocation = { x = -773, y = -2559, z = 220 } },
            { name = "wf",       level = LEVEL_WF,             painting = get_texture_info("wf_painting"),    act = 0, area = 1, pipes = false },
            { name = "lll",      level = LEVEL_LLL,            painting = get_texture_info("lll_painting"),   act = 0, area = 1, pipes = false },
            { name = "ssl",      level = LEVEL_SSL,            painting = get_texture_info("ssl_painting"),   act = 0, area = 1, pipes = false },
            { name = "thi",      level = LEVEL_THI,            painting = get_texture_info("thi_painting"),   act = 0, area = 1, pipes = false },
            { name = "ithi",     level = LEVEL_THI,            painting = get_texture_info("ithi_painting"),  act = 0, area = 3, pipes = false },
            { name = "sl",       level = LEVEL_SL,             painting = get_texture_info("sl_painting"),    act = 0, area = 1, pipes = false },
            { name = "bowser 1", level = LEVEL_BOWSER_1,       painting = get_texture_info("bitdw_painting"), act = 0, area = 1, pipes = false },
        },
    },
    {
        name = "Unknown",
        levels = {
            { name = "cg",  level = LEVEL_CASTLE_GROUNDS, painting = nil, act = 0, area = 1, pipes = false },
            { name = "bob", level = LEVEL_BOB,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "wf",  level = LEVEL_WF,             painting = nil, act = 0, area = 1, pipes = false },
            { name = "jrb", level = LEVEL_JRB,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "ccm", level = LEVEL_CCM,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "bbh", level = LEVEL_BBH,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "lll", level = LEVEL_LLL,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "ssl", level = LEVEL_SSL,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "hmc", level = LEVEL_HMC,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "ddd", level = LEVEL_DDD,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "wdw", level = LEVEL_WDW,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "ttm", level = LEVEL_TTM,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "thi", level = LEVEL_THI,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "sl",  level = LEVEL_SL,             painting = nil, act = 0, area = 1, pipes = false },
            { name = "ttc", level = LEVEL_TTC,            painting = nil, act = 0, area = 1, pipes = false },
            { name = "rr",  level = LEVEL_RR,             painting = nil, act = 0, area = 1, pipes = false },
        },
    },
    {
        name = "Arena - Base Stages",
        levels = {} -- empty table as stages are added at the end of the file
    }
    -- romhacks go below this line
    -- work for me slave I ain't doing this.
    -- (you will be added to the credits when you add a hack,
    -- just give me your username and hex code in the pr!)
}

local function calculate_romhack_levels()
    levels = romhacks[2].levels -- unknwon levels

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

local function configure_romhacks(modIndex)
    if modIndex == nil then
        -- vanilla, set level data to vanilla "romhack"
        levels = romhacks[1].levels

        -- arena override
        if romhacks[3].levels ~= {} then
            for _, level in pairs(romhacks[3].levels) do
                table.insert(levels, level)
            end
        end

        return
    end

    local mod = gActiveMods[modIndex]

    -- see if a romhack has the name of our mod
    for i = 1, #romhacks do
        local romhack = romhacks[i]

        if romhack.name == mod.name then
            -- match, set our level data to that hack
            levels = romhack.levels

            -- check arena stages
            if romhacks[3].levels ~= {} then
                local arenaHack = romhacks[3]
                for level in pairs(arenaHack.levels) do
                    table.insert(levels, level)
                end
                return
            end

            return
        end
    end

    -- arena override
    if romhacks[3].levels ~= {} then
        local romhack = romhacks[3]
        levels = romhacks[1].levels
        for level in pairs(romhack.levels) do
            log_to_console("MONKE VANILLA")
            table.insert(levels, level)
        end
    end

    -- if we don't find a match, then it's a unknown hack, so calculate that
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
                    gGlobalSyncTable.water = true

                    -- configure romhack
                    configure_romhacks(i)

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
    -- insert level into the arena stages
    table.insert(romhacks[3].levels, {
        name = name,
        level = level,
        painting = nil,
        act = 0,
        area = 1,
        pipes = false
    })
end

local function level_init()
    if initializedRomhacks then return end
    initializedRomhacks = true
    -- check for mods
    check_mods()
end

hook_event(HOOK_ON_LEVEL_INIT, level_init)