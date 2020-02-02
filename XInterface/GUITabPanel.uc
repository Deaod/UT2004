// ====================================================================
//	GUITabButton - A Tab Button has an associated Tab Control, and
//  TabPanel.
//
//  Written by Joe Wilcox
//	Updated by Ron Prestenback
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUITabPanel extends GUIPanel
	native
	abstract;

var(Panel) localized string       PanelCaption;
var(Panel)           bool         bFillHeight;	// If true, the panel will set it's height = Top - ClipY
var(Panel)		     float        FadeInTime;
var noexport    GUITabButton      MyButton;

function Refresh();  // this function is used by all tab panels
function InitPanel();	// Should be Subclassed
function OnDestroyPanel(optional bool bCancelled)	// Always call Super.OnDestroyPanel()
{
	MyButton = None;
}

event Free()
{
	OnDestroyPanel(True);
	Super.Free();
}

function ShowPanel(bool bShow)	// Show Panel should be subclassed if any special processing is needed
{
	if ( Controller != None && Controller.bModAuthor )
		log("# # # #"@MyButton.Caption@"ShowPanel() "@bShow,'ModAuthor');

	SetVisibility(bShow);
}

function bool CanShowPanel()	// Subclass this function to change selection behavior of the tab
{
	return true;
}

defaultproperties
{
}
