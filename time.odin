package main

import rl "vendor:raylib"

time_update :: #force_inline proc() {
	gs.time.delta = rl.GetFrameTime()
	gs.time.frame += 1
	gs.time.session += f64(gs.time.delta)

	gs.time.fps = int(rl.GetFPS())
}

lerp :: proc(curr, dest: f32, duration: f64) -> f32 {
	t := f32(gs.time.session / duration)
	x := curr + (dest - curr) * t

	return x
}
