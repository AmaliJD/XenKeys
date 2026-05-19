package main

import "core:fmt"
import "base:runtime"
import "core:math"
import ma "vendor:miniaudio"
import wav "waveforms"


// ----------------------------------------------------------------------------------- structs
Audio_Data :: struct
{
    logger: Logger,
    note: Note,
    wave_data: Wav_Data
}

Logger :: struct
{
    buffer_size: u32,
    is_playing: bool,
}

Wav_Data :: struct
{
    waveform_1: wav.Waveform,
    waveform_2: wav.Waveform,
    warp: f32,
}

Note :: struct
{
    frequency: f64,
    phase: f64,
    time: f64,
    instrument: int,
}


// ----------------------------------------------------------------------------------- helpers
update_phase :: proc(note: ^Note, sampleRate: u32)
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

    note := &audio_data.note
    gain := f32(.1)


    // ----------------------------------------------------------------------------------- fill output buffer
    for i in 0..<frameCount
    {
        value : f32
        if (audio_data.logger.is_playing)
        {
            value = wav.get_wave_value(
                f32(note.phase),
                audio_data.wave_data.waveform_1,
                audio_data.wave_data.waveform_2,
                audio_data.wave_data.warp,
            )
        }
        
        output_value := value * gain
        output[i * 2]     = output_value
        output[i * 2 + 1] = output_value

        update_phase(note, pDevice.sampleRate)
    }
}