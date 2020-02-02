//==============================================================================
//	Created on: 10/10/2003
//	Base class for simple popups
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class MessageWindow extends PopupPageBase;

defaultproperties
{
     Begin Object Class=FloatingImage Name=MessageWindowFrameBackground
         Image=Texture'2K4Menus.NewControls.Display2'
         DropShadowX=0
         DropShadowY=0
         WinTop=0.000000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=1.000000
     End Object
     i_FrameBG=FloatingImage'GUI2K4.MessageWindow.MessageWindowFrameBackground'

     WinTop=0.300000
     WinHeight=0.380000
}
