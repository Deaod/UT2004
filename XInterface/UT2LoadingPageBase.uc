/*=============================================================================
	UnGame.cpp: Unreal game engine.
	Copyright 1997-2002 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Michel Comeau

	I have prepared this SubClass of Vignette so that it can adapt to when
	we have percentage follow up while loading a new map.
	In Init, you build your page using calls to AddImage() and AddText() and
	any of their helper functions. This will prepare the grounds for
	the DrawVignette phase which will render the created stack of drawing
	operations.
=============================================================================*/

class UT2LoadingPageBase extends Vignette;

var array<DrawOpBase>	Operations;

simulated event DrawVignette( Canvas C, float Progress )
{
local int i;

//	PushCanvas(Canvas);
	// Draw the sequence of images/texts
	//Log("Operations.Length = "$Operations.Length);
	for (i = 0; i<Operations.Length; i++)
		Operations[i].Draw(C);
//	PopCanvas(Canvas);
}

// Uses location/size in percentage from 0.0 to 1.0
simulated function DrawOpImage AddImage(Material Image, float Top, float Left, float Height, float Width)
{
local DrawOpImage NewImage;

	//Log("Adding Image @"@Operations.Length);
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

	//Log("Adding Text @"@Operations.Length);
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
//	NewText.WrapMode = 3;
	return NewText;
}

simulated function DrawOpText AddJustifiedText(string Text, byte Just, float Top, float Left, float Height, float Width, optional byte VAlign)
{
local DrawOpText NewText;

	NewText = AddText(Text, Top, Left);
	NewText.SetSize(Height, Width);
//	NewText.WrapMode = 2;
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
