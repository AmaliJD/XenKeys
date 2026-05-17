package mathx

import "core:math"

lerp :: #force_inline proc (a, b, t: f64) -> f64
{
    return a + (b - a) * t
}

inverse_lerp :: #force_inline proc(min, max, value: f64) -> f64
{
    return (value - min) / (max - min)
}

remap :: #force_inline proc(value, in_min, in_max, out_min, out_max: f64) -> f64
{
    t := inverse_lerp(in_min, in_max, value)
    return math.lerp(out_min, out_max, t)
}