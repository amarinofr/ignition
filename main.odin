package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Direction :: enum {
	NORTH,
	SOUTH,
	EAST,
	WEST,
}

Physics :: struct {
	force, accel, mass, speed: f32,
	pos, vel, size:            Vec3,
}

Entity :: struct {
	using physics: Physics,
	is_running:    bool,
	color:         rl.Color,
}

GameState :: struct {
	screen:    [2]i32,
	camera:    rl.Camera3D,
	input_src: Input_Source,
	input:     Input,
	player:    Entity,
}

gs: ^GameState

main :: proc() {
	gs = new(GameState)

	gs.screen.x = 1280
	gs.screen.y = 720

	rl.InitWindow(gs.screen.x, gs.screen.y, "Ignition")
	rl.SetTargetFPS(60)

	gs.input.joy_deadzone = 0.005
	gs.input.trg_deadzone = 0.000001
	gs.input.sensitivity = 0.1

	gs.player.color = rl.GREEN
	gs.player.size = {1, 0.5, 1.65}
	gs.player.pos.y = 0.25

	gs.camera.position = {0, 10, 10}
	gs.camera.target = {0, 0, 0}
	gs.camera.up = {0, 1, 0}
	gs.camera.fovy = 45
	gs.camera.projection = .PERSPECTIVE

	for !rl.WindowShouldClose() {
		input()
		update()
		render()
	}

	rl.CloseWindow()
}

input :: proc() {
	input_auto_switch()

	gs.input.turn_left = false
	gs.input.turn_right = false
	gs.input.go_forward = false
	gs.input.go_back = false
	gs.input.brake = false
	gs.player.is_running = false

	//
	//  TODO: Come up with a way where I can define dynamically the
	// 		  keys, buttons and axes. Probably an array with the controls
	// 		  and then iterating through it to get the corresponding value?
	//
	#partial switch gs.input_src {
	case .KEYBOARD:
		if rl.IsKeyDown(.A) do gs.input.turn_left = true
		if rl.IsKeyDown(.D) do gs.input.turn_right = true
		if rl.IsKeyDown(.W) do gs.input.go_forward = true
		if rl.IsKeyDown(.S) do gs.input.go_back = true
		if rl.IsKeyDown(.SPACE) do gs.input.brake = true
	case .GAMEPAD:
		if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .LEFT_X) < -gs.input.joy_deadzone do gs.input.turn_left = true
		if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .LEFT_X) > gs.input.joy_deadzone do gs.input.turn_left = true
		if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .RIGHT_TRIGGER) > gs.input.trg_deadzone do gs.input.go_forward = true
		if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .LEFT_TRIGGER) > gs.input.trg_deadzone do gs.input.go_back = true
	}
}

update :: proc() {
	gs.camera.target = gs.player.pos
	gs.camera.position.x = gs.player.pos.x
	gs.camera.position.z = 10 + gs.player.pos.z
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(gs.camera)

	rl.DrawGrid(1000, 0.5)
	rl.DrawCubeV(gs.player.pos, gs.player.size, gs.player.color)

	rl.EndMode3D()

	rl.DrawText(fmt.ctprintf("INPUT: %s", gs.input_src), 20, 20, 14, rl.RED)

	rl.DrawFPS(700, 760)
	rl.EndDrawing()
}
