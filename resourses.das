require daslib/media

var
    images: table<string; Image> <- {{
        "tank_ally"=>create_image("resources/tank_ally.png");
        "tank_enemy"=>create_image("resources/tank_enemy.png");
        "tank_dead"=>create_image("resources/tank_dead.png");
        "shoot_sprite"=>create_image("resources/shoot_sprite.png");
        "background"=>create_image("resources/background.jpg");
        "heavy_tank_ally"=>create_image("resources/heavy_tank_ally.png");
        "heavy_tank_enemy"=>create_image("resources/heavy_tank_enemy.png")
        }}

    sounds: table<string; PcmSound> <- {{
        "medium_tank_start_move"=>create_sound( "resources/medium_tank_start_move.mp3" );
        "medium_tank_shoot"=>create_sound( "resources/medium_tank_shoot.mp3" )
    }}

    soundHandle: PlayingSoundHandle

def res_play_sound(name: string)
    if key_exists(sounds, name)
        soundHandle = sounds[name] |> play_sound()