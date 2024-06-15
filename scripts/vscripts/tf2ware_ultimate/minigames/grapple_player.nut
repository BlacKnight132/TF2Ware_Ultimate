minigame <- Ware_MinigameData
({
	name          = "Grapple a Player"
	author        = "ficool2"
	description   = "Grapple a player!"
	duration      = 4.0
	music         = "ridealong"
})

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, "Grappling Hook")
}

function OnUpdate()
{
	local id = ITEM_MAP["Grappling Hook"].id
	local classname = ITEM_PROJECTILE_MAP[id]
	for (local proj; proj = FindByClassname(proj, classname);)
		proj.SetTeam(proj.GetTeam() == TEAM_SPECTATOR ? TF_TEAM_RED : TEAM_SPECTATOR)
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		local target = player.GetGrapplingHookTarget()
		if (target && target.IsPlayer())
			Ware_PassPlayer(player, true)
	}
}