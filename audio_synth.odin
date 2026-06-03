package main

Synth :: struct
{
    wt1: Waveform_Type,
    wt2: Waveform_Type,
    warp: f32,

    adsr: ADSR,

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