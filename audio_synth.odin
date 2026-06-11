package main

Synth :: struct
{
    wt1: Waveform_Type,
    wt2: Waveform_Type,
    warp: f32,

    adsr: ADSR,
    down_sample: i32,
    bit_crush: i32,
    phase_skew: f32,
    amp_skew: f32,

    voice_count: u8,
    detune: f32,
}

ADSR :: struct
{
    attack: f32,
    decay: f32,
    sustain: f32,
    release: f32,
}