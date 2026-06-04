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
    Wav_None,
    Wav_Raw,
    Wav_Harmonics,
    Wav_Sample
}

Wav_None :: struct {}


// ----------------------------------------------------------------------------------- helpers
waveform_pair :: proc(wav_1, wav_2: Waveform) -> int
{
    return (int(wav_1) << 8) | int(wav_2)
}


// ----------------------------------------------------------------------------------- get wave
get_wav_value :: proc(wt1, wt2: Waveform_Type, phase: f32, warp: f32 = 0, unscaled := false) -> f32
{
    value: f32
    _phase := mathx.quantize(phase, 0)

    #partial switch w1 in wt1
    {
        case Wav_None:
            #partial switch w2 in wt2
            {
                case Wav_None:
                    value = 0
                case Wav_Raw:
                    value = mathx.lerp(0, get_wav_raw(w2.waveform, phase, unscaled), warp)
            }

        case Wav_Raw:
            #partial switch w2 in wt2
            {
                case Wav_None:
                    value = mathx.lerp(get_wav_raw(w1.waveform, phase, unscaled), 0, warp)
                case Wav_Raw:
                    value = get_wav_raw_warp(w1.waveform, w2.waveform, _phase, warp, unscaled)
            }
    }

    _value := mathx.quantize(value, 0)

    return _value
}