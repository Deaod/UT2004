//==============================================================================
//	Created on: 08/23/2003
//	Base class for the buttons on either side of a scroll zone
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class GUIScrollButtonBase extends GUIGFXButton
	native;

var() bool bIncreaseButton;		// Whether this button should increase the value or decrease the value.

defaultproperties
{
     Position=ICP_Scaled
     StyleName="RoundScaledButton"
     bNeverFocus=True
     bRepeatClick=True
}
