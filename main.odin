package main

import "core:fmt"

import "imgui"
import imgui_glfw "imgui/imgui_impl_glfw"
import imgui_gl "imgui/imgui_impl_opengl3"

import "vendor:glfw"
import gl "vendor:OpenGL"
import ma "vendor:miniaudio"

import wav "waveforms"
import "logging"
import "mathx"
import "core:math"


audio_data: ^Audio_Data


main :: proc() {
    // ----------------------------------------------------------------------------------- init glfw
    if !glfw.Init()
    {
        fmt.printfln("Failed to initialize GLFW")
        return
    }
    defer glfw.Terminate()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)


    // ----------------------------------------------------------------------------------- create window
    window_width  : i32 = 1280
    window_height : i32 = 720
    window := glfw.CreateWindow(window_width, window_height, "XenKeys", nil, nil)
    if (window == nil)
    {
        fmt.printfln("Failed to create window")
        return
    }
    glfw.MakeContextCurrent(window)
    glfw.SetKeyCallback(window, key_callback)


    // ----------------------------------------------------------------------------------- connect window (GLFW) to graphics card (OpenGL)
    gl.load_up_to(3, 3, glfw.gl_set_proc_address)
    glfw.SetWindowSizeLimits(window, 320, 180, glfw.DONT_CARE, glfw.DONT_CARE)


    // ----------------------------------------------------------------------------------- Audio_Data
    audio_data = new(Audio_Data)
    audio_data.q_freq = 6.0/5.0
    audio_data.w_freq = 8.0/5.0
    audio_data.e_freq = 4.0/3.0
    audio_data.r_freq = 1.645
    audio_data.adsr = {
        attack = .1,
        decay = .1,
        sustain = .5,
        release = 1,
    }


    // ----------------------------------------------------------------------------------- device config
    device_config := ma.device_config_init(ma.device_type.playback)
    device_config.playback.format   = .f32
    device_config.playback.channels = 2
    device_config.sampleRate        = 44100
    device_config.dataCallback      = audio_callback
    // device_config.periodSizeInFrames = 512 // default is 441
    device_config.pUserData         = audio_data

    device: ma.device
    if ma.device_init(nil, &device_config, &device) != .SUCCESS {
        fmt.println("Failed to set up audio device")
        return
    }
    ma.device_start(&device)
    defer ma.device_uninit(&device)


    // ----------------------------------------------------------------------------------- imgui setup
    imgui.CreateContext()
    imgui_glfw.InitForOpenGL(window, true)
    imgui_gl.Init("#version 330")
    defer
    {
        imgui_gl.Shutdown()
        imgui_glfw.Shutdown()
        imgui.DestroyContext()
    }

    window_flags := get_window_flags()


    // ----------------------------------------------------------------------------------- key input setup
    init_key_map()
    defer delete(key_map)


    // ----------------------------------------------------------------------------------- render loop
    waveform_visual : [256]f32
    output_visual : [2005]f32
    output_samples_count := len(output_visual)
    zKeyPressed: bool
    xKeyPressed: bool
    spaceKeyPressed: bool
    warp_up: bool
    warp_move:=false
    warp_speed:=f32(.0005)
    last_value := f32(0)
    
    for !glfw.WindowShouldClose(window)
    {
        // ----------------------------------------------------------------------------------- input
        glfw.PollEvents()
        
        if glfw.GetKey(window, glfw.KEY_Z) == glfw.PRESS && !zKeyPressed
        {
            audio_data.wave_data.warp = 0
            warp_up = false
            audio_data.wave_data.waveform_1 = wav.Waveform((int(audio_data.wave_data.waveform_1) + 1) % len(wav.Waveform))
        }
        zKeyPressed = glfw.GetKey(window, glfw.KEY_Z) == glfw.PRESS

        if glfw.GetKey(window, glfw.KEY_X) == glfw.PRESS && !xKeyPressed
        {
            audio_data.wave_data.waveform_2 = wav.Waveform((int(audio_data.wave_data.waveform_2) + 1) % 5)
            audio_data.wave_data.warp = 0
            warp_up = false
        }
        xKeyPressed = glfw.GetKey(window, glfw.KEY_X) == glfw.PRESS

        if glfw.GetKey(window, glfw.KEY_SPACE) == glfw.PRESS && !spaceKeyPressed
        {
            warp_move = !warp_move
        }
        spaceKeyPressed = glfw.GetKey(window, glfw.KEY_SPACE) == glfw.PRESS

        if warp_move
        {
            if warp_up { audio_data.wave_data.warp += warp_speed }
            else { audio_data.wave_data.warp -= warp_speed }

            if audio_data.wave_data.warp <= 0 && !warp_up
            {
                audio_data.wave_data.warp = 0
                warp_up = true
            }
            else if audio_data.wave_data.warp >= 1 && warp_up
            {
                audio_data.wave_data.warp = 1
                warp_up = false
            }
        }


        // ----------------------------------------------------------------------------------- start frame
        imgui_gl.NewFrame()
        imgui_glfw.NewFrame()
        imgui.NewFrame()


        // ----------------------------------------------------------------------------------- ui
        imgui.Begin("Log", nil, window_flags.invisible)
            imgui.Text("Buffer Size: %d", audio_data.logger.buffer_size)
            imgui.Separator()
            imgui.Text(fmt.ctprint("Wave 1:", audio_data.wave_data.waveform_1))
            imgui.Text(fmt.ctprint("Wave 2:", audio_data.wave_data.waveform_2))
            imgui.Text("warp amt: %.2f", audio_data.wave_data.warp)
            imgui.Dummy(imgui.Vec2{0, 15})
            imgui.Text("Note Count: %d", audio_data.note_count)
            imgui.Dummy(imgui.Vec2{0, 15})
            imgui.TextColored(imgui.Vec4{1.0, 0.3, 0.0, 1.0}, "elapsed time: %.3f ms", audio_data.logger.elapsed_time)
        imgui.End()

        imgui.Begin("Value", nil, window_flags.draggable)
            value_01 := mathx.clamp_01(audio_data.value)
            if value_01 > last_value
            {
                last_value = value_01
            }
            else
            {
                lerp_value := f32(.001)
                if audio_data.note_count == 0 {
                    lerp_value = .01
                }
                last_value = mathx.lerp(last_value, value_01, lerp_value)
            }
            // value_over_1 := mathx.clamp_01(audio_data.value - 1)
            imgui.ProgressBar(last_value, imgui.Vec2{0, 0}, " ")
        imgui.End()

        imgui.Begin("Note List", nil, window_flags.default)
            grid_start := imgui.GetCursorScreenPos()
            
            block_size: f32 = 24.0
            padding:    f32 = 6.0
            
            // Fetch the active window draw list
            draw_list := imgui.GetWindowDrawList()

            // Loop through an 8x8 grid layout
            for row := 0; row < 8; row += 1 {
                for col := 0; col < 8; col += 1 {
                    // Map 2D grid back to your flat 64-element array index
                    idx := row * 8 + col
                    if idx >= 64 do break
                    
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
                    switch audio_data.notes_list[idx].state {
                    case .Inactive:
                        color = 0xFF222222
                    case .Queued:
                        color = 0xFF0000FF
                    case .On:
                        color = 0xFFFFFFFF
                    case .Off:
                        color = 0xCCFF9911
                    }
                    
                    // Draw the filled square rectangle background
                    imgui.DrawList_AddRectFilled(draw_list, p_min, p_max, color)
                    
                    // Optional: Draw a thin subtle border outline around every square 
                    border_color: u32 = 0xFF444444
                    imgui.DrawList_AddRect(draw_list, p_min, p_max, border_color)
                }
            }
            
            // Explicitly calculate and tell ImGui how much layout space our custom drawings took up.
            // This ensures subsequent ImGui widgets (buttons, text) don't clip over the grid.
            total_grid_width  := 8 * (block_size + padding)
            total_grid_height := 8 * (block_size + padding)
        imgui.End()

        imgui.Begin("Waveform", nil, window_flags.default)
            wav.get_wave_values(
                waveform_visual[:],
                0,
                3,
                audio_data.wave_data.waveform_1,
                audio_data.wave_data.waveform_2,
                audio_data.wave_data.warp,
            )
            imgui.PlotLines(
                "##Waveform",
                &waveform_visual[0],
                len(waveform_visual),
                0, nil, -1.1, 1.1,
                {imgui.GetContentRegionAvail().x, imgui.GetContentRegionAvail().y},
            )
        imgui.End()

        // imgui.Begin("Output", nil, window_flags.default)
        //     wav.get_wave_values(
        //         waveform_visual[:],
        //         0,
        //         3,
        //         audio_data.wave_data.waveform_1,
        //         audio_data.wave_data.waveform_2,
        //         audio_data.wave_data.warp,
        //     )
        //     imgui.PlotLines(
        //         "##Waveform",
        //         &waveform_visual[0],
        //         len(waveform_visual),
        //         0, nil, -1.1, 1.1,
        //         {imgui.GetContentRegionAvail().x, imgui.GetContentRegionAvail().y},
        //     )
        // imgui.End()


        // ----------------------------------------------------------------------------------- rendering
        gl.ClearColor(0.15, 0.15, 0.15, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        imgui.Render()
        imgui_gl.RenderDrawData(imgui.GetDrawData())

        glfw.SwapBuffers(window)
    }
}