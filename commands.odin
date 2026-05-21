package main

import "core:fmt"
import wav "waveforms"


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
    waveform_1: wav.Waveform,
    waveform_2: wav.Waveform,
    warp: f32,
}

Command_Note_Off :: struct
{
    note_index: u16,
}

// ----------------------------------------------------------------------------------- procs
note_count: u16

@private
add_command :: proc(command: Command)
{
    next_write_index := (audio_data.live_commands.write_index + 1) % len(audio_data.live_commands.buffer)
    if next_write_index != audio_data.live_commands.read_index
    {
        audio_data.live_commands.buffer[audio_data.live_commands.write_index] = command
        audio_data.live_commands.write_index = next_write_index
    }
}

add_command_note_on :: proc(freq: f64) -> i16
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
    }

    note_count += 1
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