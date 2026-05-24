package logging

import "core:fmt"
import "core:time"
import "base:runtime"

get_time :: proc() -> time.Tick
{
    return time.tick_now()
}

get_duration :: proc(start_time: time.Tick)// -> f64
{
    duration_ticks := time.tick_since(start_time)
    duration_ms := time.duration_milliseconds(duration_ticks)
    fmt.println("Elapsed Time:", duration_ms)
}