package main

Texture :: enum (u16) {
	// Terrain_Leveling_Mask,
	Wood,

	// Light_Post_Base,
	// Light_Post_Top,
	// Shovel_Base,
	// Shovel_Top,
	// Floor_Marker,
	// Cursors_Wall_Tool_Base,
	// Cursors_Wall_Tool_Top,
	Grass,
	Gravel,
	Asphalt,
	Asphalt_Vertical_Line,
	Asphalt_Horizontal_Line,
	Concrete,
	Sidewalk,
}

Mask :: enum (u16) {
	Full_Mask,
	Grid_Mask,
	Leveling_Brush,
    Dotted_Grid,
}

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

texture_paths :: [Texture]cstring {
	// .Full_Mask               = "resources/textures/full-mask.png",
	// .Grid_Mask               = "resources/textures/grid-mask.png",
	// .Terrain_Leveling_Mask   = "resources/textures/leveling-mask.png",
	// .Light_Post_Base         = "resources/textures/light-pole-base.png",
	// .Light_Post_Top          = "resources/textures/light-pole-top.png",
	// .Shovel_Base             = "resources/textures/shovel-base.png",
	// .Shovel_Top              = "resources/textures/shovel-top.png",
	// .Floor_Marker            = "resources/textures/floors/floor-marker.png",
	.Wood                    = "resources/textures/floors/wood.png",
	// .Cursors_Wall_Tool_Base  = "resources/textures/cursors/wall-tool-base.png",
	// .Cursors_Wall_Tool_Top   = "resources/textures/cursors/wall-tool-top.png",
	.Grass                   = "resources/textures/tiles/lawn.png",
	.Gravel                  = "resources/textures/tiles/gravel.png",
	.Asphalt                 = "resources/textures/tiles/asphalt.png",
	.Asphalt_Vertical_Line   = "resources/textures/tiles/asphalt-vertical-line.png",
	.Asphalt_Horizontal_Line = "resources/textures/tiles/asphalt-horizontal-line.png",
	.Concrete                = "resources/textures/tiles/concrete.png",
	.Sidewalk                = "resources/textures/tiles/sidewalk.png",
}

mask_paths :: [Mask]cstring {
	.Full_Mask      = "resources/textures/masks/full.png",
	.Grid_Mask      = "resources/textures/masks/grid.png",
	.Leveling_Brush = "resources/textures/masks/leveling-brush.png",
	.Dotted_Grid      = "resources/textures/masks/dotted-grid.png",
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
