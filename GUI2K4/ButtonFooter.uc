//==============================================================================
//  Created on: 01/02/2004
//  Base class for top level page footers
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class ButtonFooter extends GUIFooter;

var(Footer) editconst noexport float ButtonLeft;
var(Footer) float ButtonHeight, ButtonWidth, Padding, Margin, Spacer;
var(Footer)	bool bFixedWidth, bFullHeight;
var(Footer) bool bAutoSize;
var(Footer) eTextAlign Alignment;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);
	SetupButtons();
}

function bool InternalOnPreDraw(Canvas C)
{
	if ( bBoundToParent && MenuOwner != None )
		WinTop = RelativeTop( MenuOwner.ActualTop() + MenuOwner.ActualHeight() - ActualHeight(), True );
	else
		WinTop = RelativeTop( Controller.ResY - ActualHeight(), True );

	if ( ButtonsSized(C) )
	{
		if ( !bInit )
		{
			ButtonLeft = GetButtonLeft();
			PositionButtons(C);
			OnPreDraw = None;
		}

		bInit = False;
	}

	return true;
}

function ResolutionChanged(int ResX, int ResY)
{
	SetupButtons();
}

function SetupButtons( optional string bPerButtonSizes )
{
	local int i;
	local GUIButton b;

	if ( bPerButtonSizes != "" )
		bFixedWidth = !bool(bPerButtonSizes);

	if ( bAutoSize )
	{
		for (i = 0; i < Controls.Length; i++ )
		{
			b = GUIButton(Controls[i]);
			if ( b != None )
			{
				b.bAutoSize = true;
				b.AutoSizePadding.HorzPerc = b.RelativeWidth(GetPadding(),true);
			}
		}
	}

	OnPreDraw = InternalOnPreDraw;
	bInit = True;
}

function bool ButtonsSized(Canvas C)
{
	local int i;
	local GUIButton b;
	local bool bResult;
	local string str;
	local float T, AH, AT;

	if ( !bPositioned )
		return false;

	bResult = true;
	str = GetLongestCaption(C);

	AH = ActualHeight();
	AT = ActualTop();

	for (i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None )
		{
			if ( bAutoSize && bFixedWidth )
				b.SizingCaption = str;
			else b.SizingCaption = "";

			bResult = bResult && b.bPositioned;
			if ( bFullHeight )
				b.WinHeight = b.RelativeHeight(AH,true);
			else b.WinHeight = b.RelativeHeight(ActualHeight(ButtonHeight),true);

			switch ( Justification )
			{
			case TXTA_Left:
				T = ClientBounds[1];
				break;

			case TXTA_Center:
				T = (AT + AH / 2) - (b.ActualHeight() / 2);
				break;

			case TXTA_Right:
				T = ClientBounds[3] - b.ActualHeight();
				break;
			}

			b.WinTop = b.RelativeTop(T, True );
		}
	}

	return bResult;
}


function PositionButtons( Canvas C )
{
	local int i;
	local GUIButton b;
	local float x;

	for ( i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None && b.bVisible )
		{
			if ( x == 0 )
				x = ButtonLeft;
			else x += GetSpacer();
			b.WinLeft = b.RelativeLeft( x, True );
			x += b.ActualWidth();
		}
	}
}

// Finds the longest caption of all the buttons
function string GetLongestCaption(Canvas C)
{
	local int i;
	local float XL, YL, LongestW;
	local string str;
	local GUIButton b;

	if ( C == None )
		return "";

	for ( i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None && b.bVisible )
		{
			if ( b.Style != None )
				b.Style.TextSize(C, b.MenuState, b.Caption, XL, YL, b.FontScale);
			else C.StrLen( b.Caption, XL, YL );

			if ( LongestW == 0 || XL > LongestW )
			{
				str = b.Caption;
				LongestW = XL;
			}
		}
	}

	return str;
}

function float GetButtonLeft()
{
	local int i;
	local GUIButton b;
	local float TotalWidth, AW, AL;
	local float FooterMargin;

	AL = ActualLeft();
	AW = ActualWidth();
	FooterMargin = GetMargin();

	for (i = 0; i < Controls.Length; i++ )
	{
		b = GUIButton(Controls[i]);
		if ( b != None && b.bVisible )
		{
			if ( TotalWidth > 0 )
				TotalWidth += GetSpacer();

			TotalWidth += b.ActualWidth();
		}
	}

	if ( Alignment == TXTA_Center )
		return (AL + AW) / 2 - FooterMargin / 2 - TotalWidth / 2;

	if ( Alignment == TXTA_Right )
		return (AL + AW - FooterMargin / 2) - TotalWidth;

	return AL + (FooterMargin / 2);
}

function float GetMargin()
{
	return ActualWidth(Margin);
}

function float GetPadding()
{
	return ActualWidth(Padding);
}

function float GetSpacer()
{
	return ActualWidth(Spacer);
}

event Timer()
{
	SetCaption("");
}

defaultproperties
{
     ButtonHeight=1.000000
     Padding=0.140000
     Margin=0.005000
     bFixedWidth=True
     bFullHeight=True
     bAutoSize=True
     Alignment=TXTA_Right
     WinHeight=0.040000
     bNeverFocus=False
     OnPreDraw=ButtonFooter.InternalOnPreDraw
}
