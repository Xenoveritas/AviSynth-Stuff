/*
 * AutoTraceFilter, filter for using AutoTrace to resize video
 * Copyright (C) 2013 Xenoveritas
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA
 *
 * AutoTraceFilter.cpp : The actual filter itself
 */

#include "stdafx.h"
#include "AutoTraceFilter.h"

AutoTraceFilter::AutoTraceFilter(PClip aChild, int aWidth, int aHeight, at_fitting_opts_type* aFittingOpts) :
		GenericVideoFilter(aChild),
		destWidth(aWidth), destHeight(aHeight) {
	const VideoInfo& info = child->GetVideoInfo();
	srcWidth = info.width;
	srcHeight = info.height;
	// At this point, create our bitmap for rendering a frame to
	renderedFrameData = new BYTE[destWidth * destHeight * 4];
	renderedFramePitch = destWidth * 4;
	memset(renderedFrameData, 0, destWidth * destHeight * 4);
	renderedFrame = new Gdiplus::Bitmap(destWidth, destHeight, renderedFramePitch,
		PixelFormat32bppPARGB, (BYTE*) renderedFrameData);
	graphics = new Gdiplus::Graphics(renderedFrame);
	graphics->SetSmoothingMode(Gdiplus::SmoothingModeAntiAlias);
	backgroundColor = new Gdiplus::Color(0);
	// TODO: Allow RGB32 images
	//rgb24 = info.IsRGB24();
	vi.width = destWidth;
	vi.height = destHeight;
	vi.pixel_type = VideoInfo::CS_BGR32;
	fitting_opts = aFittingOpts == NULL ? at_fitting_opts_new() : aFittingOpts;
}

AutoTraceFilter::~AutoTraceFilter() {
	delete renderedFrame;
	delete renderedFrameData;
	at_fitting_opts_free(fitting_opts);
}

void exception_handler(at_string msg, at_msg_type msg_type, at_address client_data) {
	printf("AutoTrace %s: %s\n", msg_type == AT_MSG_FATAL ? "Fatal" : "Warning", msg);
}

// Test function to dump generated splines to SVG
void dump_svg(FILE* fp, at_splines_type* splines, int srcWidth, int srcHeight, int destWidth, int destHeight) {
	// Now create the new frame
	fprintf(fp, "<?xml version=\"1.0\" standalone=\"yes\"?>\n<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%d\" height=\"%d\">\n", destWidth, destHeight);
	at_real tx = ((at_real)destWidth) / ((at_real)srcWidth);
	at_real ty = ((at_real)destHeight) / ((at_real)srcHeight);
	for (unsigned int i = 0; i < splines->length; i++) {
		at_spline_list_type spline_list = splines->data[i];
		fprintf(fp, "<path style=\"%s:#%02x%02x%02x; %s:none;\" d=\"",
				(splines->centerline) ? "stoke" : "fill",
				spline_list.color.b,
				spline_list.color.g,
				spline_list.color.r,
				(splines->centerline) ? "fill" : "stroke");
		fprintf(fp, "M%g %g ", spline_list.data->v[0].x * tx, spline_list.data->v[0].y * ty);
		for (unsigned int j = 0; j < spline_list.length; j++) {
			at_spline_type* spline = &(spline_list.data[j]);
			if (spline->degree == AT_LINEARTYPE) {
				fprintf(fp, "L%g %g ", spline->v[3].x * tx, spline->v[3].y * ty);
			} else {
				fprintf(fp, "C%g %g %g %g %g %g ",
					spline->v[1].x * tx, spline->v[1].y * ty,
					spline->v[2].x * tx, spline->v[2].y * ty,
					spline->v[3].x * tx, spline->v[3].y * ty);
			}
		}
		fprintf(fp, "z\"/>\n");
	}
	fprintf(fp, "</svg>\n");
}

PVideoFrame __stdcall AutoTraceFilter::GetFrame(int n, IScriptEnvironment* env) {
	// Grab the child frame
	PVideoFrame childFrame = child->GetFrame(n, env);
	// Create the bitmap - AutoTrace always wants a 24-bpp bitmap for some dumb reason
	at_bitmap_type *bitmap;
	bitmap = at_bitmap_new(srcWidth, srcHeight, 3);
	size_t bitmap_size = srcWidth * srcHeight * 3;
	// Pull the bitmap data
	// We can just blt lines
	const BYTE* srcBitmap = childFrame->GetReadPtr();
	int pitch = childFrame->GetPitch();
	int rowSize = childFrame->GetRowSize();
	for (int y = 0; y < srcHeight; y++) {
		// Note that R and B are swapped in this. It doesn't really matter.
		memcpy_s(bitmap->bitmap + ((srcHeight - y - 1) * rowSize), bitmap_size, srcBitmap + (y * pitch), rowSize);
	}
	// This does the actual tracing:
	at_splines_type* splines = at_splines_new(bitmap, fitting_opts, exception_handler, NULL);
	// Now create the new frame. First, blank out the old frame
	graphics->Clear(*backgroundColor);
	at_real tx = ((at_real)destWidth) / ((at_real)srcWidth);
	at_real ty = ((at_real)destHeight) / ((at_real)srcHeight);
	for (unsigned int i = 0; i < splines->length; i++) {
		at_spline_list_type spline_list = splines->data[i];
		Gdiplus::GraphicsPath path;
		for (unsigned int j = 0; j < spline_list.length; j++) {
			at_spline_type* spline = &(spline_list.data[j]);
			if (spline->degree == AT_LINEARTYPE) {
				path.AddLine((Gdiplus::REAL)(spline->v[0].x * tx), (Gdiplus::REAL)(spline->v[0].y * ty),
					(Gdiplus::REAL)(spline->v[3].x * tx), (Gdiplus::REAL)(spline->v[3].y * ty));
			} else {
				path.AddBezier(
					(Gdiplus::REAL)(spline->v[0].x * tx), (Gdiplus::REAL)(spline->v[0].y * ty),
					(Gdiplus::REAL)(spline->v[1].x * tx), (Gdiplus::REAL)(spline->v[1].y * ty),
					(Gdiplus::REAL)(spline->v[2].x * tx), (Gdiplus::REAL)(spline->v[2].y * ty),
					(Gdiplus::REAL)(spline->v[3].x * tx), (Gdiplus::REAL)(spline->v[3].y * ty));
			}
		}
		path.CloseFigure();
		// Red and blue are swapped here, so swap them back.
		Gdiplus::Color color(spline_list.color.b, spline_list.color.g, spline_list.color.r);
		Gdiplus::SolidBrush brush(color);
		graphics->FillPath(&brush, &path);
	}
	at_splines_free(splines);
	at_bitmap_free(bitmap);
	// Now we need to create our result frame
	PVideoFrame outputFrame = env->NewVideoFrame(vi);
	BYTE* outputData = outputFrame->GetWritePtr();
	env->BitBlt(outputData, outputFrame->GetPitch(), renderedFrameData, renderedFramePitch, destWidth*4, destHeight);
	return outputFrame;
}

AVSValue __cdecl Create_AutoTrace(AVSValue args, void* user_data, IScriptEnvironment* env) {
	PClip clip = args[0].AsClip();
	const VideoInfo& vi = clip->GetVideoInfo();
	if (vi.IsRGB24()) {
		at_fitting_opts_type* fitting_opts = at_fitting_opts_new();
		// Setting fitting opts based on input
		fitting_opts->color_count = args[3].AsInt(0);
		int destWidth = args[1].AsInt(0);
		int destHeight = args[2].AsInt(0);
		// If the inputs are left off entirely (or 0 or negative), then use the
		// input size. If either one is left off (or 0 or negative), then
		// determine that one based on presevering the aspect ratio of the
		// given value.
		if (destWidth <= 0) {
			if (destHeight <= 0) {
				destWidth = vi.width;
				destHeight = vi.height;
			} else {
				// Calculate width based off desired height
				destWidth = destHeight * vi.width / vi.height;
			}
		} else if (destHeight <= 0) {
			// Calculate height based off desired width
			destHeight = destWidth * vi.height / vi.width;
		}
		if (args[4].Defined()) {
			// background_color
			int background = args[4].AsInt();
			if (background != -1) {
				// To match the documentation, ignore -1, even though it would
				// be a valid color. (And argueably makes more sense than
				// 0xFFFFFF, as it has the alpha channel set to full.)
				// Note that R and B are swapped. This is by design - rather
				// than convert a BGR image into an RGB image as AutoTrace
				// expects, we just let the B and R channels be "backwards" as
				// within AutoTrace.
				fitting_opts->background_color = at_color_new(
					(background & 0x0000FF),
					(background & 0x00FF00) >> 8,
					(background & 0xFF0000) >> 16);
			}
		}
		return new AutoTraceFilter(clip, destWidth, destHeight, fitting_opts);
	} else {
		env->ThrowError("AutoTrace requires an RGB24 image");
		return NULL;
	}
}

class GdiplusLifecycleHandler {
public:
	GdiplusLifecycleHandler() {
		Gdiplus::GdiplusStartupInput gdiplusStartupInput;
		GdiplusStartup(&token, &gdiplusStartupInput, NULL);
	}
	~GdiplusLifecycleHandler() {
		Gdiplus::GdiplusShutdown(token);
	}
private:
	ULONG_PTR token;
};

void ShutdownGdiplus(void* lifecycle, IScriptEnvironment* env) {
	delete ((GdiplusLifecycleHandler*)lifecycle);
}

// The following function is the function that actually registers the filter in AviSynth
// It is called automatically, when the plugin is loaded to see which functions this filter contains.
extern "C" __declspec(dllexport) const char* __stdcall AvisynthPluginInit2(IScriptEnvironment* env) {
	// Startup Gdiplus:
	GdiplusLifecycleHandler* lifecycle = new GdiplusLifecycleHandler();
	// And then, at exit, kill it
	env->AtExit(ShutdownGdiplus, lifecycle);
	env->AddFunction("AutoTraceResize", "c[WIDTH]i[HEIGHT]i[COLORS]i[BACKGROUND_COLOR]i", Create_AutoTrace, NULL);

	return "`AutoTrace' AutoTrace resize plugin";
}