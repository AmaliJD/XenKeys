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


    // ----------------------------------------------------------------------------------- start frame
    imgui_gl.NewFrame()
    imgui_glfw.NewFrame()
    imgui.NewFrame()


    // ----------------------------------------------------------------------------------- ui
    draw_log()
    draw_output_buffer()


    // ----------------------------------------------------------------------------------- rendering
    gl.ClearColor(rgba(bg_color))
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
        imgui.PushStyleColor(.FrameBg, hex32(&_clear))
        imgui.ProgressBar(math.max(audio_data.peak_value - 1, 0), imgui.Vec2{0, 0}, " ")

        imgui.SameLine()
        imgui.Text("%.2f", audio_data.peak_value)

        imgui.PopStyleColor(3)
    imgui.End()
}