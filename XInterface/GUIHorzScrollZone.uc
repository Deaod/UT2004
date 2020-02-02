// ====================================================================
//  Class:  XInterface.GUIHorzScrollZone
//  Parent: XInterface.GUIComponent
//
//  Scrollzone implementation for horizontal lists.
// ====================================================================

class GUIHorzScrollZone extends GUIScrollZoneBase;

function bool InternalOnClick(GUIComponent Sender)
{
	local float perc;

	if (!IsInBounds())
		return false;

	perc = ( Controller.MouseX - ActualLeft() ) / ActualWidth();
	OnScrollZoneClick(perc);
	return true;
}

defaultproperties
{
}
