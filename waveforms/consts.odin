package waveforms

@private TRIANGLE_SCALE     :: f64(.9)
@private SQUARE_SCALE       :: f64(0.35)
@private SAW_SCALE          :: f64(0.4)
@private SINE_PULSE_SCALE   :: f64(0.5)
@private X_SCALE            :: f64(0.8)

Waveform :: enum {
    Sine,
    Triangle,   // odd harmonics, 1/n², alternating signs
    Square,     // odd harmonics, 1/n
    Saw,        // all harmonics, 1/n
    X,
    Test
}

Waveform_Pair :: struct {
    wave_1: Waveform,
    wave_2: Waveform
}

// harmonics : []int = {1, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 51, 53, 59, 61} // prime
// harmonics : []int = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32} // saw
harmonics : []int = {1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41} // square
// harmonics : []int = {1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50} // quarter circle
// harmonics : []int = {1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144} // fibbonaci bells
volume_limiter : f64 = 3