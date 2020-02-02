// ====================================================================
//  Class:  UT2K4UI.GUIPage
//
//  GUIPages are the base for a full page menu.  They contain the
//  Control stack for the page.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIPage extends GUIMultiComponent
    Native  Abstract;

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


var()                           bool                    bRenderWorld;       // False - don't render anything behind this menu / True - render normally (everything)
var()                           bool                    bPauseIfPossible;   // Should this menu pause the game if possible
var()                           bool                    bCheckResolution;   // obsolete
var()                           bool					bCaptureInput;		// Whether to allow input to be passed to pages lower on the menu stack.

var()                           bool                    bRequire640x480;    // Does this menu require at least 640x480
var()                           bool                    bPersistent;        // If set, page is saved across open/close/reopen.
var()                           bool                    bDisconnectOnOpen;  // Should this menu for a disconnect when opened.
var()                           bool                    bAllowedAsLast;     // If this is true, closing this page will not bring up the main menu
var()                           bool                    bRestorable;        // When the GUIController receives a call to CloseAll(), should it reopen this page the next time main is opened?

var() noexport editconst       GUIPage                  ParentPage;         // The page that exists before this one
var()                           Material                Background;         // The background image for the menu
var()                           Color                   BackgroundColor;    // The color of the background
var()                           Color                   InactiveFadeColor;  // Color Modulation for Inactive Page
var()                           Sound                   OpenSound;          // Sound to play when opened
var()                           Sound                   CloseSound;         // Sound to play when closed
var() noexport editconst
	editconstarray const array<GUIComponent>            Timers;             // List of components with Active Timers
                                                                            // if last on the stack.

var()                           EMenuRenderStyle        BackgroundRStyle;

// Delegates
delegate OnOpen()
{
	if ( Controller != None && Controller.bSnapCursor )
		CenterMouse();
}

delegate OnReOpen();
delegate OnClose(optional bool bCancelled);

delegate bool OnCanClose(optional Bool bCancelled)
{
    return true;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    Super.Closed(Sender, bCancelled);
    OnClose(bCancelled);
}

//=================================================
// PlayOpenSound / PlayerClosedSound

function PlayOpenSound()
{
    PlayerOwner().PlayOwnedSound(OpenSound,SLOT_Interface,1.0);
}

function PlayCloseSound()
{
    PlayerOwner().PlayOwnedSound(CloseSound,SLOT_Interface,1.0);
}


//=================================================
// InitComponent is responsible for initializing all components on the page.

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    FocusFirst(none);
}

//=================================================
// CheckResolution - Tests to see if this menu requires a resoltuion of at least 640x480 and if so, switches

function CheckResolution(bool Closing, GUIController InController)
{
	local string CurrentRes;
	local string Xstr, Ystr;
	local int ResX, ResY;

	if ( InController == None )
		return;

	if ( InController.ResX == 0 || InController.ResY == 0 )
	{
		CurrentRes = PlayerOwner().ConsoleCommand("GETCURRENTRES");
		if ( Divide(CurrentRes, "x", Xstr, Ystr) )
		{
			ResX = int(Xstr);
			ResY = int(Ystr);
		}
	}

	else
	{
		ResX = InController.ResX;
		ResY = InController.ResY;
		CurrentRes = InController.ResX $ "x" $ InController.ResY;
	}

    if (!Closing)
    {
    	if ( InController != None && ResX < 640 && ResY < 480 && bRequire640x480 )
        {
        	if ( InController.bModAuthor )
            	log(Name$".CheckResolution() - menu requires 640x480.  Currently at "$CurrentRes,'ModAuthor');

            InController.GameResolution = CurrentRes;
            Console(InController.Master.Console).DelayedConsoleCommand("TEMPSETRES 640x480");
        }

        return;

    }

    if ( !bRequire640x480 || InController.GameResolution == "" )
        return;

    if ( CurrentRes != InController.GameResolution )
	{
		if ( !InController.NeedsMenuResolution() )
	    {
	    	if ( InController.bModAuthor )
	    		log(Name$".CheckResolution() - restoring menu resolution to standard value:"@InController.GameResolution,'ModAuthor');
	        Console(InController.Master.Console).DelayedConsoleCommand("SETRES"@InController.GameResolution);
	        InController.GameResolution = "";
	    }

	    else if ( InController.bModAuthor )
	    	log(Name$".CheckResolution() - not restoring resolution to standard value: ParentMenu would abort.",'ModAuthor');
	}
}

event ChangeHint(string NewHint)
{
	SetHint(NewHint);
}

event SetFocus(GUIComponent Who)
{
    if (Who==None)
        return;

    Super.SetFocus(Who);
}

event HandleParameters(string Param1, string Param2);   // Should be subclassed
function bool GetRestoreParams( out string Param1, out string Param2 ); // Params will be used when page is reopened

// Should be subclassed - general purpose function to workaround menuclass dependancy
// Not called from anywhere - call it only if you need it
function HandleObject( Object Obj, optional Object OptionalObj_1, optional Object OptionalObj_2 );
function string GetDataString() { return ""; }
function SetDataString(string Str);

// If !bPersistent, return true for GUIController to close this menu at level change
// If bPersistent, return true to be removed from persistent stack at level change (will also be closed if open)
function bool NotifyLevelChange()
{
	LevelChanged();
	return true;
}

event Free()            // This control is no longer needed
{
    local int i;

    if ( !bPersistent )
	{
	    for ( i = 0; i < Timers.Length; i++ )
	        Timers[i]=None;

	    Super.Free();
	}
}

final function bool IsOpen()
{
	if ( Controller == None )
		return false;

	return Controller.FindMenuIndex(Self) != -1;
}

function bool AllowOpen(string MenuClass)
{
	return true;
}

defaultproperties
{
     bCaptureInput=True
     bRequire640x480=True
     BackgroundColor=(B=255,G=255,R=255,A=255)
     InactiveFadeColor=(B=64,G=64,R=64,A=255)
     BackgroundRStyle=MSTY_Normal
     RenderWeight=0.000100
     bTabStop=False
     bAcceptsInput=True
}
