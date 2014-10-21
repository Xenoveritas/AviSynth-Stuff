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
