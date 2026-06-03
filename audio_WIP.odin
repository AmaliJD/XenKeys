package main

Hard_Params :: enum // hard set and don't change
{
    
}

Soft_Params :: enum // modulatable
{

}

Modulation :: struct
{
    final_value: f32,
    lfo: LFO,
    delay, fade_in: f32,
}

LFO :: struct
{
    frequency: f32,
    low, high: f32,
}