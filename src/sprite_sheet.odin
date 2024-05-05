package main

import "tile"

Wall_Texture :: enum (u16) {
	Wall_Top,
	Brick,
	Varg,
	Nyana,
    Frame,
}

Wall_Mask_Texture :: enum (u16) {
	Full_Mask,
	Door_Opening,
	Window_Opening,
}

wall_texture_paths :: [Wall_Texture]cstring {
	.Wall_Top = "resources/textures/walls/wall-top.png",
	.Brick    = "resources/textures/walls/brick-wall.png",
	.Varg     = "resources/textures/walls/varg-wall.png",
	.Nyana    = "resources/textures/walls/nyana-wall.png",
	.Frame    = "resources/textures/walls/frame.png",
}

wall_mask_paths :: [Wall_Mask_Texture]cstring {
	.Full_Mask      = "resources/textures/wall-masks/full.png",
	.Door_Opening   = "resources/textures/wall-masks/door-opening.png",
	.Window_Opening = "resources/textures/wall-masks/window-opening.png",
}
