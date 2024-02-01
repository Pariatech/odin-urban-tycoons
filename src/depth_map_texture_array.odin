package main

Depth_Map_Texture :: enum {
    None,
    Chair_North,
}

DEPTH_MAP_TEXTURE_PATHS :: [Depth_Map_Texture]cstring {
    .None = "resources/textures/no-depth-map.png",
    .Chair_North = "resources/textures/chair-depth-map.png",
}

