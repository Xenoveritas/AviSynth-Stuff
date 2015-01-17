# Miscellaneous utilities that I've found somewhat useful

# AudioDub an audio clip on a BlankClip to allow it to be trimmed.
# audio   the audio clip to be turned into a clip
# fps     the FPS of the returned clip (defaults to 24)
function AudioToClip(clip audio, float "fps") {
	fps = Default(fps, 24.0)
	return AudioDub( \
		BlankClip( \
			fps=fps, \
			length=Floor(audio.AudioLengthF() / audio.AudioRate())*fps \
		), audio)
}

# Adds/removes frames from the video to match the audio length (via ChangeFPS).
# c    the clip to match audio and video lengths
function VideoLengthToAudioLength(clip c) {
	audio_length = c.AudioLengthF() / c.AudioRate()
	# Calculate the "correct" framerate for the audio rate
	fps = c.FrameCount() / audio_length
	# And apply it
	return ChangeFPS(AssumeFPS(c, fps), \
		c.FrameRateNumerator(), c.FrameRateDenominator())
}
