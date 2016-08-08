#
# Examples of the speed filers.
#

Import("..\Speed.avsi")

# Create an example clip with animation:

example = BlankClip(color=$FF000080, width=320, height=240, length=60).KillAudio()

# And use easings to make a square bounce back and forth.

Import("..\Easings.avsi")
function SquareAnim(clip back, int t) {
	total_frames = 60
	w = (back.Width()-10)
	h = (back.Height()-10)
	x = Floor(w * EaseOutBounce(Float(t%total_frames)/total_frames))
	return back.Layer(BlankClip(color=$FFFFFF00, width=10, height=10), x=x, y=h/2)
}

example = example.Animate(0, example.FrameCount()-1, "SquareAnim", \
	0, example.FrameCount()-1)

original = example.Subtitle("Original", align=2)
super_fast = example.IncreaseSpeed(10).Subtitle("IncreaseSpeed(10)", align=2)
slow_2x = example.ReduceSpeed2X().Subtitle("ReduceSpeed2X", align=2)
slow_4x = example.ReduceSpeed4X().Subtitle("ReduceSpeed4X", align=2)
fast_2x_blend = example.Speed2X().Subtitle("Speed2X, blend=true", align=2)
fast_2x = example.Speed2X(false).Subtitle("Speed2X, blend=false", align=2)
fast_4x_blend = example.Speed4X().Subtitle("Speed4X, blend=true", align=2)
fast_4x = example.Speed4X(false).Subtitle("Speed4X, blend=false", align=2)

StackVertical( \
	StackHorizontal(original, super_fast, slow_2x, slow_4x), \
	StackHorizontal(fast_2x_blend, fast_2x, fast_4x_blend, fast_4x) \
)
