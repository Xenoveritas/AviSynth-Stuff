#
# Example script for using the timer.
#

# Import the header containing the timer functions
Import("Timer.avsi")

# The clip to use for the timer digits:
digits = ImageSource("led_digits.png", pixel_type="RGB32")
# Since we want to include the alpha mask, we need to use RGB32. The image you
# use should almost always be RGB32.
#
# NOTE: If it looks like the image clips strangely, that's because the blurs
# really do go across image boundaries in the original source from Wikimedia
# Commons.

# Create a clip:
c = BlankClip(length=15*60*24, fps=24)

# And add a timer to it:
Timer(c, digits, colon_width=32)

# And a timer in the lower-right corner with hours:
Timer(digits, colon_width=32, type="HMS", \
	x = Width() - (70 * 5 + 32 * 2), \
	y = Height() - digits.Height())

# Here, we're abusing last to not pass in a clip (it happens automatically, so
# digits is the digit clip and the clip the timer is added to is the one
# returned by the previous clip), and calculating the position. Since in HMS
# mode there are five digits and two colons, we use those to position based on
# the Width() of the last clip, and then place the y based on the Height() of
# the blank clip and the Height() of the digits.
