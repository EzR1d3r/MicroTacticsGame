require daslib/media
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code


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

var
    screen_width = 1440
    screen_height = 800
    increment_id = 0
    ally_units: table<int; Unit>
    enemy_units: table<int; Unit>
    selection: array<int>


def shoot(var shooter: Unit; var target: Unit; dt: float)
    if shooter.attack_cooldown < shooter.attack_rate
        shooter.attack_cooldown+=dt
    else
        if target.hp > 0
            make_damage(target, shooter.damage)
            shooter.attack_cooldown = 0.0

def make_damage(var target: Unit; value: int)
    target.hp -= value

def get_id
    return ++increment_id

def create_ally_unit(pos: float2)
    var id: int = get_id()
    ally_units[id] <- [[Unit() id=id, pos=pos, size_radius=20.0, speedMax=80.0, hp=40, damage=5, color = 0xFF156800]]

def create_enemy_unit(pos: float2)
    var id: int = get_id()
    enemy_units[id] <- [[Unit() id=id, pos=pos, size_radius=20.0, speedMax=80.0, hp=40, damage=5, color = 0xFFA00000]]

def render_centered_rect(pos: float2; size: float; color: uint; offset: float = 0.0)
    rect(pos.x - size/2.0 - offset, pos.y - size/2.0 - offset, size + offset * 2.0, size + offset * 2.0, color)

def render_unit(var u: Unit)
    var color = u.hp <= 0 ? desaturate_color(u.color) : u.color
    fill_circle(u.pos.x, u.pos.y, u.size_radius, color)
    set_font_size(10)
    text_out(u.pos.x, u.pos.y, "X {u.pos.x}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+15.0, "Y {u.pos.y}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+30.0, "ID {u.id}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+45.0, "CM {length(u.command_stack)}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+60.0, "HP {u.hp}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+75.0, "CD {u.attack_cooldown}", 0xFFFFFFFF)

def render_cursor
    var mouse_pos: float2 = get_mouse_position()
    text_out(mouse_pos.x, mouse_pos.y, "X {mouse_pos.x}", 0xFFFFFFFF)
    text_out(mouse_pos.x, mouse_pos.y+15.0, "Y {mouse_pos.y}", 0xFFFFFFFF)

def select
    if get_mouse_button_down(MB_LEFT)
        var mouse_pos: float2 = get_mouse_position()
        clear(selection)
        for k, v in keys(ally_units), values(ally_units)
            if length(mouse_pos - v.pos) < 30.0
                emplace(selection, v.id)

def add_commands
    if get_mouse_button_down(MB_RIGHT)
        var mouse_pos: float2 = get_mouse_position()

        for id in selection
            if key_exists(ally_units, id)
                // for cmd in ally_units[id].command_stack
                //     cmd->done(ally_units[id])

                clear(ally_units[id].command_stack)

                for k, v in keys(enemy_units), values(enemy_units)
                    if length(mouse_pos-v.pos) < 30.0
                        push(ally_units[id].command_stack, new AttackTarget(v.id))
                        break

                if length(ally_units[id].command_stack) == 0
                    push(ally_units[id].command_stack, new MovePos(mouse_pos))


def process_commands(dt: float)
    for k, v in keys(ally_units), values(ally_units)
        var idx = 0
        while (length(v.command_stack) != 0) && (idx < length(v.command_stack))
            v.command_stack[idx]->process(v, dt)

            if v.command_stack[idx]->is_done(v)
                erase(v.command_stack, idx)
            else
                idx++

def move_all(dt: float)
    for k, v in keys(ally_units), values(ally_units)
        v.pos += v.speed * dt

def common_render
    pass

[export]
def initialize
    set_window_title("MicroTactics")
    set_resolution(screen_width, screen_height)
    create_ally_unit(float2(1000.0, 300.0))
    create_ally_unit(float2(1000.0, 400.0))
    create_ally_unit(float2(1000.0, 500.0))
    create_ally_unit(float2(1000.0, 600.0))

    create_enemy_unit(float2(200.0, 300.0))
    create_enemy_unit(float2(200.0, 400.0))
    create_enemy_unit(float2(200.0, 500.0))
    create_enemy_unit(float2(200.0, 600.0))
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    select()
    add_commands()
    process_commands(dt)
    move_all(dt)
    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    common_render()
    for k, v in keys(ally_units), values(ally_units)
        render_unit(v)

    for k, v in keys(enemy_units), values(enemy_units)
        render_unit(v)

    for id in selection
        if key_exists(ally_units, id)
            render_centered_rect(ally_units[id].pos, ally_units[id].size_radius * 2.0, 0xFF00FF00, 5.0)

    render_cursor()

    return
