#include "stdafx.h"
#include "Counter.h"

#include <algorithm>
#include <iostream>
#include <stdio.h>

using namespace std;

// Since we only deal with RGBA, this is always 4. This is used more to make
// the code readable than anything else, as the only other format I'm ever
// likely to bother supporting is YUY2.
#define BYTES_PER_PIXEL		4

class CounterPainter {
public:
	CounterPainter(PVideoFrame src, VideoFrame* dest, int digit_width, IScriptEnvironment* env);
	void drawDigit(int digit, int x, int y);
	void blankArea(int x, int y, int w, int h);
private:
	// Source pointer.
	const BYTE* src_p;
	// Destination pointer.
	BYTE* dst_p;
	// And the pitches.
	const int src_pitch;
	const int dst_pitch;
	// And the source height:
	const int src_height;
	// And our height
	const int dst_height;
	const int digit_width;
	IScriptEnvironment* env;
};

CounterPainter::CounterPainter(PVideoFrame src, VideoFrame* dest, int aDigitWidth, IScriptEnvironment* aEnv) :
		src_p(src->GetReadPtr()), dst_p(dest->GetWritePtr()),
		src_pitch(src->GetPitch()), dst_pitch(dest->GetPitch()),
		src_height(src->GetHeight()), dst_height(dest->GetHeight()),
		digit_width(aDigitWidth), env(aEnv) {
	//printf("srcp=%p, %d per row, %d high\ndstp=%p, %d per row, %d high\n", src_p, src_pitch, src_height, dst_p, dst_pitch, dst_height);
	// And everything is done by intializer statements.
}

void CounterPainter::drawDigit(int digit, int x, int y) {
	// This copies a chunk out of the digits (src) array, and places them in the dst.
	// So start by assuming we have a complete digit.
	int dx = digit * digit_width;
	int dy = 0;
	int dh = src_height;
	// Figure out how much of this we can actually draw, since we don't want to clip off the top/off the bottom.
	if (y > 0) {
		// Clipped off the top, keep dy at 0, but only draw part of the digit
		dh -= y;
	} else if (y < 0) {
		// Clipped off the bottom, so we need to adjust both dy and height
		dy -= y;
		// Note that y is negative, so if y is -4, we want to subtract 4 off the height, so height + (-4) = height - 4.
		dh += y;
		// And reset y to 0
		y = 0;
	}
	//cout << "Render digit " << digit << " to " << x << ", " << y << " [" << digit_width << "x" << dst_height << "] from " << dx << ", " << dy << " [" << digit_width << "x" << dh << "]" << endl;
	// OK, now for the actual copy.
	//env->BitBlt(dst_p, dst_pitch, src_p+64, src_pitch, digit_width, dst_height);
	env->BitBlt(dst_p + (y * dst_pitch) + (x * BYTES_PER_PIXEL), dst_pitch, src_p + (dy * src_pitch) + (dx * BYTES_PER_PIXEL), src_pitch, digit_width*BYTES_PER_PIXEL, dh);
}

void CounterPainter::blankArea(int x, int y, int w, int h) {
	//cout << "Blank " << x << ", " << y << " [" << w << "x" << h << "]" << endl;
	BYTE* dp = dst_p + (dst_pitch * y) + (x * BYTES_PER_PIXEL);
	for (; h > 0; h--) {
		memset(dp, 0, w*BYTES_PER_PIXEL);
		dp += dst_pitch;
	}
}

// Is there seriously no built-in integer comparator?
int int_cmp (const void* a, const void* b) {
	return *(int*)a - *(int*)b;
}

Counter::Counter(PClip source, int aSpinTime, unsigned int aBounce, unsigned int* aCounts, size_t aLength, bool aShowZero, bool aPadZero, IScriptEnvironment* env)
	: GenericVideoFilter(source),
	counts(aCounts, aCounts + aLength),
	showZero(aShowZero),
	padZero(aPadZero),
	spinTime(aSpinTime),
	bounce(aBounce),
	lastFrame(-1) {
	// We currently only work with RGB32 images
	if (!vi.IsRGB32()) {
		env->ThrowError("Source colorspace must be RGB32");
	}
	if (aLength == 0) {
		env->ThrowError("Cowardly refusing to create a null filter");
	}
	// showZero only makes sense as false if padZero is false
	if (!showZero && padZero)
		showZero = true;
	// Sort the counts
	sort(counts.begin(), counts.end());
	cout << "Counter, spin time=" << spinTime;
	cout << ", pad=" << padZero << ", show zero=" << showZero << ", frames:";
	for (vector<unsigned int>::iterator it = counts.begin(); it != counts.end(); it++) {
		cout << " " << *it;
	}
	cout << endl;
	int max_count = counts.size();
	cout << "Total counts is " << max_count;
	// Now we need to count the number of digits in max_count.
	int digits = 0;
	for (; max_count > 0; max_count /= 10, digits++) ;
	cout << " which is " << digits << " digits wide." << endl;
	digitWidth = vi.width / 10;
	vi.width = digits * digitWidth;
	vi.num_frames = *(counts.end()-1) + spinTime + 1;
	cout << "Requires " << vi.num_frames << " to render." << endl;
}

Counter::~Counter() {
	// We actually don't need to delete the video frame, because it'll automatically go out of scope.
}

PVideoFrame __stdcall Counter::GetFrame(int n, IScriptEnvironment* env) {
	vector<unsigned int>::iterator cur_count = lower_bound(counts.begin(), counts.end(), (unsigned int) n);
	// See where that puts us
	int count = cur_count - counts.begin();
	unsigned int previous = 0;
	if (count > 0) {
		// We want to know when we changed to this count, which is the value of the PREVIOUS entry.
		previous = *(cur_count - 1);
	}
	PVideoFrame dest = env->NewVideoFrame(vi);
	if (count == 0 && !showZero) {
		BYTE* dst_p = dest->GetWritePtr();
		int dst_pitch = dest->GetPitch();
		int width = dest->GetRowSize();
		// We're already done already (count will be 1 when we spin it up)
		// But we do need to blank the clip.
		for (int i = 0; i < vi.height; i++) {
			memset(dst_p, 0, width);
			dst_p += dst_pitch;
		}
		return dest;
	}
	PVideoFrame src = child->GetFrame(n, env);
	// Once the dest frame refcount goes above 1, trying to get the write pointer gets NULL, so pass-by-ref instead.
	// Which looks really strange, but it works, so whatever.
	CounterPainter p = CounterPainter(src, dest.operator->(), digitWidth, env);
	// Get ready to draw digits.
	int x = vi.width - digitWidth;
	int d;
	// See if we're spinning
	int spin = n - previous;
	if (count > 0 && spin < spinTime) {
		// If we are, we want to draw two digits - the last one and the current one.
		spin = spin * (vi.height - 1) / spinTime + 1;
		//cout << "Frame " << n << " - spinning (y=" << spin << ")."  << endl;
		// This is more complicated, since we need to "spin" to the new one.
		int oldCount = count-1;
		if (!showZero && oldCount == 0) {
			// Special case: just draw the current one.
			d = count % 10;
			count /= 10;
			p.drawDigit(d, x, spin - vi.height);
			// And blank the lines above it
			p.blankArea(x, spin, digitWidth, vi.height - spin);
			// Then fall through to work as normal.
			x -= digitWidth;
		} else {
			for (; x >= 0; x -= digitWidth) {
				d = count % 10;
				count /= 10;
				int o_d = oldCount % 10;
				oldCount /= 10;
				if (d == o_d) {
					// This digit didn't change, so just draw it as-is.
					p.drawDigit(d, x, 0);
				} else {
					// Otherwise, it did, so first draw the old digit.
					// Special case: we're not padding with zeros
					if (!padZero && oldCount == 0 && o_d == 0) {
						p.blankArea(x, spin, digitWidth, vi.height - spin);
					} else {
						p.drawDigit(o_d, x, spin);
					}
					// And then draw the new digit
					p.drawDigit(d, x, spin - vi.height);
				}
				if (count == oldCount) {
					// The rest didn't change, so break and draw as normal below
					x -= digitWidth;
					break;
				}
			}
		}
	} else {
		// Always draw the first digit.
		d = count % 10;
		count /= 10;
		p.drawDigit(d, x, 0);
		x -= digitWidth;
	}
	// Draw whatever remains, or the entire thing if we never drew anything before this.
	for (; x >= 0; x -= digitWidth) {
		if (count == 0 && !padZero)
			break;
		d = count % 10;
		count /= 10;
		p.drawDigit(d, x, 0);
	}
	// Re-increment by digit width.
	x += digitWidth;
	if (x > 0) {
		// If there's remaining junk on the left, blank it
		p.blankArea(0, 0, vi.width - x, vi.height);
	}
	return dest;
}

AVSValue __cdecl Create_Counter(AVSValue args, void* user_data, IScriptEnvironment* env) {
	// Args are: ci+[PAD_ZEROES]b[SHOW_ZERO]b[SPIN_TIME]i
	unsigned int* counts;
	size_t length = args[1].ArraySize();
	counts = new unsigned int[length];
	for (size_t i = 0; i < length; i++) {
		counts[i] = args[1][i].AsInt();
	}
	bool pad_zero = args[2].AsBool(true);
	bool show_zero = args[3].AsBool(true);
	Counter* res = new Counter(args[0].AsClip(), args[4].AsInt(30), 0, counts, length, show_zero, pad_zero, env);
	// We need to delete this copy
	delete counts;
	return res;
}

enum FramesParseState {
	// Before a frame definition, counting whitespaced (accepting state)
	FP_BEFORE,
	// Defining a frame (, trans to FP_BEFORE; digit stays, WS trans to FP_AFTER_FRAME, accepting state)
	FP_FRAME,
	// Whitespace after a frame definition (accepting state)
	FP_AFTER_FRAME
};

#define IS_WHITESPACE(c)		(c == ' ' || c == '\t' || c == '\r' || c == '\n')
#define IS_DIGIT(c)				(c >= '0' && c <= '9')
#define IS_FIELD_SEPARATOR(c)	(c == ',')

AVSValue __cdecl Create_CounterStr(AVSValue args, void* user_data, IScriptEnvironment* env) {
	// Args are: "cs[PAD_ZEROES]b[SHOW_ZERO]b[SPIN_TIME]i"
	// This is basically identical to Counter, except it takes a comma-separated string.
	// So grab that string first
	const char* str = args[1].AsString();
	size_t numFrames = 1;
	for (size_t i = 0; str[i] != '\0'; i++) {
		if (IS_FIELD_SEPARATOR(str[i])) {
			numFrames++;
		}
	}
	unsigned int* frames;
	frames = new unsigned int[numFrames];
	// Now, parse.
	size_t index = 0;
	int state = 0;
	unsigned int frame = 0;
	for (size_t i = 0; str[i] != '\0'; i++) {
		char c = str[i];
		switch (state) {
		case FP_BEFORE:
			if (IS_DIGIT(c)) {
				frame = (c - '0');
				state = FP_FRAME;
			} else if (IS_WHITESPACE(c)) {
				// Do nothing
			} else {
				env->ThrowError("Unexpected character in frames list, wanted frame number, got '%c'", c);
			}
			break;
		case FP_FRAME:
			if (IS_DIGIT(c)) {
				frame *= 10;
				frame += (c - '0');
			} else if (IS_WHITESPACE(c) || IS_FIELD_SEPARATOR(c)) {
				// Add this
				frames[index] = frame;
				index++;
				frame = 0;
				state = IS_FIELD_SEPARATOR(c) ? FP_BEFORE : FP_AFTER_FRAME;
			} else {
				env->ThrowError("Unexpected character in frames list, wanted digit, whitespace, or field separator, got '%c'", c);
			}
			break;
		case FP_AFTER_FRAME:
			if (IS_WHITESPACE(c)) {
				// Do nothing
			} else if (IS_FIELD_SEPARATOR(c)) {
				// Go back to FP_BEFORE
				state = FP_BEFORE;
			} else {
				env->ThrowError("Unexpected character in frames list, wanted whitespace or field separator, got '%c'", c);
			}
			break;
		default:
			env->ThrowError("In a bad state.");
		}
	}
	if (state == FP_FRAME) {
		// We ended while defining a frame, which is fine, just add it
		frames[index] = frame;
		index++;
	}
	bool pad_zero = args[2].AsBool(true);
	bool show_zero = args[3].AsBool(true);
	Counter* res = new Counter(args[0].AsClip(), args[4].AsInt(30), 0, frames, index, show_zero, pad_zero, env);
	// We need to delete this copy
	delete frames;
	return res;
}