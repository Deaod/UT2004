// ====================================================================
//  Class:  xVoting.PlayerInfoMultiColumnListBox
//
//	Multi-Column list box used to display Player Info.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class PlayerInfoMultiColumnListBox extends GUIMultiColumnListBox;

//------------------------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super.InitComponent(MyController, MyOwner);
//	Header.Hide();
}
//------------------------------------------------------------------------------------------------
function Add(string Label, string Value)
{
	PlayerInfoMultiColumnList(List).Add(Label,Value);
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     DefaultListClass="xVoting.PlayerInfoMultiColumnList"
}
