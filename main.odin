package main

import "core:fmt"

import "imgui"
import imgui_glfw "imgui/imgui_impl_glfw"
import imgui_gl "imgui/imgui_impl_opengl3"

import "vendor:glfw"
import gl "vendor:OpenGL"
import ma "vendor:miniaudio"

import wav "waveforms"

window_width  : i32 = 1280
window_height : i32 = 720

main :: proc() {
    // Init GLFW
    if !glfw.Init() {
        fmt.printfln("Failed to initialize GLFW")
        return
    }
    defer glfw.Terminate()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    // Create Window
    window := glfw.CreateWindow(window_width, window_height, "XenKeys", nil, nil)
    if (window == nil) {
        fmt.printfln("Failed to create window")
        return
    }
    glfw.MakeContextCurrent(window)

    // Connect window (GLFW) to graphics card (OpenGL)
    gl.load_up_to(3, 3, glfw.gl_set_proc_address)

    glfw.SetWindowSizeLimits(window, 320, 180, glfw.DONT_CARE, glfw.DONT_CARE)

    audio_data : Audio_Data
    audio_data.note.frequency = 220

    device_config := ma.device_config_init(ma.device_type.playback)
    device_config.playback.format   = .f32
    device_config.playback.channels = 2
    device_config.sampleRate        = 44100
    device_config.dataCallback      = audio_callback
    // device_config.periodSizeInFrames = 512 // default is 441
    device_config.pUserData         = &audio_data

    device: ma.device
    if ma.device_init(nil, &device_config, &device) != .SUCCESS {
        fmt.println("Failed to set up audio device")
        return
    }
    ma.device_start(&device)
    defer ma.device_uninit(&device)

    imgui.CreateContext()
    imgui_glfw.InitForOpenGL(window, true)
    imgui_gl.Init("#version 330")
    defer {
        imgui_gl.Shutdown()
        imgui_glfw.Shutdown()
        imgui.DestroyContext()
    }

    window_flags := get_window_flags()

    waveform_visual : [128]f32
    zKeyPressed: bool
    // Main Loop
    for !glfw.WindowShouldClose(window) {
        // Input
        glfw.PollEvents()
        audio_data.keyPressed = glfw.GetKey(window, glfw.KEY_SPACE) == glfw.PRESS
        
        if glfw.GetKey(window, glfw.KEY_Z) == glfw.PRESS && !zKeyPressed {
            audio_data.waveform = wav.Waveform((int(audio_data.waveform) + 1) % 4)
        }
        zKeyPressed = glfw.GetKey(window, glfw.KEY_Z) == glfw.PRESS

        // Start Frame
        imgui_gl.NewFrame()
        imgui_glfw.NewFrame()
        imgui.NewFrame()

        // UI
        imgui.Begin("Log", nil, window_flags.invisible)
        imgui.Text("Buffer Size: %d", audio_data.logger.bufferSize)
        imgui.Text("Key Pressed: %d", audio_data.keyPressed)
        imgui.End()

        imgui.Begin("Waveform", nil, window_flags.default)
        wav.get_wave_values(waveform_visual[:], 0, 1, audio_data.waveform)
        imgui.PlotLines(
            "##Waveform",
            &waveform_visual[0],
            len(waveform_visual),
            0, nil, -1.1, 1.1,
            {imgui.GetContentRegionAvail().x, imgui.GetContentRegionAvail().y},
        )
        imgui.End()

        // Rendering
        gl.ClearColor(0.15, 0.15, 0.15, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        imgui.Render()
        imgui_gl.RenderDrawData(imgui.GetDrawData())

        glfw.SwapBuffers(window)
    }
}