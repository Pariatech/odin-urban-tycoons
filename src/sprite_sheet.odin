package main

Texture :: enum {
	Full_Mask,
	Grid_Mask,
	Terrain_Leveling_Mask,
	Grass,
	Gravel,
	Wood,
	Brick,
	Varg,
    Nyana,
	Light_Post_Base,
	Light_Post_Top,
	Wall_Top,

	Wall_Top_Diagonal,
	Wall_Top_Diagonal_Cross,
	Short_Wall_Top_Diagonal,
	Brick_Wall_Side_Base,
	Brick_Wall_Side_Top,
	Brick_Wall_Diagonal_Base,
	Brick_Wall_Diagonal_Top,
	Brick_Wall_Cross_Diagonal_Base,
	Brick_Wall_Cross_Diagonal_Top,
	Varg_Wall_Side_Base,
	Varg_Wall_Side_Top,
	Varg_Wall_Diagonal_Base,
	Varg_Wall_Diagonal_Top,
	Varg_Wall_Cross_Diagonal_Base,
	Varg_Wall_Cross_Diagonal_Top,
	Nyana_Wall_Side_Base,
	Nyana_Wall_Side_Top,
	Nyana_Wall_Diagonal_Base,
	Nyana_Wall_Diagonal_Top,
	Nyana_Wall_Cross_Diagonal_Base,
	Nyana_Wall_Cross_Diagonal_Top,
	Extended_Side_Wall_Base_Mask,
	Extended_Side_Wall_Top_Mask,
	Side_Wall_Base_Mask,
	Side_Wall_Top_Mask,
	End_Wall_Base_Mask,
	End_Wall_Top_Mask,
	Extended_Left_Diagonal_Wall_Base_Mask,
	Extended_Left_Diagonal_Wall_Top_Mask,
	Extended_Right_Diagonal_Wall_Base_Mask,
	Extended_Right_Diagonal_Wall_Top_Mask,
	Diagonal_Wall_Base_Mask,
	Diagonal_Wall_Top_Mask,
	Side_Top_Mask,
	Wall_Window_Base,
	Wall_Window_Top,
	Wall_Window_Mask_Base,
	Wall_Window_Mask_Top,
	Shovel_Base,
	Shovel_Top,
	Floor_Marker,
	Cursors_Wall_Tool_Base,
	Cursors_Wall_Tool_Top,
}

texture_paths :: [Texture]cstring {
	.Full_Mask                              = "resources/textures/full-mask.png",
	.Grid_Mask                              = "resources/textures/grid-mask.png",
	.Terrain_Leveling_Mask                  = "resources/textures/leveling-mask.png",
	.Grass                                  = "resources/textures/lawn-diffuse-512x512.png",
	.Gravel                                 = "resources/textures/gravel-diffuse-512x512.png",
	.Brick                                  = "resources/textures/brick.png",
	.Varg                                   = "resources/textures/varg.png",
	.Nyana                                   = "resources/textures/nyana.png",
	.Light_Post_Base                        = "resources/textures/light-pole-base.png",
	.Light_Post_Top                         = "resources/textures/light-pole-top.png",
	.Wall_Top                               = "resources/textures/wall-top.png",
	.Wall_Top_Diagonal                      = "resources/textures/walls/top/diagonal.png",
	.Wall_Top_Diagonal_Cross                = "resources/textures/walls/wall-top-diagonal-cross.png",
	.Short_Wall_Top_Diagonal                = "resources/textures/walls/short-wall-top-diagonal.png",
	.Brick_Wall_Side_Base                   = "resources/textures/walls/brick/side-base.png",
	.Brick_Wall_Side_Top                    = "resources/textures/walls/brick/side-top.png",
	.Brick_Wall_Diagonal_Base               = "resources/textures/walls/brick/diagonal-base.png",
	.Brick_Wall_Diagonal_Top                = "resources/textures/walls/brick/diagonal-top.png",
	.Brick_Wall_Cross_Diagonal_Base         = "resources/textures/walls/brick/cross-diagonal-base.png",
	.Brick_Wall_Cross_Diagonal_Top          = "resources/textures/walls/brick/cross-diagonal-top.png",
	.Varg_Wall_Side_Base                    = "resources/textures/walls/varg/side-base.png",
	.Varg_Wall_Side_Top                     = "resources/textures/walls/varg/side-top.png",
	.Varg_Wall_Diagonal_Base                = "resources/textures/walls/varg/diagonal-base.png",
	.Varg_Wall_Diagonal_Top                 = "resources/textures/walls/varg/diagonal-top.png",
	.Varg_Wall_Cross_Diagonal_Base          = "resources/textures/walls/varg/cross-diagonal-base.png",
	.Varg_Wall_Cross_Diagonal_Top           = "resources/textures/walls/varg/cross-diagonal-top.png",
	.Nyana_Wall_Side_Base                   = "resources/textures/walls/nyana/side-base.png",
	.Nyana_Wall_Side_Top                    = "resources/textures/walls/nyana/side-top.png",
	.Nyana_Wall_Diagonal_Base               = "resources/textures/walls/nyana/diagonal-base.png",
	.Nyana_Wall_Diagonal_Top                = "resources/textures/walls/nyana/diagonal-top.png",
	.Nyana_Wall_Cross_Diagonal_Base         = "resources/textures/walls/nyana/cross-diagonal-base.png",
	.Nyana_Wall_Cross_Diagonal_Top          = "resources/textures/walls/nyana/cross-diagonal-top.png",
	.Extended_Side_Wall_Base_Mask           = "resources/textures/walls/masks/extended-side-wall-base.png",
	.Extended_Side_Wall_Top_Mask            = "resources/textures/walls/masks/extended-side-wall-top.png",
	.Side_Wall_Base_Mask                    = "resources/textures/walls/masks/side-wall-base.png",
	.Side_Wall_Top_Mask                     = "resources/textures/walls/masks/side-wall-top.png",
	.End_Wall_Base_Mask                     = "resources/textures/walls/masks/end-wall-base.png",
	.End_Wall_Top_Mask                      = "resources/textures/walls/masks/end-wall-top.png",
	.Extended_Left_Diagonal_Wall_Base_Mask  = "resources/textures/walls/masks/extended-left-diagonal-wall-base.png",
	.Extended_Left_Diagonal_Wall_Top_Mask   = "resources/textures/walls/masks/extended-left-diagonal-wall-top.png",
	.Extended_Right_Diagonal_Wall_Base_Mask = "resources/textures/walls/masks/extended-right-diagonal-wall-base.png",
	.Extended_Right_Diagonal_Wall_Top_Mask  = "resources/textures/walls/masks/extended-right-diagonal-wall-top.png",
	.Diagonal_Wall_Base_Mask                = "resources/textures/walls/masks/diagonal-wall-base.png",
	.Diagonal_Wall_Top_Mask                 = "resources/textures/walls/masks/diagonal-wall-top.png",
	.Side_Top_Mask                          = "resources/textures/walls/masks/side-top.png",
	.Wall_Window_Base                       = "resources/textures/walls/wall-window-base.png",
	.Wall_Window_Top                        = "resources/textures/walls/wall-window-top.png",
	.Wall_Window_Mask_Base                  = "resources/textures/walls/wall-window-mask-base.png",
	.Wall_Window_Mask_Top                   = "resources/textures/walls/wall-window-mask-top.png",
	.Shovel_Base                            = "resources/textures/shovel-base.png",
	.Shovel_Top                             = "resources/textures/shovel-top.png",
	.Floor_Marker                           = "resources/textures/floors/floor-marker.png",
	.Wood                                   = "resources/textures/floors/wood.png",
	.Cursors_Wall_Tool_Base                 = "resources/textures/cursors/wall-tool-base.png",
	.Cursors_Wall_Tool_Top                  = "resources/textures/cursors/wall-tool-top.png",
}
