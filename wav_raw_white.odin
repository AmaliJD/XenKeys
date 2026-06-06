package main

import "core:math"
import "core:math/rand"
import "mathx"

@private white_value: f32
@private white_phase: f32

// ----------------------------------------------------------------------------------- white
white :: proc(phase: f32) -> f32
{
    //return rand.float32() * 2 - 1
    if phase != white_phase
    {
        white_value = rand.float32() * 2 - 1
        white_phase = phase
    }

    return white_value
}


// ----------------------------------------------------------------------------------- morph to pulse
white_to_pulse :: proc(phase, warp: f32) -> f32
{
    if phase < mathx.remap(warp, 0, 1, 0, PULSE_HIGH_LIMIT)
    {
        return 0
    }
    else
    {
        return white(phase)
    }
}


// ----------------------------------------------------------------------------------- morph to sine
white_to_sine :: proc(phase, warp: f32) -> f32
{
    return mathx.lerp(white(phase), sine(phase), warp)
    // return white_to_mixed(phase, warp, sine)
}


// ----------------------------------------------------------------------------------- morph to triangle
white_to_triangle :: proc(phase, warp: f32) -> f32
{
    return mathx.lerp(white(phase), triangle(phase), warp)
    // return white_to_mixed(phase, warp, triangle)
}


// ----------------------------------------------------------------------------------- morph to square
white_to_square :: proc(phase, warp: f32) -> f32
{
    return mathx.lerp(white(phase), square(phase), warp)
    // return white_to_mixed(phase, warp, square)
}


// ----------------------------------------------------------------------------------- morph to saw
white_to_saw :: proc(phase, warp: f32) -> f32
{
    return mathx.lerp(white(phase), saw(phase), warp)
    // return white_to_mixed(phase, warp, saw)
}


// ----------------------------------------------------------------------------------- morph to mixed - alternative 2-stage lerp
white_to_mixed :: proc(phase, warp: f32, wav_proc: proc(f32) -> f32) -> f32
{
    wav := wav_proc(phase)
    mixed := math.abs(white(phase) * wav) * math.sign(wav)
    if warp < .5
    {
        return mathx.lerp(white(phase), mixed, mathx.remap(warp, 0, .5, 0, 1))
    }
    else
    {
        return mathx.lerp(mixed, wav, mathx.remap(warp, .5, 1, 0, 1))
    }
}