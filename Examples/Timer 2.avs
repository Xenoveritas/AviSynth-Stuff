# A newer example

Import("..\Timer.avsi")

video = BlankClip(length=24*90*60)

digits = ImageSource("digits.png", pixel_type="RGB32")
msDigits = ImageSource("milli_digits.png", pixel_type="RGB32")
msDigitsNoSep = ImageSource("milli_digits_no_sep.png", pixel_type="RGB32")

y = 0
video = video.Subtitle("TimerWithMillis (MS)", x=0, y=y, align=7, size=16, text_color=$FFFFFF)
y = y + 16
video = TimerWithMillis(video, digits, msDigits, colon_width=12, colon_width_ms=5, x=0, y=y, type="MS")
y = y + digits.Height()
video = video.Subtitle("Timer (MS)", x=0, y=y, align=7, size=16, text_color=$FFFFFF)
y = y + 16
video = Timer(video, digits, x=0, y=y, colon_width=12, type="MS")
y = y + digits.Height()
video = video.Subtitle("TimerWithMillis (HMS)", x=0, y=y, align=7, size=16, text_color=$FFFFFF)
y = y + 16
video = TimerWithMillis(video, digits, msDigits, colon_width=12, colon_width_ms=5, x=0, y=y, type="HMS")
y = y + digits.Height()
video = video.Subtitle("Timer (HMS)", x=0, y=y, align=7, size=16, text_color=$FFFFFF)
y = y + 16
video = Timer(video, digits, x=0, y=y, colon_width=12, type="HMS")
y = y + digits.Height()
video = video.Subtitle("TimerWithMillis (HMS, no colon)", x=0, y=y, align=7, size=16, text_color=$FFFFFF)
y = y + 16
video = TimerWithMillis(video, digits, msDigitsNoSep, colon_width=12, colon_width_ms=0, x=0, y=y, type="HMS")

video
