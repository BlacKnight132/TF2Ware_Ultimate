// by ficool2 and pokemonpasta

// Settings for a special round
class Ware_SpecialRoundData
{
	function constructor(table = null)
	{
		min_players      = 0
		convars          = {}
		reverse_text     = false
		allow_damage     = false
		force_collisions = false
		boss_count       = 1
		
		if (table)
		{
			foreach (key, value in table)
				this[key] = value
		}
	}
	
	// == Mandatory settings ==
	
	// Visual name
	name             		 = null
	// Who made this?
	// Unused for now but might be used for credits in the future
	author           		 = null
	// Description shown in chat
	description      		 = null
	
	// == Optional settings ==
	// Minimum amount of players needed to start, default is 0
	min_players      		 = null
	// Table of convars to set for this special round
	// Reverted to previous values after special round ends	
	convars          		 = null
	// Reverse all text! Default is false
	reverse_text     		 = null
	// Always allow damage, including between minigames, default is false
	allow_damage     		 = null
	// Always enable collisions between players, default is false
	force_collisions 		 = null
	// Amount of bosses to play, default is 1
	boss_count       		 = null
	
	// == Callbacks == 
	// TODO: document these
	cb_get_boss_threshold    = null
	cb_get_minigame          = null
	cb_get_overlay2          = null
	cb_get_player_roll       = null
	cb_on_calculate_scores   = null
	cb_on_player_spawn       = null
	cb_on_player_inventory   = null
	cb_on_begin_intermission = null
	cb_on_minigame_start     = null
	cb_on_minigame_end       = null
	cb_on_speedup            = null
	cb_on_take_damage        = null
	cb_on_update             = null
}

// Rolls and starts a special round
function Ware_BeginSpecialRound()
{
	Ware_BeginSpecialRoundInternal()
}

// Ends the current special round if present
function Ware_EndSpecialRound()
{
	Ware_EndSpecialRoundInternal()
}