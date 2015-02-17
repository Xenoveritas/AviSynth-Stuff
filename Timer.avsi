#:
#: Create an overlay on top of an existing clip that is a timer.
#:

#: .. function:: Timer(video, timer, x, y, start_frame, end_frame, colon_width, use_dashes, type)
#:
#:    :param clip video: the video to overlay the timer on top of
#:    :param clip timer: a clip to use for the timer digits
#:    :param int x, y: the x, y coordinates (defaults to 0, 0)
#:    :param int start_frame: the first frame to display the timer on (defaults
#:      to 0)
#:    :param int end_frame: the last frame to end the timer on (defaults to the
#:      ``video``'s ``FrameCount``)
#:    :param int colon_width: the width of the colon glyph, otherwise assumed
#:      to be the same as the digits
#:    :param bool use_dashes: indicates that the timer contains 12 glyphs, the
#:      12th is a dash to use before the timer starts. The dash is always the
#:      width of a digit as it replaces the digits. (Defaults to ``false``)
#:    :param string type: either ``"MS"`` to only show minutes/seconds or
#:      ``"HMS"`` to show hours/minutes/seconds. Default is ``"MS"`` if the
#:      time span from ``start`` to ``end`` is less than an hour, ``"HMS"`` if
#:      it is an hour or more.
#:
#:    Overlay the given video with a timer, using the given information.
#:
#:    The timer clip should be an image clip (as only the first frame will be used
#:    - I think), which contains each of the digits starting at 0 and ending at 9,
#:    and then a colon to use to separate hours/minutes/seconds.
#:
#:    If ``use_dashes`` is ``true`` then the timer image should be 0-9, the dash,
#:    and finally the colon.
function Timer(clip video, clip timer, int "x", int "y", \
	int "start_frame", int "end_frame", int "colon_width", bool "use_dashes", \
	string "type") {
	start_frame = Default(start_frame, 0)
	end_frame = Default(end_frame, video.FrameCount()-1)
	Assert(start_frame < end_frame, "Start frame " + String(start_frame) + " after end frame " + String(end_frame))
	x = Default(x, 0)
	y = Default(y, 0)
	use_dashes = Default(use_dashes, false)
	type = Default(type, ((end_frame - start_frame) / video.FrameRate()) < (60*60) ? "MS" : "HMS")
	# Calculate digit width (timer is 10 digits plus the colon, plus optionally
	# the dash)
	colon_width = Default(colon_width, timer.Width()/(use_dashes ? 12 : 11))
	digit_width = (timer.Width()-colon_width)/(use_dashes ? 11 : 10)
	Assert(digit_width > 0, "Digit width is too small (" + String(digit_width) + ")")
	Assert(colon_width > 0, "Colon width is too small (" + String(colon_width) + ")")
	# If there is no chance to use the dash, just disable it
	use_dashes = use_dashes && start_frame > 0 ? use_dashes : false
	return Animate(video, \
		use_dashes ? start_frame-1 : start_frame, \
		end_frame, "OverlayTimer" + type, \
		timer, use_dashes ? -1 : 0, digit_width, colon_width, x, y, \
		timer, end_frame-start_frame, digit_width, colon_width, x, y)
}

#: .. function:: TimerWithMillis(video, timer, timer_ms, x, y, start_frame, end_frame, colon_width, colon_width_ms, use_dashes, type)
#:
#:    :param clip video: the video to overlay the timer on top of
#:    :param clip timer: a clip to use for the timer digits
#:    :param clip timer_ms: a clip to use for the timer digits
#:    :param int x, y: the x, y coordinates (defaults to 0, 0)
#:    :param int start_frame: the first frame to display the timer on (defaults
#:      to 0)
#:    :param int end_frame: the last frame to end the timer on (defaults to the
#:      ``video``'s ``FrameCount``)
#:    :param int colon_width: the width of the colon glyph, otherwise assumed
#:      to be the same as the digits
#:    :param int colon_width_ms: the width of the colon glyph for the
#:      milliseconds digits, otherwise assumed to be the same as the
#:      millisecond digits
#:    :param bool use_dashes: indicates that the timer contains 12 glyphs, the
#:      12th is a dash to use before the timer starts. The dash is always the
#:      width of a digit as it replaces the digits. (Defaults to ``false``)
#:    :param string type: either ``"MS"`` to only show minutes/seconds or
#:      ``"HMS"`` to show hours/minutes/seconds. Default is ``"MS"`` if the
#:      time span from ``start`` to ``end`` is less than an hour, ``"HMS"`` if
#:      it is an hour or more.
#:
#:    Overlay the given video with a timer, using the given information.
#:
#:    The timer clip should be an image clip (as only the first frame will be used
#:    - I think), which contains each of the digits starting at 0 and ending at 9,
#:    and then a colon to use to separate hours/minutes/seconds. The millisecond
#:    image can be a different size to allow milliseconds to be smaller than the
#:     main digits.
#:
#:    If ``use_dashes`` is ``true`` then both timer images should be 0-9, the dash,
#:    and finally the colon.
function TimerWithMillis(clip video, clip timer, clip timer_ms, int "x", int "y", \
	int "start_frame", int "end_frame", int "colon_width", int "colon_width_ms", bool "use_dashes", \
	string "type") {
	start_frame = Default(start_frame, 0)
	end_frame = Default(end_frame, video.FrameCount()-1)
	Assert(start_frame < end_frame, "Start frame " + String(start_frame) + " after end frame " + String(end_frame))
	x = Default(x, 0)
	y = Default(y, 0)
	use_dashes = Default(use_dashes, false)
	type = Default(type, ((end_frame - start_frame) / video.FrameRate()) < (60*60) ? "MS" : "HMS")
	# Calculate digit width (timer is 10 digits plus the colon, plus optionally
	# the dash)
	colon_width = Default(colon_width, timer.Width()/(use_dashes ? 12 : 11))
	digit_width = (timer.Width()-colon_width)/(use_dashes ? 11 : 10)
	Assert(digit_width > 0, "Digit width is too small (" + String(digit_width) + ")")
	Assert(colon_width > 0, "Colon width is too small (" + String(colon_width) + ")")
	colon_width_ms = Default(colon_width_ms, timer_ms.Width()/(use_dashes ? 12 : 11))
	digit_width_ms = (timer_ms.Width()-colon_width_ms)/(use_dashes ? 11 : 10)
	Assert(digit_width_ms > 0, "Millisecond digit width is too small (" + String(digit_width_ms) + ")")
	Assert(colon_width_ms >= 0, "Millisecond colon width is too small (" + String(colon_width_ms) + ")")
	# If there is no chance to use the dash, just disable it
	use_dashes = use_dashes && start_frame > 0 ? use_dashes : false
	return Animate(video, \
		use_dashes ? start_frame-1 : start_frame, \
		end_frame, "OverlayTimer" + type + "ms", \
		timer, timer_ms, use_dashes ? -1 : 0, digit_width, colon_width, digit_width_ms, colon_width_ms, x, y, \
		timer, timer_ms, end_frame-start_frame, digit_width, colon_width, digit_width_ms, colon_width_ms, x, y)
}

function OverlayTimerDigit(clip video, clip timer, int digit, int digit_width, int x, int y) {
	digit_clip = Crop(timer, \
		digit*digit_width, 0, \
		digit_width, timer.Height())
	return Layer(video, digit_clip, x=x, y=y)
}

# If only I hadn't made the dash last, this would be unnecessary... oh well.
function OverlayTimerColon(clip video, clip timer, int digit_width, int colon_width, int x, int y) {
	digit_clip = Crop(timer, \
		digit_width*10, 0, \
		colon_width, timer.Height())
	return Layer(video, digit_clip, x=x, y=y)
}

function OverlayTimerMS(clip video, clip timer, int frame, int digit_width, \
		int colon_width, int x, int y) {
	# First, convert frames into seconds
	seconds = Floor(frame / video.FrameRate())
	# Calculate minutes...
	minutes = seconds / 60
	# ...and remove them from the seconds counter...
	seconds = seconds - minutes * 60
	# ...and generate the timer overlay:
	minutes_10s = frame < 0 ? 11 : minutes / 10
	minutes_1s = frame < 0 ? 11 : minutes - minutes_10s*10
	seconds_10s = frame < 0 ? 11 : seconds / 10
	seconds_1s = frame < 0 ? 11 : seconds - seconds_10s*10
	result = video
	result = OverlayTimerDigit(result, timer, minutes_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, minutes_1s, digit_width, x, y)
	x = x + digit_width
	# Colon
	result = OverlayTimerColon(result, timer, digit_width, colon_width, x, y)
	x = x + colon_width
	result = OverlayTimerDigit(result, timer, seconds_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, seconds_1s, digit_width, x, y)
	return result
}

function OverlayTimerHMS(clip video, clip timer, int frame, int digit_width, \
		int colon_width, int x, int y) {
	# First, convert frames into seconds
	seconds = Floor(frame / video.FrameRate())
	# Calculate minutes...
	minutes = seconds / 60
	# ...and remove them from the seconds counter...
	seconds = seconds - minutes * 60
	# ...and now calculate hours...
	hours = frame < 0 ? 11 : minutes / 60
	# ...and remove them from the minutes counter...
	minutes = minutes - hours * 60
	# ...and generate the timer overlay:
	minutes_10s = frame < 0 ? 11 : minutes / 10
	minutes_1s = frame < 0 ? 11 : minutes - minutes_10s*10
	seconds_10s = frame < 0 ? 11 : seconds / 10
	seconds_1s = frame < 0 ? 11 : seconds - seconds_10s*10
	result = video
	result = OverlayTimerDigit(result, timer, hours, digit_width, x, y)
	x = x + digit_width
	# Colon
	result = OverlayTimerColon(result, timer, digit_width, colon_width, x, y)
	x = x + colon_width
	result = OverlayTimerDigit(result, timer, minutes_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, minutes_1s, digit_width, x, y)
	x = x + digit_width
	# Colon
	result = OverlayTimerColon(result, timer, digit_width, colon_width, x, y)
	x = x + colon_width
	result = OverlayTimerDigit(result, timer, seconds_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, seconds_1s, digit_width, x, y)
	return result
}

function OverlayTimerMSms(clip video, clip timer, clip timer_ms, int frame, \
		int digit_width, int colon_width, \
		int digit_width_ms, int colon_width_ms, int x, int y) {
	# First, convert frames into seconds
	seconds = frame / video.FrameRate()
	# Grab the milliseconds...
	millis = Floor(seconds * 1000) % 1000
	# ...and drop them from the seconds.
	seconds = Floor(seconds)
	# Calculate minutes...
	minutes = seconds / 60
	# ...and remove them from the seconds counter...
	seconds = seconds - minutes * 60
	# ...and generate the timer overlay:
	minutes_10s = frame < 0 ? 11 : minutes / 10
	minutes_1s = frame < 0 ? 11 : minutes - minutes_10s*10
	seconds_10s = frame < 0 ? 11 : seconds / 10
	seconds_1s = frame < 0 ? 11 : seconds - seconds_10s*10
	millis_100s = frame < 0 ? 11 : millis / 100
	millis_10s = frame < 0 ? 11 : (millis - millis_100s*100) / 10
	millis_1s = frame < 0 ? 11 : millis - millis_100s*100 - millis_10s*10
	result = video
	result = OverlayTimerDigit(result, timer, minutes_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, minutes_1s, digit_width, x, y)
	x = x + digit_width
	# Colon
	result = OverlayTimerColon(result, timer, digit_width, colon_width, x, y)
	x = x + colon_width
	result = OverlayTimerDigit(result, timer, seconds_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, seconds_1s, digit_width, x, y)
	# And now for the millisecond part
	y = y + timer.Height() - timer_ms.Height()
	x = x + digit_width
	result = colon_width_ms > 0 ? OverlayTimerColon(result, timer_ms, digit_width_ms, colon_width_ms, x, y) : result
	x = x + colon_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_100s, digit_width_ms, x, y)
	x = x + digit_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_10s, digit_width_ms, x, y)
	x = x + digit_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_1s, digit_width_ms, x, y)
	x = x + digit_width_ms
	return result
}

function OverlayTimerHMSms(clip video, clip timer, clip timer_ms, int frame, \
		int digit_width, int colon_width, \
		int digit_width_ms, int colon_width_ms, \
		int x, int y) {
	# First, convert frames into seconds
	seconds = frame / video.FrameRate()
	# Grab the milliseconds...
	millis = Floor(seconds * 1000) % 1000
	# ...and drop them from the seconds.
	seconds = Floor(seconds)
	# Calculate minutes...
	minutes = seconds / 60
	# ...and remove them from the seconds counter...
	seconds = seconds - minutes * 60
	# ...and now calculate hours...
	hours = frame < 0 ? 11 : minutes / 60
	# ...and remove them from the minutes counter...
	minutes = minutes - hours * 60
	# ...and generate the timer overlay:
	minutes_10s = frame < 0 ? 11 : minutes / 10
	minutes_1s = frame < 0 ? 11 : minutes - minutes_10s*10
	seconds_10s = frame < 0 ? 11 : seconds / 10
	seconds_1s = frame < 0 ? 11 : seconds - seconds_10s*10
	millis_100s = frame < 0 ? 11 : millis / 100
	millis_10s = frame < 0 ? 11 : (millis - millis_100s*100) / 10
	millis_1s = frame < 0 ? 11 : millis - millis_100s*100 - millis_10s*10
	result = video
	result = OverlayTimerDigit(result, timer, hours, digit_width, x, y)
	x = x + digit_width
	# Colon
	result = OverlayTimerColon(result, timer, digit_width, colon_width, x, y)
	x = x + colon_width
	result = OverlayTimerDigit(result, timer, minutes_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, minutes_1s, digit_width, x, y)
	x = x + digit_width
	# Colon
	result = OverlayTimerColon(result, timer, digit_width, colon_width, x, y)
	x = x + colon_width
	result = OverlayTimerDigit(result, timer, seconds_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, seconds_1s, digit_width, x, y)
	# And now for the millisecond part
	y = y + timer.Height() - timer_ms.Height()
	x = x + digit_width
	result = colon_width_ms > 0 ? OverlayTimerColon(result, timer_ms, digit_width_ms, colon_width_ms, x, y) : result
	x = x + colon_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_100s, digit_width_ms, x, y)
	x = x + digit_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_10s, digit_width_ms, x, y)
	x = x + digit_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_1s, digit_width_ms, x, y)
	x = x + digit_width_ms
	return result
}
