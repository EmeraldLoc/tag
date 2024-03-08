-- code heavily taken from arena

bombCooldown = 0

define_custom_obj_fields({
    oTagBobombGlobalOwner = 'u32',
})

function is_invuln_or_intang(m)
    local invuln = ((m.action & ACT_FLAG_INVULNERABLE) ~= 0) or (m.invincTimer ~= 0)
    local intang = ((m.action & ACT_FLAG_INTANGIBLE) ~= 0)
    return invuln or intang
end

function global_index_hurts_mario_state(globalIndex, m)
    if globalIndex == gNetworkPlayers[m.playerIndex].globalIndex then
        return false
    end

    local npAttacker = network_player_from_global_index(globalIndex)
    if npAttacker == nil then return false end
    local sAttacker = gPlayerSyncTable[npAttacker.localIndex]
    local sVictim = gPlayerSyncTable[m.playerIndex]

    -- make sure eliminated or frozen dont get hit from bombs
    if sVictim.state == ELIMINATED_OR_FROZEN or sAttacker.state == ELIMINATED_OR_FROZEN then return false end

    return true
end

function mario_bobomb_use(m)
    local np = gNetworkPlayers[m.playerIndex]

    spawn_sync_object(id_bhvTagBobomb, E_MODEL_BLACK_BOBOMB, m.pos.x, m.pos.y + 50, m.pos.z,
        function (o)
            -- set starter variables
            o.oTagBobombGlobalOwner = np.globalIndex
            o.oFaceAngleYaw = m.faceAngle.y
            o.oMoveAngleYaw = m.faceAngle.y
        end)

    -- set actions depending on action flag
    if m.action & ACT_FLAG_SWIMMING ~= 0 then
        set_mario_action(m, ACT_WATER_PUNCH, 0)
    elseif m.action & ACT_FLAG_MOVING ~= 0 then
        set_mario_action(m, ACT_MOVE_PUNCHING, 0)
    elseif m.action & ACT_FLAG_AIR ~= 0 then
        set_mario_action(m, ACT_DIVE, 0)
    elseif m.action & ACT_FLAG_STATIONARY ~= 0 then
        set_mario_action(m, ACT_PUNCHING, 0)
    end
end

function bhv_tag_bobomb_init(o)
    o.oAction = 0
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_scale(o, 0.75)
    cur_obj_play_sound_2(SOUND_AIR_BOBOMB_LIT_FUSE)
    -- alright this section is kinda complex, lemme break it down, first, set the forward velocity
    o.oForwardVel = gMarioStates[o.oTagBobombGlobalOwner].forwardVel + 50
    -- here, we use math.sin instead of sins because sins cant process negative numbers
    -- math.sin takes in a radian, so, convert moveAngleYaw to a radian
    o.oVelX = math.sin(math.rad((o.oMoveAngleYaw / 65535) * 360)) * o.oForwardVel
    o.oVelY = 30
    -- same as above
    o.oVelZ = math.cos(math.rad((o.oMoveAngleYaw / 65535) * 360)) * o.oForwardVel
    o.oAnimations = gObjectAnimations.bobomb_seg8_anims_0802396C
    cur_obj_init_animation(1)
    network_init_object(o, false, nil)
end

function bhv_tag_bobomb_intersects_player(o, m, pos, radius)
    local ownerNp = network_player_from_global_index(o.oTagBobombGlobalOwner)
    local cm = m
    if m.playerIndex == 0 and ownerNp.localIndex ~= 0 then
        cm = lag_compensation_get_local_state(ownerNp)
    end

    local mPos1 = { x = cm.pos.x, y = cm.pos.y + 50,  z = cm.pos.z }
    local mPos2 = { x = cm.pos.x, y = cm.pos.y + 150, z = cm.pos.z }
    local ret = (vec3f_dist(pos, mPos1) < radius or vec3f_dist(pos, mPos2) < radius)

    return ret
end

function bhv_tag_bobomb_expode(o)
    o.oAction = 1
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_billboard(o)
    obj_scale(o, 2)
    o.oAnimState = -1
    cur_obj_play_sound_2(SOUND_GENERAL2_BOBOMB_EXPLOSION)
    set_environmental_camera_shake(SHAKE_ENV_EXPLOSION)
    o.oOpacity = 255
    obj_set_model_extended(o, E_MODEL_EXPLOSION)

    local m = gMarioStates[0]
    local np = gNetworkPlayers[0]
    local a = { x = o.oPosX, y = o.oPosY, z = o.oPosZ }
    local validAttack = global_index_hurts_mario_state(o.oTagBobombGlobalOwner, m) or np.globalIndex == o.oTagBobombGlobalOwner
    local radius = 500
    if np.globalIndex == o.oTagBobombGlobalOwner then radius = 300 end
    if validAttack and bhv_tag_bobomb_intersects_player(o, m, a, radius) and mario_health_float(m) > 0 then

        -- check up here so that if it's set to the same state as the tagger then make sure they take kb
        if gGlobalSyncTable.gamemode ~= ASSASSINS then
            if gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].state == gPlayerSyncTable[m.playerIndex].state then return end
        end

        if m.playerIndex ~= network_local_index_from_global(o.oTagBobombGlobalOwner) then
            if ((gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].state == TAGGER and gPlayerSyncTable[m.playerIndex].state == RUNNER) or gGlobalSyncTable.gamemode == ASSASSINS) and gGlobalSyncTable.roundState == ROUND_ACTIVE and gPlayerSyncTable[m.playerIndex].invincTimer <= 0 then
                if gGlobalSyncTable.gamemode == TAG then
                    gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].state = RUNNER
                    gPlayerSyncTable[m.playerIndex].state = TAGGER
                    tagged_popup(network_local_index_from_global(o.oTagBobombGlobalOwner), m.playerIndex)
                    gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags = gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags + 1
                elseif gGlobalSyncTable.gamemode == FREEZE_TAG then
                    gPlayerSyncTable[m.playerIndex].state = ELIMINATED_OR_FROZEN
                    gGlobalSyncTable.frozenIndex = network_global_index_from_local(m.playerIndex)
                    freezed_popup(network_local_index_from_global(o.oTagBobombGlobalOwner), m.playerIndex)
                    gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags = gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags + 1
                elseif gGlobalSyncTable.gamemode == INFECTION then
                    gPlayerSyncTable[m.playerIndex].state = TAGGER
                    tagged_popup(network_local_index_from_global(o.oTagBobombGlobalOwner), m.playerIndex)
                    gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags = gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags + 1
                elseif gGlobalSyncTable.gamemode == HOT_POTATO then
                    gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].state = RUNNER
                    gPlayerSyncTable[m.playerIndex].state = TAGGER
                    tagged_popup(network_local_index_from_global(o.oTagBobombGlobalOwner), m.playerIndex)
                    gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags = gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags + 1
                elseif gGlobalSyncTable.gamemode == JUGGERNAUT then
                    tagged_popup(network_local_index_from_global(o.oTagBobombGlobalOwner), m.playerIndex)
                    gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags = gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags + 1
                    gPlayerSyncTable[m.playerIndex].juggernautTags = gPlayerSyncTable[m.playerIndex].juggernautTags + 1
                elseif gGlobalSyncTable.gamemode == ASSASSINS then
                    if network_local_index_from_global(gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].assassinTarget) == 0 then
                        tagged_popup(network_local_index_from_global(o.oTagBobombGlobalOwner), m.playerIndex)
                        gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags = gPlayerSyncTable[network_local_index_from_global(o.oTagBobombGlobalOwner)].amountOfTags + 1
                        gPlayerSyncTable[m.playerIndex].state = ELIMINATED_OR_FROZEN
                     else
                        return -- make nothing happen
                    end
                end
            end
        end

        if gPlayerSyncTable[m.playerIndex].state == ELIMINATED_OR_FROZEN or gPlayerSyncTable[m.playerIndex].state == SPECTATOR then return end

        o.oDamageOrCoinValue = 3
        interact_damage(m, INTERACT_DAMAGE, o)

        -- knockback
        local ownerNp = network_player_from_global_index(o.oTagBobombGlobalOwner)
        local cm = m
        if np.globalIndex ~= o.oTagBobombGlobalOwner then
            cm = lag_compensation_get_local_state(ownerNp)
        end
        local vel = {
            x = cm.pos.x - o.oPosX,
            y = 0.5,
            z = cm.pos.z - o.oPosZ,
        }
        vec3f_normalize(vel)
        vel.y = 0.5
        vec3f_normalize(vel)
        vec3f_mul(vel, 40)

        set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
        gPlayerSyncTable[m.playerIndex].invincTimer = 10
        m.knockbackTimer = 10
        m.vel.x = vel.x
        m.vel.y = vel.y
        m.vel.z = vel.z
        m.forwardVel = 0
        m.faceAngle.y = atan2s(vel.z, vel.x) + 0x8000
    end
end

function bhv_tag_bobomb_thrown_loop(o)
    local a   = { x = o.oPosX, y = o.oPosY, z = o.oPosZ }
    local dir = { x = o.oVelX, y = o.oVelY, z = o.oVelZ }
    o.oVelY = o.oVelY - 3
    o.oFaceAnglePitch = o.oFaceAnglePitch - 0x100

    for i = 0, MAX_PLAYERS - 1 do
        local m = gMarioStates[i]
        if gNetworkPlayers[m.playerIndex].connected and global_index_hurts_mario_state(o.oTagBobombGlobalOwner, m) and not is_invuln_or_intang(m) then
            if bhv_tag_bobomb_intersects_player(o, m, a, 200) then
                bhv_tag_bobomb_expode(o)
                return
            end
        end
    end

    local info = collision_find_surface_on_ray(
            a.x, a.y, a.z,
            dir.x, dir.y, dir.z)

    local floorHeight = find_floor_height(o.oPosX, o.oPosY + 100, o.oPosZ)

    if o.oTimer > 30 * 1 or info.surface ~= nil or o.oPosY < floorHeight then
        bhv_tag_bobomb_expode(o)
        return
    else
        o.oPosX = o.oPosX + dir.x
        o.oPosY = o.oPosY + dir.y
        o.oPosZ = o.oPosZ + dir.z
    end
end

function bhv_tag_bobomb_explode_loop(o)
    if o.oTimer >= 9 then
        o.activeFlags = ACTIVE_FLAG_DEACTIVATED
    end

    o.oOpacity = o.oOpacity - 14
    cur_obj_scale((o.oTimer / 9.0 + 1.0) * 2)
    o.oAnimState = o.oAnimState + 1
end

function bhv_tag_bobomb_loop(o)
    if o.oAction == 0 then
        bhv_tag_bobomb_thrown_loop(o)
    else
        bhv_tag_bobomb_explode_loop(o)
    end
end

---@param m MarioState
local function mario_update(m)
    if gPlayerSyncTable[0].state == TAGGER and gGlobalSyncTable.modifier == MODIFIER_BOMBS and bombCooldown >= 2 * 30 and m.playerIndex == 0 then
        if m.controller.buttonDown & Y_BUTTON ~= 0 then
            bombCooldown = 0
            mario_bobomb_use(m)
        end
    end
end

local function update()
    if bombCooldown < 2 * 30 then
        bombCooldown = bombCooldown + 1
    end
end

id_bhvTagBobomb = hook_behavior(nil, OBJ_LIST_GENACTOR, true, bhv_tag_bobomb_init, bhv_tag_bobomb_loop, "tag bobomb")

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_UPDATE, update)