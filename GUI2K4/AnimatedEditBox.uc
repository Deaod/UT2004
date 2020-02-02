//==============================================================================
//	Created on: 10/18/2003
//	This specialized menu-option only displays the editbox when this component is focused
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class AnimatedEditBox extends moEditBox;

// Controls how quickly the component slides open & closed
var() float  Increment;

// Should the caption be the same as the value?
var() bool   bUseValueForCaption;

var() noexport editconst protected bool bUpdated;

function bool InternalOnPreDraw( Canvas C )
{
	CaptionWidth += Increment;

	// Set caret position so that all text will be visible
	MyEditBox.CaretPos = 0;

	// If we've arrived, unhook predraw
	if ( CaptionWidth <= 0.0 || CaptionWidth >= 1.0 )
		OnPreDraw = None;

	return true;
}

function SetText( string Str )
{
	Super.SetText(Str);

	if ( bUseValueForCaption )
		SetCaption(MyEditBox.GetText());
}

function InternalOnActivate()
{
	ShowEditBox();
}

function InternalOnDeactivate()
{
	ShowLabel();
	if ( bUpdated )
		InternalOnChange(Self);

	bUpdated = False;
}

function ShowEditBox()
{
	if ( CaptionWidth > 0.0 )
	{
		// Increment must be negative
		if ( Increment > 0.0 )
			Increment *= -1.0;

		OnPreDraw = InternalOnPreDraw;
	}
}

function ShowLabel()
{
	if ( CaptionWidth < 1.0 )
	{
		// Increment must be a positive number
		if ( Increment < 0.0 )
			Increment *= -1.0;

		OnPreDraw = InternalOnPreDraw;
	}
}

function InternalOnChange(GUIComponent Sender)
{
    if (Controller.bCurMenuInitialized)
    {
    	if ( Sender != Self )
    		bUpdated = True;

    	// If InternalOnChange() was called manually, or we're receiving a call to OnChange() as a result of a call to SetText()
    	if ( Sender == Self || MenuState != MSAT_Focused )
    	{
			if ( !bIgnoreChange )
			{
				if ( bUseValueForCaption )
					SetCaption(MyEditBox.GetText());

				OnChange(Self);
			}
		}
	}

	bIgnoreChange = False;
}

/*
function InternalOnMousePressed(GUIComponent Sender, bool IsRepeat)
{
	// Set bCaptureMouse so that we receive the MouseRelease instead of MyComponent
	bCaptureMouse = True;
}

function InternalOnMouseRelease(GUIComponent Sender)
{
	bCaptureMouse = False;
}
*/

defaultproperties
{
     increment=0.100000
     bAutoSizeCaption=False
     CaptionWidth=1.000000
     OnActivate=AnimatedEditBox.InternalOnActivate
     OnDeActivate=AnimatedEditBox.InternalOnDeactivate
}
