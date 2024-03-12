package main

Texture :: enum (u16) {
	Full_Mask,
	Grid_Mask,
	// Terrain_Leveling_Mask,
	// Wood,
	// Brick,
	// Varg,
	// Nyana,
	// Light_Post_Base,
	// Light_Post_Top,
	// Wall_Top,
	// Shovel_Base,
	// Shovel_Top,
	// Floor_Marker,
	// Cursors_Wall_Tool_Base,
	// Cursors_Wall_Tool_Top,
	// Door_Opening,
	// Window_Opening,
	Grass,
	Gravel,
	Asphalt,
	Asphalt_Vertical_Line,
	Asphalt_Horizontal_Line,
	Concrete,
    Sidewalk,
}

texture_paths :: [Texture]cstring {
	// .Full_Mask               = "resources/textures/full-mask.png",
	// .Grid_Mask               = "resources/textures/grid-mask.png",
	.Full_Mask               = "resources/textures/masks/full.png",
	.Grid_Mask               = "resources/textures/masks/grid.png",
	// .Terrain_Leveling_Mask   = "resources/textures/leveling-mask.png",
	// .Brick                   = "resources/textures/brick-wall.png",
	// .Varg                    = "resources/textures/varg-wall.png",
	// .Nyana                   = "resources/textures/nyana-wall.png",
	// .Light_Post_Base         = "resources/textures/light-pole-base.png",
	// .Light_Post_Top          = "resources/textures/light-pole-top.png",
	// .Wall_Top                = "resources/textures/wall-top.png",
	// .Shovel_Base             = "resources/textures/shovel-base.png",
	// .Shovel_Top              = "resources/textures/shovel-top.png",
	// .Floor_Marker            = "resources/textures/floors/floor-marker.png",
	// .Wood                    = "resources/textures/floors/wood.png",
	// .Cursors_Wall_Tool_Base  = "resources/textures/cursors/wall-tool-base.png",
	// .Cursors_Wall_Tool_Top   = "resources/textures/cursors/wall-tool-top.png",
	// .Door_Opening            = "resources/textures/door-opening.png",
	// .Window_Opening          = "resources/textures/window-opening.png",
	.Grass                   = "resources/textures/tiles/lawn.png",
	.Gravel                  = "resources/textures/tiles/gravel.png",
	.Asphalt                 = "resources/textures/tiles/asphalt.png",
	.Asphalt_Vertical_Line   = "resources/textures/tiles/asphalt-vertical-line.png",
	.Asphalt_Horizontal_Line = "resources/textures/tiles/asphalt-horizontal-line.png",
	.Concrete                = "resources/textures/tiles/concrete.png",
	.Sidewalk                = "resources/textures/tiles/sidewalk.png",
}
