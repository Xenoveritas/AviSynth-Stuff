#!/usr/bin/env node

// Screw AviSynth, let's build this file using a proper scripting language.

console.log('# Easings.avs');
console.log('#');
console.log('# This is a generated file. Use:');
console.log('#   node Easings.js > Easings.avs');
console.log('# to generate this file.');
console.log('#');
console.log('# These examples may still prove useful but this file is mostly intended to show');
console.log('# what the easings do.');
console.log();
console.log('Import("..\\Easings.avsi")');
console.log();

var easings = [
    'Linear', 'Quad', 'Cubic', 'Quart', 'Quint', 'Expo', 'Sine', 'Circ', 'Elastic', 'Back', 'Bounce'
];
var types = [ 'In', 'Out', 'InOut' ];

var width = 320, height = 240;
var dotWidth = 5, dotHeight = 5, dotX = (dotWidth-1)/2, dotY = (dotHeight-1)/2;
var upperBound = 50;
var leftBound = dotX+1;
var rightBound = width - leftBound;
var horizRange = rightBound - leftBound;
var lowerBound = height - upperBound;
var vertRange = lowerBound - upperBound;
var fps = 30;
var frames = 30*5;

var totalWidth = 1280;
var totalHeight = Math.ceil(easings.length / (totalWidth / width)) * height;

console.log('global dot = BlankClip(%d, %d, %d, color=$FFFF0000)', frames, dotWidth, dotHeight);
console.log('global fade_from = ImageSource("foggy.jpg", pixel_type="RGB32")');
console.log('global fade_to = ImageSource("shoreline.jpg", pixel_type="RGB32")');
console.log();
console.log('function make_backdrop(string name) {');
console.log('    c = BlankClip(width=%d, height=%d, fps=%d, length=%d, color=$FF000080)', width, height, fps, frames);
console.log('    # Create upper bound marker')
console.log('    c = c.Layer(BlankClip(width=%d, height=1, fps=%d, length=%d, color=$FFCCCCCC), op="add", x=0, y=%d)', width, fps, frames, upperBound);
console.log('    # Create lower bound marker')
console.log('    c = c.Layer(BlankClip(width=%d, height=1, fps=%d, length=%d, color=$FFCCCCCC), op="add", x=0, y=%d)', width, fps, frames, lowerBound);
console.log('    return c.Subtitle(name, x=%d, y=%d, align=2)', width/2, height);
console.log('}');
console.log();

// Create moving dot examples for all types and eases
types.forEach(function(type) {
    console.log('# Examples of Ease%ss', type);
    console.log('example%s = BlankClip(width=%d, height=%d, fps=%d, length=%d, color=$000080)', type, totalWidth, totalHeight, fps, frames);
    var x = 0, y = 0;
    easings.forEach(function(e) {
        console.log();
        console.log('# Ease%s%s', type, e);
        console.log();
        console.log('function anim_Ease%s%s(clip c, float p) {', type, e);
        console.log('    return c.Layer(dot, op="add", x=Floor(p*%d)+%d, y=Floor(Ease%s%s(p)*%d)+%d)', horizRange, leftBound-dotX, type, e, vertRange, upperBound - dotY);
        console.log('}');
        console.log('example_Ease%s%s = make_backdrop("Ease%s%s") \\', type, e, type, e);
        console.log('    .Animate(0, %d, "anim_Ease%s%s", 0.0, 1.0)', frames-1, type, e);
        console.log('example%s = example%s.Layer(example_Ease%s%s, op="add", x=%d, y=%d)', type, type, type, e, x, y);
        x += width;
        if (x >= totalWidth) {
            x = 0;
            y += height;
        }
    });
});
types.forEach(function(type) {
    console.log('# Examples of Ease%ss done as fades', type);
    console.log('example_fade%s = BlankClip(width=%d, height=%d, fps=%d, length=%d, color=$000080)', type, totalWidth, totalHeight, fps, frames);
    var x = 0, y = 0;
    easings.forEach(function(e) {
        console.log();
        console.log('# Ease%s%s', type, e);
        console.log();
        console.log('function anim_FadeEase%s%s(clip c, float p) {', type, e);
        console.log('    a = Floor(Max(0.0, Min(1.0, Ease%s%s(p)))*255)', type, e);
        console.log('    return c.Layer(Layer(fade_from, fade_to, op="add", level=a), op="add", x=0, y=0)');
        console.log('}');
        console.log('example_FadeEase%s%s = BlankClip(width=%d, height=%d, fps=%d, length=%d) \\', type, e, width, height, fps, frames);
        console.log('    .Animate(0, %d, "anim_FadeEase%s%s", 0.0, 1.0) \\', frames-1, type, e);
        console.log('    .Subtitle("Ease%s%s", x=%d, y=%d, align=2)', type, e, width/2, height);
        console.log('example_fade%s = example_fade%s.Layer(example_FadeEase%s%s, op="add", x=%d, y=%d)', type, type, type, e, x, y);
        x += width;
        if (x >= totalWidth) {
            x = 0;
            y += height;
        }
    });
});

console.log();
console.log(types.map(function(t) { return "example" + t; }).join(' ++ ') + ' ++ ' +
    types.map(function(t) { return "example_fade" + t; }).join(' ++ '));
