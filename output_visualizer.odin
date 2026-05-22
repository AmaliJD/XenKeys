package main

import "core:math"

get_output_samples_count :: proc (frequency: f64, sampleRate: u32, periods: int) -> int
{
    return int((f32(periods) / f32(frequency)) * f32(sampleRate))
}

get_lowest_frequency :: proc() -> f64
{
    freq :f64= 44100.0 / 2.0
    for n in audio_data.notes_list
    {
        if n.state == .On
        {
            freq = math.min(freq, n.frequency)
        }
    }

    return freq
}

// get_wave_values :: proc(buffer: []f32, phase_start, phase_end: f32, wav_1, wav_2: Waveform, warp: f32)
// {
//     count := len(buffer)
//     step := (phase_end - phase_start) / f32(count - 1)

//     phase := mathx.wrap_01(phase_start)
//     for i in 0..<count
//     {
//         buffer[i] = f32(get_wave_value(phase, wav_1, wav_2, warp, true))
//         phase += step
        
//         if phase >= 1
//         {
//             phase -= 1
//         }
//         else if phase < 0
//         {
//             phase += 1
//         }
//     }
// }