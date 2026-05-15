package waveforms

import "core:math"
import "../mathx"

explicit_harmonics :: proc(harmonics: []f32, volume_limiter: f32, phase: f32) -> f32 {
    val: f32
    i := f32(1)
    for n in harmonics {
        val += i * (1.0 / f32(n)) * math.sin(2.0 * math.PI * phase * f32(n))
    }

    val /= volume_limiter

    return val
}

test :: proc(phase: f32) -> f32 {
    return 0
}