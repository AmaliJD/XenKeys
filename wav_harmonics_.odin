package main

import "core:math"
import "mathx"

MAX_HARMONICS :: 64
harmonics_primes := [MAX_HARMONICS]f32{
    1,2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,
    101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,
    211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,
    307,
}


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
    Octaves,
    Chimes,
    Primes,
    Fibonacci,
    Test
}

// ----------------------------------------------------------------------------------- get value
get_wav_harmonics :: proc(wh: Wav_Harmonics, phase, pulse_mod: f32) -> f32
{
    val: f32
    n : f32 = 1
    amp_sign : f32 = 1
    amp_sum: f32

    #partial switch wh.preset
    {
        case .Sine:
            val = get_sine_table(phase)
            amp_sum = 1

        case .Triangle:
            for i in 1..=wh.harmonics
            {
                curr_val := get_sine_table(phase * n)

                amp := amp_sign / (n * n)
                amp_sum += math.abs(amp)
                val += curr_val * amp

                n += 2
                amp_sign *= -1
            }

        case .Square:
            // for i in 1..=wh.harmonics
            // {
            //     curr_val := get_sine_table(phase * n)

            //     amp := amp_sign / n
            //     amp_sum += math.abs(amp)
            //     val += curr_val * amp

            //     n += 2
            // }
            duty_cycle := mathx.remap(pulse_mod, 0, 1, .5, PULSE_LOW_LIMIT)
            for i in 1..=wh.harmonics
            {
                n_phase := n * phase - n * duty_cycle / 2 + .25
                curr_val := get_sine_table(n_phase)
                
                amp := (2 / (n * math.PI)) * get_sine_table(n * duty_cycle / 2)
                amp_sum += math.abs(amp)
                
                val += curr_val * amp

                n += 1
            }

        case .Saw:
            for i in 1..=wh.harmonics
            {
                curr_val := get_sine_table(phase * n)

                amp := amp_sign / n
                amp_sum += math.abs(amp)
                val += curr_val * amp

                n += 1
            }

        case .Octaves:
            for i in 1..=wh.harmonics
            {
                curr_val := get_sine_table(phase * n)

                amp : f32 = amp_sign / n
                amp_sum += math.abs(amp)
                val += curr_val * amp

                n *= 2
            }

        case .Primes:
            for i in 1..=wh.harmonics
            {
                n = harmonics_primes[i]

                curr_val := get_sine_table(phase * n)

                amp : f32 = amp_sign / (n)
                amp_sum += math.abs(amp)
                val += curr_val * amp
                
                amp_sign *= -1
            }

        case .Fibonacci:
            curr: f32 = 1
            prev: f32 = 0
            for i in 1..=wh.harmonics
            {
                n = curr
                curr_val := get_sine_table(phase * n)

                amp : f32 = amp_sign / (n)
                amp_sum += math.abs(amp)
                val += curr_val * amp
                
                temp := curr
                curr = curr + prev
                prev = temp
            }

        case .Chimes:
            for i in 1..=wh.harmonics
            {
                curr_val := get_sine_table(phase * n)

                amp := amp_sign / (n)
                amp_sum += math.abs(amp)
                val += curr_val * amp

                n *= 6
            }
        
        case .Test:
            for i in 1..=wh.harmonics
            {
                curr_val := get_sine_table(phase * n)

                amp := amp_sign / (n)
                amp_sum += math.abs(amp)
                val += curr_val * amp

                n *= 6
            }
    }

    val /= amp_sum
    return val;
}