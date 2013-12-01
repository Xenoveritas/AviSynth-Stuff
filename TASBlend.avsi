# Implementation of the "TASBlend" filter, based on the filter described at
# http://tasvideos.org/EncodingGuide/TASBlend.html but with some additional
# comments and features.
#
# c       the clip to blend
# ratio   the ratio of the first frame compared to the second, defaults to
#         2/3rds.
function TASBlend(clip c, float "ratio") {
	ratio = Default(ratio, 2.0/3.0)

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
