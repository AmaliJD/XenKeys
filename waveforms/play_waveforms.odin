package waveforms

import "core:math"
import "../mathx"
import "../logging"





get_wave_value :: proc(phase: f32, wav_1, wav_2: Waveform_Type, warp: f32 = 0, unscaled: bool = false) -> f32
{
    value: f32

    phase_quantize : f32 = 32
    _phase := phase//f32(math.round(phase * phase_quantize)) / phase_quantize

    scale : f32 = 1

    // switch wav_1
    // {
    //     case .Sine:
    //         switch wav_2
    //         {
    //             case .Sine:
    //                 value = sine_to_pulse(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SINE_SCALE, SINE_PULSE_SCALE, warp) }
    //             case .Triangle:
    //                 value = sine_to_triangle(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SINE_SCALE, TRIANGLE_SCALE, warp) }
    //             case .Square:
    //                 value = sine_to_square(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SINE_SCALE, SQUARE_SCALE, warp) }
    //             case .Saw:
    //                 value = sine_to_saw(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SINE_SCALE, SAW_SCALE, warp) }
    //             case .White:
    //                 value = sine_to_white(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SINE_SCALE, NOISE_SCALE, warp) }
    //         }
    //     case .Triangle:
    //         switch wav_2
    //         {
    //             case .Sine:
    //                 value = triangle_to_sine(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SINE_SCALE, warp) }
    //             case .Triangle:
    //                 value = triangle_to_pulse(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, TRIANGLE_SCALE, warp) }
    //             case .Square:
    //                 value = triangle_to_square(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SQUARE_SCALE, warp) }
    //             case .Saw:
    //                 value = triangle_to_saw(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SAW_SCALE, warp) }
    //             case .White:
    //                 value = triangle_to_white(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, NOISE_SCALE, warp) }
    //         }
    //     case .Square:
    //         switch wav_2
    //         {
    //             case .Sine:
    //                 value = square_to_sine(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SQUARE_SCALE, SINE_PULSE_SCALE, warp) }
    //             case .Triangle:
    //                 value = square_to_triangle(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SQUARE_SCALE, TRIANGLE_SCALE, warp) }
    //             case .Square:
    //                 value = square_to_pulse(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SQUARE_SCALE, SQUARE_SCALE, warp) }
    //             case .Saw:
    //                 value = square_to_saw(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SQUARE_SCALE, SAW_SCALE, warp) }
    //             case .White:
    //                 value = square_to_white(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SQUARE_SCALE, NOISE_SCALE, warp) }
    //         }
    //     case .Saw:
    //         switch wav_2
    //         {
    //             case .Sine:
    //                 value = saw_to_sine(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SAW_SCALE, SINE_PULSE_SCALE, warp) }
    //             case .Triangle:
    //                 value = saw_to_triangle(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SAW_SCALE, TRIANGLE_SCALE, warp) }
    //             case .Square:
    //                 value = saw_to_square(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SAW_SCALE, SQUARE_SCALE, warp) }
    //             case .Saw:
    //                 value = saw_to_pulse(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SAW_SCALE, SAW_SCALE, warp) }
    //             case .White:
    //                 value = saw_to_white(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(SAW_SCALE, NOISE_SCALE, warp) }
    //         }
    //     case .White:
    //         switch wav_2
    //         {
    //             case .Sine:
    //                 value = white_to_sine(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(NOISE_SCALE, SINE_PULSE_SCALE, warp) }
    //             case .Triangle:
    //                 value = white_to_triangle(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(NOISE_SCALE, TRIANGLE_SCALE, warp) }
    //             case .Square:
    //                 value = white_to_square(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(NOISE_SCALE, SQUARE_SCALE, warp) }
    //             case .Saw:
    //                 value = white_to_saw(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(NOISE_SCALE, SAW_SCALE, warp) }
    //             case .White:
    //                 value = white_to_pulse(_phase, warp)
    //                 if !unscaled { scale = mathx.lerp(NOISE_SCALE, NOISE_SCALE, warp) }
    //         }
    // }

    #partial switch w1 in wav_1
    {
        case Wav_Raw:
            #partial switch w2 in wav_2
            {
                case Wav_Raw:
                    _proc := Waveform_Raw_Warp_Matrix[w1.waveform][w2.waveform]
                    value = _proc.wave_proc(_phase, warp)
                    if !unscaled { scale = mathx.lerp(_proc.start_scale, _proc.end_scale, warp) }
            }
    }
    // _proc := Waveform_Raw_Warp_Matrix[wav_1][wav_2]
    // value = _proc.wave_proc(_phase, warp)
    // if !unscaled { scale = mathx.lerp(_proc.start_scale, _proc.end_scale, warp) }

    value_quantize : f32 = 32
    _value := value//f32(math.round(value * value_quantize)) / value_quantize

    return _value * scale
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

waveform_pair :: proc(wav_1, wav_2: Waveform) -> int
{
    return (int(wav_1) << 8) | int(wav_2)
}