#:
#: This contains several common transitions to move between clips.
#:
#: These transitions accept an "easing" function which determines how the
#: transition applies. See Easings.avsi for the complete list of easings.

Import("Easings.avsi")

#: .. function:: DissolveEasing(first, second, frames, easing)
#:
#:    :param clip first: the first clip (plays before the transition)
#:    :param clip second: the second clip (plays after the transition)
#:    :param int frames: the number of frames which the transition takes place over
#:    :param string easing: the easing function to use to do the transition
#:
#:    Identical to Dissolve (mostly) except uses the given easing function.
#:    Unlike the rest of panning transitions, this clamps the easing function to
#:    the 0..1 range. (Values less than 0 are treated as 0, greater than 1 are
#:    treated as 1.)
function DissolveEasing(clip first, clip second, int frames, string easing) {
	return CreateMovingTransition(first, second, BlankClip(first, length=frames), frames, easing, 0, 0, "Dissolve_anim")
}

function Dissolve_anim(clip background, clip first, clip second, string easing, int dx, int dy, float t) {
	a = Floor(Clamp(Eval(easing + "(" + String(t) + ")") * 255, 0, 255))
	return Layer(background, Layer(first, second, op="add", level=a), op="add")
}

#: .. function:: Pan(first, second, frames, dx, dy, [string easing[, clip background]])
#:
#:    :param clip first: the first clip (plays before the transition)
#:    :param clip second: the second clip (plays after the transition)
#:    :param int frames: the number of frames which the transition takes place over
#:    :param int dx: the x direction (-1 = left, 1 = right, 0 = no movement)
#:    :param int dy: the y direction (-1 = up, 1 = down, 0 = no movement)
#:    :param clip background: (optional) a clip behind the first and second
#:      clip. Defaults to a black BlankClip. Only really necessary if you have
#:      alpha in the clips or if you're going for a diagonal pan (where both dx
#:      and dy are non-zero), where it will be visible.
#:    :param string easing: the easing function to use to do the transition,
#:      defaults to ``EaseInLinear``
#:
#:    Pan from the first clip to the second clip in the given direction.
function Pan(clip first, clip second, int frames, int dx, int dy, string "easing", clip "background") {
	Assert(!(dx == 0 && dy == 0), "Cowardly refusing to do a pan with no movement")
	background = Default(background, BlankClip(first, length=frames))
	easing = Default(easing, "EaseInLinear")
	return CreateMovingTransition(first, second, background, frames, easing, dx, dy, "Pan_anim")
}

#: .. function:: PanLeftToRight(first, second, frames, [easing[, clip background]])
#:
#:    :func:`Pan` starting with the first clip, moving to the second clip,
#:    left-to-right. This is simply::
#:
#:        Pan(first, second, frames, -1, 0, easing, background)
function PanLeftToRight(clip first, clip second, int frames, string "easing", clip "background") {
	return Pan(first, second, frames, -1, 0, easing, background)
}

#: .. function:: PanRightToLeft(first, second, frames, [easing[, clip background]])
#:
#:    :func:`Pan` starting with the first clip, moving to the second clip,
#:    right-to-left. This is simply::
#:
#:        Pan(first, second, frames, 1, 0, easing, background)
function PanRightToLeft(clip first, clip second, int frames, string "easing", clip "background") {
	return Pan(first, second, frames, 1, 0, easing, background)
}

#: .. function:: PanTopToBottom(first, second, frames, [easing[, clip background]])
#:
#:    :func:`Pan` starting with the first clip, moving to the second clip,
#:    top-to-bottom. This is simply::
#:
#:        Pan(first, second, frames, 0, -1, easing, background)
function PanTopToBottom(clip first, clip second, int frames, string "easing", clip "background") {
	return Pan(first, second, frames, 0, -1, easing, background)
}

#: .. function:: PanBottomToTop(first, second, frames, [easing[, clip background]])
#:
#:    :func:`Pan` starting with the first clip, moving to the second clip,
#:    bottom-to-top. This is simply::
#:
#:        Pan(first, second, frames, 0, 1, easing, background)
function PanBottomToTop(clip first, clip second, int frames, string "easing", clip "background") {
	return Pan(first, second, frames, 0, 1, easing, background)
}

function Pan_anim(clip background, clip first, clip second, string easing, int dx, int dy, float t) {
	t = Easing(easing, t)
	x = dx == 0 ? 0 : Floor(t * (first.Width()-1)) * dx
	y = dy == 0 ? 0 : Floor(t * (first.Height()-1)) * dy
	sx = first.Width() * dx * -1
	sy = first.Height() * dy * -1
	r = Layer(background, first, "add", x=x, y=y)
	r = Layer(r, second, "add", x=(sx+x), y=(sy+y))
	return r
}

#: .. function:: SlideIn(first, second, frames, dx, dy, [string easing[, clip background]])
#:
#:    :param clip first: the first clip (plays before the transition)
#:    :param clip second: the second clip (plays after the transition)
#:    :param int frames: the number of frames which the transition takes place over
#:    :param int dx: the x direction (-1 = move left starting at the right,
#:      1 = move right starting at the left, 0 = no movement)
#:    :param int dy: the y direction the y direction (-1 = move up starting at
#:      the bottom, 1 = move down starting at the top, 0 = no movement)
#:    :param clip background: (optional) a clip behind the first and second
#:      clip. Defaults to a black BlankClip. Only really necessary if you have
#:      alpha in the clips.
#:    :param string easing: the easing function to use to do the transition,
#:      defaults to ``EaseInLinear``
#:
#:    Slide the second clip in over the first in the given direction.
function SlideIn(clip first, clip second, int frames, int dx, int dy, string "easing", clip "background") {
	background = Default(background, BlankClip(first, length=frames))
	easing = Default(easing, "EaseInLinear")
	return CreateMovingTransition(first, second, background, frames, easing, dx, dy, "SlideIn_anim")
}

#: .. function:: SlideInLeft(first, second, frames, [string easing[, clip background]])
#:
#:    :func:`SlideIn` the second clip in from the right, moving left. This is
#:    simply::
#:
#:        SlideIn(first, second, frames, -1, 0, easing, background)
function SlideInLeft(clip first, clip second, int frames, string "easing", clip "background") {
	return SlideIn(first, second, frames, -1, 0, easing, background)
}

#: .. function:: SlideInRight(first, second, frames, [string easing[, clip background]])
#:
#:    :func:`SlideIn` the second clip in from the left, moving right. This is
#:    simply::
#:
#:        SlideIn(first, second, frames, 1, 0, easing, background)
function SlideInRight(clip first, clip second, int frames, string "easing", clip "background") {
	return SlideIn(first, second, frames, 1, 0, easing, background)
}

#: .. function:: SlideInUp(first, second, frames, [string easing[, clip background]])
#:
#:    :func:`SlideIn` the second clip in from the bottom, moving up. This is
#:    simply::
#:
#:        SlideIn(first, second, frames, 0, -1, easing, background)
function SlideInUp(clip first, clip second, int frames, string "easing", clip "background") {
	return SlideIn(first, second, frames, 0, -1, easing, background)
}

#: .. function:: SlideInDown(first, second, frames, [string easing[, clip background]])
#:
#:    :func:`SlideIn` the second clip in from the top, moving down. This is
#:    simply::
#:
#:        SlideIn(first, second, frames, 0, 1, easing, background)
function SlideInDown(clip first, clip second, int frames, string "easing", clip "background") {
	return SlideIn(first, second, frames, 0, 1, easing, background)
}

function SlideIn_anim(clip background, clip first, clip second, string easing, int dx, int dy, float t) {
	t = Easing(easing, t)
	x = dx == 0 ? 0 : Floor(t * (first.Width()-1)) * dx
	y = dy == 0 ? 0 : Floor(t * (first.Height()-1)) * dy
	sx = first.Width() * dx * -1
	sy = first.Height() * dy * -1
	return Layer(first, second, "add", x=(sx+x), y=(sy+y))
}

#: .. function:: SlideOut(first, second, frames, dx, dy, [string easing[, clip background]])
#:
#:    :param clip first: the first clip (plays before the transition)
#:    :param clip second: the second clip (plays after the transition)
#:    :param int frames: the number of frames which the transition takes place over
#:    :param int dx: the x direction (-1 = move left starting at the right,
#:      1 = move right starting at the left, 0 = no movement)
#:    :param int dy: the y direction the y direction (-1 = move up starting at
#:      the bottom, 1 = move down starting at the top, 0 = no movement)
#:    :param clip background: (optional) a clip behind the first and second
#:      clip. Defaults to a black BlankClip. Only really necessary if you have
#:      alpha in the clips.
#:    :param string easing: the easing function to use to do the transition,
#:      defaults to ``EaseInLinear``
#:
#:    Slide the first clip out over the second in the given direction.
function SlideOut(clip first, clip second, int frames, int dx, int dy, string "easing", clip "background") {
	background = Default(background, BlankClip(first, length=frames))
	easing = Default(easing, "EaseInLinear")
	return CreateMovingTransition(first, second, background, frames, easing, dx, dy, "SlideOut_anim")
}

#: .. function:: SlideOutLeft(first, second, frames, [string easing[, clip background]])
#:
#:    :func:`SlideOut` the first clip out to the left, revealing the second.
#:    This is simply::
#:
#:        SlideOut(first, second, frames, -1, 0, easing, background)
function SlideOutLeft(clip first, clip second, int frames, string "easing", clip "background") {
	return SlideOut(first, second, frames, -1, 0, easing, background)
}

#: .. function:: SlideOutRight(first, second, frames, [string easing[, clip background]])
#:
#:    :func:`SlideOut` the first clip out to the right, revealing the second.
#:    This is simply::
#:
#:        SlideOut(first, second, frames, 1, 0, easing, background)
function SlideOutRight(clip first, clip second, int frames, string "easing", clip "background") {
	return SlideOut(first, second, frames, 1, 0, easing, background)
}

#: .. function:: SlideOutUp(first, second, frames, [string easing[, clip background]])
#:
#:    :func:`SlideOut` the first clip up out of the screen, revealing the second.
#:    This is simply::
#:
#:        SlideOut(first, second, frames, 0, -1, easing, background)
function SlideOutUp(clip first, clip second, int frames, string "easing", clip "background") {
	return SlideOut(first, second, frames, 0, -1, easing, background)
}


#: .. function:: SlideOutDown(first, second, frames, [string easing[, clip background]])
#:
#:    :func:`SlideOut` the first clip down out of the screen, revealing the second.
#:    This is simply::
#:
#:        SlideOut(first, second, frames, 0, 1, easing, background)
function SlideOutDown(clip first, clip second, int frames, string "easing", clip "background") {
	return SlideOut(first, second, frames, 0, 1, easing, background)
}

function SlideOut_anim(clip background, clip first, clip second, string easing, int dx, int dy, float t) {
	# Literally SlideIn backwards
	return SlideIn_anim(background, second, first, easing, -dx, -dy, 1.0-t)
}

function Wipe(clip first, clip second, int frames, int dx, int dy, string "easing", int "gradient") {
	easing = Default(easing, "EasingLinear")
	TransitionAsserts(first, second, frames)
	gradient = Default(gradient, dx != 0 ? first.Width()/16 : first.Height()/16)
	Assert(gradient >= 0, "Gradient size must be at least 0")
	Assert(!(dx == 0 && dy == 0), "Transition must be in some direction")
	Assert((dx != 0 && dy == 0) || (dx == 0 && dy != 0), "Diagonals are not supported at this time.")
	# Now generate the mask
	mask = dx != 0 ? CreateHorizontalGradientMask(first.Width(), first.Height(), gradient) : \
		CreateVerticalGradientMask(first.Width(), first.Height(), gradient)
	# Default mask is horizontal/vertical
	mask = dx > 0 ? FlipHorizontal(mask) : mask
	mask = dy > 0 ? FlipVertical(mask) : mask
	return CreateMovingTransition(first, second, mask, frames, easing, dx, dy, "Wipe_anim")
}

function WipeLeft(clip first, clip second, int frames, string "easing", int "width") {
	return Wipe(first, second, frames, -1, 0, easing, width)
}

function WipeRight(clip first, clip second, int frames, string "easing", int "width") {
	return Wipe(first, second, frames, 1, 0, easing, width)
}

function WipeUp(clip first, clip second, int frames, string "easing", int "height") {
	return Wipe(first, second, frames, 0, -1, easing, height)
}

function WipeDown(clip first, clip second, int frames, string "easing", int "height") {
	return Wipe(first, second, frames, 0, 1, easing, height)
}

# The original intention was to load a static gradient that went from 1-254 and
# just BilinearResize that as necessary. Sadly, ImageReader/ImageSource load
# relative to the "who even knows" directory (the current directory of
# whatever's loading the AVS maybe?), and it's impossible to get the current
# script directory, so instead we generate using a loop.
# Oh, but AviSynth doesn't do THAT either so enjoy this recursive, many-filtered
# monstrosity instead.
#
# (OK, so it is conceptually possible to get the current script path, you can do
# magic by *purposely throwing an exception and doing string magic to get the
# filename* but .. uh... no.)
#
# I wonder what the max recursion depth possible in AviSynth is?
function TransitionsGradientStackDestroyer(clip c, int w, int h, int x) {
	color = (255*(x+1))/(w+1)
	# Of COURSE AviSynth doesn't do bitshifting. What was I thinking?
	color = $FF000000 + (color * $10000) + (color * $100) + color
	c = c.Layer(BlankClip(length=1, pixel_type="RGB32", width=1, height=h, color=color), "add", x=x)
	x = x + 1
	return x < w ? \
	TransitionsGradientStackDestroyer(c, w, h, x) : \
	c
}

function TransitionsGradient(int w, int h) {
	# Initial color (so we can skip x=0)
	color = 255/(w+1)
	color = $FF000000 + (color * $10000) + (color * $100) + color
	# By setting the clip length to a single frame, we should (hopefully) force
	# the value of the Hell Filter we're about to create to be cached.
	c = BlankClip(length=1, pixel_type="RGB32", width=w, height=h, color=color)
	# The AviSynth manual recommends building a string to generate loops.
	# A-yup.
	return TransitionsGradientStackDestroyer(c, w, h, 1)
}

function CreateHorizontalGradientMask(int width, int height, int gradient_width) {
	Assert(width > 0 && height > 0, "Width/height must be at least 1!")
	Assert(gradient_width >= 0, "Gradient width must be at least 0")
	# Ignore the gradient for now
	# (Length=1 is a performance hack - basically, the frame should be generated
	# *once* and then cached and reused)
	rv = BlankClip(length=1, width=width*2+gradient_width, height=height, pixel_type="RGB32", color=$FF000000)
	right = BlankClip(length=1, width=width, height=height, pixel_type="RGB32", color=$FFFFFFFF)
	rv = rv.Layer(right, "add", x=(width+gradient_width))
	# If there is a gradient, generate it
	return gradient_width > 0 ? \
	rv.Layer(TransitionsGradient(gradient_width, height), "add", x=width) : \
	rv
}

function CreateVerticalGradientMask(int width, int height, int gradient_height) {
	# Haha, like I'm doing that a second time.
	return TurnRight(CreateHorizontalGradientMask(height, width, gradient_height))
}

function Wipe_anim(clip mask, clip first, clip second, string easing, int dx, int dy, float t) {
	t = Easing(easing, t)
	# Wipe moves the entire mask from 0-(mask.width()-second.width())
	x = dx == 0 ? 0 : Round(\
		(mask.Width()-second.Width()) * \
		(dx < 0 ? t : (1-t)))
	y = dy == 0 ? 0 : Round(\
		(mask.Height()-second.Height()) * \
		(dy < 0 ? t : (1-t)))
	# We don't actually "move" the mask - instead, we crop it as necessary
	mask = mask.Crop(x, y, second.Width(), second.Height())
	return first.Layer(Mask(second,mask), "add")
}

# These functions are separated out more to make the transition code more
# readable than any other reason.

# Trim before the transition overlap period.
function TrimBefore(clip c, int overlap) {
	return c.Trim(0, c.FrameCount() - overlap - 1)
}
# Trim everything after the transition overlap period.
function TrimAfter(clip c, int overlap) {
	return c.Trim(overlap, 0)
}

# Trim to only the given number of frames
function TrimEnd(clip c, int overlap) {
	return c.Trim(c.FrameCount()-overlap, c.FrameCount()-1)
}
# Trim only the given number at the start.
function TrimStart(clip c, int overlap) {
	return c.Trim(0, overlap)
}

#: .. function:: CreateMovingTransition(first, second, background, frames, easing, dx, dy, transition)
#:
#:    :param clip first: the first clip (plays before the transition)
#:    :param clip second: the second clip (plays after the transition)
#:    :param clip background: a clip behind the first and second, only really
#:      necessary in cases where the clips have alpha or the movement reveals a
#:      blank background.
#:    :param int frames: the number of frames which the transition takes place over
#:    :param string easing: the easing function to use to do the transition
#:    :param int dx: the x direction (-1 = left, 1 = right, 0 = no movement)
#:    :param int dy: the y direction (-1 = up, 1 = down, 0 = no movement)
#:      clip. Defaults to a black BlankClip. Only really necessary if you have
#:      alpha in the clips or if you're going for a diagonal pan (where both dx
#:      and dy are non-zero), where it will be visible.
#:    :param string transition: the function ``Animate`` should call
#:
#:    Utility function to create a transition that involves moving one clip over
#:    another. The majority of other transitions in this file use this to do
#:    the bulk of the work.
function CreateMovingTransition(clip first, clip second, clip background, int frames, string easing, int dx, int dy, string transition) {
	TransitionAsserts(first, second, frames)
	first_trans = first.TrimEnd(frames)
	second_trans = second.TrimStart(frames)
	transition = Animate(background,0,frames-1,transition, \
			first_trans,second_trans,easing,dx,dy,0.0, \
			first_trans,second_trans,easing,dx,dy,1.0)
	# Deal with audio over the transition.
	transition = transition.DissolveAudioEasing(first_trans, second_trans, easing)
	return first.TrimBefore(frames) + transition + second.TrimAfter(frames)
}

# Utility function to dissolve audio using an easing. Doesn't actually work.
# Hopefully I will find a solution, but until I do, this is the placeholder.
function DissolveAudioEasing(clip transition, clip first, clip second, string easing) {
	# FIXME: I'd absolutely love to have the audio follow the easing function,
	# but I can't at all come up with a way to do it.
	return HasAudio(first) && HasAudio(second) ? \
		AudioDub(transition, Dissolve(first, second, first.FrameCount())) : \
		transition
}

# Generic assertions that apply to all transitions
function TransitionAsserts(clip first, clip second, int frames) {
	Assert(frames > 0, "Frames must be at least 1 (got " + String(frames) + ")")
	Assert(frames <= first.FrameCount(), "Frames (" + String(frames) + \
		") cannot be greater than first clip's frame count (" + \
		String(first.FrameCount()) + ")")
	Assert(frames <= second.FrameCount(), "Frames (" + String(frames) + \
		") cannot be greater than second clip's frame count (" + \
		String(second.FrameCount()) + ")")
	Assert(first.Width() == second.Width() && first.Height() == second.Height(), \
		"Clips must be the same size (first is " + \
		String(first.Width()) + "x" + String(first.Height()) + \
		", second is " + String(second.Width()) + "x" + String(second.Height()) + ")")
}
