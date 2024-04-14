minigame <- Ware_MinigameData();
minigame.name = "Wild West";
minigame.description = "Get Ready to Shoot..."
minigame.duration = 180.0;
minigame.music = "staredown";
minigame.location = "dirtsquare";
minigame.min_players = 2;
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.end_delay = 3.0; 
minigame.custom_overlay = "";

mexican_standoff <- false;
standoff_count <- 0;
game_over <- false;
shootout <- false;
sound_standoff <- "tf2ware_ultimate/mexican_standoff.mp3";
PrecacheSound(sound_standoff);

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY, null);
	Ware_SetGlobalAttribute("no_attack", 1, -1);
	Ware_SetGlobalAttribute("no_jump", 1, -1);
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.AddFlag(FL_ATCONTROLS);
		Ware_GetPlayerMiniData(player).holding_attack <- 0;
	}
}

function OnTeleport(players)
{
	PlacePlayers(players);
}

function PlacePlayers(players)
{
	EntFire("tf_ragdoll", "Kill");
	
	Shuffle(players);
	
	if (players.len() <= 3)
	{
		standoff_count = players.len();
		mexican_standoff = true;
		
		Ware_TeleportPlayersCircle(players, Ware_MinigameLocation.center, 135.0);

		foreach (player in players)
			Ware_GetPlayerMiniData(player).opponent <- null;

		Ware_PlayMinigameSound(null, Ware_Minigame.music, SND_STOP);
		PlaySoundOnAllClients(sound_standoff);
		
		Ware_CreateTimer(@() GiveGuns(), 2.0);
		return;
	}
	else
	{
		mexican_standoff = false;
	}
	
	local x_offset = 0.0;
	local flip = 0;
	local first = true;
	local spacing = 64.0;
	local y_spacing = 150.0;
	
	local last_player;
	
	foreach (player in players)
	{
		if (flip % 4 == 0)
		{
			x_offset *= -1.0;
			if (first)
				first = false;
			else
				x_offset += x_offset < 0.0 ? spacing : -spacing;
		}
	
		if (flip & 1)
		{
			Ware_GetPlayerMiniData(player).opponent <- last_player;
			Ware_GetPlayerMiniData(last_player).opponent <- player;
			
			player.Teleport(
				true, Ware_MinigameLocation.center + Vector(x_offset, -y_spacing, 0),
				true, QAngle(0, 90, 0),
				true, Vector());
				
			x_offset += x_offset < 0.0 ? -spacing : spacing;
		}
		else
		{
			player.Teleport(
				true, Ware_MinigameLocation.center + Vector(x_offset, y_spacing, 0),
				true, QAngle(0, 270, 0),
				true, Vector());	
		}
		
		last_player = player;
	
		flip++;
	}
	
	if (flip & 1)	
		Ware_GetPlayerMiniData(last_player).opponent <- null;
	
	Ware_CreateTimer(@() GiveGuns(), 2.0);
}

function GiveGuns()
{
	local clip = mexican_standoff ? 6 : 1;
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;	
		Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/minigames/wildwest_ready");	
	
		if (IsEntityAlive(player) 
			&& (mexican_standoff || Ware_GetPlayerMiniData(player).opponent != null))
		{
			Ware_SetPlayerAmmo(player, TF_AMMO_SECONDARY, 0);
			local weapon = Ware_GivePlayerWeapon(player, "L'Etranger");
			weapon.SetClip1(clip);
		}
	}
	
	local delay;
	if (mexican_standoff)
		delay = RandomFloat(20.0, 45.0);
	else
		delay = RandomFloat(3.0, 10.0);
	
	Ware_CreateTimer(@() StartShootout(), delay);
}

function StartShootout()
{
	shootout = true;
	
	if (mexican_standoff)
		PlaySoundOnAllClients(sound_standoff, 0.2, 100, SND_CHANGE_VOL);
	else
		Ware_PlayMinigameSound(null, Ware_Minigame.music, SND_CHANGE_VOL, 0.2);
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		
		Ware_ShowScreenOverlay(player, "hud/tf2ware_ultimate/minigames/wildwest_shoot");
			
		if (IsEntityAlive(player))
			player.RemoveCustomAttribute("no_attack");
		
		if (player.IsFakeClient())
		{
			Ware_CreateTimer(@() SetPropInt(player, "m_afButtonForced", IN_ATTACK), RandomFloat(0.4, 1.0));
			Ware_CreateTimer(@() SetPropInt(player, "m_afButtonForced", 0), 1.0);
		}
	}	
	
	local delay = mexican_standoff ? 3.5 : 2.5;
	Ware_CreateTimer(@() StopShootout(), delay);
}

function StopShootout()
{
	shootout = false;
	
	local final_players = [];
	local alive_players = Ware_GetAlivePlayers();
	if (mexican_standoff && alive_players.len() > standoff_count - 1)
	{
		foreach (data in alive_players)
		{
			local player = data.player;
			if (IsEntityAlive(player))
			{
				Ware_ChatPrint(player, "{color} You have all been disqualified for surviving. Cowards!", TF_COLOR_DEFAULT);
				player.TakeDamageCustom(player, player, null, Vector(), Vector(), 1000.0, DMG_GENERIC, TF_DMG_CUSTOM_SUICIDE);			
			}
		}
	}
	else
	{
		foreach (data in Ware_MinigamePlayers)
		{
			local player = data.player;
			if (IsEntityAlive(player))
			{
				local opponent = Ware_GetPlayerMiniData(player).opponent;
				if (opponent)
				{
					if (opponent.IsValid())
					{
						if (IsEntityAlive(opponent))
						{
							player.TakeDamageCustom(player, player, null, Vector(), Vector(), 1000.0, DMG_GENERIC, TF_DMG_CUSTOM_SUICIDE);
							opponent.TakeDamageCustom(player, player, null, Vector(), Vector(), 1000.0, DMG_GENERIC, TF_DMG_CUSTOM_SUICIDE);
							local msg = "{color}You and your opponent have been disqualified for missing!";
							Ware_ChatPrint(player, msg, TF_COLOR_DEFAULT);
							Ware_ChatPrint(opponent, msg, TF_COLOR_DEFAULT);
							continue;
						}
					}
					else
					{
						Ware_ChatPrint(player, "{color}Your opponent had disconnected so you have been spared...", TF_COLOR_DEFAULT);
					}
				}
				else if (!mexican_standoff)
				{
					Ware_ChatPrint(player, "{color}You had no opponent so you have been spared...", TF_COLOR_DEFAULT);
				}
				
				Ware_StripPlayer(player, true);
				Ware_ShowScreenOverlay(player, null);
				player.AddCustomAttribute("no_attack", 1, -1);				
				final_players.append(player);
			}
		}
	}
	
	local count = final_players.len();
	if (count > 1)
	{
		if (count > 3)
			Ware_PlayMinigameSound(null, Ware_Minigame.music, SND_CHANGE_VOL, 1.0);	
		
		PlacePlayers(final_players);
	}
	else
	{
		if (count == 1)
			Ware_ChatPrint(null, "{player}{color} wins as the best gunslinger!", final_players[0], TF_COLOR_DEFAULT);
		else
			Ware_ChatPrint(null, "{color}Nobody won!", TF_COLOR_DEFAULT);
		
		game_over = true;
	}
}

function OnTakeDamage(params)
{
	local victim = params.const_entity;
	if (victim.IsPlayer())
	{
		local attacker = params.attacker;
		if (attacker && attacker != victim && attacker.IsPlayer())
		{
			if (!mexican_standoff)
			{
				local opponent = Ware_GetPlayerMiniData(attacker).opponent;
				if (opponent != victim)
					return false;
			}
			
			params.damage *= 5.0;
			
			if (GetPropInt(victim, "m_LastHitGroup") == HITGROUP_HEAD)
			{
				params.damage *= 3.0;
				params.damage_type = params.damage_type | DMG_CRIT;
				params.damage_stats = TF_DMG_CUSTOM_HEADSHOT;
			}
		}
	}
}

function OnUpdate()
{
	local time = Time();
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		local minidata = Ware_GetPlayerMiniData(player);
		
		// block holding attack before shootout
		local buttons = GetPropInt(player, "m_nButtons");
		if (!shootout)
		{
			if (buttons & IN_ATTACK)
			{
				SetPropFloat(player, "m_Shared.m_flStealthNoAttackExpire", time + 0.2);
				minidata.holding_attack = true;
			}
			else
			{
				minidata.holding_attack = false;
			}
		}
		else if (shootout)
		{
			if (minidata.holding_attack && (buttons & IN_ATTACK))
				SetPropFloat(player, "m_Shared.m_flStealthNoAttackExpire", time + 0.2);
			else
				minidata.holding_attack = false;
		}
	}
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.RemoveFlag(FL_ATCONTROLS);
		SetPropInt(player, "m_afButtonForced", 0);
	}
}

function CheckEnd()
{
	 return game_over;
}