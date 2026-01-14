package main

import "core:fmt"
import rl "vendor:raylib"

Input_Source :: enum {
	UNKNOWN,
	KEYBOARD,
	GAMEPAD,
}

Input :: struct {
	turn_left, turn_right, go_forward, go_back, brake: bool,
	joy_deadzone, trg_deadzone, sensitivity:           f32,
	gamepad_id:                                        i32,
}

keyboard_controls :: proc() {
	if rl.IsKeyDown(.A) do gs.input.turn_left = true
	if rl.IsKeyDown(.D) do gs.input.turn_right = true
	if rl.IsKeyDown(.W) do gs.input.go_forward = true
	if rl.IsKeyDown(.S) do gs.input.go_back = true
	if rl.IsKeyDown(.SPACE) do gs.input.brake = true
}

gamepad_controls :: proc() {
	if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .LEFT_X) < -gs.input.joy_deadzone do gs.input.turn_left = true
	if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .LEFT_X) > gs.input.joy_deadzone do gs.input.turn_right = true
	if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .RIGHT_TRIGGER) > gs.input.trg_deadzone do gs.input.go_forward = true
	if rl.GetGamepadAxisMovement(gs.input.gamepad_id, .LEFT_TRIGGER) > gs.input.trg_deadzone do gs.input.go_back = true
}


input_auto_switch :: proc() {
	//
	//  NOTE: Need to create option to change&lock input type
	//

	if rl.GetKeyPressed() != .KEY_NULL {
		gs.input_src = .KEYBOARD
	}

	if rl.IsGamepadAvailable(gs.input.gamepad_id) {
		if rl.GetGamepadButtonPressed() != .UNKNOWN {
			gs.input_src = .GAMEPAD
		}
	}
}
