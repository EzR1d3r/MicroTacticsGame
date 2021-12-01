require daslib/media

require objects
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code

var
    screen_width = 1440
    screen_height = 800
    selection: array<int>
    seed: int4

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


def process_commands_core(dt: float; var map: table<int; Unit>)
    for k, v in keys(map), values(map)
        var idx = 0
        while (length(v.command_stack) != 0) && (idx < length(v.command_stack))
            v.command_stack[idx]->process(v, dt)

            if v.command_stack[idx]->is_done(v)
                erase(v.command_stack, idx)
            else
                idx++

def move_units(dt: float; var map: table<int; Unit>)
    for unit in values(map)
        unit.pos += unit.speed * dt

def common_render
    // text_out(30.0, 30.0, "CD {0%4}", 0xFFFFFFFF)
    pass

[export]
def initialize
    set_window_title("MicroTactics")
    randomize_seed(seed)
    set_resolution(screen_width, screen_height)
    create_ally_unit(float2(1000.0, 300.0))
    create_ally_unit(float2(1000.0, 400.0))
    create_ally_unit(float2(1000.0, 500.0))
    create_ally_unit(float2(1000.0, 600.0))

    create_enemy_unit(float2(200.0, 300.0))
    create_enemy_unit(float2(200.0, 400.0))
    create_enemy_unit(float2(200.0, 500.0))
    create_enemy_unit(float2(200.0, 600.0))

    var ids <- [{for k in keys(ally_units); k}]
    for enemy in values(enemy_units)
        var i = random_int(seed) % length(ids)
        push(enemy.command_stack, new AttackTarget(ids[i]))
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    select()
    add_commands()
    process_commands_core(dt, ally_units)
    process_commands_core(dt, enemy_units)
    move_units(dt, ally_units)
    move_units(dt, enemy_units)
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
