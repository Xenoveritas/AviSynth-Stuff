# A collection of avisynth functions to help people animate and position DS screens in an approximate widescreen space.
# It's designed with the idea of working with a 1280x768 area, as this is 5 DS screens wide and 4 DS screens tall,
# allowing you to fit them in in a variety of patterns.
# It's designed to work with the output from DeSmuME, with the 2 256x192 stacked on top of each other
# This was initially thrown together for the Something Awful forums by forums user Mastigophoran
# Got some ideas of stuff to add for R3 from Admiral H. Curtiss, and Captain Flame Guy, and the Tech Support Crowd helped a bit too
# More stuff for R4 from YamiNoSenshi. Thanks YamiNoSenshi!

# Temporary Readme can be found here:       http://lpix.org/sslptest/index.php?id=10443

# Changelog:

# Revision 2:
# Done: Have some way to have frame A drawn before frame B, should be pretty easy to do with an eval/default values
# Nope: Probably add some more examples?
# Done: Make a function to set the variables yourself and then call functions to perform them
# Done: Make some functions that make it easier to perform eg Fades/Dissolves without desyncing the two videos

# Revision 3:  (# NB: original Rev 3 has typo, was line 322, has -MDS_QSzY instead of -MDS_QSzX )
# Done: Fixed some stupid bugs with TopO and BottomO
# Done: Added in automated better sizing below 1x scale
# Done: Add 4th param to most 3 param calls to 'undo'
# Done: FlipFlop function?
# Done: Create functions that allow you to change additional filters
# Done: Add in functions for help with custom transitions

# Revions 4:
# Done: Added Vertical Mode, just call MDS_SetVerticalMode() And use MDS_SideWays or MDS_SideWaysGap! Technically works with everything else but uses a 3x multiple - use after SetParams
# Done: Added transition effect to go from VertStack to... Vertstack rotated on its side? You probably want to call MDS_SideWaysA afterwards. -
#	MDS_VStackToRotated and MDS_RotatedToVStack. They have an optional param to select which way to rotate which will be remembered across multiple calls.
# Done: Added 'step' params to resize and positioning function, in case this is useful for more advanced functions. Will just be an integer from 0 to 29.
# Done: Fixed resize methods for immediate function to match those used in animated (relevant to lower res videos)
# Done: Changed the way MDS_AnimFunc and MDS_PositionFunc get called, now they let you change the core animation that's at work, which lets you actually accomplish things by changing them, unlike previous attempts.
# Done: Added MDS_DraftSettings and MDS_SmoothSettings, which are some presets for blockpreserve and resize filters so that people who don't actually want
#   to know every detail of this stupid overengineered system can get smoother (but slower to process) results

global MDS_LastFrame = 0
global MDS_DrawBFirst = false

global AFC = 30 #animation frame count

global MDS_AnimResizeFilter = "PointResize"
# These are used when we resize the videos up above 1x or down below 1x
global MDS_FinalResizeUp = "PointResize"
global MDS_FinalResizeDown = "Spline36Resize"

global MDS_PositionAnimFunc = "MDS_AnimPosition"
global MDS_PositionOngoingFunc = "MDS_PositionNonAnim"
global MDS_ResizeOngoingFunc = "MDS_ResizeNonAnim"

#This is the filter that will be called (the params you have access to are called c, the clip, and val, an angle in degrees
global MDS_RotationPluginCall = "zoom(c,angle = string(val))"

# This is the function that is called to resize the vidoes in the regular functions
# If you wanted to, you could change this to something else
global MDS_AnimFunc = "MDS_AnimResizeCore"
global MDS_PositionFunc = "MDS_PositionCore"	#A main manager function for things in general, calls the animation and non animated position methods

global MDS_GetTopFunc = "intMDS_GetTop"
global MDS_GetBotFunc = "intMDS_GetBot"

# This int will pixel double (well, multiply by MDS_BlockPreserve) inputs before applying the resize to them, in an attempt to preserve blockiness when using a better filter
global MDS_BlockPreserve = 0

# These are the base sizes for the input panes
global MDS_basesizeX = 256
global MDS_basesizeY = 192

global MDS_MaxX = 1280
global MDS_MaxY = 768
global MDS_SzX = 1024
global MDS_SzY = 768
global MDS_QSzX = 256
global MDS_QSzY = 192
global MDS_SBSX = 512
global MDS_SBSY = 384

global MDS_Border = 128

# These values are used to keep track of where we last put the video, and where we want to put it next
global LastTopPosX = 0
global LastTopPosY = 0
global LastTopSizeX = 256
global LastTopSizeY = 192
global LastBotPosX = 0
global LastBotPosY = 192
global LastBotSizeX = 256
global LastBotSizeY = 192

global newTSX = 0
global newTSY = 0
global newBSX = 256
global newBSY = 192
global newTPX = 0
global newTPY = 192
global newBPX = 256
global newBPY = 192

global MDS_MemTSX = LastTopSizeX
global MDS_MemTSY = LastTopSizeY
global MDS_MemBSX = LastBotSizeX
global MDS_MemBSY = LastBotSizeY

global MDS_MemTPX = LastTopPosX
global MDS_MemTPY = LastTopPosY
global MDS_MemBPX = LastBotPosX
global MDS_MemBPY = LastBotPosY

global MDS_RotatedToRight = false
global MDS_VertStackGapGap = 92
global MDS_SidewaysGapGap = 92
global MDS_OneTimeUseDown = false

#And this just makes our video return something if we accidently view it
BlankClip(length=240, width=640, height=480, pixel_type="RGB32", fps=24, fps_denominator=1, audio_rate=44100, stereo=False, sixteen_bit=True, color=$000000)
Subtitle("This is MastiDS.avs! Import this script into your AVS!")
Subtitle("Also, load your avi after you import, because this clip returned by the import line!",y = 50)

function MDS_SetAFC(int newAFC)
{
	global AFC = newAFC
}

function MDS_SetParams(int "pMaxX", int "pMaxY", int "pSzX", int "pSzY", int "pQSzX", int "pQSzY", int "pSBSX", int "pSBSY")
{
	global MDS_MaxX = Default(pMaxX,MDS_MaxX)
	global MDS_MaxY = Default(pMaxY,MDS_MaxY)
	global MDS_SzX = Default(pSzX,MDS_SzX)
	global MDS_SzY = Default(pSzY,MDS_SzY)
	global MDS_QSzX = Default(pQSzX,floor(MDS_SzX / 4))
	global MDS_QSzY = Default(pQSzY,floor(MDS_SzY / 4))
	global MDS_SBSX = Default(pSBSX,floor(MDS_SzX / 2))
	global MDS_SBSY = Default(pSBSY,floor(MDS_SzY / 2))

	global MDS_Border = floor((MDS_MaxX - MDS_SzX) / 2)
}

function MDS_SetDefaultParams()
{
	MDS_SetParams(1280,768,1024,768)
}

function MDS_SetHalfSizeParams()
{
	MDS_SetParams(640,384,512,384)
}

function MDS_SetVertHalfSizeParams()
{
	MDS_SetParams(852,512,384,512)
}

function MDS_Set169WideScreen()
{
	MDS_SetParams(1364,768,1024,768)	# needs to be multiple of 4 for Yuv
}

function MDS_SetHorizontalMode(bool "NoParamChange")
{
	MDS_ChangeCropWorkers("intMDS_GetTop","intMDS_GetBot")
	NoParamChange = Default(NoParamChange,FALSE)
	l = (NoParamChange == FALSE) ? MDS_SetParams(pSzX = floor(4 * (MDS_SzY / 3))) : 0
}
function MDS_SetVerticalMode(bool "RotateToRight", bool "NoParamChange")
{
	MDS_ChangeCropWorkers("intMDS_GetVertTop","intMDS_GetVertBot")
	NoParamChange = Default(NoParamChange,FALSE)
	l = (NoParamChange == FALSE) ? MDS_SetParams(pSzX = floor(3 * (MDS_SzY / 4))) : 0
}

function MDS_DraftSettings()
{
	global MDS_VertStackGapGap = (MDS_VertStackGapGap == -92) ? -92 : 92
	global MDS_SidewaysGapGap = (MDS_SidewaysGapGap == -92) ? -92 : 92
	MDS_SetBlockPreserve(0)
	global MDS_AnimResizeFilter = "PointResize"
	global MDS_FinalResizeUp = "PointResize"
	global MDS_FinalResizeDown = "Spline36Resize"
}
function MDS_SmoothSettings()
{
	global MDS_VertStackGapGap = (MDS_VertStackGapGap == 92) ? -92 : 92
	global MDS_SidewaysGapGap = (MDS_SidewaysGapGap == 92) ? -92 : 92
	MDS_SetBlockPreserve(4)
	global MDS_AnimResizeFilter = "Spline36Resize"
	global MDS_FinalResizeUp = "PointResize"
	global MDS_FinalResizeDown = "Spline36Resize"
}

function MDS_ResetLastframe()
{
	global MDS_LastFrame = 0
}

function MDS_ChangeResizeFilter(string FilterName)
{
	global MDS_AnimResizeFilter = FilterName
}

function MDS_TopOnTop(bool Bfirst)
{
	global MDS_DrawBFirst = Bfirst
}

function MDS_SetBlockPreserve(int Factor)
{
	global MDS_BlockPreserve = Factor
}

function MDS_SetFinalResizeMethods(string "OneXorMore", string "BelowOneX")
{
	global MDS_FinalResizeUp = Default(OneXorMore,MDS_FinalResizeUp)
	global MDS_FinalResizeDown = Default(BelowOneX,MDS_FinalResizeDown)
}

function MDS_SetFinalPositionMethods(string OngoingFunctionName)
{
	global MDS_PositionOngoingFunc = OngoingFunctionName
}

function MDS_ChangeAnimationWorker(string FuncName)
{
	global MDS_AnimFunc = FuncName
}

function MDS_ChangePositionWorker(string FuncName)
{
	global MDS_PositionFunc = FuncName
}
function MDS_ChangeCropWorkers(string "TopGetter", string "BotGetter")
{
	global MDS_GetTopFunc = Default(TopGetter,MDS_GetTopFunc)
	global MDS_GetBotFunc = Default(BotGetter,MDS_GetBotFunc)
}

function MDS_ChangeBaseSizes(int BaseX, int BaseY)
{
	global MDS_basesizeX = BaseX
	global MDS_basesizeY = BaseY
}

function MDS_ChangeAnimWorker(string "Worker")
{
	global MDS_RotationPluginCall = Default(Worker,"zoom(c,angle = string(val))")
}

# Positioning functions begin:

function intMDS_SBS()
{
	global newTSX = MDS_SBSX
	global newTSY = MDS_SBSY
	global newBSX = MDS_SBSX
	global newBSY = MDS_SBSY
	global newTPX = MDS_Border
	global newTPY = floor((MDS_SzY - MDS_SBSY) / 2)
	global newBPX = MDS_Border + MDS_SBSX
	global newBPY = floor((MDS_SzY - MDS_SBSY) / 2)
}
function MDS_SBS(clip raw)
{
	MDS_SameCode(raw,"intMDS_SBS")
}
function MDS_SBS(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_SBS",frame,frame2)
}
function MDS_SBSA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_SBS")
}
function MDS_SBSA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_SBSA",frame,frame2)
}

function intMDS_SBSL()
{
	global newTSX = floor(MDS_SBSX * 1.5)
	global newTSY = floor(MDS_SBSY * 1.5)
	global newBSX = MDS_SBSX
	global newBSY = MDS_SBSY
	global newTPX = 0
	global newTPY = floor((MDS_SzY - (MDS_SBSY * 1.5)) / 2)
	global newBPX = floor(MDS_SBSX * 1.5)
	global newBPY = floor((MDS_SzY - MDS_SBSY) / 2)
}
function MDS_SBSL(clip raw)
{
	MDS_SameCode(raw,"intMDS_SBSL")
}
function MDS_SBSL(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_SBSL",frame,frame2)
}
function MDS_SBSLA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_SBSL")
}
function MDS_SBSLA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_SBSLA",frame,frame2)
}

function intMDS_SBSR()
{
	global newTSX = MDS_SBSX
	global newTSY = MDS_SBSY
	global newBSX = floor(MDS_SBSX * 1.5)
	global newBSY = floor(MDS_SBSY * 1.5)
	global newTPX = 0
	global newTPY = floor((MDS_SzY - MDS_SBSY) / 2)
	global newBPX = MDS_SBSX
	global newBPY = floor((MDS_SzY - (MDS_SBSY * 1.5)) / 2)
}
function MDS_SBSR(clip raw)
{
	MDS_SameCode(raw,"intMDS_SBSR")
}
function MDS_SBSR(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_SBSR",frame,frame2)
}
function MDS_SBSRA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_SBSR")
}
function MDS_SBSRA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_SBSRA",frame,frame2)
}

function intMDS_Top()
{
	global newTSX = MDS_SzX
	global newTSY = MDS_SzY
	global newBSX = MDS_QSzX
	global newBSY = MDS_QSzY
	global newTPX = 0
	global newTPY = 0
	global newBPX = MDS_SzX
	global newBPY = MDS_SzY - MDS_QSzY
}
function MDS_Top(clip raw)
{
	MDS_SameCode(raw,"intMDS_Top")
}
function MDS_Top(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_Top",frame,frame2)
}
function MDS_TopA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_Top")
}
function MDS_TopA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_TopA",frame,frame2)
}


function intMDS_TopO()
{
	global newTSX = MDS_SzX
	global newTSY = MDS_SzY
	global newBSX = MDS_QSzX
	global newBSY = MDS_QSzY
	global newTPX = MDS_Border
	global newTPY = 0
	global newBPX = MDS_MaxX
	global newBPY = MDS_SzY - MDS_QSzY
}
function MDS_TopO(clip raw)
{
	MDS_SameCode(raw,"intMDS_TopO")
}
function MDS_TopO(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_TopO",frame,frame2)
}
function MDS_TopOA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_TopO")
}
function MDS_TopOA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_TopOA",frame,frame2)
}

function intMDS_BotO()
{
	global newTSX = MDS_QSzX
	global newTSY = MDS_QSzY
	global newBSX = MDS_SzX
	global newBSY = MDS_SzY
	global newTPX = -MDS_QSzX
	global newTPY = 0
	global newBPX = MDS_Border
	global newBPY = 0
}
function MDS_BotO(clip raw)
{
	MDS_SameCode(raw,"intMDS_BotO")
}
function MDS_BotO(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_BotO",frame,frame2)
}
function MDS_BotOA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_BotO")
}
function MDS_BotOA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_BotOA",frame,frame2)
}


function intMDS_Bot()
{
	global newTSX = MDS_QSzX
	global newTSY = MDS_QSzY
	global newBSX = MDS_SzX
	global newBSY = MDS_SzY
	global newTPX = 0
	global newTPY = 0
	global newBPX = MDS_QSzX
	global newBPY = 0
}
function MDS_Bot(clip raw)
{
	MDS_SameCode(raw,"intMDS_Bot")
}
function MDS_Bot(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_Bot",frame,frame2)
}
function MDS_BotA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_Bot")
}
function MDS_BotA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_BotA",frame,frame2)
}

function intMDS_TopHSlide()
{
	global newTSX = MDS_SzX
	global newTSY = MDS_SzY
	global newBSX = MDS_SzX
	global newBSY = MDS_SzY
	global newTPX = MDS_Border
	global newTPY = 0
	global newBPX = MDS_SzX + MDS_Border
	global newBPY = 0
}
function MDS_TopHSlide(clip raw)
{
	MDS_SameCode(raw,"intMDS_TopHSlide")
}
function MDS_TopHSlide(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_TopHSlide",frame,frame2)
}
function MDS_TopHSlideA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_TopHSlide")
}
function MDS_TopHSlideA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_TopHSlideA",frame,frame2)
}

function intMDS_BotHSlide()
{
	global newTSX = MDS_SzX
	global newTSY = MDS_SzY
	global newBSX = MDS_SzX
	global newBSY = MDS_SzY
	global newTPX = -MDS_SzX + MDS_Border
	global newTPY = 0
	global newBPX = MDS_Border
	global newBPY = 0
}
function MDS_BotHSlide(clip raw)
{
	MDS_SameCode(raw,"intMDS_BotHSlide")
}
function MDS_BotHSlide(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_BotHSlide",frame,frame2)
}
function MDS_BotHSlideA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_BotHSlide")
}
function MDS_BotHSlideA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_BotHSlideA",frame,frame2)
}

function intMDS_TopVSlide()
{
	global newTSX = MDS_SzX
	global newTSY = MDS_SzY
	global newBSX = MDS_SzX
	global newBSY = MDS_SzY
	global newTPX = MDS_Border
	global newTPY = 0
	global newBPX = MDS_Border
	global newBPY = MDS_SzY
}
function MDS_TopVSlide(clip raw)
{
	MDS_SameCode(raw,"intMDS_TopVSlide")
}
function MDS_TopVSlide(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_TopVSlide",frame,frame2)
}
function MDS_TopVSlideA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_TopVSlide")
}
function MDS_TopVSlideA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_TopVSlideA",frame,frame2)
}

function intMDS_BotVSlide()
{
	global newTSX = MDS_SzX
	global newTSY = MDS_SzY
	global newBSX = MDS_SzX
	global newBSY = MDS_SzY
	global newTPX = MDS_Border
	global newTPY = -MDS_SzY
	global newBPX = MDS_Border
	global newBPY = 0
}
function MDS_BotVSlide(clip raw)
{
	MDS_SameCode(raw,"intMDS_BotVSlide")
}
function MDS_BotVSlide(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_BotVSlide",frame,frame2)
}
function MDS_BotVSlideA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_BotVSlide")
}
function MDS_BotVSlideA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_BotVSlideA",frame,frame2)
}

function intMDS_VertStack()
{
	global newTSX = MDS_SBSX
	global newTSY = MDS_SBSY
	global newBSX = MDS_SBSX
	global newBSY = MDS_SBSY
	global newTPX = MDS_Border + floor((MDS_SzX - MDS_SBSX) / 2)
	global newTPY = 0
	global newBPX = MDS_Border + floor((MDS_SzX - MDS_SBSX) / 2)
	global newBPY = MDS_SBSY
}
function MDS_VertStack(clip raw)
{
	MDS_SameCode(raw,"intMDS_VertStack")
}
function MDS_VertStack(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_VertStack",frame,frame2)
}
function MDS_VertStackA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_VertStack")
}
function MDS_VertStackA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_VertStackA",frame,frame2)
}

function intMDS_VertStackGap()
{
	# This is adapted from a function from YamiNoSenshi
	# ps this whole weird - business is about using a nice filter for the final resize
	global MDS_OneTimeUseDown = (LeftStr(string(MDS_VertStackGapGap),1) == "-") ? true : false

	TempGap = (MDS_VertStackGapGap >= 0) ? MDS_VertStackGapGap : -MDS_VertStackGapGap

	totallines = MDS_BaseSizeY * 2 + TempGap

	ratio = float(MDS_BaseSizeY) / float(totallines)

	NewX = floor(MDS_SzX * ratio)
	NewY = floor(MDS_SzY * ratio)

	global newTSX = NewX
	global newTSY = NewY
	global newBSX = NewX
	global newBSY = NewY
	global newTPX = MDS_Border + floor((MDS_SzX - NewX) / 2)
	global newTPY = 0
	global newBPX = MDS_Border + floor((MDS_SzX - NewX) / 2)
	global newBPY = MDS_MaxY - NewY
}
function MDS_VertStackGap(clip raw, string "gap")
{
	gap = default(gap,string(MDS_VertStackGapGap))
	global MDS_VertStackGapGap = Value(gap)
	MDS_SameCode(raw,"intMDS_VertStackGap")
}
function MDS_VertStackGap(clip c, clip raw, int frame, int "frame2", string "gap")
{
	gap = default(gap,string(MDS_VertStackGapGap))
	global MDS_VertStackGapGap = Value(gap)
	MDS_SameCodeA(c,raw,"MDS_VertStackGap",frame,frame2)
}
function MDS_VertStackGapA(clip raw, string "gap")
{
	gap = default(gap,string(MDS_VertStackGapGap))
	global MDS_VertStackGapGap = Value(gap)
	MDS_SameCodeA(raw,"intMDS_VertStackGap")
}
function MDS_VertStackGapA(clip c, clip raw, int frame, int "frame2", string "gap")
{
	gap = default(gap,string(MDS_VertStackGapGap))
	global MDS_VertStackGapGap = Value(gap)
	MDS_SameCodeA(c,raw,"MDS_VertStackGapA",frame,frame2)
}


function intMDS_SideWays()
{
	ThreeHeight = MDS_SzY
	ThreeWidth = floor(3 * (ThreeHeight / 4))
	global newTSX = ThreeWidth
	global newTSY = ThreeHeight
	global newBSX = ThreeWidth
	global newBSY = ThreeHeight
	global newTPX = (MDS_MaxX / 2) - ThreeWidth
	global newTPY = 0
	global newBPX = (MDS_MaxX / 2)
	global newBPY = 0
}
function MDS_SideWays(clip raw)
{
	MDS_SameCode(raw,"intMDS_SideWays")
}
function MDS_SideWays(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_SideWays",frame,frame2)
}
function MDS_SideWaysA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_SideWays")
}
function MDS_SideWaysA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_SideWaysA",frame,frame2)
}

function intMDS_SideWaysGap()
{
	# This is adapted from a function from YamiNoSenshi

	TempGap = (MDS_SidewaysGapGap >= 0) ? MDS_SidewaysGapGap : -MDS_SidewaysGapGap

	totallines = MDS_BaseSizeY * 2 + TempGap
	ratio = float(MDS_BaseSizeY) / float(totallines)

	# So if gap is too small, this will accidently zoom into the content, so, if ratio * height > three height, just do it normally?

	ThreeHeight = MDS_SzY
	ThreeWidth = floor(3 * (ThreeHeight / 4))

	NewX = floor(MDS_MaxX * ratio)
	NewY = floor((NewX * 4) / 3)

	# If these would be oversized, don't zoom in
	l = (NewY > MDS_MaxY) ? eval("""
		ScaledGap = floor(float(TempGap) * (float(ThreeWidth) / float(MDS_BaseSizeY)))
		global newTSX = ThreeWidth
		global newTSY = ThreeHeight
		global newBSX = ThreeWidth
		global newBSY = ThreeHeight
		global newTPX = floor((MDS_MaxX - ScaledGap) / 2) - ThreeWidth
		global newTPY = 0
		global newBPX = floor((MDS_MaxX + ScaledGap) / 2)
		global newBPY = 0
	""") : eval ("""
		# Otherwise scale them down
		global MDS_OneTimeUseDown = (LeftStr(string(MDS_SidewaysGapGap),1) == "-") ? true : false

		global newTSX = NewX
		global newTSY = NewY
		global newBSX = NewX
		global newBSY = NewY
		global newTPX = 0
		global newTPY = floor((MDS_MaxY - NewY) / 2)
		global newBPX = MDS_MaxX - NewX
		global newBPY = floor((MDS_MaxY - NewY) / 2)
	""")
}
function MDS_SideWaysGap(clip raw, string "gap")
{
	gap = default(gap,string(MDS_SidewaysGapGap))
	global MDS_SidewaysGapGap = Value(gap)
	MDS_SameCode(raw,"intMDS_SideWaysGap")
}
function MDS_SideWaysGap(clip c, clip raw, int frame, int "frame2", string "gap")
{
	gap = default(gap,string(MDS_SidewaysGapGap))
	global MDS_SidewaysGapGap = Value(gap)
	MDS_SameCodeA(c,raw,"MDS_SideWaysGap",frame,frame2)
}
function MDS_SideWaysGapA(clip raw, string "gap")
{
	gap = default(gap,string(MDS_SidewaysGapGap))
	global MDS_SidewaysGapGap = Value(gap)
	MDS_SameCodeA(raw,"intMDS_SideWaysGap")
}
function MDS_SideWaysGapA(clip c, clip raw, int frame, int "frame2", string "gap")
{
	gap = default(gap,string(MDS_SidewaysGapGap))
	global MDS_SidewaysGapGap = Value(gap)
	MDS_SameCodeA(c,raw,"MDS_SideWaysGapA",frame,frame2)
}

function intMDS_SideWaysCGap()
{
	ThreeHeight = MDS_SzY
	ThreeWidth = floor(3 * (ThreeHeight / 4))
	global newTSX = ThreeWidth
	global newTSY = ThreeHeight
	global newBSX = ThreeWidth
	global newBSY = ThreeHeight
	global newTPX = 0
	global newTPY = 0
	global newBPX = MDS_MaxX - ThreeWidth
	global newBPY = 0
}
function MDS_SideWaysCGap(clip raw)
{
	MDS_SameCode(raw,"intMDS_SideWaysCGap")
}
function MDS_SideWaysCGap(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_SideWaysCGap",frame,frame2)
}
function MDS_SideWaysCGapA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_SideWaysCGap")
}
function MDS_SideWaysCGapA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_SideWaysCGapA",frame,frame2)
}

function intMDS_RotateEffectSub()
{
	FakeNewHeight = floor(4 * (MDS_SBSY / 3))
	global newTSX = MDS_SBSY
	global newTSY = FakeNewHeight
	global newBSX = MDS_SBSY
	global newBSY = FakeNewHeight
	global newTPX = floor(MDS_MaxX / 2) - MDS_SBSY
	global newTPY = floor((MDS_MaxY - FakeNewHeight) / 2)
	global newBPX = floor(MDS_MaxX / 2)
	global newBPY = floor((MDS_MaxY - FakeNewHeight) / 2)
}
function MDS_RotateEffectSub(clip raw)
{
	MDS_SameCode(raw,"intMDS_RotateEffectSub")
}
function MDS_RotateEffectSub(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_RotateEffectSub",frame,frame2)
}
function MDS_RotateEffectSubA(clip raw)
{
	MDS_SameCodeA(raw,"intMDS_RotateEffectSub")
}
function MDS_RotateEffectSubA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_RotateEffectSubA",frame,frame2)
}
function MDS_VStackToRotated(clip c, clip raw, int frame, bool "RightInstead")
{
	y = trim(c,frame,frame+AFC)
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	direction = (MDS_RotatedToRight == FALSE) ? -90 : 90
	r = trim(c,0,frame - 1) + Animate(y,0,AFC,"intMDS_RotationWrapper",0,direction)
	MDS_SetVerticalMode()
	intMDS_RotateEffectSub()
	MDS_Custom(r,raw,frame + AFC)	# this is a problem!
	# Is it a problem? It doesn't seem like a problem? Maybe this is old me commenting re not having frame2?
}
function MDS_RotatedToVStack(clip c, clip raw, int frame, int "RightInstead")
{
	y = trim(c,frame,frame+AFC)
	global MDS_RotatedToRight = Default(RightInstead,MDS_RotatedToRight)
	direction = (MDS_RotatedToRight == FALSE) ? 90 : -90
	r = trim(c,0,frame - 1) + Animate(y,0,AFC,"intMDS_RotationWrapper",0,direction)
	MDS_SetHorizontalMode()
	intMDS_VertStack()
	MDS_Custom(r,raw,frame + AFC)
}
function intMDS_RotationWrapper(clip c, int val)
{
	try
	{
	eval (MDS_RotationPluginCall)
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform Zoom? You need to get the Zoom plugin from the avisynth website, or use MDS_ChangeAnimWorker("your filter call here")
""" + err_msg)
	}
}

function MDS_Custom_TargetData(int TSX,int TSY,int BSX, int BSY, int TPX, int TPY, int BPX, int BPY)
{
	global newTSX = TSX
	global newTSY = TSY
	global newBSX = BSX
	global newBSY = BSY
	global newTPX = TPX
	global newTPY = TPY
	global newBPX = BPX
	global newBPY = BPY
}
function MDS_Custom(clip raw)
{
	MDS_ExceptionCheck(raw)
	MDS_UpdateGlobals()
	MDS_DoDSImmediate(raw)
}
function MDS_Custom(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_Custom",frame,frame2)
}
function MDS_CustomA(clip raw)
{
	MDS_ExceptionCheck(raw)
	final = MDS_DoDSAnimate(raw)
	MDS_UpdateGlobals()
	return final
}
function MDS_CustomA(clip c, clip raw, int frame, int "frame2")
{
	MDS_SameCodeA(c,raw,"MDS_CustomA",frame,frame2)
}

function MDS_Dissolve(clip c, clip raw, int frame, string layout)
{
	MDS_ExceptionCheck(raw,frame)
	try {
	r = Eval(layout + "(raw)")
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably)
""" + err_msg)
	}
	l = Dissolve(trim(c,frame,frame + AFC), trim(r,frame +1,0),AFC).AudioDub(trim(raw,frame,0))
	Trim(c,0,frame - 1) + l
}

function MDS_DissolveToBot(clip c, clip raw, int frame, string "layout")
{
	layout = Default(layout, "MDS_BotVSlide")
	MDS_Dissolve(c, raw, frame, layout)
}
function MDS_DissolveToTop(clip c, clip raw, int frame, string "layout")
{
	layout = Default(layout, "MDS_TopVSlide")
	MDS_Dissolve(c, raw, frame, layout)
}

function MDS_Fade(clip c, clip raw, int frame, string layout, bool "fadeaudio")
{
	MDS_ExceptionCheck(raw,frame)
	fadeaudio = Default(fadeaudio, false)
	try {
	r = Eval(layout + "(raw)")
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably)
""" + err_msg)
	}
	k = floor(AFC/2)
	l = FadeOut(trim(c,frame,frame + k),k) + FadeIn(trim(r,frame + k + 3,0),k)
	l = (fadeaudio == false) ? Eval("""
		l.AudioDub(trim(raw,frame,0))
		""") : l
	Trim(c,0,frame - 1) + l
}

function MDS_LongFade(clip c, clip raw, int frame, string layout, bool "fadeaudio")
{
	MDS_ExceptionCheck(raw,frame)
	MDS_ExceptionCheck(raw,frame+AFC)
	fadeaudio = Default(fadeaudio, false)
	try {
	r = Eval(layout + "(raw)")
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably)
""" + err_msg)
	}
	k = floor(AFC)
	l = FadeOut(trim(c,frame,frame + k),k) + FadeIn(trim(r,frame + k + 3,0),k)
	l = (fadeaudio == false) ? Eval("""
		l.AudioDub(trim(raw,frame,0))
		""") : l
	Trim(c,0,frame - 1) + l
}

function MDS_FadeToBot(clip c, clip raw, int frame, string "layout", bool "fadeaudio")
{
	layout = Default(layout, "MDS_BotVSlide")
	fadeaudio = Default(fadeaudio, false)
	MDS_Fade(c,raw,frame,layout,fadeaudio)
}
function MDS_FadeToTop(clip c, clip raw, int frame, string "layout", bool "fadeaudio")
{
	layout = Default(layout, "MDS_TopVSlide")
	fadeaudio = Default(fadeaudio, false)
	MDS_Fade(c,raw,frame,layout,fadeaudio)
}

function MDS_CustomTransition(clip c, clip raw, int frame, string layout, string funcname)
{
	MDS_ExceptionCheck(raw,frame)
	try {
	r = Eval(layout + "(raw)")
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably)
""" + err_msg)
	}
	try {
	l = Eval(funcname + "(trim(c,frame,frame + AFC), trim(r,frame +1,0),AFC).AudioDub(trim(raw,frame,0))")
	}
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided transition function! (probably)
""" + err_msg)
	}
	Trim(c,0,frame - 1) + l
}

function MDS_flipflop(clip c, clip raw, string func1, string func2, int f1, int "f2", \
int "f3", int "f4", int "f5", int "f6",\
int "f7", int "f8", int "f9", int "f10",\
int "f11", int "f12", int "f13", int "f14",\
int "f15", int "f16", int "f17", int "f18",\
int "f19", int "f20", int "f21", int "f22",\
int "f23", int "f24", int "f25", int "f26",\
int "f27", int "f28", int "f29", int "f30",\
int "f31", int "f32", int "f33", int "f34",\
int "f35", int "f36", int "f37", int "f38",\
int "f39", int "f40", int "f41", int "f42")
{
		f2 = Default(f2,-100)
		f3 = Default(f3,-100)
		f4 = Default(f4,-100)

		r = Eval(func1 + "(c,raw,f1)")
		r = (f2 > -100) ? Eval(func2 + "(r,raw,f2)") : r

		i = (f3 > -100) ? Eval("""
			r = MDS_flipflop(r,raw,func1,func2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,\
			f13,f14,f15,f16,f17,f18,f19,f20,f21,f22,f23,f24,f25,f26,\
			f27,f28,f29,f30,f31,f32,f33,f34,f35,f36,f37,f38,f39,f40,f41,f42)
			""") : Eval("")

		return r
}

# Worker functions:

# Code used by basically everything:
function MDS_SameCode(clip raw, string FunctionName)
{
	MDS_ExceptionCheck(raw)
	try {	Eval(FunctionName + "()") }
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably)
""" + err_msg)
	}
	MDS_UpdateGlobals()
	MDS_DoDSImmediate(raw)
}
function MDS_SameCodeA(clip raw, string FunctionName)
{
	MDS_ExceptionCheck(raw)
	try {	Eval(FunctionName + "()") }
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided layout function! (probably)
""" + err_msg)
	}
	final = MDS_DoDSAnimate(raw)
	MDS_UpdateGlobals()
	return final
}
function MDS_SameCodeA(clip c, clip raw, string FunctionName, int frame, int "frame2")
{
	q = (RightStr(FunctionName,1) == "A") ? MDS_ExceptionCheck(raw,frame) : MDS_ExceptionCheck(raw)
	frame2 = Default(frame2,-100)
	l = (frame2 > -100) ? Eval("""
	MDS_ExceptionCheck(raw,frame2)
	intMDS_StorePos()
	""") : 1
	r = Trim(c,0,frame - 1) + Eval(FunctionName + "(trim(raw,frame,0))")
	l = (frame2 > -100) ? Eval("""
	intMDS_RecallPos()
	r = RightStr(FunctionName,1) == "A" ?	Trim(r,0,frame2-1) + MDS_CustomA(trim(raw,frame2,0)) : Trim(r,0,frame2-1) + MDS_Custom(trim(raw,frame2,0)) """) : r
	r
}

# Cropping functions, includes 2 extra for vert mode:
function intMDS_GetTop(clip c)
{
	crop(c,0,0,0,MDS_basesizeY)
}
function intMDS_GetBot(clip c)
{
	crop(c,0,MDS_basesizeY,0,0)
}
function intMDS_GetVertTop(clip c)
{
	l = (MDS_RotatedToRight == FALSE) ? TurnLeft(intMDS_GetTop(c)) : TurnRight(intMDS_GetBot(c))
	l
}
function intMDS_GetVertBot(clip c)
{
	l = (MDS_RotatedToRight == FALSE) ? TurnLeft(intMDS_GetBot(c)) : TurnRight(intMDS_GetTop(c))
	l
}

# Primary worker functions, for both instant and animated effects
function MDS_DoDSImmediate(clip c)
{
	a = Eval(MDS_GetTopFunc + "(c)")
	b = Eval(MDS_GetBotFunc + "(c)")

	a = Eval(MDS_ResizeOngoingFunc + "(a,newTSX,newTSY,FALSE)")
	b = Eval(MDS_ResizeOngoingFunc + "(b,newBSX,newBSY,TRUE)")
	BlankClip(a,width=MDS_MaxX,height=MDS_MaxY).AudioDub(c)
	final = (MDS_DrawBFirst == false) ? Eval("""
	""" + MDS_PositionOngoingFunc + """(a,newTPX,newTPY,FALSE)
	""" + MDS_PositionOngoingFunc + """(b,newBPX,newBPY,TRUE)
	""") : Eval("""
	""" + MDS_PositionOngoingFunc + """(b,newBPX,newBPY,TRUE)
	""" + MDS_PositionOngoingFunc + """(a,newTPX,newTPY,FALSE)
	""")
	return final
}
function MDS_DoDSAnimate(clip c)
{
	a = Eval(MDS_GetTopFunc + "(c)")
	b = Eval(MDS_GetBotFunc + "(c)")
	BASE = BlankClip(a,width=MDS_MaxX,height=MDS_MaxY).AudioDub(c)
	try {
	q = eval(MDS_AnimFunc + "(a,0,AFC,LastTopSizeX,LastTopSizeY,newTSX,newTSY,FALSE)")
	r = eval(MDS_AnimFunc + "(b,0,AFC,LastBotSizeX,LastBotSizeY,newBSX,newBSY,TRUE)")
	final = (MDS_DrawBFirst == false) ? Eval("""
		BASE.""" + MDS_PositionFunc + """ (q,0,AFC,LastTopPosX,LastTopPosY,newTPX,newTPY,FALSE).""" + MDS_PositionFunc + """(r,0,AFC,LastBotPosX,LastBotPosY,newBPX,newBPY,TRUE)
		""") : Eval("""
		BASE.""" + MDS_PositionFunc + """ (r,0,AFC,LastBotPosX,LastBotPosY,newBPX,newBPY,TRUE).""" + MDS_PositionFunc + """(q,0,AFC,LastTopPosX,LastTopPosY,newTPX,newTPY,FALSE)
		""")
	}
	catch (err_msg)
	{
		Assert(0 == 1, """Error processing animations, probably bad function name?
""" + err_msg)
	}

	return final
}

# Default Position and Resize functions:
Function MDS_PositionCore(clip Base, clip AddMe, int start, int end, int StartX, int StartY, int EndX, int EndY, bool IsBottom)
{
	AnimatedSection = Animate(Base,start,end,MDS_PositionAnimFunc,AddMe,StartX,StartY,0,IsBottom,AddMe,EndX,EndY,AFC,IsBottom)#.trim(start,end)
	OngoingSection = eval(MDS_PositionOngoingFunc + "(trim(Base,end + 1,0),trim(AddMe,end+1,0),EndX,EndY,IsBottom)")
	return AnimatedSection + OngoingSection
}

Function MDS_AnimPosition(clip Base, clip AddMe, int X, int Y, int step, bool IsBottom)
{
	layer(Base,AddMe,"ADD",256,X,Y)
}

Function MDS_PositionNonAnim(clip Base, clip AddMe, int X, int Y, bool IsBottom)
{
	layer(Base,AddMe,"ADD",256,X,Y)
}

Function MDS_AnimResizeCore(clip c, int start, int end, int StartX, int StartY, int EndX, int EndY, bool IsBottom)
{
	output = Animate(c,start,end,"MDS_AnimResize",StartX,StartY,MDS_AnimResizeFilter,EndX,EndY,MDS_AnimResizeFilter).trim(start,end)
	string s = (EndX >= MDS_basesizeX) ? MDS_FinalResizeUp : MDS_FinalResizeDown
	output = eval("output + c.trim(AFC + 1,0)." + MDS_ResizeOngoingFunc + "(EndX,EndY,IsBottom)")
	return output
}

Function MDS_AnimResize(clip c, int x, int y, string "method")
{
	blank = BlankClip(c,width = MDS_SzX,height = MDS_SzY)
	c = (MDS_BlockPreserve > 1) ? PointResize(c,c.width() * MDS_BlockPreserve,c.height() * MDS_BlockPreserve) : c
	f = Default(method,"PointResize")
	try {	q = Eval("c." + f + "(x,y)") }
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided resize function! (probably)
""" + err_msg)
	}
	Layer(blank,q)
}

Function MDS_ResizeNonAnim(clip c, int x, int y, bool IsBottom)
{
	blank = BlankClip(c,width = MDS_SzX,height = MDS_SzY)
	c = (MDS_BlockPreserve > 1) ? PointResize(c,c.width() * MDS_BlockPreserve,c.height() * MDS_BlockPreserve) : c
	string s = (x >= MDS_basesizeX) ? MDS_FinalResizeUp : MDS_FinalResizeDown
	l = (MDS_OneTimeUseDown == true) ? eval("""
		s = MDS_FinalResizeDown
		global MDS_OneTimeUseDown = false
	""") : 0
	try {	q = Eval("c." + s + "(x,y)") }
	catch (err_msg) {
		Assert(0 == 1, """Couldn't perform provided resize function! (probably)
""" + err_msg)
	}
	Layer(blank,q)
}

# Global setting functions, extra var set used for new 'back/forth' effects due to custom layout support
function MDS_UpdateGlobals()
{
	global LastTopSizeX = newTSX
	global LastTopSizeY = newTSY
	global LastBotSizeX = newBSX
	global LastBotSizeY = newBSY

	global LastTopPosX = newTPX
	global LastTopPosY = newTPY
	global LastBotPosX = newBPX
	global LastBotPosY = newBPY
}
Function intMDS_StorePos()
{
	global MDS_MemTSX = LastTopSizeX
	global MDS_MemTSY = LastTopSizeY
	global MDS_MemBSX = LastBotSizeX
	global MDS_MemBSY = LastBotSizeY

	global MDS_MemTPX = LastTopPosX
	global MDS_MemTPY = LastTopPosY
	global MDS_MemBPX = LastBotPosX
	global MDS_MemBPY = LastBotPosY
}
Function intMDS_RecallPos()
{
	global newTSX = MDS_MemTSX
	global newTSY = MDS_MemTSY
	global newBSX = MDS_MemBSX
	global newBSY = MDS_MemBSY
	global newTPX = MDS_MemTPX
	global newTPY = MDS_MemTPY
	global newBPX = MDS_MemBPX
	global newBPY = MDS_MemBPY
}

# Exception Checks:
Function MDS_ExceptionCheck(clip raw)
{
	Assert(width(raw) == MDS_basesizeX, "MDS Error: Raw clip not " + string(MDS_basesizeX) + " pixels wide")
	Assert(height(raw) == 2 * MDS_basesizeY, "MDS Error: Raw clip not " + string(MDS_basesizeY) + " pixels high")
}
Function MDS_ExceptionCheck(clip raw, int frame)
{
	MDS_ExceptionCheck(raw)
	Assert(frame >= MDS_LastFrame, "MDS Error: Frame " + string(frame) + " is smaller than lastframe+AFC (" + string(MDS_LastFrame) + ") - call MDS_ResetLastframe() if not an error")
	global MDS_LastFrame = frame + AFC
}

# Debug function, not very useful
Function intMDS_DrawDebug(clip c)
{
	# Note that this is kind of useless, since it will be applied to all frames regardless of the state things are at the time.
	c
	Subtitle("Last: TopS (" + string(LastTopSizeX) + "," + string(LastTopSizeY) + ") BotS (" + \
	string(LastBotSizeX) + "," + string(LastBotSizeY) + ") TopP (" + string(LastTopPosX) + "," + \
	string(LastTopPosY) + ") BotP (" + string(LastBotPosX) + "," + \
	string(LastBotPosY) + ")")

	Subtitle("New: TopS (" + string(newTSX) + "," + string(newTSY) + ") BotS (" + \
	string(newBSX) + "," + string(newBSY) + ") TopP (" + string(newTPX) + "," + \
	string(newTPY) + ") BotP (" + string(newBPX) + "," + \
	string(newBPY) + ")", y = 100)
}
