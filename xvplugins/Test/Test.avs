LoadPlugin("..\Release\xvplugins.dll")

font = ImageSource("boxy_bold_fixed.png", pixel_type="RGB32")

text = ImageText(font, "Test\nMultiline\n:)", multiline=true)
text_swapped = PaletteSwap(text, "ffffff>ffff00; 000000>808000")

# 60, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900
counter = Counter(Crop(font, 0, 8, 80, 8), 60, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020, 1080, 1140, 1200, 1260, 1320, 1380, 1440, 1500)
counter2 = CounterStr(Crop(font, 0, 8, 80, 8), pad_zero=false, show_zero=false, "60, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020, 1080, 1140, 1200, 1260, 1320, 1380, 1440, 1500")

#return text
#return MessageClip("Test: width=" + String(text.Width()) + ", height=" + String(text.Height()))
Layer(BlankClip(color=$FF808080, fps=30, length=1560), text)
Layer(text_swapped, x=128, y=4)
Layer(counter, x=0, y=64)
Layer(counter2, x=0, y=72)
Layer(Crop(font, 0, 8, 80, 8), x=0, y=96)
