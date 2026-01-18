package main

import rl "vendor:raylib"

Entity_ID :: distinct u64

Entity_Flags :: enum {
	STATIC,
	MOVING,
	TURNING,
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
	ID:                                                                Entity_ID,
	using physics:                                                     Physics,
	accel, brake, top_speed, bottom_speed, turn_angle, rotation_angle: f32,
	type:                                                              bit_set[Entity_Type],
	model:                                                             rl.Model,
	flags:                                                             bit_set[Entity_Flags],
	color:                                                             rl.Color,
}


setup_player :: proc() {
	gs.input.joy_deadzone = 0.005
	gs.input.trg_deadzone = 0.000001
	gs.input.sensitivity = 0.1

	gs.player.color = rl.GREEN
	gs.player.scale = {0.5, 0.5, 0.5}
	// gs.player.pos.y = 0.25
	gs.player.accel = 5
	gs.player.brake = 20
	gs.player.top_speed = 5
	gs.player.bottom_speed = 2
	gs.player.turn_angle = 45

	gs.camera.position = {0, 10, 0}
	gs.camera.target = {0, 0, 0}
	gs.camera.up = {0, 1, 0}
	gs.camera.fovy = 45
	gs.camera.projection = .PERSPECTIVE
}
