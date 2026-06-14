package main

import "mathx"

Note :: struct
{
    state: Note_State,
    synth_index: u16,

    frequency: f64,
    phase: f64,
    time: f64,

    velocity: f32,
    last_envelope_value: f32,

    vibrato_targets: [4]i16,
    vibrato_sample_count: u32,
}

Note_State :: enum u8
{
    Inactive,
    Queued,
    On,
    Off,
}

update_note :: proc(note: ^Note, sampleRate: u32)
{
    synth := &audio_data.synths_list[note.synth_index]
    frequency := note.frequency

    // vibrato
    if (synth.vibrato != 0 && synth.vibrato_hz > 0)
    {
        if (note.vibrato_sample_count == 0)
        {
            note.vibrato_targets.x = note.vibrato_targets.y
            note.vibrato_targets.y = note.vibrato_targets.z
            note.vibrato_targets.z = note.vibrato_targets.w
            note.vibrato_targets.w = i16(mathx.rand_float32_magnitude_1() * f32(max(i16)))
        }

        vibrato_sample_hz := u32(f32(sampleRate) / synth.vibrato_hz)
        vibrato_t := f32(note.vibrato_sample_count) / f32(vibrato_sample_hz)
        note.vibrato_sample_count = (note.vibrato_sample_count + 1) % vibrato_sample_hz

        p: [4]f32
        p.x = f32(note.vibrato_targets.x) / f32(max(i16))
        p.y = f32(note.vibrato_targets.y) / f32(max(i16))
        p.z = f32(note.vibrato_targets.z) / f32(max(i16))
        p.w = f32(note.vibrato_targets.w) / f32(max(i16))

        vibrato_offset := mathx.cubic_lerp(p.x, p.y, p.z, p.w, vibrato_t) * synth.vibrato
        frequency = mathx.add_cents(note.frequency, f64(vibrato_offset))
    }

    // phase
    note.phase += frequency / f64(sampleRate)
    if note.phase >= 1 do note.phase -= 1

    // time
    dt := 1.0 / f64(sampleRate)
    note.time += dt
}