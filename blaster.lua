
local gunCooldown = 0
local maxGunCooldown = 0.8 * 30

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    if gGlobalSyncTable.modifier ~= MODIFIER_BLASTER then return end
    if gPlayerSyncTable[0].state == WILDCARD_ROLE then return end
    if gPlayerSyncTable[0].state == SPECTATOR then return end

    if  m.controller.buttonPressed & binds[BIND_GUN].btn ~= 0
    and gunCooldown >= maxGunCooldown then
        spawn_sync_object(id_bhvBullet, E_MODEL_BOOST_TRAIL, m.pos.x, m.pos.y + 120, m.pos.z, function (o)
            o.oBulletOwner = network_global_index_from_local(m.playerIndex)
            obj_scale(o, 0.25)
        end)

        gunCooldown = 0
    end

    gunCooldown = gunCooldown + 1
end

local function on_render()
    if gGlobalSyncTable.modifier ~= MODIFIER_BLASTER then return end

    hud_bullet(gunCooldown, maxGunCooldown)
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_render)