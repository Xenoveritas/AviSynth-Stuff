// ImageText.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "ImageText.h"
#include <iostream>

using namespace std;

ImageText::ImageText(PClip source, const char* str, unsigned int rows, unsigned int cols, bool translateEscapes, IScriptEnvironment* env) :
	GenericVideoFilter(source) {
	// We currently only work with RGB32 images
	if (!vi.IsRGB32()) {
		env->ThrowError("Source colorspace must be RGB32");
	}
	metrics = new ImageTextMetrics(vi.width, vi.height, ' ', '\x7F', rows, cols);
	size_t size = strlen(str) + 1;
	char* tmpText = new char[size];
	cout << "Create text \"" << str << "\", rows=" << rows << "; cols=" << cols << "; Translate escapes: " << (translateEscapes ? "yes" : "no") << endl;
	if (translateEscapes) {
		// OK, go through and remove escapes. This may shrink the string, but never grow it.
		char* dst = tmpText;
		for (size_t i = 0; i < size; i++) {
			char c = str[i];
			// No bounds checking is needed because C strings are null-terminated.
			if (c == '\\') {
				// Check the next character to decide what to do
				i++;
				c = str[i];
				switch (c) {
				case 'r':
					c = '\r';
					break;
				case 'n':
					c = '\n';
					break;
				case 't':
					c = '\t';
					break;
				default:
					// Just ignore, so move backwards so the next character gets processed as normal.
					i--;
					continue;
				}
			}
			*(dst) = c;
			dst++;
		}
		// cout << "Created new string: " << tmpText << endl;
	} else {
		// Otherwise, just copy!
		strcpy_s(tmpText, size, str);
		// cout << "Did nothing: " << tmpText << endl;
	}
	text = tmpText;
	// We need to change our video info to fit the text we're generating.
	vi.width = metrics->GetStringWidth(text);
	vi.height = metrics->GetStringHeight(text);
	//cout << "Created new image, [" << vi.width << "x" << vi.height << "]." << endl;
}

ImageText::~ImageText() {
	delete metrics;
	delete text;
	metrics = NULL;
	text = NULL;
}

PVideoFrame __stdcall ImageText::GetFrame(int n, IScriptEnvironment* env) {
	// Time to generate a frame.
	PVideoFrame src = child->GetFrame(n, env);
	PVideoFrame result = env->NewVideoFrame(vi);

	// Grab a read pointer from the source:
	const unsigned char* srcp = src->GetReadPtr();
	// And a write pointer to copy to:
	unsigned char* dstp = result->GetWritePtr();
	// And the pitches.
	const int src_pitch = src->GetPitch();
	const int dst_pitch = result->GetPitch();
	// And the source height:
	const int src_height = src->GetHeight();
	// And our height
	const int dst_height = result->GetHeight();

	// FIXME: Hard-coded for RGB32
	const int bpp = 4;

	char c;
	int d_y;
	int x, y, w, h;
	const int lineHeight = metrics->GetLineHeight();
	const int width = vi.width;
	int c_x = 0;
	int c_y2 = vi.height;
	int c_y = c_y2 - lineHeight;
	for (size_t i = 0; ; i++) {
		c = text[i];
		if (c == '\0')
			break;
		if (c == '\n') {
			// New line
			if (c_x < width) {
				// We need to finish filling the line
				for (d_y = c_y; d_y < c_y2; d_y++) {
					memset(dstp + (dst_pitch*d_y) + c_x*bpp, 0, (width-c_x)*bpp);
				}
			}
			c_x = 0;
			c_y2 = c_y;
			c_y -= lineHeight;
			// And move along
			continue;
		}
		// Otherwise, grab the text metrics
		ITRECT* rect = metrics->GetMetrics(c);
		if (rect == NULL)
			continue;
		x = rect->x;
		y = rect->y;
		w = rect->width;
		h = rect->height;
		// Note: metrics assumes top-down, for RGB, we're bottom-up, so flip it
		y = src_height - y - h;
		// Now we need to copy that chunk from the source frame to the destination frame
		// FIXME: Right now we assume every character is the same height. This is currently always true,
		// but not a strict requirement.
		env->BitBlt(dstp + (dst_pitch*c_y) + c_x*bpp, dst_pitch, srcp + (src_pitch*y + x*bpp), src_pitch, w*bpp, lineHeight);
		/*
		for (d_y = 0; d_y < lineHeight; d_y++) {
			// And copy.
			memcpy(dstp + (dst_pitch*(d_y+c_y)) + c_x*bpp, srcp + (src_pitch*(d_y + y) + x*bpp), w*bpp);
		}*/
		c_x += rect->width;
	}
	// And a final check in case the last line isn't the longest
	if (c_x < width) {
		// We need to finish filling the line
		for (d_y = c_y; d_y < c_y2; d_y++) {
			memset(dstp + (dst_pitch*d_y) + c_x*bpp, 0, (width-c_x)*bpp);
		}
	}
	return result;
}

ImageTextMetrics::ImageTextMetrics(unsigned int width, unsigned int height, char firstCharacter, char lastCharacter, unsigned int rows, unsigned int cols) :
	firstCharacter(firstCharacter), lastCharacter(lastCharacter) {
	unsigned int numChars = lastCharacter - firstCharacter + 1; // Last character is inclusive
	//cout << "Creating metrics for " << numChars << " characters from a " << width << "x" << height << " image." << endl;
	if (rows == 0) {
		// Calculate rows based on number of columns
		if (cols == 0) {
			// FIXME: This should raise an error, really.
			cols = 16;
		}
		rows = ((numChars - 1) / cols) + 1;
	} else if (cols == 0) {
		// Calculate columns based on number of rows
		cols = ((numChars - 1) / rows) + 1;
	}
	//cout << cols << " glyphs per line, " << rows << " lines." << endl;
	// Now generate our text metrics
	metrics = new ITRECT[numChars];
	unsigned int x = 0;
	unsigned int y = 0;
	unsigned int w = width / cols;
	unsigned int h = height / rows;
	lineHeight = h;
	// Make width be an exact multiple
	width = cols * w;
	for (unsigned int c = 0; c < numChars; c++) {
		//cout << "Character " << c << ": (" << x << "," << y << "), [" << w << "x" << h << "]." << endl;
		metrics[c].x = x;
		metrics[c].y = y;
		metrics[c].width = w;
		metrics[c].height = h;
		x += w;
		if (x >= width) {
			x = 0;
			y += h;
		}
	}
	// And done.
}

ImageTextMetrics::~ImageTextMetrics() {
	delete metrics;
	metrics = NULL;
}

ITRECT* ImageTextMetrics::GetMetrics(char c) {
	if (c < firstCharacter || c > lastCharacter)
		return NULL;
	return metrics + (c - firstCharacter);
}

unsigned int ImageTextMetrics::GetStringWidth(const char* str) {
	unsigned int res = 0;
	unsigned int currentLine = 0;
	//cout << "Calculate text metrics for \"" << str << "\"." << endl;
	for (size_t i = 0; ; i++) {
		char c = str[i];
		if (c == '\0')
			break;
		if (c == '\n') {
			if (currentLine > res) {
				res = currentLine;
			}
			currentLine = 0;
			continue;
		}
		if (c < firstCharacter || c > lastCharacter) {
			continue;
		}
		//cout << "Character " << c << ": width=" << metrics[c - firstCharacter].width << endl;
		currentLine += metrics[c - firstCharacter].width;
	}
	return res > currentLine ? res : currentLine;
}

unsigned int ImageTextMetrics::GetStringHeight(const char* str) {
	unsigned int res = lineHeight;
	for (size_t i = 0; ; i++) {
		char c = str[i];
		if (c == '\0')
			break;
		if (c == '\n') {
			res += lineHeight;
		}
	}
	return res;
}

AVSValue __cdecl Create_ImageText(AVSValue args, void* user_data, IScriptEnvironment* env) {
	return new ImageText(args[0].AsClip(), args[1].AsString(),
		args[2].AsInt(0), args[3].AsInt(16), args[5].AsBool(false), env);
}

enum PaletteParseState {
	// No palette data parsed (accepting state)
	PP_BEFORE,
	// Defining a source color
	PP_SRC_COLOR,
	// Whitespace after a source color
	PP_SRC_COLOR_WS,
	// Found = in the source color, whitespace afterwards
	PP_AFTER_EQUALS,
	// Defining a destination color (accepting state)
	PP_DST_COLOR,
	// Whitespace after a destination color (accepting state)
	PP_DST_COLOR_WS
};

#define IS_WHITESPACE(c)	(c == ' ' || c == '\t' || c == '\r' || c == '\n')
#define IS_HEXDIGIT(c)		((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f'))
#define IS_EQUALSIGN(c)		(c == '=' || c == '>')
#define IS_SPLITTER(c)		(c == ';' || c == ',')
// NOTE: assumes IS_HEXDIGIT already verified, else results are undefined
#define DECODE_HEX(c)		(c <= '9' ? c - '0' : (c <= 'F' ? (c - 'A') : (c - 'a')) + 10)

Palette::Palette(const char* pal, IScriptEnvironment* env) {
	// Basically, the palette string should be 'COLOR=COLOR;COLOR=COLOR'.
	// All whitespace in the string is ignored.
	// Quick pass: count colors (based on number of equal signs)
	unsigned int colors = 0;
	for (int i = 0; ; i++) {
		char c = pal[i];
		if (c == '\0')
			break;
		if (IS_EQUALSIGN(c))
			colors++;
	}
	if (colors == 0)
		env->ThrowError("No colors given in palette swap, refusing to create a very inefficient null filter.");
	// Now that we have an upper bound on the number of colors, allocate storage space for our palette
	size = colors;
	entries = new PaletteEntry[colors];
	int state = 0;
	int src_color = 0;
	int dst_color = 0;
	// Current entry:
	PaletteEntry* cur_entry = entries;
	// Reset actual colors found:
	colors = 0;
	for (int i = 0; ; i++) {
		char c = pal[i];
		if (c == '\0')
			break;
		switch (state) {
		case PP_BEFORE:
			if (IS_WHITESPACE(c)) {
				// Do nothing.
			} else if (IS_HEXDIGIT(c)) {
				// Transition and start the source color
				state = PP_SRC_COLOR;
				src_color = DECODE_HEX(c);
			} else {
				// Otherwise, throw an error.
				env->ThrowError("Expected start of source color, found '%c'", c);
			}
			break;
		case PP_SRC_COLOR:
			if (IS_HEXDIGIT(c)) {
				// Add to current
				src_color <<= 4;
				src_color |= DECODE_HEX(c);
			} else if (IS_WHITESPACE(c)) {
				// Transition to PP_SRC_COLOR_WS
				state = PP_SRC_COLOR_WS;
			} else if (IS_EQUALSIGN(c)) {
				// Transition to PP_AFTER_EQUALS
				state = PP_AFTER_EQUALS;
			} else {
				env->ThrowError("Expecting color definition, found '%c'", c);
			}
			break;
		case PP_SRC_COLOR_WS:
			if (IS_WHITESPACE(c)) {
				// Do nothing
			} else if (IS_EQUALSIGN(c)) {
				// Transition to PP_AFTER_EQUALS
				state = PP_AFTER_EQUALS;
			} else {
				env->ThrowError("Expecting '=', found '%c'", c);
			}
			break;
		case PP_AFTER_EQUALS:
			if (IS_WHITESPACE(c)) {
				// Do nothing.
			} else if (IS_HEXDIGIT(c)) {
				// Transition and start the destination color
				state = PP_DST_COLOR;
				dst_color = DECODE_HEX(c);
			} else {
				// Otherwise, throw an error.
				env->ThrowError("Expected start of destination color, found '%c'", c);
			}
			break;
		case PP_DST_COLOR:
			if (IS_HEXDIGIT(c)) {
				// Add to current
				dst_color <<= 4;
				dst_color |= DECODE_HEX(c);
			} else if (IS_WHITESPACE(c) || IS_SPLITTER(c)) {
				// Store the entry...
				cur_entry->original = src_color;
				cur_entry->swapped = dst_color;
				cur_entry++;
				colors++;
				// .. and transition based on character
				state = IS_SPLITTER(c) ? PP_BEFORE : PP_DST_COLOR_WS;
			} else {
				env->ThrowError("Expecting color definition, found '%c'", c);
			}
			break;
		default:
			env->ThrowError("Palette parsing state machine has gone off its rails!");
		}
	}
	switch (state) {
	case PP_BEFORE:
	case PP_DST_COLOR_WS:
		// Accepting states without any additional work.
		break;
	case PP_DST_COLOR:
		// This one needs to store current work
		cur_entry->original = src_color;
		cur_entry->swapped = dst_color;
		cur_entry++;
		colors++;
		break;
	default:
		env->ThrowError("Unexpected end of palette definition");
	}
	if (size != colors) {
		env->ThrowError("Expected %d colors, but found %d (internal error)", size, colors);
	}
	// And for debugging purposes, dump the palette
	for (unsigned int i = 0; i < size; i++) {
		cout << "Entry " << i << ": " << hex << entries[i].original << " => " << hex << entries[i].swapped << endl;
	}
}

Palette::~Palette() {
	delete entries;
	entries = NULL;
	size = 0;
}

Pixel32 Palette::SwapPixel(Pixel32 original) {
	for (unsigned int i = 0; i < size; i++) {
		if (entries[i].original == (original & 0xFFFFFF))
			return entries[i].swapped | (original & 0xFF000000);
	}
	return original;
}

// And one more that's vaguely related.
PaletteSwap::PaletteSwap(PClip source, Palette* palette, IScriptEnvironment* env) :
	GenericVideoFilter(source), palette(palette) {
	// We currently only work with RGB32 images, future versions might work with RGB24 too, but it ONLY really makes sense with RGB32 images.
	if (!vi.IsRGB32()) {
		env->ThrowError("Source colorspace must be RGB32");
	}
}

PaletteSwap::~PaletteSwap() {
	delete palette;
}

PVideoFrame __stdcall PaletteSwap::GetFrame(int n, IScriptEnvironment* env) {
	PVideoFrame src = child->GetFrame(n, env);
	PVideoFrame dst = env->NewVideoFrame(vi);

	const unsigned char* srcp = src->GetReadPtr();
	unsigned char* dstp = dst->GetWritePtr();

	// Grab the pitch...
	const int dst_pitch = dst->GetPitch();
	const int src_pitch = src->GetPitch();

	// And start copying.
	int x, y;
	for (y = 0; y < vi.height; y++) {
		// Create pointers for the single line (we need to keep the originals to add the line pitch)
		const Pixel32* src_pt = (Pixel32*) srcp;
		Pixel32* dst_pt = (Pixel32*) dstp;
		for (x = 0; x < vi.width; x++) {
			*(dst_pt) = palette->SwapPixel(*(src_pt));
			src_pt++;
			dst_pt++;
		}
		// And then advance to the next line.
		srcp = srcp + src_pitch;
		dstp = dstp + dst_pitch;
	}
	return dst;
}

AVSValue __cdecl Create_PaletteSwap(AVSValue args, void* user_data, IScriptEnvironment* env) {
	Palette* palette = new Palette(args[1].AsString(), env);
	return new PaletteSwap(args[0].AsClip(), palette, env);
}