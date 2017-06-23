#: Miscellaneous utilities that I've found somewhat useful.

#: .. function:: AudioToClip(audio, fps=24.0)
#:
#:    :param clip audio: the audio clip to be turned into a clip
#:    :param float fps: the FPS of the returned clip (defaults to 24)
#:
#:    AudioDub an audio clip on a BlankClip to allow it to be trimmed.
function AudioToClip(clip audio, float "fps") {
	fps = Default(fps, 24.0)
	return AudioDub( \
		BlankClip( \
			fps=fps, \
			length=Floor(audio.AudioLengthF() / audio.AudioRate())*fps \
		), audio)
}

#: .. function:: VideoLengthToAudioLength(c)
#:
#:    :param clip c: the clip to match audio and video lengths
#:
#:    Adds/removes frames from the video to match the audio length (via ``ChangeFPS``).
function VideoLengthToAudioLength(clip c) {
	audio_length = c.AudioLengthF() / c.AudioRate()
	# Calculate the "correct" framerate for the audio rate
	fps = c.FrameCount() / audio_length
	# And apply it
	return ChangeFPS(AssumeFPS(c, fps), \
		c.FrameRateNumerator(), c.FrameRateDenominator())
}

#: .. function:: Cut(c, start, end)
#:
#:    :param clip c: the clip to cut
#:    :param int start: the first frame (inclusive) to be removed
#:    :param int end: the last frame (exclusive) to be removed
#:
#:    Cut out a region of frames.
function Cut(clip c, int start, int end) {
	Assert(start < end, "start must be after end (given " + String(start) + ", " + String(end) + ")")
	return c.Trim(0, start-1) + c.Trim(end, 0)
}

#: .. function:: DissolveCut(c, start, end[, overlap])
#:
#:    :param clip c: the clip to cut
#:    :param int start: the first frame (inclusive) to be removed (fade starts
#:        on this frame)
#:    :param int end: the last frame (exclusive) to be removed (fade back in
#:        ends on this frame)
#:    :param int overlap: if given, the number of frames over which to fade
#:        while dissolving between the cut areas. Defaults to 1 second by
#:        rounding the frame rate to the nearest whole number.
#:
#:    Cut out a region, dissolving over the start and end of the cut footage.
#:    This actually removes the region from ``start + overlap`` through
#:    ``end - overlap``. So ``DissolveCut(c, 400, 600, 30)`` will completely
#:    remove frames 430-570 (inclusive), and frames 400-429 will dissolve to
#:    frames 571-600.
function DissolveCut(clip c, int start, int end, int "overlap") {
	overlap = Default(overlap, Round(c.FrameRate()))
	Assert(start + overlap < end - overlap, \
		"Frame cuts overlap (actual cut would be frames " + \
		String(start + overlap) + "-" + String(end + overlap) + ")")
	before = c.Trim(0, start+overlap)
	after = c.Trim(end-overlap, 0)
	return Dissolve(before, after, overlap)
}

#: .. function:: LayerFadeIO(back, over, start, end, start_time[, end_time], x=0, y=0, easing="linear"[, end_easing])
#:
#:    :param clip back: the clip to fade on top of
#:    :param clip over: the clip being faded on top of back
#:    :param int start: the frame to start fading in on
#:    :param int end: the frame to have finished fading out on
#:    :param int start_time: the number of frames to fade in over
#:    :param int end_time: the number of frames to fade out, defaults to start_time
#:    :param int x, y: coordinates to place the upper layer on; defaults to 0,0
#:    :param string easing: the easing function to use; defaults to
#:      ``EaseInLinear``
#:    :param string end_easing: the end easing function to use; defaults to the
#:      same as ``easing``
#:
#:    Fade a layer on top of another layer. The fade animation starts at the
#:    ``start`` frame (the first frame where the overlaid clip will be at all
#:    visible), and ends at ``end`` frame (the last frame where the overlaid
#:    clip will be at all visible). The clip will be fully opaque ``start_time``
#:    frames after ``start`` (so if ``start`` is 30 and ``start_time`` is 15,
#:    the first fully opaque frame will be 45).
#:
#:    Note that in order to use the Easing functions, you must include the
#:    ``Easings.avsi`` file.
#
function LayerFadeIO(clip back, clip over, \
		int start, int end, \
		int start_time, int "end_time", \
		int "x", int "y", \
		string "easing", string "end_easing") {
	easing = Default(easing, "EaseInLinear")
	end_easing = Default(end_easing, easing)
	end_time = Default(end_time, start_time)
	x = Default(x, 0)
	y = Default(y, 0)
	Assert(start < end, "Cannot start before end")
	Assert(start < back.FrameCount(), "Start time (" + String(start) + ") is after clip ends (" + String(back.FrameCount()-1) + ")")
	Assert(end < back.FrameCount(), "End time (" + String(end) + ") is after clip ends (" + String(back.FrameCount()-1) + ")")
	Assert(end - start_time > start, "End time does not give enough time for the clip to fade in (earliest start is " + String(end-start_time-end_time-1) + " using current settings)")
	Assert(end - start_time - end_time > start, "End time does not give enough time for the clip to fade out (earliest start is " + String(end-start_time-end_time-1) + " using current settings)")
	# Just the fade in section
	fade_in = Trim(back, start, start + start_time)
	# Everything after the fade in
	after = Trim(back, start + start_time + 1, 0)
	# Generate the actual fade in.
	before = Animate(fade_in, -1, start_time, "Layer_Easing", \
		over,"add",0.0,x,y,easing, over,"add",1.0,x,y,easing)
	# If start is 0, there is nothing to insert before the fade in. Otherwise,
	# add in the stuff from before it.
	before = start > 0 ? Trim(back, 0, (start == 1 ? -1 : start - 1)) + before : before
	# Convert end to after time
	end = end - before.FrameCount() - end_time
	#Assert(false, "Original is " + String(back.FrameCount()) + ", Start is " + String(start) + ", End is " + String(end) + ", final is " + String(end+end_time-1))
	# Trim out to only the part after the fade in
	over = Trim(over, start_time + 1, 0)
	# And generate the fade out
	after = Animate(after, end - 1, end + end_time + 1, "Layer_Easing", \
		over,"add",1.0,x,y,end_easing, over,"add",0.0,x,y,end_easing)
	# Combine them together
	res = before + after
	# Sanity check
	Assert(back.FrameCount() == res.FrameCount(), "Wanted " + string(back.FrameCount()) + ", have " + String(res.FrameCount()) + ", before is " + String(before.FrameCount()) + " frames, after is " + String(after.FrameCount()) + ", combined is " + String(before.FrameCount() + after.FrameCount()))
	return res
}

#: .. function:: LayerFadeIn(back, over, start, end, start_time[, end_time], x=0, y=0, easing="linear"[, end_easing])
#:
#:    :param clip back: the clip to fade on top of
#:    :param clip over: the clip being faded on top of back
#:    :param int start: the frame to start fading in on
#:    :param int fade_duration: the number of frames to fade in over
#:    :param int x, y: coordinates to place the upper layer on; defaults to 0,0
#:    :param string easing: the easing function to use; defaults to ``EaseInLinear``
#:
#:    Fade in a layer on top of another layer. The fade in animation starts at
#:    the ``start`` frame (the first frame where the overlaid clip will be at
#:    all visible) and lasts for ``fade_duration`` frames. Once the layer had
#:    been faded in, it will remain for the remainder of the video.
#:
#:    Note that in order to use the Easing functions, you must include the
#:    ``Easings.avsi`` file.
#
function LayerFadeIn(clip back, clip over, \
		int start, int fade_duration, \
		int "x", int "y", \
		string "easing") {
	easing = Default(easing, "EaseInLinear")
	x = Default(x, 0)
	y = Default(y, 0)
	Assert(start < back.FrameCount(), "Start time (" + String(start) + ") is after clip ends (" + String(back.FrameCount()-1) + ")")

	# Just the fade in section
	fade_in = Trim(back, start, 0)
	# Generate the actual fade in.
	res = Animate(fade_in, -1, fade_duration, "Layer_Easing", \
		over,"add",0.0,x,y,easing, over,"add",1.0,x,y,easing)
	# If start is 0, there is nothing to insert before the fade in. Otherwise,
	# add in the stuff from before it.
	res = start > 0 ? Trim(back, 0, (start == 1 ? -1 : start - 1)) + res : res
	# Sanity check
	Assert(back.FrameCount() == res.FrameCount(), "Wanted " + string(back.FrameCount()) + ", have " + String(res.FrameCount()))
	return res
}

function Layer_Easing(clip c, clip c2, string op, float level, int x, int y, string easing) {
	max_level = c.IsRGB() ? 257 : 256
	try {
		lvl = Round(Clamp(Easing(easing, level)) * max_level)
	} catch (ex) {
		Assert(easing == "EaseInLinear", "You must include Easings.avsi to use easings")
		lvl = Round(level * max_level)
	}
	return c.Layer(c2, op, lvl, x, y)
}

#: .. function:: AssertEquals(expected, actual)
#:
#:    :param val expected: the expected value
#:    :param val actual: the actual value received
#:
#:    Helper function for ``Assert`` to provide useful information.
function AssertEquals(val expected, val actual) {
	Assert(actual == expected, "Expected " + String(expected) + ", got " + String(actual))
}

#: .. function:: AssertFrameCountEquals(expected, actual[, verb][, message])
#:
#:    :param val expected: the base clip with the expected number of frames,
#:      or just an integer with the number of frames expected
#:    :param val actual: the actual clip with the number of frames to test,
#:      or just an integer with the actual number of frames
#:    :param string verb: if given, a verb to use in the default message,
#:      defaults to "generated"
#:    :param string message: if given, a default message to use (the verb
#:      parameter is not used in this case)
#:
#:    Fade in a layer on top of another layer. The fade in animation starts at
#:    the ``start`` frame (the first frame where the overlaid clip will be at
#:    all visible) and lasts for ``fade_duration`` frames. Once the layer had
#:    been faded in, it will remain for the remainder of the video.
#:
#:    Note that in order to use the Easing functions, you must include the
#:    ``Easings.avsi`` file.
#
function AssertFrameCountEquals(val expected, val actual, string "verb", string "message") {
	expected_count = IsClip(expected) ? expected.FrameCount() : expected
	actual_count = IsClip(actual) ? actual.FrameCount() : actual
	# FIXME if possible: report what the bad type is
	Assert(IsInt(expected_count), "Bad type for expected")
	Assert(IsInt(actual_count), "Bad type from actual")
	verb = Default(verb, "generated")
	message = Default(message, "Expected " + String(expected_count) + " frames, " + verb + " " + String(actual_count) + " frames (" + String(Abs(actual_count - expected_count)) + " too " + (actual_count > expected_count ? " many" : "few") + ")")
	Assert(expected_count == actual_count, message)
}
