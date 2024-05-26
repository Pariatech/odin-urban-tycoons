package ui

import "core:log"

help_window :: proc(using ctx: ^Context) {
	rect(
		ctx,
		{x = 175, y = 175, w = 500, h = 26, color = {0.0, 0.251, 0.502, 1}},
	)

	text(ctx, {175 + 500 / 2, 180}, "Help", .CENTER, .TOP, 16)

	if button(
		   ctx,
		   {175 + 500 - 22, 179},
		   {18, 18},
		   "x",
		   {0.255, 0.412, 0.882, 1},
		   txt_size = 26,
	   ) {
		log.info("button clicked!")
        help_window_opened = false
	}

	rect(
		ctx,
		{x = 175, y = 200, w = 500, h = 400, color = {0.255, 0.412, 0.882, 1}},
	)

	text(
		ctx,
		{185, 210},
		`---- Camera ----
W,A,S,D:      Move camera
Q,E:          Rotate camera
Mouse Scroll: Zoom

---- Terrain Tool [T] ----
Only work on grass tiles

Left Click:              Raise land
Right Click:             Lower land
+:                       Increase brush size
-:                       Reduce brush size
Shift +:                 Increase brush strength
Shift -:                 Reduce brush strength
Ctrl Click:              Smooth terrain
Shift Click & Drag:      Level terrain
Ctrl Shift Click & Drag: Flatten terrain

---- Wall Tool [G] ----
Left Click & Drag:              Place Wall
Shift Left Click & Drag:        Place Wall Rectangle
Ctrl Left Click & Drag:         Remove Wall
Ctrl Shift Left Click & Drag:   Remove Wall Rectangle
`,
		ah = .LEFT,
		av = .TOP,
		size = 18,
		clip_start = {185, 210},
		clip_end = {175 + 500 - 10, 200 + 400 - 10},
	)
}
