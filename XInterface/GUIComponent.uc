// ====================================================================
//  Class:  UT2K4UI.GUIComponent
//
//  GUIComponents are the most basic building blocks of menus.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIComponent extends GUI
	Abstract
    Native;

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
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// Variables
var(Menu)  noexport editconst GUIPage             PageOwner;              // Callback to the GUIPage that contains this control
var(Menu)  noexport editconst GUIComponent        MenuOwner;              // Callback to the Component that owns this one
var(State) noexport           GUIComponent        FocusInstead;           // Who should get the focus instead of this control if bNeverFocus
var(State) noexport           eMenuState          MenuState;              // Used to determine the current state of this component
var(State) editconst noexport eMenuState          LastMenuState;          // The previous MenuState of this component
var(State) noexport           eDropState          DropState;              // Used to determine the current drop state of this component
var(Style)                    eFontScale          FontScale;              // If this component has a style, which size font should be applied to the style

// RenderStyle and MenuColor are usually pulled from the Parent menu, unless specificlly overridden

var()       string          IniOption;                  // Points to the INI option to load for this component
var()       string          IniDefault;                 // The default value for a missing ini option
var(Style)  string          StyleName;                  // Name of my Style
var()   localized string    Hint;                       // The hint that gets displayed for this component
var() noexport GUILabel     FriendlyLabel;              // My state is projected on this objects state.
var(Menu)   float           WinTop,WinLeft;             // Where does this component exist (in world space) - Grr.. damn Left()
var(Menu)   float           WinWidth,WinHeight;         // Where does this component exist (in world space) - Grr.. damn Left()
var()       float           RenderWeight;               // Used to determine sorting in the controls stack
var(Style)  int             MouseCursorIndex;           // The mouse cursor to use when over this control
var(Menu)   int             TabOrder;                   // Used to figure out tabbing
var()       int             Tag;                        // Free (can be used for anything)

var()       bool            bDebugging;
var(Menu)   bool            bTabStop;                   // Does a TAB/Shift-Tab stop here
var()       bool            bFocusOnWatch;              // If true, watching focuses
var(Menu)   bool            bBoundToParent;             // Use the Parents Bounds for all positioning
var(Menu)   bool            bScaleToParent;             // Use the Parent for scaling
var(State)  noexport bool   bHasFocus;                  // Does this component currently have input focus
var(State)  bool            bVisible;                   // Is this component currently visible
var(State)  bool            bAcceptsInput;              // Does this control accept input
var()       bool            bCaptureTabs;               // If true, OnKeyEvent() is called for tab presses, overriding default behavior (NextControl()/PrevControl())
var(State)  bool            bCaptureMouse;              // Control should capture the mouse when pressed
var(State)  bool            bNeverFocus;                // This control should never fully receive focus
var(State)  bool            bRepeatClick;               // Whether this component should receive OnClick() events when the mouse button is held down
var(State)  bool            bRequireReleaseClick;       // If True, this component wants the click on release even if it's not active
var()       bool            bMouseOverSound;            // Should component bleep when mouse goes over it
var()       bool            bDropSource;                // Can this component act as a drag-n-drop source
var()       bool            bDropTarget;                // Can this component act as a drag-n-drop target
var(State)  noexport bool   bPendingFocus;              // Big big hack for ComboBoxes..
var()       bool            bInit;                      // Can be used by any component as an "initialization" hook
var()       bool            bNeverScale;                // Do not treat position/dimension values in the -2.0 to 2.0 range as scaled values
                                                        // useful for internally managed components (GUIComboBox's list, button, etc.)

/*
 This property is solely for the benefit of mod authors, to indicate components which
 will be skipped by the native rendering code if the component doesn't have a valid style.
 Mod authors: changing the value of this property in your subclasses will cause your menus to crash the game
*/
var const noexport bool bRequiresStyle;
var() editconst const noexport  bool                bPositioned;                // Whether this component has been positioned yet (first Pre-Render)
var() editconst noexport      bool                  bAnimating;                 // If true, all input/focus/etc will be ignored
var() editconst noexport const bool                 bTravelling, bSizing;       // Travelling is true when animating position, Sizing is true when animating dimensions
var() editconst noexport const array<vector>        MotionFrame, SizeFrame;

// Notes about the Top/Left/Width/Height : This is a somewhat hack but it's really good for functionality.  If
// the value is < 2, then the control is considered to be scaled.  If they are >= 2 they are considered to be normal world coords.
// If bNeverScale is set, then values between -2/2 will also be considered actual values
// 0 = 0, 1 = 100%, 2 = 2px
var(Menu) editconst const noexport  float       Bounds[4];                              // Internal normalized positions in world space
var(Menu) editconst const noexport  float       ClientBounds[4];                        // The bounds of the actual client area (minus any borders)


// Timer Support
var()                   bool        bTimerRepeat;
var() noexport editconst const   int         TimerIndex;         // For easier maintenance
var()                   float       TimerCountdown;
var()                   float       TimerInterval;

var noexport const float MouseOffset[4]; // Used natively for drawing outlines
var() editconst GUIContextMenu ContextMenu;
var() editconst GUIToolTip     ToolTip;

// Used for Saving the last state before drawing natively
var noexport const color WhiteColor;

// Style holds a pointer to the GUI style of this component.
var(Style) noexport              GUIStyles        Style;                     // My GUI Style
var(Style)   enum                EClickSound
{
    CS_None,
    CS_Click,
    CS_Edit,
    CS_Up,
    CS_Down,
    CS_Drag,
    CS_Fade,
    CS_Hover,
    CS_Slide,
} OnClickSound;

var()   enum                EParentScaleType	// Used to bound/scale in one dimension only
{
	SCALE_All,
	SCALE_X,
	SCALE_Y,
} BoundingType, ScalingType;

var(Menu) bool bStandardized;
var(Menu) float StandardHeight;

// FOR TESTING
var editconst const noexport int PreDrawCount, DrawCount;
var editconst noexport int OnRenderCount, OnRenderedCount, OnPreDrawCount, OnDrawCount;
// Delegates

Delegate OnArrival(GUIComponent Sender, EAnimationType Type);         // Called when an animating component arrives at a spot
Delegate OnEndAnimation( GUIComponent Sender, EAnimationType Type );	// Called immediately after the component arrives at the last keypoint

// Drawing delegates return true if you want to short-circuit the default drawing code
// Called for all components, but natively, only ContextMenus do not perform native PreDraw if delegate returns false
// Bounds/ClientBounds are updated just before the call to OnPreDraw().
// If you modify the positions of the component, you can force an immediate refresh of the Bounds by returning true from OnPreDraw
/*
Delegate bool OnPreDraw(canvas Canvas);		// Called from the GUIComponent's native PreDraw function.
Delegate bool OnDraw(canvas Canvas);		// Called the moment the native Draw function is called on a component
Delegate OnRender(canvas Canvas);           // Called immediately after a component's native Super.Draw is called
Delegate OnRendered(canvas Canvas);      	// Called immediately after a component has finished rendering.
*/

// The "default" versions of these delegates are only called if GUI.Counter > 0
Delegate bool OnPreDraw(canvas Canvas)
{
	if ( Counter < 1 )
		return false;

	OnPreDrawCount++;
	if ( OnPreDrawCount > Counter )
		log("OnPreDraw called"@OnPreDrawCount@"times: "$GetMenuPath());

	return false;
}

Delegate bool OnDraw(canvas Canvas)
{
	if ( COUNTER < 1 )
		return false;

	OnDrawCount++;
	if ( OnDrawCount > Counter )
		log("OnDraw called"@OnDrawCount@"times: "$GetMenuPath());

	return false;
}
Delegate OnRender(canvas Canvas)
{
	if ( COUNTER < 1 )
		return;

	OnRenderCount++;
	if ( OnRenderCount > Counter )
		log("OnRender called"@OnRenderCount@"times: "$GetMenuPath());
}
Delegate OnRendered(canvas Canvas)
{
	if ( COUNTER < 1 )
		return;
	OnRenderedCount++;
	if ( OnRenderedCount > Counter )
		log("OnRendered called"@OnRenderedCount@"times:"@GetMenuPath());
}

Delegate OnActivate();                                                  // Called when the component gains focus
Delegate OnDeActivate();                                                // Called when the component loses focus
Delegate OnWatch();                                                     // Called when the component is being watched
Delegate OnHitTest(float MouseX, float MouseY);                         // Called when Hit test is performed for mouse input
Delegate OnMessage(coerce string Msg, float MsgLife);                   // When a message comes down the line
Delegate OnHide();
Delegate OnShow();

// Called just before OnHover()
// Controller assigns the value of its MouseOver property to the result of this function
delegate GUIToolTip OnBeginTooltip()
{
	if ( ToolTip != None )
		return ToolTip.EnterArea();

	else if ( MenuOwner != None )
		return MenuOwner.OnBeginTooltip();

	return None;
}

// Called on the current ActiveControl when the mouse is moved over a new component
// This is called before OnBeginTooltip is called on the new control
// Return false if the tooltip will remain visible after leaving this control
delegate bool OnEndTooltip()
{
	if ( ToolTip != None )
		return ToolTip.LeaveArea();

	else if ( MenuOwner != None )
		return MenuOwner.OnEndTooltip();

	return true;
}

Delegate OnInvalidate(GUIComponent Who);    // Called when the background is clicked

// Return true to override default behavior
// Called on both the active control & active page
delegate bool OnHover( GUIComponent Sender ) { return false; }

// -- Input event delegates
Delegate bool OnClick(GUIComponent Sender);         // The mouse was clicked on this control
Delegate bool OnDblClick(GUIComponent Sender);      // The mouse was double-clicked on this control
Delegate bool OnRightClick(GUIComponent Sender);    // Return false to prevent context menu from appearing

Delegate OnMousePressed(GUIComponent Sender, bool bRepeat);     // Sent when a mouse is pressed (initially)
Delegate OnMouseRelease(GUIComponent Sender);       // Sent when the mouse is released.

Delegate OnTimer(GUIComponent Sender);				// Called from Timer()
Delegate OnChange(GUIComponent Sender); // Called when a component changes it's value

Delegate bool OnKeyType(out byte Key, optional string Unicode)      // Key Strokes
{
    return false;
}

Delegate bool OnKeyEvent(out byte Key, out byte State, float delta)
{
    return false;
}

delegate bool OnDesignModeKeyEvent( Interactions.EInputKey Key, Interactions.EInputAction State )
{
	return false;
}

Delegate bool OnCapturedMouseMove(float deltaX, float deltaY)
{
    return false;
}

Delegate OnLoadINI(GUIComponent Sender, string s);      // Do the actual work here
Delegate string OnSaveINI(GUIComponent Sender);         // Do the actual work here

// drag-n-drop
// Called when mouse is released over the DropSource to detemine whether OnClick() should be called
delegate bool OnMultiSelect( GUIComponent Sender )
{
	return true;
}

delegate bool OnBeginDrag(GUIComponent Sender)      // Called on the source component when a drag & drop operation begins
{
    return bDropSource;
}

delegate OnEndDrag(GUIComponent Sender, bool bAccepted);

// Called on the target component when data is dropped
// DropStateChange() will be called on the source - DRP_Accept if it returns true, DRP_Reject if it returns false
delegate bool OnDragDrop(GUIComponent Sender)
{
    return false;
}

delegate OnDragEnter(GUIComponent Sender);          // Called on the target component when the mouse enters the components bounds
delegate OnDragLeave(GUIComponent Sender);          // Called on a target component when the mouse leaves the components bounds
delegate OnDragOver(GUIComponent Sender);           // Called when the mouse is moved inside a target's bounds


native(812) final function PlayerController PlayerOwner();

native(813) function final SetTimer(float Interval, optional bool bRepeat);
native(814) function final KillTimer();

// Auto-positioning - accounts for bBoundToParent & bScaleToParent
native(815) final function AutoPosition(
        array<GUIComponent> Components,
        float LeftBound, float UpperBound, float RightBound, float LowerBound,
        float LeftPad, float UpperPad, float RightPad, float LowerPad,
        optional int NumberOfColumns, optional float ColumnPadding
        );

native(816) final function AutoPositionOn(
		array<GUIComponent> Components, GUIComponent Frame,
		float LeftPadPerc, float UpperPadPerc, float RightPadPerc, float LowerPadPerc,
		optional int NumberOfColumns, optional float ColumnPadding
		);

native(817) final function UpdateOffset(float PosX, float PosY, float PosW, float PosH);
//native(818) final function DrawSpriteWidget(Canvas C, float ResScaleX, float ResScaleY, out HudBase.SpriteWidget Widget);
//native(819) final function DrawNumericWidget(Canvas C, float ResScaleX, float ResScaleY, out HudBase.NumericWidget Widget, out HudBase.DigitSet Digit);

// The ActualXXXX functions are not viable until after the first pre-render so don't
// use them in inits
native(820) final function float ActualWidth( optional coerce float Val, optional bool bForce );
native(821) final function float ActualHeight( optional coerce float Val, optional bool bForce );
native(822) final function float ActualLeft( optional coerce float Val, optional bool bForce );
native(823) final function Float ActualTop( optional coerce float Val, optional bool bForce );

native(824) final function float RelativeLeft( optional coerce float RealLeft, optional bool bForce );
native(825) final function float RelativeTop( optional coerce float RealTop, optional bool bForce );
native(826) final function float RelativeWidth( optional coerce float RealWidth, optional bool bForce );
native(827) final function float RelativeHeight( optional coerce float RealHeight, optional bool bForce );

event ResolutionChanged( int ResX, int ResY );

function SetPosition( float NewLeft, float NewTop, float NewWidth, float NewHeight, optional bool bForceRelative )
{
	if ( bDebugging && (Controller == None || Controller.bModAuthor) )
		log(Name$".SetPosition( "$NewLeft$","@NewTop$","@NewWidth$","@NewHeight$","@bForceRelative,'ModAuthor');

	if ( bForceRelative )
	{
		WinLeft   = RelativeLeft(NewLeft);
		WinTop    = RelativeTop(NewTop);
		WinWidth  = RelativeWidth(NewWidth);
		WinHeight = RelativeHeight(NewHeight);
	}
	else
	{
		WinLeft   = NewLeft;
		WinTop    = NewTop;
		WinWidth  = NewWidth;
		WinHeight = NewHeight;
	}

	if ( bDebugging && bForceRelative && (Controller == None || Controller.bModAuthor) )
		log(Name@"SetPosition() Current L:"$WinLeft$"("$Bounds[0]$") T:"$WinTop$"("$Bounds[1]$") W:"$WinWidth$"("$Bounds[0]+Bounds[2]$") H:"$WinHeight$"("$Bounds[1]+Bounds[3]$")",'ModAuthor');
}

// For debugging
native(828) final function string GetMenuPath();
// Used only for design mode - performs raw hit detection, without regard to properties that affect
// hit detection (bAcceptsInput, MenuState, etc.)
native(829) final function bool  SpecialHit( optional bool bForce );

event string AdditionalDebugString() { return ""; }

event Timer()
{
	OnTimer(Self);
}

event Opened(GUIComponent Sender)                   // Called when the Menu Owner is opened
{
    LoadIni();
    if ( ToolTip != None )
    {
    	ToolTip.InitComponent( Controller, Self );
    	SetToolTipText( Hint );
    }
}

event Closed(GUIComponent Sender, bool bCancelled)  // Called when the Menu Owner is closed
{
    if (!bCancelled)
        SaveIni();
}

event Free()            // This control is no longer needed
{
    MenuOwner       = None;
    PageOwner       = None;
    Controller      = None;
    FocusInstead    = None;
    FriendlyLabel   = None;
    Style           = None;
    if ( ToolTip != None )
    	ToolTip.Free();

    ToolTip         = None;
}

function string LoadINI()
{
    local string s;

    if ( (PlayerOwner()==None) || (INIOption=="") )
        return "";

	if ( IniOption ~= "@Internal" )
	{
		OnLoadIni(Self,"");
		return "";
	}


	s = PlayerOwner().ConsoleCommand("get"@IniOption);
    if (s=="")
        s = IniDefault;

    OnLoadINI(Self,s);
    return s;
}

function SaveINI(optional string Value)
{
    if (PlayerOwner()==None)
        return;

    OnSaveINI(Self);
}

// Take a string and strip out colour codes
static function string StripColorCodes(string InString)
{
    local int CodePos;

    CodePos = InStr(InString, Chr(27));
//    while(CodePos != -1 && CodePos < Len(InString)-3) // ignore colour codes at the end of the string
	while ( CodePos != -1 ) // do not ignore color codes at the end of the word, or they aren't stripped
    {
	    InString = Left(InString, CodePos)$Mid(InString, CodePos+4);
        CodePos = InStr(InString, Chr(27));
    }

    return InString;
}

static function string MakeColorCode(color NewColor)
{
    // Text colours use 1 as 0.
    if(NewColor.R == 0)
        NewColor.R = 1;

    if(NewColor.G == 0)
        NewColor.G = 1;

    if(NewColor.B == 0)
        NewColor.B = 1;

    return Chr(0x1B)$Chr(NewColor.R)$Chr(NewColor.G)$Chr(NewColor.B);
}

// Functions

event MenuStateChange(eMenuState Newstate)
{
//log("MenuStateChange:"$NewState@Self.Name);

	if ( MenuState != MSAT_Watched )
		LastMenuState = MenuState;

    bPendingFocus = false;
	MenuState = NewState;
    switch (MenuState)
    {
        case MSAT_Focused:
        	if ( !bNeverFocus )
			{
				bHasFocus = true;
	            break;
	        }

	        MenuState = MSAT_Blurry;

        case MSAT_Blurry:
            bHasFocus = false;
            if ( LastMenuState != MSAT_Blurry && LastMenuState != MSAT_Disabled )
	            OnDeActivate();
            break;

        case MSAT_Watched:
            if (bFocusOnWatch)
            {
                SetFocus(None);
                return;
            }

            OnWatch();
            break;

        case MSAT_Disabled:
            if (Controller.ActiveControl == Self)
                Controller.ActiveControl = None;

            if (Controller.FocusedControl == Self)
                LoseFocus(None);

            break;
    }

    if ( FriendlyLabel != None )
        FriendlyLabel.MenuState = MenuState;
}

event bool IsMultiSelect()
{
	if ( Controller == None )
		return false;

	return bDropSource && DropState != DRP_Source && Controller.CtrlPressed && OnMultiSelect(Self);
}

event DropStateChange(eDropState NewState)
{
    if (Controller == None)
        return;

// log( Name$".DropStateChange Current:"$GetEnum(enum'eDropState',DropState)@"New:"$GetEnum(enum'eDropState',NewState)
//		@"DropSource:"$Controller.DropSource == Self@"DropTarget:"$Controller.DropTarget==Self);

    switch (NewState)
    {
        case DRP_None:
        	// might be DropTarget with DropState == DRP_Source if we are mousing over the DropSource
        	if ( Controller.DropTarget == Self )
        	{
                OnDragLeave(Self);
                Controller.DropTarget = None;

                // If this component is also the DropSource, do not alter the DropState
                if ( Controller.DropSource == Self )
                	return;
	        }

            else if (Controller.DropSource == Self)
            {
                UpdateOffset(0,0,0,0);
                Controller.DropSource = None;
            }

            break;

        case DRP_Source:

			// Don't alter the drop state if component didn't want to begin a drag operation
    		if ( !OnBeginDrag(Self) )
    			return;

            Controller.DropSource = Self;
            Controller.PlayInterfaceSound(CS_Drag);
            break;

        case DRP_Target:
            Controller.DropTarget = Self;
            if (DropState == DRP_None)
                OnDragEnter(Self);

            break;

        case DRP_Accept:
        	Controller.PlayInterfaceSound(CS_Up);

        	if ( Controller.DropSource != None )
	            Controller.DropSource.OnEndDrag(Self, True);

            Controller.DropTarget = None;
            NewState = DRP_None;

            break;

        case DRP_Reject:
        	Controller.PlayInterfaceSound(CS_Down);
        	if ( Controller.DropSource != None )
	            Controller.DropSource.OnEndDrag(Self, False);

            Controller.DropTarget = None;
            NewState = DRP_None;
            break;
    }

    DropState = NewState;
}

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Controller = MyController;
    MenuOwner = MyOwner;

    PageOwner = OwnerPage();

    if (Style==None)
        Style = Controller.GetStyle(StyleName, FontScale);
}

function bool IsInBounds()  // Script version of PerformHitTest
{
    return ( (Controller.MouseX >= Bounds[0] && Controller.MouseX<=Bounds[2]) && (Controller.MouseY >= Bounds[1] && Controller.MouseY <=Bounds[3]) );
}

function bool IsInClientBounds()
{
    return ( (Controller.MouseX >= ClientBounds[0] && Controller.MouseX<=ClientBounds[2]) && (Controller.MouseY >= ClientBounds[1] && Controller.MouseY <=ClientBounds[3]) );
}

event bool CanAcceptFocus()
{
	return MenuState != MSAT_Disabled && bVisible && !bNeverFocus;
}

event SetFocus(GUIComponent Who)
{
    if (Who==None)
    {
        if (bNeverFocus)
        {
            if (FocusInstead != None)
                FocusInstead.SetFocus(Who);

            return;
        }
        bPendingFocus = true;
        if (Controller.FocusedControl!=None)
        {
            if  (Controller.FocusedControl == Self) // Already Focused
                return;
            else Controller.FocusedControl.LoseFocus(Self);
        }

        MenuStateChange(MSAT_Focused);
        Controller.FocusedControl = self;
		OnActivate();
    }
    else
        MenuStateChange(MSAT_Focused);


    if (MenuOwner!=None)
        MenuOwner.SetFocus(self);
}

event LoseFocus(GUIComponent Sender)
{
    if (Controller!=None)
        Controller.FocusedControl = None;

    if (MenuState != MSAT_Disabled)
        MenuStateChange(MSAT_Blurry);

    if (MenuOwner!=None)
        MenuOwner.LoseFocus(Self);
}

event bool FocusFirst(GUIComponent Sender)  // Focus your first child, or yourself if no childrean
{
    if ( !bTabStop || !CanAcceptFocus() )
        return false;

	SetFocus(None);
    return true;
}

event bool FocusLast(GUIComponent Sender) // Focus your last child, or yourself
{
    if ( !bTabStop || !CanAcceptFocus() )
        return false;

    SetFocus(None);
    return true;
}

event bool NextControl(GUIComponent Sender)
{
    if (MenuOwner!=None)
        return MenuOwner.NextControl(Self);

    return false;
}

event bool PrevControl(GUIComponent Sender)
{
    if (MenuOwner!=None)
        return MenuOwner.PrevControl(Self);

    return false;
}

event bool NextPage()
{
    if (MenuOwner != None)
        return MenuOwner.NextPage();

    return false;
}

event bool PrevPage()
{
    if (MenuOwner != None)
        return MenuOwner.PrevPage();

    return false;
}

// Force control to use same area as its MenuOwner.
function FillOwner()
{
    WinLeft = 0.0;
    WinTop = 0.0;
    WinWidth = 1.0;
    WinHeight = 1.0;
    bScaleToParent = true;
    bBoundToParent = true;
}

event SetVisibility( coerce bool bIsVisible)
{
    bVisible = bIsVisible;

    if (bVisible)
        OnShow();
    else OnHide();
}

function CenterMouse()
{
	local PlayerController PC;
	local float MidX, MidY;

	PC = PlayerOwner();
	if ( PC != None )
	{
		MidX = ActualLeft() + ActualWidth() / 2;
		MidY = ActualTop() + ActualHeight() / 2;
		PC.ConsoleCommand("SETMOUSE" @ MidX @ MidY);
	}
}

event Hide()
{
    SetVisibility(false);
}

event Show()
{
    SetVisibility(true);
}

function SetFocusInstead( GUIComponent InFocusComp )
{
	if ( InFocusComp != None )
		bNeverFocus = true;

	FocusInstead = InFocusComp;
}

function SetFriendlyLabel(GUILabel NewLabel)
{
    FriendlyLabel = NewLabel;
}

function SetHint(string NewHint)
{
    Hint = NewHint;
    SetToolTipText(Hint);
}

function SetToolTipText( string NewToolTipText )
{
    if ( ToolTip != None )
    	ToolTip.SetTip( NewToolTipText );
}

function SetTooltip( GUIToolTip InTooltip )
{
	if ( ToolTip != None )
		ToolTip.LeaveArea();

	ToolTip = InToolTip;
	if ( ToolTip != None )
		ToolTip.InitComponent( Controller, Self );
}

function PadLeft( out string Src, int StrLen, optional string PadStr )
{
    if ( PadStr == "" )
        PadStr = " ";

    while ( Len(Src) < StrLen )
        Src = PadStr $ Src;
}

function PadRight( out string Src, int StrLen, optional string PadStr )
{
    if ( PadStr == "" )
        PadStr = " ";

    while ( Len(Src) < StrLen )
        Src = Src $ PadStr;
}

final function DebugFocus( GUIComponent Who, bool bLose )
{
	return;
	if ( Controller != None && Controller.CtrlPressed )
	{
		if ( bLose )
		{
			if ( Who == None )
				log(Name@"losing focus chain down");
			else log(Name@"losing focus of"@Who);
		}

		else
		{
			if ( Who == None )
				log(Name@"sending focus chain down");
			else log(Name@"setting focus to"@Who);
		}
	}
}

final function DebugFocusPosition( GUIComponent Who, bool Last )
{
	return;
	if ( Controller.CtrlPressed )
	{
		if ( Last )
		{
			if ( Who == None )
				log(Name@"FocusLast going down");
			else log(Name@"FocusLast call from"@Who);
		}

		else
		{
			if ( Who == None )
				log(Name@"FocusFirst going down");
			else log(Name@"FocusFirst call from"@Who);
		}
	}
}

event GUIPage OwnerPage()
{
	local GUIComponent C;

	if ( PageOwner != None )
		return PageOwner;

	C = Self;
	while ( C != None )
	{
		if ( GUIPage(C) != None )
			return GUIPage(C);

		C = C.MenuOwner;
	}

	Warn( "OwnerPage not found!" );
	return None;
}

// By default, we don't care which components are animating
// Input is disabled while bAnimating
event BeginAnimation( GUIComponent Animating )
{
	bAnimating = True;
	if ( MenuOwner != None )
		MenuOwner.BeginAnimation(Animating);
}

event EndAnimation( GUIComponent Animating, EAnimationType Type )
{
	bAnimating = False;
	if ( MenuOwner != None )
		MenuOwner.EndAnimation( Animating, Type );

	if ( Animating == Self )
		OnEndAnimation(Animating, Type);
}

// If you short circuit these functions (by modifying the animation arrays directly)
// you must call BeginAnimation() on the owning page for each frame
function Animate( float NewLeft, float NewTop, optional float Time )
{
	local int i;

	i = MotionFrame.Length;
	MotionFrame.Length = i + 1;
	MotionFrame[i].X = NewLeft;
	MotionFrame[i].Y = NewTop;
	MotionFrame[i].Z = Time;

	if ( i < 1 )
		BeginAnimation(Self);
}

function Resize( float NewWidth, float NewHeight, optional float Time )
{
	local int i;

	i = SizeFrame.Length;
	SizeFrame.Length = i + 1;
	SizeFrame[i].X = NewWidth;
	SizeFrame[i].Y = NewHeight;
	SizeFrame[i].Z = Time;

	if ( i < 1 )
		BeginAnimation(Self);
}

function DAnimate( float NewLeft, float NewTop, float NewWidth, float NewHeight, optional float PositionTime, optional float DimensionTime )
{
	Animate( NewLeft, NewTop, PositionTime );
	Resize( NewWidth, NewHeight, DimensionTime );
}

function KillAnimation()
{
	if ( MotionFrame.Length > 0 )
	{
		MotionFrame.Remove( 0, MotionFrame.Length );
		EndAnimation( Self, AT_Position );
	}

	if ( SizeFrame.Length > 0 )
	{
		SizeFrame.Remove( 0, SizeFrame.Length );
		EndAnimation( Self, AT_Dimension );
	}
}

final function EnableComponent(GUIComponent Comp)
{
	if ( Comp == None )
		return;

	Comp.EnableMe();
}

final function DisableComponent(GUIComponent Comp)
{
	if ( Comp == None )
		return;

	Comp.DisableMe();
}

function EnableMe()
{
	if ( MenuState != MSAT_Disabled )
		return;

	MenuStateChange(MSAT_Blurry);
}

function DisableMe()
{
	if ( MenuState == MSAT_Disabled )
		return;

	MenuStateChange(MSAT_Disabled);
}

function LevelChanged()
{
	if ( ToolTip != None )
		ToolTip.Free();
}

function DebugTabOrder();

defaultproperties
{
     FontScale=FNS_Medium
     WinWidth=1.000000
     RenderWeight=0.500000
     TabOrder=-1
     Tag=-1
     bVisible=True
     bInit=True
}
