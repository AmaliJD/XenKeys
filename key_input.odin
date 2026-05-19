package main

import "core:fmt"
import "base:runtime"
import "vendor:glfw"

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32)
{
    context = runtime.default_context()

    switch action
    {
        case glfw.PRESS:
            switch key
            {
                case glfw.KEY_GRAVE_ACCENT:
                    add_command_note_on(440)
                case glfw.KEY_1:
                case glfw.KEY_2:
                case glfw.KEY_3:
                case glfw.KEY_4:
                case glfw.KEY_5:
                case glfw.KEY_6:
                case glfw.KEY_7:
                case glfw.KEY_8:
                case glfw.KEY_9:
                case glfw.KEY_0:
                case glfw.KEY_MINUS:
                case glfw.KEY_EQUAL:
            }

        case glfw.RELEASE:
            switch key
            {
                case glfw.KEY_GRAVE_ACCENT:
            }
    }
}