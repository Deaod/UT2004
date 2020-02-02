//==============================================================================
//	Created on: 10/10/2003
//	Base class for non-fullscreen menus
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class PopupPageBase extends UT2K4GUIPage;

var automated FloatingImage    i_FrameBG;
var bool                       bFading, bClosing;
var(Fade) config float         FadeTime;
var(Fade) float                CurFadeTime;
var(Fade) byte                 CurFade, DesiredFade;

delegate FadedIn();
delegate FadedOut();

event Opened(GUIComponent Sender)
{
	if ( bCaptureInput )
		FadeIn();

	Super.Opened(Sender);
}

function bool InternalOnPreDraw( Canvas C )
{
	if ( !bFading )
		return false;

	if (CurFadeTime >= 0.0)
	{
		CurFade += float(DesiredFade - CurFade) * (Controller.RenderDelta / CurFadeTime);
		InactiveFadeColor = class'Canvas'.static.MakeColor(CurFade, CurFade, CurFade);
		CurFadeTime -= Controller.RenderDelta;

		if ( CurFadeTime < 0 )
		{
			CurFade = DesiredFade;
			InactiveFadeColor = class'Canvas'.static.MakeColor(CurFade, CurFade, CurFade);
			bFading = False;
			if ( bClosing )
			{
				bClosing = False;
				FadedOut();
			}
			else
				FadedIn();
		}
	}

    return false;
}

function FadeIn()
{
	if ( Controller.bModulateStackedMenus )
	{
		bClosing = False;
		bFading = True;
		CurFadeTime = FadeTime;
	}
	else FadedIn();
}

function FadeOut()
{
	if ( Controller.bModulateStackedMenus )
	{
		bFading = True;
		bClosing = True;
		CurFadeTime = FadeTime;
		DesiredFade = default.CurFade;
	}
	else FadedOut();
}

defaultproperties
{
     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'2K4Menus.NewControls.Display1'
         DropShadow=None
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.020000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=0.980000
         RenderWeight=0.000003
     End Object
     i_FrameBG=FloatingImage'GUI2K4.PopupPageBase.FloatingFrameBackground'

     FadeTime=0.350000
     CurFade=200
     DesiredFade=80
     bRenderWorld=True
     bRequire640x480=False
     BackgroundRStyle=MSTY_Modulated
     OnPreDraw=PopupPageBase.InternalOnPreDraw
}
