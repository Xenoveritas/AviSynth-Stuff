Import("..\Utilities.avsi")
Import("..\Easings.avsi")

total_time = 30*10

clip_a = ImageSource("foggy.jpg", start=0, end=total_time, fps=30, pixel_type="RGB32")
clip_b = ImageSource("shoreline.jpg", start=0, end=total_time, fps=30, pixel_type="RGB32")

clip_b = clip_b.BilinearResize(clip_b.Width()/2, clip_b.Height()/2).ShowFrameNumber()

# Do a little PIP effect
clip_a.LayerFadeIO(clip_b, 30, total_time-30, 30, 60, clip_a.Width()/2-4, 4, easing="EasingSine", end_easing="EaseInOutBounce")
