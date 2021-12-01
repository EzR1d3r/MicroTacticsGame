require daslib/media

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
    speed: float2 = float2(0.0, 0.0)
    speedMax: float
    hp: int
    damage: int
    img: string
    color: uint const
    attack_range: float const = 200.0
    attack_rate: float const = 1.0
    attack_cooldown: float = 1.0
    command_stack: array<Command?>


class Command
    def abstract process(var unit: Unit; dt: float): void
    def abstract is_done(var unit: Unit): bool
    def abstract done(var unit: Unit): void


class MovePos: Command
    pos: float2

    def MovePos(var pos_: float2)
        pos = pos_

    def override  process(var unit: Unit; dt: float)
        if is_done(unit)
            done(unit)
        else
            // var k = length(unit.speed) < unit.speedMax ? 20.0 : 1.0
            unit.speed = unit.speedMax * normalize(pos - unit.pos)

    def override is_done(unit: Unit): bool
        if length(pos - unit.pos) <= 1.0
            return true
        else
            return false

    def override done(var unit: Unit)
        unit.speed = float2(0.0, 0.0)


class AttackTarget: Command
    target_id: int

    def AttackTarget(var target_id_: int)
        target_id = target_id_

    def override process(var unit: Unit; dt: float)
        if is_done(unit)
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

    def private try_attack(var shooter: Unit; var target: Unit; dt: float)
        if (length(target.pos - shooter.pos) <= shooter.attack_range)
            shooter.speed = float2(0.0, 0.0)
            shoot(shooter, target, dt)
        else
            shooter.speed = shooter.speedMax * normalize(target.pos - shooter.pos)

def shoot(var shooter: Unit; var target: Unit; dt: float)
    if shooter.attack_cooldown < shooter.attack_rate
        shooter.attack_cooldown+=dt
    else
        if target.hp > 0
            make_damage(target, shooter.damage)
            shooter.attack_cooldown = 0.0

def make_damage(var target: Unit; value: int)
    target.hp -= value