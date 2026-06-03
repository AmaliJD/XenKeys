package main

Note :: struct
{
    state: Note_State,
    synth_index: u16,

    frequency: f64,
    phase: f64,
    time: f64,

    velocity: f32,
    last_envelope_value: f32,
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
    note.phase += note.frequency / f64(sampleRate)
    if note.phase >= 1 do note.phase -= 1

    dt := 1.0 / f64(sampleRate)
    note.time += dt
}