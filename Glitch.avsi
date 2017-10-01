#:
#: Functions that provide a sort of "glitched video" effect. These are intended
#: to be used in combination with mask overlays to selectively apply the effect
#: on the video. They include things like letting the video "roll".
#:

#: .. function:: RollHorizontal(c, amount)
#:
#:    :param clip c: the clip to roll
#:    :param int amount: how many pixels to "roll" - negative moves left,
#:      positive moves right (0 returns the original clip). Note that YUV clips
#:      can usually only be moved by multiples of two.
#:
#:    "Rolls" a clip left or right the given number of pixels.
function RollHorizontal(clip c, int amount) {
	amount = amount % c.Width()
	left = amount == 0 ? c : (amount < 0 ? c.Crop(0-amount, 0, c.Width() + amount, 0) : \
		c.Crop(c.Width() - amount, 0, amount, 0))
	right = amount == 0 ? c : (amount < 0 ? c.Crop(0, 0, -amount, 0) : \
		c.Crop(0, 0, c.Width() - amount, 0))
	return amount == 0 ? c : \
		((c.IsRGB() || c.IsYUY2()) ? Layer(Layer(c, c, x=amount), c, x=(amount > 0 ? amount -c.Width() : c.Width() + amount)) : \
			Overlay(Overlay(c, c, x=amount), c, x=(amount > 0 ? amount -c.Width() : c.Width() + amount)))
}

#: .. function:: RollVertical(c, amount)
#:
#:    :param clip c: the clip to roll
#:    :param int amount: how many pixels to "roll" - negative moves up,
#:      positive moves down (0 returns the original clip). Note that YUV clips
#:      can usually only be moved by multiples of two.
#:
#:    "Rolls" a clip up or down the given number of pixels.
function RollVertical(clip c, int amount) {
	amount = amount % c.Height()
	return amount == 0 ? c : \
		((c.IsRGB() || c.IsYUY2()) ? Layer(Layer(c, c, y=amount), c, y=(amount > 0 ? amount -c.Height() : c.Height() + amount)) : \
			Overlay(Overlay(c, c, y=amount), c, y=(amount > 0 ? amount -c.Height() : c.Height() + amount)))
}

#: .. function:: Roll(c, x, y)
#:
#:    :param clip c: the clip to roll
#:    :param int x: how many pixels to "roll" left or right
#:    :param int y: how many pixels to "roll" up or down
#:
#:    "Rolls" a clip by the given number of pixels. This simply combines the
#:    effects of
function Roll(clip c, int x, int y) {
	return RollVertical(RollHorizontal(c, x), y)
}

#: .. function:: Posterize(c, red[, green[, blue]])
#:
#:    :param clip c: the clip to posterize
#:    :param int red: the red level - how many "bits" of red should remain - 1
#:        means either 100% or 0%, 2 means 100%, 66%, 33%, 0%, etc.
#:    :param int green: if given, the green level, otherwise uses the same
#:        value red does
#:    :param int blue: if given, the blue level, otherwise uses the same
#:        value red does
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
#:    :param clip c: the clip to split RGB channels in
#:    :param int amount: the amount to move the different channels by
#:
#:    Splits RGB channels by amount. The green channel doesn't move, red is
#:    moved ``amount`` pixels left, and blue is moved ``amount`` pixels right.
#:    Amount may be negative, in which case red is moved right and blue is moved
#:    left.
function SplitRGB(clip c, int amount) {
	return amount == 0 ? c : MergeRGB(c.RollHorizontal(-amount), c, c.RollHorizontal(amount))
}

#: .. function:: SplitChroma(c, amount)
#:
#:    :param clip c: the clip to split chroma channels in
#:    :param int amount: the amount to move the different channels by
#:
#:    Splits the UV channels by amount. Luma is not moved.
function SplitChroma(clip c, int amount) {
	return amount == 0 ? c : YToUV(c.UToY().RollHorizontal(-amount), c.VToY().RollHorizontal(amount), c)
}
