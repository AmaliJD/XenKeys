package mathx

import "core:math"

lerp :: #force_inline proc (a, b, t: f32) -> f32
{
    return a + (b - a) * t
}

inverse_lerp :: #force_inline proc(min, max, value: f32) -> f32
{
    return (value - min) / (max - min)
}

remap :: #force_inline proc(value, in_min, in_max, out_min, out_max: f32) -> f32
{
    t := inverse_lerp(in_min, in_max, value)
    return math.lerp(out_min, out_max, t)
}