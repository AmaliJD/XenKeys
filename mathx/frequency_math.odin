package mathx

import "core:math"

cent_log_scale: f64 = math.ln_f64(2) / 1200
degree_log_scale: f64 = math.ln_f64(2) / 360
semitone_log_scale: f64 = math.ln_f64(2) / 12
octave_log_scale: f64 = math.ln_f64(2)

add_cents :: proc(frequency, cents: f64) -> f64
{
    return frequency * math.exp(cent_log_scale * cents)
}

add_degrees :: proc(frequency, degrees: f64) -> f64
{
    return frequency * math.exp(degree_log_scale * degrees)
}

add_semitones :: proc(frequency, semitones: f64) -> f64
{
    return frequency * math.exp(semitone_log_scale * semitones)
}

add_octaves :: proc(frequency, octaves: f64) -> f64
{
    return frequency * math.exp(octave_log_scale * octaves)
}

add_intervals :: proc
{
    add_intervals_recomputed_log_scale,
    add_intervals_precomputed_log_scale,
}

@private
add_intervals_recomputed_log_scale :: proc(frequency, intervals, base, divisions: f64) -> f64
{
    return frequency * math.exp(get_interval_log_scale(base, divisions) * intervals)
}

@private
add_intervals_precomputed_log_scale :: proc(frequency, intervals, interval_log_scale: f64) -> f64
{
    return frequency * math.exp(interval_log_scale * intervals)
}

get_interval_log_scale :: proc(base, divisions: f64) -> f64
{
    if base <= 0 || divisions <= 0
    {
        return 0
    }

    return math.ln_f64(base) / divisions
}