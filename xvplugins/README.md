xvplugins
=========

This is simply a bunch of AviSynth stuff that isn't (really) possible using
plain AviSynth and instead required a plugin.

It may prove useful to some people and is presented here in source form.

To test the plugin, use the files in the Test directory.

Building
--------

You'll need to have Visual Studio 2012 Express (or, I'd assume, the pro
versions, which I don't have) installed. Then simply open the solution and build
for release.

Alternatively, from the Developer Command Prompt, you can use `MSBUILD` to build
the solution:

    msbuild xvplugins.sln /p:Configuration=Release

With the plugin built, you can check out the test directory to test it out. The
tests script itself is intended to be run via [VirtualDub](http://www.virtualdub.org/)
and will require that to be installed.

Plugin Functions
----------------

The plugin includes the following AviSynth functions:

### ImageText

`ImageText(clip font, string text, int "rows", int "cols", string "unimplemented", boolean "multiline")`

Take an image from `font` and generate a new clip from it that contains the same
number of frames, rendering the given text `text` using the `font`.

* `font` - the clip to use
* `text` - the text to render
* `rows` - the number of rows of text in the clip (default: 0)
* `cols` - the number of columns of text in the clip (default: 16)
* `unimplemented` - ignore this for now :)
* `multiline` - when true, the `\n` escape sequence in `text` will produce
newlines in the output image.

### PaletteSwap

`PaletteSwap(clip c, string palette)`

Swaps colors in the input clip based on the palette definition.

### Counter

`Counter(clip numbers, int frames..., boolean "pad_zero", boolean "show_zero", int "spin_time")`

Creates a counter that counts up on each given input frame.

### CounterStr

`CounterStr(clip numbers, string frames, boolean "pad_zero", boolean "show_zero", int "spin_time")`

Same as above, but uses a string of comma-separated numbers to define the frames.