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
    attack_cooldown: float = 1.0
    command_stack: array<Command?>

enum CommandType
    MOVE
    ATTACK_TARGET
    MOVE_ATTACK

class Command
    cmd_type: CommandType
    pos: float2
    target: int

    def Command(var cmd_type_: CommandType; var pos_: float2; var target_: int)
        cmd_type = cmd_type_
        pos = pos_
        target = target_

    def process(var unit: Unit)
        if cmd_type == CommandType MOVE
            if length(pos - unit.pos) <= 1.0
                unit.speed = float2(0.0, 0.0)
            else
                // var k = length(unit.speed) < unit.speedMax ? 20.0 : 1.0
                unit.speed = unit.speedMax * normalize(pos - unit.pos)

    def is_done(unit: Unit): bool
        if cmd_type == CommandType MOVE
            if length(pos - unit.pos) <= 1.0
                return true
            else
                return false

        return false

var
    screen_width = 1440
    screen_height = 800
    increment_id = 0
    ally_units: table<int; Unit>
    selection: array<int>


def get_id
    return ++increment_id

def create_unit(pos: float2)
    var id: int = get_id()
    ally_units[id] <- [[Unit id=id, pos=pos, size_radius=20.0, speedMax=80.0, hp=40, damage=5]]

def render_centered_rect(pos: float2; size: float; color: uint; offset: float = 0.0)
    rect(pos.x - size/2.0 - offset, pos.y - size/2.0 - offset, size + offset * 2.0, size + offset * 2.0, color)

def render_unit(var u: Unit)
    fill_circle(u.pos.x, u.pos.y, u.size_radius, 0xFF156800)
    set_font_size(10)
    text_out(u.pos.x, u.pos.y, "X {u.pos.x}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+15.0, "Y {u.pos.y}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+30.0, "ID {u.id}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+45.0, "CM {length(u.command_stack)}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+60.0, "HP {u.hp}", 0xFFFFFFFF)

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
                clear(ally_units[id].command_stack)
                push(ally_units[id].command_stack, new Command(CommandType MOVE, mouse_pos, -1))

def process_commands
    for k, v in keys(ally_units), values(ally_units)
        var idx = 0
        while (length(v.command_stack) != 0) && (idx < length(v.command_stack))
            v.command_stack[idx]->process(v)

            if v.command_stack[idx]->is_done(v)
                erase(v.command_stack, idx)
            else
                idx++

def move_all(dt: float)
    for k, v in keys(ally_units), values(ally_units)
        v.pos += v.speed * dt

[export]
def initialize
    set_window_title("MicroTactics")
    set_resolution(screen_width, screen_height)
    create_unit(float2(100.0, 300.0))
    create_unit(float2(200.0, 300.0))
    create_unit(float2(300.0, 300.0))
    create_unit(float2(400.0, 300.0))
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    select()
    add_commands()
    process_commands()
    move_all(dt)
    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    for k, v in keys(ally_units), values(ally_units)
        render_unit(v)

    for id in selection
        if key_exists(ally_units, id)
            render_centered_rect(ally_units[id].pos, ally_units[id].size_radius * 2.0, 0xFF00FF00, 5.0)

    render_cursor()

    return
