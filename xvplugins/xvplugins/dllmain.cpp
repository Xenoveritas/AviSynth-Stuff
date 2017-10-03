// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"
#include "ImageText.h"
#include "Counter.h"
#include "SkewLines.h"

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}


// The following function is the function that actually registers the filter in AviSynth
// It is called automatically, when the plugin is loaded to see which functions this filter contains.
extern "C" __declspec(dllexport) const char* __stdcall AvisynthPluginInit2(IScriptEnvironment* env) {
	env->AddFunction("ImageText", "cs[ROWS]i[COLS]i[METRICS]s[MULTILINE]b", Create_ImageText, NULL);
	env->AddFunction("PaletteSwap", "cs", Create_PaletteSwap, NULL);
	env->AddFunction("Counter", COUNTER_ARGS, Create_Counter, NULL);
	env->AddFunction("CounterStr", COUNTER_STR_ARGS, Create_CounterStr, NULL);
	env->AddFunction("SkewLines", "cs", Create_SkewLines, NULL);
	// The AddFunction has the following paramters:
	// AddFunction(Filtername , Arguments, Function to call,0);

	// Arguments is a string that defines the types and optional names of the arguments for your filter.
	// c - Video Clip
	// i - Integer number
	// f - Float number
	// s - String
	// b - boolean

	// Is this even used anywhere?
	return "xvplugins";
}
