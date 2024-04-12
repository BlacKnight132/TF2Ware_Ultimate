minigame <- Ware_MinigameData();
minigame.name = "Ghostbusters";
minigame.description = 
[
	"Survive the Ghostbusters!"
	"Vacuum all Ghosts!"
	"Kill the Ghostbusters!"
];	
minigame.duration = 79.5;
minigame.end_delay = 0.5;
minigame.music = "ghostbusters";
minigame.location = "manor";
minigame.custom_overlay = 
[
	"ghostbusters_survive"
	"ghostbusters_vacuum"
	"ghostbusters_kill"
];
minigame.min_players = 5;
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.convars =
{
	mp_teams_unbalance_limit = 0,
}

local ghost_model = "models/props_halloween/ghost.mdl";
local vo_ghost_sound = "TF2Ware_Ultimate.GhostLaugh";
PrecacheModel(ghost_model);
PrecacheScriptSound(vo_ghost_sound);

MISSION_GHOST <- 0;
MISSION_MEDIC <- 1;
MISSION_HEAVY <- 2;

local spies = [];
local medics = [];
local heavies = [];

local spy_spawns = 
[
	[ Vector(-3464, 263, -198),   -90  ],
	[ Vector(-2594, -542, -198),  127  ],
	[ Vector(-2957, -84, 218),    -155 ],
	[ Vector(-230, 631, -198),    49   ],
	[ Vector(-2149, 1309, -390),  51   ],
	[ Vector(-987, 674, 74),      -161 ],
	[ Vector(-1256, 32, -198),    176  ],
	[ Vector(-161, 876, 74),      -134 ],
	[ Vector(-3618, -254, -198),  -37  ],
	[ Vector(-3023, 681, 74),     73   ],
	[ Vector(-2598, -669, -198),  142  ],
	[ Vector(-3420, -261, -198),  -49  ],
	[ Vector(-515, -529, -198),   170  ],
	[ Vector(-1569, -428, -158),  -15  ],
	[ Vector(-2155, -114, -198),  93   ],
	[ Vector(-2171, -697, -198),  -180 ],
	[ Vector(-2168, 178, -390),   179, ],
	[ Vector(-1999, 856, -390),   3    ],
	[ Vector(-955, -534, -198),   -53  ],
	[ Vector(-184, 587, 67),      -141 ],
];

local kill_icon;

local medic_powerplay_vo =
[
	"scenes/player/medic/low/607.vcd",
	"scenes/player/medic/low/608.vcd",
	"scenes/player/medic/low/1232.vcd",
	"scenes/player/medic/low/4649.vcd",
	"scenes/player/medic/low/6814.vcd",
	"scenes/player/medic/low/6815.vcd",
];

local spy_powerplay_vo =
[
	"scenes/player/spy/low/4705.vcd",
];

function OnStart()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (heavies.find(player) != null)
		{
			Ware_SetPlayerMission(player, MISSION_HEAVY);	
			Ware_SetPlayerClass(player, TF_CLASS_HEAVYWEAPONS);
			Ware_StripPlayer(player, false);
			Ware_SetPlayerTeam(player, TF_TEAM_RED);
			SetEntityColor(player, 0, 255, 0, 255);
			SetPropFloat(player, "m_flMaxspeed", 320.0);
		}
		else if (medics.find(player) != null)
		{
			Ware_SetPlayerMission(player, MISSION_MEDIC);	
			Ware_SetPlayerClass(player, TF_CLASS_MEDIC);
			Ware_StripPlayer(player, false);
			Ware_SetPlayerTeam(player, TF_TEAM_BLUE);
			Ware_GivePlayerWeapon(player, "Medi Gun", { "ubercharge rate penalty" : 0.0 });
			Ware_PassPlayer(player, false);
			SetPropFloat(player, "m_flMaxspeed", 300.0);
			
			local minidata = Ware_GetPlayerMiniData(player);
			minidata.last_target <- null;
			minidata.vo_timer <- 0.0;
		}
		else
		{
			Ware_SetPlayerMission(player, MISSION_GHOST);	
			Ware_SetPlayerClass(player, TF_CLASS_SPY);
			Ware_StripPlayer(player, false);
			Ware_SetPlayerTeam(player, TF_TEAM_BLUE);
			Ware_GivePlayerWeapon(player, "Fists", { "no_attack" : 1 });
			player.SetCustomModel(ghost_model);
			Ware_AddPlayerAttribute(player, "reduced_healing_from_medics", 0.0, -1);
			TogglePlayerWearables(player, false);
			SetPropInt(player, "m_nRenderMode", kRenderTransColor);			
			SetEntityColor(player, 255, 255, 255, 60);
			SetPropFloat(player, "m_flMaxspeed", 280.0);
			player.SetForcedTauntCam(1);
			
			local minidata = Ware_GetPlayerMiniData(player);
			minidata.vo_timer <- 0.0;			
			minidata.drain_tick <- 0;
		}
		
		SetPropBool(player, "m_bGlowEnabled", true);
	}
	
	kill_icon = Ware_SpawnEntity("handle_dummy", { classname = "merasmus_zap" } ); // kill icon
	
	local vo_spies = clone(spies);
	local vo_count = Min(12, vo_spies.len());
	for (local i = 0; i < vo_count; i++)
		Ware_CreateTimer(@() PlayVocalization(RemoveRandomElement(vo_spies), vo_ghost_sound), RandomFloat(4.0, 8.0));	
}

function OnTeleport(players)
{
	local medic_count = Clamp(ceil(players.len() / 3.5).tointeger(), 2, 7);
	local heavy_count = Min(Clamp(players.len() / 4, 1, 3), players.len());
	
	medic_count = Min(medic_count, players.len());
	for (local i = 0; i < medic_count; i++)
		medics.append(RemoveRandomElement(players));

	heavy_count = Min(heavy_count, players.len());
	for (local i = 0; i < heavy_count; i++)
		heavies.append(RemoveRandomElement(players));	
		
	spies = clone(players);
	
	Ware_TeleportPlayersRow(medics,
		Ware_MinigameLocation.lobby,
		QAngle(0, -90, 0),
		400.0,
		-60.0, 60.0);
	
	Ware_TeleportPlayersRow(heavies,
		Ware_MinigameLocation.center + Vector(-296, 528, 0),
		QAngle(0, -180, 0),
		400.0,
		-60.0, 60.0);	
	
	Shuffle(spy_spawns);
	local spawn_len = spy_spawns.len();
	local spawn_idx = 0;
	foreach (player in spies)
	{
		local spawn = spy_spawns[spawn_idx];
		player.Teleport(
			true, Ware_MinigameLocation.center + spawn[0], 
			true, QAngle(0, spawn[1], 0), 
			true, Vector());
		spawn_idx = (spawn_idx + 1) % spawn_len;
	}
}

function TogglePlayerPowerplay(player, play_vo, toggle)
{
	if (player.IsEFlagSet(EFL_USER) == toggle)
		return;
	
	if (toggle)
	{
		local player_class = player.GetPlayerClass();
		if (play_vo)
		{
			if (player_class == TF_CLASS_MEDIC)
				player.PlayScene(RandomElement(medic_powerplay_vo), 0.0);
			else if (player_class == TF_CLASS_SPY)
				player.PlayScene(RandomElement(spy_powerplay_vo) 0.0);
		}
		
		if (player_class == TF_CLASS_SPY)
		{
			BurnPlayer(player, 1.0, 5.0, function() 
			{
				if (activator)
					activator.AddCond(TF_COND_INVULNERABLE);
			});
		}
		else
		{
			player.AddCond(TF_COND_INVULNERABLE);	
		}
		
		SetPropFloat(player, "m_flMaxspeed", 500.0);
	}
	else
	{
		player.RemoveCond(TF_COND_INVULNERABLE);
		player.RemoveCond(TF_COND_BURNING);
		if (player.GetPlayerClass() == TF_CLASS_MEDIC)
			SetPropFloat(player, "m_flMaxspeed", 300.0);
		else
			SetPropFloat(player, "m_flMaxspeed", 280.0);
	}
	
	if (toggle)
		player.AddEFlags(EFL_USER);
	else
		player.RemoveEFlags(EFL_USER);
}

function OnUpdate()
{
	foreach (medic in medics)
	{
		if (medic.IsValid() && IsEntityAlive(medic))
		{
			local weapon = medic.GetActiveWeapon();
			if (weapon && weapon.GetClassname() == "tf_weapon_medigun")
			{
				local medic_minidata = Ware_GetPlayerMiniData(medic);
				local target = GetPropEntity(weapon, "m_hHealingTarget");
				if (target)
				{
					if (target.GetPlayerClass() == TF_CLASS_SPY)
					{
						local spy_minidata = Ware_GetPlayerMiniData(target);											
						if (++spy_minidata.drain_tick % 3 == 0)		
						{
							local health = target.GetHealth();
							health -= 1;											
							if (health > 0)
							{
								target.SetHealth(health);
							}
							else
							{
								target.RemoveCond(TF_COND_INVULNERABLE);
								target.TakeDamage(100, DMG_BULLET|DMG_CRIT, medic);
							}
						}
						
						local time = Time();
						
						local play_medic_vo = false;
						if (medic_minidata.vo_timer < time)
						{
							play_medic_vo = true;
							medic_minidata.vo_timer = time + 5.0;
						}
						
						local play_spy_vo = false;
						if (spy_minidata.vo_timer < time)
						{
							play_spy_vo = true;
							spy_minidata.vo_timer = time + 4.0;
						}						
							
						TogglePlayerPowerplay(medic, play_medic_vo, true);
						TogglePlayerPowerplay(target, play_spy_vo, true);						
						SetPropFloat(weapon, "m_flChargeLevel", 1.0);
					}
					
					medic_minidata.last_target = target;
				}
				else
				{
					local last_target = medic_minidata.last_target;
					if (last_target && last_target.IsValid())
						TogglePlayerPowerplay(last_target, true, false);		
				
					TogglePlayerPowerplay(medic, true, false);
					SetPropFloat(weapon, "m_flChargeLevel", 0.0);

					medic_minidata.last_target = null;
				}
			}
		}
	}
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_BURN)
		return false;
	
	local victim = params.const_entity;
	local attacker = params.attacker;
	if (attacker && attacker.IsPlayer())
	{
		local victim_class = victim.GetPlayerClass();
		local attacker_class = attacker.GetPlayerClass();
		
		if (victim_class == TF_CLASS_SPY && attacker_class == TF_CLASS_HEAVYWEAPONS)
			return false;	
		if (victim_class == TF_CLASS_SPY && attacker_class == TF_CLASS_MEDIC)
			params.inflictor = kill_icon;
		else if (victim_class == TF_CLASS_MEDIC && attacker_class == TF_CLASS_HEAVYWEAPONS)
			params.damage = 125.0;
		else if (victim_class == TF_CLASS_HEAVYWEAPONS)
			return false;
	}
}

function OnPlayerDeath(params)
{
	local victim = GetPlayerFromUserID(params.userid);
	if (victim && victim.GetPlayerClass() == TF_CLASS_SPY)
	{
		Ware_PassPlayer(victim, false);
		DispatchParticleEffect("ghost_appearation", victim.GetOrigin(), Vector());
		victim.SetCustomModel("");
		CreateTimer(@() KillPlayerRagdoll(victim), 0.0);
	}
}

function OnEnd()
{
	local alive_spies  = spies.filter(@(i, player) player.IsValid() && IsEntityAlive(player));
	local alive_medics = medics.filter(@(i, player) player.IsValid() && IsEntityAlive(player));
	
	if (alive_spies.len() == 0 && alive_medics.len() > 0)
	{
		foreach (player in heavies)
		{
			if (player.IsValid())
				Ware_PassPlayer(player, false);
		}
			
		foreach (player in alive_medics)
			Ware_PassPlayer(player, true);
			
		Ware_ChatPrint(null, "{color}All ghosts are dead... The Ghostbusters win!", TF_COLOR_DEFAULT);
	}
	else if (alive_medics.len() == 0)
	{
		Ware_ChatPrint(null, "{color}All ghostbusters are dead... The Undead win!", TF_COLOR_DEFAULT);
	}
	else
	{
		local word = alive_spies.len() > 1 ? "ghosts" : "ghost";
		Ware_ChatPrint(null, "{color}There is {int} {str} left standing... The Undead win!", TF_COLOR_DEFAULT, alive_spies.len(), word);
	}
}

function OnCleanup()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		
		TogglePlayerPowerplay(player, false, false);		
		SetPropBool(player, "m_bGlowEnabled", false);		
		
		if (data.mission == MISSION_GHOST)
		{
			player.SetCustomModel("");
			SetPropInt(player, "m_nRenderMode", kRenderNormal);
			SetEntityColor(player, 255, 255, 255, 255);
			SetPropInt(player, "m_iFOV", 0);			
			TogglePlayerWearables(player, true);	
			player.SetForcedTauntCam(0);
		}
		else if (data.mission == MISSION_HEAVY)
		{
			SetEntityColor(player, 255, 255, 255, 255);
		}
	}
}

function CheckEnd()
{
	local alive_spies  = spies.filter(@(i, player) player.IsValid() && IsEntityAlive(player));
	local alive_medics = medics.filter(@(i, player) player.IsValid() && IsEntityAlive(player));
	return alive_spies.len() == 0 || alive_medics.len() == 0;
}