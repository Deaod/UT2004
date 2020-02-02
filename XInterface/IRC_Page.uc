class IRC_Page extends UT2K3TabPanel
    abstract;

var moEditBox           TextEntry;
var GUIScrollTextBox    TextDisplay;

var localized string HasLeftText;
var localized string HasJoinedText;
var localized string WasKickedByText;
var localized string NowKnownAsText;
var localized string QuitText;
var localized string SetsModeText;
var localized string NewTopicText;

var config int MaxChatScrollback;
var config int InputHistorySize;

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

// When you hit enter in the input box, call the class
function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    local string Input;
    local int Index;

    // Only care about key-press events
    if(State != 1)
        return false;

    if( Key == 0x0D ) // ENTER
    {
        Input = TextEntry.GetText();

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
            TextEntry.SetText(""); // And empty box again.
        }

        return true;
    }
    else if( Key == 0x26 ) // UP
    {
        if( InputHistory.Length > 0 ) // do nothing if no history
        {
            TextEntry.SetText( InputHistory[ InputHistoryPos ] );

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

            TextEntry.SetText( InputHistory[ InputHistoryPos ] );

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
                    Word = Word$Character;
                    i++;
                }
            }
            else
            {
                if( Character == " " ) // Pass over spaces (add straight to output)
                {
                    OutString = OutString$Character;
                    i++;
                }
                else // Hit the first character of a word.
                {
                    InWord = true;
                    Word = Word$Character;
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

    ClickString = StripColorCodes(TextDisplay.MyScrollText.ClickedString);
    //Log("DOUBLE CLICKED: ["$ClickString$"]");

    // Check for WWW URL
    if( Left(ClickString, 7) == "http://" )
    {
        PlayerOwner().ConsoleCommand("start"@ClickString);
    }
    else
    if( Left(ClickString, 9) == "unreal://" || Left(ClickString, Len(PlayerOwner().GetURLProtocol())+3)==(PlayerOwner().GetURLProtocol()$"://") )
    {
        Controller.CloseAll(false);
        PlayerOwner().ClientTravel( ClickString, TRAVEL_Absolute, false );
    }

    return true;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.Initcomponent(MyController, MyOwner);

    TextEntry = moEditBox(Controls[0]);
    TextEntry.OnKeyEvent = InternalOnKeyEvent;
    TextEntry.MyEditBox.Style = Controller.GetStyle("IRCEntry", TextEntry.MyEditBox.FontScale); // Force the style of the sub-component to the IRC text style

    TextDisplay = GUIScrollTextBox( GUIPanel( GUISplitter(Controls[1]).Controls[0] ).Controls[0] );
    TextDisplay.MyScrollText.Separator = Chr(13); // New line character
    TextDisplay.MyScrollText.MaxHistory = MaxChatScrollback;
    TextDisplay.MyScrollText.Style = Controller.GetStyle("IRCText",TextDisplay.MyScrollText.FontScale);
    TextDisplay.MyScrollText.bClickText = true;
    TextDisplay.MyScrollText.OnDblClick = IRCTextDblClick;
}

defaultproperties
{
     HasLeftText="has left"
     HasJoinedText="has joined"
     WasKickedByText="was kicked by"
     NowKnownAsText="is now known as"
     QuitText="Quit"
     SetsModeText="sets mode"
     NewTopicText="Topic"
     MaxChatScrollback=250
     InputHistorySize=16
     IRCTextColor=(B=160,G=160,R=160)
     IRCNickColor=(B=255,G=150,R=150)
     IRCActionColor=(G=200,R=230)
     IRCInfoColor=(B=160,G=130,R=130)
     IRCLinkColor=(B=150,G=150,R=255)
     Begin Object Class=moEditBox Name=EntryBox
         CaptionWidth=0.000000
         OnCreateComponent=EntryBox.InternalOnCreateComponent
         WinTop=0.950000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=0.050000
     End Object
     Controls(0)=moEditBox'XInterface.IRC_Page.EntryBox'

     Begin Object Class=GUISplitter Name=MainSplitter
         SplitPosition=0.800000
         bFixedSplitter=True
         Begin Object Class=GUIPanel Name=DisplayPanel
             Begin Object Class=GUIScrollTextBox Name=DisplayBox
                 bNoTeletype=True
                 bStripColors=True
                 CharDelay=0.001500
                 EOLDelay=0.250000
                 bVisibleWhenEmpty=True
                 OnCreateComponent=DisplayBox.InternalOnCreateComponent
                 StyleName="ServerBrowserGrid"
                 WinHeight=1.000000
                 bScaleToParent=True
             End Object
             Controls(0)=GUIScrollTextBox'XInterface.IRC_Page.DisplayBox'

         End Object
         Controls(0)=GUIPanel'XInterface.IRC_Page.DisplayPanel'

         Begin Object Class=GUIPanel Name=UtilPanel
         End Object
         Controls(1)=GUIPanel'XInterface.IRC_Page.UtilPanel'

         WinHeight=0.950000
     End Object
     Controls(1)=GUISplitter'XInterface.IRC_Page.MainSplitter'

     WinTop=0.150000
     WinHeight=0.730000
}
