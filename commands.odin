package main

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
    note_id: u16,
    frequency: f64,
    waveform_1: wav.Waveform,
    waveform_2: wav.Waveform,
    warp: f32,
}

Command_Note_Off :: struct
{
    note_id: u16,
}

// ----------------------------------------------------------------------------------- procs
note_count: u16

@private
add_command :: proc(command: Command)
{
    next_write_index := (audio_data_ptr.live_commands.write_index + 1) % len(audio_data_ptr.live_commands.buffer)
    if next_write_index != audio_data_ptr.live_commands.read_index
    {
        audio_data_ptr.live_commands.buffer[audio_data_ptr.live_commands.write_index] = command
        audio_data_ptr.live_commands.write_index = next_write_index
    }
}

add_command_note_on :: proc(freq: f64)
{
    cmd := Command_Note_On {
        note_id = note_count,
        frequency = freq,
    }

    note_count += 1
    add_command(cmd)
}