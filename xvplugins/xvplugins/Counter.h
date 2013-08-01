//
// Counter.h
//
// Header file for the Counter filter - takes another clip, and generates a
// "counter" that counts up at certain frames.
//
#include "avisynth.h"
#include <vector>

// Actual filter class.
class Counter : public GenericVideoFilter {
public:
	Counter(PClip source, int spinTime, unsigned int bounce, unsigned int* counts, size_t length, bool showZero, bool padZero, IScriptEnvironment* env);
	~Counter();

	PVideoFrame __stdcall GetFrame(int n, IScriptEnvironment* env);

private:
	std::vector<unsigned int> counts;
	int spinTime;
	unsigned int bounce;
	unsigned int digitWidth;
	bool showZero;
	bool padZero;
	int lastFrame;
};


#define COUNTER_ARGS		"ci+[PAD_ZERO]b[SHOW_ZERO]b[SPIN_TIME]i"
AVSValue __cdecl Create_Counter(AVSValue args, void* user_data, IScriptEnvironment* env);

#define COUNTER_STR_ARGS	"cs[PAD_ZERO]b[SHOW_ZERO]b[SPIN_TIME]i"
AVSValue __cdecl Create_CounterStr(AVSValue args, void* user_data, IScriptEnvironment* env);