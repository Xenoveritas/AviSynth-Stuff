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
function IncreaseSpeed(clip c, int amount, bool "blend") {
	Assert(amount > 0, "Invalid speed increase " + String(amount) + ": amount must be 1 or more")
	blend = Default(blend, false)
	# Don't bother doing anything if the increase is 1.
	fast = amount == 1 ? c : \
		blend ? Speed_blend(c, amount) : c.SelectEvery(amount)
	fast = fast.AssumeFPS(c.FrameRateNumerator(), c.FrameRateDenominator())
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

#
# This function is "special" and is used to try and "trick" AviSynth into
# blending frames "in sequence." At about 8X the frame cache stops being our
# friend and just blending frames starts causing stupid seeking.
#
# AviSynth doesn't support the concept of loops, so this ends up being
# recursive to make up for that.
#
function Speed_blend(clip c, int frames) {
	Assert(frames > 2, "Blending together 1 frame makes no sense")
	# TODO: Even if we're not given an exact power of two, we can use the largest
	# power of two on the left and then keep iterating until we get down to 2, 1
	# in the worst case. This will reduce the math errors. But for now:
	return Frac(Sqrt(frames)) == 0.0 ? \
		Speed_blend_pow2(c, frames, 0, frames).Subtitle("powerof2") : \
		Speed_blend_loop(c, c.SelectEvery(frames, 0), 1, frames, c.IsRGB() ? 257.0 : 256.0)
}

#
# A "special case" - blend together frames that happen to be a power of two.
# This works by blending frames 0,1 together, then 2,3, then the combintation,
# and so on.
#
# It only works "cleanly" on a power of two and assumes that it was given a
# power of 2 to start.
#
# Each iteration splits into half, recursing through each half, creating a
# filter graph that looks like:
#
# Layer(
#  Layer(
#   SelectEvery(4, 0),
#   SelectEvery(4, 1), "fast"
#  ),
#  Layer(
#   SelectEvery(4, 2),
#   SelectEvery(4, 3), "fast"
#  ),
#  "fast"
# )
#
# The idea being that it ends up requesting frames sequentially to build the
# "final" frame, while needing to keep as few frames in memory as possible.
#
function Speed_blend_pow2(clip c, int total, int offset, int split) {
	# Due to AviSynth's horrible syntax this looks terrible, but basically:
	# if (split == 2) {
	#    left = c.SelectEvery(total, offset);
	#    right = c.SelectEvery(total, offset+1);
	# } else {
	#    split = split / 2;
	#    left = c.Speed_blend_pow2(total, offset, split);
	#    right = c.Speed_blend_pow2(total, offset + split, split);
	# }
	split = split / 2
	left = (split == 1) ? \
		c.SelectEvery(total, offset) : \
		c.Speed_blend_pow2(total, offset, split)
	right = (split == 1) ? \
		c.SelectEvery(total, offset + 1) : \
		c.Speed_blend_pow2(total, offset + split, split)
	return Layer(left, right, "fast")
}

function Speed_blend_loop(clip c, clip previous_frame, int frame, int total_frames, float max_level) {
	# The level we want to blend is 1 / (frame+1) - so the first frame is "given",
	# the second frame is then layered at half that, the third frame then adds
	# 1/3rd, and so forth. It adds up so that by the end the "real" influence is
	# the number of frames, AND we can go through sequentially without seeking.
	level = Floor(max_level * (1 / Float(frame+1)))
	result = previous_frame.Layer(c.SelectEvery(total_frames, frame), "add", level)
	# The actual "loop" is done via recursion here:
	return frame + 1 < total_frames ? \
		Speed_blend_loop(c, result, frame + 1, total_frames, max_level) : \
		result
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
