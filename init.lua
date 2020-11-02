local modname = "undamage"
local modpath = minetest.get_modpath(modname)

local S = minetest.get_translator("undamage")

-- global mod object
undamage = {}

-- mod settings
undamage.settings = {
	players = {},
	report_damage_change = false,
}

-- load user settings
assert(loadfile(modpath .. "/settings.lua"))(modpath) --Load the settings

undamage.debug = function (...)
	local text = "DEBUG:"
	for i,v in ipairs({...}) do
		text = text .. " " .. v
	end
	minetest.chat_send_all(text)
end

-- initializes the players undamage config if not present and
-- returns the players undamage config
undamage.get_player_config = function (name)
	local cfg = undamage.settings.players[name]
	if cfg == nil then
		cfg = {
			name = name,
			damage_factor = undamage.settings.default_damage_factor,
			min_hp = undamage.settings.default_min_hp,
		}
		undamage.settings.players[name] = cfg
	end
	return cfg
end

undamage.adjust_damage = function (player, hp_change, reason)
	if hp_change >= 0 then
		return hp_change
	end

	local name = player:get_player_name()
	local cfg = undamage.get_player_config(name)
	if cfg.damage_factor == 1.0 and cfg.min_hp == 0 then
		return hp_change
	end

	local ud_change = hp_change
	local hp = player:get_hp()
	if hp <= cfg.min_hp then
		-- add some HP to allow for receiving damage next time
		ud_change = 1
	else
		ud_change = math.min(-1, hp_change * cfg.damage_factor)
	end

	if undamage.settings.report_damage_change and ud_change ~= hp_change then
		local dmg_new  = S("@1 HP", ud_change)
		local dmg_orig = S("@1 HP", hp_change)
		local msg = S("Player @1: damage of @2 reduced to @3", name, dmg_orig, dmg_new)
		if (hp <= cfg.min_hp) then
			msg = msg .. S(", protected from dying")
		end
		minetest.chat_send_player(name, msg)
	end
    return ud_change
end

undamage.report_player_status = function(player)
	local name = player:get_player_name()
	local cfg = undamage.get_player_config(name)

	if cfg.damage_factor == 1.0 and cfg.min_hp == 0 then
		return
	end

	minetest.chat_send_player(name, S(
		"Hey @1, you are undamaged with damage_factor=@2 and min_hp=@3.",
		name,
		cfg.damage_factor,
		cfg.min_hp
	))
end

undamage.chat_command = {
	params = "<name> <factor>",
	description = "Set receiving damage factor of <name> to <factor>",
	privs = {bring = true},
	func = function(name, param)
		local found, _, target, factor = param:find("^([^%s]+)%s+(%d+.?%d*)$")
		if found == nil then
			minetest.chat_send_player(name, "Invalid arguments: " .. param)
			return
		end
		local player = minetest.get_player_by_name(target)
		if player == nil then
			minetest.chat_send_player(name, "Invalid player name: " .. target)
			return
		end

		local cfg = undamage.settings.players[target]
		if cfg == nil then
			cfg = {
				name = target,
				damage_factor = 1.0,
				min_hp = 1,
			}
		end
		cfg.damage_factor = factor
		undamage.settings.players[target] = cfg
		undamage.report_player_status(player)
	end
}

minetest.register_on_player_hpchange(undamage.adjust_damage, true)
minetest.register_on_joinplayer(undamage.report_player_status)
minetest.register_chatcommand("undamage", undamage.chat_command)
