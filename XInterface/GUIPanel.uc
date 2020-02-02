// ====================================================================
//  Class:  XInterface.GUIPanel
//
//  The GUI panel is a visual control that holds components.  All
//  components who are children of the GUIPanel are bound to the panel
//  by default.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIPanel extends GUIMultiComponent
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(Panel)	Material	Background;

Delegate bool OnPostDraw(Canvas Canvas);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.Initcomponent(MyController, MyOwner);

	for (i=0;i<Controls.length;i++)
	{
		Controls[i].bBoundToParent=true;
		Controls[i].bScaleToParent=true;
	}

}

defaultproperties
{
     PropagateVisibility=True
     bTabStop=False
}
