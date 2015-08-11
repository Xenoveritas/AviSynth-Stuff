#: Effects that attempt to mimic VCR distortions.

#: .. function:: VCRTweak(c, amount)
#:
#:    :param clip c: the clip to do the effect on
#:    :param float amount: a number between 0 and 1.0 that indicates "how much"
#:      of the effect should be applied.
#:
#:    Applies a VCR "tweak" effect, desaturating and brightening the image.
function VCRTweak(clip c, float amount) {
	Assert(amount >= 0.0 && amount <= 1.0, "Amount " + String(amount) + " out of range [0.0-1.0].")
	return amount == 0.0 ? c : c.Layer(c.Levels(0, 1.0, 255, 64, 255).Greyscale(), "add", level=Round(amount*256))
}

#: .. function:: VCREffect_WrapLine(c, y, shift_x)
#:
#:    :param clip c: the clip to do the effect on
#:    :param int y: the y coordinate shift a line on
#:    :param int shift_x: the (currently positive only) number of pixels to
#:      shift the given line by
#:    :param float vcr_tweak: a value to give to ``VCRTweak`` to alter the given
#:      line. Defaults to 0.0 (does nothing).
#:
#:    Wraps a given line around by the given ``shift_x`` amount.
function VCREffect_WrapLine(clip c, int y, int shift_x, float "vcr_tweak") {
	Assert(shift_x >= 0, "Currently only supports amounts >= 0, sorry")
	# Fairly simple: push the given line by the given number of pixels.
	# Note: this will likely only work on RGB inputs.
	vcr_tweak = Default(vcr_tweak, 0.0)
	return shift_x == 0 ? c : \
		c.Layer(c.Crop(0, y, c.Width()-shift_x, 1).VCRTweak(vcr_tweak), x=shift_x, y=y) \
			.Layer(c.Crop(c.Width()-shift_x, y, shift_x, 1).VCRTweak(vcr_tweak), x=0, y=y)
}

#: .. function:: VCREffect_Loop(c, y, amount, decay)
#:
#:    :param clip c: the clip to do the effect on
#:    :param int y: the y coordinate to start the effect on
#:    :param float amount: floating point number indicating number of pixels to
#:      shift by
#:    :param float max_amount: the initial amount value, used to compute a value for
#:      ``vcr_tweak`` in the ``VCREffect_WrapLine`` call.
#:    :param float decay: the decay amount - the "header" will shift down by
#:      this percentage each line. Closer to 1.0 makes it much taller, closer
#:      to 0.0 makes it shorter.
#:
#:    Implementation of ``VCREffect``, this deals with looping (via recursion)
#:    to create all the necessary layers to generate the effect.
function VCREffect_Loop(clip c, int y, float amount, float max_amount, float decay) {
	c = c.VCREffect_WrapLine(y, Round(amount), amount / max_amount)
	amount = amount * decay
	return amount > 0.5 ? c.VCREffect_Loop(y+1, amount, max_amount, decay) : c
}

#: .. function:: VCREffect(c, y, start[, decay])
#:
#:    :param clip c: the clip to do the effect on
#:    :param int y: the y coordinate to start the effect on
#:    :param int amount: the starting number of pixels to shift the header by
#:    :param float decay: the decay amount - the "header" will shift down by
#:      this percentage each line. Closer to 1.0 makes it much taller, closer
#:      to 0.0 makes it shorter.
#:
#:    Do a simple VCR effect. Note that this effect currently require an RGB32
#:    input clip because you can't adjust by a single pixel on YUV clips.
function VCREffect(clip c, int y, int amount, float "decay") {
	decay = Default(decay, 0.825)
	Assert(decay > 0.0, "Decay must be a positive number")
	Assert(decay < 1.0, "Decay must be less than 1, otherwise you create an infinite loop!")
	return c.VCREffect_Loop(y, amount, amount, decay)
}

#: .. function:: VCRFastForward(clip c, int speed[, float decay])
#:
#:    :param clip c: the clip to speed up
#:    :param int speed: the number of times faster to make the video (so 2 is
#:      twice as fast, 3 is three times, etc.)
#:    :param float decay: the decay amount for the bars, given to ``VCREffect``
#:
#:    Speeds up the given clip, increasing the pitch of the underlying sound
#:    while doing it. (If you don't want to do that, see ``Speed.avsi`` for
#:    functions that speed up a clip without altering pitch.)
#:
#:    This applies several different effects to make it look like the effect is
#:    being done by a VCR. (Which translates to it being very slow because it's
#:    creating a stupidly complicated filter-chain in order to achieve the
#:    effect.)
function VCRFastForward(clip c, int speed, float "decay") {
	Assert(speed > 1, "Speed must be greater than 1 (otherwise you're not fast forwarding)")
	# First up, increase the speed of the underlying clip.
	# TODO: Really this should blend frames. It's called "VCR effect", distortions
	# are to be expected.
	c = c.AssumeFPS(c.FrameRate()*speed).ChangeFPS(c)
	c = c.AssumeSampleRate(c.AudioRate() * speed).ResampleAudio(c.AudioRate())
	# Start the band at 1/8th the image Width
	amount = c.Width() / 8
	decay = Default(decay, 0.825)
	# Add four bands
	increment = c.Height() / 4
	y = increment / 2
	c = c.VCREffect(y, amount, decay)
	y = y + increment
	c = c.VCREffect(y, amount, decay)
	y = y + increment
	c = c.VCREffect(y, amount, decay)
	y = y + increment
	c = c.VCREffect(y, amount, decay)
	return c
}

#: .. function:: VCRFastForwardRange(clip c, int start, int end, int speed[, float decay])
#:
#:    :param clip c: the clip to speed up
#:    :param int start: the first frame to speed up (inclusive)
#:    :param int end: the last frame to speed up (inclusive)
#:    :param int speed: the number of times faster to make the video (so 2 is
#:      twice as fast, 3 is three times, etc.)
#:    :param float decay: the decay amount for the bars, given to ``VCREffect``
#:
#:    Speeds up the range of a given section of a video, increasing the pitch of
#:    the underlying sound while doing it. (If you don't want to do that, see
#:    ``Speed.avsi`` for functions that speed up a clip without altering pitch.)
#:
#:    This applies several different effects to make it look like the effect is
#:    being done by a VCR. (Which translates to it being very slow because it's
#:    creating a stupidly complicated filter-chain in order to achieve the
#:    effect.)
function VCRFastForwardRange(clip c, int start, int end, int speed, float "decay") {
	# Currently starting and ending at the end are "degenerate" and don't work.
	Assert(start < end, "Start frame (" + String(start) + ") must be less than end frame (" + String(end) + ")")
	result = c.Trim(start, end).VCRFastForward(speed, decay)
	result = start > 0 ? c.Trim(0, start-1) + result : result
	result = end < c.FrameCount() ? result + c.Trim(end+1, 0) : result
	return result
}
