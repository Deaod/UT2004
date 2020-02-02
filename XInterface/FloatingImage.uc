//==============================================================================
//	Created on: 10/10/2003
//	This is a GUIImage that is not full screen, but should render beneath everything else
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class FloatingImage extends GUIImage;

defaultproperties
{
     DropShadow=Texture'2K4Menus.Floating.FloatingShadow'
     ImageStyle=ISTY_PartialScaled
     DropShadowX=6
     DropShadowY=6
     WinTop=0.375000
     WinLeft=0.250000
     WinWidth=0.500000
     WinHeight=0.350000
     RenderWeight=0.000001
     bBoundToParent=True
     bScaleToParent=True
}
