
-- yipee
enemies = {
    amp = { name = "Amp", bhvs = { id_bhvCirclingAmp, id_bhvHomingAmp }, active = true, default = true },
    boo = { name = "Boo", bhvs = { id_bhvBoo, id_bhvBooInCastle, id_bhvBalconyBigBoo, id_bhvGhostHuntBigBoo, id_bhvMerryGoRoundBigBoo }, active = false, default = false },
    bobomb = { name = "Bob-omb", bhvs = { id_bhvBobomb }, active = true, default = true },
    bookend = { name = "Bookend", bhvs = { id_bhvFlyingBookend, id_bhvBookendSpawn }, active = true, default = true },
    bulletBill = { name = "Bullet Bill", bhvs = { id_bhvBulletBill, id_bhvBulletBillCannon }, active = true, default = true },
    bully = { name = "Bully", bhvs = { id_bhvBigBully, id_bhvBigBullyWithMinions, id_bhvSmallBully, id_bhvBigChillBully, id_bhvSmallChillBully }, active = true, default = true },
    bubba = { name = "Bubba", bhvs = { id_bhvBubba }, active = false, default = false },
    chuckya = { name = "Chuckya", bhvs = { id_bhvChuckya }, active = true, default = true },
    clam = { name = "Clam", bhvs = { id_bhvClamShell }, active = true, default = true },
    flyGuy = { name = "Fly Guy", bhvs = { id_bhvFlyGuy }, active = true, default = true },
    goomba = { name = "Goomba", bhvs = { id_bhvGoomba, id_bhvGoombaTripletSpawner }, active = true, default = true },
    heaveHo = { name = "Heave-Ho", bhvs = { id_bhvHeaveHo, id_bhvHeaveHoThrowMario }, active = false, default = false },
    kingBobomb = { name = "King Bobomb", bhvs = { id_bhvKingBobomb }, active = false, default = false },
    kingWhomp = { name = "King Whomp", bhvs = { id_bhvWhompKingBoss }, active = false, default = false },
    klepto = { name = "Klepto", bhvs = { id_bhvKlepto }, active = true, default = true },
    koopaTroopa = { name = "Koopa Troopa", bhvs = { id_bhvKoopa }, active = true, default = true },
    lakitu = { name = "Lakitu", bhvs = { id_bhvEnemyLakitu }, active = true, default = true },
    madPiano = { name = "Mad Piano", bhvs = { id_bhvMadPiano }, active = true, default = true },
    mantaRay = { name = "Manta Ray", bhvs = { id_bhvMantaRay }, active = true, default = true },
    moneybags = { name = "Moneybags", bhvs = { id_bhvMoneybag, id_bhvMoneybagHidden }, active = false, default = false },
    mrBlizzard = { name = "Mr. Blizzard", bhvs = { id_bhvMrBlizzard, id_bhvMrBlizzardSnowball }, active = true, default = true },
    mrI = { name = "Mr. I", bhvs = { id_bhvMrI, id_bhvMrIBody, id_bhvMrIBlueCoin }, active = true, default = true },
    piranhaPlant = { name = "Piranha Plant", bhvs = { id_bhvPiranhaPlant, id_bhvFirePiranhaPlant }, active = true, default = true },
    pokey = { name = "Pokey", bhvs = { id_bhvPokey, id_bhvPokeyBodyPart }, active = true, default = true },
    scuttlebug = { name = "Scuttlebug", bhvs = { id_bhvScuttlebug, id_bhvScuttlebugSpawn }, active = true, default = true },
    skeeter = { name = "Skeeter", bhvs = { id_bhvSkeeter, id_bhvSkeeterWave }, active = true, default = true },
    snufit = { name = "Snufit", bhvs = { id_bhvSnufit, id_bhvScuttlebugSpawn }, active = true, default = true },
    spindel = { name = "Spindel", bhvs = { id_bhvSpindel }, active = true, default = true },
    spindrift = { name = "Spindrift", bhvs = { id_bhvSpindrift }, active = true, default = true },
    spiny = { name = "Spiny", bhvs = { id_bhvSpiny }, active = true, default = true },
    sushi = { name = "Sushi", bhvs = { id_bhvSushiShark }, active = true, default = true }, -- tasty
    swoop = { name = "Swoop", bhvs = { id_bhvSwoop }, active = true, default = true },
    thwomp = { name = "Thwmop", bhvs = { id_bhvThwomp, id_bhvThwomp2, id_bhvGrindel, id_bhvHorizontalGrindel }, active = true, default = true },
    toxBox = { name = "Tox Box", bhvs = { id_bhvToxBox }, active = true, default = true },
    whomp = { name = "Whomp", bhvs = { id_bhvSmallWhomp }, active = false, default = false },
}

local function mario_update()
    -- loop thru all enemies and delete if they're not active
    for _, enemy in pairs(enemies) do
        if not enemy.active then
            for _, bhvId in pairs(enemy.bhvs) do
                obj_mark_for_deletion(obj_get_first_with_behavior_id(bhvId))
            end
        end
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)