// ====================================================================
//  Class:  Engine.GUIController
//
//  The GUIController is a simple FILO menu stack.  You have 3 things
//  you can do.  You can Open a menu which adds the menu to the top of the
//  stack.  You can Replace a menu which replaces the current menu with the
//  new menu.  And you can close a menu, which returns you to the last menu
//  on the stack.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIController extends BaseGUIController
    DependsOn(GUI)
    Config(User)
    Abstract
    Native;

#exec OBJ LOAD FILE=InterfaceContent.utx

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

const DoCounter = 1;
var const int FONT_NUM;
var const int STYLE_NUM;
var const int CURSOR_NUM;

struct native ProfileStruct
{
	var string ProfileName;
	var float ProfileSeconds;
};

struct native eOwnageMap
{
	var		int		RLevel;
	var 	string	MapName;
    var		string 	MapDesc;
    var		string	MapURL;
};

var array<ProfileStruct> Profilers;

var              const  floatbox            MouseCursorBounds;
var editinline          Array<vector>       MouseCursorOffset;  // Only X,Y used, between 0 and 1. 'Hot Spot' of cursor material.
var editinline export   protected array<GUIPage>      MenuStack;          // Holds the stack of menus
var                     protected Array<GUIPage>      PersistentStack;    // Holds the set of pages which are persistent across close/open
var editinline          protected Array<GUIFont>      FontStack;          // Holds all the possible fonts
var                     protected Array<GUIStyles>    StyleStack;         // Holds all of the possible styles
var editinline          protected Array<Material>     MouseCursors;       // Holds a list of all possible mouse
var 					array<material>	              ImageList;          // List of various images

struct native AutoLoadMenu
{
	var string MenuClassName;
	var bool   bPreInitialize;
};

struct native init RestoreMenuItem
{
	var() string MenuClassName;
	var() string Param1, Param2;
};

var                     Array<string>       DefaultStyleNames;      // Holds the name of all styles to use
var                     Array<string>       StyleNames;             // Holds the name of all styles to use
var config              array<AutoLoadMenu> AutoLoad;               // Any menu classes in here will be automatically loaded
var                  array<RestoreMenuItem> RestoreMenus;

struct native DesignModeHint
{
	var() localized string Key, Description;
};

var           array<DesignModeHint>         DesignModeHints;        // List of commands for design mode
var config              float               MenuMouseSens;
var                     float               MouseX,MouseY;          // Where is the mouse currently located
var                     float               LastMouseX, LastMouseY;
var                     float               DblClickWindow;         // How long do you have for a double click
var                     float               LastClickTime;          // When did the last click occur
var                     float               ButtonRepeatDelay;      // The amount of delay for faking button repeats
var                     float               RepeatDelta;            // Data var
var                     float               RepeatTime;             // How long until the next repeat;
var                     float               CursorFade;             // How visible is the cursor
var                     float               FastCursorFade;         // How visible is the cursor

var globalconfig        int                 MaxSimultaneousPings;   // Upper limit to number of open connections (for server pinging only - not does include game channels)
var                     int                 FastCursorStep;         // Are we fading in or out
var const               int                 ResX, ResY;             // Current resolution
var                     int                 LastClickX, LastClickY; // Who was the active component
var                     int                 CursorStep;             // Are we fading in or out
var const private   pointer                 Designer;               // GUI design editor window reference

// Sounds
var                     sound               MouseOverSound;
var                     sound               ClickSound;
var                     sound               EditSound;
var                     sound               UpSound;
var                     sound               DownSound;
var						sound				DragSound;
var						sound				FadeSound;

var                     GUIPage             ActivePage;             // Points to the currently active page
var                     GUIComponent        FocusedControl;         // Top most Focused control
var                     GUIComponent        ActiveControl;          // Which control is currently active
var deprecated          GUIComponent        SkipControl;            // This control should be skipped over and drawn at the end
var                     GUIComponent        MoveControl;            // Used for visual design

// Drag - n - Drop support
var                     GUIComponent        DropSource;             // Source component for a drag-n-drop operation currently in progress
var                     GUIComponent        DropTarget;             // Target component for a drag-n-drop operation currently in progress
var GUIContextMenu      ContextMenu;                                // Used for Right Click menus
var GUIToolTip          MouseOver;
var Material            WhiteBorder;


var                     string              GameResolution;
var transient           string              LastGameType;           // Used for some places where we need to know the last gametype selected

// Menu types
var              config string              RequestDataMenu;        // Menu for single item data entry
var              config string              ArrayPropertyMenu;      // Menu for editing static array playinfo properties
var              config string              DynArrayPropertyMenu;   // Menu for editing dynamic array playinfo properties
var              config string              FilterMenu;             // Menu for configuring server browser filters
var              config string              MapVotingMenu;          // Menu that appears for map voting
var              config string              KickVotingMenu;
var              config string              MatchSetupMenu;
var              config string              EditFavoriteMenu;
var               array<string>             MainMenuOptions;        // Menu classes that will be displayed on the main menu
var        globalconfig string              DesignerMenu;           // Menu for in-game GUI designer


var                     byte                RepeatKey;              // Used to determine what should repeat
var                     bool                bIgnoreNextRelease;     // Used to make sure discard errant releases.
var                     bool                ShiftPressed;           // Shift key is being held
var                     bool                AltPressed;             // Alt key is being held
var                     bool                CtrlPressed;            // Ctrl key is being held
var						bool				bModulateStackedMenus;	// If true, all menus except the topmost will be greyed

var globalconfig		bool				bQuietMenu;
var globalconfig        bool                bNoToolTips;            // Do not display mouse-over tool-tips
var globalconfig        bool                bDesignModeToolTips;    // Whether tooltips are displayed while in design mode
var globalconfig        bool                bAutoRefreshBrowser;	// Auto refresh server browser when returning from the game or another menu
var globalconfig        bool                bModAuthor;             // Allows bDesign Mode
var globalconfig        bool                bExpertMode;            // Display all advanced settings
var globalconfig        bool                bDesignMode;            // Are we in design mode;
var                     bool                bInteractiveMode;     // All input goes to design mode
var globalconfig        bool                bHighlightCurrent;      // Highlight the current control being edited
var globalconfig        bool                bDrawFullPaths;         // Display full menu paths in design mode
var 		            bool                MainNotWanted;          // Prevents main menu from being opened when last menu is closed and isn't bAllowedAsLast
var                     bool                bCurMenuInitialized;    // Has the current Menu Finished initialization
var                     bool                bForceMouseCheck;       // HACK
var                     bool                bIgnoreUntilPress;      // HACK //???
var                     bool                bSnapCursor;            // Snap cursor to first component when page is opened

var						float				RenderDelta, LastRenderTime;	// Used for timing

var	config				bool				bFixedMouseSize;		// Keep the mouse from scaling

var const byte          KeyDown[255];			// Bit mask of keys currently held down

var array<class<GUIComponent> > RegisteredClasses;

var bool				bECEEdition;	// Set to true if this is the ECE edition

delegate bool OnNeedRawKeyPress(byte NewKey);
delegate AddBuddy( optional string NewBuddyName );

// =====================================================================================================================
// =====================================================================================================================
//  Utility functions for the UI
// =====================================================================================================================
// =====================================================================================================================


native event GUIFont GetMenuFont(string FontName);  // Finds a given font in the FontStack
native event GUIStyles GetStyle(string StyleName, out GUI.eFontScale FontScale);  // Find a style on the stack
native final function string GetCurrentRes();             // Returns the current res as a string

// Attempts to set the render device to the class specified by NewRenderDevice - returns whether change was successful
native final function bool SetRenderDevice( string NewRenderDevice );
native private final function ResetDesigner();

native final function ResetInput();
native final function GetProfileList(string Prefix, out array<string> ProfileList);
native final function ResetKeyboard();
native final function GetOGGList(out array<string> OGGFiles);

native final function PlayInterfaceSound( GUIComponent.EClickSound SoundType );

native final function SetMoveControl( GUIComponent C );
native function Profile(string ProfileName);

// Used by a demo manager
native function GetDEMList(out array<string> DEMFiles);
native function bool GetDEMHeader(string DemoName, out string MapName, out string GameType,
								  out int ScoreLimit, out int TimeLimit, out int ClientSide,
                                  out string RecordedBy, out string Timestamp, out String ReqPackages);

// Used by Ownage Maps

native function GetOwnageList(out array<int> RLevel, out array<string> MNames, out array<string> MDesc, out array<string> mURL);
native function SaveOwnageList(array<eOwnageMap> Maps);

// deprecated -- Use CacheManager/xUtil instead
native final function GetWeaponList(out array<class<Weapon> > WeaponClass, out array<string> WeaponDesc);
native final function GetMapList( string Prefix, GUIList list, optional bool bDecoText );

// URL stuff

native function LaunchURL(string URL);

// Firewall stuff

native function bool CheckFirewall();
native function bool AuthroizeFirewall();

native function bool CheckForECE();

function string LoadDecoText(string PackageName, string DecoTextName)
{
    local int i;
    local DecoText Deco;
    local string DecoText;

    if (InStr(DecoTextName, ".") != -1)
    {
        if (PackageName == "")
            Divide(DecoTextName, ".", PackageName, DecoTextName);
        else DecoTextName = Mid(DecoTextName, InStr(DecoTextName, ".") + 1);
    }

    Deco = class'xUtil'.static.LoadDecoText(PackageName, DecoTextName);
    if (Deco == None)
        return "";

    for (i = 0; i < Deco.Rows.Length; i++)
    {
        if (DecoText != "")
            DecoText $= "|";
        DecoText $= Deco.Rows[i];
    }

    return DecoText;
}
final function GetTeamSymbolList(out array<string> SymbolNames, optional bool bNoSinglePlayer)
{
	// Moved to CacheManager so GameInfo can access this
	class'CacheManager'.static.GetTeamSymbolList(SymbolNames, bNoSinglePlayer);
}

// -- deprecated

function GUIPage TopPage()
{
    return ActivePage;
}


// =====================================================================================================================
// =====================================================================================================================
//  Initialization
// =====================================================================================================================
// =====================================================================================================================

event InitializeController()
{
    local int i;
    local class<GUIStyles> NewStyleClass;


	PrecachePlayerRecords();

    for (i=0;i<DefaultStyleNames.Length;i++)
    {
        NewStyleClass = class<GUIStyles>(DynamicLoadObject(DefaultStyleNames[i],class'class'));
        if (NewStyleClass != None)
            if (!RegisterStyle(NewStyleClass))
                log("Could not create requested style"@DefaultStyleNames[i]);
    }

    for (i=0;i<StyleNames.Length;i++)
    {
        NewStyleClass = class<GUIStyles>(DynamicLoadObject(StyleNames[i],class'class'));
        if (NewStyleClass != None)
            if (!RegisterStyle(NewStyleClass))
                log("Could not create requested style"@StyleNames[i]);
    }


	for (i=0;i<FontStack.length;i++)
    	FontStack[i].Controller = self;

    class'CacheManager'.static.InitCache();

    bECEEdition = CheckForECE();

}

function PrecachePlayerRecords()
{
    local xUtil.PlayerRecord Rec;

	Rec = class'xUtil'.static.GetPlayerRecord(0);
}

function bool RegisterStyle(class<GUIStyles> StyleClass, optional bool bTemporary)
{
	local GUIStyles NewStyle;
	local int i,index;

	Index = -1;
    if (StyleClass != None)
    {
        for (i = 0; i < StyleStack.Length; i++)
        {
            if (StyleStack[i].Class == StyleClass)
            {
            	log("Style already registered '"$StyleClass$"'");
            	return true;
            }

			if (StyleStack[i].KeyName == StyleClass.Default.KeyName)
            	Index = i;
        }

		NewStyle = new(None) StyleClass;
        if (NewStyle != None)
        {
           // Dynamic Array Auto Sizes StyleStack.
            if (Index<0)
            {
//            	if ( bModAuthor )
//	            	log("Registering Style"@NewStyle,'ModAuthor');
	            StyleStack[StyleStack.Length] = NewStyle;
            }
            else
            {
            	if ( bModAuthor )
	            	log("Replacing Style"@StyleStack[Index].KeyName@"with"@NewStyle,'ModAuthor');
            	StyleStack[Index].Controller = none;
            	StyleStack[Index] = NewStyle;
            }
            NewStyle.Controller = self;
            NewStyle.Initialize();
            NewStyle.bTemporary = bTemporary;
            return true;
        }
    }
    return false;
}

//event class<GUIComponent> AddComponentClass(string ClassName) { return None; }
event class<GUIComponent> AddComponentClass(string ClassName)
{
	local int i;
	local class<GUIComponent> Cls;


	for ( i = 0; i < RegisteredClasses.Length; i++ )
		if ( string(RegisteredClasses[i]) ~= ClassName )
			return RegisteredClasses[i];

	Cls = class<GUIComponent>(DynamicLoadObject(ClassName,class'Class'));
	if ( Cls != None )

		RegisteredClasses[RegisteredClasses.Length] = Cls;

	return Cls;
}


// =====================================================================================================================
// =====================================================================================================================
//  Menu manipulation
// =====================================================================================================================
// =====================================================================================================================

event GUIPage FindPersistentMenuByName( string MenuClass )
{
	local int i;

	if ( MenuClass == "" )
		return None;

	for ( i = 0; i < PersistentStack.Length; i++ )
		if ( MenuClass ~= string(PersistentStack[i].Class) )
			return PersistentStack[i];

	return None;
}

event int FindMenuIndexByName( string MenuClass )
{
	local int i;

	if ( MenuClass == "" )
		return -1;

	for ( i = 0; i < MenuStack.Length; i++ )
		if ( MenuClass ~= string(MenuStack[i].Class) )
			return i;
	return -1;
}

event int FindMenuIndex( GUIPage Menu )
{
	local int i;

	if ( Menu == None )
		return -1;

	for ( i = 0; i < MenuStack.Length; i++ )
		if ( MenuStack[i] == Menu )
			return i;

	return -1;
}

event int FindPersistentMenuIndex( GUIPage Menu )
{
	local int i;

	if ( Menu == None )
		return -1;

	for ( i = 0; i < PersistentStack.Length; i++ )
		if ( Menu == PersistentStack[i] )
			return i;

	return -1;
}

function GUIPage FindPersistentMenuByClass( class<GUIPage> PageClass )
{
	local int i;

	if ( PageClass == None )
		return None;

	for ( i = 0; i < PersistentStack.Length; i++ )
		if ( ClassIsChildOf(PersistentStack[i].Class, PageClass) )
			return PersistentStack[i];

	return None;
}

function GUIPage FindMenuByClass( class<GUIPage> PageClass )
{
	local int i;

	if ( PageClass == None )
		return None;

	for ( i = 0; i < MenuStack.Length; i++ )
		if ( ClassIsChildOf(MenuStack[i].Class,PageClass) )
			return MenuStack[i];

	return None;
}

// CreateMenu - Attempts to Create a menu.  Returns none if it can't
event GUIPage CreateMenu(string NewMenuName)
{
    local class<GUIPage> NewMenuClass;
    local GUIPage NewMenu;
    local int i;


    // Big hack here - If the menu we are creating is XInterface.UT2MainMenu then
    // Pull the actual main menu from native code
    if (NewMenuName ~= "XInterface.UT2MainMenu")
        NewMenuName = GetMainMenuClass();

    // Load the menu's package if needed

    NewMenuClass = class<GUIPage>(AddComponentClass(NewMenuName));
    if (NewMenuClass != None)
    {
        // If it's persistent, try to find an instance in the PersistentStack.
        if( NewMenuClass.default.bPersistent )
        {
            for( i=0;i<PersistentStack.Length;i++ )
            {
                if( PersistentStack[i].Class == NewMenuClass )
                {
                    NewMenu = PersistentStack[i];
                    break;
                }
            }
        }

        // Not found, spawn a new menu
        if( NewMenu == None )
        {
            NewMenu = new(None) NewMenuClass;

            // Check for errors
            if (NewMenu == None)
            {
                log("Could not create requested menu"@NewMenuName);
                return None;
            }
            else
            if( NewMenuClass.default.bPersistent )
            {
                // Save in PersistentStack if it's persistent.
                i = PersistentStack.Length;
                PersistentStack.Length = i+1;
                PersistentStack[i] = NewMenu;
            }
        }

		bCurMenuInitialized = false;
        return NewMenu;
    }

	log("Could not DLO menu '"$NewMenuName$"'");
    return none;
}



// ================================================
// OpenMenu - Opens a new menu and places it on top of the stack
event bool OpenMenu(string NewMenuName, optional string Param1, optional string Param2)
{
    local GUIPage NewMenu;

    // Sanity Check
	if ( bModAuthor )
		log(Class@"OpenMenu ["$NewMenuName$"] ("$Param1$") ("$Param2$")",'ModAuthor');

	if (ActivePage != none)
	{
		if ( !ActivePage.AllowOpen(NewMenuName) )
			return false;
	}

	if ( !bCurMenuInitialized && MenuStack.Length > 0 )
	{
		if ( bModAuthor )
			log("Cannot open menu until menu initialization is complete!",'ModAuthor');

		return false;
	}

    NewMenu = CreateMenu(NewMenuName);
    if (NewMenu!=None)
    {
    	// do not allow the same menu to be duplicated in the stack
    	if ( FindMenuIndex(NewMenu) != -1 )
    	{
    		bCurMenuInitialized = True;
    		return false;
    	}

        NewMenu.ParentPage = ActivePage;
        ResetFocus();
		PushMenu( MenuStack.Length, NewMenu, Param1, Param2 );

		if ( NewMenu.bDisconnectOnOpen )
			ConsoleCommand("DISCONNECT");

        return true;
    }

	log("Could not open menu"@NewMenuName);

	return false;
}

event AutoLoadMenus()
{
    local GUIPage NewMenu;
    local int i;

    super.AutoLoadMenus();

    for ( i=0; i < AutoLoad.Length; i++ )
    {
        NewMenu = CreateMenu(AutoLoad[i].MenuClassName);
        if ( NewMenu == None )
        {
            log("Could not auto-load"@AutoLoad[i].MenuClassName);
            continue;
        }

		if ( AutoLoad[i].bPreInitialize )
	        NewMenu.InitComponent(Self, None);
    }
}

// ================================================
// Replaces a menu in the stack.  returns true if success
event bool ReplaceMenu(string NewMenuName, optional string Param1, optional string Param2, optional bool bCancelled)
{
    local GUIPage NewMenu;

	if ( ActivePage == None || MenuStack.Length == 0 )
		return OpenMenu(NewMenuName, Param1, Param2);

	if ( bModAuthor )
		log(Class@"ReplaceMenu ["$NewMenuName$"]  ("$Param1$")  ("$Param2$")",'ModAuthor');

	if ( !bCurMenuInitialized && MenuStack.Length > 0 )
	{
		if ( bModAuthor )
			log("Cannot replace menu until menu initialization is complete!",'ModAuthor');
		return false;
	}

    NewMenu = CreateMenu(NewMenuName);
    if (NewMenu != None)
    {
        NewMenu.ParentPage = ActivePage.ParentPage;
        ResetFocus();

        // Remove the old menu
        PopMenu( -1, ActivePage, bCancelled );

        // Add this menu to the stack and give it focus
        PushMenu( MenuStack.Length - 1, NewMenu, Param1, Param2 );

        return true;
    }

    return false;
}

// Initialize a new menu and add to the stack at the specified point.
protected event PushMenu( int Index, GUIPage NewMenu, optional string Param1, optional string Param2 )
{
	if ( NewMenu == None )
	{
		log("Call to GUIController.PushMenu() with invalid NewMenu!!!");
		return;
	}

	SetControllerStatus(true);
	if ( Index >= 0 )
	{
		MenuStack[Index] = NewMenu;
		ActivePage = NewMenu;
	}

	CloseOverlays();
	ResetInput();
	if (NewMenu.Controller == None)
	    NewMenu.InitComponent(Self, None);

	NewMenu.CheckResolution(false,Self);

	// Pass along the event
	NewMenu.Opened(NewMenu);

	NewMenu.MenuState = MSAT_Focused;
	NewMenu.PlayOpenSound();

	bCurMenuInitialized = true;

	NewMenu.HandleParameters(Param1, Param2);
	bForceMouseCheck = true;

	NewMenu.OnOpen();
}

protected event PopMenu( int Index, GUIPage CurMenu, optional bool bCancelled )
{
	CloseOverlays();

    // Close out the current page
    CurMenu.Closed( CurMenu, bCancelled );

    if ( Index >= 0 && Index + 1 < MenuStack.Length && MenuStack[Index + 1] != None )
    	MenuStack[Index + 1].ParentPage = CurMenu.ParentPage;

    CurMenu.ParentPage = None;

    // Free all object references
    CurMenu.Free();

	// Sanity check - something may have changed the order of the menustack between
	// now and the original call to CloseMenu()/RemoveMenu()
	if ( Index < 0 )
		return;

	if ( Index >= MenuStack.Length || MenuStack[Index] != CurMenu )
		Index = FindMenuIndex(CurMenu);

    if ( Index >= 0 && Index < MenuStack.Length )
   		MenuStack.Remove( Index, 1 );
}

function bool RemoveMenuAt( int Index, optional bool bCancelled )
{
	if ( Index < 0 || Index >= MenuStack.Length )
		return False;

	return RemoveMenu(MenuStack[Index], bCancelled);
}

// Close a menu that isn't the top menu
event bool RemoveMenu( GUIPage Menu, optional bool bCancelled )
{
    if ( MenuStack.Length == 0 )
    {
        log("GUIController.RemoveMenu() - Attempting to close a non-existing menu page");
        return false;
    }

	if ( Menu == None || Menu == ActivePage )
		return CloseMenu(bCancelled);

	if ( bModAuthor )
		log(Class@"RemoveMenu ["$Menu.Name$"]",'ModAuthor');

	if ( !bCurMenuInitialized )
	{
		if ( bModAuthor )
			log("Cannot remove menu until initialization is complete!",'ModAuthor');
		return false;
	}

	if ( !Menu.OnCanClose(bCancelled) )
		return false;

    ResetInput();
    Menu.PlayCloseSound();       // Play the closing sound

	PopMenu( FindMenuIndex(Menu), Menu, bCancelled );

    // Gab the next page on the stack
    if ( MenuStack.Length == 0 ) // Pass control back to the previous menu
    {
        if ( !Menu.bAllowedAsLast && !MainNotWanted )
            return OpenMenu(GetMainMenuClass());

        ActivePage = None;
        SetControllerStatus(false);
    }

	VerifyStack();
    bForceMouseCheck = true;
    return true;
}

event bool CloseMenu( optional bool bCancelled )   // Close the top menu.  returns true if success.
{
    if ( MenuStack.Length == 0 || ActivePage == None )
    {
        log("Attempting to close a non-existing menu page");
        return false;
    }

	if ( bModAuthor )
		log(Class@"CloseMenu ["$ActivePage.Name$"]",'ModAuthor');

	if ( !bCurMenuInitialized )
	{
		if ( bModAuthor )
			log("Cannot close menu until initialization is complete!",'ModAuthor');
		return false;
	}

	if ( !ActivePage.OnCanClose(bCancelled) )
		return false;

    ResetInput();
    ActivePage.PlayCloseSound();       // Play the closing sound

	PopMenu( FindMenuIndex(ActivePage), ActivePage, bCancelled );
	ActivePage.CheckResolution(True,Self);

    // Gab the next page on the stack
    bCurMenuInitialized=false;
    if ( MenuStack.Length > 0 ) // Pass control back to the previous menu
    {
        ActivePage = MenuStack[MenuStack.Length-1];
        ActivePage.MenuState = MSAT_Focused;

        ResetFocus();
        ActivePage.FocusFirst(None);
        if ( !ActivePage.bNeverFocus )
	        ActivePage.OnActivate();
    }
    else
    {
        if (!ActivePage.bAllowedAsLast && !MainNotWanted)
        {
        	ActivePage = none;
            return OpenMenu(GetMainMenuClass());
        }

        ActivePage = None;
        SetControllerStatus(false);
    }

    bCurMenuInitialized=true;
    if ( ActivePage != None )
    	ActivePage.OnReopen();

    bForceMouseCheck = true;

    return true;
}

event CloseAll(bool bCancel, optional bool bForced)
{
    local int i;

	if ( bModAuthor )
	{
		log(Name@"CloseAll bCancel:"$bCancel@"Forced:"$bForced@"(Currently"@MenuStack.Length@"menus open)",'ModAuthor');
		for ( i = 0; i < MenuStack.Length; i++ )
		{
			if ( MenuStack[i] == None )
				log("   Menu["$i$"]: None",'ModAuthor');
			else
				log("   Menu["$i$"]:"$MenuStack[i].Name,'ModAuthor');
		}
	}

    // Close the current menu manually before we clean up the stack.
    if ( bForced )
    	MainNotWanted = True;

	if ( MenuStack.Length > 0 )
		SaveRestorePages();

    if( MenuStack.Length >= 0 )
        CloseMenu(bCancel);

    MainNotWanted = False;

    for ( i = MenuStack.Length - 1;i >= 0; i-- )
        PopMenu(i, MenuStack[i], bCancel);

    //log("GUIController::CloseAll - After Menu closing "@GameResolution);
    if (GameResolution != "")
    {
        Console(Master.Console).DelayedConsoleCommand("SETRES"@GameResolution);
        GameResolution="";
    }

    ActivePage=None;
    SetControllerStatus(false);
}

function int Count()
{
	return MenuStack.Length;
}

function SaveRestorePages()
{
	local int i;
	local string Param1, Param2, MenuClass;

	// First, clear any current entries
	RestoreMenus.Remove( 0, RestoreMenus.Length );

	for ( i = MenuStack.Length - 1; i >= 0; i-- )
	{
		if ( MenuStack[i] != None )
		{
			if ( MenuStack[i].bRestorable )
			{
				MenuClass = string(MenuStack[i].Class);
				Param1 = "";
				Param2 = "";

				if ( MenuStack[i].GetRestoreParams(Param1, Param2) )
				{
					RestoreMenus.Insert(0, 1);
					RestoreMenus[0].MenuClassName = MenuClass;
					RestoreMenus[0].Param1 = Param1;
					RestoreMenus[0].Param2 = Param2;
				}
			}
		}
	}
}

function PerformRestore()
{
	local int i, idx;

	if ( bModAuthor )
		log("Restoring previously open menus ("$RestoreMenus.Length$" menus to restore)",'ModAuthor');

	for ( i = 0; i < RestoreMenus.Length; i++ )
	{
		idx = FindMenuIndexByName(RestoreMenus[i].MenuClassName);
		if ( idx == -1 )
			OpenMenu(RestoreMenus[i].MenuClassName, RestoreMenus[i].Param1, RestoreMenus[i].Param2);
	}

	RestoreMenus.Remove(0, RestoreMenus.Length);
}

function SetControllerStatus(bool On)
{
	local bool bWasActive;

	if ( bActive && !On && ViewportOwner != None && ViewportOwner.Actor != None )
		ViewportOwner.Actor.UnpressButtons();

	bWasActive = bActive;

    bActive = On;
    bVisible = On;
    bRequiresTick=On;

	if ( bActive && !bWasActive && ViewportOwner != None && ViewportOwner.Actor != None )
		ViewportOwner.Actor.UnpressButtons();

    ViewportOwner.bShowWindowsMouse = On && ViewportOwner.bWindowsMouseAvailable;

    if (On)
        bIgnoreUntilPress = true;
    else
    {
    	ResetDesigner();
        ViewportOwner.Actor.ConsoleCommand("toggleime 0");
    }

    PurgeComponentClasses();
}

event ChangeFocus(GUIComponent Who)
{
	if ( Who != None )
		Who.SetFocus(None);

    return;
}

function ResetFocus()
{
    MoveControl = None;

    if (ActiveControl!=None)
    {
    	ActiveControl.MenuStateChange(MSAT_Blurry);
        ActiveControl = None;
    }

    if ( FocusedControl != None )
    	FocusedControl.LoseFocus(None);

    RepeatKey=0;
    RepeatTime=0;
}

event MoveFocused(GUIComponent C, int bmLeft, int bmTop, int bmWidth, int bmHeight, float ClipX, float ClipY, float Val)
{
	if ( C.bScaleToParent && C.MenuOwner != None )
	{
		ClipX = C.MenuOwner.ActualWidth();
		ClipY = C.MenuOwner.ActualHeight();
	}

	if (bmLeft!=0)
    {
        if ( C.WinLeft < 2.0 && C.WinLeft > -2.0 && !C.bNeverScale )
        	C.WinLeft += (Val/ClipX) * bmLeft;
        else
            C.WinLeft += Val*bmLeft;
    }

    if (bmTop!=0)
    {
        if ( C.WinTop < 2.0 && C.WinTop > -2.0 && !C.bNeverScale )
            C.WinTop += (Val/ClipY) * bmTop;
        else
            C.WinTop += Val*bmTop;
    }

    if (bmWidth!=0)
    {
        if (C.WinWidth < 2.0 && C.WinWidth > -2.0 && !C.bNeverScale)
            C.WinWidth += (Val/ClipX) * bmWidth;
        else
            C.WinWidth += Val*bmWidth;
    }

    if (bmHeight!=0)
    {
        if (C.WinHeight <= 2.0)
            C.WinHeight += (Val/ClipX) * bmHeight;
        else
            C.WinHeight += Val*bmHeight;
    }
}

function bool HasMouseMoved( optional float ErrorMargin )
{
	return Abs(MouseX - LastMouseX) > Abs(ErrorMargin) || Abs(MouseY - LastMouseY) > Abs(ErrorMargin);
}

event bool CanShowHints()
{
	if ( bNoToolTips )
		return false;

	if ( ActivePage != None && ActivePage.bCaptureMouse )
		return false;

	if ( DropSource != None || DropTarget != None )
		return false;

	if ( !bDesignModeToolTips && bDesignMode && bHighlightCurrent )
		return false;

	return true;
}

event bool NeedsMenuResolution()
{
	local int i;

	for ( i = MenuStack.Length - 1; i >= 0; i-- )
	{
		if ( MenuStack[i] != None && MenuStack[i].bRequire640x480 )
			return true;

		if ( !MenuStack[i].bRenderWorld )
			break;
	}

	return false;
}

event SetRequiredGameResolution(string GameRes)
{
    GameResolution = GameRes;
}

event NotifyLevelChange()
{
    local int i;

	if ( bModAuthor )
		log(Class@"NotifyLevelChange()",'ModAuthor');

	ResetDesigner();

	if ( bActive && ViewportOwner.Actor != None && ViewportOwner.Actor.Level != None && ViewportOwner.Actor.Level.IsPendingConnection() )
		SaveRestorePages();

    for (i = MenuStack.Length - 1; i >= 0 && MenuStack.Length != 0; i--)
    {
        // Menus might start closing other menus during NotifyLevelChange, so always check for None
        if (MenuStack[i] != None)
        {
            // If menu is in persistent stack, skip notification here.
        	if ( MenuStack[i].bPersistent )
        		continue;

			if ( MenuStack[i].NotifyLevelChange() )
				RemoveMenu(MenuStack[i], True);
        }
    }

    for (i = PersistentStack.Length - 1; i >= 0; i--)
    {
        if (PersistentStack[i] != None && PersistentStack[i].NotifyLevelChange())
        {
        	if ( PersistentStack[i].IsOpen() )
        		RemoveMenu( PersistentStack[i], True);
        	else PersistentStack[i].Free();

			if ( !PersistentStack[i].bPersistent )
	        	PersistentStack.Remove(i,1);
        }
    }

	PurgeObjectReferences();
	VerifyStack();

	if ( MenuStack.Length > 0 )
		RestoreMenus.Remove(0,RestoreMenus.Length);
}

// =====================================================================================================================
// =====================================================================================================================
//  Menu-stack maintenance & cleanup
// =====================================================================================================================
// =====================================================================================================================

function CloseOverlays()
{
	MouseOver = None;
	ContextMenu = None;
}

function VerifyStack()
{
	local int i;

	for ( i = 0; i < MenuStack.Length; i++ )
	{
		if ( MenuStack[i] == None || (MenuStack[i].Controller == None && bCurMenuInitialized) )
		{
			MenuStack.Remove(i--, 1);
			continue;
		}

		if ( i > 0 )
			MenuStack[i].ParentPage = MenuStack[i-1];
	}

	ConsolidateMenus();
}

function PurgeObjectReferences()
{
	local class<GUIStyles> OriginalStyle;
	local int i;

	// Remove any temporary (i.e. mod-defined) styles
	for ( i = 0; i < STYLE_NUM; i++ )
	{
		if ( StyleStack[i] == None )
		{
			OriginalStyle = class<GUIStyles>(DynamicLoadObject(DefaultStyleNames[i],class'Class'));
			if ( !RegisterStyle(OriginalStyle) )
			{
				log("Could not restore default style "$i$" ("$DefaultStyleNames[i]$")");
				continue;
			}
		}

		if ( StyleStack[i].bTemporary )
		{
			OriginalStyle = class<GUIStyles>(DynamicLoadObject(DefaultStyleNames[i],class'Class'));
			if ( !RegisterStyle(OriginalStyle) )
			{
				log("Could not restore default style "$i$" ("$DefaultStyleNames[i]$")");
				StyleStack[i] = None;
			}
		}
	}

	if (StyleStack.Length > STYLE_NUM)
		StyleStack.Remove(STYLE_NUM, StyleStack.Length - STYLE_NUM);

	if (FontStack.Length > FONT_NUM)
		FontStack.Remove(FONT_NUM, FontStack.Length - FONT_NUM);

	if (MouseCursors.Length > CURSOR_NUM)
		MouseCursors.Remove(CURSOR_NUM, MouseCursors.Length - CURSOR_NUM);

	PurgeComponentClasses();
}

// Should be overridden
function PurgeComponentClasses();

// This is used to remove any duplicate clases from the menu stack (keeping the topmost one)
function ConsolidateMenus()
{
	local int i, j;

	for ( i = MenuStack.Length - 1; i >= 0; i-- )
	{
		for ( j = 0; j < i; j++ )
		{
			if ( MenuStack[i].Class == MenuStack[j].Class )
			{
				MenuStack[j+1].ParentPage = MenuStack[j].ParentPage;
				MenuStack.Remove(j,1);
				break;
			}
		}
	}
}

// =====================================================================================================================
// =====================================================================================================================
//  Main menu classes - should be overridden in child classes
// =====================================================================================================================
// =====================================================================================================================

static event Validate();
native static final function string GetMainMenuClass();          // Returns GameEngine.MainMenuClass
static function string GetSinglePlayerPage();
static function string GetServerBrowserPage();
static function string GetMultiplayerPage();
static function string GetInstantActionPage();
static function string GetModPage();
static function string GetSettingsPage();
static function string GetQuitPage();

// =====================================================================================================================
// =====================================================================================================================
//  Keybind management
// =====================================================================================================================
// =====================================================================================================================

// SetKeyBind( "Space", "Jump" ); return true if successful
final function bool SetKeyBind( string BindKeyName, string BindKeyValue )
{
	ViewportOwner.Actor.ConsoleCommand("set Input" @ BindKeyName @ BindKeyValue );
	return true;
}

final function bool KeyNameFromIndex( byte iKey, out string KeyName, out string LocalizedKeyName )
{
	KeyName = ViewportOwner.Actor.ConsoleCommand("KEYNAME" @ iKey);
	LocalizedKeyName = ViewportOwner.Actor.ConsoleCommand("LOCALIZEDKEYNAME" @ iKey);

	return KeyName != "";
}

// GetCurrentBind( "Space", CommandBoundToSpace ); return true if successful
final function bool GetCurrentBind( string BindKeyName, out string BindKeyValue )
{
	if ( BindKeyName != "" )
	{
		BindKeyValue = ViewportOwner.Actor.ConsoleCommand("KEYBINDING" @ BindKeyName);
		return BindKeyValue != "";
	}

	return false;
}

// GetAssignedKeys( "Jump", ArrayOfKeysThatPerformJump ); return true if successful
final function bool GetAssignedKeys( string BindAlias, out array<string> BindKeyNames, out array<string> LocalizedBindKeyNames )
{
	local int i, iKey;
	local string s;

	BindKeyNames.Length = 0;
	LocalizedBindKeyNames.Length = 0;
	s = ViewportOwner.Actor.ConsoleCommand("BINDINGTOKEY" @ "\"" $ BindAlias $ "\"");
	if ( s != "" )
	{
		Split(s, ",", BindKeyNames);
		for ( i = 0; i < BindKeyNames.Length; i++ )
		{
			iKey = int(ViewportOwner.Actor.ConsoleCommand("KEYNUMBER" @ BindKeyNames[i]));
			if ( iKey != -1 )
				LocalizedBindKeyNames[i] = ViewportOwner.Actor.ConsoleCommand("LOCALIZEDKEYNAME" @ iKey);
		}
	}

	return BindKeyNames.Length > 0;
}

// SearchBinds( "switchweapon ", ArrayofAliasesThatBeginWithSwitchWeapon ); return true if successful
final function bool SearchBinds( string BindAliasMask, out array<string> BindAliases )
{
	local string s;

	BindAliases.Length = 0;
	s = ViewportOwner.Actor.ConsoleCommand("FINDKEYBINDS" @ "\"" $ BindAliasMask $ "\"");
	if ( s != "" )
		Split(s, ",", BindAliases);

	return BindAliases.Length > 0;
}

final function bool KeyPressed( EInputKey iKey )
{
	return KeyDown[iKey] != 0;
}

/** show a Question menu, when the page succesfully opens it returns the handle to it. by default the btnOk is used */
function GUIQuestionPage ShowQuestionDialog(string Question, optional byte Buttons, optional byte defButton)
{
	local GUIQuestionPage QPage;

	if (Buttons == 0) Buttons = 1;

	if (OpenMenu(QuestionMenuClass))
	{
		QPage = GUIQuestionPage(TopPage());
		QPage.SetupQuestion(Question, Buttons, defButton);
		return QPage;
	}
	return none;
}

defaultproperties
{
     FONT_NUM=9
     STYLE_NUM=30
     CURSOR_NUM=7
     MouseCursorOffset(1)=(X=0.500000,Y=0.500000)
     MouseCursorOffset(2)=(X=0.500000,Y=0.500000)
     MouseCursorOffset(3)=(X=0.500000,Y=0.500000)
     MouseCursorOffset(4)=(X=0.500000,Y=0.500000)
     MouseCursorOffset(5)=(X=0.500000,Y=0.500000)
     FontStack(0)=UT2MenuFont'XInterface.GUIController.GUIMenuFont'
     FontStack(1)=UT2DefaultFont'XInterface.GUIController.GUIDefaultFont'
     FontStack(2)=UT2LargeFont'XInterface.GUIController.GUILargeFont'
     FontStack(3)=UT2HeaderFont'XInterface.GUIController.GUIHeaderFont'
     FontStack(4)=UT2SmallFont'XInterface.GUIController.GUISmallFont'
     FontStack(5)=UT2MidGameFont'XInterface.GUIController.GUIMidGameFont'
     FontStack(6)=UT2SmallHeaderFont'XInterface.GUIController.GUISmallHeaderFont'
     FontStack(7)=UT2ServerListFont'XInterface.GUIController.GUIServerListFont'
     FontStack(8)=UT2IRCFont'XInterface.GUIController.GUIIRCFont'
     MouseCursors(0)=Texture'InterfaceContent.Menu.MouseCursor'
     MouseCursors(1)=Texture'InterfaceContent.Menu.SplitterCursor'
     MouseCursors(2)=Texture'InterfaceContent.Menu.SplitterCursor'
     MouseCursors(3)=Texture'InterfaceContent.Menu.SplitterCursorVert'
     MouseCursors(4)=Texture'InterfaceContent.Menu.SplitterCursor'
     MouseCursors(5)=Texture'InterfaceContent.Menu.SplitterCursor'
     MouseCursors(6)=Texture'InterfaceContent.Menu.MouseCursor'
     DefaultStyleNames(0)="XInterface.STY_RoundButton"
     DefaultStyleNames(1)="XInterface.STY_RoundScaledButton"
     DefaultStyleNames(2)="XInterface.STY_SquareButton"
     DefaultStyleNames(3)="XInterface.STY_ListBox"
     DefaultStyleNames(4)="XInterface.STY_ScrollZone"
     DefaultStyleNames(5)="XInterface.STY_TextButton"
     DefaultStyleNames(6)="XInterface.STY_Page"
     DefaultStyleNames(7)="XInterface.STY_Header"
     DefaultStyleNames(8)="XInterface.STY_Footer"
     DefaultStyleNames(9)="XInterface.STY_TabButton"
     DefaultStyleNames(10)="XInterface.STY_CharButton"
     DefaultStyleNames(11)="XInterface.STY_ArrowLeft"
     DefaultStyleNames(12)="XInterface.STY_ArrowRight"
     DefaultStyleNames(13)="XInterface.STY_ServerBrowserGrid"
     DefaultStyleNames(14)="XInterface.STY_NoBackground"
     DefaultStyleNames(15)="XInterface.STY_ServerBrowserGridHeader"
     DefaultStyleNames(16)="XInterface.STY_SliderCaption"
     DefaultStyleNames(17)="XInterface.STY_LadderButton"
     DefaultStyleNames(18)="XInterface.STY_LadderButtonHi"
     DefaultStyleNames(19)="XInterface.STY_LadderButtonActive"
     DefaultStyleNames(20)="XInterface.STY_BindBox"
     DefaultStyleNames(21)="XInterface.STY_SquareBar"
     DefaultStyleNames(22)="XInterface.STY_MidGameButton"
     DefaultStyleNames(23)="XInterface.STY_TextLabel"
     DefaultStyleNames(24)="XInterface.STY_ComboListBox"
     DefaultStyleNames(25)="XInterface.STY_SquareMenuButton"
     DefaultStyleNames(26)="XInterface.STY_IRCText"
     DefaultStyleNames(27)="XInterface.STY_IRCEntry"
     DefaultStyleNames(28)="XInterface.STY_ListSelection"
     DefaultStyleNames(29)="XInterface.STY_EditBox"
     DesignModeHints(0)=(Key=" Key",Description="                                Description")
     DesignModeHints(1)=(Key=" (F1)",Description="                                View this help screen")
     DesignModeHints(2)=(Key=" Ctrl + Alt + D",Description="                      Toggles design mode")
     DesignModeHints(3)=(Key=" Ctrl + Alt + E",Description="                      Toggles property editor mode")
     DesignModeHints(4)=(Key=" [Ctrl +] H",Description="                          Toggles active/focused info")
     DesignModeHints(5)=(Key=" [Ctrl +] I",Description="                          Toggle interactive mode")
     DesignModeHints(6)=(Key=" [Ctrl +] P",Description="                          Toggles full MenuOwner chains for active/focused")
     DesignModeHints(7)=(Key=" [Ctrl +] C",Description="                          Copy MoveControl position to clipboard")
     DesignModeHints(8)=(Key=" [Ctrl +] X",Description="                          Export MoveControl to clipboard")
     DesignModeHints(9)=(Key=" [Ctrl +] U",Description="                          Refresh the property window in the designer")
     DesignModeHints(10)=(Key=" [Ctrl +] Up/Down/Left/Right",Description="         Reposition MoveControl using arrow keys")
     DesignModeHints(11)=(Key=" [Ctrl +] +/-",Description="                        Resize MoveControl vertically")
     DesignModeHints(12)=(Key=" [Ctrl +] Num+/Num-",Description="                  Resize selected component horizontally")
     DesignModeHints(13)=(Key=" [Ctrl +] WheelUp",Description="                    Set MoveControl to MoveControl's menuowner")
     DesignModeHints(14)=(Key=" [Ctrl +] WheenDown",Description="                  Set MoveControl to MoveControl's focused control")
     DesignModeHints(15)=(Key=" [(Ctrl + Alt) +] MouseX/Y+LMouse",Description="    Reposition MoveControl using mouse")
     DesignModeHints(16)=(Key=" (Shift)",Description="                             Hides all design mode indicators")
     DesignModeHints(17)=(Key=" (Ctrl + Alt)",Description="                        View focus chain")
     DesignModeHints(18)=(Key=" [Ctrl +] Tab",Description="                        Select new MoveControl")
     DesignModeHints(19)=(Key=" [Ctrl +] LMouse",Description="                     Select new MoveControl")
     MenuMouseSens=1.250000
     DblClickWindow=0.500000
     ButtonRepeatDelay=0.250000
     FastCursorStep=1
     CursorStep=1
     MouseOverSound=Sound'MenuSounds.MS_MouseOver'
     ClickSound=Sound'MenuSounds.MS_Click'
     EditSound=Sound'MenuSounds.MS_Edit'
     UpSound=Sound'MenuSounds.MS_ListChangeUp'
     DownSound=Sound'MenuSounds.MS_ListChangeDown'
     WhiteBorder=Texture'InterfaceContent.Menu.WhiteBorder'
     RequestDataMenu="GUI2K4.UT2K4GetDataMenu"
     ArrayPropertyMenu="GUI2K4.GUIArrayPropPage"
     DynArrayPropertyMenu="GUI2K4.GUIDynArrayPage"
     FilterMenu="GUI2K4.UT2K4_FilterListPage"
     MapVotingMenu="xVoting.MapVotingPage"
     KickVotingMenu="xVoting.KickVotingPage"
     MatchSetupMenu="xVoting.MatchConfigPage"
     EditFavoriteMenu="GUI2K4.EditFavoritePage"
     DesignerMenu="GUIDesigner.PropertyManager"
     bModulateStackedMenus=True
     bExpertMode=True
     bHighlightCurrent=True
     bCurMenuInitialized=True
     NetworkMsgMenu="GUI2K4.UT2K4NetworkStatusMsg"
     QuestionMenuClass="XInterface.GUIQuestionPage"
}
