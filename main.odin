package main

import "core:fmt"
import rl "vendor:raylib"

Direction :: enum {
	NORTH,
	SOUTH,
	EAST,
	WEST,
}

Physics :: struct {
	accel, top_speed, steering_angle: f32,
	pos, vel, size:                   Vec3,
	rotation:                         Matrix,
}

Entity :: struct {
	using physics: Physics,
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
	gs.player.accel = 5
	gs.player.top_speed = 25
	gs.player.steering_angle = 0.15

	gs.camera.position = {0, 10, 0}
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

	// gs.player.vel.z = lerp(gs.player.vel.z, 0, gs.player.accel * 3)
	gs.input.turn_left = false
	gs.input.turn_right = false
	gs.input.go_forward = false
	gs.input.go_back = false
	gs.input.brake = false

	//
	//  TODO: Come up with a way where I can define dynamically the
	// 		  keys, buttons and axes. Probably an array with the controls
	// 		  and then iterating through it to get the corresponding value?
	//
	#partial switch gs.input_src {
	case .KEYBOARD:
		keyboard_controls()
	case .GAMEPAD:
		gamepad_controls()
	}

	if gs.input.go_forward {
		gs.player.vel.z += gs.player.accel * rl.GetFrameTime()
	}
	if gs.input.go_back {
		gs.player.vel.z -= gs.player.accel * rl.GetFrameTime()
	}
	if gs.input.brake {
		gs.player.vel.z -= (gs.player.accel * 4) * rl.GetFrameTime()
	}

	if gs.input.turn_left {
		// gs.player.rotation.z += gs.player.steering_angle
	}
}

update :: proc() {
	if gs.input.brake {
		gs.player.vel.z = clamp(gs.player.vel.z, 0, gs.player.top_speed)
	} else {
		gs.player.vel.z = clamp(gs.player.vel.z, -gs.player.top_speed / 4, gs.player.top_speed)
	}

	gs.player.pos.z += gs.player.vel.z * rl.GetFrameTime()

	fmt.printfln("VEL Z: %f", gs.player.vel.z)
	fmt.printfln("POS Z: %f", gs.player.pos.z)

	gs.camera.position.z = gs.player.pos.z - 10
	gs.camera.target = gs.player.pos

}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	rl.BeginMode3D(gs.camera)

	rl.DrawGrid(1000, 0.5)
	rl.DrawCubeV(gs.player.pos, gs.player.size, gs.player.color)
	rl.EndMode3D()


	if gs.input.go_forward {
		rl.DrawText("Forward", 20, 50, 18, rl.BLUE)
	}
	if gs.input.go_back {
		rl.DrawText("Back", 20, 50, 18, rl.BLUE)
	}
	if gs.input.brake {
		rl.DrawText("BRAKING", 20, 50, 18, rl.BLUE)
	}

	rl.DrawText(fmt.ctprintf("INPUT: %s", gs.input_src), 20, 20, 14, rl.RED)

	rl.DrawFPS(700, 760)
	rl.EndDrawing()
}
