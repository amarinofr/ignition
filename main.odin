package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Entity :: struct {
	pos, vel, size:      Vec3,
	speed, accel, brake: f32,
	color:               rl.Color,
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

	gs.input.left = false
	gs.input.right = false
	gs.input.accel = false
	gs.input.back = false
	gs.input.brake = false

	//
	//  TODO: This can definitely be simplified.
	//
	#partial switch gs.input_src {
	case .KEYBOARD:
		gs.player.accel = 0.03
		gs.player.brake = 0.09

		if rl.IsKeyDown(.A) do gs.input.left = true
		if rl.IsKeyDown(.D) do gs.input.right = true
		if rl.IsKeyDown(.W) do gs.input.accel = true
		if rl.IsKeyDown(.S) do gs.input.back = true
		if rl.IsKeyDown(.SPACE) do gs.input.brake = true
	case .GAMEPAD:
		gs.player.accel =
			rl.GetGamepadAxisMovement(gs.input.gamepad_id, .RIGHT_TRIGGER) * gs.input.sensitivity
		gs.player.brake =
			rl.GetGamepadAxisMovement(gs.input.gamepad_id, .LEFT_TRIGGER) * gs.input.sensitivity

		if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .LEFT_X) < -gs.input.joy_deadzone {
			gs.input.left = true
		}
		if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .LEFT_X) > gs.input.joy_deadzone {
			gs.input.right = true
		}
		if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .RIGHT_TRIGGER) > gs.input.trg_deadzone {
			gs.input.accel = true
		}
		if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .LEFT_TRIGGER) > gs.input.trg_deadzone {
			gs.input.back = true
		}
	}
}

update :: proc() {
	gs.camera.target = gs.player.pos
	gs.camera.position.x = gs.player.pos.x
	gs.camera.position.z = 10 + gs.player.pos.z


	//
	// NOTE: This is working but can 100% be better. Think about it.
	//
	if gs.input.accel {
		gs.player.vel.z -= gs.player.accel * rl.GetFrameTime()
		gs.player.pos.z = gs.player.pos.z + gs.player.vel.z
	} else {
		gs.player.vel.z -= lerp(gs.player.vel.z, 0, 0.1)
		gs.player.pos.z = gs.player.pos.z + gs.player.vel.z
	}

	gs.player.vel.z = clamp(gs.player.vel.z, -0.2, 0.2)

	fmt.printfln("speed: %f", gs.player.vel.z)


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
