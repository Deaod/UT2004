//==============================================================================
//	Created on: 10/10/2003
//	Base class for larger non-full screen menus
//  Background images are sized according to the size of the page.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class LargeWindow extends FloatingWindow;

defaultproperties
{
     bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     bMoveAllowed=False
     bCaptureInput=True
     bRequire640x480=True
     InactiveFadeColor=(B=60,G=60,R=60)
     OnCreateComponent=None.None
     WinTop=0.200000
     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=0.600000
}
