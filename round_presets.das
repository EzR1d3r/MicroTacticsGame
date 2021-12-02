require daslib/media
require objects
require unit_presets
require globals

var
    rounds: table<int;function> <- {{VK_1=>@@init_round1; VK_2=>@@init_round2}}
    round_idx: int = 0

def clear_units
    clear(ally_units)
    clear(enemy_units)

def init_round1
    clear_units()
    create_ally_medium_tank(float2(1000.0, 200.0))
    create_ally_medium_tank(float2(1000.0, 300.0))
    create_ally_medium_tank(float2(1000.0, 400.0))
    create_ally_medium_tank(float2(1000.0, 500.0))

    create_enemy_medium_tank(float2(200.0, 200.0))
    create_enemy_medium_tank(float2(200.0, 300.0))
    create_enemy_medium_tank(float2(200.0, 400.0))
    create_enemy_medium_tank(float2(200.0, 500.0))
    create_enemy_medium_tank(float2(200.0, 600.0))

    var ids <- [{for k in keys(ally_units); k}]
    for enemy in values(enemy_units)
        var random_id = ids[random_int(seed) % length(ids)]
        push(enemy.command_queue, new MovePos(ally_units[random_id].pos - float2(enemy.attack_range, 0.0)))

def init_round2
    clear_units()
    create_ally_medium_tank(float2(1000.0, 500.0))
    create_ally_heavy_tank(float2(1000.0, 200.0))

    create_enemy_medium_tank(float2(200.0, 600.0))
    create_enemy_medium_tank(float2(200.0, 400.0))
    create_enemy_heavy_tank(float2(200.0, 200.0))

    var ids <- [{for k in keys(ally_units); k}]
    for enemy in values(enemy_units)
        var random_id = ids[random_int(seed) % length(ids)]
        push(enemy.command_queue, new MovePos(ally_units[random_id].pos - float2(enemy.attack_range, 0.0)))

def start_round(KEY_CODE: int)
    if key_exists(rounds, KEY_CODE)
        invoke(rounds[KEY_CODE])