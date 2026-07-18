Original version was made in [Unity](https://github.com/AmaliJD/MusicTester) but I want to expand this and build it in a lower level langugae, no Unity overhead


The current version of the synth includes a **global waveform** and **polyphonic keyboard input**

https://github.com/user-attachments/assets/f0615092-4c14-4838-88b3-4c75695aee93



https://github.com/user-attachments/assets/a7bab85b-aa84-4bd9-9ad2-beae675c9300


-----------------------------------------------------------------------------------
Run in debug mode with the following command:
*odin run . **-debug** -extra-linker-flags:"/LIBPATH:./imgui"*

The build may fail several times due to a debug mode bug handling function aliases.

-----------------------------------------------------------------------------------
Run in release mode with the following command:
*odin run . **-o:speed** -extra-linker-flags:"/LIBPATH:./imgui"*
