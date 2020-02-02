//==============================================================================
// Single Player Ladder page with only one ladder, to be used by a custom ladder
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SPTab_CustomLadder extends UT2K4SPTab_SingleLadder;

var string CustomLadderClass;
var int CustomLadderIndex;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	Super(UT2K4SPTab_LadderBase).Initcomponent(pMyController, MyOwner);
}

function InitCustom()
{
	CustomLadderIndex = GP.GetCustomLadder(CustomLadderClass);
	Entries = CreateVButtons(LadderId, LadderTop, LadderLeft, LadderHeight);
	CreateLabels();
	moveMatchInfo(-0.085, 0.25);
	bInit = true;
}

defaultproperties
{
}
