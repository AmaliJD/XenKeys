package main

import "mathx"
import "core:math"
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
get_wav_value :: proc(synth: ^Synth, phase: f32) -> (f32, f32)
{
    value: f32

    skew: f32 = 5.0

    _phase := phase
    if synth.phase_skew < 0
    {
        skewed_phase := math.pow_f32(_phase, 1.0/skew)
        _phase = mathx.lerp(_phase, skewed_phase, math.abs(synth.phase_skew))
    }
    else if  synth.phase_skew > 0
    {
        skewed_phase := math.pow_f32(_phase, skew)
        _phase = mathx.lerp(_phase, skewed_phase, synth.phase_skew)
    }
    _phase = mathx.quantize(_phase, synth.down_sample)

    scale: f32 = 1
    #partial switch w1 in synth.wt1
    {
        case nil:
            #partial switch w2 in synth.wt2
            {
                case nil:
                    value = 0
                case Wav_Raw:
                    value, scale = get_wav_raw(w2.waveform, _phase)
                    value = mathx.lerp(0, value, synth.warp)
            }

        case Wav_Raw:
            #partial switch w2 in synth.wt2
            {
                case nil:
                    value, scale = get_wav_raw(w1.waveform, _phase)
                    value = mathx.lerp(value, 0, synth.warp)
                case Wav_Raw:
                    value, scale = get_wav_raw_warp(w1.waveform, w2.waveform, _phase, synth.warp)
            }
    }

    _value := mathx.quantize_unipolar(value, synth.bit_crush)
    if synth.amp_skew > 0
    {
        skewed_value := math.sign(_value) * math.pow_f32(math.abs(_value), 1.0/skew)
        _value = mathx.lerp(_value, skewed_value, synth.amp_skew)
    }
    else if  synth.amp_skew < 0
    {
        skewed_value := math.sign(_value) * math.pow_f32(math.abs(_value), skew)
        _value = mathx.lerp(_value, skewed_value, math.abs(synth.amp_skew))
    }

    return _value, scale
}

write_wav_values_to_buffer :: proc(buffer: []f32, synth: ^Synth, phase_start, phase_end: f32, unscaled := false)
{
    count := len(buffer)
    step := (phase_end - phase_start) / f32(count - 1)
    phase := mathx.wrap_01(phase_start)

    for i in 0..<count
    {
        value, scale := get_wav_value(synth, phase)
        buffer[i] = value * (1 if unscaled else scale)
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