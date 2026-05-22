package main

import "core:fmt"

import "imgui"
import imgui_glfw "imgui/imgui_impl_glfw"
import imgui_gl "imgui/imgui_impl_opengl3"

import "vendor:glfw"
import gl "vendor:OpenGL"
import ma "vendor:miniaudio"

import wav "waveforms"


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
    altKeyPressed: bool
    warp_up: bool
    warp_move:=false
    warp_speed:=f32(.0005)

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

        if glfw.GetKey(window, glfw.KEY_LEFT_ALT) == glfw.PRESS && !altKeyPressed
        {
            warp_move = !warp_move
        }
        altKeyPressed = glfw.GetKey(window, glfw.KEY_LEFT_ALT) == glfw.PRESS

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