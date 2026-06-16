package main

import "core:fmt"
import "core:sync"


// ----------------------------------------------------------------------------------- commands metadata
Command :: union
{
    Command_Note_On,
    Command_Note_Off,
}

Live_Command_Buffer :: struct
{
    buffer: [12]Command,
    write_index: u16,
    read_index: u16,
}


// ----------------------------------------------------------------------------------- commands
Command_Note_On :: struct
{
    note_index: u16,
    frequency: f64,
    velocity: f32,
}

Command_Note_Off :: struct
{
    note_index: u16,
}

// ----------------------------------------------------------------------------------- procs
@private
add_command :: proc(command: Command)
{
    read_index := sync.atomic_load(&audio_data.live_commands.read_index)
    write_index := sync.atomic_load(&audio_data.live_commands.write_index)

    next_write_index := (write_index + 1) % len(audio_data.live_commands.buffer)
    if next_write_index != read_index
    {
        audio_data.live_commands.buffer[write_index] = command
        sync.atomic_store(&audio_data.live_commands.write_index, next_write_index)
    }
}

add_command_note_on :: proc(freq: f64, synth_index: u16) -> i16
{
    index : i16 = -1
    for n, i in audio_data.notes_list
    {
        if n.state == .Inactive
        {
            index = i16(i)
            break
        }
    }
    if index == -1
    {
        fmt.println("Note On ERROR: no free slots")
        return -1
    }

    cmd := Command_Note_On {
        note_index = u16(index),
        frequency = freq,
        velocity = 1,
    }

    audio_data.notes_list[index].state = .Queued
    audio_data.notes_list[index].synth_index = synth_index

    add_command(cmd)

    return index
}

add_command_note_off :: proc(index: u16)
{
    if index >= len(audio_data.notes_list)
    {
        fmt.println("Note Off ERROR: index out of range")
        return
    }

    cmd := Command_Note_Off {
        note_index = index
    }

    add_command(cmd)
}