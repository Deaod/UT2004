//==============================================================================
//	Description
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class GUIListSpacer extends GUIMenuOption;

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if ( Sender == self && GUILabel(NewComp) != None )
		NewComp.FontScale = FontScale;

	Super.InternalOnCreateComponent(NewComp, Sender);
}

defaultproperties
{
     CaptionWidth=1.000000
     ComponentWidth=0.000000
     ComponentClassName="XInterface.GUILabel"
     StyleName="NoBackground"
     Tag=-2
     bNeverFocus=True
     OnClickSound=CS_None
}
