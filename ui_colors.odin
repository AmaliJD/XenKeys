package main

import "imgui"

Color :: [4]f32
bg_color : Color = { 0.15, 0.15, 0.15, 1.0 }
color_1 : Color = { 1.0, 0.3, 0.0, 1.0 }
color_2 : Color = { 1.0, 0.8, 0.0, 1.0 }

_clear : Color = { 0.0, 0.0, 0.0, 0.0 }
_white : Color = { 1.0, 1.0, 1.0, 1.0 }
_black : Color = { 0.0, 0.0, 0.0, 1.0 }

rgba :: proc(c: Color) -> (f32, f32, f32, f32)
{
    return c.r, c.g, c.b, c.a
}

vec4 :: proc(c: ^Color) -> imgui.Vec4
{
    return (^imgui.Vec4)(c)^
}

hex32 :: proc(c: ^Color) -> u32
{
    return imgui.ColorConvertFloat4ToU32(vec4(c))
}