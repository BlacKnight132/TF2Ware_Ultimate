// Purpose of this plugin:
// - set sv_cheats 1 for the duration of the map
// - allow vscript to control host_timescale
// - block cheat commands and impulses on the server-side, as sv_cheats is required for host_timescale modification
// - use tournament whitelist system to block weapons/body cosmetics/taunts to prevent spawn lagspikes

#include <sourcemod>
#include <sdktools>

#define PLUGIN_NAME "TF2Ware Ultimate"
#define PLUGIN_VERSION "1.1.0"

public Plugin myinfo =
{
	name        = PLUGIN_NAME,
	author      = "ficool2",
	description = "Dedicated functionality for TF2Ware Ultimate",
	version     = PLUGIN_VERSION,
	url         = "https://github.com/ficool2/TF2Ware_Ultimate"
};

#include "loadout_whitelister.sp"

bool g_Enabled = false;

ArrayList g_CheatCommands;
ArrayList g_CheatCommandsArgs;
int g_CheatImpulses[] = { 76, 81, 82, 83, 101, 102, 103, 106, 107, 108, 195, 196, 197, 200, 202, 203 };

ConVar host_timescale;
ConVar sv_cheats;
ConVar nb_update_frequency;

//ConVar ware_version;
ConVar ware_cheats;
ConVar ware_log_cheats;

bool ShouldEnable()
{
	// TODO check how this behaves with workshop maps
	char map_name[PLATFORM_MAX_PATH];
	GetCurrentMap(map_name, sizeof(map_name));
	return StrContains(map_name, "tf2ware_ultimate", false) != -1;
}

Action ListenerCheatCommand(int client, const char[] command, int argc)
{
	if (!ware_cheats.BoolValue && client > 0)	
	{
		if (ware_log_cheats.BoolValue)
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(client, name, sizeof(name));
			LogMessage("Client '%s' attempted to execute cheat command '%s'", name, command);
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

Action ListenerCheatCommandArgs(int client, const char[] command, int argc)
{
	if (!ware_cheats.BoolValue && argc >= 1)
	{
		if (ware_log_cheats.BoolValue)
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(client, name, sizeof(name));
			LogMessage("Client '%s' attempted to execute cheat command '%s'", name, command);	
		}		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action ListenerVScript(Event event, const char[] name, bool dontBroadcast)
{
	char id[32];
	event.GetString("id", id, sizeof(id), "");
	if (StrEqual(id, "tf2ware_ultimate"))
	{
		char routine[64];
		event.GetString("routine", routine, sizeof(routine), "");
		
		if (StrEqual(routine, "timescale"))
		{
			host_timescale.SetFloat(event.GetFloat("value", 1.0), true, false);
		}
		else if (StrEqual(routine, "loadout_on"))
		{
			script_allow_loadout = true;
		}
		else if (StrEqual(routine, "loadout_off"))
		{
			script_allow_loadout = false;
		}
		else
		{
			LogMessage("Unknown VScript routine '%s'", routine);
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public void OnCheatsChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	// cheats must be enabled for host_timescale to function
	sv_cheats.SetInt(1, true, false);
}

void Enable()
{
	if (g_Enabled || !ShouldEnable())
		return;
	g_Enabled = true;
	
	LogMessage("Enabling...");
	
	GameData gamedata = new GameData("tf2ware_ultimate");
	if (gamedata)	
	{
		LoadoutWhitelister_Start(gamedata);
	}
	else
	{
		LogError("Failed to retrieve 'tf2ware_ultimate' gamedata, loadout caching will be unavailable");	
	}
	delete gamedata;

	host_timescale = FindConVar("host_timescale");
	sv_cheats = FindConVar("sv_cheats");
	nb_update_frequency = FindConVar("nb_update_frequency");
	
	host_timescale.SetFloat(1.0, true, false);
	sv_cheats.SetInt(1, true, false);
	// fix ghost jittering
	nb_update_frequency.SetFloat(0.05, false, false);
	
	HookConVarChange(sv_cheats, OnCheatsChanged);
	
	CreateConVar("ware_version", PLUGIN_VERSION, "TF2Ware Ultimate plugin version");
	ware_cheats = CreateConVar("ware_cheats", "0", "Enable sv_cheats commands");
	ware_log_cheats = CreateConVar("ware_log_cheats", "1", "Log cheat command attempts");
	
	// unused event repurposed for vscript <-> sourcemod communication
	HookEvent("player_rematch_change", ListenerVScript, EventHookMode_Pre);
	
	char name[64];
	char description[128];
	bool is_command;
	int flags;
	
	Handle hConCommandIter = FindFirstConCommand(name, sizeof(name), is_command, flags, description, sizeof(description));
	do 
	{
		if (is_command && (flags & FCVAR_CHEAT))
		{	
			AddCommandListener(ListenerCheatCommand, name);
			g_CheatCommands.PushString(name);
		}
	} 
	while ( FindNextConCommand(hConCommandIter, name, sizeof(name), is_command, flags, description, sizeof(description)));
	
	// special cases
	AddCommandListener(ListenerCheatCommand, "addcond");
	AddCommandListener(ListenerCheatCommand, "removecond");
	AddCommandListener(ListenerCheatCommand, "mp_playgesture");
	AddCommandListener(ListenerCheatCommand, "mp_playanimation");
	g_CheatCommands.PushString("addcond");	
	g_CheatCommands.PushString("removecond");	
	g_CheatCommands.PushString("mp_playgesture");	
	g_CheatCommands.PushString("mp_playanimation");	
	
	AddCommandListener(ListenerCheatCommandArgs, "kill");
	AddCommandListener(ListenerCheatCommandArgs, "explode");
	AddCommandListener(ListenerCheatCommandArgs, "fov");
	g_CheatCommandsArgs.PushString("kill");	
	g_CheatCommandsArgs.PushString("explode");	
	g_CheatCommandsArgs.PushString("fov");	
}

void Disable(bool map_unload)
{
	if (!g_Enabled)
		return;
	g_Enabled = false;
	
	LogMessage("Disabling...");
	
	LoadoutWhitelister_End(map_unload);
	
	host_timescale.SetFloat(1.0, true, false);
	sv_cheats.SetInt(0, true, false);
	nb_update_frequency.SetFloat(0.1, false, false);
	
	UnhookConVarChange(sv_cheats, OnCheatsChanged);
	
	UnhookEvent("player_rematch_change", ListenerVScript, EventHookMode_Pre);
	
	// OnPluginEnd will clear these automatically
	if (map_unload)
	{
		char name[64];
		for (int i = 0; i < g_CheatCommands.Length; i++)
		{
			g_CheatCommands.GetString(i, name, sizeof(name));	
			RemoveCommandListener(ListenerCheatCommand, name);	
		}
		
		for (int i = 0; i < g_CheatCommandsArgs.Length; i++)
		{
			g_CheatCommandsArgs.GetString(i, name, sizeof(name));
			RemoveCommandListener(ListenerCheatCommandArgs, name);	
		}		
	}
	
	g_CheatCommands.Clear();
	g_CheatCommandsArgs.Clear();

}

public void OnClientPutInServer(int client)
{
	LoadoutWhitelister_InitClient(client);
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (g_Enabled)
	{
		if (impulse > 0 && !ware_cheats.BoolValue)
		{
			for (int i = 0; i < sizeof(g_CheatImpulses); i++)
			{
				if (impulse == g_CheatImpulses[i])
				{
					if (ware_log_cheats.BoolValue)
					{
						char name[MAX_NAME_LENGTH];
						GetClientName(client, name, sizeof(name));
						LogMessage("Client '%s' attempted to execute cheat impulse '%d'", name, impulse);		
					}					
					impulse = 0;					
					break;
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public void OnPluginStart()
{
	g_CheatCommands = new ArrayList(ByteCountToCells(64));
	g_CheatCommandsArgs = new ArrayList(ByteCountToCells(64));
	Enable();
}

public void OnPluginEnd()
{
	Disable(false);
}

public void OnMapStart()
{
	Enable();
	
	LoadoutWhitelister_ReloadWhitelist();
}

public void OnMapEnd()
{
	Disable(true);
}