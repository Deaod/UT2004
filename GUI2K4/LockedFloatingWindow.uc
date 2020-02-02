//==============================================================================
//  Created on: 12/29/2003
//  This implementation of floating window has an internal frame, and is intended for
//  menus which contain one or two large components (like lists)
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class LockedFloatingWindow extends FloatingWindow;

var automated GUISectionBackground sb_Main;
var automated GUIButton b_Cancel, b_OK;

var() localized string SubCaption;  // this is the caption that will go onto the sectionbackground header
var() float EdgeBorder[4];

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

	if ( SubCaption != "" )
		sb_Main.Caption = SubCaption;

	AlignButtons();

}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if ( Sender == Self )
		NewComp.bBoundToParent = True;
	else Super.InternalOnCreateComponent(NewComp, Sender);
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_OK )
	{
		Controller.CloseMenu(false);
		return true;
	}

	if ( Sender == b_Cancel )
	{
		Controller.CloseMenu(true);
		return true;
	}

	return false;
}

function AlignButtons()
{
	local float X,Y,Xs,Ys;
	local float WIP,HIP;

	WIP = ActualWidth();
	HIP = ActualHeight();

	Xs = b_Ok.ActualWidth() * 0.1;
	Ys = b_Ok.ActualHeight() * 0.1;

	X = 1 - ( (b_Ok.ActualWidth()  + Xs) / WIP) - (EdgeBorder[2] / WIP);
	Y = 1 - ( (b_Ok.ActualHeight() + Ys) / HIP) - (EdgeBorder[3] / WIP);

	b_Ok.WinLeft = X;
	b_Ok.WinTop = Y;

	X = 1 -( (b_Ok.ActualWidth() + b_Cancel.ActualWidth() + Xs) / WIP) - (EdgeBorder[2] / WIP);

	b_Cancel.WinLeft = X;
	b_Cancel.WinTop = Y;
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=InternalFrameImage
         WinTop=0.075000
         WinLeft=0.040000
         WinWidth=0.675859
         WinHeight=0.550976
         OnPreDraw=InternalFrameImage.InternalPreDraw
     End Object
     sb_Main=AltSectionBackground'GUI2K4.LockedFloatingWindow.InternalFrameImage'

     Begin Object Class=GUIButton Name=LockedCancelButton
         Caption="Cancel"
         bAutoShrink=False
         WinTop=0.872397
         WinLeft=0.512695
         WinWidth=0.159649
         TabOrder=99
         bBoundToParent=True
         OnClick=LockedFloatingWindow.InternalOnClick
         OnKeyEvent=LockedCancelButton.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'GUI2K4.LockedFloatingWindow.LockedCancelButton'

     Begin Object Class=GUIButton Name=LockedOKButton
         Caption="OK"
         bAutoShrink=False
         WinTop=0.872397
         WinLeft=0.742188
         WinWidth=0.159649
         TabOrder=100
         bBoundToParent=True
         OnClick=LockedFloatingWindow.InternalOnClick
         OnKeyEvent=LockedOKButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.LockedFloatingWindow.LockedOKButton'

     EdgeBorder(0)=16.000000
     EdgeBorder(1)=24.000000
     EdgeBorder(2)=16.000000
     EdgeBorder(3)=24.000000
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     DefaultLeft=0.125000
     DefaultTop=0.150000
     DefaultWidth=0.740000
     DefaultHeight=0.700000
     bCaptureInput=True
     InactiveFadeColor=(B=60,G=60,R=60)
     WinTop=0.150000
     WinLeft=0.125000
     WinWidth=0.740000
     WinHeight=0.700000
}
