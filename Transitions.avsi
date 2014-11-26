#
# This contains several common transitions to move between clips.
#
# These transitions accept an "easing" function which determines how the
# transition applies. See Easings.avsi for the complete list of easings.

Import("Easings.avsi")

# Identical to Dissolve (mostly) except uses the given easing function.
# Unlike the rest of panning transitions, this clamps the easing function to the
# 0..1 range. (Values less than 0 are treated as 0, greater than 1 are treated
# as 1.)
function DissolveEasing(clip first, clip second, int frames, string easing) {
	TransitionAsserts(first, second, frames)
	return CreateTransition(first, second, frames, BlankClip(first, length=frames), easing, "Dissolve_anim")
}

# Pan starting with the first clip, moving to the second clip, left-to-right
function PanLeftToRight(clip first, clip second, int frames, clip "background", string "easing") {
	background = Default(background, BlankClip(first, length=frames))
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, background, easing, "PanLR_anim")
}

# Pan starting with the first clip, moving to the second clip, right-to-left
function PanRightToLeft(clip first, clip second, int frames, clip "background", string "easing") {
	background = Default(background, BlankClip(first, length=frames))
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, background, easing, "PanRL_anim")
}

# Pan starting with the first clip, moving to the second clip, top-to-bottom
function PanTopToBottom(clip first, clip second, int frames, clip "background", string "easing") {
	background = Default(background, BlankClip(first, length=frames))
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, background, easing, "PanTB_anim")
}

# Pan starting with the first clip, moving to the second clip, bottom-to-top
function PanBottomToTop(clip first, clip second, int frames, clip "background", string "easing") {
	background = Default(background, BlankClip(first, length=frames))
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, background, easing, "PanBT_anim")
}

# Slides the second clip in from the left.
function SlideInLeft(clip first, clip second, int frames, string "easing") {
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, BlankClip(first, length=frames), easing, "SlideInL_anim")
}

# Slides the second clip in from the right.
function SlideInRight(clip first, clip second, int frames, string "easing") {
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, BlankClip(first, length=frames), easing, "SlideInR_anim")
}

# Slides the second clip in from the bottom.
function SlideInUp(clip first, clip second, int frames, string "easing") {
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, BlankClip(first, length=frames), easing, "SlideInU_anim")
}

# Slides the second clip in from the top.
function SlideInDown(clip first, clip second, int frames, string "easing") {
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, BlankClip(first, length=frames), easing, "SlideInD_anim")
}

# Slides the first clip out to the left, revealing the second.
function SlideOutLeft(clip first, clip second, int frames, string "easing") {
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, BlankClip(first, length=frames), easing, "SlideOutL_anim")
}

# Slides the first clip out to the right, revealing the second.
function SlideOutRight(clip first, clip second, int frames, string "easing") {
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, BlankClip(first, length=frames), easing, "SlideOutR_anim")
}

# Slides the first clip up out of the screen, revealing the second.
function SlideOutUp(clip first, clip second, int frames, string "easing") {
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, BlankClip(first, length=frames), easing, "SlideOutU_anim")
}

# Slides the first clip down out of the screen, revealing the second.
function SlideOutDown(clip first, clip second, int frames, string "easing") {
	easing = Default(easing, "EasingLinear")
	return CreateTransition(first, second, frames, BlankClip(first, length=frames), easing, "SlideOutD_anim")
}

# Utility function to do the meat of the transitions.
function CreateTransition(clip first, clip second, int frames, clip background, string easing, string transition) {
	TransitionAsserts(first, second, frames)
	first_trans = first.Trim(first.FrameCount()-frames, first.FrameCount()-1)
	second_trans = second.Trim(0, frames)
	transition = Animate(background,0,frames-1,transition, \
			first_trans,second_trans,easing,0.0, \
			first_trans,second_trans,easing,1.0)
	# Deal with audio over the transition.
	# FIXME: I'd absolutely love to have the audio follow the easing function,
	# but I can't at all come up with a way to do it.
	transition = HasAudio(first) && HasAudio(second) ? \
		AudioDub(transition, Dissolve(first_trans, second_trans, frames)) : \
		transition
	return first.Trim(0, first.FrameCount()-frames-1) + \
		transition + \
		second.Trim(frames,0)
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

function PanLR_anim(clip background, clip first, clip second, string easing, float t) {
	x = Floor(Eval(easing + "(" + String(t) + ")") * (first.Width()-1))
	r = Layer(background, first, "add", x=-x)
	r = Layer(r, second, "add", x=(first.Width()-x))
	return r
}

function PanRL_anim(clip background, clip first, clip second, string easing, float t) {
	x = Floor(Eval(easing + "(" + String(t) + ")") * (first.Width()-1))
	r = Layer(background, first, "add", x=x)
	r = Layer(r, second, "add", x=-(first.Width()-x))
	return r
}

function PanTB_anim(clip background, clip first, clip second, string easing, float t) {
	y = Floor(Eval(easing + "(" + String(t) + ")") * (first.Height()-1))
	r = Layer(background, first, "add", y=-y)
	r = Layer(r, second, "add", y=(first.Height()-y))
	return r
}

function PanBT_anim(clip background, clip first, clip second, string easing, float t) {
	y = Floor(Eval(easing + "(" + String(t) + ")") * (first.Height()-1))
	r = Layer(background, first, "add", y=y)
	r = Layer(r, second, "add", y=-(first.Height()-y))
	return r
}

function SlideInL_anim(clip background, clip first, clip second, string easing, float t) {
	x = Floor(Eval(easing + "(" + String(t) + ")") * (first.Width()-1))
	return Layer(first, second, "add", x=first.Width()-x)
}

function SlideInR_anim(clip background, clip first, clip second, string easing, float t) {
	x = Floor(Eval(easing + "(" + String(t) + ")") * (first.Width()-1))
	return Layer(first, second, "add", x=x-first.Width())
}

function SlideInU_anim(clip background, clip first, clip second, string easing, float t) {
	y = Floor(Eval(easing + "(" + String(t) + ")") * (first.Height()-1))
	return Layer(first, second, "add", y=first.Height()-y)
}

function SlideInD_anim(clip background, clip first, clip second, string easing, float t) {
	y = Floor(Eval(easing + "(" + String(t) + ")") * (first.Height()-1))
	return Layer(first, second, "add", y=y-first.Height())
}

function SlideOutL_anim(clip background, clip first, clip second, string easing, float t) {
	x = Floor(Eval(easing + "(" + String(t) + ")") * (first.Width()-1))
	return Layer(second, first, "add", x=-x)
}

function SlideOutR_anim(clip background, clip first, clip second, string easing, float t) {
	x = Floor(Eval(easing + "(" + String(t) + ")") * (first.Width()-1))
	return Layer(second, first, "add", x=x)
}

function SlideOutU_anim(clip background, clip first, clip second, string easing, float t) {
	y = Floor(Eval(easing + "(" + String(t) + ")") * (first.Height()-1))
	return Layer(second, first, "add", y=-y)
}

function SlideOutD_anim(clip background, clip first, clip second, string easing, float t) {
	y = Floor(Eval(easing + "(" + String(t) + ")") * (first.Height()-1))
	return Layer(second, first, "add", y=y)
}

function Dissolve_anim(clip background, clip first, clip second, string easing, float t) {
	a = Floor(Clamp(Eval(easing + "(" + String(t) + ")") * 255, 0, 255))
	return Layer(background, Layer(first, second, op="add", level=a), op="add")
}
