package main

Vector3 :: struct {
    x: f32,
    y: f32,
    z: f32,
}

Vector4 :: struct {
    using vector3: Vector3,
    w: f32,
}

Color_RGB :: struct {
    r: f32,
    g: f32,
    b: f32,
}

Half_Tile :: struct {
    position: Vector3,
    corner: u32,
    corners_y: [3]f32,
    corners_light: [3]Color_RGB,
    texture: f32,
    mask_texture: f32,
}
