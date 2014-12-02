Import("..\Transitions.avsi")

transition_time = 30
total_time = 40

clip_a = ImageSource("foggy.jpg", start=0, end=total_time, fps=30, pixel_type="RGB32")
clip_b = ImageSource("shoreline.jpg", start=0, end=total_time, fps=30, pixel_type="RGB32")

# Debugging:
#clip_a = clip_a.ShowFrameNumber(x=10, y=30, size=20)
#clip_b = clip_b.ShowFrameNumber(x=clip_b.Width()-60, y=30, size=20)

# For the sake of these, make clip_a have a 440Hz tone behind it
clip_a = AudioDub(clip_a, Tone())
# Now clip_b needs audio as well. It's set to silence so visually looking at the
# audio generated can determine if the transition easings are working correctly.
clip_b = AudioDub(clip_b, Tone(type="silence"))

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
DissolveEasing(clip_a, clip_b, transition_time, "EaseInOutSine").Label("DissolveEasing", "EaseInOutSine") ++ \
WipeLeft(clip_b, clip_a, transition_time, "EaseInOutSine").Label("WipeLeft", "EaseInOutSine") ++ \
WipeRight(clip_a, clip_b, transition_time, "EaseInOutSine").Label("WipeRight", "EaseInOutSine") ++ \
WipeUp(clip_b, clip_a, transition_time, "EaseInOutSine").Label("WipeUp", "EaseInOutSine") ++ \
WipeDown(clip_a, clip_b, transition_time, "EaseInOutSine").Label("WipeDown", "EaseInOutSine")
