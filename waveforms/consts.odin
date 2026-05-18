package waveforms

SINE_SCALE          :: f32(1)
TRIANGLE_SCALE      :: f32(.9)
SQUARE_SCALE        :: f32(0.35)
SAW_SCALE           :: f32(0.4)
SINE_PULSE_SCALE    :: f32(0.5)

PULSE_LOW_LIMIT     :: f32(.005)
PULSE_HIGH_LIMIT    :: f32(.995)

Waveform :: enum {
    Sine,
    Triangle,   // odd harmonics, 1/n², alternating signs
    Square,     // odd harmonics, 1/n
    Saw,        // all harmonics, 1/n
    White,      // random
}

Waveform_Pair_Proc :: struct {
    wave_proc:      proc(f32, f32) -> f32,
    start_scale:    f32,
    end_scale:      f32,
}

// harmonics : []int = {1, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 51, 53, 59, 61} // prime
// harmonics : []int = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32} // saw
harmonics : []int = {1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41} // square
// harmonics : []int = {1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50} // quarter circle
// harmonics : []int = {1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144} // fibbonaci bells
volume_limiter : f32 = 3