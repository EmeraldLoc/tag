
---@param o Object
function boost_particle_init(o)
	-- set basic init vars
	o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
	o.oFaceAnglePitch = 0
	o.oFaceAngleYaw = 90
	o.oFaceAngleRoll = 0
	o.oAnimState = 2
	-- set scale to be very small compared to original object size
	obj_scale(o, 0.15)
	-- make sure the object faces the camera
	obj_set_billboard(o)
end

---@param o Object
function boost_particle_loop(o)
	-- increase timer, and after it goes over 0.6 seconds, delte the object
	o.oTimer = o.oTimer + 1

	if o.oTimer >= 0.6 * 30 then
		o.activeFlags = ACTIVE_FLAG_DEACTIVATED
	end
end

id_bhvBoostParticle = hook_behavior(nil, OBJ_LIST_DEFAULT, false, boost_particle_init, boost_particle_loop)