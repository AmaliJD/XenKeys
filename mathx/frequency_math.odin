package mathx

import "core:math"

freq_add_interval :: proc (frequency: f64, edo, index: int, period_ratio: f64) -> f64
{
    return frequency * math.pow(math.pow(period_ratio, 1.0 / f64(edo)), f64(index))
}