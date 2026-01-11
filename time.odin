package main

import rl "vendor:raylib"

lerp :: proc(curr, dest: f32, duration: f32) -> f32 {
	return (curr + (dest - curr) * duration) * rl.GetFrameTime()
}
