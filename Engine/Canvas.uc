//=============================================================================
// Canvas: A drawing canvas.
// This is a built-in Unreal class and it shouldn't be modified.
//
// Notes.
//   To determine size of a drawable object, set Style to STY_None,
//   remember CurX, draw the thing, then inspect CurX and CurYL.
//=============================================================================
class Canvas extends Object
	native
	noexport;

// added for drawing solid primatives.
#exec TEXTURE IMPORT NAME=WhiteTexture FILE=Textures\White.tga MIPS=0
#exec TEXTURE IMPORT NAME=BlackTexture FILE=Textures\Black.tga MIPS=0
#exec TEXTURE IMPORT NAME=GrayTexture  FILE=Textures\Gray.tga MIPS=0

// simple default font, so various stuff doesn't crash
#exec Font Import File=Textures\SmallFont.bmp Name="DefaultFont"

// Modifiable properties.
var font    Font;            // Font for DrawText.
var float   FontScaleX, FontScaleY; // Scale for DrawText & DrawTextClipped. // gam
var float   SpaceX, SpaceY;  // Spacing for after Draw*.
var float   OrgX, OrgY;      // Origin for drawing.
var float   ClipX, ClipY;    // Bottom right clipping region.
var float   CurX, CurY;      // Current position for drawing.
var float   Z;               // Z location. 1=no screenflash, 2=yes screenflash.
var byte    Style;           // Drawing style STY_None means don't draw.
var float   CurYL;           // Largest Y size since DrawText.
var color   DrawColor;       // Color for drawing.
var bool    bCenter;         // Whether to center the text.
var bool    bNoSmooth;       // Don't bilinear filter.
var const int SizeX, SizeY;  // Zero-based actual dimensions.
var Plane   ColorModulate;   // sjs - Modulate all colors by this before rendering
var bool	bForceAlpha;	 // Force all drawing to be alpha'ed
var float	ForcedAlpha;	 // How much to force

var bool    bRenderLevel;    // gam - Will render the level if enabled.

// Stock fonts.
var font TinyFont, SmallFont, MedFont;
var localized string TinyFontName, SmallFontName, MedFontName;

// Internal.
var const viewport Viewport; // Viewport that owns the canvas.
var const pointer      pCanvasUtil; // sjs

// native functions.
native(464) final function StrLen( coerce string String, out float XL, out float YL ); // Wrapped!
native(465) final function DrawText( coerce string Text, optional bool CR );
native(466) final function DrawTile( material Mat, float XL, float YL, float U, float V, float UL, float VL );
native(467) final function DrawActor( Actor A, bool WireFrame, optional bool ClearZ, optional float DisplayFOV );
native(468) final function DrawTileClipped( Material Mat, float XL, float YL, float U, float V, float UL, float VL );
native(469) final function DrawTextClipped( coerce string Text, optional bool bCheckHotKey );
native(470) final function TextSize( coerce string String, out float XL, out float YL ); // Clipped!
native(480) final function DrawPortal( int X, int Y, int Width, int Height, actor CamActor, vector CamLocation, rotator CamRotation, optional int FOV, optional bool ClearZ );
native final function vector WorldToScreen( vector WorldLoc );
native final function GetCameraLocation( out vector CameraLocation, out rotator CameraRotation );

native final function SetScreenLight( int index, vector Position, color lightcolor, float radius );
native final function SetScreenProjector( int index, vector Position, color color, float radius, texture tex );
native final function DrawScreenActor( Actor A, optional float FOV, optional bool WireFrame, optional bool ClearZ );
native final function Clear(optional bool ClearRGB, optional bool ClearZ);
native final function WrapStringToArray(string Text, out array<string> OutArray, float dx, optional string EOL);
static native final function WrapText( out String Text, out String Line, float dx, Font F, float FontScaleX );


// jmw - These are two helper functions.  The use the whole texture only.  If you need better support, use DrawTile

native final function DrawTilePartialStretched( Material Mat, float XL, float YL ); // rjp
native final function DrawTileStretched(material Mat, float XL, float YL);
native final function DrawTileJustified(material Mat, byte Justification, float XL, float YL);
native final function DrawTileScaled(material Mat, float XScale, float YScale);
native final function DrawTextJustified(coerce string String, byte Justification, float x1, float y1, float x2, float y2);
native final function DrawActorClipped( Actor A, bool WireFrame, float Left, float Top, float Width, float Height, optional bool ClearZ, optional float DisplayFOV);

// UnrealScript functions.
event Reset()
{
	Font        = Default.Font;
	FontScaleX  = Default.FontScaleX; // gam
	FontScaleY  = Default.FontScaleY; // gam
	SpaceX      = Default.SpaceX;
	SpaceY      = Default.SpaceY;
	OrgX        = Default.OrgX;
	OrgY        = Default.OrgY;
	CurX        = Default.CurX;
	CurY        = Default.CurY;
	Style       = Default.Style;
	DrawColor   = Default.DrawColor;
	CurYL       = Default.CurYL;
	bCenter     = false;
	bNoSmooth   = false;
	Z           = 1.0;
    ColorModulate = Default.ColorModulate; // sjs
}
final function SetPos( float X, float Y )
{
	CurX = X;
	CurY = Y;
}
final function SetOrigin( float X, float Y )
{
	OrgX = X;
	OrgY = Y;
}
final function SetClip( float X, float Y )
{
	ClipX = X;
	ClipY = Y;
}
final function DrawPattern( material Tex, float XL, float YL, float Scale )
{
	DrawTile( Tex, XL, YL, (CurX-OrgX)*Scale, (CurY-OrgY)*Scale, XL*Scale, YL*Scale );
}
final function DrawIcon( texture Tex, float Scale )
{
	if ( Tex != None )
		DrawTile( Tex, Tex.USize*Scale, Tex.VSize*Scale, 0, 0, Tex.USize, Tex.VSize );
}
final function DrawRect( texture Tex, float RectX, float RectY )
{
	DrawTile( Tex, RectX, RectY, 0, 0, Tex.USize, Tex.VSize );
}

final function SetDrawColor(byte R, byte G, byte B, optional byte A)
{
	local Color C;

	C.R = R;
	C.G = G;
	C.B = B;
	if ( A == 0 )
		A = 255;
	C.A = A;
	DrawColor = C;
}

static final function Color MakeColor(byte R, byte G, byte B, optional byte A)
{
	local Color C;

	C.R = R;
	C.G = G;
	C.B = B;
	if ( A == 0 )
		A = 255;
	C.A = A;
	return C;
}

// Draw a vertical line
final function DrawVertical(float X, float height)
{
	local float cX,cY;
	
	CX = CurX; CY = CurY;
    CurX = X;
    DrawTile(Texture'engine.WhiteSquareTexture', 2, height, 0, 0, 2, 2);
    CurX = CX; CurY = CY;
}

// Draw a horizontal line
final function DrawHorizontal(float Y, float width)
{
	local float cx,cy;
	CX = CurX; CY = CurY;
    CurY = Y;
    DrawTile(Texture'engine.WhiteSquareTexture', width, 2, 0, 0, 2, 2);
    CurX = CX; CurY = CY;
}

// Draw Line is special as it saves it's original position

final function DrawLine(int direction, float size)
{
	local float cx,cy;
	CX = CurX; CY = CurY;

	switch (direction)
	{
		case 0:
			CurY-=Size;
			DrawVertical(CurX,size);
			break;
		case 1:
			DrawVertical(CurX,size);
			break;
		case 2:
			CurX-=Size;
			DrawHorizontal(CurY,size);
			break;
		case 3:
			DrawHorizontal(CurY,size);
			break;
	}
    CurX = CX; CurY = CY;
}

final simulated function DrawBracket(float width, float height, float bracket_size)
{
	local float x,y;
	Width  = max(width,5);
	Height = max(height,5);

	x = curX; 	Y = curY;

    DrawHorizontal(CurY,bracket_size);
    DrawHorizontal(CurY+Height,bracket_size);
    DrawVertical(CurX,bracket_size);
    DrawVertical(CurX+Width,bracket_size);

    CurY = Y + Height-bracket_size;
    DrawVertical(CurX,Bracket_size);
    DrawVertical(CurX+Width,Bracket_Size);

    CurX = X+Width-Bracket_Size;
    DrawHorizontal(Y,Bracket_Size);
    DrawHorizontal(Y+Height, Bracket_Size);

}

final simulated function DrawBox(canvas canvas, float width, float height)
{
	DrawHorizontal(CurY,Width);
	DrawHorizontal(CurY+Height,Width);
	DrawVertical(CurX,Height);
	DrawVertical(CurX+Width,Height);
}

simulated function DrawScreenText (String Text, float X, float Y, EDrawPivot Pivot)
{
    local int TextScreenWidth, TextScreenHeight;
    local float UL, VL;

    X *= SizeX;
    Y *= SizeY;

	TextSize (Text, UL, VL);

    TextScreenWidth = UL;
    TextScreenHeight = VL;

    switch (Pivot)
    {
        case DP_UpperLeft:
            break;

        case DP_UpperMiddle:
            X -= TextScreenWidth / 2;
            break;

        case DP_UpperRight:
            X -= TextScreenWidth;
            break;

        case DP_MiddleRight:
            X -= TextScreenWidth;
            Y -= TextScreenHeight / 2;
            break;

        case DP_LowerRight:
            X -= TextScreenWidth;
            Y -= TextScreenHeight;
            break;

        case DP_LowerMiddle:
            X -= TextScreenWidth / 2;
            Y -= TextScreenHeight;
            break;

        case DP_LowerLeft:
            Y -= TextScreenHeight;
            break;

        case DP_MiddleLeft:
            Y -= TextScreenHeight / 2;
            break;

        case DP_MiddleMiddle:
            X -= TextScreenWidth / 2;
            Y -= TextScreenHeight / 2;
            break;
    }

	SetPos (X, Y);
    DrawTextClipped (Text);
}

defaultproperties
{
     Font=Font'Engine.DefaultFont'
     FontScaleX=1.000000
     FontScaleY=1.000000
     Z=1.000000
     Style=1
     DrawColor=(B=127,G=127,R=127,A=255)
     ColorModulate=(W=1.000000,X=1.000000,Y=1.000000,Z=1.000000)
     bRenderLevel=True
     TinyFontName="UT2003Fonts.FontMono"
     SmallFontName="UT2003Fonts.FontMono"
     MedFontName="UT2003Fonts.FontMono800x600"
}
