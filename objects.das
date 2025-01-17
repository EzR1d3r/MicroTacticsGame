require daslib/media
require resourses

var
    ally_units: table<int; Unit>
    enemy_units: table<int; Unit>
    increment_id = 0

def get_id
    return ++increment_id

struct Unit
    id: int
    pos: float2
    size_radius: float
    speed: float = 0.0
    direction: float2 = float2(1.0, 0.0)
    speedMax: float
    max_hp: int
    hp: int
    damage: int
    color: uint const
    attack_range: float const = 200.0
    attack_rate: float const = 1.0
    attack_cooldown: float = 1.0
    command_queue: array<Command?>
    res: UnitResDef

struct UnitResDef
    img: string
    img_dead: string
    img_shoot_sprite: string
    img_shoot_sprite_pos: float2
    snd_start_move: string
    snd_shoot: string

class Command
    def abstract process(var unit: Unit; dt: float): void
    def is_done(var unit: Unit): bool
        return unit.hp <= 0
    def abstract done(var unit: Unit): void


class MovePos: Command
    pos: float2

    def MovePos(var pos_: float2)
        pos = pos_

    def override  process(var unit: Unit; dt: float)
        if Command`is_done(self, unit) || is_done(unit)
            done(unit)
        else
            unit.direction = normalize(pos - unit.pos)
            unit.speed = unit.speedMax

    def override is_done(unit: Unit): bool
        if length(pos - unit.pos) <= 1.0
            return true
        else
            return false

    def override done(var unit: Unit)
        unit.speed = 0.0


class AttackTarget: Command
    target_id: int

    def AttackTarget(var target_id_: int)
        target_id = target_id_

    def override process(var unit: Unit; dt: float)
        if Command`is_done(self, unit) || is_done(unit)
            done(unit)
        else
            if key_exists(enemy_units, target_id)
                try_attack(unit, enemy_units[target_id], dt)
            elif key_exists(ally_units, target_id)
                try_attack(unit, ally_units[target_id], dt)

    def override is_done(unit: Unit): bool
        var b: bool = key_exists(ally_units, target_id) && ally_units[target_id].hp <= 0
        b ||= key_exists(enemy_units, target_id) && enemy_units[target_id].hp <= 0
        return b

    def override done(var unit: Unit)
        unit.attack_cooldown = unit.attack_rate
        unit.speed = 0.0

    def private try_attack(var shooter: Unit; var target: Unit; dt: float)
        shooter.direction = normalize(target.pos - shooter.pos)
        if (length(target.pos - shooter.pos) <= shooter.attack_range)
            shooter.speed = 0.0
            shoot(shooter, target, dt)
        else
            shooter.speed = shooter.speedMax


class AttackPassive: Command
    target_id: int

    def AttackPassive(var target_id_: int)
        target_id = target_id_

    def override process(var unit: Unit; dt: float)
        if Command`is_done(self, unit) || is_done(unit)
            done(unit)
        else
            if key_exists(enemy_units, target_id)
                try_attack(unit, enemy_units[target_id], dt)
            elif key_exists(ally_units, target_id)
                try_attack(unit, ally_units[target_id], dt)

    def override is_done(unit: Unit): bool
        if key_exists(ally_units, target_id)
            return is_dead_or_missed(unit, ally_units)
        elif key_exists(enemy_units, target_id)
            return is_dead_or_missed(unit, enemy_units)

        return true

    def private is_dead_or_missed(unit: Unit; var map: table<int; Unit>)
        return map[target_id].hp <= 0 || length(map[target_id].pos - unit.pos) > unit.attack_range

    def override done(var unit: Unit)
        unit.attack_cooldown = unit.attack_rate
        unit.speed = 0.0

    def private try_attack(var shooter: Unit; var target: Unit; dt: float)
        shooter.direction = normalize(target.pos - shooter.pos)
        if (length(target.pos - shooter.pos) <= shooter.attack_range)
            shooter.speed = 0.0
            shoot(shooter, target, dt)

def shoot(var shooter: Unit; var target: Unit; dt: float)
    if shooter.attack_cooldown < shooter.attack_rate
        shooter.attack_cooldown+=dt
    else
        if target.hp > 0
            res_play_sound(shooter.res.snd_shoot)
            make_damage(target, shooter.damage)
            shooter.attack_cooldown = 0.0

def make_damage(var target: Unit; value: int)
    target.hp -= value

def push_front(var command_queue: array<Command?>; cmd: Command?) // perhaps a crutch
    var new_queue: array<Command?>
    resize(new_queue, length(command_queue) + 1)
    new_queue[0] = cmd
    for i in range(0, length(command_queue))
        new_queue[i+1] = command_queue[i]

    return <- new_queue