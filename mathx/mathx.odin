package mathx

import "core:math"
import "core:math/rand"


// ----------------------------------------------------------------------------------- lerp
lerp :: proc
{
    lerp_32,
    lerp_64,
}

@private
lerp_32 :: #force_inline proc (a, b, t: f32) -> f32
{
    return a + (b - a) * t
}

@private
lerp_64 :: #force_inline proc (a, b, t: f64) -> f64
{
    return a + (b - a) * t
}


// ----------------------------------------------------------------------------------- inverse lerp
inverse_lerp :: proc
{
    inverse_lerp_32,
    inverse_lerp_64,
}

@private
inverse_lerp_32 :: #force_inline proc(min, max, value: f32) -> f32
{
    if max != min
    {
        return (value - min) / (max - min)
    }
    else
    {
        return 1
    }
}

@private
inverse_lerp_64 :: #force_inline proc(min, max, value: f64) -> f64
{
    if max != min
    {
        return (value - min) / (max - min)
    }
    else
    {
        return 1
    }
}


// ----------------------------------------------------------------------------------- remap
remap :: proc
{
    remap_32,
    remap_64,
}

@private
remap_32 :: #force_inline proc(value, in_min, in_max, out_min, out_max: f32) -> f32
{
    t := inverse_lerp(in_min, in_max, value)
    return math.lerp(out_min, out_max, t)
}

@private
remap_64 :: #force_inline proc(value, in_min, in_max, out_min, out_max: f64) -> f64
{
    t := inverse_lerp(in_min, in_max, value)
    return math.lerp(out_min, out_max, t)
}


// ----------------------------------------------------------------------------------- other
wrap_01 :: proc(val: f32) -> f32
{
    return val - math.floor(val)
}

clamp_01 :: proc(val: f32) -> f32
{
    if val > 1 {
        return 1
    }
    else if val < 0 {
        return 0
    }

    return val
}

ramp_up_pow :: proc(val: f32, pow: u8) -> f32
{
    t: f32 = 1
    for i in 0..<pow
    {
        t *= val
    }

    return t
}

ramp_down_pow :: proc(val: f32, pow: u8) -> f32
{
    t: f32 = 1
    for i in 0..<pow
    {
        t *= (1 - val)
    }

    return 1 - t
}

quantize :: proc(val: f32, steps: i32) -> f32
{
    if steps == 0 { return val }

    _steps := f32(steps)
    _val := math.round(val * _steps) / _steps
    return _val
}

quantize_unipolar :: proc(val: f32, steps: i32) -> f32
{
    if steps == 0 { return val }

    _steps := f32(steps)
    val_01 := (val + 1.0) * 0.5
    quantized_val_01 := math.round(val_01 * _steps) / _steps
    _val := (quantized_val_01 * 2.0) - 1.0
    return _val
}

rand_float32_magnitude_1 :: proc() -> f32
{
    return rand.float32() * 2 - 1
}

cubic_lerp :: proc(p0, p1, p2, p3, t: f32) -> f32
{
    t2 := t * t
    t3 := t2 * t

    c0 := -0.5 * p0 + 1.5 * p1 - 1.5 * p2 + 0.5 * p3
    c1 := p0 - 2.5 * p1 + 2.0 * p2 - 0.5 * p3
    c2 := -0.5 * p0 + 0.5 * p2
    c3 := p1

    return (c0 * t3) + (c1 * t2) + (c2 * t) + c3
}