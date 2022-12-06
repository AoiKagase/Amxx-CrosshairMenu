#pragma semicolon 1

#include <amxmodx>

/* If you want players to save the crosshair they chose, define NVAULT_SAVE. It will use nvault.inc */
#define NVAULT_SAVE

#define PLUGIN_NAME		"Crosshair Menu"
#define PLUGIN_VERS		"1.2.5"
#define PLUGIN_AUTH		"KriTo & PurposeLess"

new const crosshairs[][][] = {
	{"Lined Point","LinedPoint_R","LinedPoint_Y","LinedPoint_G","LinedPoint_P","LinedPoint_C"},
	{"Cross","Cross_R","Cross_Y","Cross_G","Cross_P","Cross_C"},
	{"Cross-2","Cross2_R","Cross2_Y","Cross2_G","Cross2_P","Cross2_C"},
	{"Point","Point_R","Point_Y","Point_G","Point_P","Point_C"},
	{"Square","Square_R","Square_Y","Square_G","Square_P","Square_C"},
	{"Square-2","Square2_R","Square2_Y","Square2_G","Square2_P","Square2_C"},
	{"Cool Cross","CoolCross_R","CoolCross_Y","CoolCross_G","CoolCross_P","CoolCross_C"}
};

new const colors[][] = {
	"Red",
	"Yellow",
	"Green",
	"Purple",
	"Cyan"
};

new
	g_crosshair_type[MAX_PLAYERS + 1],
	g_crosshair_color[MAX_PLAYERS + 1],
	bool:g_scope[MAX_PLAYERS + 1],
	g_msgids[4];

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERS, PLUGIN_AUTH);

	register_clcmd("say /crosshair", "@clcmd_crosshair");
	register_clcmd("say /cross", "@clcmd_crosshair");

	register_event("SetFOV", "@Event_SetFOV", "be");
	register_event("CurWeapon", "@Event_CurWeapon", "be", "1=1", "2!18");

	g_msgids[0] = get_user_msgid("HideWeapon");
	g_msgids[1] = get_user_msgid("WeaponList");
	g_msgids[2] = get_user_msgid("SetFOV");
	g_msgids[3] = get_user_msgid("CurWeapon");
}

@Event_SetFOV(const id) {
	if(!g_crosshair_type[id]) {
		return;
	}

	new FOV = read_data(1);

	if(FOV == 90) {
		g_scope[id] = false;
	}
	else {
		g_scope[id] = true;
		SetMessage_HideWeapon(id, 0);
	}
}

public plugin_precache() {
	for(new i = 0; i < sizeof(crosshairs); i++) {
		for(new a = 1; a < sizeof(crosshairs[]); a++) {
			precache_generic(fmt("sprites/%s.txt", crosshairs[i][a]));
		}
	}
	precache_generic("sprites/recrosshair.spr");
}

public client_putinserver(id) {
	client_cmd(id, "crosshair 1");
}

@clcmd_crosshair(const id) {
	new menu = menu_create("\yCrosshair Menu", "@clcmd_crosshair_handler");

	if(g_crosshair_type[id]) {
		menu_additem(menu, fmt("Change Crosshair Type \dCurrent: %s", crosshairs[g_crosshair_type[id] - 1][0]), "1");
		menu_additem(menu, fmt("Change Crosshair Color \dCurrent: %s", colors[g_crosshair_color[id]]), "2");
		menu_additem(menu, "Default Crosshair", "3");
	}
	else {
		menu_additem(menu, "Change Crosshair Type \dCurrent: Default", "1");
	}

	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

@clcmd_crosshair_handler(const id, const menu, const item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6];
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	new key = str_to_num(data), weapon = get_user_weapon(id);
	switch(key) {
		case 1: {
			g_crosshair_type[id] = Calc(g_crosshair_type[id] + 1, sizeof(crosshairs), 1);
			Change_Crosshair(id, weapon);
		}
		case 2: {
			g_crosshair_color[id] = Calc(g_crosshair_color[id] + 1, sizeof(colors) - 1, 0);
			Change_Crosshair(id, weapon);
		}
		case 3: {
			SetMessage_HideWeapon(id, 0);
			g_crosshair_type[id] = 0;
		}
	}
	@clcmd_crosshair(id);
	return PLUGIN_HANDLED;
}

Calc(const arg, const max, const min) {
	return (arg > max) ? min : arg;
}

@Event_CurWeapon(const id) {
	if(!g_crosshair_type[id] || g_scope[id]) {
		return;
	}

	new weapon = read_data(2);
	Change_Crosshair(id, weapon);
}

Change_Crosshair(const id, const weapon) {
	switch(weapon) {
		case CSW_P228: SetMessage_WeaponList(id, 9, 52);
		case CSW_HEGRENADE: SetMessage_WeaponList(id, 12, 1);
		case CSW_XM1014: SetMessage_WeaponList(id, 5, 32);
		case CSW_C4: SetMessage_WeaponList(id, 14, 1);
		case CSW_MAC10: SetMessage_WeaponList(id, 6, 100);
		case CSW_AUG: SetMessage_WeaponList(id, 4, 90);
		case CSW_SMOKEGRENADE: SetMessage_WeaponList(id, 13, 1);
		case CSW_ELITE: SetMessage_WeaponList(id, 10, 120);
		case CSW_FIVESEVEN: SetMessage_WeaponList(id, 7, 100);
		case CSW_UMP45: SetMessage_WeaponList(id, 6, 100);
		case CSW_GALIL: SetMessage_WeaponList(id, 4, 90);
		case CSW_FAMAS: SetMessage_WeaponList(id, 4, 90);
		case CSW_USP: SetMessage_WeaponList(id, 6, 100);
		case CSW_GLOCK18: SetMessage_WeaponList(id, 10, 120);
		case CSW_MP5NAVY: SetMessage_WeaponList(id, 10, 120);
		case CSW_M249: SetMessage_WeaponList(id, 3, 200);
		case CSW_M3: SetMessage_WeaponList(id, 5, 32);
		case CSW_M4A1: SetMessage_WeaponList(id, 4, 90);
		case CSW_TMP: SetMessage_WeaponList(id, 10, 120);
		case CSW_FLASHBANG: SetMessage_WeaponList(id, 11, 2);
		case CSW_DEAGLE: SetMessage_WeaponList(id, 8, 35);
		case CSW_SG552: SetMessage_WeaponList(id, 4, 90);
		case CSW_AK47: SetMessage_WeaponList(id, 2, 90);
		case CSW_KNIFE: SetMessage_WeaponList(id, -1, -1);
		case CSW_P90: SetMessage_WeaponList(id, 7, 100);
		default: return;
	}

	SetMessage_HideWeapon(id, 1<<6);
	SetMessage_SetFOV(id, 89);
	SetMessage_CurWeapon(id);
	SetMessage_SetFOV(id, 90);
}

SetMessage_WeaponList(const id, const pAmmoId, const pAmmoMaxAmount) {
	message_begin(MSG_ONE, g_msgids[1], .player = id); {
		write_string(crosshairs[g_crosshair_type[id] - 1][g_crosshair_color[id] + 1]);
		write_byte(pAmmoId);
		write_byte(pAmmoMaxAmount);
		write_byte(-1);
		write_byte(-1);
		write_byte(0);
		write_byte(11);
		write_byte(2);
		write_byte(0);
	}
	message_end();
}

SetMessage_SetFOV(const id, const FOV) {
	message_begin(MSG_ONE, g_msgids[2], .player = id); {
		write_byte(FOV);
	}
	message_end();
}

SetMessage_CurWeapon(const id) {
	new ammo;
	get_user_weapon(id, ammo);

	message_begin(MSG_ONE, g_msgids[3], .player = id); {
		write_byte(1);
		write_byte(2);
		write_byte(ammo);
	}
	message_end();
}

SetMessage_HideWeapon(const id, const byte) {
	message_begin(MSG_ONE, g_msgids[0], .player = id); {
		write_byte(byte);
	}
	message_end();
}

#if defined NVAULT_SAVE
#include <nvault>

new g_vault;

public plugin_cfg() {
	g_vault = nvault_open("crosshairvault");

	if(g_vault == INVALID_HANDLE) {
		set_fail_state("Unknown nvault for crosshair");
	}
}

public plugin_end() {
	nvault_close(g_vault);
}

public client_authorized(id, const authid[]) {
	g_crosshair_type[id] = nvault_get(g_vault, fmt("%s_type", authid));
	g_crosshair_color[id] = nvault_get(g_vault, fmt("%s_color", authid));
}

public client_disconnected(id) {
	new authid[MAX_AUTHID_LENGTH];
	get_user_authid(id, authid, charsmax(authid));

	if(!g_crosshair_type[id]) {
		if(nvault_get(g_vault, fmt("%s_type", authid))) {
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