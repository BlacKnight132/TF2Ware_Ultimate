hale_model <- "models/tf2ware_ultimate/saxton_hale.mdl"

hale_start_sound <- "TF2Ware_Ultimate.HaleStart"
hale_jump_sound <- "TF2Ware_Ultimate.HaleJump"
hale_rage_sound <- "TF2Ware_Ultimate.HaleRage"
hale_talk_sound <- "TF2Ware_Ultimate.HaleRamble"
hale_death_sound <- "TF2Ware_Ultimate.HaleDeath"
hale_win_sound <- "TF2Ware_Ultimate.HaleWin"

special_round <- Ware_SpecialRoundData
({
	name = "Versus Saxton Hale"
	author = ["Batfoxkid", "ficool2"]  // Put OG modeler and voice actor here?
	description = "Everyone is SAXTON HALE!"
	category = "weapon"
	pitch_override = 0
})

function OnPrecache()
{
	PrecacheModel(hale_model)
	PrecacheScriptSound(hale_start_sound)
	PrecacheScriptSound(hale_jump_sound)
	PrecacheScriptSound(hale_rage_sound)
	PrecacheScriptSound(hale_talk_sound)
	PrecacheScriptSound(hale_death_sound)
	PrecacheScriptSound(hale_win_sound)
}

function ApplyHaleMelee(player)
{
	local data = Ware_GetPlayerData(player)
	local melee

	if (!data.special_melee || !data.special_melee.IsValid())
	{
		melee = CreateEntitySafe("tf_weapon_shovel")
		SetPropInt(melee, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 5)
		SetPropBool(melee, "m_AttributeManager.m_Item.m_bInitialized", true)
		melee.DispatchSpawn()
	}

	if (melee)
		Ware_EquipSpecialMelee(player, melee, null)
}

function ApplyHaleModel(player)
{
	player.SetCustomModelWithClassAnimations(hale_model)
	Ware_TogglePlayerWearables(player, false)

	// Allow hats as this model hides it's own
	for (local wearable = player.FirstMoveChild(); wearable; wearable = wearable.NextMovePeer())
	{
		if (IsWearableHat(wearable) || wearable.GetClassname() == "tf_viewmodel")
			Ware_ToggleWearable(wearable, true)
	}
}

function OnStart()
{
	foreach(player in Ware_Players)
	{
		local special = Ware_GetPlayerSpecialRoundData(player)
		special.hale_rage <- 0
		special.hale_jumptime <- 0.0
		special.hale_injump <- 0
		special.hale_rambletime <- 0.0

		if (player.IsAlive())
		{
			ApplyHaleMelee(player)
			ApplyHaleModel(player)
			Ware_UpdatePlayerVoicePitch(player)
		}
	}

	Ware_PlaySoundOnAllClients(hale_start_sound)
}

function OnPlayerConnect(player)
{
	local special = Ware_GetPlayerSpecialRoundData(player)
	special.hale_rage <- 0
	special.hale_jumptime <- 0.0
	special.hale_injump <- 0
	special.hale_rambletime <- 0.0
}

function OnPlayerInventory(player)
{
	ApplyHaleMelee(player)
	ApplyHaleModel(player)
}

function OnPlayerSpawn(player)
{
	ApplyHaleModel(player)
}

function OnUpdate()
{
	foreach (data in Ware_PlayersData)
	{
		local player = data.player
		if (player.IsAlive())
		{
			local special = Ware_GetPlayerSpecialRoundData(player)
			local rage = special.hale_rage
			local jump = special.hale_jumptime
			local text = ""
			local buttons = GetPropInt(player, "m_nButtons")
			local time = Time()

			if (special.hale_injump != 0)
			{
				if (player.GetFlags() & FL_ONGROUND)
				{
					Ware_RemovePlayerAttribute(player, "cancel falling damage")

					if (special.hale_injump == 2)
					{
						player.SetGravity(1.0)

						local origin = player.GetOrigin()

						foreach (victim in Ware_MinigamePlayers)
						{
							if (player == victim || !victim.IsAlive())
								continue

							local vector = victim.GetOrigin()
							local dist = VectorDistance(origin, vector)
							if (dist < 300.0)
							{
								local angles =  VectorAngles(vector - origin)
								local vector = angles.Forward()
								vector *= 400.0

								// Lift off ground
								if(victim.GetFlags() & FL_ONGROUND)
									vector.z = Max(vector.z, 300.0);

								victim.SetAbsVelocity(vector)
							}
						}
					}

					special.hale_injump = 0
				}
				// Start weighdown
				else if (special.hale_injump != 2 && (buttons & IN_DUCK) && player.EyeAngles().x > 60.0)
				{
					player.SetGravity(6.0)
					special.hale_injump = 2
				}
			}

			if (jump < 0.0)
			{
				// Jump is on cooldown
				jump += time
				if (jump > 0.0)
				{
					jump = 0.0
					special.hale_jumptime = jump
				}
			}
			else if ((buttons & IN_ATTACK2) || (buttons & IN_DUCK))
			{
				// Charging jump
				if (jump == 0.0)
				{
					jump = time
					special.hale_jumptime = jump
				}

				// 1.5s to full charge
				jump = (time - jump) * 66.66667
				jump = Min(jump, 100.0)
			}
			else if (jump > 0.0)
			{
				// Jump if possible
				if (player.GetMoveType() == MOVETYPE_WALK && player.EyeAngles().x < -20.0)
				{
					jump = Min(jump, 100.0)

					local velocity = player.GetAbsVelocity()

					velocity.x *= 1.0 + (jump * 0.00275)
					velocity.y *= 1.0 + (jump * 0.00275)
					velocity.z = 750.0 + (jump * 3.25)

					player.SetAbsVelocity(velocity)
					SetPropBool(player, "m_bJumping", true)

					EmitSoundEx(
					{
						sound_name = hale_jump_sound,
						volume = 1.0,
						pitch = 100 * Ware_GetPitchFactor(),
						entity = player,
						flags = SND_CHANGE_PITCH,
						filter_type = RECIPIENT_FILTER_GLOBAL
					})

					special.hale_jumptime = -(time + 5.0)
					special.hale_injump = 1

					Ware_AddPlayerAttribute(player, "cancel falling damage", 1.0, -1)
				}
				else
				{
					jump = 0.0
					special.hale_jumptime = jump
				}
			}

			if (rage >= 100)
			{
				text = "Call Medic to activate RAGE."
			}
			else
			{
				text = "RAGE meter: " + rage.tostring() + " percent!"
			}

			if (jump >= 0.0)
			{
				text += "\nJump charge: " + jump.tointeger().tostring() + " percent. Look up and stand up to use super-jump."
			}
			else
			{
				text += "\nSuper Jump will be ready again in: " + (-jump).tointeger().tostring()
			}

			Ware_ShowText(player, CHANNEL_MISC, text, 0.2, rage >= 100 ? "255 0 0" : "255 255 255", -1.0, 0.83)
		}
	}
}

function OnPlayerVoiceline(player, voiceline)
{
	if (voiceline in VCD_MAP)
	{
		local special = Ware_GetPlayerSpecialRoundData(player)

		if (VCD_MAP[voiceline].find(".Medic") == null)
		{
			if (special.hale_rambletime < Time())
			{
				special.hale_rambletime = Time() + 5.0

				EmitSoundEx(
				{
					sound_name = hale_talk_sound,
					volume = 0.8,
					pitch = 100 * Ware_GetPitchFactor(),
					entity = player,
					flags = SND_CHANGE_PITCH,
					filter_type = RECIPIENT_FILTER_GLOBAL
				})
			}
		}
		else if (special.hale_rage >= 100)
		{
			// RAGE
			special.hale_rage = 0
			special.hale_rambletime = Time() + 5.0

			EmitSoundEx(
			{
				sound_name = hale_rage_sound,
				volume = 1.0,
				pitch = 100 * Ware_GetPitchFactor(),
				entity = player,
				flags = SND_CHANGE_PITCH,
				filter_type = RECIPIENT_FILTER_GLOBAL
			})

			local origin = player.GetOrigin()
			local duration = 30.0 / Ware_MinigamePlayers.len()

			duration = Clamp(duration, 1.0, 3.0)

			player.AddCondEx(TF_COND_NOHEALINGDAMAGEBUFF, duration, null)

			foreach (victim in Ware_MinigamePlayers)
			{
				if (player == victim || !victim.IsAlive())
					continue

				local dist = VectorDistance(origin, victim.GetOrigin())
				if (dist < 400.0)
				{
					victim.StunPlayer(duration, 0.75, TF_STUN_LOSER_STATE|TF_STUN_BY_TRIGGER, null)
				}
			}
		}
	}
}

function OnCalculateScore(data)
{
	local player = data.player
	local special = Ware_GetPlayerSpecialRoundData(player)

	if (data.passed)
	{
		special.hale_rambletime = Time() + 3.0

		Ware_PlaySoundOnClient(data.player, hale_win_sound, 1.0, 100, SND_CHANGE_PITCH)
	}
	else
	{
		local rage = special.hale_rage + 20
		special.hale_rage = Min(rage, 100)
		special.hale_rambletime = Time() + 3.0

		Ware_PlaySoundOnClient(player, hale_death_sound, 1.0, 100, SND_CHANGE_PITCH)
	}
}

function OnEnd()
{
	foreach (player in Ware_Players)
	{
		player.SetCustomModel("")
		Ware_TogglePlayerWearables(player, true)
		Ware_UpdatePlayerVoicePitch(player)

		Ware_RemovePlayerAttribute(player, "cancel falling damage")
		player.SetGravity(1.0)

		Ware_DestroySpecialMelee(player)
	}
}
