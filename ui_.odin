package main

import "core:fmt"

import "imgui"
import imgui_glfw "imgui/imgui_impl_glfw"
import imgui_gl "imgui/imgui_impl_opengl3"

import "vendor:glfw"
import gl "vendor:OpenGL"
import ma "vendor:miniaudio"

import "logging"
import "mathx"
import "core:math"


ui_data := struct
{
    
}{

}

render :: proc(window: glfw.WindowHandle)
{
    // ----------------------------------------------------------------------------------- input
    glfw.PollEvents()
    audio_data.log.elapsed_time = logging.get_time()


    // ----------------------------------------------------------------------------------- start frame
    imgui_gl.NewFrame()
    imgui_glfw.NewFrame()
    imgui.NewFrame()


    // ----------------------------------------------------------------------------------- ui
    draw_log()
    draw_output_buffer()
    draw_note_list()


    // ----------------------------------------------------------------------------------- rendering
    gl.ClearColor(rgba(gray_15))
    gl.Clear(gl.COLOR_BUFFER_BIT)

    imgui.Render()
    imgui_gl.RenderDrawData(imgui.GetDrawData())

    glfw.SwapBuffers(window)
}

draw_log :: proc()
{
    imgui.Begin("Log", nil, window_flags.invisible)
        imgui.Text("Note Count: %d", audio_data.note_count)
        imgui.Dummy(imgui.Vec2{0, 10})
        imgui.TextColored(vec4(&color_1), "elapsed time: %.3f ms", audio_data.log.elapsed_time)
    imgui.End()
}

draw_output_buffer :: proc()
{
    imgui.Begin("Output Buffer", nil, window_flags.draggable)
        cursor_pos := imgui.GetCursorPos()
        imgui.PushStyleColor(.PlotHistogram, hex32(&color_1))
        imgui.ProgressBar(audio_data.peak_value, imgui.Vec2{0, 0}, " ")

        imgui.SetCursorPos(cursor_pos)
        imgui.PushStyleColor(.PlotHistogram, hex32(&color_2))
        imgui.PushStyleColor(.FrameBg, hex32(&CLEAR))
        imgui.ProgressBar(math.max(audio_data.peak_value - 1, 0), imgui.Vec2{0, 0}, " ")

        imgui.SetCursorPos(cursor_pos)
        imgui.PushStyleColor(.PlotHistogram, hex32(&WHITE))
        imgui.ProgressBar(math.max(audio_data.peak_value - 2, 0), imgui.Vec2{0, 0}, " ")

        imgui.SameLine()
        imgui.Text("%.2f", audio_data.peak_value)

        imgui.PopStyleColor(4)
    imgui.End()
}

draw_note_list :: proc()
{
    imgui.Begin("Note List", nil, window_flags.default)
        note_count: u16 = 0
        block_size: f32 = 24.0
        padding:    f32 = 6.0

        grid_start := imgui.GetCursorScreenPos()
        draw_list := imgui.GetWindowDrawList()

        // Loop through an 8x8 grid layout
        for row := 0; row < 8; row += 1
        {
            for col := 0; col < 8; col += 1
            {
                index := row * 8 + col
                if index >= 64 do break
                
                // Calculate the exact bounding box pixels for this specific slot
                p_min := imgui.Vec2{
                    grid_start.x + f32(col) * (block_size + padding),
                    grid_start.y + f32(row) * (block_size + padding),
                }
                p_max := imgui.Vec2{
                    p_min.x + block_size,
                    p_min.y + block_size,
                }
                
                // Assign packed u32 colors directly using Hex Literals (Format: 0x_AA_BB_GG_RR)
                color: u32
                switch audio_data.notes_list[index].state {
                case .Inactive:
                    color = hex32(&gray_13)
                    if note_count < audio_data.note_count {
                        color_1_low := color_1
                        color_1_low.a = .13
                        color = hex32(&color_1_low)
                    }
                case .Queued:
                    color = hex32(&RED)
                case .On:
                    color = hex32(&WHITE)
                    note_count += 1
                case .Off:
                    color = hex32(&color_3)
                    note_count += 1
                }
                
                imgui.DrawList_AddRectFilled(draw_list, p_min, p_max, color)
                border_color: u32 = 0xFF444444
                imgui.DrawList_AddRect(draw_list, p_min, p_max, border_color)
            }
        }
        
        // Explicitly calculate and tell ImGui how much layout space our custom drawings took up.
        // This ensures subsequent ImGui widgets (buttons, text) don't clip over the grid.
        // total_grid_width  := 8 * (block_size + padding)
        // total_grid_height := 8 * (block_size + padding)
    imgui.End()
}