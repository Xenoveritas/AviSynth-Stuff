Import("..\Transitions.avsi")

transition_time = 30
total_time = 40

clip_a = ImageSource("foggy.jpg", start=0, end=total_time, fps=30, pixel_type="RGB32")
clip_b = ImageSource("shoreline.jpg", start=0, end=total_time, fps=30, pixel_type="RGB32")

function Label(clip c, string transition, string easing) {
	return Subtitle(c, transition, align=2, x=c.Width()/2, y=c.Height()-22, size=16) \
		.Subtitle("Easing: " + easing, align=2, x=c.Width()/2, y=c.Height()-4, size=16)
}

PanLeftToRight(clip_a, clip_b, transition_time, easing="EaseInOutSine").Label("PanLeftToRight", "EaseInOutSine") ++ \
PanRightToLeft(clip_b, clip_a, transition_time, easing="EaseInOutSine").Label("PanRightToLeft", "EaseInOutSine") ++ \
PanTopToBottom(clip_a, clip_b, transition_time, easing="EaseInOutSine").Label("PanTopToBottom", "EaseInOutSine") ++ \
PanBottomToTop(clip_b, clip_a, transition_time, easing="EaseInOutSine").Label("PanBottomToTop", "EaseInOutSine") ++ \
SlideOutLeft(clip_a, clip_b, transition_time, easing="EaseInOutBack").Label("SlideOutLeft",  "EaseInOutBack") ++ \
SlideOutRight(clip_b, clip_a, transition_time, easing="EaseInOutBack").Label("SlideOutRight", "EaseInOutBack") ++ \
SlideOutUp(clip_a, clip_b, transition_time, easing="EaseInOutBack").Label("SlideOutUp",  "EaseInOutBack") ++ \
SlideOutDown(clip_b, clip_a, transition_time, easing="EaseInOutBack").Label("SlideOutDown", "EaseInOutBack") ++ \
SlideInLeft(clip_a, clip_b, transition_time, easing="EaseInOutElastic").Label("SlideInLeft",  "EaseInOutElastic") ++ \
SlideInRight(clip_b, clip_a, transition_time, easing="EaseInOutElastic").Label("SlideInRight", "EaseInOutElastic") ++ \
SlideInUp(clip_a, clip_b, transition_time, easing="EaseInOutElastic").Label("SlideInUp",  "EaseInOutElastic") ++ \
SlideInDown(clip_b, clip_a, transition_time, easing="EaseInOutElastic").Label("SlideInDown", "EaseInOutElastic") ++ \
DissolveEasing(clip_a, clip_b, transition_time, "EaseInOutSine").Label("DissolveEasing", "EaseInOutSine")
