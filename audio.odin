package main

import "core:fmt"
import "base:runtime"
import "core:math"
import "core:math/rand"
import ma "vendor:miniaudio"
import wav "waveforms"


// ----------------------------------------------------------------------------------- consts
MAX_NOTES :: 12


// ----------------------------------------------------------------------------------- structs
Audio_Data :: struct
{
    logger: Logger,

    live_commands: Live_Command_Buffer,
    notes_list: [MAX_NOTES]Note,

    wave_data: Wav_Data
}

Logger :: struct
{
    buffer_size: u32,
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
    instrument: int,
}

Note_State :: enum u8
{
    Inactive,
    On,
    Off,
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
    audio_data := (^Audio_Data)(pDevice.pUserData)
    output := ([^]f32)(pOutput)

    audio_data.logger.buffer_size = frameCount
    


    // ----------------------------------------------------------------------------------- read live commands
    for audio_data.live_commands.read_index != audio_data.live_commands.write_index
    {
        command := audio_data.live_commands.buffer[audio_data.live_commands.read_index]

        switch cmd in command
        {
            case Command_Note_On:
                audio_data.notes_list[cmd.note_index].state = .On
                audio_data.notes_list[cmd.note_index].phase = rand.float64()
                audio_data.notes_list[cmd.note_index].frequency = cmd.frequency

            case Command_Note_Off:
                audio_data.notes_list[cmd.note_index].state = .Off
        }

        audio_data.live_commands.read_index = (audio_data.live_commands.read_index + 1) % len(audio_data.live_commands.buffer)
    }


    // ----------------------------------------------------------------------------------- fill output buffer
    for gain := f32(.1); i in 0..<frameCount
    {
        value: f32

        // ----------------------------------------------------------------------------------- read notes
        for &note in audio_data.notes_list
        {
            switch note.state
            {
                case .On:
                
                note_value := wav.get_wave_value(
                    f32(note.phase),
                    audio_data.wave_data.waveform_1,
                    audio_data.wave_data.waveform_2,
                    audio_data.wave_data.warp,
                )

                update_note(&note, pDevice.sampleRate)
                value += note_value

                case .Off:
                    note.state = .Inactive

                case .Inactive:
            }
        }
        
        output_value := value * gain
        output[i * 2]     = output_value
        output[i * 2 + 1] = output_value
    }
}