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
	fast = amount == 1 ? c : \
		c.AssumeFPS(c.FrameRate()*amount).ChangeFPS(c.FrameRateNumerator(), c.FrameRateDenominator())
	return c.HasAudio() ? AudioDub(fast, TimeStretch(c, tempo=100.0*amount)) : fast
}

#: .. function:: ReduceSpeed(c)
#:
#:    :param clip c: the clip to speed down
#:    :param int amount: integer amount to slow down by - 2 is half as fast, 3
#:      is a third as fast, and so on
#:
#:    Decelerates a clip to a quarter its original speed while maintaining the
#:    original audio pitch. (If the input clip has no audio, the resulting clip
#:    will also have no audio.)
function ReduceSpeed(clip c, int amount) {
	Assert(amount > 0, "Invalid speed decrease " + String(amount) + ": amount must be 1 or more")
	# Don't bother doing anything if the reduction is 1.
	slow = amount == 1 ? c : c.AssumeFPS(c.FrameRate()/amount).ChangeFPS(c.FrameRateNumerator(), c.FrameRateDenominator())
	return c.HasAudio() ?	AudioDub(slow, TimeStretch(c, tempo=100.0/amount)) : slow
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
	fast = Speed_copyFPS(blend ? Speed2X_blend(c) : SelectEven(c), c)
	return c.HasAudio() ? AudioDub(fast, TimeStretch(c, tempo=200)) : fast
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
	fast = Speed_copyFPS(blend ? Speed2X_blend(Speed2X_blend(c)) : SelectEvery(c,4,0), c)
	return c.HasAudio() ? AudioDub(fast, TimeStretch(c, tempo=400)) : fast
}

#: .. function:: ReduceSpeed2X(c)
#:
#:    :param clip c: the clip to speed down
#:
#:    Decelerates a clip to half its original speed while maintaining the
#:    original audio pitch. Identical to ``ReduceSpeed(c, 2)``, but provided to
#:    mirror ``Speed2X()``.
function ReduceSpeed2X(clip c) {
	return ReduceSpeed(c, 2)
}

#: .. function:: ReduceSpeed4X(c)
#:
#:    :param clip c: the clip to speed down
#:
#:    Decelerates a clip to a quarter its original speed while maintaining the
#:    original audio pitch. Identical to ``ReduceSpeed(c, 4)``, but provided to
#:    mirror ``Speed4X()``.
function ReduceSpeed4X(clip c) {
	return ReduceSpeed(c, 4)
}
