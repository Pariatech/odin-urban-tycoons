package object

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/linalg/glsl"
import "core:path/filepath"
import "core:slice"
import "core:strings"

import gl "vendor:OpenGL"
import "vendor:cgltf"
import stbi "vendor:stb/image"

import "../camera"
import c "../constants"
import "../floor"
import "../renderer"
import "../wall"

Type :: enum {
	Door,
	Window,
	Chair,
	Table,
	Painting,
	Counter,
	Carpet,
	Tree,
	Wall,
	Wall_Top,
}

Model :: enum {
	Wood_Door,
	Wood_Window,
	Wood_Chair,
	Wood_Table_1x2,
	Poutine_Painting,
	Wood_Counter,
	Small_Carpet,
	Tree,
	Wall_Side_Bricks012,
	Wall_Side_Brick,
	Wall_Side_Dark_Blue,
	Wall_Side_Drywall,
	Wall_Side_Frame,
	Wall_Side_Marble001,
	Wall_Side_Paint001,
	Wall_Side_Paint002,
	Wall_Side_Paint003,
	Wall_Side_Paint004,
	Wall_Side_Paint005,
	Wall_Side_Paint006,
	Wall_Side_Planks003,
	Wall_Side_Planks011,
	Wall_Side_Royal_Blue,
	Wall_Side_Tiles009,
	Wall_Side_Tiles077,
	Wall_Side_White,
	Wall_Side_White_Cladding,
	Wall_Side_Wood_Sidding002,
	Wall_Diagonal_Bricks012,
	Wall_Diagonal_Brick,
	Wall_Diagonal_Dark_Blue,
	Wall_Diagonal_Drywall,
	Wall_Diagonal_Frame,
	Wall_Diagonal_Marble001,
	Wall_Diagonal_Paint001,
	Wall_Diagonal_Paint002,
	Wall_Diagonal_Paint003,
	Wall_Diagonal_Paint004,
	Wall_Diagonal_Paint005,
	Wall_Diagonal_Paint006,
	Wall_Diagonal_Planks003,
	Wall_Diagonal_Planks011,
	Wall_Diagonal_Royal_Blue,
	Wall_Diagonal_Tiles009,
	Wall_Diagonal_Tiles077,
	Wall_Diagonal_White,
	Wall_Diagonal_White_Cladding,
	Wall_Diagonal_Wood_Sidding002,
	Wall_Diagonal_Cross_Bricks012,
	Wall_Diagonal_Cross_Brick,
	Wall_Diagonal_Cross_Dark_Blue,
	Wall_Diagonal_Cross_Drywall,
	Wall_Diagonal_Cross_Frame,
	Wall_Diagonal_Cross_Marble001,
	Wall_Diagonal_Cross_Paint001,
	Wall_Diagonal_Cross_Paint002,
	Wall_Diagonal_Cross_Paint003,
	Wall_Diagonal_Cross_Paint004,
	Wall_Diagonal_Cross_Paint005,
	Wall_Diagonal_Cross_Paint006,
	Wall_Diagonal_Cross_Planks003,
	Wall_Diagonal_Cross_Planks011,
	Wall_Diagonal_Cross_Royal_Blue,
	Wall_Diagonal_Cross_Tiles009,
	Wall_Diagonal_Cross_Tiles077,
	Wall_Diagonal_Cross_White,
	Wall_Diagonal_Cross_White_Cladding,
	Wall_Diagonal_Cross_Wood_Sidding002,
	Wall_Cutaway_Left_Top,
	Wall_Cutaway_Right_Top,
	Wall_Diagonal_Cross_Top,
	Wall_Diagonal_Side_Top,
	Wall_Short_Top,
	Wall_Side_Top,
	Wall_Down_Short_Top,
	Wall_Down_Side_Top,
}

Orientation :: enum {
	South,
	East,
	North,
	West,
}

Placement :: enum {
	Floor,
	Wall,
	Counter,
	Table,
}

Placement_Set :: bit_set[Placement]

TYPE_PLACEMENT_TABLE :: [Type]Placement_Set {
	.Door = {.Wall},
	.Window = {.Wall},
	.Chair = {.Floor},
	.Table = {.Floor},
	.Painting = {.Wall},
	.Counter = {.Floor},
	.Carpet = {.Floor},
	.Tree = {.Floor},
	.Wall = {.Floor},
	.Wall_Top = {.Wall},
}

MODEL_PLACEMENT_TABLE :: #partial [Model]Placement_Set{}

MODEL_SIZE :: [Model]glsl.ivec2 {
	.Wood_Door = {1, 2},
	.Wood_Window = {1, 2},
	.Wood_Chair = {1, 1},
	.Wood_Table_1x2 = {1, 2},
	.Poutine_Painting = {1, 1},
	.Wood_Counter = {1, 1},
	.Small_Carpet = {1, 1},
	.Tree = {2, 2},
	.Wall_Side_Bricks012 = {1, 1},
	.Wall_Side_Brick = {1, 1},
	.Wall_Side_Dark_Blue = {1, 1},
	.Wall_Side_Drywall = {1, 1},
	.Wall_Side_Frame = {1, 1},
	.Wall_Side_Marble001 = {1, 1},
	.Wall_Side_Paint001 = {1, 1},
	.Wall_Side_Paint002 = {1, 1},
	.Wall_Side_Paint003 = {1, 1},
	.Wall_Side_Paint004 = {1, 1},
	.Wall_Side_Paint005 = {1, 1},
	.Wall_Side_Paint006 = {1, 1},
	.Wall_Side_Planks003 = {1, 1},
	.Wall_Side_Planks011 = {1, 1},
	.Wall_Side_Royal_Blue = {1, 1},
	.Wall_Side_Tiles009 = {1, 1},
	.Wall_Side_Tiles077 = {1, 1},
	.Wall_Side_White = {1, 1},
	.Wall_Side_White_Cladding = {1, 1},
	.Wall_Side_Wood_Sidding002 = {1, 1},
	.Wall_Diagonal_Bricks012 = {1, 1},
	.Wall_Diagonal_Brick = {1, 1},
	.Wall_Diagonal_Dark_Blue = {1, 1},
	.Wall_Diagonal_Drywall = {1, 1},
	.Wall_Diagonal_Frame = {1, 1},
	.Wall_Diagonal_Marble001 = {1, 1},
	.Wall_Diagonal_Paint001 = {1, 1},
	.Wall_Diagonal_Paint002 = {1, 1},
	.Wall_Diagonal_Paint003 = {1, 1},
	.Wall_Diagonal_Paint004 = {1, 1},
	.Wall_Diagonal_Paint005 = {1, 1},
	.Wall_Diagonal_Paint006 = {1, 1},
	.Wall_Diagonal_Planks003 = {1, 1},
	.Wall_Diagonal_Planks011 = {1, 1},
	.Wall_Diagonal_Royal_Blue = {1, 1},
	.Wall_Diagonal_Tiles009 = {1, 1},
	.Wall_Diagonal_Tiles077 = {1, 1},
	.Wall_Diagonal_White = {1, 1},
	.Wall_Diagonal_White_Cladding = {1, 1},
	.Wall_Diagonal_Wood_Sidding002 = {1, 1},
	.Wall_Diagonal_Cross_Bricks012 = {1, 1},
	.Wall_Diagonal_Cross_Brick = {1, 1},
	.Wall_Diagonal_Cross_Dark_Blue = {1, 1},
	.Wall_Diagonal_Cross_Drywall = {1, 1},
	.Wall_Diagonal_Cross_Frame = {1, 1},
	.Wall_Diagonal_Cross_Marble001 = {1, 1},
	.Wall_Diagonal_Cross_Paint001 = {1, 1},
	.Wall_Diagonal_Cross_Paint002 = {1, 1},
	.Wall_Diagonal_Cross_Paint003 = {1, 1},
	.Wall_Diagonal_Cross_Paint004 = {1, 1},
	.Wall_Diagonal_Cross_Paint005 = {1, 1},
	.Wall_Diagonal_Cross_Paint006 = {1, 1},
	.Wall_Diagonal_Cross_Planks003 = {1, 1},
	.Wall_Diagonal_Cross_Planks011 = {1, 1},
	.Wall_Diagonal_Cross_Royal_Blue = {1, 1},
	.Wall_Diagonal_Cross_Tiles009 = {1, 1},
	.Wall_Diagonal_Cross_Tiles077 = {1, 1},
	.Wall_Diagonal_Cross_White = {1, 1},
	.Wall_Diagonal_Cross_White_Cladding = {1, 1},
	.Wall_Diagonal_Cross_Wood_Sidding002 = {1, 1},
	.Wall_Cutaway_Left_Top = {1, 1},
	.Wall_Cutaway_Right_Top = {1, 1},
	.Wall_Diagonal_Cross_Top = {1, 1},
	.Wall_Diagonal_Side_Top = {1, 1},
	.Wall_Short_Top = {1, 1},
	.Wall_Side_Top = {1, 1},
	.Wall_Down_Short_Top = {1, 1},
	.Wall_Down_Side_Top = {1, 1},
}

TYPE_MAP :: [Model]Type {
	.Wood_Door                           = .Door,
	.Wood_Window                         = .Window,
	.Wood_Chair                          = .Chair,
	.Wood_Table_1x2                      = .Table,
	.Poutine_Painting                    = .Painting,
	.Wood_Counter                        = .Counter,
	.Small_Carpet                        = .Carpet,
	.Tree                                = .Tree,
	.Wall_Side_Bricks012                 = .Wall,
	.Wall_Side_Brick                     = .Wall,
	.Wall_Side_Dark_Blue                 = .Wall,
	.Wall_Side_Drywall                   = .Wall,
	.Wall_Side_Frame                     = .Wall,
	.Wall_Side_Marble001                 = .Wall,
	.Wall_Side_Paint001                  = .Wall,
	.Wall_Side_Paint002                  = .Wall,
	.Wall_Side_Paint003                  = .Wall,
	.Wall_Side_Paint004                  = .Wall,
	.Wall_Side_Paint005                  = .Wall,
	.Wall_Side_Paint006                  = .Wall,
	.Wall_Side_Planks003                 = .Wall,
	.Wall_Side_Planks011                 = .Wall,
	.Wall_Side_Royal_Blue                = .Wall,
	.Wall_Side_Tiles009                  = .Wall,
	.Wall_Side_Tiles077                  = .Wall,
	.Wall_Side_White                     = .Wall,
	.Wall_Side_White_Cladding            = .Wall,
	.Wall_Side_Wood_Sidding002           = .Wall,
	.Wall_Diagonal_Bricks012             = .Wall,
	.Wall_Diagonal_Brick                 = .Wall,
	.Wall_Diagonal_Dark_Blue             = .Wall,
	.Wall_Diagonal_Drywall               = .Wall,
	.Wall_Diagonal_Frame                 = .Wall,
	.Wall_Diagonal_Marble001             = .Wall,
	.Wall_Diagonal_Paint001              = .Wall,
	.Wall_Diagonal_Paint002              = .Wall,
	.Wall_Diagonal_Paint003              = .Wall,
	.Wall_Diagonal_Paint004              = .Wall,
	.Wall_Diagonal_Paint005              = .Wall,
	.Wall_Diagonal_Paint006              = .Wall,
	.Wall_Diagonal_Planks003             = .Wall,
	.Wall_Diagonal_Planks011             = .Wall,
	.Wall_Diagonal_Royal_Blue            = .Wall,
	.Wall_Diagonal_Tiles009              = .Wall,
	.Wall_Diagonal_Tiles077              = .Wall,
	.Wall_Diagonal_White                 = .Wall,
	.Wall_Diagonal_White_Cladding        = .Wall,
	.Wall_Diagonal_Wood_Sidding002       = .Wall,
	.Wall_Diagonal_Cross_Bricks012       = .Wall,
	.Wall_Diagonal_Cross_Brick           = .Wall,
	.Wall_Diagonal_Cross_Dark_Blue       = .Wall,
	.Wall_Diagonal_Cross_Drywall         = .Wall,
	.Wall_Diagonal_Cross_Frame           = .Wall,
	.Wall_Diagonal_Cross_Marble001       = .Wall,
	.Wall_Diagonal_Cross_Paint001        = .Wall,
	.Wall_Diagonal_Cross_Paint002        = .Wall,
	.Wall_Diagonal_Cross_Paint003        = .Wall,
	.Wall_Diagonal_Cross_Paint004        = .Wall,
	.Wall_Diagonal_Cross_Paint005        = .Wall,
	.Wall_Diagonal_Cross_Paint006        = .Wall,
	.Wall_Diagonal_Cross_Planks003       = .Wall,
	.Wall_Diagonal_Cross_Planks011       = .Wall,
	.Wall_Diagonal_Cross_Royal_Blue      = .Wall,
	.Wall_Diagonal_Cross_Tiles009        = .Wall,
	.Wall_Diagonal_Cross_Tiles077        = .Wall,
	.Wall_Diagonal_Cross_White           = .Wall,
	.Wall_Diagonal_Cross_White_Cladding  = .Wall,
	.Wall_Diagonal_Cross_Wood_Sidding002 = .Wall,
	.Wall_Cutaway_Left_Top               = .Wall_Top,
	.Wall_Cutaway_Right_Top              = .Wall_Top,
	.Wall_Diagonal_Cross_Top             = .Wall_Top,
	.Wall_Diagonal_Side_Top              = .Wall_Top,
	.Wall_Short_Top                      = .Wall_Top,
	.Wall_Side_Top                       = .Wall_Top,
	.Wall_Down_Short_Top                 = .Wall_Top,
	.Wall_Down_Side_Top                  = .Wall_Top,
}

WIDTH :: 256
HEIGHT :: 512
MIPMAP_LEVELS :: i32(2)
OBJECTS_PATH :: "resources/textures/objects/"

Instance :: struct {
	position:  glsl.vec3,
	light:     glsl.vec3,
	texture:   f32,
	depth_map: f32,
	mirror:    f32,
	mask:      f32,
}

Texture :: enum {
	Wood_Door_1_S,
	Wood_Door_1_W,
	Wood_Door_1_N,
	Wood_Door_1_E,
	Wood_Door_2_S,
	Wood_Door_2_W,
	Wood_Door_2_N,
	Wood_Door_2_E,
	Wood_Window_1_S,
	Wood_Window_1_W,
	Wood_Window_1_N,
	Wood_Window_1_E,
	Wood_Window_2_S,
	Wood_Window_2_W,
	Wood_Window_2_N,
	Wood_Window_2_E,
	Wood_Chair_S,
	Wood_Chair_W,
	Wood_Chair_N,
	Wood_Chair_E,
	Wood_Table_1x2_1_S,
	Wood_Table_1x2_1_W,
	Wood_Table_1x2_1_N,
	Wood_Table_1x2_1_E,
	Wood_Table_1x2_2_S,
	Wood_Table_1x2_2_W,
	Wood_Table_1x2_2_N,
	Wood_Table_1x2_2_E,
	Poutine_Painting_S,
	Poutine_Painting_W,
	Poutine_Painting_N,
	Poutine_Painting_E,
	Wood_Counter_S,
	Wood_Counter_W,
	Wood_Counter_N,
	Wood_Counter_E,
	Small_Carpet_S,
	Small_Carpet_W,
	Small_Carpet_N,
	Small_Carpet_E,
	Tree_1_S,
	Tree_1_W,
	Tree_1_N,
	Tree_1_E,
	Tree_2_S,
	Tree_2_W,
	Tree_2_N,
	Tree_2_E,
	Tree_3_S,
	Tree_3_W,
	Tree_3_N,
	Tree_3_E,
	Tree_4_S,
	Tree_4_W,
	Tree_4_N,
	Tree_4_E,
	Wall_Side_Bricks012,
	Wall_Side_Brick,
	Wall_Side_Dark_Blue,
	Wall_Side_Drywall,
	Wall_Side_Frame,
	Wall_Side_Marble001,
	Wall_Side_Paint001,
	Wall_Side_Paint002,
	Wall_Side_Paint003,
	Wall_Side_Paint004,
	Wall_Side_Paint005,
	Wall_Side_Paint006,
	Wall_Side_Planks003,
	Wall_Side_Planks011,
	Wall_Side_Royal_Blue,
	Wall_Side_Tiles009,
	Wall_Side_Tiles077,
	Wall_Side_White,
	Wall_Side_White_Cladding,
	Wall_Side_Wood_Sidding002,
	Wall_Diagonal_Bricks012,
	Wall_Diagonal_Brick,
	Wall_Diagonal_Dark_Blue,
	Wall_Diagonal_Drywall,
	Wall_Diagonal_Frame,
	Wall_Diagonal_Marble001,
	Wall_Diagonal_Paint001,
	Wall_Diagonal_Paint002,
	Wall_Diagonal_Paint003,
	Wall_Diagonal_Paint004,
	Wall_Diagonal_Paint005,
	Wall_Diagonal_Paint006,
	Wall_Diagonal_Planks003,
	Wall_Diagonal_Planks011,
	Wall_Diagonal_Royal_Blue,
	Wall_Diagonal_Tiles009,
	Wall_Diagonal_Tiles077,
	Wall_Diagonal_White,
	Wall_Diagonal_White_Cladding,
	Wall_Diagonal_Wood_Sidding002,
	Wall_Diagonal_Cross_Bricks012,
	Wall_Diagonal_Cross_Brick,
	Wall_Diagonal_Cross_Dark_Blue,
	Wall_Diagonal_Cross_Drywall,
	Wall_Diagonal_Cross_Frame,
	Wall_Diagonal_Cross_Marble001,
	Wall_Diagonal_Cross_Paint001,
	Wall_Diagonal_Cross_Paint002,
	Wall_Diagonal_Cross_Paint003,
	Wall_Diagonal_Cross_Paint004,
	Wall_Diagonal_Cross_Paint005,
	Wall_Diagonal_Cross_Paint006,
	Wall_Diagonal_Cross_Planks003,
	Wall_Diagonal_Cross_Planks011,
	Wall_Diagonal_Cross_Royal_Blue,
	Wall_Diagonal_Cross_Tiles009,
	Wall_Diagonal_Cross_Tiles077,
	Wall_Diagonal_Cross_White,
	Wall_Diagonal_Cross_White_Cladding,
	Wall_Diagonal_Cross_Wood_Sidding002,
	Wall_Cutaway_Left_Top,
	Wall_Cutaway_Right_Top,
	Wall_Diagonal_Cross_Top,
	Wall_Diagonal_Side_Top,
	Wall_Short_Top,
	Wall_Side_Top,
	Wall_Down_Short_Top,
	Wall_Down_Side_Top,
}

Depth_Map :: enum {
	Wood_Door_1_S,
	Wood_Door_1_W,
	Wood_Door_1_N,
	Wood_Door_1_E,
	Wood_Door_2_S,
	Wood_Door_2_W,
	Wood_Door_2_N,
	Wood_Door_2_E,
	Wood_Window_1_S,
	Wood_Window_1_W,
	Wood_Window_1_N,
	Wood_Window_1_E,
	Wood_Window_2_S,
	Wood_Window_2_W,
	Wood_Window_2_N,
	Wood_Window_2_E,
	Wood_Chair_S,
	Wood_Chair_W,
	Wood_Chair_N,
	Wood_Chair_E,
	Wood_Table_1x2_1_S,
	Wood_Table_1x2_1_W,
	Wood_Table_1x2_1_N,
	Wood_Table_1x2_1_E,
	Wood_Table_1x2_2_S,
	Wood_Table_1x2_2_W,
	Wood_Table_1x2_2_N,
	Wood_Table_1x2_2_E,
	Poutine_Painting_S,
	Poutine_Painting_W,
	Poutine_Painting_N,
	Poutine_Painting_E,
	Wood_Counter_S,
	Wood_Counter_W,
	Wood_Counter_N,
	Wood_Counter_E,
	Small_Carpet_S,
	Small_Carpet_W,
	Small_Carpet_N,
	Small_Carpet_E,
	Tree_1_S,
	Tree_1_W,
	Tree_1_N,
	Tree_1_E,
	Tree_2_S,
	Tree_2_W,
	Tree_2_N,
	Tree_2_E,
	Tree_3_S,
	Tree_3_W,
	Tree_3_N,
	Tree_3_E,
	Tree_4_S,
	Tree_4_W,
	Tree_4_N,
	Tree_4_E,
	Wall_Side,
	Wall_Diagonal,
	Wall_Diagonal_Cross,
	Wall_Cutaway_Left_Top,
	Wall_Cutaway_Right_Top,
	Wall_Diagonal_Cross_Top,
	Wall_Diagonal_Side_Top,
	Wall_Short_Top,
	Wall_Side_Top,
	Wall_Down_Short_Top,
	Wall_Down_Side_Top,
}

Mask :: enum {
	None,
	Cutaway_Left,
	Cutaway_Right,
	Door,
	Down,
	Down_Short,
	Up_Short,
	Window,
}


DIFFUSE_PATHS :: [Texture]cstring {
	.Wood_Door_1_S                       = "Doors/diffuse/Wood.Door.001_0001.png",
	.Wood_Door_1_W                       = "Doors/diffuse/Wood.Door.001_0002.png",
	.Wood_Door_1_N                       = "Doors/diffuse/Wood.Door.001_0003.png",
	.Wood_Door_1_E                       = "Doors/diffuse/Wood.Door.001_0004.png",
	.Wood_Door_2_S                       = "Doors/diffuse/Wood.Door.002_0001.png",
	.Wood_Door_2_W                       = "Doors/diffuse/Wood.Door.002_0002.png",
	.Wood_Door_2_N                       = "Doors/diffuse/Wood.Door.002_0003.png",
	.Wood_Door_2_E                       = "Doors/diffuse/Wood.Door.002_0004.png",
	.Wood_Window_1_S                     = "Windows/diffuse/Wood.Window.001_0001.png",
	.Wood_Window_1_W                     = "Windows/diffuse/Wood.Window.001_0002.png",
	.Wood_Window_1_N                     = "Windows/diffuse/Wood.Window.001_0003.png",
	.Wood_Window_1_E                     = "Windows/diffuse/Wood.Window.001_0004.png",
	.Wood_Window_2_S                     = "Windows/diffuse/Wood.Window.002_0001.png",
	.Wood_Window_2_W                     = "Windows/diffuse/Wood.Window.002_0002.png",
	.Wood_Window_2_N                     = "Windows/diffuse/Wood.Window.002_0003.png",
	.Wood_Window_2_E                     = "Windows/diffuse/Wood.Window.002_0004.png",
	.Wood_Chair_S                        = "Chairs/diffuse/Chair_0001.png",
	.Wood_Chair_W                        = "Chairs/diffuse/Chair_0002.png",
	.Wood_Chair_N                        = "Chairs/diffuse/Chair_0003.png",
	.Wood_Chair_E                        = "Chairs/diffuse/Chair_0004.png",
	.Wood_Table_1x2_1_S                  = "Tables/diffuse/Table.6Places.001_0001.png",
	.Wood_Table_1x2_2_S                  = "Tables/diffuse/Table.6Places.002_0001.png",
	.Wood_Table_1x2_1_W                  = "Tables/diffuse/Table.6Places.001_0002.png",
	.Wood_Table_1x2_2_W                  = "Tables/diffuse/Table.6Places.002_0002.png",
	.Wood_Table_1x2_1_N                  = "Tables/diffuse/Table.6Places.001_0003.png",
	.Wood_Table_1x2_2_N                  = "Tables/diffuse/Table.6Places.002_0003.png",
	.Wood_Table_1x2_1_E                  = "Tables/diffuse/Table.6Places.001_0004.png",
	.Wood_Table_1x2_2_E                  = "Tables/diffuse/Table.6Places.002_0004.png",
	.Poutine_Painting_S                  = "Paintings/diffuse/Poutine.Painting_0001.png",
	.Poutine_Painting_W                  = "Paintings/diffuse/Poutine.Painting_0002.png",
	.Poutine_Painting_N                  = "Paintings/diffuse/Poutine.Painting_0003.png",
	.Poutine_Painting_E                  = "Paintings/diffuse/Poutine.Painting_0004.png",
	.Wood_Counter_S                      = "Counters/diffuse/Wood.Counter_0001.png",
	.Wood_Counter_W                      = "Counters/diffuse/Wood.Counter_0002.png",
	.Wood_Counter_N                      = "Counters/diffuse/Wood.Counter_0003.png",
	.Wood_Counter_E                      = "Counters/diffuse/Wood.Counter_0004.png",
	.Small_Carpet_S                      = "Carpets/diffuse/Small.Carpet_0001.png",
	.Small_Carpet_W                      = "Carpets/diffuse/Small.Carpet_0002.png",
	.Small_Carpet_N                      = "Carpets/diffuse/Small.Carpet_0003.png",
	.Small_Carpet_E                      = "Carpets/diffuse/Small.Carpet_0004.png",
	.Tree_1_S                            = "Trees/diffuse/Tree.001_0001.png",
	.Tree_1_W                            = "Trees/diffuse/Tree.001_0002.png",
	.Tree_1_N                            = "Trees/diffuse/Tree.001_0003.png",
	.Tree_1_E                            = "Trees/diffuse/Tree.001_0004.png",
	.Tree_2_S                            = "Trees/diffuse/Tree.002_0001.png",
	.Tree_2_W                            = "Trees/diffuse/Tree.002_0002.png",
	.Tree_2_N                            = "Trees/diffuse/Tree.002_0003.png",
	.Tree_2_E                            = "Trees/diffuse/Tree.002_0004.png",
	.Tree_3_S                            = "Trees/diffuse/Tree.003_0001.png",
	.Tree_3_W                            = "Trees/diffuse/Tree.003_0002.png",
	.Tree_3_N                            = "Trees/diffuse/Tree.003_0003.png",
	.Tree_3_E                            = "Trees/diffuse/Tree.003_0004.png",
	.Tree_4_S                            = "Trees/diffuse/Tree.004_0001.png",
	.Tree_4_W                            = "Trees/diffuse/Tree.004_0002.png",
	.Tree_4_N                            = "Trees/diffuse/Tree.004_0003.png",
	.Tree_4_E                            = "Trees/diffuse/Tree.004_0004.png",
	.Wall_Side_Bricks012                 = "Walls_Side/Walls.Side/Bricks012_0001.png",
	.Wall_Side_Brick                     = "Walls_Side/Walls.Side/brick-wall_0001.png",
	.Wall_Side_Dark_Blue                 = "Walls_Side/Walls.Side/dark_blue_0001.png",
	.Wall_Side_Drywall                   = "Walls_Side/Walls.Side/drywall_0001.png",
	.Wall_Side_Frame                     = "Walls_Side/Walls.Side/frame_0001.png",
	.Wall_Side_Marble001                 = "Walls_Side/Walls.Side/Marble001_0001.png",
	.Wall_Side_Paint001                  = "Walls_Side/Walls.Side/Paint001_0001.png",
	.Wall_Side_Paint002                  = "Walls_Side/Walls.Side/Paint002_0001.png",
	.Wall_Side_Paint003                  = "Walls_Side/Walls.Side/Paint003_0001.png",
	.Wall_Side_Paint004                  = "Walls_Side/Walls.Side/Paint004_0001.png",
	.Wall_Side_Paint005                  = "Walls_Side/Walls.Side/Paint005_0001.png",
	.Wall_Side_Paint006                  = "Walls_Side/Walls.Side/Paint006_0001.png",
	.Wall_Side_Planks003                 = "Walls_Side/Walls.Side/Planks003_0001.png",
	.Wall_Side_Planks011                 = "Walls_Side/Walls.Side/Planks011_0001.png",
	.Wall_Side_Royal_Blue                = "Walls_Side/Walls.Side/royal_blue_0001.png",
	.Wall_Side_Tiles009                  = "Walls_Side/Walls.Side/Tiles009_0001.png",
	.Wall_Side_Tiles077                  = "Walls_Side/Walls.Side/Tiles077_0001.png",
	.Wall_Side_White                     = "Walls_Side/Walls.Side/white_0001.png",
	.Wall_Side_White_Cladding            = "Walls_Side/Walls.Side/white_cladding_0001.png",
	.Wall_Side_Wood_Sidding002           = "Walls_Side/Walls.Side/WoodSiding002_0001.png",
	.Wall_Diagonal_Bricks012             = "Walls_Side/Walls.Side.Diagonal/Bricks012_0001.png",
	.Wall_Diagonal_Brick                 = "Walls_Side/Walls.Side.Diagonal/brick-wall_0001.png",
	.Wall_Diagonal_Dark_Blue             = "Walls_Side/Walls.Side.Diagonal/dark_blue_0001.png",
	.Wall_Diagonal_Drywall               = "Walls_Side/Walls.Side.Diagonal/drywall_0001.png",
	.Wall_Diagonal_Frame                 = "Walls_Side/Walls.Side.Diagonal/frame_0001.png",
	.Wall_Diagonal_Marble001             = "Walls_Side/Walls.Side.Diagonal/Marble001_0001.png",
	.Wall_Diagonal_Paint001              = "Walls_Side/Walls.Side.Diagonal/Paint001_0001.png",
	.Wall_Diagonal_Paint002              = "Walls_Side/Walls.Side.Diagonal/Paint002_0001.png",
	.Wall_Diagonal_Paint003              = "Walls_Side/Walls.Side.Diagonal/Paint003_0001.png",
	.Wall_Diagonal_Paint004              = "Walls_Side/Walls.Side.Diagonal/Paint004_0001.png",
	.Wall_Diagonal_Paint005              = "Walls_Side/Walls.Side.Diagonal/Paint005_0001.png",
	.Wall_Diagonal_Paint006              = "Walls_Side/Walls.Side.Diagonal/Paint006_0001.png",
	.Wall_Diagonal_Planks003             = "Walls_Side/Walls.Side.Diagonal/Planks003_0001.png",
	.Wall_Diagonal_Planks011             = "Walls_Side/Walls.Side.Diagonal/Planks011_0001.png",
	.Wall_Diagonal_Royal_Blue            = "Walls_Side/Walls.Side.Diagonal/royal_blue_0001.png",
	.Wall_Diagonal_Tiles009              = "Walls_Side/Walls.Side.Diagonal/Tiles009_0001.png",
	.Wall_Diagonal_Tiles077              = "Walls_Side/Walls.Side.Diagonal/Tiles077_0001.png",
	.Wall_Diagonal_White                 = "Walls_Side/Walls.Side.Diagonal/white_0001.png",
	.Wall_Diagonal_White_Cladding        = "Walls_Side/Walls.Side.Diagonal/white_cladding_0001.png",
	.Wall_Diagonal_Wood_Sidding002       = "Walls_Side/Walls.Side.Diagonal/WoodSiding002_0001.png",
	.Wall_Diagonal_Cross_Bricks012       = "Walls_Side/Walls.Side.Diagonal.Cross/Bricks012_0001.png",
	.Wall_Diagonal_Cross_Brick           = "Walls_Side/Walls.Side.Diagonal.Cross/brick-wall_0001.png",
	.Wall_Diagonal_Cross_Dark_Blue       = "Walls_Side/Walls.Side.Diagonal.Cross/dark_blue_0001.png",
	.Wall_Diagonal_Cross_Drywall         = "Walls_Side/Walls.Side.Diagonal.Cross/drywall_0001.png",
	.Wall_Diagonal_Cross_Frame           = "Walls_Side/Walls.Side.Diagonal.Cross/frame_0001.png",
	.Wall_Diagonal_Cross_Marble001       = "Walls_Side/Walls.Side.Diagonal.Cross/Marble001_0001.png",
	.Wall_Diagonal_Cross_Paint001        = "Walls_Side/Walls.Side.Diagonal.Cross/Paint001_0001.png",
	.Wall_Diagonal_Cross_Paint002        = "Walls_Side/Walls.Side.Diagonal.Cross/Paint002_0001.png",
	.Wall_Diagonal_Cross_Paint003        = "Walls_Side/Walls.Side.Diagonal.Cross/Paint003_0001.png",
	.Wall_Diagonal_Cross_Paint004        = "Walls_Side/Walls.Side.Diagonal.Cross/Paint004_0001.png",
	.Wall_Diagonal_Cross_Paint005        = "Walls_Side/Walls.Side.Diagonal.Cross/Paint005_0001.png",
	.Wall_Diagonal_Cross_Paint006        = "Walls_Side/Walls.Side.Diagonal.Cross/Paint006_0001.png",
	.Wall_Diagonal_Cross_Planks003       = "Walls_Side/Walls.Side.Diagonal.Cross/Planks003_0001.png",
	.Wall_Diagonal_Cross_Planks011       = "Walls_Side/Walls.Side.Diagonal.Cross/Planks011_0001.png",
	.Wall_Diagonal_Cross_Royal_Blue      = "Walls_Side/Walls.Side.Diagonal.Cross/royal_blue_0001.png",
	.Wall_Diagonal_Cross_Tiles009        = "Walls_Side/Walls.Side.Diagonal.Cross/Tiles009_0001.png",
	.Wall_Diagonal_Cross_Tiles077        = "Walls_Side/Walls.Side.Diagonal.Cross/Tiles077_0001.png",
	.Wall_Diagonal_Cross_White           = "Walls_Side/Walls.Side.Diagonal.Cross/white_0001.png",
	.Wall_Diagonal_Cross_White_Cladding  = "Walls_Side/Walls.Side.Diagonal.Cross/white_cladding_0001.png",
	.Wall_Diagonal_Cross_Wood_Sidding002 = "Walls_Side/Walls.Side.Diagonal.Cross/WoodSiding002_0001.png",
	.Wall_Cutaway_Left_Top               = "Walls_Top/diffuse/Walls.Cutaway.Left.Top_0001.png",
	.Wall_Cutaway_Right_Top              = "Walls_Top/diffuse/Walls.Cutaway.Right.Top_0001.png",
	.Wall_Diagonal_Cross_Top             = "Walls_Top/diffuse/Walls.Diagonal.Cross.Top_0001.png",
	.Wall_Diagonal_Side_Top              = "Walls_Top/diffuse/Walls.Diagonal.Side.Top_0001.png",
	.Wall_Short_Top                      = "Walls_Top/diffuse/Walls.Short.Top_0001.png",
	.Wall_Side_Top                       = "Walls_Top/diffuse/Walls.Side.Top_0001.png",
	.Wall_Down_Short_Top                 = "Walls_Top/diffuse/Walls.Down.Short.Top_0001.png",
	.Wall_Down_Side_Top                  = "Walls_Top/diffuse/Walls.Down.Top_0001.png",
}

DEPTH_MAP_PATHS :: [Depth_Map]cstring {
	.Wood_Door_1_S           = "Doors/mist/Wood.Door.001_0001.png",
	.Wood_Door_1_W           = "Doors/mist/Wood.Door.001_0002.png",
	.Wood_Door_1_N           = "Doors/mist/Wood.Door.001_0003.png",
	.Wood_Door_1_E           = "Doors/mist/Wood.Door.001_0004.png",
	.Wood_Door_2_S           = "Doors/mist/Wood.Door.002_0001.png",
	.Wood_Door_2_W           = "Doors/mist/Wood.Door.002_0002.png",
	.Wood_Door_2_N           = "Doors/mist/Wood.Door.002_0003.png",
	.Wood_Door_2_E           = "Doors/mist/Wood.Door.002_0004.png",
	.Wood_Window_1_S         = "Windows/mist/Wood.Window.001_0001.png",
	.Wood_Window_1_W         = "Windows/mist/Wood.Window.001_0002.png",
	.Wood_Window_1_N         = "Windows/mist/Wood.Window.001_0003.png",
	.Wood_Window_1_E         = "Windows/mist/Wood.Window.001_0004.png",
	.Wood_Window_2_S         = "Windows/mist/Wood.Window.002_0001.png",
	.Wood_Window_2_W         = "Windows/mist/Wood.Window.002_0002.png",
	.Wood_Window_2_N         = "Windows/mist/Wood.Window.002_0003.png",
	.Wood_Window_2_E         = "Windows/mist/Wood.Window.002_0004.png",
	.Wood_Chair_S            = "Chairs/mist/Chair_0001.png",
	.Wood_Chair_W            = "Chairs/mist/Chair_0002.png",
	.Wood_Chair_N            = "Chairs/mist/Chair_0003.png",
	.Wood_Chair_E            = "Chairs/mist/Chair_0004.png",
	.Wood_Table_1x2_1_S      = "Tables/mist/Table.6Places.001_0001.png",
	.Wood_Table_1x2_2_S      = "Tables/mist/Table.6Places.002_0001.png",
	.Wood_Table_1x2_1_W      = "Tables/mist/Table.6Places.001_0002.png",
	.Wood_Table_1x2_2_W      = "Tables/mist/Table.6Places.002_0002.png",
	.Wood_Table_1x2_1_N      = "Tables/mist/Table.6Places.001_0003.png",
	.Wood_Table_1x2_2_N      = "Tables/mist/Table.6Places.002_0003.png",
	.Wood_Table_1x2_1_E      = "Tables/mist/Table.6Places.001_0004.png",
	.Wood_Table_1x2_2_E      = "Tables/mist/Table.6Places.002_0004.png",
	.Poutine_Painting_S      = "Paintings/mist/Poutine.Painting_0001.png",
	.Poutine_Painting_W      = "Paintings/mist/Poutine.Painting_0002.png",
	.Poutine_Painting_N      = "Paintings/mist/Poutine.Painting_0003.png",
	.Poutine_Painting_E      = "Paintings/mist/Poutine.Painting_0004.png",
	.Wood_Counter_S          = "Counters/mist/Wood.Counter_0001.png",
	.Wood_Counter_W          = "Counters/mist/Wood.Counter_0002.png",
	.Wood_Counter_N          = "Counters/mist/Wood.Counter_0003.png",
	.Wood_Counter_E          = "Counters/mist/Wood.Counter_0004.png",
	.Small_Carpet_S          = "Carpets/mist/Small.Carpet_0001.png",
	.Small_Carpet_W          = "Carpets/mist/Small.Carpet_0002.png",
	.Small_Carpet_N          = "Carpets/mist/Small.Carpet_0003.png",
	.Small_Carpet_E          = "Carpets/mist/Small.Carpet_0004.png",
	.Tree_1_S                = "Trees/mist/Tree.001_0001.png",
	.Tree_1_W                = "Trees/mist/Tree.001_0002.png",
	.Tree_1_N                = "Trees/mist/Tree.001_0003.png",
	.Tree_1_E                = "Trees/mist/Tree.001_0004.png",
	.Tree_2_S                = "Trees/mist/Tree.002_0001.png",
	.Tree_2_W                = "Trees/mist/Tree.002_0002.png",
	.Tree_2_N                = "Trees/mist/Tree.002_0003.png",
	.Tree_2_E                = "Trees/mist/Tree.002_0004.png",
	.Tree_3_S                = "Trees/mist/Tree.003_0001.png",
	.Tree_3_W                = "Trees/mist/Tree.003_0002.png",
	.Tree_3_N                = "Trees/mist/Tree.003_0003.png",
	.Tree_3_E                = "Trees/mist/Tree.003_0004.png",
	.Tree_4_S                = "Trees/mist/Tree.004_0001.png",
	.Tree_4_W                = "Trees/mist/Tree.004_0002.png",
	.Tree_4_N                = "Trees/mist/Tree.004_0003.png",
	.Tree_4_E                = "Trees/mist/Tree.004_0004.png",
	.Wall_Side               = "Walls_Side/mist/Walls.Side_0001.png",
	.Wall_Diagonal           = "Walls_Side/mist/Walls.Side.Diagonal_0001.png",
	.Wall_Diagonal_Cross     = "Walls_Side/mist/Walls.Side.Diagonal.Cross_0001.png",
	.Wall_Cutaway_Left_Top   = "Walls_Top/mist/Walls.Cutaway.Left.Top_0001.png",
	.Wall_Cutaway_Right_Top  = "Walls_Top/mist/Walls.Cutaway.Right.Top_0001.png",
	.Wall_Diagonal_Cross_Top = "Walls_Top/mist/Walls.Diagonal.Cross.Top_0001.png",
	.Wall_Diagonal_Side_Top  = "Walls_Top/mist/Walls.Diagonal.Side.Top_0001.png",
	.Wall_Short_Top          = "Walls_Top/mist/Walls.Short.Top_0001.png",
	.Wall_Side_Top           = "Walls_Top/mist/Walls.Side.Top_0001.png",
	.Wall_Down_Short_Top     = "Walls_Top/mist/Walls.Down.Short.Top_0001.png",
	.Wall_Down_Side_Top      = "Walls_Top/mist/Walls.Down.Top_0001.png",
}

MASK_PATHS :: [Mask]cstring {
	.None          = "Walls_Mask/diffuse/Walls.Mask.None_0001.png",
	.Cutaway_Left  = "Walls_Mask/diffuse/Walls.Mask.Cutaway.Left_0001.png",
	.Cutaway_Right = "Walls_Mask/diffuse/Walls.Mask.Cutaway.Right_0001.png",
	.Door          = "Walls_Mask/diffuse/Walls.Mask.Door_0001.png",
	.Down          = "Walls_Mask/diffuse/Walls.Mask.Down_0001.png",
	.Down_Short    = "Walls_Mask/diffuse/Walls.Mask.Down.Short_0001.png",
	.Up_Short      = "Walls_Mask/diffuse/Walls.Mask.Up.Short_0001.png",
	.Window        = "Walls_Mask/diffuse/Walls.Mask.Window_0001.png",
}

BILLBOARDS :: [Model][Orientation][]Texture {
	.Wood_Door =  {
		.South = {.Wood_Door_1_S, .Wood_Door_2_S},
		.East = {.Wood_Door_1_E, .Wood_Door_2_E},
		.North = {.Wood_Door_1_N, .Wood_Door_2_N},
		.West = {.Wood_Door_1_W, .Wood_Door_2_W},
	},
	.Wood_Window =  {
		.South = {.Wood_Window_1_S, .Wood_Window_2_S},
		.East = {.Wood_Window_1_E, .Wood_Window_2_E},
		.North = {.Wood_Window_1_N, .Wood_Window_2_N},
		.West = {.Wood_Window_1_W, .Wood_Window_2_W},
	},
	.Wood_Chair =  {
		.South = {.Wood_Chair_S},
		.East = {.Wood_Chair_E},
		.North = {.Wood_Chair_N},
		.West = {.Wood_Chair_W},
	},
	.Wood_Table_1x2 =  {
		.South = {.Wood_Table_1x2_1_S, .Wood_Table_1x2_2_S},
		.East = {.Wood_Table_1x2_1_E, .Wood_Table_1x2_2_E},
		.North = {.Wood_Table_1x2_1_N, .Wood_Table_1x2_2_N},
		.West = {.Wood_Table_1x2_1_W, .Wood_Table_1x2_2_W},
	},
	.Poutine_Painting =  {
		.South = {.Poutine_Painting_S},
		.East = {.Poutine_Painting_E},
		.North = {.Poutine_Painting_N},
		.West = {.Poutine_Painting_W},
	},
	.Wood_Counter =  {
		.South = {.Wood_Counter_S},
		.East = {.Wood_Counter_E},
		.North = {.Wood_Counter_N},
		.West = {.Wood_Counter_W},
	},
	.Small_Carpet =  {
		.South = {.Small_Carpet_S},
		.East = {.Small_Carpet_E},
		.North = {.Small_Carpet_N},
		.West = {.Small_Carpet_W},
	},
	.Tree =  {
		.South = {.Tree_1_S, .Tree_2_S, .Tree_3_S, .Tree_4_S},
		.East = {.Tree_1_E, .Tree_2_E, .Tree_3_E, .Tree_4_E},
		.North = {.Tree_1_N, .Tree_2_N, .Tree_3_N, .Tree_4_N},
		.West = {.Tree_1_W, .Tree_2_W, .Tree_3_W, .Tree_4_W},
	},
	.Wall_Side_Bricks012 =  {
		.South = {.Wall_Side_Bricks012},
		.East = {.Wall_Side_Bricks012},
		.North = {.Wall_Side_Bricks012},
		.West = {.Wall_Side_Bricks012},
	},
	.Wall_Side_Brick =  {
		.South = {.Wall_Side_Brick},
		.East = {.Wall_Side_Brick},
		.North = {.Wall_Side_Brick},
		.West = {.Wall_Side_Brick},
	},
	.Wall_Side_Dark_Blue =  {
		.South = {.Wall_Side_Dark_Blue},
		.East = {.Wall_Side_Dark_Blue},
		.North = {.Wall_Side_Dark_Blue},
		.West = {.Wall_Side_Dark_Blue},
	},
	.Wall_Side_Drywall =  {
		.South = {.Wall_Side_Drywall},
		.East = {.Wall_Side_Drywall},
		.North = {.Wall_Side_Drywall},
		.West = {.Wall_Side_Drywall},
	},
	.Wall_Side_Frame =  {
		.South = {.Wall_Side_Frame},
		.East = {.Wall_Side_Frame},
		.North = {.Wall_Side_Frame},
		.West = {.Wall_Side_Frame},
	},
	.Wall_Side_Marble001 =  {
		.South = {.Wall_Side_Marble001},
		.East = {.Wall_Side_Marble001},
		.North = {.Wall_Side_Marble001},
		.West = {.Wall_Side_Marble001},
	},
	.Wall_Side_Paint001 =  {
		.South = {.Wall_Side_Paint001},
		.East = {.Wall_Side_Paint001},
		.North = {.Wall_Side_Paint001},
		.West = {.Wall_Side_Paint001},
	},
	.Wall_Side_Paint002 =  {
		.South = {.Wall_Side_Paint002},
		.East = {.Wall_Side_Paint002},
		.North = {.Wall_Side_Paint002},
		.West = {.Wall_Side_Paint002},
	},
	.Wall_Side_Paint003 =  {
		.South = {.Wall_Side_Paint003},
		.East = {.Wall_Side_Paint003},
		.North = {.Wall_Side_Paint003},
		.West = {.Wall_Side_Paint003},
	},
	.Wall_Side_Paint004 =  {
		.South = {.Wall_Side_Paint004},
		.East = {.Wall_Side_Paint004},
		.North = {.Wall_Side_Paint004},
		.West = {.Wall_Side_Paint004},
	},
	.Wall_Side_Paint005 =  {
		.South = {.Wall_Side_Paint005},
		.East = {.Wall_Side_Paint005},
		.North = {.Wall_Side_Paint005},
		.West = {.Wall_Side_Paint005},
	},
	.Wall_Side_Paint006 =  {
		.South = {.Wall_Side_Paint006},
		.East = {.Wall_Side_Paint006},
		.North = {.Wall_Side_Paint006},
		.West = {.Wall_Side_Paint006},
	},
	.Wall_Side_Planks003 =  {
		.South = {.Wall_Side_Planks003},
		.East = {.Wall_Side_Planks003},
		.North = {.Wall_Side_Planks003},
		.West = {.Wall_Side_Planks003},
	},
	.Wall_Side_Planks011 =  {
		.South = {.Wall_Side_Planks011},
		.East = {.Wall_Side_Planks011},
		.North = {.Wall_Side_Planks011},
		.West = {.Wall_Side_Planks011},
	},
	.Wall_Side_Royal_Blue =  {
		.South = {.Wall_Side_Royal_Blue},
		.East = {.Wall_Side_Royal_Blue},
		.North = {.Wall_Side_Royal_Blue},
		.West = {.Wall_Side_Royal_Blue},
	},
	.Wall_Side_Tiles009 =  {
		.South = {.Wall_Side_Tiles009},
		.East = {.Wall_Side_Tiles009},
		.North = {.Wall_Side_Tiles009},
		.West = {.Wall_Side_Tiles009},
	},
	.Wall_Side_Tiles077 =  {
		.South = {.Wall_Side_Tiles077},
		.East = {.Wall_Side_Tiles077},
		.North = {.Wall_Side_Tiles077},
		.West = {.Wall_Side_Tiles077},
	},
	.Wall_Side_White =  {
		.South = {.Wall_Side_White},
		.East = {.Wall_Side_White},
		.North = {.Wall_Side_White},
		.West = {.Wall_Side_White},
	},
	.Wall_Side_White_Cladding =  {
		.South = {.Wall_Side_White_Cladding},
		.East = {.Wall_Side_White_Cladding},
		.North = {.Wall_Side_White_Cladding},
		.West = {.Wall_Side_White_Cladding},
	},
	.Wall_Side_Wood_Sidding002 =  {
		.South = {.Wall_Side_Wood_Sidding002},
		.East = {.Wall_Side_Wood_Sidding002},
		.North = {.Wall_Side_Wood_Sidding002},
		.West = {.Wall_Side_Wood_Sidding002},
	},
	.Wall_Diagonal_Bricks012 =  {
		.South = {.Wall_Diagonal_Bricks012},
		.East = {.Wall_Diagonal_Cross_Bricks012},
		.North = {.Wall_Diagonal_Bricks012},
		.West = {.Wall_Diagonal_Cross_Bricks012},
	},
	.Wall_Diagonal_Brick =  {
		.South = {.Wall_Diagonal_Brick},
		.East = {.Wall_Diagonal_Brick},
		.North = {.Wall_Diagonal_Brick},
		.West = {.Wall_Diagonal_Brick},
	},
	.Wall_Diagonal_Dark_Blue =  {
		.South = {.Wall_Diagonal_Dark_Blue},
		.East = {.Wall_Diagonal_Dark_Blue},
		.North = {.Wall_Diagonal_Dark_Blue},
		.West = {.Wall_Diagonal_Dark_Blue},
	},
	.Wall_Diagonal_Drywall =  {
		.South = {.Wall_Diagonal_Drywall},
		.East = {.Wall_Diagonal_Drywall},
		.North = {.Wall_Diagonal_Drywall},
		.West = {.Wall_Diagonal_Drywall},
	},
	.Wall_Diagonal_Frame =  {
		.South = {.Wall_Diagonal_Frame},
		.East = {.Wall_Diagonal_Frame},
		.North = {.Wall_Diagonal_Frame},
		.West = {.Wall_Diagonal_Frame},
	},
	.Wall_Diagonal_Marble001 =  {
		.South = {.Wall_Diagonal_Marble001},
		.East = {.Wall_Diagonal_Marble001},
		.North = {.Wall_Diagonal_Marble001},
		.West = {.Wall_Diagonal_Marble001},
	},
	.Wall_Diagonal_Paint001 =  {
		.South = {.Wall_Diagonal_Paint001},
		.East = {.Wall_Diagonal_Paint001},
		.North = {.Wall_Diagonal_Paint001},
		.West = {.Wall_Diagonal_Paint001},
	},
	.Wall_Diagonal_Paint002 =  {
		.South = {.Wall_Diagonal_Paint002},
		.East = {.Wall_Diagonal_Paint002},
		.North = {.Wall_Diagonal_Paint002},
		.West = {.Wall_Diagonal_Paint002},
	},
	.Wall_Diagonal_Paint003 =  {
		.South = {.Wall_Diagonal_Paint003},
		.East = {.Wall_Diagonal_Paint003},
		.North = {.Wall_Diagonal_Paint003},
		.West = {.Wall_Diagonal_Paint003},
	},
	.Wall_Diagonal_Paint004 =  {
		.South = {.Wall_Diagonal_Paint004},
		.East = {.Wall_Diagonal_Paint004},
		.North = {.Wall_Diagonal_Paint004},
		.West = {.Wall_Diagonal_Paint004},
	},
	.Wall_Diagonal_Paint005 =  {
		.South = {.Wall_Diagonal_Paint005},
		.East = {.Wall_Diagonal_Paint005},
		.North = {.Wall_Diagonal_Paint005},
		.West = {.Wall_Diagonal_Paint005},
	},
	.Wall_Diagonal_Paint006 =  {
		.South = {.Wall_Diagonal_Paint006},
		.East = {.Wall_Diagonal_Paint006},
		.North = {.Wall_Diagonal_Paint006},
		.West = {.Wall_Diagonal_Paint006},
	},
	.Wall_Diagonal_Planks003 =  {
		.South = {.Wall_Diagonal_Planks003},
		.East = {.Wall_Diagonal_Planks003},
		.North = {.Wall_Diagonal_Planks003},
		.West = {.Wall_Diagonal_Planks003},
	},
	.Wall_Diagonal_Planks011 =  {
		.South = {.Wall_Diagonal_Planks011},
		.East = {.Wall_Diagonal_Planks011},
		.North = {.Wall_Diagonal_Planks011},
		.West = {.Wall_Diagonal_Planks011},
	},
	.Wall_Diagonal_Royal_Blue =  {
		.South = {.Wall_Diagonal_Royal_Blue},
		.East = {.Wall_Diagonal_Royal_Blue},
		.North = {.Wall_Diagonal_Royal_Blue},
		.West = {.Wall_Diagonal_Royal_Blue},
	},
	.Wall_Diagonal_Tiles009 =  {
		.South = {.Wall_Diagonal_Tiles009},
		.East = {.Wall_Diagonal_Tiles009},
		.North = {.Wall_Diagonal_Tiles009},
		.West = {.Wall_Diagonal_Tiles009},
	},
	.Wall_Diagonal_Tiles077 =  {
		.South = {.Wall_Diagonal_Tiles077},
		.East = {.Wall_Diagonal_Tiles077},
		.North = {.Wall_Diagonal_Tiles077},
		.West = {.Wall_Diagonal_Tiles077},
	},
	.Wall_Diagonal_White =  {
		.South = {.Wall_Diagonal_White},
		.East = {.Wall_Diagonal_White},
		.North = {.Wall_Diagonal_White},
		.West = {.Wall_Diagonal_White},
	},
	.Wall_Diagonal_White_Cladding =  {
		.South = {.Wall_Diagonal_White_Cladding},
		.East = {.Wall_Diagonal_White_Cladding},
		.North = {.Wall_Diagonal_White_Cladding},
		.West = {.Wall_Diagonal_White_Cladding},
	},
	.Wall_Diagonal_Wood_Sidding002 =  {
		.South = {.Wall_Diagonal_Wood_Sidding002},
		.East = {.Wall_Diagonal_Wood_Sidding002},
		.North = {.Wall_Diagonal_Wood_Sidding002},
		.West = {.Wall_Diagonal_Wood_Sidding002},
	},
	.Wall_Diagonal_Cross_Bricks012 =  {
		.South = {.Wall_Diagonal_Cross_Bricks012},
		.East = {.Wall_Diagonal_Cross_Bricks012},
		.North = {.Wall_Diagonal_Cross_Bricks012},
		.West = {.Wall_Diagonal_Cross_Bricks012},
	},
	.Wall_Diagonal_Cross_Brick =  {
		.South = {.Wall_Diagonal_Cross_Brick},
		.East = {.Wall_Diagonal_Cross_Brick},
		.North = {.Wall_Diagonal_Cross_Brick},
		.West = {.Wall_Diagonal_Cross_Brick},
	},
	.Wall_Diagonal_Cross_Dark_Blue =  {
		.South = {.Wall_Diagonal_Cross_Dark_Blue},
		.East = {.Wall_Diagonal_Cross_Dark_Blue},
		.North = {.Wall_Diagonal_Cross_Dark_Blue},
		.West = {.Wall_Diagonal_Cross_Dark_Blue},
	},
	.Wall_Diagonal_Cross_Drywall =  {
		.South = {.Wall_Diagonal_Cross_Drywall},
		.East = {.Wall_Diagonal_Cross_Drywall},
		.North = {.Wall_Diagonal_Cross_Drywall},
		.West = {.Wall_Diagonal_Cross_Drywall},
	},
	.Wall_Diagonal_Cross_Frame =  {
		.South = {.Wall_Diagonal_Cross_Frame},
		.East = {.Wall_Diagonal_Cross_Frame},
		.North = {.Wall_Diagonal_Cross_Frame},
		.West = {.Wall_Diagonal_Cross_Frame},
	},
	.Wall_Diagonal_Cross_Marble001 =  {
		.South = {.Wall_Diagonal_Cross_Marble001},
		.East = {.Wall_Diagonal_Cross_Marble001},
		.North = {.Wall_Diagonal_Cross_Marble001},
		.West = {.Wall_Diagonal_Cross_Marble001},
	},
	.Wall_Diagonal_Cross_Paint001 =  {
		.South = {.Wall_Diagonal_Cross_Paint001},
		.East = {.Wall_Diagonal_Cross_Paint001},
		.North = {.Wall_Diagonal_Cross_Paint001},
		.West = {.Wall_Diagonal_Cross_Paint001},
	},
	.Wall_Diagonal_Cross_Paint002 =  {
		.South = {.Wall_Diagonal_Cross_Paint002},
		.East = {.Wall_Diagonal_Cross_Paint002},
		.North = {.Wall_Diagonal_Cross_Paint002},
		.West = {.Wall_Diagonal_Cross_Paint002},
	},
	.Wall_Diagonal_Cross_Paint003 =  {
		.South = {.Wall_Diagonal_Cross_Paint003},
		.East = {.Wall_Diagonal_Cross_Paint003},
		.North = {.Wall_Diagonal_Cross_Paint003},
		.West = {.Wall_Diagonal_Cross_Paint003},
	},
	.Wall_Diagonal_Cross_Paint004 =  {
		.South = {.Wall_Diagonal_Cross_Paint004},
		.East = {.Wall_Diagonal_Cross_Paint004},
		.North = {.Wall_Diagonal_Cross_Paint004},
		.West = {.Wall_Diagonal_Cross_Paint004},
	},
	.Wall_Diagonal_Cross_Paint005 =  {
		.South = {.Wall_Diagonal_Cross_Paint005},
		.East = {.Wall_Diagonal_Cross_Paint005},
		.North = {.Wall_Diagonal_Cross_Paint005},
		.West = {.Wall_Diagonal_Cross_Paint005},
	},
	.Wall_Diagonal_Cross_Paint006 =  {
		.South = {.Wall_Diagonal_Cross_Paint006},
		.East = {.Wall_Diagonal_Cross_Paint006},
		.North = {.Wall_Diagonal_Cross_Paint006},
		.West = {.Wall_Diagonal_Cross_Paint006},
	},
	.Wall_Diagonal_Cross_Planks003 =  {
		.South = {.Wall_Diagonal_Cross_Planks003},
		.East = {.Wall_Diagonal_Cross_Planks003},
		.North = {.Wall_Diagonal_Cross_Planks003},
		.West = {.Wall_Diagonal_Cross_Planks003},
	},
	.Wall_Diagonal_Cross_Planks011 =  {
		.South = {.Wall_Diagonal_Cross_Planks011},
		.East = {.Wall_Diagonal_Cross_Planks011},
		.North = {.Wall_Diagonal_Cross_Planks011},
		.West = {.Wall_Diagonal_Cross_Planks011},
	},
	.Wall_Diagonal_Cross_Royal_Blue =  {
		.South = {.Wall_Diagonal_Cross_Royal_Blue},
		.East = {.Wall_Diagonal_Cross_Royal_Blue},
		.North = {.Wall_Diagonal_Cross_Royal_Blue},
		.West = {.Wall_Diagonal_Cross_Royal_Blue},
	},
	.Wall_Diagonal_Cross_Tiles009 =  {
		.South = {.Wall_Diagonal_Cross_Tiles009},
		.East = {.Wall_Diagonal_Cross_Tiles009},
		.North = {.Wall_Diagonal_Cross_Tiles009},
		.West = {.Wall_Diagonal_Cross_Tiles009},
	},
	.Wall_Diagonal_Cross_Tiles077 =  {
		.South = {.Wall_Diagonal_Cross_Tiles077},
		.East = {.Wall_Diagonal_Cross_Tiles077},
		.North = {.Wall_Diagonal_Cross_Tiles077},
		.West = {.Wall_Diagonal_Cross_Tiles077},
	},
	.Wall_Diagonal_Cross_White =  {
		.South = {.Wall_Diagonal_Cross_White},
		.East = {.Wall_Diagonal_Cross_White},
		.North = {.Wall_Diagonal_Cross_White},
		.West = {.Wall_Diagonal_Cross_White},
	},
	.Wall_Diagonal_Cross_White_Cladding =  {
		.South = {.Wall_Diagonal_Cross_White_Cladding},
		.East = {.Wall_Diagonal_Cross_White_Cladding},
		.North = {.Wall_Diagonal_Cross_White_Cladding},
		.West = {.Wall_Diagonal_Cross_White_Cladding},
	},
	.Wall_Diagonal_Cross_Wood_Sidding002 =  {
		.South = {.Wall_Diagonal_Cross_Wood_Sidding002},
		.East = {.Wall_Diagonal_Cross_Wood_Sidding002},
		.North = {.Wall_Diagonal_Cross_Wood_Sidding002},
		.West = {.Wall_Diagonal_Cross_Wood_Sidding002},
	},
	.Wall_Cutaway_Left_Top =  {
		.South = {.Wall_Cutaway_Left_Top},
		.East = {.Wall_Cutaway_Left_Top},
		.North = {.Wall_Cutaway_Left_Top},
		.West = {.Wall_Cutaway_Left_Top},
	},
	.Wall_Cutaway_Right_Top =  {
		.South = {.Wall_Cutaway_Right_Top},
		.East = {.Wall_Cutaway_Right_Top},
		.North = {.Wall_Cutaway_Right_Top},
		.West = {.Wall_Cutaway_Right_Top},
	},
	.Wall_Diagonal_Cross_Top =  {
		.South = {.Wall_Diagonal_Cross_Top},
		.East = {.Wall_Diagonal_Cross_Top},
		.North = {.Wall_Diagonal_Cross_Top},
		.West = {.Wall_Diagonal_Cross_Top},
	},
	.Wall_Diagonal_Side_Top =  {
		.South = {.Wall_Diagonal_Side_Top},
		.East = {.Wall_Diagonal_Side_Top},
		.North = {.Wall_Diagonal_Side_Top},
		.West = {.Wall_Diagonal_Side_Top},
	},
	.Wall_Short_Top =  {
		.South = {.Wall_Short_Top},
		.East = {.Wall_Short_Top},
		.North = {.Wall_Short_Top},
		.West = {.Wall_Short_Top},
	},
	.Wall_Side_Top =  {
		.South = {.Wall_Side_Top},
		.East = {.Wall_Side_Top},
		.North = {.Wall_Side_Top},
		.West = {.Wall_Side_Top},
	},
	.Wall_Down_Short_Top =  {
		.South = {.Wall_Down_Short_Top},
		.East = {.Wall_Down_Short_Top},
		.North = {.Wall_Down_Short_Top},
		.West = {.Wall_Down_Short_Top},
	},
	.Wall_Down_Side_Top =  {
		.South = {.Wall_Down_Side_Top},
		.East = {.Wall_Down_Side_Top},
		.North = {.Wall_Down_Side_Top},
		.West = {.Wall_Down_Side_Top},
	},
}

DEPTH_MAPS :: [Model][Orientation][]Depth_Map {
	.Wood_Door =  {
		.South = {.Wood_Door_1_S, .Wood_Door_2_S},
		.East = {.Wood_Door_1_E, .Wood_Door_2_E},
		.North = {.Wood_Door_1_N, .Wood_Door_2_N},
		.West = {.Wood_Door_1_W, .Wood_Door_2_W},
	},
	.Wood_Window =  {
		.South = {.Wood_Window_1_S, .Wood_Window_2_S},
		.East = {.Wood_Window_1_E, .Wood_Window_2_E},
		.North = {.Wood_Window_1_N, .Wood_Window_2_N},
		.West = {.Wood_Window_1_W, .Wood_Window_2_W},
	},
	.Wood_Chair =  {
		.South = {.Wood_Chair_S},
		.East = {.Wood_Chair_E},
		.North = {.Wood_Chair_N},
		.West = {.Wood_Chair_W},
	},
	.Wood_Table_1x2 =  {
		.South = {.Wood_Table_1x2_1_S, .Wood_Table_1x2_2_S},
		.East = {.Wood_Table_1x2_1_E, .Wood_Table_1x2_2_E},
		.North = {.Wood_Table_1x2_1_N, .Wood_Table_1x2_2_N},
		.West = {.Wood_Table_1x2_1_W, .Wood_Table_1x2_2_W},
	},
	.Poutine_Painting =  {
		.South = {.Poutine_Painting_S},
		.East = {.Poutine_Painting_E},
		.North = {.Poutine_Painting_N},
		.West = {.Poutine_Painting_W},
	},
	.Wood_Counter =  {
		.South = {.Wood_Counter_S},
		.East = {.Wood_Counter_E},
		.North = {.Wood_Counter_N},
		.West = {.Wood_Counter_W},
	},
	.Small_Carpet =  {
		.South = {.Small_Carpet_S},
		.East = {.Small_Carpet_E},
		.North = {.Small_Carpet_N},
		.West = {.Small_Carpet_W},
	},
	.Tree =  {
		.South = {.Tree_1_S, .Tree_2_S, .Tree_3_S, .Tree_4_S},
		.East = {.Tree_1_E, .Tree_2_E, .Tree_3_E, .Tree_4_E},
		.North = {.Tree_1_N, .Tree_2_N, .Tree_3_N, .Tree_4_N},
		.West = {.Tree_1_W, .Tree_2_W, .Tree_3_W, .Tree_4_W},
	},
	.Wall_Side_Bricks012 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Brick =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Dark_Blue =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Drywall =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Frame =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Marble001 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Paint001 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Paint002 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Paint003 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Paint004 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Paint005 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Paint006 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Planks003 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Planks011 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Royal_Blue =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Tiles009 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Tiles077 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_White =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_White_Cladding =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Side_Wood_Sidding002 =  {
		.South = {.Wall_Side},
		.East = {.Wall_Side},
		.North = {.Wall_Side},
		.West = {.Wall_Side},
	},
	.Wall_Diagonal_Bricks012 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Brick =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Dark_Blue =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Drywall =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Frame =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Marble001 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Paint001 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Paint002 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Paint003 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Paint004 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Paint005 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Paint006 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Planks003 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Planks011 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Royal_Blue =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Tiles009 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Tiles077 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_White =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_White_Cladding =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Wood_Sidding002 =  {
		.South = {.Wall_Diagonal},
		.East = {.Wall_Diagonal},
		.North = {.Wall_Diagonal},
		.West = {.Wall_Diagonal},
	},
	.Wall_Diagonal_Cross_Bricks012 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Brick =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Dark_Blue =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Drywall =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Frame =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Marble001 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Paint001 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Paint002 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Paint003 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Paint004 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Paint005 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Paint006 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Planks003 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Planks011 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Royal_Blue =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Tiles009 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Tiles077 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_White =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_White_Cladding =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Diagonal_Cross_Wood_Sidding002 =  {
		.South = {.Wall_Diagonal_Cross},
		.East = {.Wall_Diagonal_Cross},
		.North = {.Wall_Diagonal_Cross},
		.West = {.Wall_Diagonal_Cross},
	},
	.Wall_Cutaway_Left_Top =  {
		.South = {.Wall_Cutaway_Left_Top},
		.East = {.Wall_Cutaway_Left_Top},
		.North = {.Wall_Cutaway_Left_Top},
		.West = {.Wall_Cutaway_Left_Top},
	},
	.Wall_Cutaway_Right_Top =  {
		.South = {.Wall_Cutaway_Right_Top},
		.East = {.Wall_Cutaway_Right_Top},
		.North = {.Wall_Cutaway_Right_Top},
		.West = {.Wall_Cutaway_Right_Top},
	},
	.Wall_Diagonal_Cross_Top =  {
		.South = {.Wall_Diagonal_Cross_Top},
		.East = {.Wall_Diagonal_Cross_Top},
		.North = {.Wall_Diagonal_Cross_Top},
		.West = {.Wall_Diagonal_Cross_Top},
	},
	.Wall_Diagonal_Side_Top =  {
		.South = {.Wall_Diagonal_Side_Top},
		.East = {.Wall_Diagonal_Side_Top},
		.North = {.Wall_Diagonal_Side_Top},
		.West = {.Wall_Diagonal_Side_Top},
	},
	.Wall_Short_Top =  {
		.South = {.Wall_Short_Top},
		.East = {.Wall_Short_Top},
		.North = {.Wall_Short_Top},
		.West = {.Wall_Short_Top},
	},
	.Wall_Side_Top =  {
		.South = {.Wall_Side_Top},
		.East = {.Wall_Side_Top},
		.North = {.Wall_Side_Top},
		.West = {.Wall_Side_Top},
	},
	.Wall_Down_Short_Top =  {
		.South = {.Wall_Down_Short_Top},
		.East = {.Wall_Down_Short_Top},
		.North = {.Wall_Down_Short_Top},
		.West = {.Wall_Down_Short_Top},
	},
	.Wall_Down_Side_Top =  {
		.South = {.Wall_Down_Side_Top},
		.East = {.Wall_Down_Side_Top},
		.North = {.Wall_Down_Side_Top},
		.West = {.Wall_Down_Side_Top},
	},
}

Object :: struct {
	pos:         glsl.ivec3,
	light:       glsl.vec3,
	parent:      glsl.ivec3,
	model:       Model,
	type:        Type,
	orientation: Orientation,
	placement:   Placement,
	texture:     Texture,
	depth_map:   Depth_Map,
	mask:        Mask,
	offset_y:    f32,
}

Chunk :: struct {
	objects:  [dynamic]Object,
	vao, ibo: u32,
	dirty:    bool,
}

Chunks :: [c.CHUNK_HEIGHT][c.WORLD_CHUNK_WIDTH][c.WORLD_CHUNK_DEPTH]Chunk

Uniform_Object :: struct {
	view_proj: glsl.mat4,
}

Vertex :: struct {
	pos:       glsl.vec3,
	texcoords: glsl.vec2,
}

VERTEX_SHADER_PATH :: "resources/shaders/object.vert"
FRAGMENT_SHADER_PATH :: "resources/shaders/object.frag"
MODEL_PATH :: "resources/models/billboard.glb"

chunks: Chunks
shader_program: u32
ubo: u32
uniform_object: Uniform_Object
indices: [6]u8
vertices: [4]Vertex
vbo, ebo: u32
texture_array: u32
depth_map_texture_array: u32
mask_texture_array: u32

init :: proc() -> (ok: bool = true) {
	// gl.Enable(gl.MULTISAMPLE)

	load_model() or_return

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(Vertex),
		&vertices,
		gl.STATIC_DRAW,
	)

	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	defer gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(u8),
		&indices,
		gl.STATIC_DRAW,
	)


	gl.GenTextures(1, &texture_array)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)
	load_texture_array(DIFFUSE_PATHS) or_return

	gl.GenTextures(1, &depth_map_texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, depth_map_texture_array)
	load_depth_map_texture_array() or_return

	gl.GenTextures(1, &mask_texture_array)
	gl.ActiveTexture(gl.TEXTURE2)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, mask_texture_array)
	load_texture_array(MASK_PATHS) or_return

	renderer.load_shader_program(
		&shader_program,
		VERTEX_SHADER_PATH,
		FRAGMENT_SHADER_PATH,
	) or_return


	gl.Uniform1i(gl.GetUniformLocation(shader_program, "texture_sampler"), 0)
	gl.Uniform1i(
		gl.GetUniformLocation(shader_program, "depth_map_texture_sampler"),
		1,
	)
	gl.Uniform1i(
		gl.GetUniformLocation(shader_program, "mask_texture_sampler"),
		2,
	)

	gl.GenBuffers(1, &ubo)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.UseProgram(0)

	for z in 0 ..< c.WORLD_HEIGHT {
		for x in 0 ..< c.WORLD_CHUNK_WIDTH {
			for y in 0 ..< c.WORLD_CHUNK_DEPTH {
				init_chunk(&chunks[z][x][y])
			}
		}
	}

	add({3, 0, 3}, .Wood_Chair, .South, .Floor)
	add({4, 0, 4}, .Wood_Chair, .East, .Floor)
	add({3, 0, 5}, .Wood_Chair, .North, .Floor)
	add({2, 0, 4}, .Wood_Chair, .West, .Floor)

	add({0, 0, 1}, .Wood_Table_1x2, .South, .Floor)
	add({2, 0, 0}, .Wood_Table_1x2, .North, .Floor)
	add({0, 0, 2}, .Wood_Table_1x2, .East, .Floor)
	add({1, 0, 4}, .Wood_Table_1x2, .West, .Floor)

	wall.set_wall(
		{5, 0, 5},
		.N_S,
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)
	wall.set_wall(
		{5, 0, 5},
		.E_W,
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)

	add({5, 0, 5}, .Wood_Window, .South, .Wall)
	add({5, 0, 5}, .Wood_Window, .West, .Wall)

	wall.set_wall(
		{7, 0, 5},
		.N_S,
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)
	wall.set_wall(
		{7, 0, 5},
		.E_W,
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)

	add({7, 0, 4}, .Wood_Window, .North, .Wall)
	add({6, 0, 5}, .Wood_Window, .East, .Wall)

	wall.set_wall(
		{9, 0, 5},
		.N_S,
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)
	wall.set_wall(
		{9, 0, 5},
		.E_W,
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)

	add({9, 0, 5}, .Wood_Door, .South, .Wall)
	add({9, 0, 5}, .Wood_Door, .West, .Wall)

	wall.set_wall(
		{11, 0, 5},
		.N_S,
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)
	wall.set_wall(
		{11, 0, 5},
		.E_W,
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)

	add({11, 0, 4}, .Wood_Door, .North, .Wall)
	add({10, 0, 5}, .Wood_Door, .East, .Wall)

	wall.set_wall(
		{13, 0, 5},
		.N_S,
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)
	wall.set_wall(
		{13, 0, 5},
		.E_W,
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)

	add({13, 0, 5}, .Poutine_Painting, .South, .Wall)
	add({13, 0, 5}, .Poutine_Painting, .West, .Wall)
	add({13, 0, 4}, .Poutine_Painting, .North, .Wall)
	add({12, 0, 5}, .Poutine_Painting, .East, .Wall)

	add({1, 0, 7}, .Wood_Counter, .South, .Floor)
	add({0, 0, 8}, .Wood_Counter, .West, .Floor)
	add({2, 0, 8}, .Wood_Counter, .East, .Floor)
	add({1, 0, 9}, .Wood_Counter, .North, .Floor)

	add({0, 0, 14}, .Wood_Counter, .West, .Floor)
	add({0, 0, 13}, .Wood_Counter, .West, .Floor)
	add({0, 0, 12}, .Wood_Counter, .West, .Floor)
	add({0, 0, 11}, .Wood_Counter, .West, .Floor)

	add({12, 0, 0}, .Small_Carpet, .South, .Floor)


	add({14, 0, 1}, .Tree, .South, .Floor)

	add({17, 0, 0}, .Tree, .North, .Floor)

	add({20, 0, 1}, .Tree, .East, .Floor)
	add({24, 0, 0}, .Tree, .West, .Floor)

	add({3, 0, 11}, .Wall_Side_Top, .South, .Floor)
	add({3, 0, 11}, .Wall_Side_Bricks012, .South, .Floor, mask = .Window)

	add({4, 0, 11}, .Wall_Cutaway_Left_Top, .South, .Floor)
	add({4, 0, 11}, .Wall_Side_Bricks012, .South, .Floor, mask = .Cutaway_Left)

	add({5, 0, 11}, .Wall_Down_Side_Top, .South, .Floor)
	add({5, 0, 11}, .Wall_Side_Bricks012, .South, .Floor, mask = .Down)

	add({6, 0, 11}, .Wall_Down_Short_Top, .South, .Floor)
	add({6, 0, 11}, .Wall_Side_Bricks012, .South, .Floor, mask = .Down_Short)

	add({3, 0, 11}, .Wood_Counter, .East, .Floor)

	add({3, 0, 11}, .Wall_Side_Top, .West, .Floor)
	add({3, 0, 11}, .Wall_Side_Bricks012, .West, .Floor)

	add({3, 0, 12}, .Wall_Side_Top, .West, .Floor)
	add({3, 0, 12}, .Wall_Side_Bricks012, .West, .Floor)

	add({3, 0, 13}, .Wall_Cutaway_Left_Top, .West, .Floor)
	add({3, 0, 13}, .Wall_Side_Bricks012, .West, .Floor, mask = .Cutaway_Left)

	add({3, 0, 14}, .Wall_Down_Side_Top, .West, .Floor)
	add({3, 0, 14}, .Wall_Side_Bricks012, .West, .Floor, mask = .Down)

	add({3, 0, 15}, .Wall_Down_Short_Top, .West, .Floor)
	add({3, 0, 15}, .Wall_Side_Bricks012, .West, .Floor, mask = .Down_Short)

	add({15, 0, 15}, .Wall_Side_Bricks012, .South, .Floor)
	add({15, 0, 15}, .Wall_Side_Bricks012, .West, .Floor)
	add({15, 0, 15}, .Wood_Counter, .East, .Floor)

	add({3, 0, 21}, .Wall_Diagonal_Side_Top, .South, .Floor)
	add({3, 0, 21}, .Wall_Diagonal_Bricks012, .South, .Floor)
	add({4, 0, 20}, .Wall_Diagonal_Side_Top, .South, .Floor)
	add({4, 0, 20}, .Wall_Diagonal_Bricks012, .South, .Floor)
	add({5, 0, 19}, .Wall_Diagonal_Side_Top, .South, .Floor)
	add({5, 0, 19}, .Wall_Diagonal_Bricks012, .South, .Floor)

	add({5, 0, 18}, .Wall_Diagonal_Cross_Top, .South, .Floor)
	add({5, 0, 18}, .Wall_Diagonal_Cross_Bricks012, .South, .Floor)

	// log.debug(can_add({0, 0, 1}, .Wood_Table_1x2, .South))
	// log.debug(can_add({0, 0, 0}, .Wood_Table_1x2, .North))
	// log.debug(can_add({1, 0, 0}, .Wood_Table_1x2, .West))
	// log.debug(can_add({1, 0, 0}, .Wood_Table_1x2, .East))
	// log.debug(can_add({3, 0, 4}, .Wood_Table_1x2, .East))

	return true
}

init_chunk :: proc(using chunk: ^Chunk) {
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)

	gl.GenBuffers(1, &ibo)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(
		0,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, pos),
	)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, texcoords),
	)

	gl.BindBuffer(gl.ARRAY_BUFFER, ibo)

	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(
		2,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, position),
	)

	gl.EnableVertexAttribArray(3)
	gl.VertexAttribPointer(
		3,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, light),
	)

	gl.EnableVertexAttribArray(4)
	gl.VertexAttribPointer(
		4,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, texture),
	)

	gl.EnableVertexAttribArray(5)
	gl.VertexAttribPointer(
		5,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, depth_map),
	)

	gl.EnableVertexAttribArray(6)
	gl.VertexAttribPointer(
		6,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, mirror),
	)

	gl.EnableVertexAttribArray(7)
	gl.VertexAttribPointer(
		7,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, mask),
	)

	gl.VertexAttribDivisor(2, 1)
	gl.VertexAttribDivisor(3, 1)
	gl.VertexAttribDivisor(4, 1)
	gl.VertexAttribDivisor(5, 1)
	gl.VertexAttribDivisor(6, 1)
	gl.VertexAttribDivisor(7, 1)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
}

get_draw_texture :: proc(using v: Object) -> f32 {
	if type == .Wall || type == .Wall_Top {
        billboards:= BILLBOARDS
		texture := billboards[model][Orientation(camera.rotation)][0]
		// #partial switch model {
		// case .Wall_Cutaway_Left:
		// 	#partial switch camera.rotation {
		// 	case .South_East:
		// 		if orientation == .South {
		// 			texture = .Wall_Cutaway_Right
		// 		}
		// 	case .North_East:
		// 		texture = .Wall_Cutaway_Right
		// 	case .North_West:
		// 		if orientation == .West {
		// 			texture = .Wall_Cutaway_Right
		// 		}
		// 	}
		// case .Wall_Cutaway_Right:
		// 	#partial switch camera.rotation {
		// 	case .South_East:
		// 		if orientation == .South {
		// 			texture = .Wall_Cutaway_Left
		// 		}
		// 	case .North_East:
		// 		texture = .Wall_Cutaway_Left
		// 	case .North_West:
		// 		if orientation == .West {
		// 			texture = .Wall_Cutaway_Left
		// 		}
		// 	}
		// }
		return f32(texture)
	}
	family := (int(texture) / 4) * 4
	index := int(texture) - family
	return f32(family + (index + int(camera.rotation)) % 4)
}

get_draw_depth_map_texture :: proc(using v: Object) -> f32 {
	if type == .Wall || type == .Wall_Top {
		texture := depth_map
		// #partial switch model {
		// case .Wall_Cutaway_Left:
		// 	#partial switch camera.rotation {
		// 	case .South_East:
		// 		if orientation == .South {
		// 			texture = .Wall_Cutaway_Right
		// 		}
		// 	case .North_East:
		// 		texture = .Wall_Cutaway_Right
		// 	case .North_West:
		// 		if orientation == .West {
		// 			texture = .Wall_Cutaway_Right
		// 		}
		// 	}
		// case .Wall_Cutaway_Right:
		// 	#partial switch camera.rotation {
		// 	case .South_East:
		// 		if orientation == .South {
		// 			texture = .Wall_Cutaway_Left
		// 		}
		// 	case .North_East:
		// 		texture = .Wall_Cutaway_Left
		// 	case .North_West:
		// 		if orientation == .West {
		// 			texture = .Wall_Cutaway_Left
		// 		}
		// 	}
		// }
		return f32(texture)
	}
	family := (int(depth_map) / 4) * 4
	index := int(depth_map) - family
	return f32(family + (index + int(camera.rotation)) % 4)

}

sort_objects :: proc(a, b: Object) -> bool {
	switch camera.rotation {
	case .South_West:
		if a.type == .Wall &&
		   b.type != .Wall &&
		   a.pos.x == b.pos.x &&
		   a.pos.z == b.pos.z {
			return false
		}
		if a.type != .Wall &&
		   b.type == .Wall &&
		   a.pos.x == b.pos.x &&
		   a.pos.z == b.pos.z {
			return true
		}
		return a.pos.z > b.pos.z || (a.pos.z == b.pos.z && a.pos.x > b.pos.x)
	case .South_East:
		if a.type == .Wall &&
		   b.type != .Wall &&
		   a.pos.x == b.pos.x &&
		   a.pos.z == b.pos.z {
			return a.orientation == .West
		}
		if a.type != .Wall &&
		   b.type == .Wall &&
		   a.pos.x == b.pos.x &&
		   a.pos.z == b.pos.z {
			return b.orientation == .South
		}
		if a.type == .Wall &&
		   b.type == .Wall &&
		   a.pos.x == b.pos.x &&
		   a.pos.z == b.pos.z {
			return a.orientation == .West
		}
		return a.pos.z > b.pos.z || (a.pos.z == b.pos.z && a.pos.x < b.pos.x)
	case .North_East:
		if a.type == .Wall &&
		   b.type != .Wall &&
		   a.pos.x == b.pos.x &&
		   a.pos.z == b.pos.z {
			return true
		}
		if a.type != .Wall &&
		   b.type == .Wall &&
		   a.pos.x == b.pos.x &&
		   a.pos.z == b.pos.z {
			return false
		}
		return a.pos.z < b.pos.z || (a.pos.z == b.pos.z && a.pos.x < b.pos.x)
	case .North_West:
		if a.type == .Wall &&
		   b.type != .Wall &&
		   a.pos.x == b.pos.x &&
		   a.pos.z == b.pos.z {
			return a.orientation == .South
		}
		if a.type != .Wall &&
		   b.type == .Wall &&
		   a.pos.x == b.pos.x &&
		   a.pos.z == b.pos.z {
			return b.orientation == .West
		}
		if a.type == .Wall &&
		   b.type == .Wall &&
		   a.pos.x == b.pos.x &&
		   a.pos.z == b.pos.z {
			return a.orientation == .South
		}
		return a.pos.z < b.pos.z || (a.pos.z == b.pos.z && a.pos.x > b.pos.x)
	}
	return false
}

get_instance :: proc(using v: Object) -> Instance {
	instance: Instance = {
		position = {f32(pos.x), f32(pos.y) + offset_y, f32(pos.z)},
		light = light,
		texture = get_draw_texture(v),
		depth_map = get_draw_depth_map_texture(v),
		mirror = 1,
		mask = f32(mask),
	}

	if type == .Wall || type == .Wall_Top {
		switch camera.rotation {
		case .South_West:
			if orientation == .West {
				instance.mirror = -1
			}
		case .South_East:
			if orientation == .West {
				instance.position.x -= 1
			} else {
				instance.mirror = -1
			}
		case .North_East:
			if orientation == .West {
				instance.position.x -= 1
				instance.mirror = -1
			} else {
				instance.position.z -= 1
			}
		case .North_West:
			if orientation == .South {
				instance.position.z -= 1
				instance.mirror = -1
			}
		}
	}

	return instance
}

draw_chunk :: proc(using chunk: ^Chunk) {
	instances := len(objects)

	if dirty {
		dirty = false


		gl.BindBuffer(gl.ARRAY_BUFFER, ibo)
		gl.BufferData(
			gl.ARRAY_BUFFER,
			instances * size_of(Instance),
			nil,
			gl.STATIC_DRAW,
		)

		slice.sort_by(objects[:], sort_objects)
		i := 0
		for v in objects {
			texture := f32(v.texture)
			instance := get_instance(v)
			gl.BufferSubData(
				gl.ARRAY_BUFFER,
				i * size_of(Instance),
				size_of(Instance),
				&instance,
			)
			i += 1
		}

		gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	}

	gl.BindVertexArray(vao)
	gl.DrawElementsInstanced(
		gl.TRIANGLES,
		i32(len(indices)),
		gl.UNSIGNED_BYTE,
		nil,
		i32(instances),
	)
	gl.BindVertexArray(0)
}

draw :: proc() {
	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	ubo_index := gl.GetUniformBlockIndex(shader_program, "UniformBufferObject")
	gl.UniformBlockBinding(shader_program, ubo_index, 2)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, ubo)

	uniform_object.view_proj = camera.view_proj

	gl.BufferData(
		gl.UNIFORM_BUFFER,
		size_of(Uniform_Object),
		&uniform_object,
		gl.STATIC_DRAW,
	)

	gl.UseProgram(shader_program)

	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)

	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, depth_map_texture_array)

	gl.ActiveTexture(gl.TEXTURE2)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, mask_texture_array)

	gl.DepthFunc(gl.ALWAYS)
	defer gl.DepthFunc(gl.LEQUAL)

	gl.Disable(gl.MULTISAMPLE)
	defer gl.Enable(gl.MULTISAMPLE)

	for floor in 0 ..< c.WORLD_HEIGHT {
		it := camera.make_visible_chunk_iterator()
		for pos in it->next() {
			draw_chunk(&chunks[floor][pos.x][pos.y])
		}
	}
}

load_model :: proc() -> (ok: bool = true) {
	options: cgltf.options
	data, result := cgltf.parse_file(options, MODEL_PATH)
	if result != .success {
		log.error("failed to parse file")
		return false
	}
	result = cgltf.load_buffers(options, data, MODEL_PATH)
	if result != .success {
		log.error("failed to load buffers")
		return false
	}
	defer cgltf.free(data)

	for mesh in data.meshes {
		primitive := mesh.primitives[0]
		if primitive.indices != nil {
			accessor := primitive.indices
			for i in 0 ..< accessor.count {
				index := cgltf.accessor_read_index(accessor, i)
				indices[i] = u8(index)
			}
		}

		for attribute in primitive.attributes {
			if attribute.type == .position {
				accessor := attribute.data
				for i in 0 ..< accessor.count {
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&vertices[i].pos),
						3,
					)
					vertices[i].pos.x *= -1
				}
			}
			if attribute.type == .texcoord {
				accessor := attribute.data
				for i in 0 ..< accessor.count {
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&vertices[i].texcoords),
						2,
					)
				}
			}
		}
	}

	log.info(vertices)

	return true
}

load_depth_map_texture_array :: proc() -> (ok: bool = true) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(
		gl.TEXTURE_2D_ARRAY,
		gl.TEXTURE_MIN_FILTER,
		gl.NEAREST_MIPMAP_NEAREST,
	)
	// gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAX_LEVEL, MIPMAP_LEVELS)
	// gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	// gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	// max_anisotropy: f32
	// gl.GetFloatv(gl.MAX_TEXTURE_MAX_ANISOTROPY, &max_anisotropy)
	// gl.TexParameterf(
	// 	gl.TEXTURE_2D_ARRAY,
	// 	gl.TEXTURE_MAX_ANISOTROPY,
	// 	max_anisotropy,
	// )

	paths := DEPTH_MAP_PATHS
	textures := i32(len(paths))

	if (textures == 0) {
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	width: i32 = WIDTH
	height: i32 = HEIGHT
	level: i32 = 0
	for level <= MIPMAP_LEVELS {
		gl.TexImage3D(
			gl.TEXTURE_2D_ARRAY,
			level,
			gl.R16,
			width,
			height,
			textures,
			0,
			gl.RED,
			gl.UNSIGNED_SHORT,
			nil,
		)

		width /= 2
		height /= 2
		level += 1
	}

	level = 0
	width = WIDTH
	height = HEIGHT
	defer free_all(context.temp_allocator)
	for level in 0 ..= MIPMAP_LEVELS {
		// gl.TexImage3D(
		// 	gl.TEXTURE_2D_ARRAY,
		// 	level,
		// 	gl.R16,
		// 	width,
		// 	height,
		// 	textures,
		// 	0,
		// 	gl.RED,
		// 	gl.UNSIGNED_SHORT,
		// 	nil,
		// )

		for path, i in paths {
			path := fmt.ctprint(
				OBJECTS_PATH,
				width,
				"x",
				height,
				"/",
				path,
				sep = "",
			)
			// defer delete(path)

			image_width: i32
			image_height: i32
			channels: i32
			pixels := stbi.load_16(
				path,
				&image_width,
				&image_height,
				&channels,
				1,
			)
			defer stbi.image_free(pixels)

			if pixels == nil {
				log.error("Failed to load texture: ", path)
				return false
			}

			if image_width != width {
				log.error(
					"Texture: ",
					path,
					" is of a different width. expected: ",
					width,
					" got: ",
					image_width,
				)
				return false
			}

			if image_height != height {
				log.error(
					"Texture: ",
					path,
					" is of a different height. expected: ",
					height,
					" got: ",
					image_height,
				)
				return false
			}

			gl.TexSubImage3D(
				gl.TEXTURE_2D_ARRAY,
				level,
				0,
				0,
				i32(i),
				width,
				height,
				1,
				gl.RED,
				gl.UNSIGNED_SHORT,
				pixels,
			)
		}

		width /= 2
		height /= 2
	}

	gl_error := gl.GetError()
	if (gl_error != gl.NO_ERROR) {
		log.error(
			"Error loading billboard depth map texture array: ",
			gl_error,
		)
		return false
	}

	return
}

load_texture_array :: proc(paths: [$T]cstring) -> (ok: bool = true) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(
		gl.TEXTURE_2D_ARRAY,
		gl.TEXTURE_MIN_FILTER,
		gl.NEAREST_MIPMAP_LINEAR,
		// gl.NEAREST,
	)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAX_LEVEL, MIPMAP_LEVELS)


	// paths := DIFFUSE_PATHS
	textures := i32(len(paths))

	if (textures == 0) {
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	defer free_all(context.temp_allocator)
	width: i32 = WIDTH
	height: i32 = HEIGHT
	level: i32 = 0
	for level <= MIPMAP_LEVELS {
		gl.TexImage3D(
			gl.TEXTURE_2D_ARRAY,
			level,
			gl.RGBA8,
			width,
			height,
			textures,
			0,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			nil,
		)

		width /= 2
		height /= 2
		level += 1
	}

	level = 0
	width = WIDTH
	height = HEIGHT
	for level <= MIPMAP_LEVELS {
		// gl.TexImage3D(
		// 	gl.TEXTURE_2D_ARRAY,
		// 	level,
		// 	gl.RGBA8,
		// 	width,
		// 	height,
		// 	textures,
		// 	0,
		// 	gl.RGBA,
		// 	gl.UNSIGNED_BYTE,
		// 	nil,
		// )

		for path, i in paths {
			path := fmt.ctprint(
				OBJECTS_PATH,
				width,
				"x",
				height,
				"/",
				path,
				sep = "",
			)
			// log.info(path)
			// defer delete(path)

			image_width, image_height: i32
			pixels := stbi.load(path, &image_width, &image_height, nil, 4)
			defer stbi.image_free(pixels)

			if pixels == nil {
				log.error("Failed to load texture: ", path)
				return false
			}

			if image_width != width {
				log.error(
					"Texture: ",
					path,
					" is of a different width. expected: ",
					width,
					" got: ",
					image_width,
				)
				return false
			}

			if image_height != height {
				log.error(
					"Texture: ",
					path,
					" is of a different height. expected: ",
					height,
					" got: ",
					image_height,
				)
				return false
			}

			gl.TexSubImage3D(
				gl.TEXTURE_2D_ARRAY,
				level,
				0,
				0,
				i32(i),
				width,
				height,
				1,
				gl.RGBA,
				gl.UNSIGNED_BYTE,
				pixels,
			)
		}

		width /= 2
		height /= 2
		level += 1
	}

	gl_error := gl.GetError()
	if (gl_error != gl.NO_ERROR) {
		log.error("Error loading billboard texture array: ", gl_error)
		return false
	}

	// gl.GenerateMipmap(gl.TEXTURE_2D_ARRAY)

	return
}

relative_pos :: proc(x, z: i32, orientation: Orientation) -> glsl.ivec3 {
	switch orientation {
	case .South:
		return {-x, 0, -z}
	case .East:
		return {z, 0, -x}
	case .North:
		return {x, 0, z}
	case .West:
		return {-z, 0, x}
	}

	return {}
}

get_texture :: proc(
	x, z: i32,
	model: Model,
	orientation: Orientation,
) -> Texture {
	billboards := BILLBOARDS
	model_size := MODEL_SIZE
	size := model_size[model]

	return billboards[model][orientation][x * size.x + z]
}

get_depth_map :: proc(
	x, z: i32,
	model: Model,
	orientation: Orientation,
) -> Depth_Map {
	billboards := DEPTH_MAPS
	model_size := MODEL_SIZE
	size := model_size[model]

	return billboards[model][orientation][x * size.x + z]
}

add :: proc(
	pos: glsl.ivec3,
	model: Model,
	orientation: Orientation,
	placement: Placement,
	mask: Mask = .None,
	offset_y: f32 = 0,
) {
	type_map := TYPE_MAP
	model_size := MODEL_SIZE

	parent := pos
	size := model_size[model]
	type := type_map[model]
	for x in 0 ..< size.x {
		for y in 0 ..< size.y {
			pos := pos + relative_pos(x, y, orientation)
			chunk := &chunks[pos.y][pos.x / c.CHUNK_WIDTH][pos.z / c.CHUNK_DEPTH]
			append(
				&chunk.objects,
				Object {
					pos = pos,
					type = type,
					model = model,
					orientation = orientation,
					placement = placement,
					texture = get_texture(x, y, model, orientation),
					depth_map = get_depth_map(x, y, model, orientation),
					parent = parent,
					light = {1, 1, 1},
					mask = mask,
					offset_y = offset_y,
				},
			)
			chunk.dirty = true
		}
	}

	on_add(pos, model, orientation)
}

on_add :: proc(pos: glsl.ivec3, model: Model, orientation: Orientation) {
	type_map := TYPE_MAP
	type := type_map[model]

	if type != .Window && type != .Door {
		return
	}

	switch orientation {
	case .South, .North:
		pos := pos
		if orientation == .North {
			pos += {0, 0, 1}
		}
		if w, ok := wall.get_wall(pos, .E_W); ok {
			if type == .Window {
				w.mask = .Window_Opening
			} else {
				w.mask = .Door_Opening
			}
			wall.set_wall(pos, .E_W, w)
		}
	case .East, .West:
		pos := pos
		if orientation == .East {
			pos += {1, 0, 0}
		}
		if w, ok := wall.get_wall(pos, .N_S); ok {
			if type == .Window {
				w.mask = .Window_Opening
			} else {
				w.mask = .Door_Opening
			}
			wall.set_wall(pos, .N_S, w)
		}
	}
}

can_add_on_wall :: proc(
	pos: glsl.ivec3,
	model: Model,
	orientation: Orientation,
) -> bool {
	model_size := MODEL_SIZE

	size := model_size[model]
	for x in 0 ..< size.x {
		switch orientation {
		case .South, .North:
			pos := pos + {x, 0, 0}
			if orientation == .North {
				pos += {0, 0, 1}
			}
			if !wall.has_east_west_wall(pos) {
				return false
			}
		case .East, .West:
			pos := pos + {0, 0, x}
			if orientation == .East {
				pos += {1, 0, 0}
			}
			if !wall.has_north_south_wall(pos) {
				return false
			}
		}

		for y in 0 ..< size.y {
			pos := pos + relative_pos(x, y, orientation)
			chunk := &chunks[pos.y][pos.x / c.CHUNK_WIDTH][pos.z / c.CHUNK_DEPTH]

			obstacle_orientation := orientation
			if y != 0 {
				obstacle_orientation = Orientation(int(orientation) + 2 % 4)
			}
			for k, v in chunk.objects {
				if k.pos == pos &&
				   k.placement == .Wall &&
				   k.orientation == obstacle_orientation {
					return false
				}
			}
		}
	}

	return true
}

can_add_on_floor :: proc(
	pos: glsl.ivec3,
	model: Model,
	orientation: Orientation,
) -> bool {
	model_size := MODEL_SIZE

	size := model_size[model]
	for x in 0 ..< size.x {
		for y in 0 ..< size.y {
			pos := pos + relative_pos(x, y, orientation)
			chunk := &chunks[pos.y][pos.x / c.CHUNK_WIDTH][pos.z / c.CHUNK_DEPTH]

			for k, v in chunk.objects {
				if k.pos == pos && k.placement == .Floor {
					return false
				}
			}
		}
	}

	return true
}

on_rotation :: proc() {
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	for v, i in vertices {
		v := v
		rotation := glsl.mat4Rotate(
			{0, 1, 0},
			(math.PI / 2) * f32(camera.rotation),
		)
		v.pos = (glsl.vec4{v.pos.x, v.pos.y, v.pos.z, 1} * rotation).xyz
		gl.BufferSubData(
			gl.ARRAY_BUFFER,
			i * size_of(Vertex),
			size_of(Vertex),
			&v,
		)
	}
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	for &y in chunks {
		for &x in y {
			for &z in x {
				z.dirty = true
			}
		}
	}
}
