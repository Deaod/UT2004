// ====================================================================
//  Class:  XInterface.GUIVertScrollBar
//	Parent: Xinterface.GUIScrollBarBase
//
//  Custom scrollbar for vertical lists
// ====================================================================

class GUIVertScrollBar extends GUIScrollBarBase;

// Record location you grabbed the grip
function GripPressed( GUIComponent Sender, bool IsRepeat )
{
	if ( !IsRepeat )
		GrabOffset = Controller.MouseY - MyGripButton.ActualTop();
}

function bool GripPreDraw( GUIComponent Sender )
{
	local float NewPerc;

	if ( MyGripButton.MenuState != MSAT_Pressed )
		return false;

	// Calculate the new Grip Top using the mouse cursor location.
	NewPerc = FClamp(
		(Controller.MouseY - GrabOffset - MyScrollZone.ActualTop()) / (MyScrollZone.ActualHeight() - GripSize),
		0.0, 1.0 );

	UpdateGripPosition(NewPerc);

	return true;
}

function ZoneClick(float Delta)
{
	if ( Controller.MouseY < MyGripButton.Bounds[1] )
		MoveGripBy(-BigStep);
	else if ( Controller.MouseY > MyGripButton.Bounds[3] )
		MoveGripBy(BigStep);

	return;
}

defaultproperties
{
     MinGripPixels=12
     Begin Object Class=GUIVertScrollZone Name=ScrollZone
         OnScrollZoneClick=GUIVertScrollBar.ZoneClick
         OnClick=ScrollZone.InternalOnClick
     End Object
     MyScrollZone=GUIVertScrollZone'XInterface.GUIVertScrollBar.ScrollZone'

     Begin Object Class=GUIVertScrollButton Name=DownBut
         bIncreaseButton=True
         OnClick=GUIVertScrollBar.IncreaseClick
         OnKeyEvent=DownBut.InternalOnKeyEvent
     End Object
     MyIncreaseButton=GUIVertScrollButton'XInterface.GUIVertScrollBar.DownBut'

     Begin Object Class=GUIVertScrollButton Name=UpBut
         OnClick=GUIVertScrollBar.DecreaseClick
         OnKeyEvent=UpBut.InternalOnKeyEvent
     End Object
     MyDecreaseButton=GUIVertScrollButton'XInterface.GUIVertScrollBar.UpBut'

     Begin Object Class=GUIVertGripButton Name=Grip
         OnMousePressed=GUIVertScrollBar.GripPressed
         OnKeyEvent=Grip.InternalOnKeyEvent
     End Object
     MyGripButton=GUIVertGripButton'XInterface.GUIVertScrollBar.Grip'

     WinWidth=0.025000
     bAcceptsInput=True
     OnPreDraw=GUIVertScrollBar.GripPreDraw
}
