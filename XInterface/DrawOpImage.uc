class DrawOpImage extends DrawOpBase
	DependsOn(GUI);

var Material		   Image;
var byte               ImageStyle;
var float              SubX, SubY, SubXL, SubYL; // coordinates on Image
var deprecated bool	   bStretch;					// Stretch the picture;

function Draw(Canvas Canvas)
{
	local float X, Y, XL, YL, U, V, UL, VL;

	if ( Image == None )
		return;

	Canvas.Style = RenderStyle;
	Canvas.DrawColor = DrawColor;

	X = Lft * Canvas.SizeX;
	Y = Top * Canvas.SizeY;

	if ( Width < 0 )
		XL = Image.MaterialUSize();
	else XL = Width * Canvas.SizeX;

	if ( Height < 0 )
		YL = Image.MaterialVSize();
	else YL = Height * Canvas.SizeY;
	U = FMax(0, SubX);
	V = FMax(0, SubY);
	if ( SubXL < 0 )
		UL = Image.MaterialUSize();
	else
		UL = SubXL;

	if ( SubYL < 0 )
		VL = Image.MaterialVSize();
	else
		VL = SubYL;

	if ( Justification == 1 )
	{
		X -= XL / 2;
		Y -= YL / 2;
	}
	else if ( Justification == 2 )
	{
		X -= XL;
		Y -= YL;
	}

	Canvas.SetPos(X,Y);

	switch ( ImageStyle )
	{
	case 0: // Normal (scaled to fit)
		Canvas.DrawTile( Image, XL, YL, U, V, UL, VL );
		break;

	case 1: // Stretched
		Canvas.DrawTileStretched(Image,XL,YL);
		break;

	case 2: // Bound
		Canvas.DrawTileClipped( Image, XL, YL, U, V, UL, VL );
		break;
	}

	//Log("DrawOpImage.Draw Called");
}

defaultproperties
{
     SubX=-1.000000
     SubY=-1.000000
     SubXL=-1.000000
     SubYL=-1.000000
}
