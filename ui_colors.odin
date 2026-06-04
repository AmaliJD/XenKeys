package main

import "imgui"

Color :: [4]f32
gray_15 : Color = { 0.15, 0.15, 0.15, 1.0 }
gray_13 : Color = { 0.13, 0.13, 0.13, 1.0 }

color_1 : Color = { 1.0, 0.3, 0.0, 1.0 }
color_2 : Color = { 1.0, 0.8, 0.0, 1.0 }
color_3 : Color = { 0.0, 0.6, 1.0, 0.8 }

CLEAR : Color = { 0.0, 0.0, 0.0, 0.0 }
WHITE : Color = { 1.0, 1.0, 1.0, 1.0 }
BLACK : Color = { 0.0, 0.0, 0.0, 1.0 }
RED : Color = { 1.0, 0.0, 0.0, 1.0 }

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