//==============================================================================
//	Listbox for the PlayInfoList
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class PlayInfoListBox extends GUIMultiColumnListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	HeaderColumnPerc = UT2K4Tab_RulesBase(MyOwner).HeaderColumnPerc;
	Super.InitComponent(MyController, MyOwner);
}

defaultproperties
{
     DefaultListClass="GUI2K4.PlayInfoList"
     StyleName="ListBox"
}
