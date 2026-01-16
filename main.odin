package main

import "core:fmt"
import "core:strings"
import "core:time"
import rl "vendor:raylib"

Physics :: struct {
	accel, top_speed, steering_angle: f32,
	pos, vel, scale:                  Vec3,
	rotation:                         Vec3,
}

GameState :: struct {
	time:      struct {
		delta:      f32,
		session:    f64,
		frame, fps: int,
	},
	screen:    [2]i32,
	camera:    rl.Camera3D,
	input_src: Input_Source,
	input:     Input,
	player:    Entity,
}

gs: ^GameState

load_model :: proc(file: cstring) -> rl.Model {
	model := rl.LoadModel(file)

	return model
}

main :: proc() {
	gs = new(GameState)

	gs.screen.x = 1280
	gs.screen.y = 720

	setup_player()

	rl.InitWindow(gs.screen.x, gs.screen.y, "Ignition")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	gs.player.model = load_model("./assets/Car.glb")

	for !rl.WindowShouldClose() {
		input()
		update()
		render()
	}
}

input :: proc() {
	input_auto_switch()

	gs.player.flags = {.STOPPING, .BRAKING}
	gs.input.go_forward = false
	gs.input.go_back = false
	gs.input.turn_left = false
	gs.input.turn_right = false
	gs.input.brake = false

	//
	//  @TODO: Come up with a way where I can define dynamically the
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
		gs.player.flags = {.MOVING, .MOVING_FORWARD}
	}
	if gs.input.go_back {
		gs.player.flags = {.MOVING, .MOVING_BACKWARD}
	}
	if gs.input.turn_left {
		gs.player.flags += {.TURNING, .TURNING_LEFT}
	}
	if gs.input.turn_right {
		gs.player.flags += {.TURNING, .TURNING_RIGHT}
	}
	if gs.input.brake {
		gs.player.flags = {.STOPPING, .BRAKING}
		fmt.println("BRAKING")
	}
}

update :: proc() {
	time_update()

	// if gs.player.flags == {} {
	// 	gs.player.flags = {.STOPPING, .BRAKING}
	// }

	if .MOVING in gs.player.flags {
		gs.player.vel.z = clamp(gs.player.vel.z, -gs.player.top_speed, gs.player.top_speed / 4)

		if .MOVING_FORWARD in gs.player.flags {
			gs.player.vel.z -= gs.player.accel * gs.time.delta
		}

		if .MOVING_BACKWARD in gs.player.flags {
			gs.player.vel.z += gs.player.accel * gs.time.delta
		}
	}

	if .TURNING in gs.player.flags {
		if .TURNING_LEFT in gs.player.flags {
			gs.player.rotation.x += 45 * gs.time.delta
		}

		if .TURNING_RIGHT in gs.player.flags {

		}
	}

	if .BRAKING in gs.player.flags {
		gs.player.vel.z = lerp(gs.player.vel.z, 0, (gs.player.accel * 0.001))

		if !(gs.player.vel.z < -0.5) && !(gs.player.vel.z > 0.5) {
			gs.player.flags = {.STATIC}
		}
	}

	if .STATIC in gs.player.flags {
		gs.player.vel.z = 0
	}


	gs.camera.position.z = 10 + gs.player.pos.z
	gs.camera.position.y = lerp(
		gs.camera.position.y,
		16 - abs(gs.player.vel.z * 0.5),
		gs.player.accel * 0.001,
	)
	gs.camera.position.y = clamp(gs.camera.position.y, 8, 10)
	// gs.camera.position.z = clamp(gs.camera.position.y, 5, 10)

	gs.camera.target = gs.player.pos

	gs.player.pos.z += gs.player.vel.z * gs.time.delta
	gs.player.rotation.z += gs.player.steering_angle
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	rl.BeginMode3D(gs.camera)

	draw_scene()

	rl.EndMode3D()

	// for flag in gs.player.flags {
	rl.DrawText(fmt.ctprint(gs.player.flags), 20, 20, 20, rl.BLACK)
	// }

	rl.DrawText(fmt.caprintf("SPEED: %f", gs.player.vel.z), 1100, 20, 20, rl.BLACK)
	rl.DrawText(fmt.ctprintf("INPUT: %s", gs.input_src), 20, 680, 14, rl.RED)

	rl.DrawFPS(700, 760)
	rl.EndDrawing()
}
