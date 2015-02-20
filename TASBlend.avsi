#: Implementation of the "TASBlend" filter, based on the filter described at
#: http://tasvideos.org/EncodingGuide/TASBlend.html but with some additional
#: comments and features.
#:
#: .. function:: TASBlend(c, ratio=0.6666, assertEven=False)
#:
#:    :param clip c: the clip to blend
#:    :param float ratio: the ratio of the first frame compared to the second,
#:        defaults to 2/3rds.
#:    :param bool assertEven: when ``true``, check to make sure there are an
#:        even number of frames. This is necessary if you want to make sure that
#:        you're not potentially desyncing by a single frame if you're combining
#:        a blended clip with an unblended clip.
#:
#:    The resulting clip will be "TAS blended" together and therefore be at exactly
#:    half the input framerate.
#:
function TASBlend(clip c, float "ratio", bool "assertEven") {
	ratio = Default(ratio, 2.0/3.0)
	Assert((!Default(assertEven, False)) || c.FrameCount() % 2 == 0, "Frame count " + String(c.FrameCount()) + " is not even, either set assertEven=false or trim frames. (Otherwise you risk a single frame desync.)")

	# Max depends on source color type (which is potentially not RGB if coming
	# from an actual console source)
	level = Floor(c.IsYUY2() ? 256 : 257 * ratio)

	# Now create our two blends, on that's frames (0,1), (4,5), (8,9), ...
	# blended together with the first frame being the given ratio:
	c_2_1 = Layer(SelectEvery(c, 4, 0), SelectEvery(c, 4, 1), op="add", level=level)
	# And the second that's frames (3,2), (7,6), (11,10), ... blended together
	# in the opposite order.
	c_1_2 = Layer(SelectEvery(c, 4, 3), SelectEvery(c, 4, 2), op="add", level=level)

	# Now interleve the two together, so the final result are the blended frames
	# (0,1), (3,2), (4,5), (7,6), ...
	blended = Interleave(c_2_1, c_1_2)

	# And just to make sure everything makes sense, audio dub the original
	# audio back onto the resulting clip (shouldn't be necessary, but I'm
	# paranoid).
	return AudioDub(blended, c)
}
