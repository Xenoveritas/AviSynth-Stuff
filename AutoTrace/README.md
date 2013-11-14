AutoTraceFilter
===============

Project for building an intentionally useless plugin that uses AutoTrace to
trace and then resize a source image.

This plugin is licensed under the GPLv2 to match the AutoTrace license.

Usage
-----

Currently the input clip has to be RGB24, which is somewhat weird. AutoTrace
only works on RGB24 clips, so you have to convert it to RGB24.

The filter itself is just `AutoTrace(clip input, int width, int height)` and
resizes the `input` clip to `width`x`height`. The output video is RGB32, because
it renders the vectors using GDI+ and that's what it returns. (Incidentally,
because this relies on GDI+, this requires Windows XP or later.)

A simple example:

    LoadPlugin("AutoTraceFilter.dll")
    video = AviSource("video.avi")
    video = AutoTrace(video.ConvertToRGB24(), 1440, 1080)
    video = video.ChangeFPS(30)
    video.FadeOut(30)
    ConvertToYV12()
