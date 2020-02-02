//==============================================================================
//	Created on: 08/23/2003
//	Base class for scroll zone grip buttons
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class GUIGripButtonBase extends GUIGFXButton
	native;

defaultproperties
{
     Position=ICP_Bound
     StyleName="RoundButton"
     bNeverFocus=True
     bRequireReleaseClick=True
     OnClickSound=CS_None
}
