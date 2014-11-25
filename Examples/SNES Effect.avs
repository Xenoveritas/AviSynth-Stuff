#
# Example of the SNES effect.
#

Import("..\SNESEffect.avsi")

# Wouldn't it be cool if we could create gradient clips? Use a blank clip with
# some text instead.

video = BlankClip(color=$FF0000AA, fps=30, length=30*5)
video = Subtitle(video, "This is an example.", size=72, align=5)

# Add some pixels to the corners to make this clearer...

# Create a dithered pattern.
pixel = BlankClip(color=$FFFF00FF, width=1, height=1)
dithered = BlankClip(color=$FF808080, width=4, height=4)
dithered = Layer(dithered, pixel, x=0, y=0)
dithered = Layer(dithered, pixel, x=2, y=0)
dithered = Layer(dithered, pixel, x=1, y=1)
dithered = Layer(dithered, pixel, x=3, y=1)
dithered = Layer(dithered, pixel, x=0, y=2)
dithered = Layer(dithered, pixel, x=2, y=2)
dithered = Layer(dithered, pixel, x=1, y=3)
dithered = Layer(dithered, pixel, x=3, y=3)

dithered = StackHorizontal(dithered, dithered, dithered, dithered)
dithered = StackVertical(dithered, dithered, dithered, dithered)

video = Layer(video, dithered)
video = Layer(video, dithered, x = video.Width() - dithered.Width())
video = Layer(video, dithered, y = video.Height() - dithered.Height())
video = Layer(video, dithered, x = video.Width() - dithered.Width(), y = video.Height() - dithered.Height())

function txt(clip c, string text) {
	return Subtitle(c, text, size=36, align=2, text_color=$CCCCCC)
}

# An example of dissolving with the effect.
dissolve_from = txt(video, "dissolving between clips; blend=true").Trim(0,3*30)
dissolve_to = ColorBars().AudioDub(video).AssumeFPS(30).Trim(0, 3*30)
dissolve_example = Dissolve(SNESPixelOut(dissolve_from, blend=true), \
    SNESPixelIn(dissolve_to, blend=true), 32)

# Basic sample of the types of things that happen
SNESPixelIO(txt(video, "blend=false, center=false"), blend=false, center=false) ++ \
SNESPixelIO(txt(video, "blend=true, center=false"), blend=true, center=false) ++ \
SNESPixelIO(txt(video, "blend=false, center=true"), blend=false, center=true) ++ \
SNESPixelIO(txt(video, "blend=true, center=true"), blend=true, center=true) ++ \
dissolve_example
