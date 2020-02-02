// ====================================================================
//  Class:  XInterface.GUIHorzScrollBar
//  Parent: XInterface.GUIScrollBarBase
//
//  Scrollbar assembly for horizontal lists.
// ====================================================================

class GUIHorzScrollBar extends GUIScrollBarBase;

// Record location you grabbed the grip
function GripPressed( GUIComponent Sender, bool IsRepeat )
{
	if ( !IsRepeat )
		GrabOffset = Controller.MouseX - MyGripButton.ActualLeft();
}

function bool GripPreDraw( GUIComponent Sender )
{
	local float NewPerc;

	if ( MyGripButton.MenuState != MSAT_Pressed )
		return false;

	// Calculate the new Grip Top using the mouse cursor location.
	NewPerc = FClamp(
		(Controller.MouseX - GrabOffset - MyScrollZone.ActualLeft()) / (MyScrollZone.ActualWidth() - GripSize),
		0.0, 1.0 );

	UpdateGripPosition(NewPerc);

	return false;
}

function ZoneClick(float Delta)
{
	if ( Controller.MouseX < MyGripButton.Bounds[0] )
		MoveGripBy(-BigStep);
	else if ( Controller.MouseX > MyGripButton.Bounds[2] )
		MoveGripBy(BigStep);

	return;
}

defaultproperties
{
     Orientation=ORIENT_Horizontal
     MinGripPixels=12
     Begin Object Class=GUIHorzScrollZone Name=HScrollZone
         OnScrollZoneClick=GUIHorzScrollBar.ZoneClick
         OnClick=HScrollZone.InternalOnClick
     End Object
     MyScrollZone=GUIHorzScrollZone'XInterface.GUIHorzScrollBar.HScrollZone'

     Begin Object Class=GUIHorzScrollButton Name=HRightBut
         bIncreaseButton=True
         OnClick=GUIHorzScrollBar.IncreaseClick
         OnKeyEvent=HRightBut.InternalOnKeyEvent
     End Object
     MyIncreaseButton=GUIHorzScrollButton'XInterface.GUIHorzScrollBar.HRightBut'

     Begin Object Class=GUIHorzScrollButton Name=HLeftBut
         OnClick=GUIHorzScrollBar.DecreaseClick
         OnKeyEvent=HLeftBut.InternalOnKeyEvent
     End Object
     MyDecreaseButton=GUIHorzScrollButton'XInterface.GUIHorzScrollBar.HLeftBut'

     Begin Object Class=GUIHorzGripButton Name=HGrip
         OnMousePressed=GUIHorzScrollBar.GripPressed
         OnKeyEvent=HGrip.InternalOnKeyEvent
     End Object
     MyGripButton=GUIHorzGripButton'XInterface.GUIHorzScrollBar.HGrip'

     WinWidth=0.037500
     bAcceptsInput=True
     OnPreDraw=GUIHorzScrollBar.GripPreDraw
}
