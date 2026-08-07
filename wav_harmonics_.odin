package main

import "core:math"
import "mathx"

primes := [64]f32{
    1,2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,
    101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,
    211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,
    307,
} // len 64


// ----------------------------------------------------------------------------------- waveform type
Wav_Harmonics :: struct
{
    preset: Preset_Harmonics,
    harmonics: i32
}

Preset_Harmonics :: enum
{
    Sine,
    Triangle,
    Square,
    Saw,
    Octave_Organ,
    Prime,
    Fibonacci
}

// ----------------------------------------------------------------------------------- get value
get_wav_harmonics :: proc(wh: Wav_Harmonics, phase: f32) -> f32
{
    val: f32

    #partial switch wh.preset
    {
        case .Sine:
            val = get_sine_table(phase)
        case .Triangle:
            h : f32 = 1
            amp_sign : f32 = 1
            amp_sum: f32
            for i in 1..=wh.harmonics
            {
                curr_val := get_sine_table(phase * h)
                amp := amp_sign / (h * h)
                amp_sum += math.abs(amp)
                val += curr_val * amp

                h += 2
                amp_sign *= -1
            }

            val /= amp_sum

        case .Square:
            h : f32 = 1
            amp_sum: f32
            for i in 1..=wh.harmonics
            {
                curr_val := get_sine_table(phase * h)
                amp := 1 / h
                amp_sum += amp
                val += curr_val * amp

                h += 2
            }

            val /= amp_sum

        case .Saw:
            h : f32 = 1
            amp_sum: f32
            for i in 1..=wh.harmonics
            {
                curr_val := get_sine_table(phase * h)
                amp := 1 / h
                amp_sum += amp
                val += curr_val * amp

                h += 1
            }

            val /= amp_sum

        case .Octave_Organ:
            h : f32 = 1
            amp_sum: f32
            for i in 1..=wh.harmonics
            {
                curr_val := get_sine_table(phase * h)
                amp : f32 = 1 / h
                amp_sum += amp
                val += curr_val * amp

                h *= 2
            }

            val /= amp_sum

        case .Prime:
            h : f32 = 1
            amp_sum: f32
            amp_sign : f32 = 1
            for i in 1..=wh.harmonics
            {
                h = primes[i]
                curr_val := get_sine_table(phase * h)
                amp : f32 = amp_sign / (h)
                amp_sum += math.abs(amp)
                val += curr_val * amp
                amp_sign *= -1
            }

            val /= amp_sum
    }

    return val;
}