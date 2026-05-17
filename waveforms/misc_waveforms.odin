package waveforms

import "core:math"
import "../mathx"

explicit_harmonics :: proc(harmonics: []f64, volume_limiter: f64, phase: f64) -> f64 {
    val: f64
    i := f64(1)
    for n in harmonics {
        val += i * (1.0 / n) * math.sin(2.0 * math.PI * phase * n)
    }

    val /= volume_limiter

    return val
}

test :: proc(phase: f64) -> f64 {
    return 0
}