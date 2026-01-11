package main

import "core:fmt"
import rl "vendor:raylib"

Input_Source :: enum {
	UNKNOWN,
	KEYBOARD,
	GAMEPAD,
}

Input :: struct {
	gamepad_id:                              i32,
	joy_deadzone, trg_deadzone, sensitivity: f32,
	left, right, accel, back, brake:         bool,
}

input_auto_switch :: #force_inline proc() {
	//
	//  NOTE: Is there even a need for auto switch in a driving game?
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

//
//  NOTE: This is cool and all, but does it serve any purpose for this game?
//
// gamepad_moving :: proc(stick: f32) -> bool {
// 	if !(stick < -gs.input.joy_deadzone) && !(stick > gs.input.joy_deadzone) {
// 		return false
// 	}

// 	fmt.printfln("axis moving: %s", stick)

// 	return true
// }
