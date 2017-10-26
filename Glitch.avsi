#:
#: Functions that provide a sort of "glitched video" effect. These are intended
#: to be used in combination with mask overlays to selectively apply the effect
#: on the video. They include things like letting the video "roll".
#:

#: .. function:: RollHorizontal(c, amount)
#:
#:    :param clip c: the clip to roll
#:    :param int amount: how many pixels to "roll" - negative moves left,
#:      positive moves right (0 returns the original clip).
#:
#:    :return: a clip with the image shifted the given number of pixels
#:    :rtype: clip
#:
#:    "Rolls" a clip left or right the given number of pixels.
#:
#:    .. note::  YUV clips likely use chroma subsampling, meaning that moving
#:       them by an amount that isn't a multiple of the subsampling may cause
#:       some weird chroma blending. However it should still work as YUV clips
#:       are handled by ``Overlay``.
function RollHorizontal(clip c, int amount) {
	amount = amount % c.Width()
	return amount == 0 ? c : \
		((c.IsRGB() || c.IsYUY2()) ? Layer(Layer(c, c, x=amount), c, x=(amount > 0 ? amount - c.Width() : c.Width() + amount)) : \
			Overlay(Overlay(c, c, x=amount), c, x=(amount > 0 ? amount - c.Width() : c.Width() + amount)))
}

#: .. function:: RollSectionHorizontal(c, top, bottom, amount)
#:
#:    :param clip c: the clip to roll
#:    :param int top: top y coordinate (inclusive) to include
#:    :param int heightOrBottom: when positive, the height, when negative, the
#:      y coordinate from the bottom
#:    :param int amount: how many pixels to "roll" - negative moves left,
#:      positive moves right (0 returns the original clip).
#:
#:    Rolls only a certain section of the clip left or right. This works by
#:    overlaying only a certain portion of the clip over itself. As with
#:    :func:`RollHorizontal`, any ``amount`` should work with YUV clips, but
#:    choosing one that isn't a multiple of the chroma subsampling may introduce
#:    some blurriness.
#:
#:    .. warning:: When using this with YUV clips, ``top`` and
#:       ``heightOrBottom`` have to be valid crop values (they're sent to
#:       ``Crop`` as-is). For certain YUV formats, this means they must be a
#:       multiple of two.
function RollSectionHorizontal(clip c, int top, int heightOrBottom, int amount) {
	amount = amount % c.Width()
	c_over = ResetMask(c.Crop(0, top, c.Width(), heightOrBottom))
	return amount == 0 ? c : \
		((c.IsRGB() || c.IsYUY2()) ? \
			c.Layer(c_over, x=amount, y=top).Layer(c_over, x=(amount > 0 ? amount - c.Width() : c.Width() + amount), y=top) : \
			Overlay(Overlay(c, c_over, x=amount, y=top), c_over, x=(amount > 0 ? amount - c.Width() : c.Width() + amount), y=top))
}

#: .. function:: RollVertical(c, amount)
#:
#:    :param clip c: the clip to roll
#:    :param int amount: how many pixels to "roll" - negative moves up,
#:      positive moves down (0 returns the original clip). Note that YUV clips
#:      likely use chroma subsampling, meaning that moving them by an amount
#:      that isn't a multiple of the subsampling may cause some weird chroma
#:      blending. However it should still work as YUV clips are handled by
#:      ``Overlay``.
#:
#:    :return: a clip with the image shifted the given number of pixels
#:    :rtype: clip
#:
#:    "Rolls" a clip up or down the given number of pixels.
function RollVertical(clip c, int amount) {
	amount = amount % c.Height()
	return amount == 0 ? c : \
		((c.IsRGB() || c.IsYUY2()) ? \
			Layer(Layer(c, c, y=amount), c, y=(amount > 0 ? amount - c.Height() : c.Height() + amount)) : \
			Overlay(Overlay(c, c, y=amount), c, y=(amount > 0 ? amount - c.Height() : c.Height() + amount)))
}

#: .. function:: RollSectionVertical(c, top, bottom, amount)
#:
#:    :param clip c: the clip to roll
#:    :param int left: top y coordinate (inclusive) to include
#:    :param int widthOrRight: when positive, the width, when negative, the
#:      number of pixels from the right edge
#:    :param int amount: how many pixels to "roll" - negative moves up,
#:      positive moves down (0 returns the original clip).
#:
#:    Rolls only a certain section of the clip up or down. This works by
#:    overlaying only a certain portion of the clip over itself. As with
#:    :func:`RollVertical`, any ``amount`` should work with YUV clips, but
#:    choosing one that isn't a multiple of the chroma subsampling may introduce
#:    some blurriness.
#:
#:    .. warning:: When using this with YUV clips, ``left`` and
#:       ``widthOrRight`` have to be valid crop values (they're sent to
#:       ``Crop`` as-is). For certain YUV formats, this means they must be a
#:       multiple of two.
function RollSectionVertical(clip c, int left, int widthOrRight, int amount) {
	amount = amount % c.Height()
	c_over = ResetMask(c.Crop(left, 0, widthOrRight, c.Height()))
	return amount == 0 ? c : \
		((c.IsRGB() || c.IsYUY2()) ? \
			c.Layer(c_over, x=left, y=amount).Layer(c_over, x=left, y=(amount > 0 ? amount - c.Height() : c.Height() + amount)) : \
			Overlay(Overlay(c, c_over, x=left, y=amount), c_over, x = left, y=(amount > 0 ? amount - c.Height() : c.Height() + amount)))
}

#: .. function:: Roll(c, x, y)
#:
#:    :param clip c: the clip to roll
#:    :param int x: how many pixels to "roll" left or right
#:    :param int y: how many pixels to "roll" up or down
#:
#:    :return: a clip with the image shifted the given number of pixels
#:    :rtype: clip
#:
#:    "Rolls" a clip by the given number of pixels. This simply combines the
#:    effects of :func:`RollHorizontal` and :func:`RollVertical`.
function Roll(clip c, int x, int y) {
	return RollVertical(RollHorizontal(c, x), y)
}

#: .. function:: Posterize(c, red[, green[, blue]])
#:
#:    :param clip c: an RGB clip to posterize
#:    :param int red: the red level - how many "bits" of red should remain - 1
#:        means either 100% or 0%, 2 means 100%, 66%, 33%, 0%, etc.
#:    :param int green: if given, the green level, otherwise uses the same
#:        value red does
#:    :param int blue: if given, the blue level, otherwise uses the same
#:        value red does
#:
#:    :return: a clip with the image posterized
#:    :rtype: clip
#:
#:    Posterizes an RGB clip. (This only works on RGB clips because it doesn't
#:    really make sense in a YUV clip.) Values past 255 start introducing
#:    rounding effects, and 255 does effectively nothing but waste time.
function Posterize(clip c, int red, int "green", int "blue") {
	green = Default(green, red)
	blue = Default(blue, red)
	Assert(red > 0 && green > 0 && blue > 0, "Posterize cannot take negative numbers")
	red = 255.0 / red
	green = 255.0 / green
	blue = 255.0 / blue
	return c.RGBAdjust(r=1.0/red, g=1.0/green, b=1.0/blue). \
		RGBAdjust(r=Float(red), g=Float(green), b=Float(blue))
}

#: .. function:: SplitRGB(c, amount)
#:
#:    :param clip c: an RGB clip to split RGB channels in
#:    :param int amount: the amount to move the different channels by
#:
#:    :return: a clip with the RGB channels moved by the given number of pixels
#:    :rtype: clip
#:
#:    Splits RGB channels by amount. The green channel doesn't move, red is
#:    moved ``amount`` pixels left, and blue is moved ``amount`` pixels right.
#:    Amount may be negative, in which case red is moved right and blue is moved
#:    left.
#:
#:    This is simply::
#:
#:      amount == 0 ? c : MergeRGB(c.RollHorizontal(-amount), c, c.RollHorizontal(amount))
#:
#:    Similar code can be used to move RGB channels in other directions, but
#:    since the horizontal split is the most frequent "glitch" effect it's
#:    provided.
function SplitRGB(clip c, int amount) {
	return amount == 0 ? c : MergeRGB(c.RollHorizontal(-amount), c, c.RollHorizontal(amount))
}

#: .. function:: SplitChroma(c, amount)
#:
#:    :param clip c: a YUV clip to split chroma channels in
#:    :param int amount: the amount to move the different channels by - note
#:        that because this is moving the chroma planes, this is by pixels in
#:        in the chroma plane and *not* the luma plane. So in YV12, a value of
#:        1 will actually shift the planes 2 pixels apart.
#:
#:    :return: a clip with the chroma planes shifted
#:    :rtype: clip
#:
#:    Splits the UV channels by amount. Luma is not moved.
#:
#:    This is simply::
#:
#:      amount == 0 ? c : YToUV(c.UToY().RollHorizontal(-amount), c.VToY().RollHorizontal(amount), c)
#:
#:    Similar code can be used to move the chroma planes in other directions,
#:    but since the horizontal split is the most frequent "glitch" effect it's
#:    provided.
function SplitChroma(clip c, int amount) {
	return amount == 0 ? c : YToUV(c.UToY().RollHorizontal(-amount), c.VToY().RollHorizontal(amount), c)
}
