#
# The "meat" of the effect
#
function SNESPixelEffect(clip c, int step, bool "blend", bool "center") {
    Assert(step > 0, "Step must be greater than 0")
    Assert(step <= Min(c.Width(), c.Height()), \
        "Step may not be greater than the input smallest size (" + \
        String(c.Width()) + " x " + String(c.Height()) + \
        ", so step must be <= " + String(Min(c.Width(), c.Height())) + " )")
    # FIXME: Deal with non-RGB clips.
    Assert(IsRGB(c), "Input clip must be RGB")
    center = Default(center, false)
    blend = Default(blend, false)
    # Calculate new width/height (rounding up)
    w = (c.Width() - 1) / step + 1
    h = (c.Height() - 1) / step + 1
    # Scale the thing down
    small = blend ? c.BilinearResize(w, h) : c.PointResize(w, h)
    # Scale it back up
    large = small.PointResize(w * step, h * step)
    # And crop it to fit back in the originally desire dimensions
    return large.Crop(center ? (large.Width() - c.Width()) / 2 : 0, \
        center ? (large.Height() - c.Height()) / 2 : 0, \
        c.Width(), c.Height())
}

# Do a "pixel effect" into a clip.
#
# c - the clip
# max - the max "zoom" level, defaults to 32
# frames - the number of frames over which to do the effect, defaults to max
# blend - when true, "blend" the lower-level pixels together, effectively
#   blurring over each large pixel. When false, picks a single pixel instead of
#   blurring multiple lower-level pixels together.
# center - when true, "center" the results so that the pixel appears in the
#   middle; when false, keep it in the left-most corner.
function SNESPixelIn(clip c, int "max", int "frames", bool "blend", bool "center") {
    max = Default(max, 32)
    frames = Default(frames, max)
    blend = Default(blend, false)
    center = Default(center, false)
    effect = Animate(c, 0, frames, "SNESPixelEffect", max,blend,center, 1,blend,center)
    return effect.Trim(0, frames-1) + c.Trim(frames, 0)
}

# Do a "pixel effect" out of a clip.
#
# c - the clip
# max - the max "zoom" level, defaults to 32
# frames - the number of frames over which to do the effect, defaults to max
# blend - when true, "blend" the lower-level pixels together, effectively
#   blurring over each large pixel. When false, picks a single pixel instead of
#   blurring multiple lower-level pixels together.
# center - when true, "center" the results so that the pixel appears in the
#   middle; when false, keep it in the left-most corner.
function SNESPixelOut(clip c, int "max", int "frames", bool "blend", bool "center") {
    max = Default(max, 32)
    frames = Default(frames, max)
    blend = Default(blend, false)
    center = Default(center, false)
    effect = Animate(c.Trim(c.FrameCount() - frames - 1, 0), 0, frames-1, \
        "SNESPixelEffect", 1,blend,center, max,blend,center)
    return c.Trim(0, c.FrameCount() - frames - 2) + effect
}

# Do a "pixel effect" into and out of a clip. This is the same as calling
# SNESPixelIn(SNESPixelOut(c, max, frames, blend), max, frames, blend).
#
# c - the clip
# max - the max "zoom" level, defaults to 32
# frames - the number of frames over which to do the effect, defaults to max
# blend - when true, "blend" the lower-level pixels together, effectively
#   blurring over each large pixel. When false, picks a single pixel instead of
#   blurring multiple lower-level pixels together.
# center - when true, "center" the results so that the pixel appears in the
#   middle; when false, keep it in the left-most corner.
function SNESPixelIO(clip c, int "max", int "frames", bool "blend", bool "center") {
    max = Default(max, 32)
    frames = Default(frames, max)
    blend = Default(blend, false)
    center = Default(center, false)
    return SNESPixelOut(SNESPixelIn(c, max, frames, blend, center), max, frames, blend, center)
}
