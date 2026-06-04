package main

import "imgui"

// ----------------------------------------------------------------------------------- data
WINDOW_FLAGS_INVISIBLE :: imgui.WindowFlags {
    .NoTitleBar, 
    .NoResize,
    .NoBackground,
    .AlwaysAutoResize,
    .NoMove,
}

WINDOW_FLAGS_DRAGGABLE :: imgui.WindowFlags {
    .NoTitleBar,
    // .NoResize,
    .NoBackground,
    // .AlwaysAutoResize,
}

Window_Flags :: struct {
    default, invisible, draggable : imgui.WindowFlags
}

// ----------------------------------------------------------------------------------- procs
init_window_flags :: proc()
{
    window_flags = {
        default   = {},
        invisible = WINDOW_FLAGS_INVISIBLE,
        draggable = WINDOW_FLAGS_DRAGGABLE,
    }
}