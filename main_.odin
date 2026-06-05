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


// ----------------------------------------------------------------------------------- data
audio_data: ^Audio_Data
window: glfw.WindowHandle

window_width  :: 1280
window_height :: 720

window_flags: Window_Flags


// ----------------------------------------------------------------------------------- helpers
init :: proc()
{
    logging.init_time()
    init_window_flags()
    init_key_map()

    init_audio_data()
}

init_audio_data :: proc()
{
    audio_data = new(Audio_Data)
    audio_data.synths_list[0] =
    {
        wt1 = Wav_Raw{ waveform = .Square },
        wt2 = Wav_Raw{ waveform = .Square },
        warp = .2,

        adsr = {
            attack = .01,
            decay = .2,
            sustain = .5,
            release = 1,
        },

        voice_count = 1,
        detune = 0,
    }
    
    audio_data.synths_list[1] =
    {
        wt1 = Wav_Raw{ waveform = .Sine },
        wt2 = Wav_Raw{ waveform = .Saw },
        warp = .9,

        adsr = {
            attack = .1,
            decay = .2,
            sustain = .7,
            release = 1,
        },

        voice_count = 1,
        detune = 0,
    }
}


// ----------------------------------------------------------------------------------- main
main :: proc()
{
    init()


    // ----------------------------------------------------------------------------------- init glfw
    if !glfw.Init()
    {
        fmt.printfln("Failed to initialize glfw")
        return
    }
    defer glfw.Terminate()


    // ----------------------------------------------------------------------------------- create glfw window
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    
    window = glfw.CreateWindow(window_width, window_height, "XenKeys", nil, nil)
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
    

    // ----------------------------------------------------------------------------------- miniaudio device config
    device_config := ma.device_config_init(ma.device_type.playback)
    device_config.playback.format   = .f32
    device_config.playback.channels = 2
    device_config.sampleRate        = 44100
    device_config.dataCallback      = audio_callback
    // device_config.periodSizeInFrames = 512 // default is 441
    device_config.pUserData         = audio_data

    device: ma.device
    if ma.device_init(nil, &device_config, &device) != .SUCCESS
    {
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


    // ----------------------------------------------------------------------------------- ui render loop
    for !glfw.WindowShouldClose(window)
    {
        render_ui()

        // imgui.Begin("Waveform", nil, window_flags.default)
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
    }
}