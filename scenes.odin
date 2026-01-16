package main

import fmt "core:fmt"
import rl "vendor:raylib"

Scene :: enum {
	MENU,
	GAME,
	EDITOR,
}

draw_scene :: proc() {
	rl.DrawModelEx(gs.player.model, gs.player.pos, gs.player.rotation, 0, gs.player.scale, rl.RED)
	rl.DrawGrid(1000, 0.5)
}
