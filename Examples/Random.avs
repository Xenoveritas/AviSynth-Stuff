# It's kind of hard to show off randomness, but do it anyway:

Import("..\Random.avsi")

c = BlankClip()

function RandomSubtitle(clip c, int seed, int multiple) {
  s = seed * multiple
  SeedRandom(s)
  return c.Subtitle("Seed: " + String(s) + \
    "\n  NextRandomInteger(): " + String(NextRandomInteger()) + \
    "\n  Random(): " + String(Random()) + \
    "\n  RandomInteger(1,100): " + String(RandomInteger(1,100)), lsp=10)
}

c.Animate(0, c.FrameCount()-1, "RandomSubtitle", 0, 1, c.FrameCount()-1, 1) + \
c.Animate(0, c.FrameCount()-1, "RandomSubtitle", 0, 1077481576, c.FrameCount()-1, 1077481576)
