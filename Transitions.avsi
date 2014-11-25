#
# This contains several common transitions to move between clips.
#

Import("Easings.avsi")

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

# Utility function to do the meat of the transitions.
function CreateTransition(clip first, clip second, int frames, clip background, string easing, string transition) {
	TransitionAsserts(first, second, frames)
	first_trans = first.Trim(first.FrameCount()-frames, first.FrameCount()-1)
	second_trans = second.Trim(0, frames)
	transition = Animate(background,0,frames-1,transition, \
			first_trans,second_trans,easing,0.0, \
			first_trans,second_trans,easing,1.0)
	# Deal with audio over the transition.
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

function Dissolve_anim(clip background, clip first, clip second, string easing, float t) {
	a = Floor(Eval(easing + "(" + String(t) + ")") * 255)
	return Layer(background, Layer(first, second, op="add", level=a), op="add")
}
