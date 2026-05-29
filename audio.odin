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
import wav "waveforms"


// ----------------------------------------------------------------------------------- consts
MAX_NOTES :: 64
MAX_SYNTHS :: 8

// ----------------------------------------------------------------------------------- structs
Audio_Data :: struct
{
    logger: Logger,

    live_commands: Live_Command_Buffer,
    notes_list: [MAX_NOTES]Note,
    synths_list: [MAX_SYNTHS]Synth,
    // notes_list_bits: u64
    note_count: u16,
    q_index, w_index, e_index, r_index: u16,
    q_freq, w_freq, e_freq, r_freq: f64,

    wave_data: Wav_Data,
    adsr: ADSR,

    value: f32,
}

Logger :: struct
{
    buffer_size: u32,
    elapsed_time: f64
}

Wav_Data :: struct
{
    waveform_1: wav.Waveform,
    waveform_2: wav.Waveform,
    warp: f32,
}

Note :: struct
{
    state: Note_State,

    frequency: f64,
    phase: f64,
    time: f64,

    // synth: Synth,
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

Synth :: struct
{
    waveform: wav.Waveform,
    voice_count: u8,
    detune: f32,
    adsr: ADSR,
}

Hard_Params :: enum // hard set and don't change
{
    
}

Soft_Params :: enum // modulatable
{

}

ADSR :: struct
{
    attack: f32,
    decay: f32,
    sustain: f32,
    release: f32,
}

Modulation :: struct
{
    final_value: f32,
    lfo: LFO,
    delay, fade_in: f32,
}

LFO :: struct
{
    frequency: f32,
    low, high: f32,
}


// ----------------------------------------------------------------------------------- helpers
update_note :: proc(note: ^Note, sampleRate: u32)
{
    note.phase += note.frequency / f64(sampleRate)
    if note.phase >= 1 do note.phase -= 1

    dt := 1.0 / f64(sampleRate)
    note.time += dt
}


// ----------------------------------------------------------------------------------- audio processing
audio_callback :: proc "c" (pDevice: ^ma.device, pOutput, pInput: rawptr, frameCount: u32)
{
    context = runtime.default_context()

    logging.get_time()
    audio_data := (^Audio_Data)(pDevice.pUserData)
    output := ([^]f32)(pOutput)

    audio_data.logger.buffer_size = frameCount
    
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
                fmt.println(cmd.note_index, ": ON")

            case Command_Note_Off:
                audio_data.notes_list[cmd.note_index].state = .Off
                audio_data.notes_list[cmd.note_index].time = 0

                fmt.println(cmd.note_index, ": OFF")
        }

        read_index = (read_index + 1) % len(audio_data.live_commands.buffer)
        sync.atomic_store(&audio_data.live_commands.read_index, read_index)
        //audio_data.live_commands.read_index = (audio_data.live_commands.read_index + 1) % len(audio_data.live_commands.buffer)
    }


    // ----------------------------------------------------------------------------------- fill output buffer
    if audio_data.note_count > 0
    {
        for gain := f32(.2); i in 0..<frameCount
        {
            value: f32
            notes_processed: u16
            notes_deactivated := u16(0)

            // ----------------------------------------------------------------------------------- read notes
            for &note, index in audio_data.notes_list
            {
                if notes_processed >= audio_data.note_count {
                    break
                }

                note_value := wav.get_wave_value(
                    f32(note.phase),
                    audio_data.wave_data.waveform_1,
                    audio_data.wave_data.waveform_2,
                    audio_data.wave_data.warp,
                )

                envelope := f32(1)

                switch note.state
                {
                    case .On:
                        notes_processed += 1
                        
                        if time32 := f32(note.time); time32 <= audio_data.adsr.attack
                        {
                            envelope = mathx.inverse_lerp(0, audio_data.adsr.attack, time32) * note.velocity
                        }
                        else if time32 < audio_data.adsr.attack + audio_data.adsr.decay
                        {
                            t := mathx.inverse_lerp(0, audio_data.adsr.decay, time32 - audio_data.adsr.attack)
                            envelope = mathx.lerp(note.velocity, note.velocity * audio_data.adsr.sustain, t)
                        }
                        else
                        {
                            envelope = note.velocity * audio_data.adsr.sustain
                        }

                        note.last_envelope_value = envelope
                        note_value *= envelope

                        update_note(&note, pDevice.sampleRate)
                        value += note_value

                    case .Off:
                        notes_processed += 1

                        if time32 := f32(note.time); time32 <= audio_data.adsr.release
                        {
                            t := mathx.inverse_lerp(0, audio_data.adsr.release, time32)
                            envelope = mathx.lerp(note.last_envelope_value, 0, t)
                            note_value *= envelope

                            update_note(&note, pDevice.sampleRate)
                            value += note_value
                        }
                        else
                        {
                            note.state = .Inactive
                            notes_deactivated += 1
                            // audio_data.note_count -= 1
                            // notes_processed -= 1
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
        }
    }

    logging.get_duration()
    audio_data.logger.elapsed_time = logging.elapsed_time
}