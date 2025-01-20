items <-
[
	["Sandvich"              , "eat_plate_sandvich",      "Sandvich",         "models/items/plate.mdl"],
	["Festive Sandvich"      , "eat_plate_sandvich_xmas", "Festive Sandvich", "models/items/plate_sandwich_xmas.mdl"],
	["Robo-Sandvich"         , "eat_plate_sandvich_robo", "Robo-Sandvich",    "models/items/plate_robo_sandwich.mdl"],
	["Dalokohs Bar"          , "eat_plate_chocolate",     "Chocolate Bar",    "models/workshop/weapons/c_models/c_chocolate/plate_chocolate.mdl"],
	["Fishcake"              , "eat_plate_fishcake",      "Fishcake",         "models/workshop/weapons/c_models/c_fishcake/plate_fishcake.mdl"],
	["Buffalo Steak Sandvich", "eat_plate_steak",         "Steak",            "models/workshop/weapons/c_models/c_buffalo_steak/plate_buffalo_steak.mdl"],
	["Second Banana"         , "eat_plate_banana",        "Banana",           "models/items/banana/plate_banana.mdl"],
]
chosen_item <- RandomElement(items)

minigame <- Ware_MinigameData
({
	name           = "Eat the Plate"
	author         = "ficool2"
	description    = format("Eat the %s!", chosen_item[2])
	duration       = 9.0
	music          = "catchme"
	location       = "beach"
	custom_overlay = chosen_item[1]
	thirdperson    = true
	max_scale      = 1.5
})

pickup_sound <- "AmmoPack.Touch"

function OnPrecache()
{
	foreach (item in items) 
	{
		PrecacheOverlay("hud/tf2ware_ultimate/minigames/" + item[1])
		PrecacheModel(item[3])
	}
	
	PrecacheScriptSound(pickup_sound)
	PrecacheOverlay("hud/tf2ware_ultimate/minigames/eat_plate_fail")
}

function OnTeleport(players)
{
	Ware_TeleportPlayersRow(players,
		Ware_MinigameLocation.center + Vector(500, 0.0, 0),
		QAngle(0, -180, 0),
		1300.0,
		65.0, 65.0)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS)
	
	local offset = 128.0
	local pos = Ware_MinigameLocation.center * 1.0
	pos.y -= offset * 3.0
	pos.z -= 10.0
	
	local plates = Shuffle(clone(items))
	foreach (item in plates)
	{
		local prop = Ware_SpawnEntity("prop_dynamic",
		{
			origin     = pos
			model      = item[3]
			modelscale = 1.5
		})
		local trigger = Ware_SpawnEntity("trigger_multiple",
		{
			origin     = pos,
			spawnflags = SF_TRIGGER_ALLOW_CLIENTS,
		})
		trigger.SetSolid(SOLID_BBOX)
		trigger.SetSize(prop.GetBoundingMins() * 0.7, prop.GetBoundingMaxs() * 0.7)
		trigger.ValidateScriptScope()
		trigger.GetScriptScope().item <- item
		trigger.GetScriptScope().OnStartTouch <- OnTouchPlate
		trigger.ConnectOutput("OnStartTouch", "OnStartTouch")
		
		pos.y += offset
	}
}

function OnTouchPlate()
{
	if (activator && !activator.InCond(TF_COND_STUNNED))
	{
		local minidata = Ware_GetPlayerMiniData(activator)
		if (!("item" in minidata))
		{
			if (item == Ware_MinigameScope.chosen_item)
			{		
				EmitSoundOnClient(Ware_MinigameScope.pickup_sound, activator)
				minidata.item <- Ware_GivePlayerWeapon(activator, item[0])
			}
			else
			{
				minidata.item <- null
				Ware_ShowScreenOverlay(activator, "hud/tf2ware_ultimate/minigames/eat_plate_fail")
				activator.StunPlayer(10.0, 0.6, TF_STUN_LOSER_STATE, null)
			}
		}
	}
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (player.InCond(TF_COND_TAUNTING))
		{
			local minidata = Ware_GetPlayerMiniData(player)
			if ("item" in minidata && player.GetActiveWeapon() == minidata.item)
				Ware_PassPlayer(player, true)
		}
	}
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
	{
		player.RemoveCond(TF_COND_STUNNED)
		player.RemoveCond(TF_COND_ENERGY_BUFF)
	}
}