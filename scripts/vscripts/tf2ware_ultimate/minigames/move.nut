mode <- RandomInt(0, 1)

minigame <- Ware_MinigameData
({
	name           = "Move"
	author         = "ficool2"
	description    = mode == 0 ? "Move!" : "Don't Move!"
	duration       = 4.0
	music          = "actioninsilence"
	start_pass     = true
	fail_on_death  = true
	custom_overlay = mode == 0 ? "move" : "dont_move"
})

function OnPrecache()
{
	PrecacheOverlay("hud/tf2ware_ultimate/minigames/dont_move")
	PrecacheOverlay("hud/tf2ware_ultimate/minigames/move")
}

function OnUpdate()
{
	if (Ware_GetMinigameTime() < 2.0)
		return
	
	foreach (player in Ware_MinigamePlayers)
	{
		if (!IsEntityAlive(player))
			continue
		
		if (mode == 0)
		{
			if (player.GetAbsVelocity().Length() < 75.0)
				Ware_SuicidePlayer(player)
		}
		else if (mode == 1)
		{
			if (player.GetAbsVelocity().Length() > 5.0)
				Ware_SuicidePlayer(player);	
		}				
	}
}