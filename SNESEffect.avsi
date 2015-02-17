#: .. data:: global SNESPixelEffectBlend = true
#:
#:   The default value for the blend argument. The default default is true.
global SNESPixelEffectBlend = true
#: .. data:: global SNESPixelEffectCenter = false
#:
#:   The default value for the center argument. The default default is false.
global SNESPixelEffectCenter = false

#: .. function:: SNESPixelEffect(c, size[, blend[, center]])
#:
#:    :param clip c: the clip to pixelate. Currently, this clip MUST be RGB.
#:        (This is due to chroma subsampling otherwise screwing up the effect on
#:        odd pixel sizes.)
#:    :param int size: the size of pixels (must be less than or equal to the
#:        smaller input clip dimension)
#:    :param bool blend: when ``true``, individual pixels are "blended" together
#:        to form a single large pixel. When false, a single pixel is chosen and
#:        expanded to be the larger pixel. (``false`` is more true to the SNES,
#:        ``true`` probably looks better.) The default is the value of the
#:        global ``SNESPixelEffectBlend``.
#:    :param bool center: when ``true``, "centers" the left-most pixel. This is
#:        probably a mis-feature and doesn't really work when "blend" is true,
#:        but whatever. Default is the value of the global
#:        ``SNESPixelEffectCenter``.
#:
#:    Do an SNES pixelation effect on the given clip.
function SNESPixelEffect(clip c, int size, bool "blend", bool "center") {
    Assert(size > 0, "Step must be greater than 0")
    Assert(size <= Min(c.Width(), c.Height()), \
        "Step may not be greater than the input smallest size (" + \
        String(c.Width()) + " x " + String(c.Height()) + \
        ", so size must be <= " + String(Min(c.Width(), c.Height())) + " )")
    # FIXME: Deal with non-RGB clips.
    Assert(IsRGB(c), "Input clip must be RGB")
    center = Default(center, SNESPixelEffectCenter)
    blend = Default(blend, SNESPixelEffectBlend)
    # Calculate new width/height (rounding up)
    w = (c.Width() - 1) / size + 1
    h = (c.Height() - 1) / size + 1
    # Scale the thing down
    small = blend ? c.BilinearResize(w, h) : c.PointResize(w, h)
    # Scale it back up
    large = small.PointResize(w * size, h * size)
    # And crop it to fit back in the originally desire dimensions
    return large.Crop(center ? (large.Width() - c.Width()) / 2 : 0, \
        center ? (large.Height() - c.Height()) / 2 : 0, \
        c.Width(), c.Height())
}

# Do a "pixel effect" into a clip.
#
# c - the clip to do the effect on. Currently, this clip MUST be RGB. (This is
#     due to chroma subsampling otherwise screwing up the effect on odd pixel
#     sizes.)
# size - the starting size of pixels (must be less than or equals to the smaller
#    input clip dimension)
# frames - the number of frames over which to do the effect; defaults to max
# blend - when true, individual pixels are "blended" together to form a single
#    large pixel. When false, a single pixel is chosen and expanded to be the
#    larger pixel. (False is more true to the SNES, true probably looks better.)
#    Default is the value of the global SNESPixelEffectBlend.
# center - when true, "centers" the left-most pixel. This is probably a
#    mis-feature and doesn't really work when "blend" is true, but whatever.
#    Default is the value of the global SNESPixelEffectCenter.
function SNESPixelIn(clip c, int "max", int "frames", bool "blend", bool "center") {
    max = Default(max, 32)
    frames = Default(frames, max)
    blend = Default(blend, SNESPixelEffectBlend)
    center = Default(center, SNESPixelEffectCenter)
    effect = Animate(c, 0, frames, "SNESPixelEffect", max,blend,center, 1,blend,center)
    return effect.Trim(0, frames-1) + c.Trim(frames, 0)
}

# Do a "pixel effect" out of a clip.
#
# c - the clip to do the effect on. Currently, this clip MUST be RGB. (This is
#     due to chroma subsampling otherwise screwing up the effect on odd pixel
#     sizes.)
# size - the starting size of pixels (must be less than or equals to the smaller
#    input clip dimension)
# frames - the number of frames over which to do the effect; defaults to max
# blend - when true, individual pixels are "blended" together to form a single
#    large pixel. When false, a single pixel is chosen and expanded to be the
#    larger pixel. (False is more true to the SNES, true probably looks better.)
#    Default is the value of the global SNESPixelEffectBlend.
# center - when true, "centers" the left-most pixel. This is probably a
#    mis-feature and doesn't really work when "blend" is true, but whatever.
#    Default is the value of the global SNESPixelEffectCenter.
function SNESPixelOut(clip c, int "max", int "frames", bool "blend", bool "center") {
    max = Default(max, 32)
    frames = Default(frames, max)
    blend = Default(blend, SNESPixelEffectBlend)
    center = Default(center, SNESPixelEffectCenter)
    effect = Animate(c.Trim(c.FrameCount() - frames - 1, 0), 0, frames-1, \
        "SNESPixelEffect", 1,blend,center, max,blend,center)
    return c.Trim(0, c.FrameCount() - frames - 2) + effect
}

# Do a "pixel effect" into and out of a clip. This is the same as calling
# SNESPixelIn(SNESPixelOut(c, max, frames, blend), max, frames, blend).
#
# c - the clip to do the effect on. Currently, this clip MUST be RGB. (This is
#     due to chroma subsampling otherwise screwing up the effect on odd pixel
#     sizes.)
# size - the starting size of pixels (must be less than or equals to the smaller
#    input clip dimension)
# frames - the number of frames over which to do the effect; defaults to max
# blend - when true, individual pixels are "blended" together to form a single
#    large pixel. When false, a single pixel is chosen and expanded to be the
#    larger pixel. (False is more true to the SNES, true probably looks better.)
#    Default is the value of the global SNESPixelEffectBlend.
# center - when true, "centers" the left-most pixel. This is probably a
#    mis-feature and doesn't really work when "blend" is true, but whatever.
#    Default is the value of the global SNESPixelEffectCenter.
function SNESPixelIO(clip c, int "max", int "frames", bool "blend", bool "center") {
    max = Default(max, 32)
    frames = Default(frames, max)
    blend = Default(blend, SNESPixelEffectBlend)
    center = Default(center, SNESPixelEffectCenter)
    return SNESPixelOut(SNESPixelIn(c, max, frames, blend, center), max, frames, blend, center)
}
