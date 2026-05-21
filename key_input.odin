package main

import "core:fmt"
import "base:runtime"
import "vendor:glfw"
import "mathx"

Keyboard_Data :: struct
{
    pressed: bool,
    note_index: u16,
    frequency: f64
}

key_map : map[i32]Keyboard_Data

KEY_COUNT :: 13
keys : [KEY_COUNT]i32 =
{
    glfw.KEY_GRAVE_ACCENT,
    glfw.KEY_1,
    glfw.KEY_2,
    glfw.KEY_3,
    glfw.KEY_4,
    glfw.KEY_5,
    glfw.KEY_6,
    glfw.KEY_7,
    glfw.KEY_8,
    glfw.KEY_9,
    glfw.KEY_0,
    glfw.KEY_MINUS,
    glfw.KEY_EQUAL,
}

init_key_map :: proc()
{
    key_map = make(map[i32]Keyboard_Data, KEY_COUNT)

    start_frequency : f64 = 220.0
    for k, i in keys
    {
        key_map[k] = Keyboard_Data{ frequency = mathx.freq_add_interval(start_frequency, KEY_COUNT - 1, i, 2) }
    }
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32)
{
    context = runtime.default_context()

    for k in keys
    {
        if key == k
        {
            switch action
            {
                case glfw.PRESS:
                    new_index := add_command_note_on(key_map[k].frequency)
                    if new_index != -1
                    {
                        key_data := &key_map[k]
                        key_data.note_index = u16(new_index)
                        key_data.pressed = true
                    }
                    break
                
                case glfw.RELEASE:
                    if key_map[k].pressed
                    {
                        key_data := &key_map[k]
                        key_data.pressed = false

                        add_command_note_off(key_map[k].note_index)
                    }
            }
        }
    }
}