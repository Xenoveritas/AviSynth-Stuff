# Easings.avs
#
# This is a generated file. Use:
#   node Easings.js > Easings.avs
# to generate this file.
#
# These examples may still prove useful but this file is mostly intended to show
# what the easings do.

Import("..\Easings.avsi")

global dot = BlankClip(150, 5, 5, color=$FFFF0000)
global fade_from = ImageSource("foggy.jpg", pixel_type="RGB32")
global fade_to = ImageSource("shoreline.jpg", pixel_type="RGB32")

function make_backdrop(string name) {
    c = BlankClip(width=320, height=240, fps=30, length=150, color=$FF000080)
    # Create upper bound marker
    c = c.Layer(BlankClip(width=320, height=1, fps=30, length=150, color=$FFCCCCCC), op="add", x=0, y=50)
    # Create lower bound marker
    c = c.Layer(BlankClip(width=320, height=1, fps=30, length=150, color=$FFCCCCCC), op="add", x=0, y=190)
    return c.Subtitle(name, x=160, y=240, align=2)
}

# Examples of EaseIns
exampleIn = BlankClip(width=1280, height=720, fps=30, length=150, color=$000080)

# EaseInLinear

function anim_EaseInLinear(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInLinear(p)*140)+48)
}
example_EaseInLinear = make_backdrop("EaseInLinear") \
    .Animate(0, 149, "anim_EaseInLinear", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInLinear, op="add", x=0, y=0)

# EaseInQuad

function anim_EaseInQuad(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInQuad(p)*140)+48)
}
example_EaseInQuad = make_backdrop("EaseInQuad") \
    .Animate(0, 149, "anim_EaseInQuad", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInQuad, op="add", x=320, y=0)

# EaseInCubic

function anim_EaseInCubic(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInCubic(p)*140)+48)
}
example_EaseInCubic = make_backdrop("EaseInCubic") \
    .Animate(0, 149, "anim_EaseInCubic", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInCubic, op="add", x=640, y=0)

# EaseInQuart

function anim_EaseInQuart(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInQuart(p)*140)+48)
}
example_EaseInQuart = make_backdrop("EaseInQuart") \
    .Animate(0, 149, "anim_EaseInQuart", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInQuart, op="add", x=960, y=0)

# EaseInQuint

function anim_EaseInQuint(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInQuint(p)*140)+48)
}
example_EaseInQuint = make_backdrop("EaseInQuint") \
    .Animate(0, 149, "anim_EaseInQuint", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInQuint, op="add", x=0, y=240)

# EaseInExpo

function anim_EaseInExpo(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInExpo(p)*140)+48)
}
example_EaseInExpo = make_backdrop("EaseInExpo") \
    .Animate(0, 149, "anim_EaseInExpo", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInExpo, op="add", x=320, y=240)

# EaseInSine

function anim_EaseInSine(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInSine(p)*140)+48)
}
example_EaseInSine = make_backdrop("EaseInSine") \
    .Animate(0, 149, "anim_EaseInSine", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInSine, op="add", x=640, y=240)

# EaseInCirc

function anim_EaseInCirc(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInCirc(p)*140)+48)
}
example_EaseInCirc = make_backdrop("EaseInCirc") \
    .Animate(0, 149, "anim_EaseInCirc", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInCirc, op="add", x=960, y=240)

# EaseInElastic

function anim_EaseInElastic(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInElastic(p)*140)+48)
}
example_EaseInElastic = make_backdrop("EaseInElastic") \
    .Animate(0, 149, "anim_EaseInElastic", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInElastic, op="add", x=0, y=480)

# EaseInBack

function anim_EaseInBack(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInBack(p)*140)+48)
}
example_EaseInBack = make_backdrop("EaseInBack") \
    .Animate(0, 149, "anim_EaseInBack", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInBack, op="add", x=320, y=480)

# EaseInBounce

function anim_EaseInBounce(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInBounce(p)*140)+48)
}
example_EaseInBounce = make_backdrop("EaseInBounce") \
    .Animate(0, 149, "anim_EaseInBounce", 0.0, 1.0)
exampleIn = exampleIn.Layer(example_EaseInBounce, op="add", x=640, y=480)
# Examples of EaseOuts
exampleOut = BlankClip(width=1280, height=720, fps=30, length=150, color=$000080)

# EaseOutLinear

function anim_EaseOutLinear(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutLinear(p)*140)+48)
}
example_EaseOutLinear = make_backdrop("EaseOutLinear") \
    .Animate(0, 149, "anim_EaseOutLinear", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutLinear, op="add", x=0, y=0)

# EaseOutQuad

function anim_EaseOutQuad(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutQuad(p)*140)+48)
}
example_EaseOutQuad = make_backdrop("EaseOutQuad") \
    .Animate(0, 149, "anim_EaseOutQuad", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutQuad, op="add", x=320, y=0)

# EaseOutCubic

function anim_EaseOutCubic(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutCubic(p)*140)+48)
}
example_EaseOutCubic = make_backdrop("EaseOutCubic") \
    .Animate(0, 149, "anim_EaseOutCubic", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutCubic, op="add", x=640, y=0)

# EaseOutQuart

function anim_EaseOutQuart(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutQuart(p)*140)+48)
}
example_EaseOutQuart = make_backdrop("EaseOutQuart") \
    .Animate(0, 149, "anim_EaseOutQuart", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutQuart, op="add", x=960, y=0)

# EaseOutQuint

function anim_EaseOutQuint(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutQuint(p)*140)+48)
}
example_EaseOutQuint = make_backdrop("EaseOutQuint") \
    .Animate(0, 149, "anim_EaseOutQuint", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutQuint, op="add", x=0, y=240)

# EaseOutExpo

function anim_EaseOutExpo(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutExpo(p)*140)+48)
}
example_EaseOutExpo = make_backdrop("EaseOutExpo") \
    .Animate(0, 149, "anim_EaseOutExpo", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutExpo, op="add", x=320, y=240)

# EaseOutSine

function anim_EaseOutSine(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutSine(p)*140)+48)
}
example_EaseOutSine = make_backdrop("EaseOutSine") \
    .Animate(0, 149, "anim_EaseOutSine", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutSine, op="add", x=640, y=240)

# EaseOutCirc

function anim_EaseOutCirc(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutCirc(p)*140)+48)
}
example_EaseOutCirc = make_backdrop("EaseOutCirc") \
    .Animate(0, 149, "anim_EaseOutCirc", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutCirc, op="add", x=960, y=240)

# EaseOutElastic

function anim_EaseOutElastic(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutElastic(p)*140)+48)
}
example_EaseOutElastic = make_backdrop("EaseOutElastic") \
    .Animate(0, 149, "anim_EaseOutElastic", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutElastic, op="add", x=0, y=480)

# EaseOutBack

function anim_EaseOutBack(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutBack(p)*140)+48)
}
example_EaseOutBack = make_backdrop("EaseOutBack") \
    .Animate(0, 149, "anim_EaseOutBack", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutBack, op="add", x=320, y=480)

# EaseOutBounce

function anim_EaseOutBounce(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseOutBounce(p)*140)+48)
}
example_EaseOutBounce = make_backdrop("EaseOutBounce") \
    .Animate(0, 149, "anim_EaseOutBounce", 0.0, 1.0)
exampleOut = exampleOut.Layer(example_EaseOutBounce, op="add", x=640, y=480)
# Examples of EaseInOuts
exampleInOut = BlankClip(width=1280, height=720, fps=30, length=150, color=$000080)

# EaseInOutLinear

function anim_EaseInOutLinear(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutLinear(p)*140)+48)
}
example_EaseInOutLinear = make_backdrop("EaseInOutLinear") \
    .Animate(0, 149, "anim_EaseInOutLinear", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutLinear, op="add", x=0, y=0)

# EaseInOutQuad

function anim_EaseInOutQuad(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutQuad(p)*140)+48)
}
example_EaseInOutQuad = make_backdrop("EaseInOutQuad") \
    .Animate(0, 149, "anim_EaseInOutQuad", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutQuad, op="add", x=320, y=0)

# EaseInOutCubic

function anim_EaseInOutCubic(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutCubic(p)*140)+48)
}
example_EaseInOutCubic = make_backdrop("EaseInOutCubic") \
    .Animate(0, 149, "anim_EaseInOutCubic", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutCubic, op="add", x=640, y=0)

# EaseInOutQuart

function anim_EaseInOutQuart(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutQuart(p)*140)+48)
}
example_EaseInOutQuart = make_backdrop("EaseInOutQuart") \
    .Animate(0, 149, "anim_EaseInOutQuart", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutQuart, op="add", x=960, y=0)

# EaseInOutQuint

function anim_EaseInOutQuint(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutQuint(p)*140)+48)
}
example_EaseInOutQuint = make_backdrop("EaseInOutQuint") \
    .Animate(0, 149, "anim_EaseInOutQuint", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutQuint, op="add", x=0, y=240)

# EaseInOutExpo

function anim_EaseInOutExpo(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutExpo(p)*140)+48)
}
example_EaseInOutExpo = make_backdrop("EaseInOutExpo") \
    .Animate(0, 149, "anim_EaseInOutExpo", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutExpo, op="add", x=320, y=240)

# EaseInOutSine

function anim_EaseInOutSine(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutSine(p)*140)+48)
}
example_EaseInOutSine = make_backdrop("EaseInOutSine") \
    .Animate(0, 149, "anim_EaseInOutSine", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutSine, op="add", x=640, y=240)

# EaseInOutCirc

function anim_EaseInOutCirc(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutCirc(p)*140)+48)
}
example_EaseInOutCirc = make_backdrop("EaseInOutCirc") \
    .Animate(0, 149, "anim_EaseInOutCirc", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutCirc, op="add", x=960, y=240)

# EaseInOutElastic

function anim_EaseInOutElastic(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutElastic(p)*140)+48)
}
example_EaseInOutElastic = make_backdrop("EaseInOutElastic") \
    .Animate(0, 149, "anim_EaseInOutElastic", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutElastic, op="add", x=0, y=480)

# EaseInOutBack

function anim_EaseInOutBack(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutBack(p)*140)+48)
}
example_EaseInOutBack = make_backdrop("EaseInOutBack") \
    .Animate(0, 149, "anim_EaseInOutBack", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutBack, op="add", x=320, y=480)

# EaseInOutBounce

function anim_EaseInOutBounce(clip c, float p) {
    return c.Layer(dot, op="add", x=Floor(p*314)+1, y=Floor(EaseInOutBounce(p)*140)+48)
}
example_EaseInOutBounce = make_backdrop("EaseInOutBounce") \
    .Animate(0, 149, "anim_EaseInOutBounce", 0.0, 1.0)
exampleInOut = exampleInOut.Layer(example_EaseInOutBounce, op="add", x=640, y=480)
# Examples of EaseIns done as fades
example_fadeIn = BlankClip(width=1280, height=720, fps=30, length=150, color=$000080)

# EaseInLinear

function anim_FadeEaseInLinear(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInLinear(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInLinear = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInLinear", 0.0, 1.0) \
    .Subtitle("EaseInLinear", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInLinear, op="add", x=0, y=0)

# EaseInQuad

function anim_FadeEaseInQuad(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInQuad(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInQuad = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInQuad", 0.0, 1.0) \
    .Subtitle("EaseInQuad", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInQuad, op="add", x=320, y=0)

# EaseInCubic

function anim_FadeEaseInCubic(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInCubic(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInCubic = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInCubic", 0.0, 1.0) \
    .Subtitle("EaseInCubic", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInCubic, op="add", x=640, y=0)

# EaseInQuart

function anim_FadeEaseInQuart(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInQuart(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInQuart = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInQuart", 0.0, 1.0) \
    .Subtitle("EaseInQuart", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInQuart, op="add", x=960, y=0)

# EaseInQuint

function anim_FadeEaseInQuint(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInQuint(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInQuint = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInQuint", 0.0, 1.0) \
    .Subtitle("EaseInQuint", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInQuint, op="add", x=0, y=240)

# EaseInExpo

function anim_FadeEaseInExpo(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInExpo(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInExpo = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInExpo", 0.0, 1.0) \
    .Subtitle("EaseInExpo", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInExpo, op="add", x=320, y=240)

# EaseInSine

function anim_FadeEaseInSine(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInSine(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInSine = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInSine", 0.0, 1.0) \
    .Subtitle("EaseInSine", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInSine, op="add", x=640, y=240)

# EaseInCirc

function anim_FadeEaseInCirc(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInCirc(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInCirc = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInCirc", 0.0, 1.0) \
    .Subtitle("EaseInCirc", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInCirc, op="add", x=960, y=240)

# EaseInElastic

function anim_FadeEaseInElastic(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInElastic(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInElastic = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInElastic", 0.0, 1.0) \
    .Subtitle("EaseInElastic", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInElastic, op="add", x=0, y=480)

# EaseInBack

function anim_FadeEaseInBack(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInBack(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInBack = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInBack", 0.0, 1.0) \
    .Subtitle("EaseInBack", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInBack, op="add", x=320, y=480)

# EaseInBounce

function anim_FadeEaseInBounce(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInBounce(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInBounce = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInBounce", 0.0, 1.0) \
    .Subtitle("EaseInBounce", x=160, y=240, align=2)
example_fadeIn = example_fadeIn.Layer(example_FadeEaseInBounce, op="add", x=640, y=480)
# Examples of EaseOuts done as fades
example_fadeOut = BlankClip(width=1280, height=720, fps=30, length=150, color=$000080)

# EaseOutLinear

function anim_FadeEaseOutLinear(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutLinear(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutLinear = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutLinear", 0.0, 1.0) \
    .Subtitle("EaseOutLinear", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutLinear, op="add", x=0, y=0)

# EaseOutQuad

function anim_FadeEaseOutQuad(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutQuad(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutQuad = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutQuad", 0.0, 1.0) \
    .Subtitle("EaseOutQuad", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutQuad, op="add", x=320, y=0)

# EaseOutCubic

function anim_FadeEaseOutCubic(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutCubic(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutCubic = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutCubic", 0.0, 1.0) \
    .Subtitle("EaseOutCubic", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutCubic, op="add", x=640, y=0)

# EaseOutQuart

function anim_FadeEaseOutQuart(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutQuart(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutQuart = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutQuart", 0.0, 1.0) \
    .Subtitle("EaseOutQuart", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutQuart, op="add", x=960, y=0)

# EaseOutQuint

function anim_FadeEaseOutQuint(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutQuint(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutQuint = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutQuint", 0.0, 1.0) \
    .Subtitle("EaseOutQuint", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutQuint, op="add", x=0, y=240)

# EaseOutExpo

function anim_FadeEaseOutExpo(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutExpo(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutExpo = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutExpo", 0.0, 1.0) \
    .Subtitle("EaseOutExpo", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutExpo, op="add", x=320, y=240)

# EaseOutSine

function anim_FadeEaseOutSine(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutSine(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutSine = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutSine", 0.0, 1.0) \
    .Subtitle("EaseOutSine", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutSine, op="add", x=640, y=240)

# EaseOutCirc

function anim_FadeEaseOutCirc(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutCirc(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutCirc = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutCirc", 0.0, 1.0) \
    .Subtitle("EaseOutCirc", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutCirc, op="add", x=960, y=240)

# EaseOutElastic

function anim_FadeEaseOutElastic(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutElastic(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutElastic = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutElastic", 0.0, 1.0) \
    .Subtitle("EaseOutElastic", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutElastic, op="add", x=0, y=480)

# EaseOutBack

function anim_FadeEaseOutBack(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutBack(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutBack = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutBack", 0.0, 1.0) \
    .Subtitle("EaseOutBack", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutBack, op="add", x=320, y=480)

# EaseOutBounce

function anim_FadeEaseOutBounce(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseOutBounce(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseOutBounce = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseOutBounce", 0.0, 1.0) \
    .Subtitle("EaseOutBounce", x=160, y=240, align=2)
example_fadeOut = example_fadeOut.Layer(example_FadeEaseOutBounce, op="add", x=640, y=480)
# Examples of EaseInOuts done as fades
example_fadeInOut = BlankClip(width=1280, height=720, fps=30, length=150, color=$000080)

# EaseInOutLinear

function anim_FadeEaseInOutLinear(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutLinear(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutLinear = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutLinear", 0.0, 1.0) \
    .Subtitle("EaseInOutLinear", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutLinear, op="add", x=0, y=0)

# EaseInOutQuad

function anim_FadeEaseInOutQuad(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutQuad(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutQuad = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutQuad", 0.0, 1.0) \
    .Subtitle("EaseInOutQuad", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutQuad, op="add", x=320, y=0)

# EaseInOutCubic

function anim_FadeEaseInOutCubic(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutCubic(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutCubic = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutCubic", 0.0, 1.0) \
    .Subtitle("EaseInOutCubic", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutCubic, op="add", x=640, y=0)

# EaseInOutQuart

function anim_FadeEaseInOutQuart(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutQuart(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutQuart = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutQuart", 0.0, 1.0) \
    .Subtitle("EaseInOutQuart", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutQuart, op="add", x=960, y=0)

# EaseInOutQuint

function anim_FadeEaseInOutQuint(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutQuint(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutQuint = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutQuint", 0.0, 1.0) \
    .Subtitle("EaseInOutQuint", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutQuint, op="add", x=0, y=240)

# EaseInOutExpo

function anim_FadeEaseInOutExpo(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutExpo(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutExpo = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutExpo", 0.0, 1.0) \
    .Subtitle("EaseInOutExpo", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutExpo, op="add", x=320, y=240)

# EaseInOutSine

function anim_FadeEaseInOutSine(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutSine(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutSine = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutSine", 0.0, 1.0) \
    .Subtitle("EaseInOutSine", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutSine, op="add", x=640, y=240)

# EaseInOutCirc

function anim_FadeEaseInOutCirc(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutCirc(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutCirc = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutCirc", 0.0, 1.0) \
    .Subtitle("EaseInOutCirc", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutCirc, op="add", x=960, y=240)

# EaseInOutElastic

function anim_FadeEaseInOutElastic(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutElastic(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutElastic = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutElastic", 0.0, 1.0) \
    .Subtitle("EaseInOutElastic", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutElastic, op="add", x=0, y=480)

# EaseInOutBack

function anim_FadeEaseInOutBack(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutBack(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutBack = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutBack", 0.0, 1.0) \
    .Subtitle("EaseInOutBack", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutBack, op="add", x=320, y=480)

# EaseInOutBounce

function anim_FadeEaseInOutBounce(clip c, float p) {
    a = Floor(Max(0.0, Min(1.0, EaseInOutBounce(p)))*255)
    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)
}
example_FadeEaseInOutBounce = BlankClip(width=320, height=240, fps=30, length=150) \
    .Animate(0, 149, "anim_FadeEaseInOutBounce", 0.0, 1.0) \
    .Subtitle("EaseInOutBounce", x=160, y=240, align=2)
example_fadeInOut = example_fadeInOut.Layer(example_FadeEaseInOutBounce, op="add", x=640, y=480)

exampleIn ++ exampleOut ++ exampleInOut ++ example_fadeIn ++ example_fadeOut ++ example_fadeInOut
