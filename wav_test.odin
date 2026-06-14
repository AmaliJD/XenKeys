package main

import "core:math/rand"
import "core:math"
import "mathx"

// ----------------------------------------------------------------------------------- waveform type
Wav_Test :: struct
{
    harmonics: [32]f32,
    amplitudes: [32]f32,
}


// ----------------------------------------------------------------------------------- get value
get_wav_test :: get_wav_smooth_random_walk

@private
get_wav_zero :: proc() -> f32
{
    return 0
}

@private random_targets: [4]i16
@private sample_count: u32
@private sample_wrap :: u32(440)

@private
get_wav_smooth_random_walk :: proc() -> f32
{
    if (sample_count == 0)
    {
        random_targets[0] = random_targets[1]
        random_targets[1] = random_targets[2]
        random_targets[2] = random_targets[3]
        random_targets[3] = i16(mathx.rand_float32_magnitude_1() * f32(max(i16)))
    }
    t := f32(sample_count) / f32(sample_wrap)
    sample_count = (sample_count + 1) % sample_wrap

    p0 := f32(random_targets[0]) / f32(max(i16))
    p1 := f32(random_targets[1]) / f32(max(i16))
    p2 := f32(random_targets[2]) / f32(max(i16))
    p3 := f32(random_targets[3]) / f32(max(i16))

    return get_cubic_value(p0, p1, p2, p3, t)
}

@private
get_cubic_value :: proc(p0, p1, p2, p3, t: f32) -> f32
{
    t2 := t * t
    t3 := t2 * t

    c0 := -0.5 * p0 + 1.5 * p1 - 1.5 * p2 + 0.5 * p3
    c1 := p0 - 2.5 * p1 + 2.0 * p2 - 0.5 * p3
    c2 := -0.5 * p0 + 0.5 * p2
    c3 := p1

    return (c0 * t3) + (c1 * t2) + (c2 * t) + c3
}