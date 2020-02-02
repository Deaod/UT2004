// ====================================================================
//  Class:  XInterface.GUIVertScrollZone
//	Parent: XInterface.GUIScrollZoneBase
//
//	Scrollzone implementation for vertical lists.
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIVertScrollZone extends GUIScrollZoneBase;

function bool InternalOnClick(GUIComponent Sender)
{
	local float perc;

	if (!IsInBounds())
		return false;

	perc = ( Controller.MouseY - ActualTop() ) / ActualHeight();
	OnScrollZoneClick(perc);

	return true;
}

defaultproperties
{
}
