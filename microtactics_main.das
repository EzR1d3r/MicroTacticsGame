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

    def Command(cmd_type: CommandType; pos: float2; target: int)
        cmd_type = cmd_type
        pos = pos
        target = target

    def process(unit: Unit)
        if cmd_type == CommandType MOVE
            if length(unit.speed) < unit.speedMax
                pass

    def is_done(unit: Unit): bool
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
    ally_units[id] <- [[Unit id=id, pos=pos, size_radius=20.0, speedMax=40.0, hp=40, damage=5]]

def render_centered_rect(pos: float2; size: float; color: uint; offset: float = 0.0)
    rect(pos.x - size/2.0 - offset, pos.y - size/2.0 - offset, size + offset * 2.0, size + offset * 2.0, color)

def render_unit(var u: Unit)
    fill_circle(u.pos.x, u.pos.y, u.size_radius, 0xFF156800)
    set_font_size(10)
    text_out(u.pos.x, u.pos.y, "X {u.pos.x}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+15.0, "Y {u.pos.y}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+30.0, "ID {u.id}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+45.0, "CM {length(u.command_stack)}", 0xFFFFFFFF)

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
                push(ally_units[id].command_stack, new Command(CommandType MOVE, mouse_pos, -1))

def process_commands
    for k, v in keys(ally_units), values(ally_units)
        var idx = 0
        while idx < length(ally_units)
            v.command_stack[idx]->process(v)

[export]
def initialize
    set_window_title("MicroTactics")
    set_resolution(screen_width, screen_height)
    create_unit(float2(300.0, 300.0))
    create_unit(float2(600.0, 300.0))
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    select()
    add_commands()
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

    return
