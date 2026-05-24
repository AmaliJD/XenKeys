package logging

import "core:fmt"
import "core:time"
import "base:runtime"

start_tick: time.Tick
elapsed_time: f64

get_time :: proc()
{
    start_tick = time.tick_now()
}

get_duration :: proc()// -> f64
{
    duration_ticks := time.tick_since(start_tick)
    duration_ms := time.duration_milliseconds(duration_ticks)
    //fmt.println("Elapsed Time:", duration_ms)

    elapsed_time = duration_ms
}