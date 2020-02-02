//==============================================================================
// A timed label used to display subtitles
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class GUISubtitleText extends GUILabel;

/** each subtitle on a diffirent line */
var() array<string> SubTitles;
/** 
	Visible is the time this subtitle is vissible
	Delay is the time to wait to display the next sub title
*/
struct VisibleDelay
{
	var float Visible;
	var float Delay;
};
/** time to show a single subtitle */
var() array<VisibleDelay> SubTitleTiming;
/** default subtitle visibility, if <= 0 remain visible */
var() float VisibleTime;
/** default delay time */
var() float DelayTime;
/** initial delay */
var() float InitialDelay;
/** use by SetSubTitles to guess the delay, delay = guess time * no. chars */
var() float GuessCharTime;
/** default seperator */
var string Separator;

var protected int CurLine;
var protected enum eDisplayState {
	DS_Delay,
	DS_Visibility,
	DS_Stopped,
} DisplayState;

delegate OnStopped();

function Restart()
{
	CurLine = 0;
	Caption = "";
	DisplayState = DS_Delay;
	if (InitialDelay <= 0.0) SetTimer(0.001, true);
	else SetTimer(InitialDelay, true);
}

function Stop()
{
	Caption="";
	TimerInterval = 0;
	DisplayState = DS_Stopped;
	OnStopped();	
}

/** 
	Set the subtitles, using default timing 
	if bDontGuess == true lengthdata will be used (uses the same seperator)
	Return the number of items added
*/
function int SetSubtitles(string alldata, optional string sep, optional bool bDontGuess, optional string lengthdata)
{
	local array<string> newdata, datalength;
	local int i;
	if (sep == "") sep = Separator;
	split(alldata, sep, newdata);
	if (bDontGuess)	
	{
		split(lengthdata, sep, datalength);
		datalength.length = newdata.length;
	}
	ClearSubtitles();
	for (i = 0; i < newdata.length; i++)
	{
		if (bDontGuess)	AddSubtitle(newdata[i], float(datalength[i]));
			else 	AddSubtitle(newdata[i], GuessCharTime*Len(newdata[i]));
	}
	Restart();
	return i;
}

/** 
	Add a subtitle 
	if delay/visible is omitted or 0 the default value is used
	to have an actual 0 as visible/delay use a negative value
*/
function int AddSubtitle(string NewTitle, optional float delay, optional float Visible)
{
	return InsertSubtitle(SubTitles.length, NewTitle, delay, Visible);
}

/** 
	Insert a subtitle
	If the position is invalid -1 is returned
*/
function int InsertSubtitle(int position, string NewTitle, optional float delay, optional float Visible)
{
	if (position > SubTitles.Length) return -1;
	if (position < 0) return -1;	
	SubTitles.Insert(position, 1);
	SubTitleTiming.Insert(position, 1);
	SubTitles[position] = NewTitle;
	if (delay == 0) delay = DelayTime;
	SubTitleTiming[position].Delay = Max(delay, 0);
	if (visible == 0) visible = VisibleTime;
	if (visible >= delay) visible = 0;
	SubTitleTiming[position].Visible = Max(visible, 0);	
	//Log(":::: Added new subtitle: '"$NewTitle$"'"@delay@Visible@position);
	return position;
}

function ClearSubtitles()
{
	SubTitles.length = 0;
	SubTitleTiming.length = 0;
}

event Timer()
{
	if (CurLine >= SubTitles.length) 
	{
		Caption="";
		TimerInterval = 0;
		DisplayState = DS_Stopped;
		OnStopped();
		return;
	}
	if (DisplayState == DS_Delay)
	{
		Caption = SubTitles[CurLine];
		if (SubTitleTiming[CurLine].Visible > 0)
		{
			DisplayState = DS_Visibility;
			TimerInterval = SubTitleTiming[CurLine].Visible;
		}
		else {
			TimerInterval = SubTitleTiming[CurLine].delay;
			CurLine++;			
		}
	}
	else if (DisplayState == DS_Visibility) {
		Caption = "";
		DisplayState = DS_Delay;
		TimerInterval = SubTitleTiming[CurLine].delay-SubTitleTiming[CurLine].Visible;
		CurLine++;
	}
}

defaultproperties
{
     DelayTime=2.000000
     GuessCharTime=0.060000
     Separator="|"
     TextAlign=TXTA_Center
     bMultiLine=True
     StyleName="TextLabel"
}
