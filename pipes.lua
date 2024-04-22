
define_custom_obj_fields({
    oPipesLevel = "u32",
    oPipesIndex = "u32",
})

---@param o Object
local function pipe_init(o)
    -- set object flags
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    -- set collision to warp pipe col
    o.collisionData = gGlobalObjectCollisionData.warp_pipe_seg3_collision_03009AC8
end

---@param o Object
local function pipe_loop(o)
    -- get nearest mario state
    local m = nearest_mario_state_to_object(o)

    -- load collision data
    load_object_collision_model()

    -- ensure our index is 0
    if m.playerIndex ~= 0 then return end

    -- check to see if the pipe should even exist
    if levels[o.oPipesLevel].level ~= gNetworkPlayers[0].currLevelNum then
        obj_mark_for_deletion(o)
        return
    end

    -- if mario is within range, and we aren't frozen, initiate the pipe
    if  dist_between_objects(o, m.marioObj) <= 50
    and (gGlobalSyncTable.gamemode ~= FREEZE_TAG
    or gPlayerSyncTable[m.playerIndex].state ~= WILDCARD_ROLE) then
        -- get pipes (includes this pipe)
        local pipes = levels[gGlobalSyncTable.selectedLevel].pipes[o.oPipesIndex]
        -- sanity check
        if pipes == nil then return end
        -- get other pipe
        local otherPipe = obj_get_first_with_behavior_id(id_bhvPipe)
        while otherPipe == o or otherPipe.oPipesIndex ~= o.oPipesIndex do
            otherPipe = obj_get_next_with_same_behavior_id(otherPipe)

            if otherPipe == nil then return end
        end

        -- teleport to the pipe and set invincibility
        m.pos.x = otherPipe.oPosX
        m.pos.y = otherPipe.oPosY + 200
        m.pos.z = otherPipe.oPosZ

        set_mario_action(m, ACT_JUMP, 0)

        m.vel.y = 60
        m.forwardVel = 15

        if m.invincTimer < 2 * 30 and pipeUse < 1 then
            gPlayerSyncTable[m.playerIndex].invincTimer = 2 * 30 -- 2 seconds
        end

        pipeUse = pipeUse + 1
        pipeTimer = 0

        reset_camera(m.area.camera)             -- reset camera
        play_sound(SOUND_MENU_EXIT_PIPE, m.pos) -- play pipe sounds
    end
end

id_bhvPipe = hook_behavior(nil, OBJ_LIST_SURFACE, false, pipe_init, pipe_loop)