
undamage.settings.report_damage_change = true
undamage.settings.default_damage_factor = 0.25
undamage.settings.default_min_hp = 1

local players = {
    {
        name = "Admin",
        damage_factor = 0.1,
        min_hp = 1.0,
    },
}

for key, value in pairs(players) do
    undamage.settings.players[value.name] = value
end
