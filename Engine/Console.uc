//=============================================================================
// Console: handles command input and manages menus.
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
class Console extends Interaction;

var config byte ConsoleHotKey;		// The key used to bring the console up.

var int HistoryTop, HistoryBot, HistoryCur;
var string TypedStr, History[16];           // Holds the current command, and the history
var int TypedStrPos;		//Current position in TypedStr
var bool bTyping;							// Turn when someone is typing on the console
var bool bIgnoreKeys;						// Ignore Key presses until a new KeyDown is received

var() transient bool bRunningDemo;
var() transient bool bHoldingStart;
var() transient bool bHoldingBack;

var() transient float TimeIdle;             // Time since last input.
var() transient float TimeHoldingReboot;    // If start+back are held for this long it'll reboot.

var() globalconfig float TimePerTitle;      // Time spent at title screen.
var() globalconfig float TimePerDemo;       // Time spent running in attract mode.
var() globalconfig float TimeTooIdle;       // Time allowed idle players in locked interactive demo.
var() globalconfig float TimeBeforeReboot;  // If start+back are held for this long it'll reboot.

var() globalconfig float TimePerSoak;       // TimePerDemo while soaking.

var() globalconfig String DemoLevels[64];

var array<string> BufferedConsoleCommands;	// If this is blank, perform the command at Tick

event Initialized()
{
    if( IsSoaking() )
    {
        TimePerTitle = 1;
        TimePerDemo = TimePerSoak;
    }
}

event ViewportInitialized()
{
	if ( ViewportOwner.ConfiguredInternetSpeed == 0 )
		ViewportOwner.ResetConfig("ConfiguredInternetSpeed");

	if ( ViewportOwner.ConfiguredLanSpeed == 0 )
		ViewportOwner.ResetConfig("ConfiguredLanSpeed");
}

event NativeConsoleOpen()
{
}

function UnPressButtons()
{
	local PlayerController PC;

	if (ViewportOwner != none)
	{
		PC = ViewportOwner.Actor;
		if ( PC != None )
			PC.UnPressButtons();
	}
}

exec function Type()
{
	TypedStr="";
	TypedStrPos=0;
    TypingOpen();
}

exec function Talk()
{
	TypedStr="Say ";
	TypedStrPos=4;
    TypingOpen();
}

exec function TeamTalk()
{
	TypedStr="TeamSay ";
	TypedStrPos=8;
    TypingOpen();
}

exec function ConsoleOpen();
exec function ConsoleClose();
exec function ConsoleToggle();

exec function StartRollingDemo()
{
    local int i, tryCount;

	return;

    TimeIdle = 0;
    tryCount = 1024;

    do
    {
        i = int ( FRand() * float (ArrayCount(DemoLevels)) );

        tryCount--;

        if (tryCount < 0)
        {
            log ("Couldn't find a random level to StartRollingDemo", 'Error');
            return;
        }

    } until (DemoLevels[i] != "")

    bRunningDemo = true;

    if( InStr( DemoLevels[i], "NumBots" ) >= 0 )
        ViewportOwner.Actor.ClientTravel( DemoLevels[i] $ "?SpectatorOnly=1", TRAVEL_Absolute, false );
    else
        ViewportOwner.Actor.ClientTravel( DemoLevels[i] $ "?SpectatorOnly=1?bAutoNumBots=true", TRAVEL_Absolute, false );
}

exec function StopRollingDemo()
{
    bRunningDemo = false;
    TimeIdle = 0;
    ConsoleCommand( "DISCONNECT" );
}

event NotifyLevelChange()
{
    ConsoleClose();
}

function DelayedConsoleCommand(string command)
{
	BufferedConsoleCommands.Length = BufferedConsoleCommands.Length+1;
	BufferedConsoleCommands[BufferedConsoleCommands.Length-1] = Command;
}


//-----------------------------------------------------------------------------
// Message - By default, the console ignores all output.
//-----------------------------------------------------------------------------

function Chat(coerce string Msg, float MsgLife, PlayerReplicationInfo PRI);
event Message( coerce string Msg, float MsgLife);

event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	if (Action!=IST_Press)
		return false;

	if (Key==ConsoleHotKey && Action==IST_Release)
	{
		ConsoleOpen();
		return true;
	}

    if( Action == IST_Press )
    {
        TimeIdle = 0;

        if( bRunningDemo && !IsSoaking() )
        {
            StopRollingDemo();
            return( true );
        }
    }

    return( false );
}
//-----------------------------------------------------------------------------
// State used while typing a command on the console.

function TypingOpen()
{
	bTyping = true;

    if( (ViewportOwner != None) && (ViewportOwner.Actor != None) )
	    ViewportOwner.Actor.Typing( bTyping );

	//TypedStr = "";

	GotoState('Typing');
}

function TypingClose()
{
	bTyping = false;

    if( (ViewportOwner != None) && (ViewportOwner.Actor != None) )
	    ViewportOwner.Actor.Typing( bTyping );

	TypedStr="";
	TypedStrPos=0;

    if( GetStateName() == 'Typing' )
        GotoState( '' );
}

state Typing
{
	exec function Type()
	{
		TypedStr="";
		TypedStrPos=0;
        TypingClose();
	}
	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		if (bIgnoreKeys)
			return true;

		if( Key>=0x20 )
		{
			if( Unicode != "" )
				TypedStr = Left(TypedStr, TypedStrPos) $ Unicode $ Right(TypedStr, Len(TypedStr) - TypedStrPos);
			else
				TypedStr = Left(TypedStr, TypedStrPos) $ Chr(Key) $ Right(TypedStr, Len(TypedStr) - TypedStrPos);
			TypedStrPos++;
            return( true );
		}

		return false;
	}

	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string Temp;

		if (Action== IST_PRess)
		{
			bIgnoreKeys=false;
		}

		if( Key==IK_Escape )
		{
			if( TypedStr!="" )
			{
				TypedStr="";
				TypedStrPos=0;
				HistoryCur = HistoryTop;
                return( true );
			}
			else
			{
                TypingClose();
                return( true );
			}
		}
		else if( Action != IST_Press )
		{
            return( false );
		}
		else if( Key==IK_Enter )
		{
			if( TypedStr!="" )
			{
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

            TypingClose();

            return( true );
		}
		else if( Key==IK_Up )
		{
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
            return( true );
		}
		else if( Key==IK_Down )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryTop)
					HistoryCur = HistoryBot;
				else
                    HistoryCur = (HistoryCur+1) % ArrayCount(History);

				TypedStr = History[HistoryCur];
				TypedStrPos = Len(TypedStr);
			}

		}
		else if( Key==IK_Backspace )
		{
			if( TypedStrPos > 0 )
			{
				TypedStr = Left(TypedStr,TypedStrPos-1)$Right(TypedStr, Len(TypedStr) - TypedStrPos);
				TypedStrPos--;
			}
            		return( true );
		}
		else if ( Key==IK_Delete )
		{
			if ( TypedStrPos < Len(TypedStr) )
				TypedStr = Left(TypedStr,TypedStrPos)$Right(TypedStr, Len(TypedStr) - TypedStrPos - 1);
			return true;
		}
		else if ( Key==IK_Left )
		{
			TypedStrPos = Max(0, TypedStrPos - 1);
			return true;
		}
		else if ( Key==IK_Right )
		{
			TypedStrPos = Min(Len(TypedStr), TypedStrPos + 1);
			return true;
		}
		else if ( Key==IK_Home )
		{
			TypedStrPos = 0;
			return true;
		}
		else if ( Key==IK_End )
		{
			TypedStrPos = Len(TypedStr);
			return true;
		}
        return( true );
	}

    function BeginState()
	{
        bTyping = true;
        bVisible= true;
		bIgnoreKeys = true;
        HistoryCur = HistoryTop;
    }
    function EndState()
    {
		ConsoleCommand("toggleime 0");
        bTyping = false;
        bVisible = false;
    }
}

simulated event Tick( float Delta )
{

	while (BufferedConsoleCommands.Length>0)
	{
		ViewportOwner.Actor.ConsoleCommand(BufferedConsoleCommands[0]);
		BufferedConsoleCommands.Remove(0,1);
	}

/*
    if( bRunningDemo )
    {
        if( (TimePerDemo > 0.0) && (TimeIdle > TimePerDemo) && (curMenu == None) )
            StopRollingDemo();
    }
    else if
    (
        (ViewportOwner.Actor.Level == ViewportOwner.Actor.GetEntryLevel()) &&
        (curMenu != None) && (curMenu.IsA('MenuMain')) &&
        (ViewportOwner.Actor.Level.LevelAction == LEVACT_None) &&
        (ViewportOwner.Actor.Level.Pauser == None)
    )
    {
        if ( (TimePerTitle > 0.0) && (TimeIdle > TimePerTitle) )
            StartRollingDemo();
    }
*/
}

event ConnectFailure(string FailCode,string URL);

function SetMusic(string NewSong);

function string SetInitialMusic(string NewSong)
{
	return NewSong;
}

defaultproperties
{
     ConsoleHotKey=9
     HistoryBot=-1
     TimePerTitle=30.000000
     TimePerDemo=60.000000
     TimeTooIdle=60.000000
     TimeBeforeReboot=5.000000
     TimePerSoak=3600.000000
     DemoLevels(0)="DM-Curse3"
     DemoLevels(1)="DM-Antalus"
     DemoLevels(2)="CTF-Chrome"
     DemoLevels(3)="DOM-SunTemple"
     DemoLevels(4)="BR-Endagra"
     bRequiresTick=True
}
