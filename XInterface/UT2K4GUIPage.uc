//==============================================================================
//	Created on: 08/15/2003
//	Base class for all UT2004 GUIPages
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4GUIPage extends GUIPage
	abstract;

var Sound PopInSound, SlideInSound, FadeInSound, BeepSound;

defaultproperties
{
     PopInSound=Sound'2K4MenuSounds.MainMenu.OptionIn'
     SlideInSound=Sound'2K4MenuSounds.MainMenu.GraphSlide'
     FadeInSound=Sound'2K4MenuSounds.MainMenu.CharFade'
     BeepSound=Sound'MenuSounds.select3'
     WinTop=0.375000
     WinHeight=0.500000
}
