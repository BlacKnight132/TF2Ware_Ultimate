minigame <- Ware_MinigameData();
minigame.name = "Extinguish"
minigame.description =
[
	"Get Extinguished!"
	"Extinguish a Scout!"
];
minigame.duration = 4.5;
minigame.end_delay = 0.5;
minigame.music = "fencing";
minigame.min_players = 2;
minigame.allow_damage = true;
minigame.friendly_fire = false;
minigame.start_pass = true;
minigame.fail_on_death = true;
minigame.custom_overlay = 
[
	"extinguish_scout"
	"extinguish_pyro"
];
minigame.convars =
{
	mp_teams_unbalance_limit = 0,
}

function OnStart()
{
	local pyro_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE);
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
					
		if (player.GetTeam() == pyro_team)
		{
			Ware_SetPlayerMission(player, 1);
			Ware_SetPlayerClass(player, TF_CLASS_PYRO);
			Ware_GivePlayerWeapon(player, "Backburner");
			Ware_SetPlayerTeam(player, pyro_team);
			Ware_SetPlayerAmmo(player, TF_AMMO_PRIMARY, 50);
			Ware_PassPlayer(player, false);			
		}
		else
		{
			Ware_SetPlayerMission(player, 0);
			Ware_SetPlayerClass(player, TF_CLASS_SCOUT);
			player.SetHealth(25);		
			Ware_CreateTimer(@() BurnPlayer(player, 10, Ware_GetMinigameRemainingTime()), RandomFloat(0.0, 0.2));		
			Ware_SetPlayerTeam(player, pyro_team);
		}
	}
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		if (data.player.GetPlayerClass() == TF_CLASS_PYRO)
			Ware_DisablePlayerPrimaryFire(data.player);
	}
}

function OnGameEvent_player_healonhit(params)
{
	local player = PlayerInstanceFromIndex(params.entindex);
	if (player)
		Ware_PassPlayer(player, true);
}
