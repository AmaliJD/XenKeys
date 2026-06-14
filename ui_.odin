package main

import "core:fmt"
import "core:reflect"
import "core:strings"

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
    space_key: Key,
    extra_keys: [6]Key,
    extra_index: [6]i16,

    waveform_view: [256]f32,
}{
    space_key = { id = glfw.KEY_SPACE },
    extra_keys = {
        { id = glfw.KEY_Z },
        { id = glfw.KEY_S },
        { id = glfw.KEY_E },
        { id = glfw.KEY_C },
        { id = glfw.KEY_F },
        { id = glfw.KEY_T },
    },
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

    press_key_note(&(ui_data.extra_keys[0]), &(ui_data.extra_index[0]), 220 * 16/15)
    press_key_note(&(ui_data.extra_keys[1]), &(ui_data.extra_index[1]), 220 * 5/4)
    press_key_note(&(ui_data.extra_keys[2]), &(ui_data.extra_index[2]), 220 * 8/5)
    press_key_note(&(ui_data.extra_keys[3]), &(ui_data.extra_index[3]), 220 * 15/14)
    press_key_note(&(ui_data.extra_keys[4]), &(ui_data.extra_index[4]), 220 * 9/7)
    press_key_note(&(ui_data.extra_keys[5]), &(ui_data.extra_index[5]), 220 * 13/8)

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

            if imgui.IsMouseHoveringRect(cell_tl, cell_br) && imgui.IsMouseClicked(.Left)
            {
                audio_data.synth_index = i
            }
        }

        grid_width  := MAX_SYNTHS * (cell_width + padding_x) - padding_x
        grid_height := cell_height + 2 * padding_y
        imgui.Dummy(imgui.Vec2{grid_width, grid_height})


        synth := &audio_data.synths_list[audio_data.synth_index]
        button_label_1: cstring = strings.clone_to_cstring(fmt.tprintf("%s##wt1", get_waveform_type_label(synth.wt1)))
        button_label_2: cstring = strings.clone_to_cstring(fmt.tprintf("%s##wt2", get_waveform_type_label(synth.wt2)))

        imgui.Dummy(imgui.Vec2{0, 5})
        if imgui.Button(button_label_1)
        {
            #partial switch &w in synth.wt1
            {
                case nil:
                    synth.wt1 = Wav_Raw { waveform = .Sine }

                case Wav_Raw:
                    next := int(w.waveform) + 1
                    if next < len(Waveform)
                    {
                        w.waveform = Waveform(next)
                    }
                    else
                    {
                        synth.wt1 = nil
                    }
            }
        }

        imgui.SameLine(90)
        imgui.SliderFloat("##Warp", &synth.warp, 0.0, 1.0, "%.2f")

        style := imgui.GetStyle()
        wt2_button_offset := (grid_width + 35) - imgui.CalcTextSize(button_label_2).x
        imgui.SameLine(wt2_button_offset)
        if imgui.Button(button_label_2)
        {
            #partial switch &w in synth.wt2
            {
                case nil:
                    synth.wt2 = Wav_Raw { waveform = .Sine }

                case Wav_Raw:
                    next := int(w.waveform) + 1
                    if next < len(Waveform)
                    {
                        w.waveform = Waveform(next)
                    }
                    else
                    {
                        synth.wt2 = nil
                    }
            }
        }

        imgui.PushItemWidth(100.0)
        imgui.Dummy(imgui.Vec2{0, 10})
        imgui.Text("A:")
        imgui.SameLine(0, 2)
        imgui.SliderFloat("##wt1_A", &synth.adsr.attack, 0.0, 1.0, "%.2f")
        imgui.SameLine(0, 15)
        imgui.Text("D:")
        imgui.SameLine(0, 2)
        imgui.SliderFloat("##wt1_D", &synth.adsr.decay, 0.0, 1.0, "%.2f")
        imgui.SameLine(0, 15)
        imgui.Text("S:")
        imgui.SameLine(0, 2)
        imgui.SliderFloat("##wt1_S", &synth.adsr.sustain, 0.0, 1.0, "%.2f")
        //imgui.SameLine(0, 15)
        imgui.Text("R:")
        imgui.SameLine(0, 2)
        imgui.PushItemWidth(362.0)
        imgui.SliderFloat("##wt1_R", &synth.adsr.release, 0.0, 5.0, "%.2f")
        
        imgui.PushItemWidth(290.0)
        imgui.Dummy(imgui.Vec2{0, 10})
        imgui.Text("Down Sample:")
        imgui.SameLine(98)
        imgui.SliderInt("##DownSample", &synth.down_sample, 0, 32, "%d")

        imgui.Text("Bit Crush:")
        imgui.SameLine(98)
        imgui.SliderInt("##BitCrush", &synth.bit_crush, 0, 32, "%d")

        imgui.Dummy(imgui.Vec2{0, 10})
        imgui.Text("Phase Skew:")
        imgui.SameLine(98)
        imgui.SliderFloat("##PhaseSkew", &synth.phase_skew, -1, 1, "%.2f")

        imgui.Text("Amp Skew:")
        imgui.SameLine(98)
        imgui.SliderFloat("##AmpSkew", &synth.amp_skew, -1, 1, "%.2f")

        imgui.Dummy(imgui.Vec2{0, 10})
        imgui.PushItemWidth(240.0)
        imgui.Text("Vibrato Strength:")
        imgui.SameLine(135)
        imgui.SliderFloat("##Vibrato Strength", &synth.vibrato, 0, 100, "%.2f")

        imgui.Text("Vibrato Hz:")
        imgui.SameLine(135)
        imgui.SliderFloat("##Vibrato Hz", &synth.vibrato_hz, 0, 20, "%.2f")

        imgui.PopItemWidth()

        imgui.Dummy(imgui.Vec2{0, 30})

        write_wav_values_to_buffer(
            ui_data.waveform_view[:],
            synth,
            0,
            3,
            true,
        )

        imgui.PlotLines(
            "##Waveform",
            &ui_data.waveform_view[0],
            len(ui_data.waveform_view),
            0, nil, -1.1, 1.1,
            {imgui.GetContentRegionAvail().x, 180},
        )
        
    imgui.End()
}

get_waveform_type_label :: proc(wt: Waveform_Type) -> string
{
    switch w in wt
    {
        case nil:
            return "None"

        case Wav_Raw:
            return reflect.enum_string(w.waveform)

        case Wav_Harmonics, Wav_Sample, Wav_Sf, Wav_Test:
            return "Undefined"
    }

    return "Undefined"
}