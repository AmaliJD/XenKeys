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
    space_key: Key
}{
    space_key = { id = glfw.KEY_SPACE }
}

render_ui :: proc()
{
    // ----------------------------------------------------------------------------------- input
    glfw.PollEvents()

    update_keys()
    if ui_data.space_key.pressed_this_frame
    {
        audio_data.synth_index = (audio_data.synth_index + 1) % MAX_SYNTHS
    }

    audio_data.log.elapsed_time = logging.get_time()


    // ----------------------------------------------------------------------------------- start frame
    imgui_gl.NewFrame()
    imgui_glfw.NewFrame()
    imgui.NewFrame()


    // ----------------------------------------------------------------------------------- ui
    draw_log()
    draw_output_buffer()
    draw_note_list()
    draw_synth_display()


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
    imgui.Begin("Note List", nil, window_flags.locked)
        note_count: u16 = 0
        cell_size: f32 = 24.0
        padding: f32 = 6.0

        draw_start_pos := imgui.GetCursorScreenPos()
        draw_list := imgui.GetWindowDrawList()

        for row := 0; row < 8; row += 1
        {
            for col := 0; col < 8; col += 1
            {
                index := row * 8 + col

                // u32 Hex Literals 0xFFFFFFFF (Format: 0x_AA_BB_GG_RR)
                color: u32
                switch audio_data.notes_list[index].state
                {
                    case .Inactive:
                        if note_count < audio_data.note_count
                        {
                            color_1_low := color_1
                            color_1_low.a = .13
                            color = hex32(&color_1_low)
                        }
                        else
                        {
                            color = hex32(&gray_13)
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
                
                cell_tl := imgui.Vec2 {
                    draw_start_pos.x + f32(col) * (cell_size + padding),
                    draw_start_pos.y + f32(row) * (cell_size + padding),
                }
                cell_br := imgui.Vec2 {
                    cell_tl.x + cell_size,
                    cell_tl.y + cell_size,
                }
                
                imgui.DrawList_AddRectFilled(draw_list, cell_tl, cell_br, color)
                imgui.DrawList_AddRect(draw_list, cell_tl, cell_br, hex32(&gray_25))
            }
        }
        
        grid_width  := 8 * (cell_size + padding) - padding
        grid_height := 8 * (cell_size + padding) - padding
        imgui.Dummy(imgui.Vec2{grid_width, grid_height})
    imgui.End()
}

draw_synth_display :: proc()
{
    imgui.Begin("Synths", nil, window_flags.locked)
        cell_width: f32 = 42.0
        cell_height: f32 = 12.0
        padding_x: f32 = 6.0
        padding_y: f32 = 6.0

        draw_start_pos := imgui.GetCursorScreenPos()
        draw_list := imgui.GetWindowDrawList()

        for i: u16 = 0; i < MAX_SYNTHS; i += 1
        {
            color: u32
            if i != audio_data.synth_index
            {
                color = hex32(&gray_13)
            }
            else
            {
                color = hex32(&WHITE)
            }

            cell_tl := imgui.Vec2 {
                draw_start_pos.x + f32(i) * (cell_width + padding_x),
                draw_start_pos.y + padding_y,
            }
            cell_br := imgui.Vec2 {
                cell_tl.x + cell_width,
                cell_tl.y + cell_height,
            }

            imgui.DrawList_AddRectFilled(draw_list, cell_tl, cell_br, color)
            imgui.DrawList_AddRect(draw_list, cell_tl, cell_br, hex32(&gray_25))
        }

        grid_width  := MAX_SYNTHS * (cell_width + padding_x) - padding_x
        grid_height := cell_height + 2 * padding_y
        imgui.Dummy(imgui.Vec2{grid_width, grid_height})
    imgui.End()
}