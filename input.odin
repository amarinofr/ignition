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


input_auto_switch :: proc() {
	//
	//  NOTE: I need to create in the future the ability to choose which controller
	// 		   and if there's auto switching or not.
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
