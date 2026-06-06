package main

import "mathx"
import "logging"


// ----------------------------------------------------------------------------------- data
Waveform :: enum
{
    Sine,
    Triangle,   // odd harmonics, 1/n², alternating signs
    Square,     // odd harmonics, 1/n
    Saw,        // all harmonics, 1/n
    White,      // random
}

Waveform_Type :: union
{
    Wav_Raw,
    Wav_Harmonics,
    Wav_Sample,
    Wav_Sf,
}


// ----------------------------------------------------------------------------------- helpers
waveform_pair :: proc(wav_1, wav_2: Waveform) -> int
{
    return (int(wav_1) << 8) | int(wav_2)
}


// ----------------------------------------------------------------------------------- get wave
get_wav_value :: proc(wt1, wt2: Waveform_Type, phase, warp: f32, down_sample, bit_crush: i32, unscaled := false) -> f32
{
    value: f32
    _phase := mathx.quantize(phase, down_sample)

    #partial switch w1 in wt1
    {
        case nil:
            #partial switch w2 in wt2
            {
                case nil:
                    value = 0
                case Wav_Raw:
                    value = mathx.lerp(0, get_wav_raw(w2.waveform, _phase, unscaled), warp)
            }

        case Wav_Raw:
            #partial switch w2 in wt2
            {
                case nil:
                    value = mathx.lerp(get_wav_raw(w1.waveform, _phase, unscaled), 0, warp)
                case Wav_Raw:
                    value = get_wav_raw_warp(w1.waveform, w2.waveform, _phase, warp, unscaled)
            }
    }

    _value := mathx.quantize_unipolar(value, bit_crush)

    return _value
}

write_wav_values_to_buffer :: proc(buffer: []f32, wt1, wt2: Waveform_Type, phase_start, phase_end, warp: f32, down_sample, bit_crush: i32, unscaled := false)
{
    count := len(buffer)
    step := (phase_end - phase_start) / f32(count - 1)
    phase := mathx.wrap_01(phase_start)

    for i in 0..<count
    {
        buffer[i] = get_wav_value(wt1, wt2, phase, warp, down_sample, bit_crush, unscaled)
        phase += step
        
        if phase >= 1
        {
            phase -= 1
        }
        else if phase < 0
        {
            phase += 1
        }
    }
}