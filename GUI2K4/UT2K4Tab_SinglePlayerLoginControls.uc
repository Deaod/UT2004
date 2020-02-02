//==============================================================================
// Special tab for ladder matches
// Player can't switch teams, can't become spectator
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4Tab_SinglePlayerLoginControls extends UT2K4Tab_PlayerLoginControls;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	b_Team.Hide();
}

function bool ButtonClicked(GUIComponent Sender)
{
	if ((Sender == i_JoinRed) || (Sender == i_JoinBlue)) return true;
	return Super.ButtonClicked(Sender);
}

function SetupGroups()
{
	RemoveComponent(b_Spec);
	Super.SetupGroups();
}

defaultproperties
{
}
