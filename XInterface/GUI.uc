// ====================================================================
//  Class:  UT2K4UI.GUI
//
//  GUI is an abstract class that holds all of the enums and structs
//  for the UI system
//
//  Written by Joe Wilcox
//  Updated by Ron Prestenback
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUI extends Object
    abstract
    instanced
    native
    editinlinenew
    config(User);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// Number of times each of the rendering functions are allowed to be called on a single component each tick
// (PreDraw, Draw, and all delegates)
// Set to 1 to find components that are being rendered (or pre-drawn, or anything) twice each tick
// Set to 0 to disable render debugging
const Counter = 0;

var noexport GUIController Controller;             // Callback to the GUIController running the show
var noexport    plane      SaveModulation;
var noexport     float     SaveX,SaveY;
var noexport     color     SaveColor;
var noexport     font      SaveFont;
var noexport     byte      SaveStyle;


enum eMenuState     // Defines the various states of a component
{
    MSAT_Blurry,            // Component has no focus at all
    MSAT_Watched,           // Component is being watched (ie: Mouse is hovering over, etc)
    MSAT_Focused,           // Component is Focused (ie: selected)
    MSAT_Pressed,           // Component is being pressed
    MSAT_Disabled,          // Component is disabled.
};

enum eDropState     // Defines the state for components allowed to participate in drop operations
{
    DRP_None,       // Not participating in a drop operation
    DRP_Source,     // Currently acting as a source
    DRP_Target,     // Currently a target
    DRP_Accept,     // Accepted dropped data
    DRP_Reject      // Reject dropped data
};

enum eFontScale     // Defines which range of font/fontcolors are used for this component's style
{
    FNS_Small,
    FNS_Medium,
    FNS_Large
};

enum eTextAlign     // Used for aligning text in a box
{
    TXTA_Left,
    TXTA_Center,
    TXTA_Right,
};

enum eTextCase      // Used for forcing case on text
{
    TXTC_None,
    TXTC_Upper,
    TXTC_Lower,
};

enum eImgStyle      // Used to define the style for an image
{
    ISTY_Normal,
    ISTY_Stretched,
    ISTY_Scaled,
    ISTY_Bound,
    ISTY_Justified,
    ISTY_PartialScaled,
    ISTY_Tiled,
};

enum eImgAlign      // Used for aligning justified images in a box
{
    IMGA_TopLeft,
    IMGA_Center,
    IMGA_BottomRight,
};

enum eEditMask      // Used to define the mask of an input box
{
    EDM_None,
    EDM_Alpha,
    EDM_Numeric,
};

enum EMenuRenderStyle
{
    MSTY_None,
    MSTY_Normal,
    MSTY_Masked,
    MSTY_Translucent,
    MSTY_Modulated,
    MSTY_Alpha,
    MSTY_Additive,
    MSTY_Subtractive,
    MSTY_Particle,
    MSTY_AlphaZ,
};

enum eIconPosition
{
    ICP_Normal,
    ICP_Center,
    ICP_Scaled,
    ICP_Stretched,
    ICP_Bound,
};

enum ePageAlign         // Used to Align panels to a form.
{
    PGA_None,
    PGA_Client,
    PGA_Left,
    PGA_Right,
    PGA_Top,
    PGA_Bottom,
};

enum eDrawDirection
{
	DRD_LeftToRight,
	DRD_RightToLeft,
	DRD_TopToBottom,
	DRD_BottomToTop,
};

enum eCellStyle
{
	CELL_FixedSize,
    CELL_FixedCount
};

enum EOrientation
{
	ORIENT_Vertical, ORIENT_Horizontal
};

enum EAnimationType
{
	AT_Position, AT_Dimension,
};

const QBTN_Ok           =1;
const QBTN_Cancel       =2;
const QBTN_Retry        =4;
const QBTN_Continue     =8;
const QBTN_Yes          =16;
const QBTN_No           =32;
const QBTN_Abort        =64;
const QBTN_Ignore       =128;
const QBTN_OkCancel     =3;
const QBTN_AbortRetry   =68;
const QBTN_YesNo        =48;
const QBTN_YesNoCancel  =50;


struct native init GUIListElem
{
    var string Item;
    var object ExtraData;
    var string ExtraStrData;
    var bool   bSection;
};

struct APackInfo	// OBSOLETE - Use CacheManager.GetAnnouncerList() instead
{
	var string PackageName;
    var localized string Description;
};

struct native init MultiSelectListElem
{
	var string Item;
	var object ExtraData;
	var string ExtraStrData;
	var bool   bSelected;
	var int    SelectionIndex;	// Used for tracking
    var bool   bSection;
};

struct native init ImageListElem
{
	var int      Item;
	var Material Image;
	var int	 	 Locked;
};

struct native init GUITreeNode
{
	var() string Caption;
	var() string Value;
	var() string ParentCaption;
	var() string ExtraInfo;
	var() int Level;
	var() bool bEnabled;

cppstruct
{
	UBOOL operator==( const FGUITreeNode& Other ) const;
}
};

struct AutoLoginInfo
{
	var() string IP;
	var() string Port;
	var() string Username;
	var() string Password;
	var() bool   bAutologin;
};

struct GUITabItem
{
	var() string ClassName;
	var() localized string Caption, Hint;
};


// GUI-wide utility functions
static function bool IsDigit( string Test, optional bool bAllowDecimal )
{
	if ( Test == "" )
		return false;

	while ( Test != "" )
	{
		if ( Asc(Left(Test,1)) > 57 )
			return false;
		if ( Asc(Left(Test,1)) < 48 && !(bAllowDecimal && Left(Test,1) == ".") )
			return false;
		Test = Mid(Test,1);
	}

	return true;
}

// Join together array elements into a single string
static final function string JoinArray(array<string> StringArray, optional string delim, optional bool bIgnoreBlanks)
{
    local int i;
    local string s;

    if (delim == "")
        delim = ",";

    for (i = 0; i < StringArray.Length; i++)
    {
        if ((StringArray[i] != "") || (!bIgnoreBlanks))
        {
            if (s != "")
                s $= delim;

            s $= StringArray[i];
        }
    }

    return s;
}


// Temp for profiling

native function Profile(string ProfileName);

native function 			GetModList(out array<string> ModDirs, out array<string> ModTitles);
native function string		GetModValue(string ModDir, string ModKey);
native function material 	GetModLogo(string ModDir);

defaultproperties
{
}
