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
 * AutoTraceFilter.h : define the filter class file
 */
#pragma once

class AutoTraceFilter : public GenericVideoFilter {
public:
	AutoTraceFilter(PClip aChild, int aWidth, int aHeight, at_fitting_opts_type* aFittingOpts=NULL);
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