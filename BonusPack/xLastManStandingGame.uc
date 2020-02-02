// ====================================================================
//  Class: BonusPack.xLastManStandingGame
//
//  Main 'Last Man Standing' game type tab.
//
//  Written by James Golding
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class xLastManStandingGame extends xDeathMatch
	config;

struct LMSDataEntry
{
	var PlayerController	PC;
	var vector				LocationHistory[10];
	var int					NextLocHistSlot;
	var bool				bWarmedUp;
	var int					ReWarnTime;
};

var		array<LMSDataEntry>		LMSData;

var config	float					CampThreshold;
var config	int						ReCamperWarnInterval;
var config	bool 					bHealthForKill; // number of kills before you get an extra life (zero indicates never give extra life)
var config	bool					bAllowSuperweapons;
var config	bool					bCamperAlarm;
var config	bool					bAllowPickups;
var config	bool					bAllowAdrenaline;
var config  bool					bFullAmmo;

const LMSPROPNUM = 8;
var localized string				LMSPropsDisplayText[LMSPROPNUM];
var localized string				LMSPropDescText[LMSPROPNUM];

// When player starts - give them all the weapons (not super weapons)!
function AddGameSpecificInventory(Pawn p)
{
	local Inventory Inv;

	Super.AddGameSpecificInventory(p);

	p.CreateInventory("XWeapons.BioRifle");
	p.CreateInventory("XWeapons.FlakCannon");
	p.CreateInventory("XWeapons.LinkGun");
	p.CreateInventory("XWeapons.Minigun");
	p.CreateInventory("XWeapons.RocketLauncher");
	p.CreateInventory("XWeapons.ShockRifle");
	p.CreateInventory("XWeapons.SniperRifle");

	if ( bFullAmmo )
	{
		For ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			if ( Weapon(Inv) != None )
				Weapon(Inv).MaxOutAmmo();
		}
	}
}

// Make sure all weapons are loaded.
static function PrecacheGameTextures(LevelInfo myLevel)
{
	Super.PrecacheGameTextures(myLevel);

	class'XWeapons.BioRiflePickup'.static.StaticPrecache(myLevel);
	class'XWeapons.FlakCannonPickup'.static.StaticPrecache(myLevel);
	class'XWeapons.LinkGunPickup'.static.StaticPrecache(myLevel);
	class'XWeapons.MinigunPickup'.static.StaticPrecache(myLevel);
	class'XWeapons.RocketLauncherPickup'.static.StaticPrecache(myLevel);
	class'XWeapons.ShockRiflePickup'.static.StaticPrecache(myLevel);
	class'XWeapons.SniperRiflePickup'.static.StaticPrecache(myLevel);
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( !bRewardSounds )
		V.PrecacheSound('Camper');
}

/* OBSOLETE UpdateAnnouncements() - preload all announcer phrases used by this actor */
simulated function UpdateAnnouncements() {}

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	local string InOpt;

	Super.InitGame(Options, Error);

	// Should we allow superweapons
	InOpt = ParseOption( Options, "SuperWeaps");
	if(InOpt != "")
		bAllowSuperweapons=bool(InOpt);

	// Use camper alarm
	InOpt = ParseOption( Options, "CamperAlarm");
	if(InOpt != "")
		bCamperAlarm=bool(InOpt);

	InOpt = ParseOption(Options, "AllowPickups");
    if (InOpt !="")
    	bAllowPickups=bool(InOpt);

	InOpt = ParseOption(Options, "AllowAdrenaline");
    if (InOpt !="")
    	bAllowAdrenaline=bool(InOpt);

	InOpt = ParseOption(Options, "HealthForKill");
    if (InOpt !="")
    	bHealthForKill=bool(InOpt);

	GoalScore=0;		// Force no Frag Limit
}

// Used to award extra lives for kills
function NotifyKilled(Controller Killer, Controller Other, Pawn OtherPawn)
{
	Super.NotifyKilled(Killer, Other, OtherPawn);

	// If we are not doing extra-life bonus'
	if(!bHealthForKill || Killer==None || Killer.Pawn == None || Killer.Pawn.Health >100)
		return;

    Killer.Pawn.Health = Killer.Pawn.HealthMax;
}

// Send camper warning
function SendCamperWarning(PlayerController Camper)
{
    local Controller P;
	local PlayerController Player;

	for(P = Level.ControllerList; P != None; P = P.nextController)
	{
		Player = PlayerController(P);


		if (Player != None)
		{
			// No one camps in the first 45 seconds
			if (Level.TimeSeconds - Player.PlayerReplicationInfo.StartTime < 45)
        		return;
			if(Player == Camper)
				Player.ReceiveLocalizedMessage(class'BonusPack.LMSMessage', 0);
			else
				Player.ReceiveLocalizedMessage(class'BonusPack.LMSMessage', 1, Camper.PlayerReplicationInfo);
		}
	}
}

// Camper-detector
State MatchInProgress
{
	// GameInfo's already have a 1 second timer...
    function Timer()
	{
		local int i,j;
		local Box HistoryBox;
		local float MaxDim;
		local bool bSentWarning;

		Super.Timer();

		// Do nothing else if camper alarm is off.
		if(!bCamperAlarm)
			return;

		i=0;
		while(i < LMSData.Length && !bSentWarning)
		{
			//Log( "Checking: "$LMSData[i].PC.PlayerReplicationInfo.PlayerName );

			// If controller has expired (eg. left the game), remove the guard.
			if( LMSData[i].PC == None )
			{
				//Log("Expiring Camper Guard.");
				LMSData.Remove(i, 1);
			}
			else if( !LMSData[i].PC.PlayerReplicationinfo.bIsSpectator && !LMSData[i].PC.PlayerReplicationinfo.bOnlySpectator && LMSData[i].PC.PlayerReplicationInfo.NumLives<MaxLives ) // Spectators can't camp
			{
				// Always update
				LMSData[i].LocationHistory[LMSData[i].NextLocHistSlot] = LMSData[i].PC.Pawn.Location;
				LMSData[i].NextLocHistSlot++;

				if(LMSData[i].NextLocHistSlot == 10)
				{
					LMSData[i].NextLocHistSlot = 0;
					LMSData[i].bWarmedUp = true;
				}

				// If our history is full, work out how much player is moving about (find max AABB dimension).
				if(LMSData[i].bWarmedUp)
				{
					HistoryBox.Min.X = LMSData[i].LocationHistory[0].X;
					HistoryBox.Min.Y = LMSData[i].LocationHistory[0].Y;
					HistoryBox.Min.Z = LMSData[i].LocationHistory[0].Z;

					HistoryBox.Max.X = LMSData[i].LocationHistory[0].X;
					HistoryBox.Max.Y = LMSData[i].LocationHistory[0].Y;
					HistoryBox.Max.Z = LMSData[i].LocationHistory[0].Z;

					for(j=1; j<10; j++)
					{
						HistoryBox.Min.X = FMin( HistoryBox.Min.X , LMSData[i].LocationHistory[j].X );
						HistoryBox.Min.Y = FMin( HistoryBox.Min.Y , LMSData[i].LocationHistory[j].Y );
						HistoryBox.Min.Z = FMin( HistoryBox.Min.Z , LMSData[i].LocationHistory[j].Z );

						HistoryBox.Max.X = FMax( HistoryBox.Max.X , LMSData[i].LocationHistory[j].X );
						HistoryBox.Max.Y = FMax( HistoryBox.Max.Y , LMSData[i].LocationHistory[j].Y );
						HistoryBox.Max.Z = FMax( HistoryBox.Max.Z , LMSData[i].LocationHistory[j].Z );
					}

					// Find maximum dimension of box
					MaxDim = FMax(FMax(HistoryBox.Max.X - HistoryBox.Min.X, HistoryBox.Max.Y - HistoryBox.Min.Y), HistoryBox.Max.Z - HistoryBox.Min.Z);

					//Log("Box: "$HistoryBox.Max.X@HistoryBox.Max.Y@HistoryBox.Max.Z@HistoryBox.Min.X@HistoryBox.Min.Y@HistoryBox.Min.Z);
					//Log("Player: "$LMSData[i].PC.PlayerReplicationInfo.PlayerName$" MaxDim:"$MaxDim);

					// Dont warn the same person every second!
					if(MaxDim < CampThreshold && LMSData[i].ReWarnTime == 0)
					{
						//Log(LMSData[i].PC.PlayerReplicationInfo.PlayerName$" IS CAMPING! "$MaxDim);
						SendCamperWarning(LMSData[i].PC);
						LMSData[i].ReWarnTime = ReCamperWarnInterval;
						bSentWarning=true;
					}
					else if(LMSData[i].ReWarnTime > 0)
						LMSData[i].ReWarnTime--;
				}

				i++;
			}
            else
            	i++;
		}
	}
}

event PostLogin( PlayerController NewPlayer )
{
	local LMSDataEntry NewData;
	local int i, l;

	Super.PostLogin(NewPlayer);

    NewPlayer.bAdrenalineEnabled = bAllowAdrenaline;

	// Check we dont already have data for this player controller.
	for(i=0; i<LMSData.Length; i++)
	{
		if( LMSData[i].PC == NewPlayer )
		{
			Log("xLastManStandingGame: Already have LMSData for a PC");
			return;
		}
	}

	// Add new data entry for this actor.
	NewData.PC = NewPlayer;

	l = LMSData.Length + 1;
	LMSData.Length = l;
	LMSData[l-1] = NewData;
}

function Logout(Controller Exiting)
{
	super.Logout(Exiting);
	CheckMaxLives(none);
}

function Bot SpawnBot(optional string botName)
{
	local Bot b;

    b = Super.SpawnBot(botName);
    if (B!=None)
    	b.bAdrenalineEnabled = bAllowAdrenaline;

    return b;
}

function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	if ( (ViewTarget == None) )
		return false;
	if ( Controller(ViewTarget) != None )
	{
		if ( Controller(ViewTarget).Pawn == None )
			return false;

		return ( (Controller(ViewTarget).PlayerReplicationInfo != None) && (ViewTarget != Viewer)
				&& (!Controller(ViewTarget).PlayerReplicationInfo.bOutOfLives) );
	}
	return ( (Pawn(ViewTarget) != None) && Pawn(ViewTarget).IsPlayerPawn()
		&& (!Pawn(ViewTarget).PlayerReplicationInfo.bOutOfLives) );
}

function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo PRI,Winner;

    if ( MaxLives > 0 )
    {
        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
        	PRI = C.PlayerReplicationInfo;
            if ( (PRI!=None) && !PRI.bOnlySpectator && !PRI.bOutOfLives )
            {
            	if ( Winner!=None )
	            	return false;
                else
                	Winner = PRI;
            }
        }

		if (Winner==None)
         	EndGame(Scorer,"LastMan");
		else
         	EndGame(Winner,"LastMan");
        return true;
    }
    return false;
}

function GetServerDetails(out ServerResponseLine ServerState)
{
	Super.GetServerDetails(ServerState);
	AddServerDetail( ServerState, "CampThreshold", CampThreshold );
	AddServerDetail( ServerState, "CamperRewarnInterval", RecamperWarnInterval );
	AddServerDetail( ServerState, "HealthForKills",  bHealthForKill);
	AddServerDetail( ServerState, "AllowSuperWeapons", bAllowSuperWeapons );
	AddServerDetail( ServerState, "CamperAlarm", bCamperAlarm );
	AddServerDetail( ServerState, "AllowPickups", bAllowPickups );
	AddServerDetail( ServerState, "AllowAdrenaline", bAllowAdrenaline );
	AddServerDetail( ServerState, "FullAmmo",  bFullAmmo);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ( !Default.bCamperAlarm )
	{
		if ( InStr(PropertyName, "CampThreshold") != -1 )
			return false;
		if ( InStr(PropertyName, "ReCamperWarnInterval") != -1 )
			return false;
	}

	if ( PropertyName == "MaxLives" )
		return true;
	if ( PropertyName == "bWeaponStay" )
		return false;

	return Super.AcceptPlayInfoProperty(PropertyName);
}

static function FillPlayInfo(PlayInfo PI)
{
	Super.FillPlayInfo(PI);

	PI.AddSetting(default.RulesGroup, "bHealthForKill",      GetDisplayText("bHealthForKill"),       40, 1, "Check",         ,,     ,True);
	PI.AddSetting(default.RulesGroup, "bAllowSuperweapons",  GetDisplayText("bAllowSuperweapons"),   40, 1, "Check",         ,,     ,True);
	PI.AddSetting(default.RulesGroup, "bAllowPickups",       GetDisplayText("bAllowPickups"),        60, 1, "Check",         ,,     ,True);
	PI.AddSetting(default.RulesGroup, "bAllowAdrenaline",    GetDisplayText("bAllowAdrenaline"),     50, 1, "Check",         ,,     ,True);
	PI.AddSetting(default.RulesGroup, "bFullAmmo",           GetDisplayText("bFullAmmo"),            50, 1, "Check",         ,,     ,True);
	PI.AddSetting(default.RulesGroup, "bCamperAlarm",        GetDisplayText("bCamperAlarm"),         60, 1, "Check",         ,, True,True);
	PI.AddSetting(default.GameGroup, "CampThreshold",        GetDisplayText("CampThreshold"),        60, 1, "Check",         ,, True,True);
	PI.AddSetting(default.GameGroup, "ReCamperWarnInterval", GetDisplayText("ReCamperWarnInterval"), 60, 1,  "Text", "2;0:99",, True,True);
}

static function string GetDisplayText(string PropName)
{
	switch (PropName)
	{
		case "CampThreshold":			return default.LMSPropsDisplayText[0];
		case "ReCamperWarnInterval":	return default.LMSPropsDisplayText[1];
		case "bHealthForKill":			return default.LMSPropsDisplayText[2];
		case "bAllowSuperweapons":		return default.LMSPropsDisplayText[3];
		case "bCamperAlarm":			return default.LMSPropsDisplayText[4];
		case "bAllowPickups":			return default.LMSPropsDisplayText[5];
		case "bAllowAdrenaline":		return default.LMSPropsDisplayText[6];
		case "bFullAmmo":				return default.LMSPropsDisplayText[7];
	}

	return Super.GetDisplayText(PropName);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "CampThreshold":			return default.LMSPropDescText[0];
		case "ReCamperWarnInterval":	return default.LMSPropDescText[1];
		case "bHealthForKill":			return default.LMSPropDescText[2];
		case "bAllowSuperweapons":		return default.LMSPropDescText[3];
		case "bCamperAlarm":			return default.LMSPropDescText[4];
		case "bAllowPickups":			return default.LMSPropDescText[5];
		case "bAllowAdrenaline":		return default.LMSPropDescText[6];
		case "bFullAmmo":				return default.LMSPropDescText[7];
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     CampThreshold=600.000000
     ReCamperWarnInterval=10
     bCamperAlarm=True
     bFullAmmo=True
     LMSPropsDisplayText(0)="Camping Threshold"
     LMSPropsDisplayText(1)="Camper Warning Interval"
     LMSPropsDisplayText(2)="Gain Health For Kills"
     LMSPropsDisplayText(3)="Allow SuperWeapons"
     LMSPropsDisplayText(4)="Camper Alarm"
     LMSPropsDisplayText(5)="Allow Pickups"
     LMSPropsDisplayText(6)="Allow Adrenaline"
     LMSPropsDisplayText(7)="Full Ammo"
     LMSPropDescText(0)="Determines how long a player can stand in one spot before triggering a camper warning."
     LMSPropDescText(1)="Specifies how often the camper warning is played"
     LMSPropDescText(2)="If this option is enabled, a player gains health after killing another player."
     LMSPropDescText(3)="If checked, super weapons are included in the player load out."
     LMSPropDescText(4)="Enable this option to cause an alarm to be played if a player stands in one spot too long."
     LMSPropDescText(5)="If checked, pickups will be available in the map."
     LMSPropDescText(6)="If checked, adrenaline combos will be enabled."
     LMSPropDescText(7)="If checked, players start with max ammo for all weapons."
     DefaultMaxLives=3
     ScoreBoardType="BonusPack.ScoreBoardLMS"
     HUDType="BonusPack.HudLMS"
     MapListType="BonusPack.MapListLastManStanding"
     MaxLives=3
     TimeLimit=0
     MutatorClass="BonusPack.MutLastManStanding"
     BroadcastHandlerClass="BonusPack.LMSBroadcastHandler"
     GameName="Last Man Standing"
     Description="Each player starts with a limited number of lives.  The goal is to be the last player left when the smoke clears."
     ScreenShotName="UT2004Thumbnails.LMSShots"
     DecoTextName="BonusPack.LastManStandingGame"
     Acronym="LMS"
}
