//==============================================================================
// Single Player Ladder page with only one ladder
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SPTab_SingleLadder extends UT2K4SPTab_LadderBase;

/**
	The ID of the single ladder to use
*/
var int LadderId;
/**
	Dimensions where the ladder tree should be displayed
*/
var float LadderTop, LadderLeft, LadderHeight;

var array<UT2K4LadderButton> Entries;
var array<GUILabel> Labels;
var array<AnimData> animEntries, animLabels;
/** labels to show next to the ladder button, entries should match the ladder */
var localized array<string> EntryLabels;
/** true if we already have animated the ladder, to prevent reanimation when the tab is already visible */
var bool bHasAnimated;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	Super.Initcomponent(pMyController, MyOwner);
	Entries = CreateVButtons(LadderId, LadderTop, LadderLeft, LadderHeight);
	CreateLabels();
	bInit = true;
}

function ShowPanel(bool bShow)
{
	local int i;
	Super.ShowPanel(bShow);
	if (bShow)
	{
		if (bInit)
		{
			bInit = false;
			animEntries = InitAnimData(Entries); // must be after CreateLabels()
			InitAnimLabels();
			for (i = 0; i < Entries.length; i++)
			{
				Entries[i].SetState(GetLadderProgress(LadderId));
			}
		}
		selectNextMatch();
		if (!bHasAnimated)
		{
			DoAnimate(Entries, animEntries);
			AnimateLabels();
		}
		bHasAnimated = true;
	}
	else {
		DoAnimate(Entries, animEntries, true);
		AnimateLabels(true);
		bHasAnimated = false;
	}
}

/**
	Create labels to go with the buttons
*/
function CreateLabels()
{
	local int i;
	local GUILabel lbl;
	Labels.length = Entries.length;
	for ( i = 0; i < Entries.length; i++ )
	{
		lbl = new class'GUILabel';
		lbl.WinLeft = (Entries[i].WinLeft+Entries[i].WinWidth)*1.05;
		lbl.WinTop = Entries[i].WinTop;
		lbl.WinHeight = Entries[i].WinHeight*0.95;
		lbl.WinWidth = (WinWidth/2)-lbl.WinLeft-LadderLeft;
		lbl.FontScale = FNS_Medium;
		lbl.ShadowColor.A = 128;
		lbl.ShadowOffsetX = 1;
		lbl.ShadowOffsetY = 1;
		//lbl.HiLightColor.R = 0;
		//lbl.HiLightColor.G = 0;
		//lbl.HiLightColor.B = 0;
		//lbl.HiLightColor.A = 64;
		//lbl.HiLightOffsetX = 1;
		//lbl.HiLightOffsetY = 1;
		//if (i >= (Entries.length/2)) lbl.StyleName = "DarkTextLabel";
		//	else lbl.StyleName = "TextLabel";
		lbl.StyleName = "NoBackground";
		lbl.bMultiLine=true;
		lbl.bBoundToParent = true;
		lbl.VertAlign = TXTA_Center;
		if (i < EntryLabels.length) lbl.Caption = EntryLabels[i];
			else lbl.Caption = "";
		AppendComponent(lbl);
		Labels[i] = lbl;
	}
}

/**
	Select the next match
*/
function selectNextMatch()
{
	local int offset;

	offset = min(GetLadderProgress(LadderId), Entries.length-1);
	if ((offset >= Entries.length) || (offset < 0)) return;
	while (offset >= 0)
	{
		if (GP.getMinimalEntryFeeFor(Entries[offset].MatchInfo) <= GP.Balance)
		{
			onMatchClick(Entries[offset]);
			return;
		}
		offset--;
	}
}

function AnimateLabels(optional bool breset)
{
	local int i;
	for (i = 0; i < Labels.length; i++)
	{
		if (breset)
		{
			Labels[i].WinLeft = 0-Labels[i].WinWidth;
		}
		else {
			Labels[i].Animate(animLabels[i].X, animLabels[i].Y, AnimTime*(float(i)/float(Labels.length)));
		}
	}
}

function InitAnimLabels()
{
	local int i;
	animLabels.length = Labels.length;
	for (i = 0; i < Labels.length; i++)
	{
		animLabels[i].X = Labels[i].WinLeft;
		animLabels[i].Y = Labels[i].WinTop;
	}
	AnimateLabels(true);
}

defaultproperties
{
     LadderId=-1
     LadderTop=0.050000
     LadderLeft=0.050000
     LadderHeight=0.800000
}
