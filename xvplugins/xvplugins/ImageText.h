#include "avisynth.h"

typedef struct _it_rectangle {
	unsigned int x, y;
	unsigned int width, height;
} ITRECT;

// Simple class to deal with text metrics.
class ImageTextMetrics {
public:
	ImageTextMetrics(unsigned int width, unsigned int height, char firstCharacter, char lastCharacter, unsigned int rows, unsigned int cols);
	~ImageTextMetrics();
	ITRECT* GetMetrics(char c);
	unsigned int GetStringWidth(const char* str);
	unsigned int GetStringHeight(const char* str);
	unsigned int GetLineHeight() { return lineHeight; }
private:
	char firstCharacter;
	char lastCharacter;
	ITRECT* metrics;
	unsigned int lineHeight;
};

// Actual filter class.
class ImageText : public GenericVideoFilter {
public:
	ImageText(PClip source, const char* str, unsigned int rows, unsigned int cols, bool translateEscapes, IScriptEnvironment* env);
	~ImageText();

	PVideoFrame __stdcall GetFrame(int n, IScriptEnvironment* env);
private:
	const char* text;
	ImageTextMetrics* metrics;
};

// And one more that's vaguely related.

typedef struct PaletteEntry_s {
	Pixel32 original;
	Pixel32 swapped;
} PaletteEntry;

class Palette {
public:
	Palette(const char* pal, IScriptEnvironment* env);
	~Palette();
	Pixel32 SwapPixel(Pixel32 original);
private:
	unsigned int size;
	PaletteEntry* entries;
};

class PaletteSwap : public GenericVideoFilter {
public:
	PaletteSwap(PClip source, Palette* palette, IScriptEnvironment* env);
	~PaletteSwap();

	PVideoFrame __stdcall GetFrame(int n, IScriptEnvironment* env);
private:
	Palette* palette;
};

// C functions used to wrap the constructors
AVSValue __cdecl Create_ImageText(AVSValue args, void* user_data, IScriptEnvironment* env);
AVSValue __cdecl Create_PaletteSwap(AVSValue args, void* user_data, IScriptEnvironment* env);