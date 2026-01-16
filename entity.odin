package main

import rl "vendor:raylib"

Entity_ID :: distinct u64

Entity_Flags :: enum {
	STATIC,
	MOVING,
	MOVING_FORWARD,
	MOVING_BACKWARD,
	TURNING,
	TURNING_LEFT,
	TURNING_RIGHT,
	STOPPING,
	BRAKING,
}

Entity_Type :: enum {
	PLAYER,
	ENEMY,
	MAP_EFFECT,
	MAP_OBJECT,
}

Entity :: struct {
	ID:            Entity_ID,
	using physics: Physics,
	type:          bit_set[Entity_Type],
	model:         rl.Model,
	flags:         bit_set[Entity_Flags],
	color:         rl.Color,
}


setup_player :: proc() {
	gs.input.joy_deadzone = 0.005
	gs.input.trg_deadzone = 0.000001
	gs.input.sensitivity = 0.1

	gs.player.color = rl.GREEN
	gs.player.scale = {0.5, 0.5, 0.5}
	// gs.player.pos.y = 0.25
	gs.player.accel = 5
	gs.player.top_speed = 25
	gs.player.steering_angle = 0.15

	gs.camera.position = {0, 10, 0}
	gs.camera.target = {0, 0, 0}
	gs.camera.up = {0, 1, 0}
	gs.camera.fovy = 45
	gs.camera.projection = .PERSPECTIVE
}
