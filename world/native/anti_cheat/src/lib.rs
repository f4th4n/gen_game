#[rustler::nif]
fn validate_player_movement(
    before_x: f64,
    before_y: f64,
    after_x: f64,
    after_y: f64,
    speed: f64,
    timelapse: f64,
) -> bool {
    let max_distance = speed * timelapse;

    let valid_x = (after_x - before_x).abs() <= max_distance;
    let valid_y = (after_y - before_y).abs() <= max_distance;

    valid_x && valid_y
}

rustler::init!(
    "Elixir.GenGameWorld.Native.AntiCheat",
    [validate_player_movement]
);
