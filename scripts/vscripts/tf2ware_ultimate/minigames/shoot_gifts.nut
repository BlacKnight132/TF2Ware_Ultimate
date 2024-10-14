minigame <- Ware_MinigameData
({
	name           = "Shoot 10 Gifts"
	author         = "ficool2"
	description    = "Shoot the Gift 10 times!"
	duration       = 29.9
	music          = "pumpit"
	location       = "targetrange"
	custom_overlay = "shoot_gift_10"
	convars        =
	{
		// make this easier on higher timescales or its near impossible
		phys_timescale = RemapValClamped(Ware_GetTimeScale(), 1.0, 2.0, 0.9, 0.6),	
	}
})

gift_model <- "models/tf2ware_ultimate/gift.mdl"
hit_sound  <- "Player.HitSoundBeepo"

function OnPrecache()
{
	PrecacheModel(gift_model)
	PrecacheScriptSound(hit_sound)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Sniper Rifle")

	foreach (player in Ware_MinigamePlayers)
		Ware_GetPlayerMiniData(player).points <- 0
			
	Ware_CreateTimer(@() SpawnGift(), 1.0)
}

function SpawnGift()
{
	local line = RandomElement(Ware_MinigameLocation.lines)
	local origin = Lerp(RandomFloat(0.0, 1.0), line[0], line[1])
	local angles = QAngle(0, -90, 0)
	local gift = Ware_SpawnEntity("prop_physics_override",
	{	
		model  = gift_model,
		origin = origin,
		angles = angles,
	})
	gift.AddEFlags(EFL_NO_DAMAGE_FORCES)
	gift.SetPhysVelocity(Vector(RandomFloat(-500, 500), 0, RandomFloat(1000, 1200)))
	EntityEntFire(gift, "Kill", "", RemapValClamped(Ware_GetTimeScale(), 1.0, 2.0, 1.7, 2.6))
	
	return RandomFloat(1.7, 2.1)
}

function OnTakeDamage(params)
{
	if (params.const_entity.GetClassname() == "prop_physics")
	{
		local attacker = params.attacker
		if (attacker && attacker.IsPlayer())	
		{
			local minidata = Ware_GetPlayerMiniData(attacker)
			minidata.points++
			
			EmitSoundOnClient(hit_sound, attacker)
			
			Ware_ShowText(attacker, CHANNEL_MINIGAME, "x", 0.25, "255 255 255", -1, -1)
			
			if (minidata.points >= 10)
				Ware_PassPlayer(attacker, true)
		}
		
		return false
	}
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (Ware_GetPlayerAmmo(player, TF_AMMO_PRIMARY) == 0)
			SetPropInt(player, "m_nImpulse", 101)
	}
}
