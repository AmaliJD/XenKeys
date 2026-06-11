package mathx

import "core:math"


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