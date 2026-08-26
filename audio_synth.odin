package main

import "core:math"


// ----------------------------------------------------------------------------------- data
Synth :: struct
{
    wt1: Waveform_Type,
    wt2: Waveform_Type,
    warp: f32,

    volume: f32,

    adsr: ADSR,
    down_sample: i32,
    bit_crush: i32,
    phase_skew: f32,
    amp_skew: f32,

    voice_count: u8,
    detune: f32,

    drift: f32,
    drift_frequency: f32,
}

ADSR :: struct
{
    attack: f32,
    decay: f32,
    sustain: f32,
    release: f32,
}


// ----------------------------------------------------------------------------------- setters
set_synth_waveform :: proc(synth: ^Synth, wt1, wt2: Waveform_Type, warp: f32 = 0)
{
    synth.wt1 = wt1
    synth.wt2 = wt2
    synth.warp = warp
}

set_synth_adsr :: proc(synth: ^Synth, a, d, s, r: f32)
{
    synth.adsr = {
        attack = a,
        decay = d,
        sustain = s,
        release = r,
    }
}

set_synth_waveshape :: proc(synth: ^Synth, down_sample, bit_crush: i32, phase_skew, amp_skew: f32)
{
    synth.down_sample = down_sample
    synth.bit_crush = bit_crush
    synth.phase_skew = phase_skew
    synth.amp_skew = amp_skew
}

set_synth_voices :: proc(synth: ^Synth, voice_count: u8, detune, drift, drift_frequency: f32)
{
    synth.voice_count = voice_count
    synth.detune = detune
    synth.drift = drift
    synth.drift_frequency = drift_frequency
}

set_synth_default :: proc(synth: ^Synth)
{
    if (synth.adsr.sustain == 0) { synth.adsr.sustain = 1 }
    if (synth.voice_count == 0) { synth.voice_count = 1 }
    if (synth.volume == 0) { synth.volume = 1 }
}