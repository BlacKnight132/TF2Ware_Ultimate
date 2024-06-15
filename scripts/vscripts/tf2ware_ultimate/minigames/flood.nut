minigame <- Ware_MinigameData
({
	name           = "Flood"
	author         = "ficool2"
	description    = "Get on a Platform!"
	duration       = 4.0
	end_delay      = 0.5
	music          = "ohno"
	custom_overlay = "get_platform"
	start_pass     = true
	allow_damage   = true
	fail_on_death  = true
})

platform_index <- 0

waterfall_model <- "models/props_forest/waterfall001.mdl"

function OnPrecache()
{
	PrecacheModel(waterfall_model)
}

function OnStart()
{
	local location_name = Ware_MinigameLocation.name
	
	platform_index = RandomInt(1, 4)
	
	local platform_name = format("%s_platform_%d", location_name, platform_index)
	
	EntFire(location_name + "_flood", "Open", "", 2)
	EntFire(location_name + "_croc", "Enable", "", 2)
	EntFire(platform_name, "Close")
	
	Ware_ShowAnnotation(Entities.FindByName(null, platform_name).GetOrigin() + Vector(0, 0, 100), "GET ON ME!")
	
	// the waterfall model is really busted so have to do this in an ugly manner
	local offset = Vector(444, 256, 0)
	
	local pos = Ware_MinigameLocation.mins * 1.0
	pos.x = (Ware_MinigameLocation.maxs.x + Ware_MinigameLocation.mins.x) * 0.5
	Ware_SpawnEntity("prop_dynamic",
	{
		model          = waterfall_model
		origin         = pos - offset
		angles         = QAngle(0, -45, 0)
		disableshadows = true
	})
	local pos = Ware_MinigameLocation.maxs * 1.0
	pos.x = (Ware_MinigameLocation.maxs.x + Ware_MinigameLocation.mins.x) * 0.5
	pos.z = Ware_MinigameLocation.mins.z
	Ware_SpawnEntity("prop_dynamic",
	{
		model          = waterfall_model
		origin         = pos + offset
		angles         = QAngle(0, 135, 0)
		disableshadows = true
	})
}

function OnEnd()
{
	local location_name = Ware_MinigameLocation.name
	
	EntFire(location_name + "_flood", "Close")
	EntFire(location_name + "_croc", "Disable")
	EntFire(format("%s_platform_%d", location_name, platform_index), "Open")
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_CLUB)
	{
		local victim = params.const_entity
		if (victim.IsPlayer() && params.attacker != null && params.attacker != victim)
		{
			params.damage = 10
			
			local dir = params.attacker.EyeAngles().Forward()
			dir.z = 1.0
			dir.Norm()
			victim.SetAbsVelocity(victim.GetAbsVelocity() + dir * 500.0)
		}
	}
}