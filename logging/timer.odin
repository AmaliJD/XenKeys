package logging

import "core:fmt"
import "core:time"
import "base:runtime"

@private start_tick: map[string]time.Tick
@private elapsed_time: map[string]f64
global_start_tick: time.Tick
global_elapsed_time: f64

init_time :: proc(allocator := context.allocator)
{
    start_tick = make(map[string]time.Tick)
    elapsed_time = make(map[string]f64)
}

start_time :: proc
{
    start_time_id,
    start_time_global,
}

@private
start_time_id :: proc(id: string)
{
    start_tick[id] = time.tick_now()
}

@private
start_time_global :: proc()
{
    global_start_tick = time.tick_now()
}

end_time :: proc
{
    end_time_id,
    end_time_global,
}

@private
end_time_id :: proc(id: string)
{
    if !(id in start_tick) { return }

    duration_ticks := time.tick_since(start_tick[id])
    duration_ms := time.duration_milliseconds(duration_ticks)

    elapsed_time[id] = duration_ms
}

@private
end_time_global :: proc()
{
    duration_ticks := time.tick_since(global_start_tick)
    duration_ms := time.duration_milliseconds(duration_ticks)

    global_elapsed_time = duration_ms
}

get_time :: proc
{
    get_time_id,
    get_time_global,
}

@private
get_time_id :: proc(id: string) -> f64
{
    if !(id in elapsed_time) { return 0 }

    return elapsed_time[id]
}

@private
get_time_global :: proc() -> f64
{
    return global_elapsed_time
}

print_time :: proc(id: string)
{
    if !(id in elapsed_time) { return }

    fmt.println("Elapsed Time:", elapsed_time[id])
}