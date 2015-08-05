#:
#: Functions for speeding up video while keeping the original pitch.
#: Optionally blend frames together.
#:

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