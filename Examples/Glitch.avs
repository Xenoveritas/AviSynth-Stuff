# Example of glitch filters

Import("..\Glitch.avsi")

example_clip = ImageSource("shoreline.jpg", pixel_type="RGB32", fps=60, start=1, end=640)
example_yuv_clip = example_clip.ConvertToYV12()

function AnimatedRoll(clip c, string type, int dir) {
  return Animate(c, 0, c.FrameCount() - 1, type, 0, (c.FrameCount() - 1) * dir)
}

roll_left = example_clip.AnimatedRoll("RollHorizontal", -1)
roll_right = example_clip.AnimatedRoll("RollHorizontal", 1)
roll_up = example_clip.AnimatedRoll("RollVertical", -1)
roll_down = example_clip.AnimatedRoll("RollVertical", 1)
posterize_ex = example_clip.Animate(0, 1000, "Posterize", 1, 32)

function WobbleRGBAnim(clip c, int count) {
  return c.SplitRGB(8 - Round(Sin(count/15.0)*8))
}

color_shift_example = Animate(example_clip, 0, example_clip.FrameCount()-1, "WobbleRGBAnim", 1, example_clip.FrameCount())

# And another example using YUV to shift chroma:
#chroma_shift_example = ColorBars(example_clip.Width(), example_clip.Height(), "YV12").AssumeFPS(example_clip).KillAudio().SplitChroma(0).ConvertToRGB32()
chroma_shift_example = example_yuv_clip.SplitChroma(8).ConvertToRGB32()

return roll_left.Subtitle("Roll Left") + \
  roll_right.Subtitle("Roll Right") + \
  roll_up.Subtitle("Roll Up") + \
  roll_down.Subtitle("Roll Down") + \
  posterize_ex.Subtitle("Posterize") + \
  color_shift_example.Subtitle("Color Shift") + \
  chroma_shift_example.Subtitle("Chroma Shift")
