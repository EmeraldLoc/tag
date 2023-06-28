-- code heavily taken from arena

local bombCooldown = 0

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

function active_player(m)
    local np = gNetworkPlayers[m.playerIndex]
    if m.playerIndex == 0 then
        return true
    end
    if not np.connected then
        return false
    end
    return is_player_active(m)
end

function mario_bobomb_use(m)
    local np = gNetworkPlayers[m.playerIndex]

    spawn_sync_object(id_bhvTagBobomb, E_MODEL_BLACK_BOBOMB, m.pos.x, m.pos.y + 50, m.pos.z,
        function (obj)
            -- set starter variables
            obj.oTagBobombGlobalOwner = np.globalIndex
            obj.oMoveAngleYaw = m.faceAngle.y
            obj.oForwardVel = m.forwardVel + 50
        end)

    -- set actions depending on action flag
    if (m.action & ACT_FLAG_INVULNERABLE) ~= 0 or (m.action & ACT_FLAG_INTANGIBLE) ~= 0 then
        -- nothing
    elseif (m.action & ACT_FLAG_SWIMMING) ~= 0 then
        set_mario_action(m, ACT_WATER_PUNCH, 0)
    elseif (m.action & ACT_FLAG_MOVING) ~= 0 then
        set_mario_action(m, ACT_MOVE_PUNCHING, 0)
    elseif (m.action & ACT_FLAG_AIR) ~= 0 then
        set_mario_action(m, ACT_DIVE, 0)
    elseif (m.action & ACT_FLAG_STATIONARY) ~= 0 then
        set_mario_action(m, ACT_PUNCHING, 0)
    end
end

function bhv_tag_bobomb_init(obj)
    obj.oAction = 0
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_scale(obj, 0.75)
    cur_obj_play_sound_2(SOUND_AIR_BOBOMB_LIT_FUSE)
    obj.oVelX = sins(obj.oMoveAngleYaw) * obj.oForwardVel
    obj.oVelY = 30
    obj.oVelZ = coss(obj.oMoveAngleYaw) * obj.oForwardVel
    obj.oAnimations = gObjectAnimations.bobomb_seg8_anims_0802396C
    cur_obj_init_animation(1)
    network_init_object(obj, false, nil)
end

function bhv_tag_bobomb_intersects_player(obj, m, pos, radius)
    local ownerNp = network_player_from_global_index(obj.oTagBobombGlobalOwner)
    local cm = m
    if m.playerIndex == 0 and ownerNp.localIndex ~= 0 then
        cm = lag_compensation_get_local_state(ownerNp)
    end

    local mPos1 = { x = cm.pos.x, y = cm.pos.y + 50,  z = cm.pos.z }
    local mPos2 = { x = cm.pos.x, y = cm.pos.y + 150, z = cm.pos.z }
    local ret = (vec3f_dist(pos, mPos1) < radius or vec3f_dist(pos, mPos2) < radius)

    return ret
end

function bhv_tag_bobomb_expode(obj)
    obj.oAction = 1
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_billboard(obj)
    obj_scale(obj, 2)
    obj.oAnimState = -1
    cur_obj_play_sound_2(SOUND_GENERAL2_BOBOMB_EXPLOSION)
    set_environmental_camera_shake(SHAKE_ENV_EXPLOSION)
    obj.oOpacity = 255
    obj_set_model_extended(obj, E_MODEL_EXPLOSION)

    local m = gMarioStates[0]
    local np = gNetworkPlayers[0]
    local a = { x = obj.oPosX, y = obj.oPosY, z = obj.oPosZ }
    local validAttack = global_index_hurts_mario_state(obj.oTagBobombGlobalOwner, m) or np.globalIndex == obj.oTagBobombGlobalOwner
    local radius = 500
    if np.globalIndex == obj.oTagBobombGlobalOwner then radius = 300 end
    if validAttack and bhv_tag_bobomb_intersects_player(obj, m, a, radius) and mario_health_float(m) > 0 then

        if m.playerIndex ~= network_local_index_from_global(obj.oTagBobombGlobalOwner) then
            if gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].state == TAGGER and gPlayerSyncTable[m.playerIndex].state == RUNNER and gGlobalSyncTable.roundState == ROUND_ACTIVE and gPlayerSyncTable[m.playerIndex].invincTimer <= 0 then
                if gGlobalSyncTable.gamemode == TAG then
                    gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].state = RUNNER
                    gPlayerSyncTable[m.playerIndex].state = TAGGER
                    tagged_popup(network_local_index_from_global(obj.oTagBobombGlobalOwner), m.playerIndex)
                    gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].amountOfTags = gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].amountOfTags + 1
                elseif gGlobalSyncTable.gamemode == FREEZE_TAG then
                    gPlayerSyncTable[m.playerIndex].state = ELIMINATED_OR_FROZEN
                    gGlobalSyncTable.frozenIndex = network_global_index_from_local(m.playerIndex)
                    freezed_popup(network_local_index_from_global(obj.oTagBobombGlobalOwner), m.playerIndex)
                    gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].amountOfTags = gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].amountOfTags + 1
                elseif gGlobalSyncTable.gamemode == INFECTION then
                    gPlayerSyncTable[m.playerIndex].state = TAGGER
                    tagged_popup(network_local_index_from_global(obj.oTagBobombGlobalOwner), m.playerIndex)
                    gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].amountOfTags = gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].amountOfTags + 1
                elseif gGlobalSyncTable.gamemode == HOT_POTATO then
                    gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].state = RUNNER
                    gPlayerSyncTable[m.playerIndex].state = TAGGER
                    tagged_popup(network_local_index_from_global(obj.oTagBobombGlobalOwner), m.playerIndex)
                    gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].amountOfTags = gPlayerSyncTable[network_local_index_from_global(obj.oTagBobombGlobalOwner)].amountOfTags + 1
                end
            end
        end

        if gPlayerSyncTable[m.playerIndex].state == ELIMINATED_OR_FROZEN then return end
        
        obj.oDamageOrCoinValue = 3
        interact_damage(m, INTERACT_DAMAGE, obj)

        -- knockback
        local ownerNp = network_player_from_global_index(obj.oTagBobombGlobalOwner)
        local cm = m
        if np.globalIndex ~= obj.oTagBobombGlobalOwner then
            cm = lag_compensation_get_local_state(ownerNp)
        end
        local vel = {
            x = cm.pos.x - obj.oPosX,
            y = 0.5,
            z = cm.pos.z - obj.oPosZ,
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

function bhv_tag_bobomb_thrown_loop(obj)
    local a   = { x = obj.oPosX, y = obj.oPosY, z = obj.oPosZ }
    local dir = { x = obj.oVelX, y = obj.oVelY, z = obj.oVelZ }
    obj.oVelY = obj.oVelY - 3
    obj.oFaceAnglePitch = obj.oFaceAnglePitch - 0x100

    for i = 0, MAX_PLAYERS - 1 do
        local m = gMarioStates[i]
        if active_player(m) and global_index_hurts_mario_state(obj.oTagBobombGlobalOwner, m) and not is_invuln_or_intang(m) then
            if bhv_tag_bobomb_intersects_player(obj, m, a, 200) then
                bhv_tag_bobomb_expode(obj)
                return
            end
        end
    end

    local info = collision_find_surface_on_ray(
            a.x, a.y, a.z,
            dir.x, dir.y, dir.z)

    local floorHeight = find_floor_height(obj.oPosX, obj.oPosY + 100, obj.oPosZ)
            
    if obj.oTimer > 30 * 1 or info.surface ~= nil or obj.oPosY < floorHeight then
        bhv_tag_bobomb_expode(obj)
        return
    else
        obj.oPosX = obj.oPosX + dir.x
        obj.oPosY = obj.oPosY + dir.y
        obj.oPosZ = obj.oPosZ + dir.z
    end
end

function bhv_tag_bobomb_explode_loop(obj)
    if obj.oTimer >= 9 then
        obj.activeFlags = ACTIVE_FLAG_DEACTIVATED
    end

    obj.oOpacity = obj.oOpacity - 14
    cur_obj_scale((obj.oTimer / 9.0 + 1.0) * 2)
    obj.oAnimState = obj.oAnimState + 1
end

function bhv_tag_bobomb_loop(obj)
    if obj.oAction == 0 then
        bhv_tag_bobomb_thrown_loop(obj)
    else
        bhv_tag_bobomb_explode_loop(obj)
    end
end

---@param m MarioState
local function mario_update(m)
    if gPlayerSyncTable[0].state == TAGGER and gGlobalSyncTable.modifier == MODIFIER_BOMBS and bombCooldown <= 0 and m.playerIndex == 0 then
        if m.controller.buttonDown & X_BUTTON ~= 0 or m.controller.buttonDown & L_TRIG ~= 0 then
            bombCooldown = 2 * 30 -- 2 seconds
            mario_bobomb_use(m)
        end
    end
end

local function update()
    if bombCooldown > 0 then
        bombCooldown = bombCooldown - 1
    end
end

id_bhvTagBobomb = hook_behavior(nil, OBJ_LIST_GENACTOR, true, bhv_tag_bobomb_init, bhv_tag_bobomb_loop, "tag bobomb")

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_UPDATE, update)