# minetest-undamage
Dying protection and damage reduction for individual players.

## Usage
Install the mod to your `mods` dir and edit the [settings.lua](settings.lua). Set the default damage
factor and minimum HP or add individual factors and minimum HP for each player by name:

```lua

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

```

## Command
The mod also provides an `/undamage <name> <factor>` command to temporarily set the
`damage_factor` of a player on the server. This change is not persisted after server restarts.


## License
[MIT](LICENSE)