//====================================================================
//  Private IRC conversations
//
//  Updated by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4IRC_Private extends UT2K4IRC_Channel;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	sp_Main.SplitPosition = 1;
	sp_Main.OnReleaseSplitter = None;
	sp_Main.OnLoadINI = None;
	sp_Main.bFixedSplitter = true;
	sp_Main.bDrawSplitter = false;
}

function ProcessInput(string Text)
{
	if(Left(Text, 4) ~= "/me ")
	{
		PrivateAction(tp_System.NickName, Mid(Text, 4));
		tp_System.Link.SendChannelAction(ChannelName, Mid(Text, 4));
	}
	else if(Left(Text, 1) == "/")
    {
		tp_System.Link.SendCommandText(Mid(Text, 1));
    }
	else
	{
		if(Text != "")
		{
			PrivateText(tp_System.NickName, Text);
			tp_System.Link.SendChannelText(ChannelName, Text);
		}
	}
}

function PrivateText(string Nick, string Text)
{
	if( MyButton.bActive && bIRCTextToSpeechEnabled )
		PlayerOwner().TextToSpeech( StripColorCodes(Text), 1 );

	InterpretColorCodes(Text);
	lb_TextDisplay.AddText( MakeColorCode(IRCNickColor)$"<"$Nick$"> "$MakeColorCode(IRCTextColor)$ColorizeLinks(Text) );

    if( tp_System.InGame() )
	    PlayerOwner().ClientMessage("IRC: <"$Nick$"> "$Text);

	if(!MyButton.bActive)
		MyButton.bForceFlash = true;
}

function PrivateAction(string Nick, string Text)
{
	InterpretColorCodes(Text);
	lb_TextDisplay.AddText(MakeColorCode(IRCActionColor)$"* "$Nick$" "$Text);

	if( tp_System.InGame() )
	    PlayerOwner().ClientMessage("IRC: * "$Nick$" "$Text);

	if(!MyButton.bActive)
		MyButton.bForceFlash = true;
}

function PrintAwayMessage(string Nick, string Message)
{
	InterpretColorCodes(Message);
	lb_TextDisplay.AddText(MakeColorCode(IRCInfoColor)$Nick@tp_System.IsAwayText$": "$ColorizeLinks(Message));

	if(!MyButton.bActive)
		MyButton.bForceFlash = true;
}

// Override these functions - no user list
// user funcs ---
function int GetUser( string Nick )
{
	if ( Nick ~= ChannelName )
		return 0;

	return -1;
}

function bool FindNick( string Nick )
{
	if ( Nick ~= ChannelName )
		return true;

	return false;
}

function AddUser( string Nick )
{
}

function RemoveUser( string Nick )
{
}

function ChangeNick( string OldNick, string NewNick)
{
	if ( OldNick ~= ChannelName )
	{
		// Update the channel name
		ChannelName = NewNick;

		// Update the tab caption
		MyButton.Caption = NewNick;

	}
}

function ChangeOp( string Nick, bool NewOp )
{
}

function ChangeHalfOp( string Nick, bool NewHalfOp )
{
}

function ChangeVoice( string Nick, bool NewVoice )
{
}

function bool ContextMenuOpen(GUIContextMenu Sender)
{
	return false;
}

defaultproperties
{
}
