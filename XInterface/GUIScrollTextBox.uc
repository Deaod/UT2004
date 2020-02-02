//====================================================================
//  Parent: GUIListBoxBase
//   Class: UT2K4UI.GUIScrollTextBox
//    Date: 05-01-2003
//
//  ListBox container for a scrolling text list
//
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class GUIScrollTextBox extends GUIListBoxBase
	native;

var GUIScrollText MyScrollText;

var(GUIScrollText) bool			bRepeat;		// Should the sequence be repeated ?
var(GUIScrollText) bool			bNoTeletype;	// Dont do the teletyping effect at all
var(GUIScrollText) bool			bStripColors;	// Strip out IRC-style colour characters (^C)
var(GUIScrollText) float		InitialDelay;	// Initial delay after new content was set
var(GUIScrollText) float		CharDelay;		// This is the delay between each char
var(GUIScrollText) float		EOLDelay;		// This is the delay to use when reaching end of line
var(GUIScrollText) float		RepeatDelay;	// This is used after all the text has been displayed and bRepeat is true
var(GUIScrollText) eTextAlign	TextAlign;		// How is text Aligned in the control
var(GUIScrollText) string		Separator;		// Propagate to GUIScrollText

var() string ESC, COMMA;	// fake const's

event Created()
{
	ESC = Chr(3);
	COMMA = Chr(44);
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if (GUIScrollText(NewComp) != None && Sender == Self)
		GUIScrollText(NewComp).bNoTeleType = bNoTeleType;

	Super.InternalOnCreateComponent(NewComp, Sender);
}


function InitBaseList(GUIListBase LocalList)
{
	if ((MyScrollText == None || MyScrollText != LocalList) && GUIScrollText(LocalList) != None)
		MyScrollText = GUIScrollText(LocalList);

	Super.InitBaseList(LocalList);

	MyScrollText.Separator = Separator;
   	MyScrollText.InitialDelay = InitialDelay;
	MyScrollText.CharDelay = CharDelay;
	MyScrollText.EOLDelay = EOLDelay;
	MyScrollText.RepeatDelay = RepeatDelay;
	MyScrollText.TextAlign = TextAlign;
	MyScrollText.bRepeat = bRepeat;
	MyScrollText.bNoTeletype = bNoTeletype;
	MyScrollText.OnAdjustTop  = InternalOnAdjustTop;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	if (DefaultListClass != "")
	{
		MyScrollText = GUIScrollText(AddComponent(DefaultListClass));
		if (MyScrollText == None)
		{
	       	log(Class$".InitComponent - Could not create default list ["$DefaultListClass$"]");
            return;
        }
    }

    if (MyScrollText == None)
    {
    	Warn("Could not initialize list!");
    	return;
    }

    InitBaseList(MyScrollText);
}

function SetContent(string NewContent, optional string sep)
{
	MyScrollText.SetContent(NewContent, sep);
}

function Restart()
{
	MyScrollText.Restart();
}

function Stop()
{
	MyScrollText.Stop();
}

function InternalOnAdjustTop(GUIComponent Sender)
{
	MyScrollText.EndScrolling();

}

function bool IsNumber(string Num)
{
	if ( Num > Chr(47) && Num < Chr(58) )
		return true;

	return false;
}

function string StripColors(string MyString)
{
	local int EscapePos, RemCount, LenFromEscape;

	EscapePos = InStr(MyString, ESC); // Chr(3) == ^C
	while(EscapePos != -1)
	{
		LenFromEscape = Len(MyString) - (EscapePos + 1); // how far after the escape character the string goes on for

		// Now we have to work out how many characters follow the ^C and should be removed. This is rather unpleasant..!

		for (RemCount = 0; RemCount < LenFromEscape && RemCount < 7; RemCount++)
		{
			if ( Mid(MyString, EscapePos+RemCount, 1) == ESC ||
				IsNumber(Mid(MyString, EscapePos + RemCount, 1)) ||
				Mid(MyString, EscapePos + RemCount, 1) == COMMA )
				RemCount++;
			else break;
		}
/*		RemCount = 1; // strip the ctrl-C regardless
		if( LenFromEscape >= 1 && IsNumber(Mid(MyString, EscapePos+1, 1)) ) // If a digit follows the ctrl-C, strip that
		{
			RemCount = 2; // #
			if( LenFromEscape >= 3 && Mid(MyString, EscapePos+2, 1) == Chr(44) && IsNumber(Mid(MyString, EscapePos+3, 1)) ) // If we have a comma and another digit, strip those
			{
				RemCount = 4; // #,#
				if( LenFromEscape >= 4 && IsNumber(Mid(MyString, EscapePos+4, 1)) ) // if there is another digit after that, strip it
					RemCount = 5; // #,##
			}
			else if( LenFromEscape >= 2 && IsNumber(Mid(MyString, EscapePos+2, 1)) )// if there is a second digit, strip that
			{
				RemCount = 3; // ##
				if( LenFromEscape >= 4 && Mid(MyString, EscapePos+3, 1) == Chr(44) && IsNumber(Mid(MyString, EscapePos+4, 1)) ) // If we have a comma and another digit, strip those
				{
					RemCount = 5; // ##,#
					if( LenFromEscape >= 5 && IsNumber(Mid(MyString, EscapePos+5, 1)) ) // if there is another digit after that, strip it
						RemCount = 6; // ##,##
				}
			}
		}
*/
		MyString = Left(MyString, EscapePos)$Mid(MyString, EscapePos+RemCount);

		EscapePos = InStr(MyString, Chr(3));
	}

	return MyString;
}

function AddText(string NewText)
{
	local string StrippedText;

	if(NewText == "")
		return;

	if(bStripColors)
		StrippedText = StripColors(NewText);
	else
		StrippedText = NewText;

	if ( MyScrollText.NewText != "" )
		MyScrollText.NewText $= MyScrollText.Separator;

	MyScrollText.NewText $= StrippedText;
}

defaultproperties
{
     CharDelay=0.250000
     EOLDelay=0.750000
     RepeatDelay=3.000000
     Separator="|"
     DefaultListClass="XInterface.GUIScrollText"
     FontScale=FNS_Medium
}
