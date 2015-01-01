AutoTraceFilter
===============

An intentionally useless plugin that uses AutoTrace to trace and then resize a
source video, rendering the result using GDI+. (GDI+ requires Windows XP or
later.)

This plugin is licensed under the GPLv2 to match the AutoTrace license.

Usage
-----

Currently the input clip has to be RGB24, which is somewhat weird. AutoTrace
only works on RGB24 clips, so you have to convert it to RGB24. (Otherwise I'd
have to convert it, and since AviSynth has a converter, might as well use the
one it has. A future version might automate that step.)

The filter itself is:

`AutoTraceResize(clip c, int width=0, int height=0, int colors=0, int background_color=-1)`

| parameter        | default    | description
|------------------|------------|-------------------------
| c                | (required) | the clip to resize, must be RGB24
| width            | 0          | the width to resize to, if 0 (or less), this is based on the height, preserving the aspect ratio - if both are unset (or 0 or less), they are set to the input size
| height           | 0          | the height to resize to, if 0 (or less), this is based on the width, preserving the aspect ratio - if both are unset (or 0 or less), they are set to the input size
| colors           | 0          | AutoTrace's `color_count`: reduce the image to this number of colors before tracing, defaults to 0 - no color reduction. Must be between 0-256.
| background_color | -1         | The background color. If set, pixels of this color will be considered "background" and won't be rendered to the output RGB32 image. The color is in 0xRRGGBB format, the alpha channel is ignored.

The generated video is RGB32, and can contain transparent pixels if you used the
background_color option.

A simple example:

    LoadPlugin("AutoTraceFilter.dll")
    video = AviSource("video.avi")
    video = AutoTraceResize(video.ConvertToRGB24(), 1440, 1080)
    video = video.ChangeFPS(30)
    video.FadeOut(30)
    ConvertToYV12()
