package main

import "mathx"

MAX_VOICES :: 4

Note :: struct
{
    state: Note_State,
    synth_index: u16,

    frequency: f64,
    phase: [MAX_VOICES]f64,
    time: f64,

    velocity: f32,
    last_envelope_value: f32,

    drift_targets: [4]i16,
    drift_sample_counter: u32,

    vibrato_phase: f64,

    base_params: [Params]f32,
    params: [Params]f32,
    mod_params: bit_set[Params],
    modulators: [Params]u8,
}

Note_State :: enum u8
{
    Inactive,
    Queued,
    On,
    Off,
}

update_note :: proc(note: ^Note, sample_rate: u32)
{
    synth := &audio_data.synths_list[note.synth_index]
    frequency := note.frequency

    if synth.voice_count == 0 { return }

    // vibrato
    if synth.vibrato_frequency > 0 && synth.vibrato_amp > 0
    {
        switch synth.vibrato_type
        {
            case .Exponential:
                note.vibrato_phase += f64(synth.vibrato_frequency) / f64(sample_rate)
                if note.vibrato_phase >= 1 do note.vibrato_phase -= 1

                vibrato_offset := sine(f32(note.vibrato_phase)) * synth.vibrato_amp
                frequency = mathx.add_degrees(frequency, f64(vibrato_offset))
            case .Linear:
                freq := f32(note.frequency) * synth.vibrato_frequency
                amp := f32(note.frequency) * synth.vibrato_amp

                note.vibrato_phase += f64(freq) / f64(sample_rate)
                if note.vibrato_phase >= 1 do note.vibrato_phase -= 1

                vibrato_offset := sine(f32(note.vibrato_phase)) * amp
                frequency += f64(vibrato_offset)
        }
    }

    // pitch drift
    if (synth.drift != 0 && synth.drift_frequency > 0)
    {
        if (note.drift_sample_counter == 0)
        {
            note.drift_targets.x = note.drift_targets.y
            note.drift_targets.y = note.drift_targets.z
            note.drift_targets.z = note.drift_targets.w
            note.drift_targets.w = i16(mathx.rand_float32_magnitude_1() * f32(max(i16)))
        }

        drift_sample_rate := u32(f32(sample_rate) / synth.drift_frequency)
        drift_t := f32(note.drift_sample_counter) / f32(drift_sample_rate)
        note.drift_sample_counter = (note.drift_sample_counter + 1) % drift_sample_rate

        p: [4]f32
        p.x = f32(note.drift_targets.x) / f32(max(i16))
        p.y = f32(note.drift_targets.y) / f32(max(i16))
        p.z = f32(note.drift_targets.z) / f32(max(i16))
        p.w = f32(note.drift_targets.w) / f32(max(i16))

        frequency_drift_amt := mathx.cubic_lerp(p.x, p.y, p.z, p.w, drift_t) * synth.drift
        frequency = mathx.add_degrees(frequency, f64(frequency_drift_amt))
    }

    // phase
    if synth.voice_count == 1
    {
        note.phase[0] += frequency / f64(sample_rate)
        if note.phase[0] >= 1 do note.phase[0] -= 1
    }
    else
    {
        detuned_frequency: f64
        for i in 0..<synth.voice_count
        {
            //detune_step := (synth.detune * 2) / synth.voice_count - 1
            detuned_frequency = mathx.add_degrees(frequency, f64(mathx.lerp(-synth.detune, synth.detune, f32(i) / f32(synth.voice_count))))

            note.phase[i] += detuned_frequency / f64(sample_rate)
            if note.phase[i] >= 1 do note.phase[i] -= 1
        }
    }

    // time
    dt := 1.0 / f64(sample_rate)
    note.time += dt
}