// ====================================================================
//  Base class for header / footer bars
//
//  Written by Joe Wilcox
//	Updated by Ron Prestenback
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUITitleBar extends GUIBorder
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var 			GUITabControl	DockedTabs;		// Set this to a Tab control and that control will be centered undeneath
var()			ePageAlign		DockAlign;		// How to Align the tabs.. only Left, Center and right work
var()			bool			bUseTextHeight;	// Should this control scale to the text height
var()			bool			bDockTop;		// If True, dock the control ON TOP of this one

var const Material Effect;  // obsolete

defaultproperties
{
     bUseTextHeight=True
     StyleName="TextLabel"
     bTabStop=False
}
