require objects

var
    medium_tank_hp = 180
    medium_tank_damage = 10
    medium_tank_speed_max = 80.0
    medium_tank_attack_range = 200.0

    heavy_tank_hp = 250
    heavy_tank_damage = 15
    heavy_tank_speed_max = 55.0
    heavy_tank_attack_range = 250.0

def create_ally_medium_tank(pos: float2)
    var id: int = get_id()
    ally_units[id] <- [[
        Unit() id   = id,
        pos         = pos,
        size_radius = 60.0,
        speedMax    = medium_tank_speed_max,
        hp          = medium_tank_hp,
        max_hp      = medium_tank_hp,
        damage      = medium_tank_damage,
        attack_range = medium_tank_attack_range,
        color       = 0xFF156800,
        direction   = float2(-1.0, 0.0),
        res         = [[
                        UnitResDef
                        img = "tank_ally",
                        img_dead = "tank_dead",
                        img_shoot_sprite = "shoot_sprite",
                        snd_start_move = "medium_tank_start_move",
                        snd_shoot = "medium_tank_shoot",
                        img_shoot_sprite_pos = float2(80.0, 0.0)
                    ]]
        ]]

def create_ally_heavy_tank(pos: float2)
    var id: int = get_id()
    ally_units[id] <- [[
        Unit() id   = id,
        pos         = pos,
        size_radius = 70.0,
        speedMax    = heavy_tank_speed_max,
        hp          = heavy_tank_hp,
        max_hp      = heavy_tank_hp,
        damage      = heavy_tank_damage,
        attack_range = heavy_tank_attack_range,
        color       = 0xFF156800,
        direction   = float2(-1.0, 0.0),
        res         = [[
                        UnitResDef
                        img = "heavy_tank_ally",
                        img_dead = "heavy_tank_ally",
                        img_shoot_sprite = "shoot_sprite",
                        snd_start_move = "medium_tank_start_move",
                        snd_shoot = "medium_tank_shoot",
                        img_shoot_sprite_pos = float2(110.0, 0.0)
                    ]]
        ]]

def create_enemy_medium_tank(pos: float2)
    var id: int = get_id()
    enemy_units[id] <- [[
        Unit() id   = id,
        pos         = pos,
        size_radius = 60.0,
        speedMax    = medium_tank_speed_max,
        hp          = medium_tank_hp,
        max_hp      = medium_tank_hp,
        damage      = medium_tank_damage,
        attack_range = medium_tank_attack_range,
        color       = 0xFFA00000,
        res         = [[
                        UnitResDef img = "tank_enemy",
                        img_dead = "tank_dead",
                        img_shoot_sprite = "shoot_sprite",
                        snd_start_move = "medium_tank_start_move",
                        snd_shoot = "medium_tank_shoot",
                        img_shoot_sprite_pos = float2(80.0, 0.0)
                    ]]
        ]]

def create_enemy_heavy_tank(pos: float2)
    var id: int = get_id()
    enemy_units[id] <- [[
        Unit() id   = id,
        pos         = pos,
        size_radius = 70.0,
        speedMax    = heavy_tank_speed_max,
        hp          = heavy_tank_hp,
        max_hp      = heavy_tank_hp,
        damage      = heavy_tank_damage,
        attack_range = heavy_tank_attack_range,
        color       = 0xFF156800,
        direction   = float2(1.0, 0.0),
        res         = [[
                        UnitResDef
                        img = "heavy_tank_enemy",
                        img_dead = "heavy_tank_enemy",
                        img_shoot_sprite = "shoot_sprite",
                        snd_start_move = "medium_tank_start_move",
                        snd_shoot = "medium_tank_shoot",
                        img_shoot_sprite_pos = float2(110.0, 0.0)
                    ]]
        ]]