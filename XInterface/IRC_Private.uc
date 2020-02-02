class IRC_Private extends IRC_Channel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	GUISplitter(Controls[1]).SplitOrientation = SPLIT_Horizontal;
	GUISplitter(Controls[1]).SplitPosition = 1;
	GUISplitter(Controls[1]).bFixedSplitter = true;
	GUISplitter(Controls[1]).bDrawSplitter = false;
}

function ProcessInput(string Text)
{
	if(Left(Text, 4) ~= "/me ")
	{
		PrivateAction(SystemPage.NickName, Mid(Text, 4));
		SystemPage.Link.SendChannelAction(ChannelName, Mid(Text, 4));
	}
	else if(Left(Text, 1) == "/")
    {
		SystemPage.Link.SendCommandText(Mid(Text, 1));
    }
	else
	{
		if(Text != "")
		{
			PrivateText(SystemPage.NickName, Text);
			SystemPage.Link.SendChannelText(ChannelName, Text);
		}
	}
}

function ChangedNick(string OldNick, string NewNick)
{
	TextDisplay.AddText(MakeColorCode(IRCInfoColor)$"*** "$OldNick@NowKnownAsText@NewNick$".");
	ChannelName = NewNick; // channel name matches nick for private channels
	MyButton.Caption = NewNick;

	// If page is not currently active, flash its tab
	if(!MyButton.bActive)
		MyButton.bForceFlash = true;
	// if it is active, change the 'close' button text
	else
		SystemPage.IRCPage.LeaveButton.Caption = SystemPage.IRCPage.LeavePrivateCaptionHead$Caps(NewNick)$SystemPage.IRCPage.LeavePrivateCaptionTail;
}

function UserQuit(string Nick, string Reason)
{
	TextDisplay.AddText(MakeColorCode(IRCInfoColor)$"*** "$Nick@QuitText@"("$Reason$").");

	if(!MyButton.bActive)
		MyButton.bForceFlash = true;
}

function PrivateText(string Nick, string Text)
{
	TextDisplay.AddText( MakeColorCode(IRCNickColor)$"<"$Nick$"> "$MakeColorCode(IRCTextColor)$ColorizeLinks(Text) );

    if( SystemPage.InGame() )
	    PlayerOwner().ClientMessage("IRC: <"$Nick$"> "$Text);

	if(!MyButton.bActive)
		MyButton.bForceFlash = true;
}

function PrivateAction(string Nick, string Text)
{
	TextDisplay.AddText(MakeColorCode(IRCActionColor)$"* "$Nick$" "$Text);

	if( SystemPage.InGame() )
	    PlayerOwner().ClientMessage("IRC: * "$Nick$" "$Text);

	if(!MyButton.bActive)
		MyButton.bForceFlash = true;
}

function IsAway(string Nick, string Message)
{
	TextDisplay.AddText(MakeColorCode(IRCInfoColor)$Nick@SystemPage.IsAwayText$": "$ColorizeLinks(Message));

	if(!MyButton.bActive)
		MyButton.bForceFlash = true;
}

defaultproperties
{
}
