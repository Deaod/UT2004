// ====================================================================
//  Class:  UT2K4UI.GUIStyles
//
//  The GUIStyle is an object that is used to describe common visible
//  components of the interface.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIStyles extends GUI
	Abstract
    Native
	noteditinlinenew;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(Style) const string              KeyName;            // This is the name of the style used for lookup

//  If the desired keyname is one of these, FontScale will be adjusted
//  For backwards compatibility - 0 - Smaller 1 - Larger
var(Style) const string             AlternateKeyName[2];

/* Each style contains 5 values for each font, per size
      Small  0 - 4
      Medium 5 - 9
      Large 10 - 14
*/
var(Style) noexport       string              FontNames[15];       // Holds the names of the 5 fonts to use
var(Style) noexport       GUIFont             Fonts[15];           // Holds the fonts for each state

var(Style) noexport       color               FontColors[5];      // This array holds 1 font color for each state
var(Style) noexport       color               FontBKColors[5];    // This holds the Background Colors for each state
var(Style) noexport       color               ImgColors[5];       // This array holds 1 image color for each state

var(Style) noexport       EMenuRenderStyle    RStyles[5];         // The render styles for each state
var(Style) noexport       Material            Images[5];          // This array holds 1 material for each state (Blurry, Watched, Focused, Pressed, Disabled)
var(Style) noexport       eImgStyle           ImgStyle[5];        // How should each image for each state be drawed
var(Style) noexport       float               ImgWidths[5];       // -1 if full image
var(Style) noexport       float               ImgHeights[5];      // -1 if full image
var(Style) noexport       int                 BorderOffsets[4];   // How thick is the border

var(style) noexport bool	bTemporary;		// This style should be cleaned up

// the OnDraw delegate Can be used to draw.  Return true to skip the default draw method

delegate bool OnDraw(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height);
delegate bool OnDrawText(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height, eTextAlign Align, string Text, eFontScale FontScale);

native static final function Draw(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height);
native static final function DrawText(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height, eTextAlign Align, string Text, eFontScale FontScale);
native static final function TextSize(Canvas Canvas, eMenuState MenuState, string Text, out float XL, out float YL, eFontScale FontScale);

event Initialize()
{
    local int i;

    // Preset all the data if needed
    for ( i = 0; i < ArrayCount(FontNames) && i < ArrayCount(Fonts); i++)
    {
        if (FontNames[i] != "")
            Fonts[i] = Controller.GetMenuFont(FontNames[i]);
    }
}

defaultproperties
{
}
