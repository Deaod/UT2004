//=============================================================================
// Player: Corresponds to a real player (a local camera or remote net player).
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Player extends Object
	config(User)
	native
	noexport;

//-----------------------------------------------------------------------------
// Player properties.

// Internal.
var native const pointer vfOut;
var native const pointer vfExec;

// The actor this player controls.
var transient const playercontroller Actor;
var transient const playercontroller OldActor;
var transient Console Console;

// Window input variables
var transient const bool bWindowsMouseAvailable;
var bool bShowWindowsMouse;

var transient const float WindowsMouseX;
var transient const float WindowsMouseY;
var transient int CurrentVoiceBandwidth;
var const int CurrentNetSpeed;
var globalconfig int ConfiguredInternetSpeed, ConfiguredLanSpeed;
var byte SelectedCursor;

var transient InteractionMaster InteractionMaster;	// Callback to the IM
var transient array<Interaction> LocalInteractions;	// Holds a listing of all local Interactions
var transient BaseGUIController GUIController;		// Callback to the Menu Controller


const IDC_ARROW=0;
const IDC_SIZEALL=1;
const IDC_SIZENESW=2;
const IDC_SIZENS=3;
const IDC_SIZENWSE=4;
const IDC_SIZEWE=5;
const IDC_WAIT=6;

defaultproperties
{
     ConfiguredInternetSpeed=9636
     ConfiguredLanSpeed=20000
}
