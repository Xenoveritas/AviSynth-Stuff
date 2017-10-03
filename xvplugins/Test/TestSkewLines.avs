LoadPlugin("..\Release\xvplugins.dll")

sample = ImageSource("..\..\Examples\shoreline.jpg", pixel_type="RGB32")

function skew(int frame, int y) {
  return Sin(frame + (y/2)) * 4
}

sample
SkewLines("skew")
