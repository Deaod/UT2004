// ====================================================================
//  Class:  UT2K4UI.GUISplitter
//
//	GUISplitters allow the user to size two other controls (usually Panels)
//
//  Written by Jack Porter
//	Updated by Ron Prestenback
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class GUISplitter extends GUIPanel
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EGUISplitterType
{
	SPLIT_Vertical,
	SPLIT_Horizontal,
};

var()  EGUISplitterType  SplitOrientation;
var()  float             SplitPosition;			// 0.0 - 1.0
var()  bool              bFixedSplitter;		// Can splitter be moved?
var()  bool              bDrawSplitter;			// Draw the actual splitter bar
var()  float             SplitAreaSize;			// size of splitter thing

var()  string            DefaultPanels[2];		// Names of the default panels
var()  GUIComponent      Panels[2];				// Quick Reference
var()  float             MaxPercentage;			// How big can any 1 panel get

delegate OnReleaseSplitter(GUIComponent Sender, float NewPosition);	// Notification that finished resizing splitter

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    if (DefaultPanels[0]!="")
	{
		Panels[0] = AddComponent(DefaultPanels[0], DefaultPanels[1] != "");
		if (DefaultPanels[1]!="")
			Panels[1] = Addcomponent(DefaultPanels[1]);
    }
}

event GUIComponent AppendComponent(GUIComponent NewComp, optional bool SkipRemap)
{
    OnCreateComponent(NewComp, Self);
    Controls[Controls.Length] = NewComp;

    NewComp.InitComponent(Controller, Self);
	NewComp.bBoundToParent = true;
    NewComp.bScaleToParent = true;

    if (!SkipRemap)
	    RemapComponents();
    return NewComp;

}

native function SplitterUpdatePositions();

defaultproperties
{
     SplitPosition=0.500000
     bDrawSplitter=True
     SplitAreaSize=8.000000
     StyleName="SquareButton"
     bAcceptsInput=True
     bNeverFocus=True
}
