//==============================================================================
//  Adapted from UT2LoadingPageBase
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4LoadingPageBase extends Vignette;

var array<DrawOpBase>	Operations;


simulated event DrawVignette( Canvas C, float Progress )
{
local int i;

	C.Reset();
	for (i = 0; i<Operations.Length; i++)
		Operations[i].Draw(C);
}

// Uses location/size in percentage from 0.0 to 1.0
simulated function DrawOpImage AddImage(Material Image, float Top, float Left, float Height, float Width)
{
local DrawOpImage NewImage;

	NewImage = new(None) class'DrawOpImage';
	Operations[Operations.Length] = NewImage;

	NewImage.Image = Image;
	NewImage.SetPos(Top, Left);
	NewImage.SetSize(Height, Width);
	return NewImage;
}

simulated function DrawOpImage AddImageStretched(Material Image, float Top, float Left, float Height, float Width)
{
local DrawOpImage NewImage;

	NewImage = AddImage(Image, Top, Left, Height, Width);
	NewImage.ImageStyle = 1;
	return NewImage;
}

simulated function DrawOpText AddText(string Text, float Top, float Left)
{
local DrawOpText NewText;

	NewText = new(None) class'DrawOpText';
	Operations[Operations.Length] = NewText;

	NewText.SetPos(Top, Left);
	NewText.Text = Text;
	return NewText;
}

simulated function DrawOpText AddMultiLineText(string Text, float Top, float Left, float Height, float Width)
{
local DrawOpText NewText;

	NewText = AddText(Text, Top, Left);
	NewText.SetSize(Height, Width);
	return NewText;
}

simulated function DrawOpText AddJustifiedText(string Text, byte Just, float Top, float Left, float Height, float Width, optional byte VAlign)
{
local DrawOpText NewText;

	NewText = AddText(Text, Top, Left);
	NewText.SetSize(Height, Width);
	NewText.Justification = Just;
	NewText.VertAlign = VAlign;
	return NewText;
}

simulated function Material DLOTexture(string TextureFullName)
{
	return Material(DynamicLoadObject(TextureFullName, class'Material'));
}

defaultproperties
{
}
