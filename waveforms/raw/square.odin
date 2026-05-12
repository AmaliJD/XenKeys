package raw

import "core:math"
import "../../mathx"


// ----------------------------------------------------------------------------------- square
square :: proc(phase: f32) -> f32
{
    return 1 if phase < .5 else -1
}


// ----------------------------------------------------------------------------------- square duty cycle
square_shift_duty_cycle :: proc(phase, warp: f32) -> f32
{
    _warp := mathx.remap(warp, 0, 1, .5, 1)
    return 1 if phase < math.clamp(_warp, PULSE_LOW_LIMIT, PULSE_HIGH_LIMIT) else -1
}


// ----------------------------------------------------------------------------------- morph to sine
square_to_sine :: proc(phase, warp: f32) -> f32
{
    return sine_to_square(phase, 1 - warp)
}


// ----------------------------------------------------------------------------------- morph to triangle
square_to_triangle :: proc(phase, warp: f32) -> f32
{
    return triangle_to_square(phase, 1 - warp)
}


// ----------------------------------------------------------------------------------- morph to saw
square_to_saw :: proc(phase, warp: f32) -> f32
{
    return saw_to_square(phase, 1 - warp)
}