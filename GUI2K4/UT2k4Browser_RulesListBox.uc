//====================================================================
//  Written by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_RulesListBox extends ServerBrowserMCListBox;

event Opened(GUIComponent Sender)
{
	Super.Opened(Sender);

// Prevent updating of list if scrolling
	MyScrollBar.MyGripButton.OnMousePressed = tp_Anchor.MousePressed;
	MyScrollBar.MyGripButton.OnMouseRelease = tp_Anchor.MouseReleased;
}

defaultproperties
{
     DefaultListClass="GUI2K4.UT2K4Browser_RulesList"
}
