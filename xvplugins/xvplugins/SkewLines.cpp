#include "stdafx.h"
#include "SkewLines.h"

#include <iostream>

using namespace std;

SkewLines::SkewLines(PClip source, const char* f, IScriptEnvironment* env)
	: GenericVideoFilter(source) {
	// We currently only work with RGB32 images. (In fact, this will ONLY work for interleaved images.)
	if (!vi.IsRGB32()) {
		env->ThrowError("Colorspace must be RGB32");
	}
	// Make sure that the function exists and can be called.
	if (!env->FunctionExists(f)) {
		env->ThrowError("Missing function \"%s\"", f);
	}
	// See if we can invoke the function.
	AVSValue args[2] = { 0, 0 };
	AVSValue result = env->Invoke(f, AVSValue(args, 2));
	if (!result.IsFloat()) {
		// Float counts as both an integer and float. Floats are rounded to ints, but allowed anyway.
		env->ThrowError("Bad result from %s", f);
	}
	rsize_t length = strlen(f) + 1;
	function = new char[length];
	strcpy_s(function, length, f);
}

SkewLines::~SkewLines() {
	delete function;
	function = NULL;
}

// Eventually this might be converted to a local variable so that this will
// also work with RGB24 or could be made to work on each individual plane,
// but ... meh.
#define BYTES_PER_PIXEL 4

PVideoFrame __stdcall SkewLines::GetFrame(int n, IScriptEnvironment* env) {
	// This works by selectively copying lines from the old frame onto a new frame.
	PVideoFrame dest = env->NewVideoFrame(vi);
	PVideoFrame src = child->GetFrame(n, env);
	AVSValue args[2] = { n, 0 };
	const BYTE* srcPtr = src->GetReadPtr();
	BYTE* destPtr = dest->GetWritePtr();
	int srcPitch = src->GetPitch();
	int destPitch = dest->GetPitch();
	for (int line = 0; line < vi.height; line++) {
		// Get the skew for this line.
		args[1] = line;
		AVSValue result = env->Invoke(function, AVSValue(args, 2));
		int skew = result.IsInt() ? result.AsInt() : (int) (result.AsFloat() + 0.5);
		// The skew should wrap around:
		skew %= vi.width;
		if (skew == 0) {
			// In this case, we just copy a single line.
			memcpy(destPtr, srcPtr, vi.width * BYTES_PER_PIXEL);
		}
		else {
			// Otherwise we actually have to do something.
			int remaining;
			if (skew < 0) {
				// If the skew is negative, this should move left. Thankfully
				// moving left is the same as moving right (width - |skew|).
				remaining = -skew;
				// Remember that skew is negative so we're effectively subtracting
				skew = vi.width + skew;
			}
			else {
				remaining = vi.width - skew;
			}
			// First: copy the start of the line, skewed over by skew pixels in
			// the destination (so positive values move the start of the line
			// right).
			memcpy(destPtr + (skew * BYTES_PER_PIXEL), srcPtr, remaining * BYTES_PER_PIXEL);
			// With that copied over, copy the remaining (width - remaining) pixels, which
			// is the same as skew as skew + remaining = width.
			memcpy(destPtr, srcPtr + (remaining * BYTES_PER_PIXEL), skew * BYTES_PER_PIXEL);
		}
		// In either case, advance to the next line
		srcPtr += srcPitch;
		destPtr += destPitch;
	}
	return dest;
}

AVSValue __cdecl Create_SkewLines(AVSValue args, void* user_data, IScriptEnvironment* env) {
	// Args are: cs
	return new SkewLines(args[0].AsClip(), args[1].AsString(), env);
}
