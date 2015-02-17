# AviSynth Stuff

This is basically a collection of AviSynth scripts that I've written that may
prove useful to other people in the [Let's Play
subforum](http://forums.somethingawful.com/forumdisplay.php?forumid=191) on
Something Awful.

It may also prove useful to some other people. There's not a lot here right now.

Check out the `Examples` directory for examples of using some of the scripts.

## Plugins

`xvplugins` is simply a bunch of custom AviSynth stuff that proved impossible to
do directly in AviSynth that might be of some use to other people.

`AutoTrace`, on the other hand, takes [AutoTrace](http://autotrace.sourceforge.net/)
and horribly misuses it to resize videos.

## MastiDS.avsi

Something Awful poster Mastigophoran's DS library for creating videos of DS
games. Provides utilities for showing one or both of the DS's screens as well as
transitioning between various views. Check out the [usage guide](http://lpix.org/sslptest/index.php?id=10443)
for details on how to use it.

## Easings.avsi

A port of jQuery UI's port of [Robert Panning's easings](http://easings.net/).
Every easing shown at that site is supported as an AviSynth function that can
be called with a value from 0.0-1.0 and returns an appropriate value as shown
on the [easings.net](http://easings.net/) website. (Note that for some of the
easing functions, this value is actually outside the 0.0-1.0 range! A utility
function called "Clamp" can be used to clamp values into the 0.0-1.0 range for
cases where this doesn't make sense.)

## Timer.avsi

The `Timer.avsi` include that creates a timer. For an example of how to use it,
see the `Timer.avs` script in the `Examples` directory.

It creates a timer that counts up as the clip goes on. It's mainly useful for
running races, but may also be useful in instances where you want to display
how long something takes.

You could also just use the built-in `ShowTime` AviSynth function, but this can
be used to make something that looks somewhat nicer.

## LayerFadeIO.avsi

A function for fading another layer on top of a clip. Useful if you want to
overlay information on top of a base clip for a portion of the clip.

## SNESEffect.avsi

Provides a pixelation effect, similar to the effect a ton of SNES games use.

## Speed.avsi

Filters for speeding up a clip without adjusting the pitch of the sound.

## Transitions.avsi

Simple transitions from one clip to another.

## TASBlend.avsi

An implementation of the [TASBlend](http://tasvideos.org/EncodingGuide/TASBlend.html)
filter.

## Utilities.avsi

Various utility scripts that may or may not prove useful.

## avisynth.xml

An edit mode for [jEdit](http://www.jedit.org/). I also have a separate
[Atom language plugin](https://github.com/Xenoveritas/language-avisynth) for
anyone using the [Atom text editor](https://atom.io/).
