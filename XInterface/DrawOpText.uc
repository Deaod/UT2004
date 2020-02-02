class DrawOpText extends DrawOpBase;

var localized string Text;
var string FontName;			// Font to use
var int				MaxLines;			// In case a multiline is too tall.
/** set to true to wrap text on "|" */
var bool			bWrapText;

var byte VertAlign;

function Draw(Canvas Canvas)
{
	local Font Fnt;
	local int i;
	local float X, Y, XL, YL, TextHeight, StrHeight, StrWidth;
	local array<string> Lines;

	Super.Draw(Canvas);
	if (FontName != "")
	{
		Fnt = GetFont(FontName, Canvas.SizeX);
		if (Fnt != None)
			Canvas.Font = Fnt;
	}

	Canvas.FontScaleX = 0.9;
	Canvas.FontScaleY = 0.9;

	X = Lft * Canvas.SizeX;
	Y = Top * Canvas.SizeY;
	XL = Width * Canvas.SizeX;
	YL = Height * Canvas.SizeY;

	Canvas.StrLen(Text, StrWidth, StrHeight);
	if (bWrapText) Canvas.WrapStringToArray(Text, Lines, XL, "|");
		else Lines[0] = Text;
	TextHeight = StrHeight * Lines.length;

	switch ( VertAlign )
	{
		case 1: // Center
			Y = Y + (YL - TextHeight) / 2;
			break;

		case 2: // Bottom
			Y = Y + YL - TextHeight;
			break;
	}

	for ( i = 0; i < Lines.Length; i++ )
	{
		Canvas.StrLen(Lines[i], StrWidth, StrHeight);
		switch ( Justification )
		{
			case 0: // left
				Canvas.SetPos(X, Y);
				break;

			case 1: // center
				Canvas.SetPos(X + (XL - StrWidth) / 2, Y);
				break;

			case 2: // right
				Canvas.SetPos(X + XL - StrWidth, Y);
				break;
		}

		Canvas.DrawText(Lines[i]);
		Y += StrHeight;
	}
}

defaultproperties
{
     FontName="XInterface.UT2DefaultFont"
     MaxLines=99
     bWrapText=True
}
