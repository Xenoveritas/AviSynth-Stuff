#:
#: Functions for speeding up video while keeping the original pitch.
#: Optionally blend frames together.
#:

#: .. function:: IncreaseSpeed(c)
#:
#:    :param clip c: the clip to speed up
#:    :param int amount: integer amount to speed up by - 2 doubles the speed,
#:      3 triples it
#:
#:    Accelerates a clip to a quarter its original speed while maintaining the
#:    original audio pitch. Note that because this uses strictly integer amounts
#:    it can't blend the frames together in the same way Speed2X and Speed4X do.
#:    If you want frame blending, you'll need to use those two.
function IncreaseSpeed(clip c, int amount) {
	Assert(amount > 0, "Invalid speed increase " + String(amount) + ": amount must be 1 or more")
	# Don't bother doing anything if the increase is 1.
	return amount == 1 ? c : AudioDub( \
		c.AssumeFPS(c.FrameRate()*amount).ChangeFPS(c.FrameRateNumerator(), c.FrameRateDenominator()), \
		TimeStretch(c, tempo=100.0*amount))
}

#: .. function:: ReduceSpeed(c)
#:
#:    :param clip c: the clip to speed down
#:    :param int amount: integer amount to slow down by - 2 is half as fast, 3
#:      is a third as fast, and so on
#:
#:    Decelerates a clip to a quarter its original speed while maintaining the
#:    original audio pitch.
function ReduceSpeed(clip c, int amount) {
	Assert(amount > 0, "Invalid speed decrease " + String(amount) + ": amount must be 1 or more")
	# Don't bother doing anything if the reduction is 1.
	return amount == 1 ? c : AudioDub( \
		c.AssumeFPS(c.FrameRate()/amount).ChangeFPS(c.FrameRateNumerator(), c.FrameRateDenominator()), \
		TimeStretch(c, tempo=100.0/amount))
}

function Speed_copyFPS(clip modified, clip original) {
	return AssumeFPS(modified, original.FrameRateNumerator(), original.FrameRateDenominator())
}

function Speed2X_blend(clip c) {
	return Layer(SelectEven(c), SelectOdd(c), "fast")
}

#: .. function:: Speed2X(c, blend=true)
#:
#:    :param clip c: the clip to speed up
#:    :param bool blend: ``true`` to blend frames, ``false`` to simply skip frames
#:
#:    Accelerates a clip to 2x its original speed while maintaining the original
#:    audio pitch.
function Speed2X(clip c, bool "blend") {
	blend = Default(blend, true)
	return AudioDub( \
		Speed_copyFPS(blend ? Speed2X_blend(c) : SelectEven(c), c), \
		TimeStretch(c, tempo=200))
}

#: .. function:: Speed4X(c, blend=true)
#:
#:    :param clip c: the clip to speed up
#:    :param bool blend: ``true`` to blend frames, ``false`` to simply skip frames
#:
#:    Accelerates a clip to 4x its original speed while maintaining the original
#:    audio pitch.
function Speed4X(clip c, bool "blend") {
	blend = Default(blend, true)
	return AudioDub( \
		Speed_copyFPS(blend ? Speed2X_blend(Speed2X_blend(c)) : SelectEven(c), c), \
		TimeStretch(c, tempo=400))
}

#: .. function:: ReduceSpeed2X(c)
#:
#:    :param clip c: the clip to speed down
#:
#:    Decelerates a clip to half its original speed while maintaining the
#:    original audio pitch.
function ReduceSpeed2X(clip c) {
	return AudioDub( \
		c.AssumeFPS(c.FrameRate()/2).ChangeFPS(c.FrameRateNumerator(), c.FrameRateDenominator()), \
		TimeStretch(c, tempo=50))
}

#: .. function:: ReduceSpeed4X(c)
#:
#:    :param clip c: the clip to speed down
#:
#:    Decelerates a clip to a quarter its original speed while maintaining the
#:    original audio pitch.
function ReduceSpeed4X(clip c) {
	return AudioDub( \
		c.AssumeFPS(c.FrameRate()/4).ChangeFPS(c.FrameRateNumerator(), c.FrameRateDenominator()), \
		TimeStretch(c, tempo=25))
}
