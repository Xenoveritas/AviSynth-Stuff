#
# Create an overlay on top of an existing clip that is a timer
#
# See Timer and TimerWithMillis for usage.
#

# Simple function that creates a timer.

function OverlayTimerDigit(clip video, clip timer, int digit, int digit_width, int x, int y) {
	digit_clip = Crop(timer, \
		digit*digit_width, 0, \
		digit_width, timer.Height())
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
	result = OverlayTimerDigit(result, timer, 10, digit_width, x, y)
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
	result = OverlayTimerDigit(result, timer, 10, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, minutes_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, minutes_1s, digit_width, x, y)
	x = x + digit_width
	# Colon
	result = OverlayTimerDigit(result, timer, 10, digit_width, x, y)
	x = x + colon_width
	result = OverlayTimerDigit(result, timer, seconds_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, seconds_1s, digit_width, x, y)
	return result
}

function OverlayTimerMSms(clip video, clip timer, clip timer_ms, int frame, int digit_width, \
		int colon_width, int digit_width_ms, int x, int y) {
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
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, minutes_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, minutes_1s, digit_width, x, y)
	x = x + digit_width
	# Colon
	result = OverlayTimerDigit(result, timer, 10, digit_width, x, y)
	x = x + colon_width
	result = OverlayTimerDigit(result, timer, seconds_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, seconds_1s, digit_width, x, y)
	# And now for the millisecond part
	y = y + timer.Height() - timer_ms.Height()
	x = x + digit_width
	result = OverlayTimerDigit(result, timer_ms, 10, digit_width_ms, x, y)
	x = x + digit_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_100s, digit_width_ms, x, y)
	x = x + digit_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_10s, digit_width_ms, x, y)
	x = x + digit_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_1s, digit_width_ms, x, y)
	x = x + digit_width_ms
	return result
}

function OverlayTimerHMSms(clip video, clip timer, clip timer_ms, int frame, int digit_width, \
		int colon_width, int digit_width_ms, int x, int y) {
	# First, convert frames into seconds
	seconds = frame / video.FrameRate()
	# Grab the milliseconds...
	millis = Floor((seconds * 1000) % 1000)
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
	result = OverlayTimerDigit(result, timer, 10, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, minutes_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, minutes_1s, digit_width, x, y)
	x = x + digit_width
	# Colon
	result = OverlayTimerDigit(result, timer, 10, digit_width, x, y)
	x = x + colon_width
	result = OverlayTimerDigit(result, timer, seconds_10s, digit_width, x, y)
	x = x + digit_width
	result = OverlayTimerDigit(result, timer, seconds_1s, digit_width, x, y)
	# And now for the millisecond part
	y = y + timer.Height() - timer_ms.Height()
	x = x + digit_width
	result = OverlayTimerDigit(result, timer_ms, 10, digit_width_ms, x, y)
	x = x + digit_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_100s, digit_width_ms, x, y)
	x = x + digit_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_10s, digit_width_ms, x, y)
	x = x + digit_width_ms
	result = OverlayTimerDigit(result, timer_ms, millis_1s, digit_width_ms, x, y)
	x = x + digit_width_ms
	return result
}

# Overlay the given video with a timer, using the given information.
#
# The timer clip should be an image clip (as only the first frame will be used
# - I think), which contains each of the digits starting at 0 and ending at 9,
# and then a colon to use to separate hours/minutes/seconds.
#
# video         the video to overlay the timer on top of
# timer         a clip to use for the timer digits
# x, y          the x, y coordinates (defaults to 0, 0)
# start_frame   the first frame to display the timer on
# end_frame     the last frame to end the timer on
# colon_width   if specified, the width of the colon
# use_dashes    timer contains 12 glyphs, the 12th is a dash to use before the
#               timer starts (default false) - the dash is always the width of
#               a digit.
# type          either "MS" to only show minutes/seconds or "HMS" to show
#               hours/minutes/seconds - default is based on how much time is
#               in the video
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
	digit_width = timer.Width()/(use_dashes ? 12 : 11)
	colon_width = Default(colon_width, digit_width)
	# If there is no chance to use the dash, just disable it
	use_dashes = use_dashes && start_frame > 0 ? use_dashes : false
	return Animate(video, \
		use_dashes ? start_frame-1 : start_frame, \
		end_frame, "OverlayTimer" + type, \
		timer, use_dashes ? -1 : 0, digit_width, colon_width, x, y, \
		timer, end_frame-start_frame, digit_width, colon_width, x, y)
}

# Overlay the given video with a timer, using the given information.
#
# The timer clip should be an image clip (as only the first frame will be used
# - I think), which contains each of the digits starting at 0 and ending at 9,
# and then a colon to use to separate hours/minutes/seconds.
#
# video         the video to overlay the timer on top of
# timer         a clip to use for the timer digits
# timer_ms      a clip to use for timer digits showing milliseconds
# x, y          the x, y coordinates (defaults to 0, 0)
# start_frame   the first frame to display the timer on
# end_frame     the last frame to end the timer on
# colon_width   if specified, the width of the colon
# use_dashes    timer contains 12 glyphs, the 12th is a dash to use before the
#               timer starts (default false) - the dash is always the width of
#               a digit.
# type          either "MS" to only show minutes/seconds or "HMS" to show
#               hours/minutes/seconds - default is based on how much time is
#               in the video
function TimerWithMillis(clip video, clip timer, clip timer_ms, int "x", int "y", \
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
	digit_width = timer.Width()/(use_dashes ? 12 : 11)
	colon_width = Default(colon_width, digit_width)
	digit_width_ms = timer_ms.Width()/(use_dashes ? 12 : 11)
	# If there is no chance to use the dash, just disable it
	use_dashes = use_dashes && start_frame > 0 ? use_dashes : false
	return Animate(video, \
		use_dashes ? start_frame-1 : start_frame, \
		end_frame, "OverlayTimer" + type + "ms", \
		timer, timer_ms, use_dashes ? -1 : 0, digit_width, colon_width, digit_width_ms, x, y, \
		timer, timer_ms, end_frame-start_frame, digit_width, colon_width, digit_width_ms, x, y)
}
