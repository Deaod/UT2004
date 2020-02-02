// ====================================================================
//  Class:  UT2K4UI.GUIButton
//
//	GUIButton - The basic button class
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIButton extends GUIComponent
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()   eTextAlign					CaptionAlign;
var() editconst 	GUIStyles		CaptionEffectStyle;
var() 	string						CaptionEffectStyleName;
var()	localized	string			Caption;


var() struct native PaddingPercent
{ var() float HorzPerc, VertPerc; }  AutoSizePadding; // Padding (space) to insert around caption if autosizing

// When multiple buttons should be the same size, set this value to the longest caption of the group
// and all buttons will be sized using this caption instead
var()   string                      SizingCaption;
var()   bool						bAutoSize;	     // Size according to caption size.
var()   bool                        bAutoShrink;     // Reduce size of button if bAutoSize & caption is smaller than WinWidth
var()   bool                        bWrapCaption;    // Wrap the caption if its too long - ignored if bAutoSize = true
var()	bool						bUseCaptionHeight; // Get the Height from the caption


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local eFontScale x;
	Super.InitComponent(MyController, MyOwner);

    if (CaptionEffectStyleName!="")
    	CaptionEffectStyle = Controller.GetStyle(CaptionEffectStyleName,x);

}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ((key==0x0D || Key == 0x20) && State==1)	// ENTER or Space Pressed
	{
		OnClick(self);
		return true;
	}

	return false;
}

defaultproperties
{
     CaptionAlign=TXTA_Center
     AutoSizePadding=(HorzPerc=0.125000)
     bAutoShrink=True
     StyleName="SquareButton"
     WinHeight=0.040000
     bTabStop=True
     bAcceptsInput=True
     bCaptureMouse=True
     bMouseOverSound=True
     Begin Object Class=GUIToolTip Name=GUIButtonToolTip
     End Object
     ToolTip=GUIToolTip'XInterface.GUIButton.GUIButtonToolTip'

     OnClickSound=CS_Click
     StandardHeight=0.040000
     OnKeyEvent=GUIButton.InternalOnKeyEvent
}
