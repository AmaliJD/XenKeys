package main

import "core:fmt"
import "base:runtime"
import "core:time"
import "core:math"
import "mathx"
import "core:math/rand"
import "core:sync"
import "logging"
import ma "vendor:miniaudio"


// ----------------------------------------------------------------------------------- data
MAX_NOTES :: 64
MAX_SYNTHS :: 8

Audio_Data :: struct
{
    log: Log,

    live_commands: Live_Command_Buffer,
    notes_list: [MAX_NOTES]Note,
    synths_list: [MAX_SYNTHS]Synth,
    // notes_list_bits: u64
    note_count: u16,

    value: f32,
    peak_value: f32,

    synth_index: u16
}

Log :: struct
{
    buffer_size: u32,
    elapsed_time: f64
}

init_synths_list :: proc()
{
    for &s in audio_data.synths_list
    {
        s.adsr.sustain = 1
    }
}


// ----------------------------------------------------------------------------------- audio processing
audio_callback :: proc "c" (pDevice: ^ma.device, pOutput, pInput: rawptr, frameCount: u32)
{
    context = runtime.default_context()

    logging.start_time()
    audio_data := (^Audio_Data)(pDevice.pUserData)
    output := ([^]f32)(pOutput)

    audio_data.log.buffer_size = frameCount
    
    // ----------------------------------------------------------------------------------- read live commands
    write_index := sync.atomic_load(&audio_data.live_commands.write_index)
    read_index := sync.atomic_load(&audio_data.live_commands.read_index)
    for read_index != write_index
    {
        command := audio_data.live_commands.buffer[read_index]

        switch cmd in command
        {
            case Command_Note_On:
                audio_data.notes_list[cmd.note_index].state = .On
                audio_data.notes_list[cmd.note_index].phase = rand.float64()
                audio_data.notes_list[cmd.note_index].frequency = cmd.frequency
                audio_data.notes_list[cmd.note_index].velocity = cmd.velocity
                audio_data.notes_list[cmd.note_index].time = 0

                audio_data.note_count += 1

            case Command_Note_Off:
                audio_data.notes_list[cmd.note_index].state = .Off
                audio_data.notes_list[cmd.note_index].time = 0
        }

        read_index = (read_index + 1) % len(audio_data.live_commands.buffer)
        sync.atomic_store(&audio_data.live_commands.read_index, read_index)
        //audio_data.live_commands.read_index = (audio_data.live_commands.read_index + 1) % len(audio_data.live_commands.buffer)
    }


    // ----------------------------------------------------------------------------------- fill output buffer
    peak_value: f32 = 0
    if audio_data.note_count > 0
    {
        for gain := f32(.1); i in 0..<frameCount
        {
            value: f32
            notes_processed: u16
            notes_deactivated: u16 = 0

            // ----------------------------------------------------------------------------------- read notes
            for &note, index in audio_data.notes_list
            {
                if notes_processed >= audio_data.note_count {
                    break
                }

                synth := &audio_data.synths_list[note.synth_index]
                adsr := synth.adsr

                note_value, note_scale := get_wav_value(
                    synth,
                    f32(note.phase),
                )
                note_value *= note_scale

                envelope: f32 = 1

                switch note.state
                {
                    case .On:
                        notes_processed += 1
                        
                        if time32 := f32(note.time); time32 <= adsr.attack
                        {
                            t := mathx.inverse_lerp(0, adsr.attack, time32)
                            _t := mathx.ramp_up_pow(t, 2)
                            envelope = _t * note.velocity
                        }
                        else if time32 < adsr.attack + adsr.decay
                        {
                            t := mathx.inverse_lerp(0, adsr.decay, time32 - adsr.attack)
                            _t := mathx.ramp_down_pow(t, 2)
                            envelope = mathx.lerp(note.velocity, note.velocity * adsr.sustain, _t)
                        }
                        else
                        {
                            envelope = note.velocity * adsr.sustain
                        }

                        note.last_envelope_value = envelope
                        note_value *= envelope

                        update_note(&note, pDevice.sampleRate)
                        value += note_value

                    case .Off:
                        notes_processed += 1

                        if time32 := f32(note.time); time32 <= adsr.release
                        {
                            t := mathx.inverse_lerp(0, adsr.release, time32)
                            _t := mathx.ramp_down_pow(t, 2)
                            envelope = mathx.lerp(note.last_envelope_value, 0, _t)
                            note_value *= envelope

                            update_note(&note, pDevice.sampleRate)
                            value += note_value
                        }
                        else
                        {
                            note.state = .Inactive
                            notes_deactivated += 1
                        }

                    case .Inactive:

                    case .Queued:
                }
            }

            audio_data.note_count -= notes_deactivated
            
            output_value     := value * gain
            output[i * 2]     = output_value
            output[i * 2 + 1] = output_value

            audio_data.value = output_value
            peak_value = math.max(peak_value, math.abs(output_value))
        }
    }

    lerp_amt: f32 = 1 if peak_value == 0 || peak_value > audio_data.peak_value else .1
    audio_data.peak_value = mathx.lerp(audio_data.peak_value, peak_value, lerp_amt)

    logging.end_time()
}