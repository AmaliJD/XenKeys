package main

import "imgui"

WINDOW_FLAGS_INVISIBLE :: imgui.WindowFlags {
    .NoTitleBar, 
    .NoResize,
    .NoBackground,
    .AlwaysAutoResize,
    .NoMove,
}

Window_Flags :: struct {
    default, invisible : imgui.WindowFlags
}

get_window_flags :: proc() -> Window_Flags
{
    win_flag : Window_Flags = {
        default   = {},
        invisible = WINDOW_FLAGS_INVISIBLE
    }
    return win_flag
}