class GUIProgressBar extends GUIComponent
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var Material	BarBack;		// The unselected portion of the bar
var Material	BarTop;			// The selected portion of the bar
var Color		BarColor;		// The Color of the Bar
var float		Low;			// The minimum value we should see
var float		High;			// The maximum value we should see
var float		Value;			// The current value (not clamped)

var float		CaptionWidth;	// The space reserved to the Caption
var eTextAlign	CaptionAlign;	// How align the text
var eTextAlign	ValueRightAlign;	//
var localized string Caption;	// The Caption itself
var string		FontName;		// Which font to use for display
var string		ValueFontName;	// Font to use for displaying values, use FontName if ValueFontName==""

var float	GraphicMargin;		// How Much margin to trim from graphic (X Margin only)
var float	ValueRightWidth;	// Space to leave free on right side
var bool	bShowLow;			// Show Low(Minimum) left of Bar
var bool	bShowHigh;			// Show High (Maximum) right of Bar
var bool	bShowValue;			// Show the value right of the Bar (like 75 or 75/100)
var int		NumDecimals;		// Number of decimals to display

var eDrawDirection BarDirection;

defaultproperties
{
     BarBack=Texture'InterfaceContent.Menu.BorderBoxD'
     BarTop=Texture'InterfaceContent.Menu.StatusBarInner'
     BarColor=(G=203,R=255,A=255)
     High=100.000000
     CaptionWidth=0.450000
     ValueRightAlign=TXTA_Right
     FontName="UT2MenuFont"
     ValueRightWidth=0.200000
     bShowValue=True
}
