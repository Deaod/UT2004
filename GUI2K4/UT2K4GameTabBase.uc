//==============================================================================
//  Created on: 12/11/2003
//  Base class for Instant Action & Host Multiplayer tab panels
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4GameTabBase extends UT2K4TabPanel;

var UT2K4GamePageBase p_Anchor;	// Reference to the page that owns this tab

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	if (UT2K4GamePageBase(Controller.ActivePage) != None)
		p_Anchor = UT2K4GamePageBase(Controller.ActivePage);
}

function string Play()
{
	return "";
}

function SetFooterCaption( string NewCaption, optional float SecondsToFade )
{
	if ( p_Anchor != None && p_Anchor.t_Footer != None )
	{
		p_Anchor.t_Footer.SetCaption(NewCaption);
		if ( NewCaption != "" && SecondsToFade > 0.0 )
			p_Anchor.t_Footer.SetTimer(SecondsToFade);
	}
}

defaultproperties
{
     FadeInTime=0.250000
}
