//==============================================================================
//	Created on: 10/15/2003
//	*cough*UWindows2*cough*
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class FloatingWindow extends PopupPageBase;

var automated GUIHeader t_WindowTitle;
var() GUIButton b_ExitButton;

var() localized string WindowName;
var() float MinPageWidth, MinPageHeight, MaxPageHeight, MaxPageWidth;
var() editconst bool  bResizeWidthAllowed, bResizeHeightAllowed, bResizing, bMoveAllowed, bMoving;
var() editconst bool TSizing, RSizing, LSizing, BtSizing,
         TLSizing, TRSizing, BRSizing, BLSizing;

var() config float DefaultLeft, DefaultTop, DefaultWidth, DefaultHeight;

var() int HeaderMouseCursorIndex;

function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
	Super.InitComponent( MyController, MyOwner );

	t_WindowTitle.SetCaption(WindowName);
	if ( bMoveAllowed )
	{
		// Set bAcceptsInput so that it will become the Controller's active control when moused over
		t_WindowTitle.bAcceptsInput = True;
		t_WindowTitle.MouseCursorIndex = HeaderMouseCursorIndex;
	}

	AddSystemMenu();
	i_FrameBG.OnPreDraw=AlignFrame;

}

function bool AlignFrame(Canvas C)
{
	i_FrameBG.WinHeight = i_FrameBG.RelativeHeight(ActualHeight() - t_WindowTitle.ActualHeight()*0.5);
	i_FrameBG.WinTop = i_FrameBG.RelativeTop(ActualTop() + t_WindowTitle.ActualHeight()*0.5);
	return bInit;
}

function AddSystemMenu()
{
	local eFontScale tFontScale;

	b_ExitButton = GUIButton(t_WindowTitle.AddComponent( "XInterface.GUIButton" ));
	b_ExitButton.Style = Controller.GetStyle("CloseButton",tFontScale);
	b_ExitButton.OnClick = XButtonClicked;
	b_ExitButton.bNeverFocus=true;
	b_ExitButton.FocusInstead = t_WindowTitle;
	b_ExitButton.RenderWeight=1;
	b_ExitButton.bScaleToParent=false;
	b_ExitButton.OnPreDraw = SystemMenuPreDraw;

	// Do not want OnClick() called from MousePressed()
	b_ExitButton.bRepeatClick = False;
}

function bool SystemMenuPreDraw(canvas Canvas)
{
	b_ExitButton.SetPosition( t_WindowTitle.ActualLeft() + (t_WindowTitle.ActualWidth()-35), t_WindowTitle.ActualTop(), 24, 24, true);
	return true;
}

function CheckBounds()
{
	local float AH, AW, AL, AT;

	AW = FClamp(ActualWidth(), 0.0, Controller.ResX);
	AH = FClamp(ActualHeight(), 0.0, Controller.ResY);
	AT = FClamp(ActualTop(), 0.0, Controller.ResY - AH);
	AL = FClamp(ActualLeft(), 0.0, Controller.ResX - AW);

	SetPosition( AL, AT, AW, AH, True );
}

function SetDefaultPosition()
{
	local float RH, RW;

	if ( !bPositioned )
		return;

	bInit = False;

	if ( !bResizeWidthAllowed )
		DefaultWidth = WinWidth;

	if ( !bResizeHeightAllowed )
		DefaultHeight = WinHeight;

	if ( !bMoveAllowed )
	{
		DefaultLeft = WinLeft;
		DefaultTop = WinTop;
	}

	RW = FClamp( RelativeWidth(DefaultWidth),   RelativeWidth(MinPageWidth),   RelativeWidth(MaxPageWidth) );
	RH = FClamp( RelativeHeight(DefaultHeight), RelativeHeight(MinPageHeight), RelativeHeight(MaxPageHeight) );
	SetPosition(
		FClamp( RelativeLeft(DefaultLeft), 0.0, RelativeLeft(Controller.ResX) - RW),
		FClamp( RelativeTop(DefaultTop),   0.0, RelativeTop(Controller.ResY) - RH),
		RW, RH );
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if ( Sender == Self )
	{
		NewComp.bBoundToParent = True;
		NewComp.bScaleToParent = True;

		if ( !bResizeHeightAllowed && bResizeWidthAllowed )
			NewComp.ScalingType = SCALE_X;

		else if ( !bResizeWidthAllowed && bResizeHeightAllowed )
			NewComp.ScalingType = SCALE_Y;
	}
}

event SetFocus(GUIComponent Who)
{
	if ( UT2K4GUIController(Controller) != None )
		UT2K4GUIController(Controller).SetFocusTo(Self);

    Super.SetFocus(Who);
}

function FloatingMousePressed( GUIComponent Sender, bool bRepeat )
{
	if ( Controller == None || bRepeat )
		return;

	// If ResizeAllowed, set bCaptureMouse in order to receive OnCapturedMouseMove() calls
	TSizing =  bResizeHeightAllowed && HoveringTopBorder();
	RSizing =  bResizeWidthAllowed  && HoveringRightBorder();
	LSizing =  bResizeWidthAllowed  && HoveringLeftBorder();
	BtSizing = bResizeHeightAllowed && HoveringBottomBorder();
	bMoving = bMoveAllowed && Controller.ActiveControl == t_WindowTitle && !(TSizing || RSizing || BtSizing || LSizing);

	if ( TSizing )
	{
		if ( RSizing || LSizing )
		{
			TRSizing = RSizing;
			TLSizing = LSizing;

			TSizing = False;
			RSizing = False;
			LSizing = False;
		}
	}

	else if ( BtSizing )
	{
		if ( RSizing || LSizing )
		{
			BRSizing = RSizing;
			BLSizing = LSizing;

			BtSizing = False;
			RSizing = False;
			LSizing = False;
		}
	}

	if ( bMoving )
	{
		SetMouseCursorIndex(1);
		UpdateOffset(ClientBounds[0], ClientBounds[1], ClientBounds[2], ClientBounds[3]);
	}

	bResizing = bMoving || TSizing || TRSizing || RSizing || BRSizing || BtSizing || BLSizing || LSizing || TLSizing;
	bCaptureMouse = bResizing;
	t_WindowTitle.bCaptureMouse = bCaptureMouse;
}

function FloatingMouseRelease( GUIComponent Sender )
{
	local bool bSave;

	// Unset bCaptureMouse
	bSave = bCaptureMouse;

	bResizing = False;
	bCaptureMouse = False;
	t_WindowTitle.bCaptureMouse = False;

	if ( bMoving )
	{
		SetPosition( Controller.MouseX - MouseOffset[0], Controller.MouseY - MouseOffset[1], WinWidth, WinHeight, True );
		CheckBounds();
	}

	// Reset sizing vars
	bMoving = False;
	TSizing = False;
	BtSizing = False;
	RSizing = False;
	LSizing = False;
	TLSizing = False;
	BLSizing = False;
	TRSizing = False;
	BRSizing = False;

	SetMouseCursorIndex(default.MouseCursorIndex);
	UpdateOffset( -1, -1, -1, -1 );

	if ( bSave )
		SaveCurrentPosition();
}

function SaveCurrentPosition()
{
	DefaultLeft = WinLeft;
	DefaultTop = WinTop;
	DefaultWidth = WinWidth;
	DefaultHeight = WinHeight;

	SaveConfig();
}

function bool FloatingHover( GUIComponent Sender )
{
	if ( !ResizeAllowed() )
		return false;

	if ( bCaptureMouse )
		return true;

	// If mouse is near a border, allow resizing
	if ( bResizeHeightAllowed && bResizeWidthAllowed && (BLSizing || TRSizing || HoveringBottomLeft()) )
		SetMouseCursorIndex(2);
	else if ( bResizeHeightAllowed && bResizeWidthAllowed && (TLSizing || BRSizing || HoveringTopLeft()) )
		SetMouseCursorIndex(4);
	else if ( bResizeHeightAllowed && (TSizing || BtSizing || HoveringTopBorder() || HoveringBottomBorder()) )
		SetMouseCursorIndex(3);
	else if ( bResizeWidthAllowed && (LSizing || RSizing || HoveringLeftBorder() || HoveringRightBorder()) )
		SetMouseCursorIndex(5);
	else SetMouseCursorIndex(default.MouseCursorIndex);

	return true;
}

function SetPanelPosition(Canvas C);
function bool FloatingPreDraw( Canvas C )
{
	local float OldW, OldH, DiffX, DiffY, AW, AT, AH, AL;

	InternalOnPreDraw(C);

	if ( bInit )
		SetDefaultPosition();

	if ( !bCaptureMouse || bMoving )
		return false;

	SetPanelPosition(C);
	AL = ActualLeft();
	AT = ActualTop();
	AW = ActualWidth();
	AH = ActualHeight();
	OldH = AH;
	OldW = AW;


	// Top Left
	if( TLSizing )
	{
		DiffX = Controller.MouseX - AL;
		DiffY = Controller.MouseY - AT;

		WinWidth = RelativeWidth( FClamp( AW - DiffX, ActualWidth(MinPageWidth), ActualWidth(MaxPageWidth) ) );
		WinHeight = RelativeHeight(FClamp(AH - DiffY, ActualHeight(MinPageHeight), ActualHeight(MaxPageHeight)));
		SetPosition( AL + OldW - ActualWidth(),
				AT + OldH - ActualHeight(),
				WinWidth,
				WinHeight,
				True );

		ResizedBoth();
		return true;
	}

	if ( TRSizing )
	{
		DiffX = Controller.MouseX - (AL + AW);
		DiffY = Controller.MouseY - AT;

		WinHeight = RelativeHeight(FClamp(AH - DiffY, ActualHeight(MinPageHeight), ActualHeight(MaxPageHeight)));
		SetPosition( WinLeft,
				(AT + OldH) - ActualHeight(),
				FClamp(AW + DiffX, ActualWidth(MinPageWidth), ActualWidth(MaxPageWidth)),
				WinHeight,
				True );

		ResizedBoth();
		return true;
	}

	if ( BLSizing )
	{
		DiffX = Controller.MouseX - AL;
		DiffY = Controller.MouseY - (AT + AH);

		WinWidth = RelativeWidth( FClamp(AW - DiffX, ActualWidth(MinPageWidth), ActualWidth(MaxPageWidth)) );
		SetPosition( (AL + OldW) - ActualWidth(),
				WinTop,
				WinWidth,
				FClamp(AH + DiffY, ActualHeight(MinPageHeight), ActualHeight(MaxPageHeight)),
				True );

		ResizedBoth();
		return true;
	}

	if ( BRSizing )
	{
		DiffX = Controller.MouseX - (AL + AW);
		DiffY = Controller.MouseY - (AT + AH);

		SetPosition( WinLeft,
				WinTop,
				FClamp(AW + DiffX, ActualWidth(MinPageWidth), ActualWidth(MaxPageWidth)),
				FClamp(AH + DiffY, ActualHeight(MinPageHeight), ActualHeight(MaxPageHeight)),
				True );

		ResizedBoth();
		return true;
	}

	// Top
	if ( TSizing )
	{
		DiffY = Controller.MouseY - AT;

		WinHeight = RelativeHeight( FClamp(AH - DiffY, ActualHeight(MinPageHeight), ActualHeight(MaxPageHeight)));
		SetPosition( WinLeft,
				(AT + OldH) - ActualHeight(),
				WinWidth,
				WinHeight,
				True );

		ResizedHeight();
		return true;
	}

	// Left
	if( LSizing )
	{
		DiffX = Controller.MouseX - AL;

		WinWidth = RelativeWidth( FClamp(AW - DiffX, ActualWidth(MinPageWidth), ActualWidth(MaxPageWidth)) );
		SetPosition( (AL + OldW) - ActualWidth(),
				WinTop,
				WinWidth,
				WinHeight,
				True );

		ResizedWidth();
		return true;
	}

	// Right
	if( RSizing )
	{
		DiffX = Controller.MouseX - (AL + AW);
		SetPosition( WinLeft,
				WinTop,
				FClamp(AW + DiffX, ActualWidth(MinPageWidth), ActualWidth(MaxPageWidth)),
				WinHeight,
				True );

		ResizedWidth();
		return true;
	}

	// Bottom
	if( BtSizing )
	{
		DiffY = Controller.MouseY - (AT + AH);
		SetPosition( WinLeft,
				WinTop,
				WinWidth,
				FClamp(AH + DiffY, ActualHeight(MinPageHeight), ActualHeight(MaxPageHeight)),
				True );

		ResizedHeight();
		return true;
	}

	return false;
}

function FloatingRendered( Canvas C )
{
	if ( !bMoving )
		return;

	C.SetPos( FClamp(Controller.MouseX - MouseOffset[0], 0.0, Controller.ResX - ActualWidth()),
	          FClamp(Controller.MouseY - MouseOffset[1], 0.0, Controller.ResY - ActualHeight()) );
	C.SetDrawColor(255,255,255,255);
	C.DrawTileStretched( Controller.WhiteBorder, ActualWidth(), ActualHeight() );
}

// =====================================================================================================================
// =====================================================================================================================
//  Notification
// =====================================================================================================================
// =====================================================================================================================
event ResolutionChanged( int ResX, int ResY )
{
	bInit = True;
	Super.ResolutionChanged(ResX,ResY);
}

function ResizedBoth();
function ResizedWidth();
function ResizedHeight();

// =====================================================================================================================
// =====================================================================================================================
//  Utility
// =====================================================================================================================
// =====================================================================================================================
function bool ResizeAllowed()
{
	return bResizeHeightAllowed || bResizeWidthAllowed;
}

function bool HoveringLeftBorder()
{
	if ( Controller == None )
		return false;

	return Controller.MouseX > (Bounds[0] - 5) && Controller.MouseX < (Bounds[0] + 5);
}

function bool HoveringRightBorder()
{
	if ( Controller == None )
		return false;

	return Controller.MouseX > (Bounds[2] - 5) && Controller.MouseX < (Bounds[2] + 5);
}

function bool HoveringTopBorder()
{
	if ( Controller == None )
		return false;

	return Controller.MouseY > (Bounds[1] - 5) && Controller.MouseY < (Bounds[1] + 5);
}

function bool HoveringBottomBorder()
{
	if ( Controller == None )
		return false;

	return Controller.MouseY > (Bounds[3] - 5) && Controller.MouseY < (Bounds[3] + 5);
}

function bool HoveringTopLeft()
{
	return (HoveringLeftBorder() && HoveringTopBorder()) ||
		   (HoveringRightBorder() && HoveringBottomBorder());
}

function bool HoveringBottomLeft()
{
	return (HoveringRightBorder() && HoveringTopBorder()) ||
	       (HoveringLeftBorder() && HoveringBottomBorder());
}

function bool XButtonClicked( GUIComponent Sender )
{
	Controller.CloseMenu(False);
	return true;
}

function SetMouseCursorIndex( int NewIndex )
{
	MouseCursorIndex = NewIndex;
	if ( MouseCursorIndex == default.MouseCursorIndex )
		t_WindowTitle.MouseCursorIndex = HeaderMouseCursorIndex;

	else t_WindowTitle.MouseCursorIndex = NewIndex;
}

defaultproperties
{
     Begin Object Class=GUIHeader Name=TitleBar
         bUseTextHeight=True
         WinHeight=0.043750
         RenderWeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         bNeverFocus=False
         ScalingType=SCALE_X
         OnMousePressed=FloatingWindow.FloatingMousePressed
         OnMouseRelease=FloatingWindow.FloatingMouseRelease
     End Object
     t_WindowTitle=GUIHeader'GUI2K4.FloatingWindow.TitleBar'

     MinPageWidth=0.100000
     MinPageHeight=0.100000
     MaxPageHeight=1.000000
     MaxPageWidth=1.000000
     bResizeWidthAllowed=True
     bResizeHeightAllowed=True
     bMoveAllowed=True
     DefaultLeft=0.200000
     DefaultTop=0.200000
     DefaultWidth=0.600000
     DefaultHeight=0.600000
     HeaderMouseCursorIndex=1
     bCaptureInput=False
     InactiveFadeColor=(B=255,G=255,R=255)
     OnCreateComponent=FloatingWindow.InternalOnCreateComponent
     OnPreDraw=FloatingWindow.FloatingPreDraw
     OnRendered=FloatingWindow.FloatingRendered
     OnHover=FloatingWindow.FloatingHover
     OnMousePressed=FloatingWindow.FloatingMousePressed
     OnMouseRelease=FloatingWindow.FloatingMouseRelease
}
