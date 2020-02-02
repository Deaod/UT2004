//====================================================================
//  Base class for IRC tab panels
//
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4IRC_Page extends UT2K4TabPanel
    abstract;

var automated moEditBox         ed_TextEntry;
var automated GUISplitter       sp_Main;
var() config float              MainSplitterPosition;

var GUIScrollTextBox            lb_TextDisplay;

var localized string HasLeftText;
var localized string HasJoinedText;
var localized string WasKickedByText;
var localized string NowKnownAsText;
var localized string QuitText;
var localized string SetsModeText;
var localized string NewTopicText;

var config int MaxChatScrollback;
var config int InputHistorySize;
var globalconfig bool bIRCTextToSpeechEnabled;

var transient array<string> InputHistory;
var transient int           InputHistoryPos;
var transient bool          bDoneInputScroll;

var config color IRCTextColor;
var config color IRCNickColor;
var config color IRCActionColor;
var config color IRCInfoColor;
var config color IRCLinkColor;

// Pure Virtual
function ProcessInput(string Text)
{

}

// This disconnects the IRC client at map change!!
function Free()
{
}

// When you hit enter in the input box, call the class
function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local string Input;
    local int Index;

    if ( (key==0xEC) && (State==3) )
    {

        lb_TextDisplay.MyScrollText.WheelUp();
        return true;
    }

    if ( (key==0xED) && (State==3) )
    {

        lb_TextDisplay.MyScrollText.WheelDown();
        return true;
    }

    // Only care about key-press events
    if(State != 1)
        return false;

    if( Key == 0x0D ) // ENTER
    {
        Input = ed_TextEntry.GetText();

        if(Input != "")
        {
            // Add string to end of history
            Index = InputHistory.Length;
            InputHistory.Insert(Index, 1);
            InputHistory[Index] = Input;

            // If history is too long, remove chat from start of history
            if(InputHistory.Length > InputHistorySize)
                InputHistory.Remove(0, InputHistory.Length - InputHistorySize);

            // Once you enter something - reset history position to most recent entry
            InputHistoryPos = InputHistory.Length - 1;
            bDoneInputScroll = false;

            ProcessInput(Input); // Handle whatever you typed
            ed_TextEntry.SetText(""); // And empty box again.
        }

        return true;
    }
    else if( Key == 0x26 ) // UP
    {
        if( InputHistory.Length > 0 ) // do nothing if no history
        {
            ed_TextEntry.SetText( InputHistory[ InputHistoryPos ] );

            InputHistoryPos--;
            if(InputHistoryPos < 0)
                InputHistoryPos = InputHistory.Length - 1;

            bDoneInputScroll = true;
        }

        return true;
    }
    else if( Key == 0x28 ) // DOWN
    {
        if( InputHistory.Length > 0 )
        {
            if(!bDoneInputScroll)
                InputHistoryPos = 0; // Hack so pressing 'down' gives you the oldest input

            ed_TextEntry.SetText( InputHistory[ InputHistoryPos ] );

            InputHistoryPos++;
            if(InputHistoryPos > InputHistory.Length - 1)
                InputHistoryPos = 0;

            bDoneInputScroll = true;
        }

        return true;
    }

    return false;
}


function string ColorizeLinks(string InString)
{
    local int i;
    local string OutString, Character, Word, ColourlessWord;
    local bool InWord, HaveWord;

    i=0;
    while(true)
    {
        // Get the next word in the string
        while( i<Len(InString) && !HaveWord )
        {
            Character = Mid(InString, i, 1);

            if(InWord) // We are in the middle of a word.
            {
                if( Character == " " ) // We hit a terminating space - word complete
                {
                    HaveWord = true;
                }
                else // We are just working through the word
                {
                    Word $= Character;
                    i++;
                }
            }
            else
            {
                if( Character == " " ) // Pass over spaces (add straight to output)
                {
                    OutString $= Character;
                    i++;
                }
                else // Hit the first character of a word.
                {
                    InWord = true;
                    Word $= Character;
                    i++;
                }
            }
        }

        if(Word == "")
            return OutString;

        // Deal with that word
        ColourlessWord = StripColorCodes(Word);
        if( Left(ColourlessWord, 7) == "http://" || Left(ColourlessWord, 9) == "unreal://" || Left(ColourlessWord, Len(PlayerOwner().GetURLProtocol())+3)==(PlayerOwner().GetURLProtocol()$"://") )
            OutString = OutString$MakeColorCode(IRCLinkColor)$ColourlessWord$MakeColorCode(IRCTextColor);
        else
            OutString = OutString$Word;

        // Reset for next word;
        Word = "";
        HaveWord = false;
        InWord = false;
    }

    return OutString;
}

function bool IRCTextDblClick(GUIComponent Sender)
{
    local string ClickString;

    ClickString = StripColorCodes(lb_TextDisplay.MyScrollText.ClickedString);
   	Controller.LaunchURL(ClickString);

    return true;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.Initcomponent(MyController, MyOwner);

    lb_TextDisplay.MyScrollText.MaxHistory = MaxChatScrollback;
    lb_TextDisplay.MyScrollText.bClickText = true;
    lb_TextDisplay.MyScrollText.OnDblClick = IRCTextDblClick;

    lb_TextDisplay.MyScrollText.FocusInstead = ed_TextEntry;
    lb_TextDisplay.MyScrollText.bNeverFocus = True;
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIScrollTextBox(NewComp) != None)
    {
        lb_TextDisplay = GUIScrollTextBox(NewComp);
        lb_TextDisplay.bVisibleWhenEmpty = True;
        lb_TextDisplay.WinWidth = 1.0;
        lb_TextDisplay.WinHeight = 1.0;

        lb_TextDisplay.CharDelay = 0.0015;
        lb_TextDisplay.EOLDelay = 0.25;
        lb_TextDisplay.Separator = Chr(13);
        lb_TextDisplay.bVisibleWhenEmpty = True;
        lb_TextDisplay.bNoTeletype = True;

        lb_TextDisplay.StyleName = "IRCText";
    }
}

function InterpretColorCodes( out string Text )
{
	local int Pos;
	local string Code;

	Pos = InStr(Text, Chr(3));
	while ( Pos != -1 )
	{
		Pos++;
		Code = "";

		while ( IsDigit(Mid(Text,Pos,1)) )
		{
			Code $= Mid(Text,Pos,1);
			Pos++;
		}

		if ( Code != "" && Mid(Text,Pos,1) == "," )
		{
			Text = Left(Text,Pos) $ Mid(Text,Pos+1);
			while ( IsDigit(Mid(Text,Pos,1)) )
				Text = Left(Text,Pos) $ Mid(Text,Pos+1);
		}

		Text = Repl( Text, Chr(3) $ Code, MakeColorCode(DecodeColor(int(Code))) );
		Pos = InStr(Text,Chr(3));
	}
}

function color DecodeColor( int ColorCode )
{
	local color C;

	switch ( ColorCode )
	{
		case 2:
			C = class'Canvas'.static.MakeColor(0,0,127);
			break;

		case 3:
			C = class'Canvas'.static.MakeColor(0,147,0);
			break;

		case 4:
			C = class'Canvas'.static.MakeColor(255,0,0);
			break;

		case 5:
			C = class'Canvas'.static.MakeColor(127,0,0);
			break;

		case 6:
			C = class'Canvas'.static.MakeColor(156,0,156);
			break;

		case 7:
			C = class'Canvas'.static.MakeColor(252,127,0);
			break;

		case 8:
			C = class'Canvas'.static.MakeColor(255,255,0);
			break;

		case 9:
			C = class'Canvas'.static.MakeColor(0,255,0);
			break;

		case 10:
			C = class'Canvas'.static.MakeColor(0,147,147);
			break;

		case 11:
			C = class'Canvas'.static.MakeColor(0,255,255);
			break;

		case 12:
			C = class'Canvas'.static.MakeColor(0,0,252);
			break;

		case 13:
			C = class'Canvas'.static.MakeColor(255,0,255);
			break;

		case 14:
			C = class'Canvas'.static.MakeColor(127,127,127);
			break;

		case 15:
			C = class'Canvas'.static.MakeColor(210,210,210);
			break;

		default:
			C = class'Canvas'.static.MakeColor(255,255,255);

	}

	return C;
}

defaultproperties
{
     Begin Object Class=moEditBox Name=EntryBox
         CaptionWidth=0.000000
         OnCreateComponent=EntryBox.InternalOnCreateComponent
         StyleName="IRCEntry"
         WinTop=0.950000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=0.050000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=UT2K4IRC_Page.InternalOnKeyEvent
     End Object
     ed_TextEntry=moEditBox'GUI2K4.UT2K4IRC_Page.EntryBox'

     HasLeftText="%Name% has left %Chan%."
     HasJoinedText="%Name% has joined %Chan%."
     WasKickedByText="%Kicked% was kicked by %Kicker% ( %Reason% )."
     NowKnownAsText="%OldName% is now known as %NewName%."
     QuitText="*** %Name% Quit ( %Reason% )"
     SetsModeText="*** %Name% sets mode: %mode%."
     NewTopicText="Topic"
     MaxChatScrollback=250
     InputHistorySize=16
     IRCTextColor=(B=160,G=160,R=160)
     IRCNickColor=(B=255,G=150,R=150)
     IRCActionColor=(G=200,R=230)
     IRCInfoColor=(B=160,G=130,R=130)
     IRCLinkColor=(B=150,G=150,R=255)
     WinHeight=1.000000
}
