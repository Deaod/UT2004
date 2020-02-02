//=============================================================================
// PlayerReplicationInfo.
//=============================================================================
class PlayerReplicationInfo extends ReplicationInfo
	native nativereplication;

var float				Score;				// Player's current score.
var float				Deaths;				// Number of player's deaths.
var Decoration			HasFlag;
var byte				Ping;
var Volume				PlayerVolume;
var ZoneInfo            PlayerZone;
var int					NumLives;

var string				PlayerName;			// Player name, or blank if none.
var string				CharacterName, OldCharacterName;
var string				OldName, PreviousName;	// Temporary value.
var int					PlayerID;			// Unique id number.
var TeamInfo			Team;				// Player Team
var int					TeamID;				// Player position in team.
var class<VoicePack>	VoiceType;
var string				VoiceTypeName;
var bool				bAdmin;				// Player logged in as Administrator
var bool				bIsFemale;
var bool				bIsSpectator;
var bool				bOnlySpectator;
var bool				bWaitingPlayer;
var bool				bReadyToPlay;
var bool				bOutOfLives;
var bool				bBot;
var bool				bWelcomed;			// set after welcome message broadcast (not replicated)
var bool				bReceivedPing;
var bool				bNoTeam;			// true if no teaminfo for this PRI
var bool				bTeamNotified;

var byte				PacketLoss;

// Time elapsed.
var int					StartTime;

var localized String	StringDead;
var localized String    StringSpectating;
var localized String	StringUnknown;

var int					GoalsScored;		// not replicated - used on server side only
var int					Kills;				// not replicated

var vehicle 			CurrentVehicle;		// for performance on clients

var LinkedReplicationInfo CustomReplicationInfo;	// for use by mod authors

// ========================================
// ========================================
// Voice chat
// ========================================
// ========================================
var VoiceChatReplicationInfo VoiceInfo;
var bool                     bRegisteredChatRoom;
var VoiceChatRoom		     PrivateChatRoom;     // not replicated - simulated spawn
var int                      ActiveChannel;       // this player's currently active channel
var int                      VoiceMemberMask;     // members of this player's private chatroom
var byte				     VoiceID;		      // contains the player's unique ID used by voice channels

replication
{
	// Things the server should send to the client.
	reliable if ( bNetDirty && (Role == Role_Authority) )
		Score, Deaths, PlayerVolume, PlayerZone,
		PlayerName, Team, TeamID, bIsFemale, bAdmin,
		bIsSpectator, bOnlySpectator, bWaitingPlayer, bReadyToPlay,
		StartTime, bOutOfLives, CharacterName, 
		VoiceID, VoiceMemberMask, ActiveChannel;

	reliable if ( bNetDirty && (Role == ROLE_Authority) && bNetOwner && HasFlag == None )
		HasFlag;

	reliable if ( bNetDirty && (Role == Role_Authority) && (!bNetOwner || bDemoRecording) )
		PacketLoss, Ping;

	reliable if ( bNetDirty && (Role == Role_Authority) && bNetInitial )
		PlayerID, bBot, VoiceTypeName, bNoTeam, CustomReplicationInfo;
}

event PostBeginPlay()
{
	if ( Role < ROLE_Authority )
		return;
    if (AIController(Owner) != None)
        bBot = true;
	StartTime = Level.Game.GameReplicationInfo.ElapsedTime;
	Timer();
	SetTimer(1.5 + FRand(), true);

}

simulated event PostNetBeginPlay()
{
	local GameReplicationInfo GRI;
	local VoiceChatReplicationInfo VRI;

	if ( Level.GRI != None )
		Level.GRI.AddPRI(self);
	else
	{
		ForEach DynamicActors(class'GameReplicationInfo',GRI)
		{
			GRI.AddPRI(self);
			break;
		}
	}

	// VoiceInfo will only have a value if our PlayerID was replicated prior to our PostNetBeginPlay() & VoiceReplicationInfo had been initialized.
	foreach DynamicActors(class'VoiceChatReplicationInfo', VRI)
	{
		VoiceInfo = VRI;
		break;
	}

	if ( Team != None )
		bTeamNotified = true;
}

simulated function bool NeedNetNotify()
{
	return ( !bRegisteredChatRoom || (!bNoTeam && (Team == None)) );
}

simulated event PostNetReceive()
{
	local Actor A;
	local PlayerController PC;

	if ( !bTeamNotified && (Team != None) )
	{
		bTeamNotified = true;

		PC = Level.GetLocalPlayerController();
		ForEach DynamicActors(class'Actor', A)
		{
			// find my pawn and tell it
			if ( Pawn(A) != None && Pawn(A).PlayerReplicationInfo == self )
			{
				Pawn(A).NotifyTeamChanged();
				if ( PC.PlayerReplicationInfo != self )
					break;
			}
			else if ( A.bNotifyLocalPlayerTeamReceived && PC.PlayerReplicationInfo == self )
				A.NotifyLocalPlayerTeamReceived(); //if this is the local player's PRI, tell actors that want to know about it
		}
	}

	if ( !bRegisteredChatRoom && VoiceInfo != None && PlayerID != default.PlayerID && VoiceID != default.VoiceID )
	{
		bRegisteredChatRoom = True;
		VoiceInfo.AddVoiceChatter(Self);
	}


	bNetNotify = NeedNetNotify();
}

simulated function Destroyed()
{
	local GameReplicationInfo GRI;

	if ( Level.GRI != None )
		Level.GRI.RemovePRI(self);
	else
	{
		ForEach DynamicActors(class'GameReplicationInfo',GRI)
		{
			GRI.RemovePRI(self);
			break;
		}
	}

    if ( VoiceInfo == None )
    	foreach DynamicActors( class'VoiceChatReplicationInfo', VoiceInfo )
    		break;

    if ( VoiceInfo != None )
	    VoiceInfo.RemoveVoiceChatter(Self);

    Super.Destroyed();
}

function SetCharacterVoice(string S)
{
	local class<VoicePack> NewVoiceType;

	if ( (Left(S,1) == ".") || (Right(S,1) == ".") || (Left(S,5) ~= "none.") )
	{
		return;
	}

	if ( (Level.NetMode == NM_DedicatedServer) && (VoiceType != None) )
	{
		VoiceTypeName = S;
		return;
	}
	if ( S == "" )
	{
		VoiceTypeName = "";
		return;
	}

	NewVoiceType = class<VoicePack>(DynamicLoadObject(S,class'Class'));
	if ( NewVoiceType != None )
	{
		VoiceType = NewVoiceType;
		VoiceTypeName = S;
	}
}

function SetCharacterName(string S)
{
	CharacterName = S;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	Score = 0;
	Deaths = 0;
	HasFlag = None;
	bReadyToPlay = false;
	NumLives = 0;
	bOutOfLives = false;
}

simulated function string GetHumanReadableName()
{
	return PlayerName;
}

simulated function string GetLocationName()
{
	local string VehicleString;
	local Vehicle V;

    if( ( PlayerVolume == None ) && ( PlayerZone == None ) )
    {
    	if ( (Owner != None) && Controller(Owner).IsInState('Dead') )
        	return StringDead;
        else
			return StringSpectating;
    }

    if ( Owner != None )
    {
		if ( Vehicle(Controller(Owner).Pawn) != None )
			VehicleString = Vehicle(Controller(Owner).Pawn).GetVehiclePositionString();
	}
	else if ( Level.NetMode == NM_Client )
	{
		if ( (CurrentVehicle != None) && (CurrentVehicle.PlayerReplicationInfo == self) )
			VehicleString = CurrentVehicle.GetVehiclePositionString();
		else if ( Level.TimeSeconds - Level.LastVehicleCheck > 1 )
		{
			// vehicles are often bAlwaysRelevant, so may still be relevant
			ForEach DynamicActors(class'Vehicle', V)
				if ( V.PlayerReplicationInfo == self )
				{
					VehicleString = V.GetVehiclePositionString();
					CurrentVehicle = V;
					break;
				}
			if ( V == None )
				Level.LastVehicleCheck = Level.TimeSeconds;
		}
	}
	if( ( PlayerVolume != None ) && ( PlayerVolume.LocationName != class'Volume'.Default.LocationName ) )
	{
		if ( len(PlayerVolume.LocationName@VehicleString) > 32 )
			return PlayerVolume.LocationName;
		return PlayerVolume.LocationName@VehicleString;
	}
	else if( PlayerZone != None && ( PlayerZone.LocationName != "" )  )
	{
		if ( len(PlayerZone.LocationName@VehicleString) > 32 )
			return PlayerZone.LocationName;
		return PlayerZone.LocationName@VehicleString;
	}
	else if ( VehicleString != "" )
		return VehicleString;
    else if ( Level.Title != Level.Default.Title )
		return Level.Title;
	else
        return StringUnknown;
}

simulated function material GetPortrait();
event UpdateCharacter();

function UpdatePlayerLocation()
{
    local Volume V, Best;
    local Pawn P;
    local Controller C;

    C = Controller(Owner);

    if( C != None )
        P = C.Pawn;

    if( P == None )
    {
        PlayerVolume = None;
        PlayerZone = None;
        return;
    }

    if ( PlayerZone != P.Region.Zone )
		PlayerZone = P.Region.Zone;

    foreach P.TouchingActors( class'Volume', V )
    {
        if( V.LocationName == "")
            continue;

        if( (Best != None) && (V.LocationPriority <= Best.LocationPriority) )
            continue;

        if( V.Encompasses(P) )
            Best = V;
    }
    if ( PlayerVolume != Best )
		PlayerVolume = Best;
}

/* DisplayDebug()
list important controller attributes on canvas
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	if ( Team != None )
		Canvas.DrawText("     PlayerName "$PlayerName$" Team "$Team.GetHumanReadableName() $"("$Team.TeamIndex$") has flag "$HasFlag);
	else
		Canvas.DrawText("     PlayerName "$PlayerName$" NO Team");

	if ( !bBot )
	{
		YPos += YL;
		Canvas.SetPos(4, YL);
		Canvas.DrawText("               bIsSpec:"$bIsSpectator@"OnlySpec:"$bOnlySpectator@"Waiting:"$bWaitingPlayer@"Ready:"$bReadyToPlay@"OutOfLives:"$bOutOfLives);
	}
}

event ClientNameChange()
{
    local PlayerController PC;

	ForEach DynamicActors(class'PlayerController', PC)
		PC.ReceiveLocalizedMessage( class'GameMessage', 2, self );
}

function Timer()
{
    local Controller C;

	UpdatePlayerLocation();
	SetTimer(1.5 + FRand(), true);
	if( FRand() < 0.65 )
		return;

	if( !bBot )
	{
	    C = Controller(Owner);
		if ( !bReceivedPing )
			Ping = Min(int(0.25 * float(C.ConsoleCommand("GETPING"))),255);
	}
}

function SetPlayerName(string S)
{
	OldName = PlayerName;
	PlayerName = S;
	if ( PlayerController(Owner) != None )
		PlayerController(Owner).PlayerOwnerName = S;
}

function SetWaitingPlayer(bool B)
{
	bIsSpectator = B;
	bWaitingPlayer = B;
}

function SetChatPassword( string InPassword )
{
	if ( PrivateChatRoom != None )
		PrivateChatRoom.SetChannelPassword(InPassword);
}

function SetVoiceMemberMask( int NewMask )
{
	VoiceMemberMask = NewMask;
}

simulated function string GetCallSign()
{
	if ( TeamID > 14 )
		return "";
	return class'GameInfo'.default.CallSigns[TeamID];
}

simulated event string GetNameCallSign()
{
	if ( TeamID > 14 )
		return PlayerName;
	return PlayerName$" ["$class'GameInfo'.default.CallSigns[TeamID]$"]";
}

defaultproperties
{
     StringDead="Dead"
     StringSpectating="Spectating"
     StringUnknown="Unknown"
     VoiceID=255
     NetUpdateFrequency=1.000000
     bNetNotify=True
}
