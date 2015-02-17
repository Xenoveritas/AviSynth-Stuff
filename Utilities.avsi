#: Miscellaneous utilities that I've found somewhat useful

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
#:    :param int start: the first frame (inclusive) to be removed
#:    :param int end: the last frame (exclusive) to be removed
#:    :param int overlap: if given, the number of frames to fade during.
#:        Defaults to 1 second by rounding the frame rate to the nearest whole
#:        number.
#:
#:    Cut out a region, dissolving between the region cut out.
function DissolveCut(clip c, int start, int end, int "overlap") {
	Assert(start + overlap < end - overlay, \
		"Frame cuts overlap (actual cut would be frames " + \
		String(start + overlap) + "-" + String(end + overlap) + ")")
	overlap = Default(overlap, Round(c.FrameRate()))
	before = c.Trim(0, start+overlap)
	after = c.Trim(end-overlap, 0)
	return Dissolve(before, after, overlap)
}
