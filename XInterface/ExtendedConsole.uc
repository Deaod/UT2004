// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class ExtendedConsole extends Console;

#exec OBJ LOAD FILE=MenuSounds.uax
#exec OBJ LOAD FILE=InterfaceContent.utx

// Visible Console stuff
var globalconfig int MaxScrollbackSize;

var array<string> Scrollback;
var int SBHead, SBPos;	// Where in the scrollback buffer are we
var bool bCtrl, bAlt, bShift;
var bool bConsoleHotKey;

var float   ConsoleSoundVol;

var localized string AddedCurrentHead;
var localized string AddedCurrentTail;

var localized string ServerFullMsg;

////// Speech Menu
var float SMLineSpace;

var enum ESpeechMenuState
{
	SMS_Main,
	SMS_VoiceChat,			// List of voice chat groups on the server
	SMS_Ack,
	SMS_FriendFire,
	SMS_Order,
	SMS_Other,
	SMS_Taunt,
	SMS_TauntAnim,
	SMS_PlayerSelect,
	SMS_VoiceChatChannel	// List of options for this channel (public & private)
} SMState;

// These are put together using the menu and sent to the 'Speech' exec command.
var name SMType;
var int  SMIndex;
var string SMCallsign;

var int SMOffset;

var string	SMNameArray[48];
var int		SMIndexArray[48];
var int		SMArraySize;

var config float SMOriginX;
var config float SMOriginY;
var float SMMargin, SMTab;

var localized 	string  SMStateName[10];
var localized 	string  SMChannelOptions[3];
var				array<VoiceChatRoom> VoiceChannels;
var localized 	string  SMAllString;
var localized 	string  SMMoreString;

var sound	SMOpenSound;
var sound   SMAcceptSound;
var sound   SMDenySound;

var config EInputKey	LetterKeys[10];
var        EInputKey	NumberKeys[10];

var config bool bSpeechMenuUseLetters;
var config bool bSpeechMenuUseMouseWheel;
var bool		bSpeechMenuLocked;

var int HighlightRow;

////// End Speech Menu

struct StoredPassword
{
	var config string	Server,
						Password;
};

struct ServerFavorite
{
	var() config int ServerID;
	var() config string IP;
	var() config int Port;
	var() config int QueryPort;
	var() config string ServerName;
};

var() protected config array<ServerFavorite> Favorites;

var config array<StoredPassword>	SavedPasswords;
var config string					PasswordPromptMenu;
var string							LastConnectedServer,
									LastURL;

struct ChatStruct
{
	var string	Message;
    var int		team;
};

var array<ChatStruct> ChatMessages;
var config string ChatMenuClass;
var transient GUIPage ChatMenu;
var bool bTeamChatOnly;

var transient UT2MusicManager MusicManager;				// Obsolete
var config string StatsPromptMenuClass;		// Menu that appears when connecting to a stats enabled server
var config string MusicManagerClassName;
var config string WaitingGameClassName;
var config string NeedPasswordMenuClass;	// Menu that appears when connecting to a passworded server
var config string ServerInfoMenu;			// Menu that appears when press F2

var float FadeClock;
var float FadeTime;
var array<float> DemoPlaybackSpeeds;
var string PlaybackText;

var config bool bDemoJogKeys;

delegate OnChat(string Msg, int TeamIndex);

function OnStatsClosed(optional bool bCancelled)
{
	if ( bCancelled )
		return;

	OnStatsConfigured();
}

function OnStatsConfigured()
{
//	DelayedConsoleCommand("reconnect");
	ViewportOwner.GUIController.CloseAll(false);
	ViewportOwner.Actor.ClientTravel(LastURL,TRAVEL_Absolute,false);
}

event ConnectFailure(string FailCode,string URL)
{
	local string			Error, Server;
	local int				i,Index;

	LastURL = URL;
	Server = Left(URL,InStr(URL,"/"));

	i = instr(FailCode," ");
	if (i>0)
	{
		Error = Right(FailCode,len(FailCode)-i-1);
		FailCode = Left(FailCode,i);
	}

	log("Connect Failure: "@FailCode$"["$Error$"] ("$URL$")",'Debug');

	if(FailCode == "NEEDPW")
	{
		for(Index = 0;Index < SavedPasswords.Length;Index++)
		{
			if(SavedPasswords[Index].Server == Server)
			{
				ViewportOwner.Actor.ClearProgressMessages();
				ViewportOwner.Actor.ClientTravel(URL$"?password="$SavedPasswords[Index].Password,TRAVEL_Absolute,false);
				return;
			}
		}

		LastConnectedServer = Server;
		if ( ViewportOwner.GUIController.OpenMenu(NeedPasswordMenuClass, URL, FailCode) )
			return;
	}
	else if(FailCode == "WRONGPW")
	{
		ViewportOwner.Actor.ClearProgressMessages();

		for(Index = 0;Index < SavedPasswords.Length;Index++)
		{
			if(SavedPasswords[Index].Server == Server)
			{
				SavedPasswords.Remove(Index,1);
				SaveConfig();
			}
		}

		LastConnectedServer = Server;
		if ( ViewportOwner.GUIController.OpenMenu(NeedPasswordMenuClass, URL, FailCode) )
			return;
	}
	else if(FailCode == "NEEDSTATS")
	{
		ViewportOwner.Actor.ClearProgressMessages();
		if ( ViewportOwner.GUIController.OpenMenu(StatsPromptMenuClass, "", FailCode) )
		{
			GUIController(ViewportOwner.GUIController).ActivePage.OnReopen = OnStatsConfigured;
			return;
		}
	}
	else if ( FailCode == "LOCALBAN" )
	{
		ViewportOwner.Actor.ClearProgressMessages();
		ViewportOwner.GUIController.OpenMenu(class'GameEngine'.default.DisconnectMenuClass,Localize("Errors","ConnectionFailed","Engine"),class'AccessControl'.default.IPBanned);
		return;
	}

	else if ( FailCode == "SESSIONBAN" )
	{
		ViewportOwner.Actor.ClearProgressMessages();
		ViewportOwner.GUIController.OpenMenu(class'GameEngine'.default.DisconnectMenuClass,Localize("Errors","ConnectionFailed","Engine"),class'AccessControl'.default.SessionBanned);
		return;
	}

	else if ( FailCode == "SERVERFULL" )
	{
		ViewportOwner.Actor.ClearProgressMessages();
		ViewportOwner.GUIController.OpenMenu(class'GameEngine'.default.DisconnectMenuClass,ServerFullMsg);
		return;
	}

	else if ( FailCode == "CHALLENGE" )
	{
		ViewportOwner.Actor.ClearProgressMessages();
		ViewportOwner.Actor.ClientNetworkMessage("FC_Challege","");
		return;
	}

	log("Unhandled connection failure!  FailCode '"$FailCode@"'   URL '"$URL$"'");
	ViewportOwner.Actor.ProgressCommand("menu:"$class'GameEngine'.default.DisconnectMenuClass,FailCode,Error);
}


event NotifyLevelChange()
{
	Super.NotifyLevelChange();
	if ( VoiceChannels.Length > 0 )
		VoiceChannels.Remove(0, VoiceChannels.Length);

}


////// End Speech Menu

exec function CLS()
{
	SBHead = 0;
	ScrollBack.Remove(0,ScrollBack.Length);
}

function PostRender( canvas Canvas )
{
	local float Delta,ox,oy,xl,yl;
	local font oFont;
	local color oColor;
	local float alpha;
	local float afade;


	Delta = ViewportOwner.Actor.Level.TimeSeconds - FadeClock;
	FadeClock = ViewportOwner.Actor.Level.TimeSeconds;

	FadeTime -= Delta;
	if (FadeTime>=0)
	{
		ox = Canvas.CurX;
		oy = Canvas.CurY;
		oFont = Canvas.Font;
		oColor = Canvas.DrawColor;

		Canvas.Font = class'HudBase'.static.GetMediumFontFor(Canvas);

		Alpha = 255;

		aFade = FadeTime / (1.0*ViewportOwner.Actor.Level.TimeDilation);
		if (aFade<0.5)
			Alpha *= (aFade*2);

		Canvas.SetDrawColor(64,255,64,Alpha);
		Canvas.Strlen(PlaybackText,xl,yl);
		Canvas.SetPos(5,Canvas.ClipY-yl*2.5);
		Canvas.DrawText(PlaybackText,false);

		Canvas.CurX = ox;
		Canvas.CurY = oy;
		Canvas.Font = oFont;
		Canvas.DrawColor = oColor;

	}
	else
	{
		FadeTime = 0;
		bVisible=false;
	}
}

function Chat(coerce string Msg, float MsgLife, PlayerReplicationInfo PRI)
{
	local int index;

	Message(Msg,MsgLife);		// For compatibility

    Index = ChatMessages.Length;
	ChatMessages.Length = Index+1;
    ChatMessages[Index].Message = Msg;

    if ( (PRI != None) && (PRI.Team!=None) )
	    ChatMessages[Index].Team = PRI.Team.TeamIndex;
    else
    	ChatMessages[Index].Team = 2;

	if ( (!bTeamChatOnly) || (PRI == None) || (PRI.Team==None) || (PRI.Team == ViewportOwner.Actor.PlayerReplicationInfo.Team) )
	{
		OnChat(Msg, ChatMessages[Index].team);
		OnChatMessage(Msg);
	}

	if (ChatMessages.Length>100)
    	ChatMessages.Remove(0,1);
}

delegate OnChatMessage(string Msg);

event Message( coerce string Msg, float MsgLife)
{
	if (ScrollBack.Length==MaxScrollBackSize)	// if full, Remove Entry 0
	{
		ScrollBack.Remove(0,1);
		SBHead = MaxScrollBackSize-1;
	}
	else
		SBHead++;

	ScrollBack.Length = ScrollBack.Length + 1;

	Scrollback[SBHead] = Msg;
	Super.Message(Msg,MsgLife);
}

function GetNewPlaybackSpeed(int dir)
{
	local float dist, gs;
	local int i,best;


	GS = ViewportOwner.Actor.Level.TimeDilation;
	dist=30000;
	for (i=0;i<DemoPlaybackSpeeds.Length;i++)
		if (abs(GS-DemoPlaybackSpeeds[i])<dist)
		{
			dist = GS-DemoPlaybackSpeeds[i];
			best = i;
		}

	i = clamp(best+dir,0,DemoPlaybackSpeeds.Length-1);
	ViewportOwner.Actor.Level.TimeDilation	= DemoPlaybackSpeeds[i];

	if (ViewportOwner.Actor.Level.TimeDilation>=1.1)
		PlaybackText=""@int(ViewportOwner.Actor.Level.TimeDilation)$"x";

	else
	{
		GS = 100 / (ViewportOwner.Actor.Level.TimeDilation * 100);
		PlaybackText="1/"$int(GS)$"x";
	}

	FadeTime = 1.0 * ViewportOwner.Actor.Level.Timedilation;
	bVisible=true;
	FadeClock = ViewportOwner.Actor.Level.TimeSeconds;

}



event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{

	if (Key==ConsoleHotKey)
	{
		if(Action==IST_Release)
			ConsoleOpen();
		return true;
	}

	if (ViewportOwner.Actor.bDemoOwner)
	{
		if (Action == IST_Release)
		{
			if (Key==37)
				GetNewPlaybackSpeed(-1);
			else if (Key==39)
				GetNewPlaybackSpeed(+1);
			else if (Key==38 || key==40)
			{
				ViewportOwner.Actor.Level.TimeDilation	= 1.1;
				PlaybackText="1x";
				bVisible=true;
				FadeTime=1.0;
				FadeClock = ViewportOwner.Actor.Level.TimeSeconds;
			}
		}
	}

    return Super.KeyEvent(Key,Action,Delta);
}


function PlayConsoleSound(Sound S)
{
	if(ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.Pawn == None)
		return;

	ViewportOwner.Actor.ClientPlaySound(S);//,true,ConsoleSoundVol);
}

//-----------------------------------------------------------------------------
// State used while typing a command on the console.

event NativeConsoleOpen()
{
	ConsoleOpen();
}

exec function ConsoleOpen()
{
	UnPressButtons();
	TypedStr = "";
	TypedStrPos = 0;
	bCtrl = False;
	bAlt = False;
	bShift = False;

	GotoState('ConsoleVisible');
	PlayConsoleSound(SMOpenSound);
}

exec function ConsoleClose()
{
	TypedStr="";
	TypedStrPos = 0;

	bCtrl = False;
	bAlt = False;
	bShift = False;

    if( GetStateName() == 'ConsoleVisible' )
	{
		PlayConsoleSound(SMDenySound);
        GotoState( '' );
	}
}

exec function ConsoleToggle()
{
	log("console toggle");
	UnPressButtons();

    if( GetStateName() == 'ConsoleVisible' )
        ConsoleClose();
    else
        ConsoleOpen();
}



state ConsoleVisible
{
	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		local PlayerController PC;

		if (bIgnoreKeys || bConsoleHotKey)
			return true;

		if (ViewportOwner != none)
			PC = ViewportOwner.Actor;

		if (bCtrl && PC != none)
		{
			if (Key == 3) //copy
			{
				PC.CopyToClipboard(TypedStr);
				return true;
			}
			else if (Key == 22) //paste
			{
				TypedStr $= PC.PasteFromClipboard();
				TypedStrPos += Len(PC.PasteFromClipboard());
				return true;
			}
			else if (Key == 24) // cut
			{
				PC.CopyToClipboard(TypedStr);
				TypedStr="";
				TypedStrPos = 0;
				return true;
			}
		}

		if( Key>=0x20 )
		{
			if( Unicode != "" )
				TypedStr = Left(TypedStr, TypedStrPos) $ Unicode $ Right(TypedStr, Len(TypedStr) - TypedStrPos);
			else
				TypedStr = Left(TypedStr, TypedStrPos) $ Chr(Key) $ Right(TypedStr, Len(TypedStr) - TypedStrPos);
			TypedStrPos++;
            return( true );
		}

		return( true );
	}

	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string Temp;
		local int i;

		if ( Action == IST_Release )
		{
			if ( Key == ConsoleHotKey )
			{
				if ( bConsoleHotKey ) ConsoleClose();
				return True;
			}

			switch ( Key )
			{
			case IK_Ctrl:
				bCtrl = False;
				break;

			case IK_Alt:
				bAlt = False;
				break;

			case IK_Shift:
				bShift = False;
				break;

			case IK_Escape:
				if ( TypedStr != "" )
				{
					TypedStr = "";
					TypedStrPos = 0;
					HistoryCur = HistoryTop;
				}

				else ConsoleClose();
				return True;

			default:
				return True;
			}
		}

		else if ( Action == IST_Press )
		{
			bIgnoreKeys = False;

			if ( Key == ConsoleHotKey )
			{
				bConsoleHotKey = True;
				return True;
			}

			switch ( Key )
			{
			case IK_Ctrl:
				bCtrl = True;
				break;

			case IK_Alt:
				bAlt = True;
				break;

			case IK_Shift:
				bShift = True;
				break;

			case IK_Escape:
				return True;

			case IK_Enter:
				if( TypedStr!="" )
				{
					// Print to console.

					History[HistoryTop] = TypedStr;
	                HistoryTop = (HistoryTop+1) % ArrayCount(History);

					if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
	                    HistoryBot = (HistoryBot+1) % ArrayCount(History);

					HistoryCur = HistoryTop;

					// Make a local copy of the string.
					Temp=TypedStr;
					TypedStr="";
					TypedStrPos=0;

					if( !ConsoleCommand( Temp ) )
						Message( Localize("Errors","Exec","Core"), 6.0 );

					Message( "", 6.0 );
				}

	            return true;

	        case IK_Up:
				if ( HistoryBot >= 0 )
				{
					if (HistoryCur == HistoryBot)
						HistoryCur = HistoryTop;
					else
					{
						HistoryCur--;
						if (HistoryCur<0)
	                        HistoryCur = ArrayCount(History)-1;
					}

					TypedStr = History[HistoryCur];
					TypedStrPos = Len(TypedStr);
				}
	            return true;

	        case IK_Down:
				if ( HistoryBot >= 0 )
				{
					if (HistoryCur == HistoryTop)
						HistoryCur = HistoryBot;
					else
	                    HistoryCur = (HistoryCur+1) % ArrayCount(History);

					TypedStr = History[HistoryCur];
					TypedStrPos = Len(TypedStr);
				}

				return True;

			case IK_Backspace:
				if( TypedStrPos > 0 )
				{
					TypedStr = Left(TypedStr,TypedStrPos-1)$Right(TypedStr, Len(TypedStr) - TypedStrPos);
					TypedStrPos--;
				}

           		return true;

           	case IK_Delete:
				if ( TypedStrPos < Len(TypedStr) )
					TypedStr = Left(TypedStr,TypedStrPos)$Right(TypedStr, Len(TypedStr) - TypedStrPos - 1);
				return true;

			case IK_Left:
				i = TypedStrPos - 1;

				if ( bCtrl )
					while ( i > 0 && Mid(TypedStrPos,i,1) != " " )
						i--;

				TypedStrPos = Max(0, i);
				return true;

			case IK_Right:
				i = TypedStrPos + 1;

				if ( bCtrl )
					while ( i <= Len(TypedStr) && Mid(TypedStr,i,1) != " " )
						i++;


				TypedStrPos = Min(Len(TypedStr), i);
				return true;

			case IK_Home:
				TypedStrPos = 0;
				return true;

			case IK_End:
				TypedStrPos = Len(TypedStr);
				return true;

			case IK_PageUp:
			case IK_MouseWheelUp:
				if (SBPos<ScrollBack.Length-1)
				{
					if (bCtrl)
						SBPos+=5;
					else
						SBPos++;

					if (SBPos>=ScrollBack.Length)
					  SBPos = ScrollBack.Length-1;
				}

				return true;

			case IK_PageDown:
			case IK_MouseWheelDown:
				if (SBPos>0)
				{
					if (bCtrl)
						SBPos-=5;
					else
						SBPos--;

					if (SBPos<0)
						SBPos = 0;
				}
			}
		}

		return True;
	}

    function BeginState()
	{
		SBPos = 0;
        bVisible= true;
		bIgnoreKeys = true;
		bConsoleHotKey = false;
        HistoryCur = HistoryTop;
		bCtrl = false;
    }
    function EndState()
    {
        bVisible = false;
		bCtrl = false;
		bConsoleHotKey = false;
    }

	function PostRender( canvas Canvas )
	{

		local float fw,fh;
		local float yclip,y;
		local int idx;

		Canvas.Font = class'HudBase'.static.GetConsoleFont(Canvas);
		yclip = canvas.ClipY*0.5;
		Canvas.StrLen("X",fw,fh);

		Canvas.SetPos(0,0);
		Canvas.SetDrawColor(255,255,255,200);
		Canvas.Style=4;
		Canvas.DrawTileStretched(material'ConsoleBack',Canvas.ClipX,yClip);
		Canvas.Style=1;

		Canvas.SetPos(0,yclip-1);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawTile(texture 'InterfaceContent.Menu.BorderBoxA',Canvas.ClipX,2,0,0,64,2);

		Canvas.SetDrawColor(255,255,255,255);

		Canvas.SetPos(0,yclip-5-fh);
		Canvas.DrawTextClipped("(>"@Left(TypedStr, TypedStrPos)$chr(4)$Eval( TypedStrPos < Len(TypedStr), Mid(TypedStr, TypedStrPos), "_"), true);

		idx = SBHead - SBPos;
		y = yClip-y-5-(fh*2);

		if (ScrollBack.Length==0)
			return;

		Canvas.SetDrawColor(255,255,255,255);
		while (y>fh && idx>=0)
		{
			Canvas.SetPos(0,y);
			Canvas.DrawText(Scrollback[idx],false);
			idx--;
			y-=fh;
		}
	}
}

//---------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------------------------------//

delegate OnExecAddFavorite( ServerFavorite Fav );
exec function AddCurrentToFavorites()
{
	local string address, ipString, portString;
	local int colonPos, portNum;
	local ServerFavorite NewFav;

	if( ViewportOwner == None || ViewportOwner.Actor == None )
		return;

	// Get current network address
	address = ViewportOwner.Actor.GetServerNetworkAddress();

	if(address == "")
		return;

	// Parse text to find IP and possibly port number
	colonPos = InStr(address, ":");
	if(colonPos < 0)
	{
		// No colon - assume port 7777
		ipString = address;
		portNum = 7777;
	}
	else
	{	// Parse out port number
		ipString = Left(address, colonPos);
		portString = Mid(address, colonPos+1);
		portNum = int(portString);
	}

	NewFav.IP = ipString;
	NewFav.Port = portNum;
	NewFav.QueryPort = portNum + 1;

	if ( AddFavorite( NewFav ) )
		ViewportOwner.Actor.ClientMessage(AddedCurrentHead@address@AddedCurrentTail);

	OnExecAddFavorite( NewFav );
}

static function bool InFavorites( ServerFavorite Fav )
{
	local int i;

	if ( Fav.IP == "" )
		return false;

	if ( Fav.Port == 0 )
		Fav.Port = 7777;

	if ( Fav.QueryPort == 0 )
		Fav.QueryPort = Fav.Port + 1;

	for ( i = 0; i < default.Favorites.Length; i++ )
	{
		if ( Fav.IP == default.Favorites[i].IP &&
		     Fav.Port == default.Favorites[i].Port &&
		     Fav.QueryPort == default.Favorites[i].QueryPort )
	    return true;
	}

	return false;
}

// Returns true only if this was a new server
static function bool AddFavorite( ServerFavorite NewFav )
{
	local int i;
	local bool bNew;

	if ( NewFav.IP == "" )
		return false;

	if ( NewFav.Port == 0 )
		NewFav.Port = 7777;

	if ( NewFav.QueryPort == 0 )
		NewFav.QueryPort = NewFav.Port + 1;

	bNew = True;
	for ( i = 0; i < default.Favorites.Length; i++ )
	{
		if ( NewFav.IP == default.Favorites[i].IP &&
		     NewFav.Port == default.Favorites[i].Port &&
		     NewFav.QueryPort == default.Favorites[i].QueryPort )
		{
			if ( NewFav.ServerName ~= default.Favorites[i].ServerName )
				return false;

			bNew = False;
			break;
		}
	}

	default.Favorites[i] = NewFav;
	StaticSaveConfig();
	return bNew;
}

static function bool RemoveFavorite( string IP, int Port, int QueryPort )
{
	local int i;

	for ( i = 0; i < default.Favorites.Length; i++ )
	{
		if ( default.Favorites[i].IP == IP && default.Favorites[i].Port == Port && default.Favorites[i].QueryPort == QueryPort )
		{
			default.Favorites.Remove(i,1);
			StaticSaveConfig();
			return true;
		}
	}

	return false;
}

static function GetFavorites( out array<ServerFavorite> List )
{
	List = default.Favorites;
}

static function SaveFavorites()
{
	// TODO: Add bDirty tracking, to only save if favorites have actually been modified

	StaticSaveConfig();
}

//---------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------------------------------//

exec function SpeechMenuToggle()
{
	// Don't show speech menu if no voice pack type
    if( ViewportOwner.Actor.PlayerReplicationInfo.bOnlySpectator || (ViewportOwner.Actor.PlayerReplicationInfo.VoiceType == None) )
		return;

	GotoState('SpeechMenuVisible');
}

state SpeechMenuVisible
{
	exec function SpeechMenuToggle()
	{
		GotoState('');
	}

	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		if (bIgnoreKeys)
			return true;

		return false;
	}

	function class<TeamVoicePack> GetVoiceClass()
	{
		if(ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.PlayerReplicationInfo == None)
			return None;

		return class<TeamVoicePack>(ViewportOwner.Actor.PlayerReplicationInfo.VoiceType);
	}

	// JTODO: Bubble sort. Sorry. But I already wrote the GUIList sort today and its late.
	function SortSMArray()
	{
		local int i,j, tmpInt;
		local string tmpString;

		for(i=0; i<SMArraySize-1; i++)
		{
			for(j=i+1; j<SMArraySize; j++)
			{
				if(SMNameArray[i] > SMNameArray[j])
				{
					tmpString = SMNameArray[i];
					SMNameArray[i] = SMNameArray[j];
					SMNameArray[j] = tmpString;

					tmpInt = SMIndexArray[i];
					SMIndexArray[i] = SMIndexArray[j];
					SMIndexArray[j] = tmpInt;
				}
			}
		}
	}

	// Rebuild the array of options based on the state we are now in.
	function RebuildSMArray()
	{
		local int i, index;
		local class<TeamVoicePack> tvp;
		local GameReplicationInfo GRI;
		local PlayerReplicationInfo MyPRI;
		local VoiceChatReplicationInfo VRI;
		local UnrealPlayer up;
		local name GameMesgGroup;
		local Pawn TauntPawn;
		local bool bShowJoin, bShowLeave, bShowTalk;

		SMArraySize = 0;
		SMOffset=0;

		tvp = GetVoiceClass();
		if(tvp == None)
			return;

		//Log("TVP:"$tvp$" NumTaunts:"$tvp.Default.numTaunts);
		switch (SMState)
		{
		case SMS_Main:
			if ( VoiceChatAllowed() )
			{
				SMNameArray[SMArraySize] = SMStateName[1];
				SMIndexArray[SMArraySize] = 1;
				SMArraySize++;
			}

			if ( ViewportOwner.Actor.PlayerReplicationInfo != None && !ViewportOwner.Actor.PlayerReplicationInfo.bOnlySpectator )
			{
				for(i=2; i<7; i++)
				{
					SMNameArray[SMArraySize] = SMStateName[i];
					SMIndexArray[SMArraySize] = i;
					SMArraySize++;
				}
				if ( (ViewportOwner.Actor.Pawn != None) && !ViewportOwner.Actor.Pawn.IsA('RedeemerWarhead') )
				{
					SMNameArray[SMArraySize] = SMStateName[7];
					SMIndexArray[SMArraySize] = 7;
					SMArraySize++;
				}
			}

			if ( SMArraySize == 0 )
				GotoState('');

			break;

		case SMS_Taunt:
			for(i=0; i<tvp.Default.numTaunts; i++)
			{
				if(tvp.Default.MatureTaunt[i] == 1 && ViewportOwner.Actor.bNoMatureLanguage)
					continue;

				if(tvp.Default.TauntAbbrev[i] != "")
					SMNameArray[SMArraySize] = tvp.Default.TauntAbbrev[i];
				else
					SMNameArray[SMArraySize] = tvp.Default.TauntString[i];

				SMIndexArray[SMArraySize] = i;
				SMArraySize++;
			}

			SortSMArray();
			break;

		case SMS_Ack:
			for(i=0; i<tvp.Default.numAcks; i++)
			{

            	if (tvp.Default.AckAbbrev[i] != "")
					SMNameArray[SMArraySize] = tvp.Default.AckAbbrev[i];
                else
					SMNameArray[SMArraySize] = tvp.Default.AckString[i];
				SMIndexArray[SMArraySize] = i;
				SMArraySize++;
			}

			SortSMArray();
			break;

		case SMS_FriendFire:
			for(i=0; i<tvp.Default.numFFires; i++)
			{
				if(tvp.Default.FFireAbbrev[i] != "")
					SMNameArray[SMArraySize] = tvp.Default.FFireAbbrev[i];
				else
					SMNameArray[SMArraySize] = tvp.Default.FFireString[i];

				SMIndexArray[SMArraySize] = i;
				SMArraySize++;
			}

			SortSMArray();
			break;

		case SMS_Order:
			for(i=0; i<9; i++)
			{
				if(tvp.Default.OrderSound[i] == None)
					continue;

				index = tvp.static.OrderToIndex(i, ViewportOwner.Actor.Level.GetGameClass());

				if(tvp.Default.OrderAbbrev[index] != "")
					SMNameArray[SMArraySize] = tvp.Default.OrderAbbrev[index];
				else
					SMNameArray[SMArraySize] = tvp.Default.OrderString[index];

				SMIndexArray[SMArraySize] = index;
				SMArraySize++;
			}

			break;

		case SMS_Other:
			GameMesgGroup = ViewportOwner.Actor.Level.GetGameClass().Default.OtherMesgGroup;

			for(i=0; i<ArrayCount(tvp.Default.OtherString); i++)
			{
				if(tvp.Default.OtherSound[i] == None)
					continue;

				// If we have defined a group for this message, only put it in the menu if it matches the current game group.
				if(tvp.Default.OtherMesgGroup[i] != ''  && tvp.Default.OtherMesgGroup[i] != GameMesgGroup)
						continue;

				if(tvp.Default.OtherAbbrev[i] != "")
					SMNameArray[SMArraySize] = tvp.Default.OtherAbbrev[i];
				else
					SMNameArray[SMArraySize] = tvp.Default.OtherString[i];

				SMIndexArray[SMArraySize] = i;
				SMArraySize++;
			}
			break;

		case SMS_PlayerSelect:
			if(ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.PlayerReplicationInfo == None)
				return;

			GRI = ViewportOwner.Actor.GameReplicationInfo;
			MyPRI = ViewportOwner.Actor.PlayerReplicationInfo;

			// First entry is to send to 'all'
			// HACK: Don't let you send 'Hold This Position' to all all bots
			if( SMIndex != 1)
			{
				SMNameArray[SMArraySize] = SMAllString;
				SMArraySize++;
			}

			for(i=0; i<GRI.PRIArray.Length; i++)
			{
				if ( GRI.bTeamGame )
				{
					// Dont put player on list if myself, not on a team, on the same team, or a spectator.
					if( GRI.PRIArray[i].Team == None || MyPRI.Team == None )
						continue;

					if( GRI.PRIArray[i].Team.TeamIndex != MyPRI.Team.TeamIndex )
						continue;
				}

				if( GRI.PRIArray[i].TeamId == MyPRI.TeamId )
					continue;

				if( GRI.PRIArray[i].bOnlySpectator )
					continue;

				SMNameArray[SMArraySize] = GRI.PRIArray[i].PlayerName;
				SMArraySize++;
				// Dont need a number- we use the name direct
			}

			break;

		case SMS_TauntAnim:
			if(ViewportOwner == None || ViewportOwner.Actor == None)
				return;

			up = UnrealPlayer(ViewportOwner.Actor);
			if(up == None || up.Pawn == None)
				return;

			if ( Vehicle(up.Pawn) != None )
				TauntPawn = Vehicle(up.Pawn).Driver;
			else
				TauntPawn = up.Pawn;

			for(i=0; i<TauntPawn.TauntAnims.Length; i++)
			{
				SMNameArray[SMArraySize] = TauntPawn.TauntAnimNames[Clamp(i,0,15)];  // clamped because taunt array is max 8, see Pawn.uc
				SMIndexArray[SMArraySize] = i;
				SMArraySize++;
			}

			SortSMArray();
			break;

		case SMS_VoiceChat:
			if(	ViewportOwner == None || ViewportOwner.Actor == None ||
				ViewportOwner.Actor.PlayerReplicationInfo == None || ViewportOwner.Actor.VoiceReplicationInfo == None)
			{
				log("VoiceChatChannel not displaying.  ViewportOwner:"$ViewportOwner@"Actor:"$ViewportOwner.Actor@"MyPRI:"$ViewportOwner.Actor.PlayerReplicationInfo@"VRI:"$ViewportOwner.Actor.VoiceReplicationInfo,'VoiceChat');
				return;
			}

			VRI = ViewportOwner.Actor.VoiceReplicationInfo;
			MyPRI = ViewportOwner.Actor.PlayerReplicationInfo;

			VoiceChannels = VRI.GetChannels();
			for ( i = 0; i < VoiceChannels.Length; i++ )
			{
				if ( VoiceChannels[i].CanJoinChannel(MyPRI) )
				{
					bShowTalk = True;
					if ( VoiceChannels[i].IsMember(MyPRI, True) )
						bShowLeave = True;
					else bShowJoin = True;
				}
			}

			// Only display talk option if there are any channels that we can talk in.
			if ( bShowTalk )
			{
				// Store the currently selected channel name
				SMNameArray[SMArraySize] = SMChannelOptions[2]; // Talk
				SMIndexArray[SMArraySize] = 2;
				SMArraySize++;
			}

			// Only display join option if there are any channels that we can join
			if ( bShowJoin )
			{
				SMNameArray[SMArraySize] = SMChannelOptions[0];	// Join
				SMIndexArray[SMArraySize] = 0;
				SMArraySize++;
			}

			// Only display leave option if we are a member of any channels
			if ( bShowLeave )
			{
				SMNameArray[SMArraySize] = SMChannelOptions[1];	// Leave
				SMIndexArray[SMArraySize] = 1;
				SMArraySize++;
			}

			break;

		case SMS_VoiceChatChannel:
			if(	ViewportOwner == None || ViewportOwner.Actor == None ||
				ViewportOwner.Actor.VoiceReplicationInfo == None)
			{
				log(Name@"No VoiceReplicationInfo so not generating VoiceChat menu",'VoiceChat');
				return;
			}

			VRI = ViewportOwner.Actor.VoiceReplicationInfo;
			MyPRI = ViewportOwner.Actor.PlayerReplicationInfo;
			SMStateName[ESpeechMenuState.EnumCount - 1] = SMChannelOptions[SMIndex];

			switch ( SMIndex )
			{
			case 0:    // Join
				VoiceChannels = VRI.GetChannels();
				for ( i = 0; i < VoiceChannels.Length; i++ )
				{
					if ( VoiceChannels[i].CanJoinChannel(MyPRI) && !VoiceChannels[i].IsMember(MyPRI, True) )
					{
						SMNameArray[SMArraySize] = VoiceChannels[i].GetTitle();
						SMIndexArray[SMArraySize] = VoiceChannels[i].ChannelIndex;
						SMArraySize++;
					}
				}
				break;

			case 1:    // Leave
				VoiceChannels = VRI.GetChannels();
				for ( i = 0; i < VoiceChannels.Length; i++ )
				{
					if ( VoiceChannels[i].CanJoinChannel(MyPRI) && VoiceChannels[i].IsMember(MyPRI, True) )
					{
						SMNameArray[SMArraySize] = VoiceChannels[i].GetTitle();
						SMIndexArray[SMArraySize] = VoiceChannels[i].ChannelIndex;
						SMArraySize++;
					}
				}
				break;

			case 2:    // Talk
				VoiceChannels = VRI.GetChannels();
				for ( i = 0; i < VoiceChannels.Length; i++ )
				{
					if ( VoiceChannels[i].CanJoinChannel(MyPRI) )
					{
						SMNameArray[SMArraySize] = VoiceChannels[i].GetTitle();
						SMIndexArray[SMArraySize] = VoiceChannels[i].ChannelIndex;
						SMArraySize++;
					}
				}

				break;

			}
			break;
		}
	}

	//////////////////////////////////////////////

	function EnterState(ESpeechMenuState newState, optional bool bNoSound)
	{
		SMState = newState;
		HighlightRow = 0;
		RebuildSMArray();

		if(!bNoSound)
			PlayConsoleSound(SMAcceptSound);
	}

	function LeaveState() // Go up a level
	{
		PlayConsoleSound(SMDenySound);

		switch ( SMState )
		{
			case SMS_Main:
				CloseSpeechMenu();
				break;

			case SMS_PlayerSelect:
				EnterState(SMS_Order, true);
				break;

			case SMS_VoiceChatChannel:
				EnterState(SMS_VoiceChat,True);
				break;

			default:
				EnterState(SMS_Main, True);
		}
	}
	// // // // // //

	function HandleInput(int keyIn)
	{
		local int selectIndex;
		local UnrealPlayer up;
		local Pawn TauntPawn;
		local VoiceChatReplicationInfo VRI;

		// GO BACK - previous state (might back out of menu);
		if(keyIn == -1)
		{
			HighlightRow = 0;
			LeaveState();
			return;
		}

		// TOP LEVEL - we just enter a new state
		if(SMState == SMS_Main)
		{
			switch( SMNameArray[keyIn-1] )
			{
			case SMStateName[1]: SMType = ''; if ( VoiceChatAllowed() ) EnterState( SMS_VoiceChat ); break;
			case SMStateName[2]: SMType = 'ACK'; EnterState(SMS_Ack); break;
			case SMStateName[3]: SMType = 'FRIENDLYFIRE'; EnterState(SMS_FriendFire); break;
			case SMStateName[4]: SMType = 'ORDER'; EnterState(SMS_Order); break;
			case SMStateName[5]: SMType = 'OTHER'; EnterState(SMS_Other); break;
			case SMStateName[6]: SMType = 'TAUNT'; EnterState(SMS_Taunt); break;
			case SMStateName[7]: SMType = ''; EnterState(SMS_TauntAnim); break;
			}

			return;
		}

		// Next page on the same level
		if(keyIn == 0 )
		{
			// Check there is a next page!
			if(SMArraySize - SMOffset > 9)
				SMOffset += 9;

			return;
		}

		// Previous page on the same level
		if(keyIn == -2)
		{
			SMOffset = Max(SMOffset - 9, 0);
			return;
		}

		// Otherwise - we have selected something!
		selectIndex = SMOffset + keyIn - 1;
		if(selectIndex < 0 || selectIndex >= SMArraySize) // discard - out of range selections.
			return;

		switch ( SMState )
		{
		case SMS_Order:
			SMIndex = SMIndexArray[selectIndex];
			EnterState(SMS_PlayerSelect);
			break;

		case SMS_VoiceChat:
			SMIndex = SMIndexArray[selectIndex];
			EnterState(SMS_VoiceChatChannel);
			break;

		case SMS_VoiceChatChannel:
			VRI = ViewportOwner.Actor.VoiceReplicationInfo;
			if (VRI == None)
				return;

			// Perform the action selected
			switch ( SMIndex )
			{
				case 0:	// Join Channel
					ViewportOwner.Actor.Join(SMNameArray[selectIndex],"");
					break;

				case 1:	// Leave Channel
					ViewportOwner.Actor.Leave(SMNameArray[selectIndex]);
					break;

				case 2:
					ViewportOwner.Actor.Speak(SMNameArray[selectIndex]);
					break;
			}

			// Add confirmation
			PlayConsoleSound(SMAcceptSound);
			CloseSpeechMenu();
			break;

		case SMS_PlayerSelect:
			if(SMNameArray[selectIndex] == SMAllString)
				ViewportOwner.Actor.Speech(SMType, SMIndex, "");
			else
				ViewportOwner.Actor.Speech(SMType, SMIndex, SMNameArray[selectIndex]);

			PlayConsoleSound(SMAcceptSound);

			CloseSpeechMenu(); // Close menu after message
			break;

		case SMS_TauntAnim:
			up = UnrealPlayer(ViewportOwner.Actor);
			if ( Vehicle(up.Pawn) != None )
				TauntPawn = Vehicle(up.Pawn).Driver;
			else
				TauntPawn = up.Pawn;
			up.Taunt( TauntPawn.TauntAnims[ SMIndexArray[selectIndex] ] );
			PlayConsoleSound(SMAcceptSound);
			CloseSpeechMenu();
			break;

		default:
			ViewportOwner.Actor.Speech(SMType, SMIndexArray[selectIndex], "");
			PlayConsoleSound(SMAcceptSound);
			CloseSpeechMenu();
		}
	}

	//////////////////////////////////////////////

	function string NumberToString(int num)
	{
		local EInputKey key;
		local string s;

		if(num < 0 || num > 9)
			return "";

		if(bSpeechMenuUseLetters)
			key = LetterKeys[num];
		else
			key = NumberKeys[num];

		s = ViewportOwner.Actor.ConsoleCommand( "LOCALIZEDKEYNAME"@string(int(key)) );
		return s;
	}

	function DrawNumbers( canvas Canvas, int NumNums, bool IncZero, bool sizing, out float XMax, out float YMax )
	{
		local int i;
		local float XPos, YPos;
		local float XL, YL;

		XPos = Canvas.ClipX * (SMOriginX+SMMargin);
		YPos = Canvas.ClipY * (SMOriginY+SMMargin);
		Canvas.SetDrawColor(128,255,128,255);

		for(i=0; i<NumNums; i++)
		{
			Canvas.SetPos(XPos, YPos);
			if(!sizing)
				Canvas.DrawText(NumberToString(i+1)$"-", false);
			else
			{
				Canvas.TextSize(NumberToString(i+1)$"-", XL, YL);
				XMax = Max(XMax, XPos + XL);
				YMax = Max(YMax, YPos + YL);
			}

			YPos += SMLineSpace;
		}

		if(IncZero)
		{
			Canvas.SetPos(XPos, YPos);

			if(!sizing)
				Canvas.DrawText(NumberToString(0)$"-", false);

			XPos += SMTab;
			Canvas.SetPos(XPos, YPos);

			if(!sizing)
				Canvas.DrawText(SMMoreString, false);
			else
			{
				Canvas.TextSize(SMMoreString, XL, YL);
				XMax = Max(XMax, XPos + XL);
				YMax = Max(YMax, YPos + YL);
			}
		}
	}

	function DrawCurrentArray( canvas Canvas, bool sizing, out float XMax, out float YMax )
	{
		local int i, stopAt;
		local float XPos, YPos;
		local float XL, YL;

		XPos = (Canvas.ClipX * (SMOriginX+SMMargin)) + SMTab;
		YPos = Canvas.ClipY * (SMOriginY+SMMargin);

		stopAt = Min(SMOffset+9, SMArraySize);
		for(i=SMOffset; i<stopAt; i++)
		{
			Canvas.SetPos(XPos, YPos);
			if(!sizing)
			{
				if ( SMState == SMS_VoiceChatChannel )
				{
					if ( IsActiveChannel(SMOffset + i) )
						Canvas.SetDrawColor(0,255,0,255);
					else if ( SMIndex == 2 && !IsMember(SMOffset + i) )
						Canvas.SetDrawColor(160,160,160,255);
					else Canvas.SetDrawColor(255,255,255,255);
				}
				else Canvas.SetDrawColor(255,255,255,255);

				Canvas.DrawText(SMNameArray[i], false);
			}
			else
			{
				Canvas.TextSize(SMNameArray[i], XL, YL);
				XMax = Max(XMax, XPos + XL);
				YMax = Max(YMax, YPos + YL);
			}

			YPos += SMLineSpace;
		}
	}

	function bool IsActiveChannel(int i)
	{
		if ( SMState != SMS_VoiceChatChannel )
			return false;

		if ( ViewportOwner.Actor == None || ViewportOwner.Actor.ActiveRoom == None )
			return false;

		if ( i < 0 || i > SMArraySize )
			return false;

		if ( SMIndexArray[i] != ViewportOwner.Actor.ActiveRoom.ChannelIndex )
			return false;

		return true;
	}

	function bool IsMember(int i)
	{
		if ( SMState != SMS_VoiceChatChannel )
			return false;

		if ( ViewportOwner.Actor == None || ViewportOwner.Actor.VoiceReplicationInfo == None || ViewportOwner.Actor.PlayerReplicationInfo == None )
			return false;

		return ViewportOwner.Actor.VoiceReplicationInfo.IsMember(ViewportOwner.Actor.PlayerReplicationInfo, SMIndexArray[i]);
	}



	//////////////////////////////////////////////

	function int KeyToNumber(EInputKey InKey)
	{
		local int i;

		for(i=0; i<10; i++)
		{
			if(bSpeechMenuUseLetters)
			{
				if(InKey == LetterKeys[i])
					return i;
			}
			else
			{
				if(InKey == NumberKeys[i])
					return i;
			}
		}

		return -1;
	}

	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local int input, NumNums;

		NumNums = Min(SMArraySize - SMOffset, 10);

		// While speech menu is up, dont let user use console. Debateable.
		//if( KeyIsBoundTo( Key, "ConsoleToggle" ) )
		//	return true;
		//if( KeyIsBoundTo( Key, "Type" ) )
		//	return true;

		if (Action == IST_Press)
		{
			bIgnoreKeys=false;
			if ( Key == IK_Ctrl )
				bCtrl = True;

			else if ( Key == IK_Alt )
				bAlt = True;

			else if ( key == IK_Shift )
				bShift = True;
		}

		if ( Action == IST_Release )
		{
			if ( bAlt )
			{
				if ( Key == IK_Left )	// extra mouse buttons - only tested this on logitech mx500  :\
				{
					HandleInput(-1);
					return True;
				}

				else if ( Key == IK_Right )
				{
					input = HighlightRow + 1;
					if(input == 10)
						input = 0;

					HighlightRow=0;
					HandleInput(input);
					return True;
				}
			}
		}

		if( Action != IST_Press )
			return false;

		if( Key==IK_Escape)
		{
			HandleInput(-1);
			return true ;
		}

		// If 'letters' mode is on, convert input
		input = KeyToNumber(Key);
		if(input != -1)
		{
			HandleInput(input);
			return true;
		}

		// Keys below are only used if bSpeechMenuUseMouseWheel is true
		if(!bSpeechMenuUseMouseWheel)
			return false;

		if( Key==IK_MouseWheelUp )
		{
			// If moving up on the top row, and there is a previous page
			if(HighlightRow == 0 && SMOffset > 0)
			{
				HandleInput(-2);
				HighlightRow=9;
			}
			else
			{
				HighlightRow = Max(HighlightRow - 1, 0);
			}

			return true;
		}
		else if( Key==IK_MouseWheelDown )
		{
			// If moving down on the bottom row (the 'MORE' row), act as if we hit it, and move highlight to top.
			if(HighlightRow == 9)
			{
				HandleInput(0);
				HighlightRow=0;
			}
			else
			{
				HighlightRow = Min(HighlightRow + 1, NumNums - 1);
			}

			return true;
		}
		else if( Key==IK_MiddleMouse )
		{

			input = HighlightRow + 1;
			if(input == 10)
				input = 0;

			HighlightRow=0;
			HandleInput(input);
			return true;
		}

		return false;
	}

	function Font MyGetSmallFontFor(canvas Canvas)
	{
		local int i;
		for(i=1; i<8; i++)
		{
			if ( class'HudBase'.default.FontScreenWidthSmall[i] <= Canvas.ClipX )
				return class'HudBase'.static.LoadFontStatic(i-1);
		}
		return class'HudBase'.static.LoadFontStatic(7);
	}

	function PostRender( canvas Canvas )
	{
		local float XL, YL;
		local int SelLeft, i;
		local float XMax, YMax;

		Canvas.Font = class'UT2MidGameFont'.static.GetMidGameFont(Canvas.ClipX); // Update which font to use.

		// Figure out max key name size
		XMax = 0;
		YMax = 0;
		for(i=0; i<10; i++)
		{
			Canvas.TextSize(NumberToString(i)$"- ", XL, YL);
			XMax = Max(XMax, XL);
			YMax = Max(YMax, YL);
		}
		SMLineSpace = YMax * 1.1;
		SMTab = XMax;

		SelLeft = SMArraySize - SMOffset;

		// First we figure out how big the bounding box needs to be
		XMax = 0;
		YMax = 0;
		DrawNumbers( canvas, Min(SelLeft, 9), SelLeft > 9, true, XMax, YMax);
		DrawCurrentArray( canvas, true, XMax, YMax);
		Canvas.TextSize(SMStateName[SMState], XL, YL);
		XMax = Max(XMax, Canvas.ClipX*(SMOriginX+SMMargin) + XL);
		YMax = Max(YMax, (Canvas.ClipY*SMOriginY) - (1.2*SMLineSpace) + YL);
		// XMax, YMax now contain to maximum bottom-right corner we drew to.

		// Then draw the box
		XMax -= Canvas.ClipX * SMOriginX;
		YMax -= Canvas.ClipY * SMOriginY;
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.SetPos(Canvas.ClipX * SMOriginX, Canvas.ClipY * SMOriginY);
		Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', XMax + (SMMargin*Canvas.ClipX), YMax + (SMMargin*Canvas.ClipY));

		// Draw highlight
		if(bSpeechMenuUseMouseWheel)
		{
			Canvas.SetDrawColor(255,255,255,128);
			Canvas.SetPos( Canvas.ClipX*SMOriginX, Canvas.ClipY*(SMOriginY+SMMargin) + ((HighlightRow - 0.1)*SMLineSpace) );
			Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', XMax + (SMMargin*Canvas.ClipX), 1.1*SMLineSpace );
		}

		// Then actually draw the stuff
		DrawNumbers( canvas, Min(SelLeft, 9), SelLeft > 9, false, XMax, YMax);
		DrawCurrentArray( canvas, false, XMax, YMax);

		// Finally, draw a nice title bar.
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.SetPos(Canvas.ClipX*SMOriginX, (Canvas.ClipY*SMOriginY) - (1.5*SMLineSpace));
		Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', XMax + (SMMargin*Canvas.ClipX), (1.5*SMLineSpace));

		Canvas.SetDrawColor(255,255,128,255);
		Canvas.SetPos(Canvas.ClipX*(SMOriginX+SMMargin), (Canvas.ClipY*SMOriginY) - (1.2*SMLineSpace));
		Canvas.DrawText(SMStateName[SMState]);

		if (SMState == SMS_VoiceChatChannel)
			DrawMembers(Canvas, XMax, YMax);
	}

	function DrawMembers(Canvas Canvas, float XMax, float YMax)
	{
		local array<int> Members;
		local int i;
		local float XPos, YPos, XL, YL;
		local GameReplicationInfo GRI;
		local string CurrentPlayer;

		GRI = ViewportOwner.Actor.GameReplicationInfo;
		if ( GRI == None )
			return;

		if (HighlightRow >= 0 && HighlightRow < SMArraySize)
		{
			Members = ViewportOwner.Actor.VoiceReplicationInfo.GetChannelMembersAt( SMIndexArray[SMOffset + HighlightRow] );
			Canvas.SetDrawColor(255,255,175,220);
	//		XPos = (Canvas.ClipX * (SMOriginX+SMMargin)) + SMTab;
	//		YPos = Canvas.ClipY * (SMOriginY+SMMargin);
			XPos = XMax + (SMMargin * Canvas.ClipX * 2.25)/* + SMTab*/;
			YPos = Canvas.ClipY*(SMOriginY+SMMargin) + ((HighlightRow + 0.1)*SMLineSpace);

			for(i=0; i<Members.Length; i++)
			{
				CurrentPlayer = GRI.FindPlayerByID(Members[i]).PlayerName;
				Canvas.SetPos(XPos, YPos);
				Canvas.TextSize(CurrentPlayer, XL, YL);
				XMax = Max(XMax, XPos + XL);
				YMax = Max(YMax, YPos + YL);

				YPos += SMLineSpace;
				Canvas.DrawText( CurrentPlayer );
			}
		}
	}

    function BeginState()
	{
        bVisible = true;
		bIgnoreKeys = true;
		bCtrl = false;
		HighlightRow=0;

		EnterState(SMS_Main, true);
		SMCallsign="";

		PlayConsoleSound(SMOpenSound);
	}

	function CloseSpeechMenu()
	{
		if (!bSpeechMenuLocked)
			GoToState('');
	}

    function EndState()
    {
        bVisible = false;
		bCtrl = false;
    }

	// Close speech menu on level change
	event NotifyLevelChange()
	{
		Global.NotifyLevelChange();
		GotoState('');
	}
}

exec function InGameChat()
{
	local GUIController GC;

    GC = GUIController(ViewportOwner.GUIController);
	if ( GC.OpenMenu(ChatMenuClass) )
    	ChatMenu = GC.ActivePage;

}

exec function ServerInfo()
{
	local GUIController GC;

    GC = GUIController(ViewportOwner.GUIController);

    if (GC==None)
    	return;

	GC.OpenMenu(ServerInfoMenu);
}

exec function TeamChatOnly()
{
	bTeamChatOnly = !bTeamChatOnly;
}

exec function PlayWaitingGame()
{
	local GUIController GC;

	if (WaitingGameClassName == "")
		return;

	GC = GUIController(ViewportOwner.GUIController);
	if (GC != None)
		GC.OpenMenu(WaitingGameClassName);
}

exec function MusicMenu()
{
	local GUIController C;
	local int i;

	if ( MusicManagerClassName == "" )
	{
		log("No music player menu configured.  Please check the MusicManagerClassName line of the [XInterface.ExtendedConsole] section of the UT2004.ini.");
		return;
	}

	C = GUIController(ViewportOwner.GUIController);
	if ( C != None )
	{
		i = C.FindMenuIndexByName(MusicManagerClassName);
		if ( i == -1 )
			C.OpenMenu(MusicManagerClassName);
		else C.RemoveMenuAt(i,true);
	}
}

// For debugging PlayInfo
exec function DumpPlayInfo( string group )
{
	local PlayInfo PInfo;

	foreach AllObjects( class'PlayInfo', PInfo )
	{
		if ( PInfo.InfoClasses.Length > 0 && PInfo.Settings.Length > 0 )
		{
			PInfo.Dump(group);
			break;
		}
	}
}
// For debugging CacheRecords
exec function DumpRecords(string Type)
{
	DumpCacheRecords(Type);
}

final private function AddMessage(string Mesg)
{
	log(Mesg);
	Message(Mesg,0);
}

final function DumpCacheRecords(optional string CacheType)
{
	local int i;
	local string Margin;

    local array<CacheManager.CrosshairRecord> CRecs;
    local array<CacheManager.WeaponRecord> WRecs;
    local array<CacheManager.MapRecord> MRecs;
    local array<CacheManager.MutatorRecord> MutRecs;
    local array<CacheManager.GameRecord> GRecs;
    local array<CacheManager.AnnouncerRecord> ARecs;
    local array<CacheManager.VehicleRecord> VRecs;

	if ( CacheType == "" || CacheType ~= "Crosshair" )
	{
	    class'CacheManager'.static.GetCrosshairList(CRecs);
	    AddMessage(" ================ Cached crosshair records ================ ");
	    for (i = 0; i < CRecs.Length; i++)
	    {
	        AddMessage(CRecs[i].RecordIndex$")"@CRecs[i].FriendlyName@CRecs[i].CrosshairTexture);
	    }

	    AddMessage("");
	}

	if ( CacheType == "" || CacheType ~= "GameType" )
	{
	    class'CacheManager'.static.GetGameTypeList(GRecs);
	    AddMessage(" ================ Cached gametype records ================ ");
	    for (i = 0; i < GRecs.Length; i++)
	    {
	    	for (Margin="";Len(Margin)<Len(i);Margin$=" ");

	        AddMessage(GRecs[i].RecordIndex$")"@GRecs[i].ClassName);
	        AddMessage(Margin$"    Name        :"$GRecs[i].GameName);
	        AddMessage(Margin$"    Description :"$GRecs[i].Description);
	        AddMessage(Margin$"    TextName    :"$GRecs[i].TextName);
	        AddMessage(Margin$"    GameAcronym :"$GRecs[i].GameAcronym);
	        AddMessage(Margin$"    MapListType :"$GRecs[i].MapListClassName);
	        AddMessage(Margin$"    MapPrefix   :"$GRecs[i].MapPrefix);
	        AddMessage(Margin$"    bTeamGame   :"$GRecs[i].bTeamGame);
	        AddMessage(Margin$"    Group       :"$GRecs[i].GameTypeGroup);
	    }
	    AddMessage("");
	}

	if ( CacheType == "" || CacheType ~= "Weapon" )
	{
 	   class'CacheManager'.static.GetWeaponList(WRecs);
	    AddMessage(" ================ Cached weapon records ================ ");
	    for (i = 0; i < WRecs.Length; i++)
	    {
	    	for (Margin="";Len(Margin)<Len(i);Margin$=" ");

	        AddMessage(WRecs[i].RecordIndex$")"@WRecs[i].ClassName);
	        AddMessage(Margin$"    FriendlyName:"$WRecs[i].FriendlyName);
	        AddMessage(Margin$"    Description :"$WRecs[i].Description);
	        AddMessage(Margin$"    TextName    :"$WRecs[i].TextName);
	        AddMessage(Margin$"    PickupClass :"$WRecs[i].PickupClassName);
	        AddMessage(Margin$"    Attachment  :"$WRecs[i].AttachmentClassName);
	    }
	    AddMessage("");
	}

	if ( CacheType == "" || CacheType ~= "Map" )
	{
	    class'CacheManager'.static.GetMapList(MRecs);
	    AddMessage(" ================ Cached map records ================ ");
	    for (i = 0; i < MRecs.Length; i++)
	    {
	    	for (Margin="";Len(Margin)<Len(i);Margin$=" ");

	        AddMessage(MRecs[i].RecordIndex$")"@MRecs[i].MapName);
	        AddMessage(Margin$"    Acronym       :"$MRecs[i].Acronym);
	        AddMessage(Margin$"    TextName      :"$MRecs[i].TextName);
	        AddMessage(Margin$"    FriendlyName  :"$MRecs[i].FriendlyName);
	        AddMessage(Margin$"    Author        :"$MRecs[i].Author);
	        AddMessage(Margin$"    PlayerCountMin:"$MRecs[i].PlayerCountMin);
	        AddMessage(Margin$"    PlayerCountMax:"$MRecs[i].PlayerCountMax);
	        AddMessage(Margin$"    Description   :"$MRecs[i].Description);
	        AddMessage(Margin$"    Screenshot    :"$MRecs[i].ScreenshotRef);
	        AddMessage(Margin$"    ExtraInfo     :"$MRecs[i].ExtraInfo);
	    }

	    AddMessage("");
	}

	if ( CacheType == "" || CacheType ~= "Mutator" )
	{
	    class'CacheManager'.static.GetMutatorList(MutRecs);
	    AddMessage(" ================ Cached mutator records ================ ");
	    for (i = 0; i < MutRecs.Length; i++)
	    {
	    	for (Margin="";Len(Margin)<Len(i);Margin$=" ");

	        AddMessage(MutRecs[i].RecordIndex$")"@MutRecs[i].ClassName);
	        AddMessage(Margin$"    FriendlyName       :"$MutRecs[i].FriendlyName);
	        AddMessage(Margin$"    Description        :"$MutRecs[i].Description);
	        AddMessage(Margin$"    GroupName          :"$MutRecs[i].GroupName);
	        AddMessage(Margin$"    ConfigMenu         :"$MutRecs[i].ConfigMenuClassName);
	        AddMessage(Margin$"    IconMaterialName   :"$MutRecs[i].IconMaterialName);
	    }
	    AddMessage("");
	}

	if ( CacheType == "" || CacheType ~= "Announcer" )
	{
	    class'CacheManager'.static.GetAnnouncerList(ARecs);
	    AddMessage(" ================ Cached announcer records ================ ");
	    for (i = 0; i < ARecs.Length; i++)
	    {
	    	for (Margin="";Len(Margin)<Len(i);Margin$=" ");

	        AddMessage(ARecs[i].RecordIndex$")"@ARecs[i].ClassName);
	        AddMessage(Margin$"    FriendlyName       :"$ARecs[i].FriendlyName);
	        AddMessage(Margin$"    PackageName        :"$ARecs[i].PackageName);
	        AddMessage(Margin$"    FallbackPackage    :"$ARecs[i].FallbackPackage);
	    }
	    AddMessage("");
	}

	if ( CacheType == "" || CacheType ~= "Vehicle" )
	{
	    class'CacheManager'.static.GetVehicleList(VRecs);
	    AddMessage(" ================ Cached vehicle records ================ ");
	    for (i = 0; i < VRecs.Length; i++)
	    {
	    	for (Margin="";Len(Margin)<Len(i);Margin$=" ");

	        AddMessage(VRecs[i].RecordIndex$")"@VRecs[i].ClassName);
	        AddMessage(Margin$"    FriendlyName       :"$VRecs[i].FriendlyName);
	        AddMessage(Margin$"    Description        :"$VRecs[i].Description);
	    }
	    AddMessage("");
	}
}

function bool VoiceChatAllowed()
{
	if ( ViewportOwner == None )
		return false;

	if ( ViewportOwner.Actor == None )
		return false;

	if ( ViewportOwner.Actor.Level == None )
		return false;

	if ( ViewportOwner.Actor.Level.NetMode == NM_DedicatedServer )
		return false;

	if ( ViewportOwner.Actor.Level.NetMode == NM_StandAlone )
		return false;

	return true;
}

exec function DLO( string ClassName, string ClassType )
{
	local class c;
	local object o;

	if ( ClassName == "" )
	{
		log("No class name specified.");
		return;
	}

	if ( ClassType != "" )
		c = class(DynamicLoadObject(ClassType,Class'Class'));

	else c = class'class';

	o = DynamicLoadObject(ClassName, c);
	log("Result of DLO was "$o);
}

exec function DumpLoadingHints(string param)
{
	local array<CacheManager.GameRecord> Recs;
	local int i, j;
	local bool bShowAll;

	local class<GameInfo> GameClass;
	local array<string> Hints;

	class'CacheManager'.static.GetGameTypeList(Recs);

	bShowAll = param == "";
	for ( i = 0; i < Recs.Length; i++ )
	{
		GameClass = class<GameInfo>(DynamicLoadObject( Recs[i].ClassName, class'Class' ));
		if ( GameClass != None )
		{
			Hints = GameClass.static.GetAllLoadHints(!bShowAll);
			if ( Hints.Length > 0 )
			{
				log( Recs[i].GameName @ "Loading Hints -" );
				for ( j = 0; j < Hints.Length; j++ )
					log("  "$j$") "$Hints[j] );

				log("");
			}
		}
	}
}

exec function DebugTabOrder()
{
	if ( GUIController(ViewportOwner.GUIController) != None && GUIController(ViewportOwner.GUIController).ActivePage != None )
	{
		log("Searching for components with invalid tab order...");
		GUIController(ViewportOwner.GUIController).ActivePage.DebugTabOrder();
	}
}

defaultproperties
{
     MaxScrollbackSize=128
     ConsoleSoundVol=0.300000
     AddedCurrentHead="Added Server:"
     AddedCurrentTail="To Favorites!"
     ServerFullMsg="Server is now full"
     SMOriginX=0.010000
     SMOriginY=0.300000
     SMMargin=0.015000
     SMStateName(0)="Speech Menu"
     SMStateName(1)="Voice Chat"
     SMStateName(2)="Acknowledge"
     SMStateName(3)="Friendly Fire"
     SMStateName(4)="Order"
     SMStateName(5)="Other"
     SMStateName(6)="Taunt"
     SMStateName(7)="Taunt Anim"
     SMStateName(8)="Player Select"
     SMChannelOptions(0)="Join"
     SMChannelOptions(1)="Leave"
     SMChannelOptions(2)="Talk"
     SMAllString="[ALL]"
     SMMoreString="[MORE]"
     SMOpenSound=Sound'MenuSounds.selectDshort'
     SMAcceptSound=Sound'MenuSounds.selectJ'
     SMDenySound=Sound'MenuSounds.selectK'
     LetterKeys(0)=IK_Q
     LetterKeys(1)=IK_W
     LetterKeys(2)=IK_E
     LetterKeys(3)=IK_R
     LetterKeys(4)=IK_A
     LetterKeys(5)=IK_S
     LetterKeys(6)=IK_D
     LetterKeys(7)=IK_F
     LetterKeys(8)=IK_Z
     LetterKeys(9)=IK_X
     NumberKeys(0)=IK_0
     NumberKeys(1)=IK_1
     NumberKeys(2)=IK_2
     NumberKeys(3)=IK_3
     NumberKeys(4)=IK_4
     NumberKeys(5)=IK_5
     NumberKeys(6)=IK_6
     NumberKeys(7)=IK_7
     NumberKeys(8)=IK_8
     NumberKeys(9)=IK_9
     bSpeechMenuUseMouseWheel=True
     ChatMenuClass="GUI2K4.UT2K4InGameChat"
     StatsPromptMenuClass="GUI2K4.UT2K4StatsPrompt"
     MusicManagerClassName="GUI2K4.StreamPlayer"
     NeedPasswordMenuClass="GUI2K4.UT2K4GetPassword"
     ServerInfoMenu="GUI2K4.UT2K4ServerInfo"
     DemoPlaybackSpeeds(0)=0.250000
     DemoPlaybackSpeeds(1)=0.500000
     DemoPlaybackSpeeds(2)=1.100000
     DemoPlaybackSpeeds(3)=2.000000
     DemoPlaybackSpeeds(4)=4.000000
     bDemoJogKeys=True
     ConsoleHotKey=192
}
