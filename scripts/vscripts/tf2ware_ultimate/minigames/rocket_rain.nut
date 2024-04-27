minigame <- Ware_MinigameData
({
	name           = "Rocket Rain"
	author         = "ficool2"
	description    = "Airblast the rockets!"
	duration       = 4.0
	end_delay      = 1.0
	music          = "goodtimes"
	custom_overlay = "airblast_rockets"
	allow_damage   = true
})

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Flame Thrower")
	Ware_CreateTimer(@() SpawnRockets(), 0.8)
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
		Ware_DisablePlayerPrimaryFire(data.player)
}

function OnTakeDamage(params)
{
	if (params.const_entity.IsPlayer())
	{
		params.weapon = null
		params.attacker = World
		
		local inflictor = params.inflictor
		if (inflictor != null && inflictor.GetClassname() == "ware_projectile")
		{
			// prevents server crash because of attacker not being a player
			SetPropEntity(inflictor, "m_hLauncher", null)
		}
	}
}

function OnGameEvent_object_deflected(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (player == null)
		return
	
	local object = EntIndexToHScript(params.object_entindex)
	if (object != null && object.GetClassname() == "ware_projectile")
	{
		object.SetTeam(TEAM_SPECTATOR)
		Ware_PassPlayer(player, true)
	}
}

function OnFireRocketPre()
{
	if (activator == null)
		return false

	local down = QAngle(90, 0, 0)
	local dir = down.Forward() + down.Left() * RandomFloat(-0.4, 0.4) + down.Up() * RandomFloat(-0.4, 0.4)
	dir.Norm()
	self.SetForwardVector(dir)
	
	local pos = activator.GetOrigin()
	self.SetOrigin(activator.GetOrigin() + dir * RandomFloat(-900.0, -1300.0))
	
	return true
}

function OnFireRocketPost()
{
	if (activator != null)
	{
		local rocket = FindByClassname(null, "tf_projectile_rocket")
		if (rocket != null)
		{
			rocket.SetOwner(activator)
			rocket.SetTeam(TEAM_SPECTATOR)
			SetPropFloat(rocket, "m_flModelScale", 1.5)
			rocket.KeyValueFromString("classname", "ware_projectile")
		}
	}
}

function SpawnRockets()
{
	local spawner = Ware_SpawnEntity("tf_point_weapon_mimic", 
	{
		origin     = Ware_MinigameLocation.center
		WeaponType = 0
		SpeedMin   = 500
		SpeedMax   = 500
		Damage     = 999
		Crits      = true
		angles     = QAngle(90, 0, 0)
	})
	spawner.SetTeam(TEAM_SPECTATOR)
	SetInputHook(spawner, "FireOnce", OnFireRocketPre, OnFireRocketPost)
	
	foreach (data in Ware_MinigamePlayers)
		EntFireByHandle(spawner, "FireOnce", "", -1.0, data.player, data.player)
}