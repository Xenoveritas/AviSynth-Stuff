#:
#: Functions for speeding up video while keeping the original pitch.
#: Optionally blend frames together.
#:

#: .. function:: IncreaseSpeed(c, amount, blend=false)
#:
#:    :param clip c: the clip to speed up
#:    :param int amount: integer amount to speed up by - 2 doubles the speed,
#:      3 triples it
#:    :param bool blend: whether or not to blend frames, defaults to false
#:
#:    Accelerates a clip to a quarter its original speed while maintaining the
#:    original audio pitch.
function IncreaseSpeed(clip c, int amount, bool "blend") {
	Assert(amount > 0, "Invalid speed increase " + String(amount) + ": amount must be 1 or more")
	blend = Default(blend, false)
	# Don't bother doing anything if the increase is 1.
	fast = amount == 1 ? c : \
		blend ? Speed_blend(c, amount) : c.SelectEvery(amount)
	fast = fast.AssumeFPS(c.FrameRateNumerator(), c.FrameRateDenominator())
	return c.HasAudio() ? AudioDub(fast, TimeStretch(c, tempo=100.0*amount)) : fast
}

#: .. function:: ReduceSpeed(c, amount)
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
# Entrance into the blending recursion function. This generates a filter graph
# designed to blend frames together in order, blending frames together as
# evenly and quickly as possible for any given input number.
#
# It does this by dividing each input in half, so that there's a "left side"
# and a "right side". The left side rounds down, the right side rounds up. If
# there's only one frame for a given side, it's blended as-is. If there are
# more, the function recurses, repeating the operation for each side.
#
# Ultimately the results of the left and right sides are blended together
# taking into account how many frames were on each side. If they were even, the
# "fast" blend is used. Otherwise, an alpha blend is used that takes into
# account how many frames were on each side.
#
# For example, for 3, this effectively generates:
#
# Layer(
#  Layer(c.SelectEvery(3, 0), c.SelectEvery(3, 1), "fast"),
#  c.SelectEvery(3, 2),
#  "add", (257 / 3)
# )
#
function Speed_blend(clip c, int frames) {
	Assert(frames > 1, "Blending together " + String(frames) + " frame makes no sense")
	return Speed_blend_recurse(c, frames, 0, frames, c.IsRGB() ? 257.0 : 256.0)
}

#
# Actual recursive function for doing the blending.
#
function Speed_blend_recurse(clip c, int total, int offset, int length, float max_level) {
	# Sanity asserts:
	Assert(offset >= 0, "Offset is negative (?)")
	Assert(offset < total, "Offset " + String(offset) + " is greater than total frames " + String(total))
	Assert(length > 1, "Length " + String(length) + " is too small")
	Assert(offset + length <= total, "Offset " + String(offset) + " and length " + String(length) + " is greater than total " + String(total))
	# How this works: We split into a left and right side. If the number of
	# frames on the left/right side is 1, we use it directly. Otherwise, we
	# recurse into that side. The final filter graph will end up being sequential
	# because it'll recurse down the left side until frame 0 is selected, then
	# that will blend with frame 1 on it's first left side, and so forth.
	left_frames = length / 2
	right_frames = length - left_frames
	left = left_frames == 1 ? \
		c.SelectEvery(total, offset) : \
		Speed_blend_recurse(c, total, offset, left_frames, max_level)
	right = right_frames == 1 ? \
		c.SelectEvery(total, offset + left_frames) : \
		Speed_blend_recurse(c, total, offset + left_frames, right_frames, max_level)
	# And blend: if the two sides are equal, just use fast. Otherwise, pick a
	# level remembering that 0 = left, max_level = right.
	return left_frames == right_frames ? \
		Layer(left, right, "fast") : \
		Layer(left, right, "add", Round(max_level * Float(right_frames) / length))
}

#: .. function:: Speed2X(c, blend=true)
#:
#:    :param clip c: the clip to speed up
#:    :param bool blend: ``true`` to blend frames, ``false`` to simply skip frames
#:
#:    Accelerates a clip to 2x its original speed while maintaining the original
#:    audio pitch. Identical to ``IncreaseSpeed(c, 2, blend)``.
function Speed2X(clip c, bool "blend") {
	return IncreaseSpeed(c, 2, Default(blend, true))
}

#: .. function:: Speed4X(c, blend=true)
#:
#:    :param clip c: the clip to speed up
#:    :param bool blend: ``true`` to blend frames, ``false`` to simply skip frames
#:
#:    Accelerates a clip to 4x its original speed while maintaining the original
#:    audio pitch. Identical to ``IncreaseSpeed(c, 4, blend)``.
function Speed4X(clip c, bool "blend") {
	return IncreaseSpeed(c, 4, Default(blend, true))
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
