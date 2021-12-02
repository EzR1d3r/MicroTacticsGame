require daslib/media
require resourses
require objects

var
    image_scale_k: float const = 1.2

def common_render
    images["background"] |> draw_image(0.0, 0.0)

def render_centered_rect(pos: float2; size: float; color: uint; offset: float = 0.0)
    rect(pos.x - size/2.0 - offset, pos.y - size/2.0 - offset, size + offset * 2.0, size + offset * 2.0, color)

def render_unit_core(var u: Unit; var img: Image; color: uint = 0xFFFFFFFF)
    fill_circle(u.pos.x, u.pos.y, 15.0, u.color)

    var x_size = image_scale_k * float(img.width) * u.size_radius / float(img.height)
    var y_size = image_scale_k * float(img.height) * u.size_radius / float(img.height)
    var ky = u.size_radius / float(img.height)

    //calc rotation
    var res_vec = normalize(u.direction)
    var rotation = res_vec.y >= 0.0 ? acos(res_vec.x) : 2.0 * PI - acos(res_vec.x)

    //draw img
    img |> draw_image_transformed(
        u.pos.x, u.pos.y, float4(0.0, 0.0, float(img.width), float(img.height)), color, float2(x_size, y_size), rotation
        )

    var hp_k = float(u.hp) / float(u.max_hp)
    fill_rect(u.pos.x - u.size_radius, u.pos.y - u.size_radius - 10.0, u.size_radius * 2.0, 8.0, 0xB7FF0202)
    fill_rect(u.pos.x - u.size_radius, u.pos.y - u.size_radius - 10.0, hp_k * u.size_radius * 2.0, 8.0, 0xFF35FF02)

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

def render_cursor
    var mouse_pos: float2 = get_mouse_position()
    text_out(mouse_pos.x, mouse_pos.y, "X {mouse_pos.x}", 0xFFFFFFFF)
    text_out(mouse_pos.x, mouse_pos.y+15.0, "Y {mouse_pos.y}", 0xFFFFFFFF)