package main

import fmt "core:fmt"
import rl "vendor:raylib"

Scene :: enum {
	MENU,
	GAME,
	EDITOR,
}

draw_scene :: proc() {
	rl.DrawModelEx(
		gs.player.model,
		gs.player.pos,
		{0, 1, 0},
		gs.player.rotation_angle,
		gs.player.scale,
		rl.RED,
	)
	rl.DrawGrid(1000, 0.5)
}
