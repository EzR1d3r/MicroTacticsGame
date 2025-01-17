require daslib/media
require resourses
require objects
require globals
require round_presets

var
    image_scale_k: float const = 1.2
    sprite_scale_k: float const = 0.3
    shoot_time: float const = 0.2

def common_render
    images["background"] |> draw_image(0.0, 0.0)

def render_centered_rect(pos: float2; size: float; color: uint; offset: float = 0.0)
    rect(pos.x - size/2.0 - offset, pos.y - size/2.0 - offset, size + offset * 2.0, size + offset * 2.0, color)

def render_unit_core(var u: Unit; var img: Image; color: uint = 0xFFFFFFFF)
    fill_circle(u.pos.x, u.pos.y, 15.0, u.color)

    var x_size = image_scale_k * float(img.width) * u.size_radius / float(img.height)
    var y_size = image_scale_k * float(img.height) * u.size_radius / float(img.height)

    //calc rotation
    var res_vec = normalize(u.direction)
    var rotation = res_vec.y >= 0.0 ? acos(res_vec.x) : 2.0 * PI - acos(res_vec.x)

    //draw img
    img |> draw_image_transformed(
        u.pos.x, u.pos.y, float4(0.0, 0.0, float(img.width), float(img.height)), color, float2(x_size, y_size), rotation
        )

    if u.attack_cooldown < shoot_time && u.hp > 0 && u.speed < u.speedMax // TODO, check only attack_cooldown
        render_shoot(u, images[u.res.img_shoot_sprite])

    if u.hp > 0
        var hp_k = float(u.hp) / float(u.max_hp)
        fill_rect(u.pos.x - u.size_radius, u.pos.y - u.size_radius - 10.0, u.size_radius * 2.0, 8.0, 0xB7FF0202)
        fill_rect(u.pos.x - u.size_radius, u.pos.y - u.size_radius - 10.0, hp_k * u.size_radius * 2.0, 8.0, 0xFF35FF02)

def render_shoot(u: Unit; var img: Image)
    var x_size = sprite_scale_k * float(img.width) * u.size_radius / float(img.height)
    var y_size = sprite_scale_k * float(img.height) * u.size_radius / float(img.height)

    //calc rotation
    var res_vec = normalize(u.direction)
    var rotation = res_vec.y >= 0.0 ? acos(res_vec.x) : 2.0 * PI - acos(res_vec.x)

    var sp = float2(
        u.pos.x + cos(rotation) * u.res.img_shoot_sprite_pos.x - sin(rotation) * u.res.img_shoot_sprite_pos.y,
        u.pos.y + sin(rotation) * u.res.img_shoot_sprite_pos.x + cos(rotation) * u.res.img_shoot_sprite_pos.y
        )

    //draw img
    img |> draw_image_transformed(
        sp.x, sp.y,
        float4(0.0, 0.0, float(img.width), float(img.height)), 0xFFFFFFFF, float2(x_size, y_size), rotation
        )

def render_unit(var u: Unit)
    if u.hp > 0
        render_unit_core(u, images[u.res.img])
    else
        render_unit_core(u, images[u.res.img_dead], 0xFFA35207)

def render_debug_info(var u: Unit)
    set_font_size(10)
    text_out(u.pos.x, u.pos.y, "X {u.pos.x}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+15.0, "Y {u.pos.y}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+30.0, "ID {u.id}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+45.0, "CM {length(u.command_queue)}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+60.0, "HP {u.hp}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+75.0, "CD {u.attack_cooldown}", 0xFFFFFFFF)
    text_out(u.pos.x, u.pos.y+90.0, "SP {u.speed}", 0xFFFFFFFF)

def render_cursor
    var mouse_pos: float2 = get_mouse_position()
    // text_out(mouse_pos.x, mouse_pos.y, "X {mouse_pos.x}", 0xFFFFFFFF)
    // text_out(mouse_pos.x, mouse_pos.y+15.0, "Y {mouse_pos.y}", 0xFFFFFFFF)

def main_menu
    fill_rect(0.0, 0.0, float(screen_width), float(screen_height), 0x9D000000)

    set_font_size(80)
    var text = "Micro Tactics Game"
    var size = get_text_size(text)
    text_out(screen_width/2 - int(size.x/2.0), screen_height/4, text, 0xFFFFFFFF)

    set_font_size(30)
    text = "Defeat the superior enemy with limited forces."
    size = get_text_size(text)
    text_out(screen_width/2 - int(size.x/2.0), screen_height/4 + 100, text, 0xFFFFFFFF)

    set_font_size(30)
    text = "PRESS [SPACE] TO PAUSE OR [1-{length(rounds)}] TO CHOOSE ROUND"
    size = get_text_size(text)
    text_out(screen_width/2 - int(size.x/2.0), screen_height/4 + 200, text, 0xFFFFFFFF)

    set_font_size(30)
    text = "PRESS [C] TO SWITCH COLLISION MODE(experimental) [{calc_collision_on ? "ON" : "OFF"}]"
    size = get_text_size(text)
    text_out(screen_width/2 - int(size.x/2.0), screen_height/4 + 250, text, 0xFFFFFFFF)