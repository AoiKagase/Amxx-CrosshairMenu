#pragma semicolon 1

#include <amxmodx>
#include <cstrike>

/* If you want players to save the crosshair they chose, define NVAULT_SAVE. It will use nvault.inc */
#define NVAULT_SAVE

#define PLUGIN_NAME		"Crosshair Menu"
#define PLUGIN_VERS		"1.2.6"
#define PLUGIN_AUTH		"KriTo & PurposeLess, Aoi.Kagase"

new const crosshairs[][][] = 
{
	{"Lined Point","LinedPoint_R","LinedPoint_Y","LinedPoint_G","LinedPoint_P","LinedPoint_C"},
	{"Cross","Cross_R","Cross_Y","Cross_G","Cross_P","Cross_C"},
	{"Cross-2","Cross2_R","Cross2_Y","Cross2_G","Cross2_P","Cross2_C"},
	{"Point","Point_R","Point_Y","Point_G","Point_P","Point_C"},
	{"Square","Square_R","Square_Y","Square_G","Square_P","Square_C"},
	{"Square-2","Square2_R","Square2_Y","Square2_G","Square2_P","Square2_C"},
	{"Cool Cross","CoolCross_R","CoolCross_Y","CoolCross_G","CoolCross_P","CoolCross_C"}
};

new const colors[][] = 
{
	"Red",
	"Yellow",
	"Green",
	"Purple",
	"Cyan"
};

// AmmoID, MaxAmmo
new const gAmmo[][] =
{
	{-1,  -1,-1},// #define CSW_NONE            0
	{ 9,  52, 1},// #define CSW_P228            1
	{-1,  -1,-1},// #define CSW_GLOCK           2  // Unused by game, See CSW_GLOCK18.
	{ 2,  90, 0},// #define CSW_SCOUT           3
	{12,   1, 3},// #define CSW_HEGRENADE       4
	{ 5,  32, 0},// #define CSW_XM1014          5
	{14,   1, 4},// #define CSW_C4              6
	{ 6, 100, 0},// #define CSW_MAC10           7
	{ 4,  90, 0},// #define CSW_AUG             8
	{13,   1, 3},// #define CSW_SMOKEGRENADE    9
	{10, 120, 1},// #define CSW_ELITE           10
	{ 7, 100, 1},// #define CSW_FIVESEVEN       11
	{ 6, 100, 0},// #define CSW_UMP45           12
	{ 4,  90, 0},// #define CSW_SG550           13
	{ 4,  90, 0},// #define CSW_GALIL           14
	{ 4,  90, 0},// #define CSW_FAMAS           15
	{ 6, 100, 1},// #define CSW_USP             16
	{10, 120, 1},// #define CSW_GLOCK18         17
	{ 1,  30, 0},// #define CSW_AWP             18
	{10, 120, 0},// #define CSW_MP5NAVY         19
	{ 3, 200, 0},// #define CSW_M249            20
	{ 5,  32, 0},// #define CSW_M3              21
	{ 4,  90, 0},// #define CSW_M4A1            22
	{10, 120, 0},// #define CSW_TMP             23
	{ 2,  90, 0},// #define CSW_G3SG1           24
	{11,   2, 3},// #define CSW_FLASHBANG       25
	{ 8,  35, 1},// #define CSW_DEAGLE          26
	{ 4,  90, 0},// #define CSW_SG552           27
	{ 2,  90, 0},// #define CSW_AK47            28
	{-1,  -1, 3},// #define CSW_KNIFE           29
	{ 7, 100, 0},// #define CSW_P90             30
};

enum MSGID
{
	HIDE_WEAPON,
	WEAPON_LIST,
	SET_FOV,
	CUR_WEAPON,
}

new
	g_crosshair_type[MAX_PLAYERS + 1],
	g_crosshair_color[MAX_PLAYERS + 1],
	bool:g_scope[MAX_PLAYERS + 1],
	g_msgids[MSGID];

new g_cvar_sniper = 0;

public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERS, PLUGIN_AUTH);

	register_clcmd("say /crosshair", "@clcmd_crosshair");
	register_clcmd("say /cross", "@clcmd_crosshair");

	register_event("SetFOV", "@Event_SetFOV", "be");
	register_event("CurWeapon", "@Event_CurWeapon", "be", "1=1");

	// Crosshair on Snipers. 
	bind_pcvar_num(create_cvar("crosshair_snipers", "0"), g_cvar_sniper);

	g_msgids[HIDE_WEAPON]   = get_user_msgid("HideWeapon");
	g_msgids[WEAPON_LIST]   = get_user_msgid("WeaponList");
	g_msgids[SET_FOV]   	= get_user_msgid("SetFOV");
	g_msgids[CUR_WEAPON]  	= get_user_msgid("CurWeapon");
}

@Event_SetFOV(const id) 
{
	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	if(!g_crosshair_type[id])
		return PLUGIN_CONTINUE;

	new FOV = read_data(1);

	// Default.
	if(FOV == 90)
		g_scope[id] = false;
	// AUG/SG552 Zoom.
	else if (FOV == 55)
		g_scope[id] = true;
	// Snipers. (FOV = 40, 15)
	else {
		g_scope[id] = true;
		SetMessage_HideWeapon(id, 0);
	}

	return PLUGIN_CONTINUE;
}

public plugin_precache() 
{
	for(new i = 0; i < sizeof(crosshairs); i++) 
	{
		for(new a = 1; a < sizeof(crosshairs[]); a++) 
			precache_generic(fmt("sprites/%s.txt", crosshairs[i][a]));
	}
	precache_generic("sprites/recrosshair.spr");
}

public client_putinserver(id) 
{
	client_cmd(id, "crosshair 1");
}

@clcmd_crosshair(const id) 
{
	new menu = menu_create("\yCrosshair Menu", "@clcmd_crosshair_handler");

	if(g_crosshair_type[id]) 
	{
		menu_additem(menu, fmt("Change Crosshair Type \dCurrent: %s", crosshairs[g_crosshair_type[id] - 1][0]), "1");
		menu_additem(menu, fmt("Change Crosshair Color \dCurrent: %s", colors[g_crosshair_color[id]]), "2");
		menu_additem(menu, "Default Crosshair", "3");
	}
	else 
	{
		menu_additem(menu, "Change Crosshair Type \dCurrent: Default", "1");
	}

	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

@clcmd_crosshair_handler(const id, const menu, const item) 
{
	if(item == MENU_EXIT) 
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[6];
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	new key = str_to_num(data), weapon = get_user_weapon(id);

	switch(key) 
	{
		case 1: 
		{
			g_crosshair_type[id] = Calc(g_crosshair_type[id] + 1, sizeof(crosshairs), 1);
			Change_Crosshair(id, weapon);
		}
		case 2: 
		{
			g_crosshair_color[id] = Calc(g_crosshair_color[id] + 1, sizeof(colors) - 1, 0);
			Change_Crosshair(id, weapon);
		}
		case 3: 
		{
			SetMessage_HideWeapon(id, 0);
			g_crosshair_type[id] = 0;
		}
	}

	@clcmd_crosshair(id);

	return PLUGIN_HANDLED;
}

Calc(const arg, const max, const min) 
{
	return (arg > max) ? min : arg;
}

@Event_CurWeapon(const id) 
{
	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	if(!g_crosshair_type[id])
		return PLUGIN_CONTINUE;

	new weapon = read_data(2);

	// Zoom
	if (g_scope[id]) 
	{
		// Not Snipers
		if (weapon == CSW_AUG || weapon == CSW_SG552)
			Change_Crosshair(id, weapon, 55);
	} 
	else 
	{
		Change_Crosshair(id, weapon, 90);
	}

	return PLUGIN_CONTINUE;
}

Change_Crosshair(const id, const weapon, const zoom = 90) 
{
	if (!g_cvar_sniper)
	{
		if (weapon == CSW_AWP || weapon == CSW_SCOUT || weapon == CSW_SG550 || weapon == CSW_G3SG1)
			return;
	}
	SetMessage_WeaponList(id, weapon);
	SetMessage_HideWeapon(id, 1<<6);
	SetMessage_SetFOV(id, zoom - 1);
	SetMessage_CurWeapon(id);
	SetMessage_SetFOV(id, zoom);
}

SetMessage_WeaponList(const id, const wpnId) 
{
	message_begin(MSG_ONE, g_msgids[WEAPON_LIST], .player = id); 
	{
		write_string(crosshairs[g_crosshair_type[id] - 1][g_crosshair_color[id] + 1]);
		write_byte(gAmmo[wpnId][0]);
		write_byte(gAmmo[wpnId][1]);
		write_byte(-1);
		write_byte(-1);
		write_byte(0);
		write_byte(11);
		write_byte(2);
		write_byte(0);
	}
	message_end();
}

// TMP BUG.
ResetTMP_WeaponList(const id)
{
	message_begin(MSG_ONE, g_msgids[WEAPON_LIST], .player = id); 
	{
		write_string("weapon_tmp");
		write_byte(gAmmo[CSW_TMP][0]);
		write_byte(gAmmo[CSW_TMP][1]);
		write_byte(-1);
		write_byte(-1);
		write_byte(0);
		write_byte(0);
		write_byte(CSW_TMP);
		write_byte(0);
	}
	message_end();
}

SetMessage_SetFOV(const id, const FOV) 
{
	message_begin(MSG_ONE, g_msgids[SET_FOV], .player = id); 
	{
		write_byte(FOV);
	}
	message_end();
}

SetMessage_CurWeapon(const id) 
{
	new ammo;
	new weapon = get_user_weapon(id, ammo);

	// TMP BUG
	if (weapon == CSW_TMP)
		ResetTMP_WeaponList(id);

	message_begin(MSG_ONE, g_msgids[CUR_WEAPON], .player = id); 
	{
		write_byte(1);
		write_byte(2);
		write_byte(ammo);
	}
	message_end();
}

SetMessage_HideWeapon(const id, const byte) 
{
	message_begin(MSG_ONE, g_msgids[HIDE_WEAPON], .player = id); 
	{
		write_byte(byte);
	}
	message_end();
}

#if defined NVAULT_SAVE
#include <nvault>

new g_vault;

public plugin_cfg() 
{
	g_vault = nvault_open("crosshairvault");

	if(g_vault == INVALID_HANDLE) 
		set_fail_state("Unknown nvault for crosshair");
}

public plugin_end() 
{
	nvault_close(g_vault);
}

public client_authorized(id, const authid[]) 
{
	g_crosshair_type[id] = nvault_get(g_vault, fmt("%s_type", authid));
	g_crosshair_color[id] = nvault_get(g_vault, fmt("%s_color", authid));
}

public client_disconnected(id) 
{
	new authid[MAX_AUTHID_LENGTH];
	get_user_authid(id, authid, charsmax(authid));

	if(!g_crosshair_type[id]) 
	{
		if(nvault_get(g_vault, fmt("%s_type", authid))) 
		{
			nvault_remove(g_vault, fmt("%s_type", authid));
			nvault_remove(g_vault, fmt("%s_authid", authid));
		}
		return;
	}

	new data[MAX_AUTHID_LENGTH+10];

	num_to_str(g_crosshair_type[id], data, charsmax(data));
	nvault_pset(g_vault, fmt("%s_type", authid), data);

	num_to_str(g_crosshair_color[id], data, charsmax(data));
	nvault_pset(g_vault, fmt("%s_color", authid), data);
}
#endif