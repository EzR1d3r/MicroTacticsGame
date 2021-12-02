require daslib/media
require objects
require resourses
require render
require globals
require round_presets
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code


def select
    if get_mouse_button_down(MB_LEFT)
        var mouse_pos: float2 = get_mouse_position()
        clear(selection)
        for unit in values(ally_units)
            if length(mouse_pos - unit.pos) < unit.size_radius && unit.hp > 0
                emplace(selection, unit.id)

    var i = length(selection) - 1
    while i >= 0 && length(selection) > 0
        var id = selection[i]
        if ally_units[id].hp <= 0
            erase(selection, i)
        i--

def add_commands
    if get_mouse_button_down(MB_RIGHT)
        var mouse_pos: float2 = get_mouse_position()

        for id in selection
            if key_exists(ally_units, id)
                // for cmd in ally_units[id].command_queue
                //     cmd->done(ally_units[id])

                clear(ally_units[id].command_queue)

                for enemy in values(enemy_units)
                    if (length(mouse_pos-enemy.pos) < enemy.size_radius / 1.5) && enemy.hp > 0
                        push(ally_units[id].command_queue, new AttackTarget(enemy.id))
                        break

                if length(ally_units[id].command_queue) == 0
                    push(ally_units[id].command_queue, new MovePos(mouse_pos))

                res_play_sound(ally_units[id].res.snd_start_move)

def process_commands_core(dt: float; var map: table<int; Unit>)
    for unit in values(map)
        if length(unit.command_queue) != 0
            unit.command_queue[0]->process(unit, dt)

            if unit.command_queue[0]->is_done(unit)
                unit.command_queue[0]->done(unit)
                erase(unit.command_queue, 0)

def move_units(dt: float; var map: table<int; Unit>)
    for unit in values(map)
        unit.pos += unit.speed* unit.direction * dt

def calc_collision_core(var unit: Unit; obstacle: Unit)
    if unit.speed > 0.0
        var vec = obstacle.pos - unit.pos
        let angle_cos = dot(normalize(vec), normalize(unit.direction)) / length(normalize(vec)) * length(normalize(unit.direction))
        let angle = abs(acos(angle_cos))
        if (length(vec) < 1.25 * (unit.size_radius + obstacle.size_radius)) && angle < PI / 5.0
            vec = normalize(vec)
            let rotation = PI / 4.0
            vec.x = cos(rotation) * vec.x - sin(rotation) * vec.y
            vec.y = sin(rotation) * vec.x + cos(rotation) * vec.y

            vec = (2.0 * obstacle.size_radius) * vec + unit.pos

            unit.command_queue <- push_front(unit.command_queue, new MovePos(vec))

def calc_collision
    //calc ally
    for unit in values(ally_units)
        for obstacle in values(ally_units)
            if unit.id != obstacle.id
                calc_collision_core(unit, obstacle)

        for obstacle in values(enemy_units)
            calc_collision_core(unit, obstacle)

    //calc enemy
    for unit in values(enemy_units)
        for obstacle in values(enemy_units)
            if unit.id != obstacle.id
                calc_collision_core(unit, obstacle)

        for obstacle in values(ally_units)
            calc_collision_core(unit, obstacle)

def AI
    var ids <- [{for k in keys(ally_units); k}]
    for enemy in values(enemy_units)
        if length(enemy.command_queue) == 0
            var i = random_int(seed) % length(ids)
            push(enemy.command_queue, new AttackPassive(ids[i]))

    ids <- [{for k in keys(enemy_units); k}]
    for ally in values(ally_units)
        if length(ally.command_queue) == 0
            var i = random_int(seed) % length(ids)
            push(ally.command_queue, new AttackPassive(ids[i]))

[export]
def initialize
    clear_units()
    set_window_title("MicroTactics")
    randomize_seed(seed)
    set_resolution(screen_width, screen_height)
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()

    if get_key_press(VK_SPACE)
        game_is_active = !game_is_active

    if !game_is_active
        if get_key_press(VK_1)
            start_round(VK_1)
        elif get_key_press(VK_2)
            start_round(VK_2)
        elif get_key_press(VK_3)
            start_round(VK_3)
        elif get_key_press(VK_C)
            calc_collision_on = !calc_collision_on

    if !game_is_active
        return

    select()
    add_commands()
    process_commands_core(dt, ally_units)
    process_commands_core(dt, enemy_units)
    if calc_collision_on
        calc_collision()
    move_units(dt, ally_units)
    move_units(dt, enemy_units)
    AI()
    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    enable_alpha_blend()
    common_render()
    for unit in values(ally_units)
        render_unit(unit)
        // render_debug_info(unit)

    for unit in values(enemy_units)
        render_unit(unit)
        // render_debug_info(unit)

    for id in selection
        if key_exists(ally_units, id)
            render_centered_rect(ally_units[id].pos, ally_units[id].size_radius * 2.0, 0xFF00FF00, 5.0)

    render_cursor()

    if !game_is_active
        main_menu()

    return
