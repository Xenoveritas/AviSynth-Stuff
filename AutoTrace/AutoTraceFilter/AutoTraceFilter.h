#pragma once

#include "avisynth.h"
#include "autotrace.h"

#include <gdiplus.h>

class AutoTraceFilter : public GenericVideoFilter {
public:
	AutoTraceFilter(PClip aChild, int aWidth, int aHeight);
	~AutoTraceFilter();
	PVideoFrame __stdcall GetFrame(int n, IScriptEnvironment* env);
private:
	int srcWidth;
	int srcHeight;
	//bool rgb24;
	int destWidth;
	int destHeight;
	at_fitting_opts_type *fitting_opts;
	BYTE* renderedFrameData;
	int renderedFramePitch;
	Gdiplus::Bitmap* renderedFrame;
	Gdiplus::Graphics* graphics;
	Gdiplus::Color* backgroundColor;
};