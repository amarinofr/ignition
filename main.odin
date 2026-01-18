package main

import "core:fmt"
import "core:math"
import "core:strings"
import "core:time"
import rl "vendor:raylib"

MIN_STOPPING_VEL :: 0.5

Physics :: struct {
	pos, vel, scale, rotation: Vec3,
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
	gs.input.go_forward = false
	gs.input.go_back = false
	gs.input.turn_left = false
	gs.input.turn_right = false
	gs.input.brake = false
	gs.player.flags = {.STOPPING}


	//
	//  @TODO: Come up with a way where I can define dynamically the
	//	keys, buttons and axes. Probably an array with the controls
	//	and then iterating through it to get the corresponding value?
	//


	#partial switch gs.input_src {
	case .KEYBOARD:
		keyboard_controls()
	case .GAMEPAD:
		gamepad_controls()
	}

	if gs.input.go_forward || gs.input.go_back {
		gs.player.flags = {.MOVING}
	}
	if gs.input.turn_left || gs.input.turn_right {
		gs.player.flags += {.TURNING}
	}
	if gs.input.brake {
		gs.player.flags += {.STOPPING}
	}

	input_auto_switch()
}

update :: proc() {
	time_update()

	if .TURNING in gs.player.flags {
		if gs.input.turn_left {
			gs.player.rotation_angle += gs.player.turn_angle * gs.time.delta

			if gs.player.rotation_angle >= 180 {
				gs.player.rotation_angle = -180
			}
		}
		if gs.input.turn_right {
			gs.player.rotation_angle -= gs.player.turn_angle * gs.time.delta

			if gs.player.rotation_angle <= -180 {
				gs.player.rotation_angle = 180
			}
		}
	}

	if .MOVING in gs.player.flags {
		if gs.input.go_forward {
			gs.player.vel.z -= gs.player.accel * gs.time.delta
		}
		if gs.input.go_back {
			gs.player.vel.z += gs.player.accel * gs.time.delta
		}
		if gs.input.go_forward && gs.input.go_back {
			gs.player.flags += {.STOPPING}
		}
	}

	if .STOPPING in gs.player.flags {
		if gs.player.vel.z < -MIN_STOPPING_VEL {
			gs.player.vel.z += gs.player.brake * gs.time.delta
		} else if gs.player.vel.z > MIN_STOPPING_VEL {
			gs.player.vel.z -= gs.player.brake * gs.time.delta
		} else {
			gs.player.vel.z = lerp(gs.player.vel.z, 0, f64(gs.player.accel * 200))
			gs.player.flags = {.STATIC}
		}
	}

	if .STATIC in gs.player.flags {
		gs.player.vel.z = 0
		gs.player.vel.x = 0
	}

	fmt.printfln("rotation: %f", gs.player.rotation_angle)


	// gs.player.vel.x = clamp(gs.player.vel.x, -gs.player.top_speed, gs.player.top_speed)
	gs.player.vel.z = clamp(gs.player.vel.z, -gs.player.top_speed, gs.player.bottom_speed)
	gs.player.vel.x = gs.player.vel.z * gs.player.rotation_angle * gs.time.delta

	gs.player.pos += gs.player.vel * gs.time.delta


	//
	//	@TODO: Need to come up with a better way of animating the
	// 	camera when speed going faster. Currently was using this:
	//
	// gs.camera.position.y = lerp(
	// 	gs.camera.position.y,
	// 	16 - abs(gs.player.vel.z * 0.5),
	// 	gs.player.accel * 0.001,
	// )
	//
	gs.camera.position.z = gs.player.pos.z + 10
	gs.camera.position.x = gs.player.pos.x
	gs.camera.target = gs.player.pos
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	rl.BeginMode3D(gs.camera)

	draw_scene()

	rl.DrawFPS(700, 760)
	rl.EndMode3D()

	// for flag in gs.player.flags {
	rl.DrawText(fmt.ctprint(gs.player.flags), 20, 20, 20, rl.BLACK)
	// }

	rl.DrawText(fmt.caprintf("SPEED: %f", gs.player.vel), 900, 20, 20, rl.BLACK)
	rl.DrawText(fmt.ctprintf("INPUT: %s", gs.input_src), 20, 680, 14, rl.RED)

	rl.EndDrawing()
}
