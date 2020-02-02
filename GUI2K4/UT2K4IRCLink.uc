class UT2K4IRCLink extends BufferedTCPLink;

var IpAddr			ServerIpAddr;

var string			ServerAddress;
var int				ServerPort;

var string			NickName;
var string			UserIdent;
var string			FullName;
var string			DefaultChannel;

var localized string InvalidAddressText;
var localized string ErrorBindingText;
var localized string ResolveFailedText;
var localized string ConnectedText;
var localized string ConnectingToText;
var localized string TimeOutError;
var localized string InviteString;

var UT2K4IRC_System SystemPage;

var string DisconnectReason;
var string VersionString;

struct CommandAlias
{
	var() string AliasText;
	var() string RealCommand;
};

var config array<CommandAlias> Shortcuts;

var transient float		SinceLastLevCheck;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Disable('Tick');
}

function CloseMe()
{
	if ( SystemPage != None )
		SystemPage.CloseLink(Self, False);

	else DestroyLink();
}


function Connect(UT2K4IRC_System InSystemPage, string InServer, string InNickName, string InUserIdent, string InFullName, string InDefaultChannel)
{
	local int i;

    log("UT2K4IRCLink Connect:"@InServer@InNickName@InUserIdent@InFullName@InDefaultChannel,'IRC');

	SystemPage = InSystemPage;
	NickName = InNickName;
	FullName = InFullName;
	UserIdent = InUserIdent;
	DefaultChannel = InDefaultChannel;

	i = InStr(InServer, ":");
	if(i == -1)
	{
		ServerAddress = InServer;
		ServerPort = 6667;
	}
	else
	{
		ServerAddress = Left(InServer, i);
		ServerPort = Int(Mid(InServer, i+1));
	}

	ResetBuffer();
	ServerIpAddr.Port = ServerPort;
	SetTimer(20, False);
	SystemPage.SystemText( ConnectingToText@ServerAddress );
	Resolve( ServerAddress );
}

function string ChopLeft(string Text)
{
	while(Text != "" && InStr(": !", Left(Text, 1)) != -1)
		Text = Mid(Text, 1);
	return Text;
}

function string RemoveNickPrefix(string Nick)
{
	while(Nick != "" && InStr(":@+%", Left(Nick, 1)) != -1)
		Nick = Mid(Nick, 1);
	return Nick;
}

function string Chop(string Text)
{
	while(Text != "" && InStr(": !", Left(Text, 1)) != -1)
		Text = Mid(Text, 1);
	while(Text != "" && InStr(": !", Right(Text, 1)) != -1)
		Text = Left(Text, Len(Text)-1);

	return Text;
}

function Resolved( IpAddr Addr )
{
	// Set the address
	ServerIpAddr.Addr = Addr.Addr;

	// Handle failure.
	if( ServerIpAddr.Addr == 0 )
	{
		if(SystemPage != None)
		{
			SystemPage.SystemText( InvalidAddressText );
			CloseMe();
		}
		return;
	}

	// Display success message.
	Log( "UT2004 UT2K4IRCLink: Server is "$ServerAddress$":"$ServerIpAddr.Port,'IRC' );

	// Bind the local port.
	if( BindPort() == 0 )
	{
		if(SystemPage != None)
		{
			SystemPage.SystemText( ErrorBindingText );
			CloseMe();
		}
		return;
	}

	Open( ServerIpAddr );
}

event Closed()
{
	CloseMe();
}

// Host resolution failue.
function ResolveFailed()
{
	if(SystemPage != None)
	{
		SystemPage.SystemText(ResolveFailedText);
		CloseMe();
	}
}

event Timer()
{
	if(SystemPage != None)
	{
		SystemPage.SystemText( TimeOutError );
		CloseMe();

        log("Failed to resolve "$ServerAddress,'IRC');
	}
	return;
}

event Opened()
{
	SetTimer(0, False);
	if(SystemPage != None)
		SystemPage.SystemText(ConnectedText);
	Enable('Tick');
	GotoState('LoggingIn');
}

function Tick(float DeltaTime)
{
	local string Line;

	DoBufferQueueIO();
	if(ReadBufferedLine(Line))
		ProcessInput(Line);

    Super.Tick(DeltaTime);

	if( GetStateName() == 'LoggedIn' )
	{
		// Every 5 seconds, keep the IRC client away string up to date.
		SinceLastLevCheck += DeltaTime;
		if(SinceLastLevCheck > 5)
		{
			if(SystemPage != None)
				SystemPage.UpdateAway();

			SinceLastLevCheck = 0;
		}
	}
}

function SendCommandText(string Cmd)
{
	local int i;
	local string Text, Temp;

	// Add colons for commands: PRIVMSG, QUIT, KILL, KICK, NOTICE
	Divide(Cmd, " ", Cmd, Text);
	ReplaceCommandAlias(Cmd);

//	log("IRCLink::SendCommandText() Cmd:"$Cmd,'IRC');
//	log("IRCLink::SendCommandText() Text:"$Text, 'IRC');
	switch(Cmd)
	{

	// CMD nick :message
	case "PRIVMSG":
	case "NOTICE":
	case "KILL":

		if ( Text == "" )
			break;

		Text = ChopLeft(Text);

		if ( Divide(Text, " ", Temp, Text) )
		{
			Temp @= ":" $ ChopLeft(Text);
			Text = Temp;
		}

		break;

	// disable CTCP
	case "CTCP":
		break;

	// CMD #channel nick :message
	case "KICK":

		if ( Text == "" )
			break;

		Text = ChopLeft(Text);

		if ( Divide(Text, " ", Temp, Text) )
		{
			i = InStr(Text, " ");
			if (i != -1)
				Temp @= ":"$Text;	// adding reason for kick

			else if ( Text != "" )
				Temp @= Text;

			Text = Temp;
		}

		Text = SystemPage.GetCurrentChannelName() @ Text;	// adding channel name
		break;

	// CMD :message
	case "QUIT":
		if (Text != "")
			Text = " :"$ChopLeft(Text);
		break;

	case "JOIN":
		JoinChannel(Text);
		return;

	case "PART":
		if ( Text == "" )
			Text = SystemPage.GetCurrentChannelName();

		PartChannel(Text);
		return;
	}

	if ( Cmd != "" )
		SendBufferedData( Cmd $ Eval(Text != "", " " $ Text, "") $ CRLF );
}

function ReplaceCommandAlias(out string Text)
{
	local int i;

	for (i = 0; i < Shortcuts.Length; i++)
	{
		if (Shortcuts[i].AliasText ~= Text)
		{
			Text = Shortcuts[i].RealCommand;
			return;
		}
	}
}

function SendBufferedData(string Text)
{
	ReplaceText(Text, "$*", "");
	ReplaceText(Text, "#*", "");

//	log("IRCLink::SendingBufferedData >"$ Text );
	Super.SendBufferedData(Text);
}

function SendChannelText(string Channel, string Text)
{
	if ( Channel == "" )
		Channel = SystemPage.GetCurrentChannelName();

	SendBufferedData("PRIVMSG "$Channel$" :"$Text$CRLF);
}

function SendChannelAction(string Channel, string Text)
{
	if ( Channel == "" )
		Channel = SystemPage.GetCurrentChannelName();

	if (Left(Channel,1) != "#")
		Channel = "#" $ Channel;

	SendBufferedData("PRIVMSG "$Channel$" :"$Chr(1)$"ACTION "$Text$Chr(1)$CRLF);
}

function ProcessInput(string Line)
{
	// Respond to PING
	if(Left(Line, 5) == "PING ")
		SendBufferedData("PONG "$Mid(Line, 5)$CRLF);
}

state LoggingIn
{
	function Timer()
	{
		SendBufferedData("NICK "$NickName$CRLF);
		SetTimer(1, false);
	}

	function ProcessInput(string Line)
	{
		local string Temp;

        log("LoggingIn: "$Line,'IRC');

		Temp = ParseDelimited(Line, " ", 2);

		if(ParseDelimited(Line, " ", 1)== "ERROR")
			SystemPage.SystemText(ChopLeft(ParseDelimited(Line, ":", 2, True)));

		if( Temp == "433" )
		{
			// Nick in use
			SystemPage.SystemText(ChopLeft(ParseDelimited(Line, " ", 3, True)));
			SetTimer(0, false);

			SystemPage.NotifyNickInUse();
		}
		else
		if( Temp=="432" )
		{
			// Invalid nick
			SystemPage.SystemText(ChopLeft(ParseDelimited(Line, " ", 3, True)));
			SetTimer(0, false);

			SystemPage.NotifyInvalidNick();
		}
		else
		if( SystemPage.IsDigit(Temp) )
		{
			SystemPage.SystemText(ChopLeft(ParseDelimited(Line, " ", 3, True)));
			SetTimer(0, False);
			GotoState('LoggedIn');
		}

		Global.ProcessInput(Line);
	}

	function SendCommandText(string Text)
	{
		if(ParseDelimited(Text, " ", 1) ~= "NICK")
		{
			SystemPage.ChangedNick(NickName, Chop(ParseDelimited(Text, " ", 2)));
		}
		Global.SendCommandText(Text);
	}

Begin:
	if (SystemPage.Link != None && SystemPage.Link != Self)
	{
		SystemPage.CloseLink(SystemPage.Link, True);
		SystemPage.Link = Self;
	}

	else if (SystemPage.Link == None)
		SystemPage.Link = Self;

	SendBufferedData("USER "$UserIdent$" localhost "$ServerAddress$" :"$FullName$CRLF);
	SendBufferedData("NICK "$NickName$CRLF);
//	SetTimer(1, false);
}

state LoggedIn
{
	function ProcessInput(string Line)
	{
		local string Temp, Temp2, Temp3;
		local bool bAddModifier;
		local int i;
		local string Command;

		Global.ProcessInput(Line);

		if( SystemPage == None )
		    return;

//        log("LoggedIn::ProcessInput >"$Line,'IRC');

		Command = ParseDelimited(Line, " ", 2);

		if(ParseDelimited(Line, " ", 1) == "ERROR")
		{
			SystemPage.SystemText(ChopLeft(ParseDelimited(Line, ":", 2, True)));
		}

		switch ( Command )
		{
		case "JOIN":
			Temp = ParseDelimited(Line, ":!", 2);
			//Log("JOIN:"$Line$" Temp:"$Temp$" NickName:"$NickName);
			if(Temp ~= NickName)
				Temp = "";
			SystemPage.JoinedChannel(Chop(ParseDelimited(Line, " ", 3)), Temp);
			break;

		case "PART":
			Temp = ParseDelimited(Line, ":!", 2);
			if(Temp ~= NickName)
				Temp = "";
			SystemPage.PartedChannel(Chop(ParseDelimited(Line, " ", 3)), Temp);
			break;

		case "NICK":
			SystemPage.ChangedNick(ParseDelimited(Line, ":!", 2), Chop(ParseDelimited(Line, " ", 3)));
			break;

		case "QUIT":
			SystemPage.UserQuit(ParseDelimited(Line, ":!", 2), ChopLeft(ParseDelimited(Line, " ", 3, True)));
			break;

		case "353":	// NAMES
			Temp2 = ParseDelimited(Line, "#", 2);
			Temp2 = ParseDelimited(Temp2, " :", 1);

			Temp = ParseDelimited(Line, ":", 3, True);
			while(Temp != "")
			{
				// Nickname
				Temp3 = ParseDelimited(Temp, " ", 1);

				SystemPage.UserInChannel("#"$Temp2, RemoveNickPrefix(Temp3));

				if(Left(Temp3, 1) == "@")
					SystemPage.ChangeOp("#"$Temp2, RemoveNickPrefix(Temp3), True);
				else
				if(Left(Temp3, 1) == "%")
					SystemPage.ChangeHalfOp("#"$Temp2, RemoveNickPrefix(Temp3), True);
				else
				if(Left(Temp3, 1) == "+")
					SystemPage.ChangeVoice("#"$Temp2, RemoveNickPrefix(Temp3), True);

				Temp = ParseDelimited(Temp, " ", 2, True);
			}
			break;

		case "333":	// Channel formed info
		case "366":	// End of NAMES
		case "331":	// RPL_NOTOPIC
			break;

		case "332": // RPL_TOPIC
			Temp = Chop(ParseDelimited(Line, " ", 4));
			Temp2 = Chop(ParseDelimited(Line, " ", 5, True));

			SystemPage.ChangeTopic(Temp, Temp2);
			break;

		case "341":   // RPL_INVITING
			break;

		case "301":   // RPL_AWAY
			SystemPage.PrintAwayMessage(Chop(ParseDelimited(Line, " ", 4)), ChopLeft(ParseDelimited(Line, ":", 3, True)));
			break;

		case "NOTICE":
			Temp = ParseDelimited(Line, ": ", 2);
			Temp2 = ParseDelimited(Line, ":! ", 2);

			if(InStr(Temp, "!") != -1 && InStr(Temp2, ".") == -1)
			{
				// it's a Nick.
				Temp = ChopLeft(ParseDelimited(Line, " ", 4, True));
				if(Asc(Left(Temp, 1)) == 1 && Asc(Right(Temp, 1)) == 1)
					SystemPage.CTCP("", Temp2, Mid(Temp, 1, Len(Temp) - 2));
				else
					SystemPage.UserNotice(Temp2, Temp);
			}
			else
				SystemPage.SystemText(ChopLeft(ParseDelimited(Line, " ", 4, True)));

			break;

		case "MODE":
			// channel mode
			Temp = Chop(ParseDelimited(Line, " ", 4));
			// channel
			Temp3 = Chop(ParseDelimited(Line, " ", 3));
			i = 5;
			bAddModifier = True;
			while(Temp != "")
			{
				Temp2 = Left(Temp, 1);
				if(Temp2 == "+")
					bAddModifier = True;
				if(Temp2 == "-")
					bAddModifier = False;

				if(Temp2 == "o")
				{
					SystemPage.ChangeOp(Temp3, Chop(ParseDelimited(Line, " ", i)), bAddModifier);
					i++;
				}

				if(Temp2 == "h")
				{
					SystemPage.ChangeHalfOp(Temp3, Chop(ParseDelimited(Line, " ", i)), bAddModifier);
					i++;
				}

				if(Temp2 == "v")
				{
					SystemPage.ChangeVoice(Temp3, Chop(ParseDelimited(Line, " ", i)), bAddModifier);
					i++;
				}

				Temp = Mid(Temp, 1);
			}

			SystemPage.ChangeMode(Temp3, ParseDelimited(Line, ":!", 2), ChopLeft(ParseDelimited(Line, " ", 4, True)));

			break;

		case "KICK":
			// FIXME: handle multiple kicks in a single message
			SystemPage.KickUser(Chop(ParseDelimited(Line, " ", 3)), Chop(ParseDelimited(Line, " ", 4)), ParseDelimited(Line, ":!", 2), ChopLeft(ParseDelimited(Line, ":", 3, True)));
			break;

		case "INVITE":
			SystemPage.SystemText(ParseDelimited(Line, ":!", 2)@InviteString@ParseDelimited(Line, ":", 3));
			break;

		case "PRIVMSG":
			Temp = Chop(ParseDelimited(Line, " ", 3));
			Temp2 = ChopLeft(ParseDelimited(Line, " ", 4, True));

			if(Mid(Temp2, 1, 7) == "ACTION " && Asc(Left(Temp2, 1))==1 && Asc(Right(Temp2, 1))==1)
			{
				Temp2 = Mid(Temp2, 8);
				Temp2 = Left(Temp2, Len(Temp2) - 1);

				if(Temp != "" && InStr("&#@", Left(Temp, 1)) != -1)
					SystemPage.ChannelAction(Temp, ParseDelimited(Line, ":!", 2), Temp2);
				else
					SystemPage.PrivateAction(ParseDelimited(Line, ":!", 2), Temp2);
			}
			else
			if(Asc(Left(Temp2, 1))==1 && Asc(Right(Temp2, 1))==1)
			{
				Temp2 = Mid(Temp2, 1, Len(Temp2) - 2);

				switch(Temp2)
				{
				case "VERSION":
					SendBufferedData("NOTICE "$ParseDelimited(Line, ":!", 2)$" :"$Chr(1)$"VERSION "$VersionString$Level.EngineVersion$Chr(1)$CRLF);
					SystemPage.CTCP(Temp, ParseDelimited(Line, ":!", 2), Temp2);
					break;
				default:
					SystemPage.CTCP(Temp, ParseDelimited(Line, ":!", 2), Temp2);
					break;
				}
			}
			else
			{
				if(Temp != "" && InStr("&#@", Left(Temp, 1)) != -1)
					SystemPage.ChannelText(Temp, ParseDelimited(Line, ":!", 2), Temp2);
				else
					SystemPage.PrivateText(ParseDelimited(Line, ":!", 2), Temp2);
			}

			break;

		case "TOPIC":
			Temp = Chop(ParseDelimited(Line, " ", 3));
			Temp2 = ChopLeft(ParseDelimited(Line, " ", 4, True));

			SystemPage.ChangeTopic(Temp, Temp2);
			break;

		case "305":	// No longer away
		case "306": // Now marked as away
			break;


		case "475": // ERR_BADCHANNELKEY
			SystemPage.SystemText(ChopLeft(ParseDelimited(Line, " ", 4, True)));
   			SystemPage.NotifyChannelKey(Chop(ParseDelimited(ChopLeft(ParseDelimited(Line, " ", 4, True)), ":", 1)));
			break;

		default:
			if ( SystemPage.IsDigit(Command) )
				SystemPage.SystemText(ChopLeft(ParseDelimited(Line, " ", 4, True)));

			break;
		}
	}

Begin:
	if(DefaultChannel != "")
		JoinChannel(DefaultChannel);
}

function JoinChannel(string Channel)
{
    log("UT2K4IRCLink: JoinChannel: "$Channel,'IRC');
	if ( Channel == "" )
		Channel = SystemPage.GetCurrentChannelName();

	if(Left(Channel, 1) != "#")
		Channel = "#" $ Channel;

	SendBufferedData("JOIN "$Channel$CRLF);
}

function PartChannel(string Channel)
{
	if ( Channel == "" )
		Channel = SystemPage.GetCurrentChannelName();

	if(Left(Channel, 1) != "#")
		Channel = "#" $ Channel;

	SendBufferedData("PART "$Channel$CRLF);
}

function SetNick(string NewNick)
{
	if ( NewNick == "" )
		return;

	if ( NewNick ~= "chanserv" )
		return;

	if ( NewNick ~= "q" )
		return;

	if ( NewNick ~= "nickserv" )
		return;

	SendCommandText("NICK "$NewNick);
}

function SetAway(string AwayText)
{
	SendBufferedData("AWAY :"$AwayText$CRLF);
}

function DestroyLink()
{
	SystemPage = None;
	SetTimer(0.0,False);

	if(IsConnected())
	{
		SendText("QUIT :"$DisconnectReason$CRLF);
		Close();
	}
	else
		Destroy();
}

defaultproperties
{
     InvalidAddressText="Invalid server address, aborting."
     ErrorBindingText="Error binding local port, aborting."
     ResolveFailedText="Failed to resolve server address, aborting."
     ConnectedText="Connected."
     ConnectingToText="Connecting to"
     TimeOutError="Timeout connecting to server."
     InviteString="invites you to join"
     DisconnectReason="Disconnected"
     VersionString="UT2004 IRC Client version "
     Shortcuts(0)=(AliasText="MSG",RealCommand="PRIVMSG")
     Shortcuts(1)=(AliasText="LEAVE",RealCommand="PART")
     Shortcuts(2)=(AliasText="J",RealCommand="JOIN")
     Shortcuts(3)=(AliasText="P",RealCommand="PART")
     Shortcuts(4)=(AliasText="N",RealCommand="NICK")
}
