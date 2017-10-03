#pragma once

#include "avisynth.h"

// Filter class that provides a filter that can skew individual lines.
class SkewLines : public GenericVideoFilter {
public:
	SkewLines(PClip source, const char* function, IScriptEnvironment* env);
	~SkewLines();

	PVideoFrame __stdcall GetFrame(int n, IScriptEnvironment* env);
private:
	char* function;
};

// C functions used to wrap the constructors
AVSValue __cdecl Create_SkewLines(AVSValue args, void* user_data, IScriptEnvironment* env);
