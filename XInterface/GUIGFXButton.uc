// ====================================================================
//  Class:  UT2K4UI.GUIButton
//
//	GUIGFXButton - The basic button class.  It can be used for icon buttons
//  or Checkboxes
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIGFXButton extends GUIButton
	Native;

#exec OBJ LOAD FILE=InterfaceContent.utx

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()	Int				ImageIndex;
var()	Material 		Graphic;		// The graphic to display
var()	eIconPosition	Position;		// How do we draw the Icon
var()	bool			bCheckBox;		// Is this a check box button (ie: supports 2 states)
var()	bool			bClientBound;	// Graphic is drawn using clientbounds if true

var		bool			bChecked;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	if ( bCheckBox )
		OnClick = InternalOnClick;

	if (Graphic==none && ImageIndex>=0 && ImageIndex < MyController.ImageList.Length)
		Graphic=MyController.ImageList[ImageIndex];
}

function SetChecked(bool bNewChecked)
{
	if (bCheckBox)
	{
		bChecked = bNewChecked;
		OnChange(Self);
	}
}

function bool InternalOnClick(GUIComponent Sender)
{
	if (bCheckBox)
		bChecked = !bChecked;

	OnChange(Self);
	return true;
}

defaultproperties
{
     bTabStop=False
}
