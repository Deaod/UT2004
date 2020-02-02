//==============================================================================
//  Created on: 01/19/2004
//  Tooltip that appears when this component is moused over
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class GUIToolTip extends GUIComponent
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() bool bResetPosition; // Position of this component needs to be updated
var() bool bTrackMouse;    // This tooltip will follow the mouse as it moves
var() bool bMultiLine;     // Allow hint text to be wrapped if it's too long
var() bool bTrackInput;    // Should this tooltip disappear when input is received

var() const string Text;          // Entire tooltip
var() const array<string> Lines;  // If multiline == true, contains the tooltip lines

var() noexport float StartTime;
var() noexport float CurrentTime;

var() globalconfig float MaxWidth;                          // Max width of the tooltip area, in percent of the screen width
var() globalconfig float InitialDelay;                      // Number of seconds of inactivity before appearing
var() globalconfig float ExpirationSeconds;                 // Number of seconds to display before fading out

// Return true to override default behavior

// SetPosition() is called at the end of the native PreDraw(), if (bResetPosition || bTrackMouse),
// which means SetPosition() will NOT be called if you return true from OnPreDraw()
// delegate bool OnPreDraw( Canvas C );

// Draw will NOT be called if bResetPosition == true
// delegate bool OnDraw( Canvas C );

// called when the mouse is first moved over the component associated with this tooltip
delegate GUIToolTip EnterArea()
{
	return InternalEnterArea();
}

function GUIToolTip InternalEnterArea()
{
	if (Controller==None)
	{
		if ( class'GUIController'.default.bModAuthor )
			log("ToolTip ("$self$") not initialized");

		return none;
	}

	StartTime = PlayerOwner().Level.TimeSeconds;

	// if there was a hint currently being displayed, bypass the initial delay
	if ( Controller != None && Controller.MouseOver != None && Controller.MouseOver != Self && Controller.MouseOver.bVisible )
		CurrentTime = InitialDelay;
	else CurrentTime = 0.0;
	bResetPosition = true;

	return self;
}

// Called when the mouse is moved away from the component associated with this tooltip
// Return false to keep displaying the tooltip - though sometimes controller will force the tooltip to disappear
// (for instance, if opening a context menu, etc.)
delegate bool LeaveArea()
{
	return InternalLeaveArea();
}

function bool InternalLeaveArea()
{
	StartTime = -1;
	CurrentTime = -1;

	SetVisibility(false);

	if ( Controller != None && Controller.MouseOver == Self )
		Controller.MouseOver = None;

	return true;
}

// Only received when active
delegate Tick( float RealSeconds )
{
	CurrentTime += RealSeconds;

	if ( !bVisible && CurrentTime > InitialDelay && (ExpirationSeconds == 0.0 || CurrentTime <= ExpirationSeconds) )
		ShowToolTip();

	if ( bVisible && CurrentTime > ExpirationSeconds && ExpirationSeconds > 0.0 )
		HideToolTip();
}

delegate ShowToolTip()
{
	SetVisibility(true);
}

delegate HideToolTip()
{
	SetVisibility(false);
}

// This is normally called at the end of PreDraw().
event UpdatePosition( Canvas C )
{
	WinWidth  = GetWidth(C);
	WinHeight = GetHeight(C);
	WinLeft   = GetLeft(C);
	WinTop    = GetTop(C);
	bResetPosition = false;
}

delegate float GetLeft( Canvas C )
{
	local float X;

	if ( C == None || MenuOwner == None || Style == None )
		return -1.0;

	X = FMin(Controller.MouseX, Controller.MouseCursorBounds.X1);

	if ( X + WinWidth > C.SizeX )
		X -= WinWidth + 10;

	return X;
}

delegate float GetTop( Canvas C )
{
	local float TargetTop;

	if ( C == None || MenuOwner == None || Style == None )
		return -1.0;

	if ( Controller.MouseY > C.SizeY / 8 )
		TargetTop = GetTopAboveCursor(C);
	else TargetTop = GetTopBelowCursor(C);

	if ( TargetTop < 0 )
		TargetTop = GetTopBelowCursor(C);
	return TargetTop;
}

delegate float GetWidth( Canvas C )
{
	local int i;
	local float MaxLineWidth, XL, YL;

	if ( C == None || Lines.Length == 0 || MenuOwner == None || Style == None )
		return 0.0;

	for ( i = 0; i < Lines.Length; i++ )
	{
		Style.TextSize(C, MenuOwner.MenuState, Lines[i], XL, YL, FontScale);
		if ( XL > MaxLineWidth )
			MaxLineWidth = XL;
	}

	return FMin( MaxLineWidth, MaxWidth * C.SizeX ) + Style.BorderOffsets[0] + Style.BorderOffsets[2];
}

delegate float GetHeight( Canvas C )
{
	local float XL, YL;

	if ( C == None || Lines.Length == 0 || MenuOwner == None || Style == None )
		return 0.0;

	Style.TextSize( C, MenuOwner.MenuState, Lines[0], XL, YL, FontScale );
	return (YL * Lines.Length) + Style.BorderOffsets[1] + Style.BorderOffsets[3];
}

singular function float GetTopAboveCursor( Canvas C )
{
	local float TargetY, TempY;

	if ( MenuOwner == None || C == None || Controller == None )
		return -1.0;

	TargetY = FMin(Controller.MouseCursorBounds.Y1, Controller.MouseY) - (WinHeight + 10);
	if ( TargetY < 0 )
		TempY = GetTopBelowCursor(C);

	return FMax(TempY, TargetY);
}

singular function float GetTopBelowCursor( Canvas C )
{
	local float TargetY, TempY;

	if ( MenuOwner == None || C == None || Controller == None )
		return -1.0;

	TargetY = FMax(Controller.MouseCursorBounds.Y2, Controller.MouseY) + 10;
	if ( TargetY + WinHeight > C.SizeY )
		TempY = GetTopAboveCursor(C);

	return FMax(TargetY, TempY);
}

native final function SetTip( coerce string NewTip );

defaultproperties
{
     bMultiLine=True
     bTrackInput=True
     MaxWidth=0.300000
     InitialDelay=0.250000
     ExpirationSeconds=3.000000
     StyleName="MouseOver"
     bVisible=False
}
