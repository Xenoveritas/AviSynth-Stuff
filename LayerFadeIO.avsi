#
# Fade a layer on top of another layer.
#
# back        the clip to fade on top of
# over        the clip being faded on top of back
# start       the frame to start fading in on
# end         the frame to have finished fading in on
# start_time  the number of frames to fade in over
# end_time    the number of frames to fade out, defaults to start_time
# x, y        coordinates to place the upper layer on, defaults to 0,0
function LayerFadeIO(clip back, clip over, int start, int end, int start_time, int "end_time", int "x", int "y") {
	end_time = Default(end_time, start_time)
	x = Default(x, 0)
	y = Default(y, 0)
	Assert(start < end, "Cannot start before end")
	Assert(start < back.FrameCount(), "Start time (" + String(start) + ") is after clip ends (" + String(back.FrameCount()-1) + ")")
	Assert(end < back.FrameCount(), "End time (" + String(end) + ") is after clip ends (" + String(back.FrameCount()-1) + ")")
	Assert(end - start_time > start, "End time does not give enough time for the clip to fade in")
	part_1 = Trim(back, start, start + start_time)
	after = Trim(back, start + start_time + 1, 0)
	before = Animate(part_1, 0, start_time, "Layer", \
		over,"add",0,x,y, over,"add",257,x,y)
	# If start is 0, we need to skip the before bit entirely
	before = start > 0 ? Trim(back, 0, start - 1) + before : before
	# Convert end to after time
	end = end - before.FrameCount()
	over = Trim(over, start_time + 1, 0)
	after = Animate(after, end, end + end_time-1, "Layer", \
		over,"add",257,x,y, over,"add",0,x,y)
	res = before + after
	Assert(back.FrameCount() == res.FrameCount(), "Wanted " + string(back.FrameCount()) + ", have " + String(res.FrameCount()) + ", before is " + String(before.FrameCount()) + " frames, after is " + String(after.FrameCount()) + ", combined is " + String(before.FrameCount() + after.FrameCount()))
	return res
}
