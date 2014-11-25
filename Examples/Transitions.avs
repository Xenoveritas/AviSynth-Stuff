Import("..\Transitions.avsi")

transition_time = 30
total_time = 40

clip_a = ImageSource("foggy.jpg", start=0, end=total_time, fps=30, pixel_type="RGB32")
clip_b = ImageSource("shoreline.jpg", start=0, end=total_time, fps=30, pixel_type="RGB32")

PanLeftToRight(clip_a, clip_b, transition_time).Subtitle("PanLeftToRight") ++ \
PanRightToLeft(clip_b, clip_a, transition_time).Subtitle("PanRightToLeft") ++ \
PanTopToBottom(clip_a, clip_b, transition_time).Subtitle("PanTopToBottom") ++ \
PanBottomToTop(clip_b, clip_a, transition_time).Subtitle("PanBottomToTop") ++ \
PanLeftToRight(clip_a, clip_b, transition_time, easing="EaseInOutSine").Subtitle("PanLeftToRight (EaseInOutSine)") ++ \
PanRightToLeft(clip_b, clip_a, transition_time, easing="EaseInOutSine").Subtitle("PanRightToLeft (EaseInOutSine)") ++ \
PanTopToBottom(clip_a, clip_b, transition_time, easing="EaseInOutSine").Subtitle("PanTopToBottom (EaseInOutSine)") ++ \
PanBottomToTop(clip_b, clip_a, transition_time, easing="EaseInOutSine").Subtitle("PanBottomToTop (EaseInOutSine)") ++ \
DissolveEasing(clip_a, clip_b, transition_time, "EaseInOutSine").Subtitle("DissolveEasing (EaseInOutSine)")
