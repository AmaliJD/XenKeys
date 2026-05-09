package main

import "core:fmt"
import "base:runtime"
import "core:math"
import ma "vendor:miniaudio"
import wav "waveforms"

Audio_Data :: struct {
    logger: Logger,
    note: Note,
    waveData: Wav_Data
}

Logger :: struct {
    bufferSize: u32,
    isPlaying: bool,
}

Wav_Data :: struct {
    waveform: wav.Waveform,
    warp_waveform: wav.Waveform,
    warp_amt: f32,
}

Note :: struct {
    frequency: f32,
    phase: f32,
    time: f64,
    instrument: int,
}

update_phase :: proc(note: ^Note, sampleRate: u32) {
    
    note.phase += note.frequency / f32(sampleRate)
    if note.phase >= 1 do note.phase -= 1

    dt := 1.0 / f64(sampleRate)
    note.time += dt
}

audio_callback :: proc "c" (pDevice: ^ma.device, pOutput, pInput: rawptr, frameCount: u32) {
    context = runtime.default_context()
    audio_data := (^Audio_Data)(pDevice.pUserData)
    output := ([^]f32)(pOutput)

    audio_data.logger.bufferSize = frameCount

    note := &audio_data.note
    gain : f32 = .1

    for i in 0..<frameCount {
        value : f32
        if (audio_data.logger.isPlaying) {
            value = wav.get_wave_value(note.phase, audio_data.waveData.waveform, audio_data.waveData.warp_waveform, audio_data.waveData.warp_amt)
        }
        
        output[i * 2]     = value * gain 
        output[i * 2 + 1] = value * gain

        update_phase(note, pDevice.sampleRate)
    }
}