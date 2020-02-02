//=============================================================================
// UnrealPlayer.
//=============================================================================
class UnrealPlayer extends PlayerController
	config(User);

var bool		bRising;
var bool		bLatecomer;		// entered multiplayer game after game started
var bool		bDisplayLoser;
var bool		bDisplayWinner;
var int			LastTaunt;
var float		LastWhispTime;

var() int		MultiKillLevel;
var() float		LastKillTime;

var float LastTauntAnimTime, LastAutoTauntTime;

var globalconfig string CustomizedAnnouncerPack; // OBSOLETE
var globalconfig string CustomStatusAnnouncerPack;
var globalconfig string CustomRewardAnnouncerPack;
var transient globalconfig array<string> RejoinChannels;	// Channels which player was a member of during last match

var globalconfig array<string> RecentServers;		//IPs of recently visited servers - always in order with RecentServers[0] being the most recently visited server
var globalconfig int MaxRecentServers;				//Max length of RecentServers list (0 = always show login menu)
var globalconfig bool bDontShowLoginMenu;			//Don't show the login menu unless forced by the server

var bool bReadyToStart;	//Ready to start the game - used to prevent player from clicking in until he's had a chance to see the login menu
var string LoginMenuClass;	//Set by replicated function called by DeathMatch to the name of the login menu
var bool bForceLoginMenu;	//Set by replicated function called by DeathMatch to whether it wants to force player to see login menu
var float LastKickWarningTime;

var string NetBotDebugString;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		NewClientPlayTakeHit, ClientDelayedAnnouncement, ClientDelayedAnnouncementNamed;
	reliable if ( Role == ROLE_Authority )
		PlayWinMessage, PlayStartupMessage, ClientSendStats, ClientSendSprees, ClientSendMultiKills, ClientSendCombos, ClientSendWeapon,
		ClientSendVehicle, ClientReceiveLoginMenu, ClientReceiveBotDebugString;

	reliable if ( Role < ROLE_Authority )
		ServerDropFlag, ServerTaunt, ServerPlayVehicleHorn, ServerShowPathToBase, ServerUpdateStats, ServerUpdateStatArrays, ServerGetNextWeaponStats,
		ServerGetNextVehicleStats, ServerSetReadyToStart, ServerSendBotDebugString;
}

// Local stats related functions

function ServerUpdateStats(TeamPlayerReplicationInfo PRI)
{
	ClientSendStats(PRI,PRI.GoalsScored,PRI.bFirstBlood, PRI.kills,PRI.suicides,PRI.FlagTouches,PRI.FlagReturns,PRI.FlakCount,PRI.ComboCount,PRI.HeadCount,PRI.RanOverCount,PRI.DaredevilPoints);
}

function ServerUpdateStatArrays(TeamPlayerReplicationInfo PRI)
{
	ClientSendSprees(PRI,PRI.Spree[0],PRI.Spree[1],PRI.Spree[2],PRI.Spree[3],PRI.Spree[4],PRI.Spree[5]);
	ClientSendMultiKills(PRI,PRI.MultiKills[0],PRI.MultiKills[1],PRI.MultiKills[2],PRI.MultiKills[3],PRI.MultiKills[4],PRI.MultiKills[5],PRI.MultiKills[6]);
	ClientSendCombos(PRI,PRI.Combos[0],PRI.Combos[1],PRI.Combos[2],PRI.Combos[3],PRI.Combos[4]);
}

function ServerGetNextWeaponStats(TeamPlayerReplicationInfo PRI, int i)
{
	if ( i >= PRI.WeaponStatsArray.Length )
	{
		ServerGetNextVehicleStats(PRI, 0);
		return;
	}

	ClientSendWeapon(PRI, PRI.WeaponStatsArray[i].WeaponClass, PRI.WeaponStatsArray[i].kills, PRI.WeaponStatsArray[i].deaths,PRI.WeaponStatsArray[i].deathsholding,i);
}

function ServerGetNextVehicleStats(TeamPlayerReplicationInfo PRI, int i)
{
	if (i >= PRI.VehicleStatsArray.Length)
		return;

	ClientSendVehicle(PRI, PRI.VehicleStatsArray[i].VehicleClass, PRI.VehicleStatsArray[i].Kills, PRI.VehicleStatsArray[i].Deaths, PRI.VehicleStatsArray[i].DeathsDriving, i);
}

simulated function ClientSendWeapon(TeamPlayerReplicationInfo PRI, class<Weapon> W, int kills, int deaths, int deathsholding, int i)
{
	PRI.UpdateWeaponStats(PRI,W,Kills,Deaths,DeathsHolding);
	ServerGetNextWeaponStats(PRI,i+1);
}

simulated function ClientSendVehicle(TeamPlayerReplicationInfo PRI, class<Vehicle> V, int Kills, int Deaths, int DeathsDriving, int i)
{
	PRI.UpdateVehicleStats(PRI, V, Kills, Deaths, DeathsDriving);
	ServerGetNextVehicleStats(PRI, i+1);
}

simulated function ClientSendSprees(TeamPlayerReplicationInfo PRI,byte Spree0,byte Spree1,byte Spree2,byte Spree3,byte Spree4,byte Spree5)
{
	PRI.Spree[0] = Spree0;
	PRI.Spree[1] = Spree1;
	PRI.Spree[2] = Spree2;
	PRI.Spree[3] = Spree3;
	PRI.Spree[4] = Spree4;
	PRI.Spree[5] = Spree5;
}

simulated function ClientSendMultiKills(TeamPlayerReplicationInfo PRI,
								byte MultiKills0, byte MultiKills1, byte MultiKills2, byte MultiKills3, byte MultiKills4, byte MultiKills5, byte MultiKills6)
{
	PRI.MultiKills[0] = MultiKills0;
	PRI.MultiKills[1] = MultiKills1;
	PRI.MultiKills[2] = MultiKills2;
	PRI.MultiKills[3] = MultiKills3;
	PRI.MultiKills[4] = MultiKills4;
	PRI.MultiKills[5] = MultiKills5;
	PRI.MultiKills[6] = MultiKills6;
}

simulated function ClientSendCombos(TeamPlayerReplicationInfo PRI,byte Combos0, byte Combos1, byte Combos2, byte Combos3, byte Combos4)
{
	PRI.Combos[0] = Combos0;
	PRI.Combos[1] = Combos1;
	PRI.Combos[2] = Combos2;
	PRI.Combos[3] = Combos3;
	PRI.Combos[4] = Combos4;

	ServerGetNextWeaponStats(PRI,0);
}

simulated function ClientSendStats(TeamPlayerReplicationInfo PRI, int newgoals, bool bNewFirstBlood, int newkills, int newsuicides, int newFlagTouches, int newFlagReturns, int newFlakCount, int newComboCount, int newHeadCount, int newRanOverCount, int newDaredevilPoints)
{
	PRI.GoalsScored = newGoals;
	PRI.bFirstBlood = bNewFirstBlood;
	PRI.Kills = NewKills;
	PRI.Suicides = NewSuicides;
	PRI.FlagTouches = NewFlagTouches;
	PRI.FlagReturns = NewFlagReturns;
	PRI.FlakCount = NewFlakCount;
	PRI.ComboCount = NewComboCount;
	PRI.HeadCount = NewHeadCount;
	PRI.RanOverCount = NewRanOverCount;
	PRI.DaredevilPoints = NewDaredevilPoints;

	ServerUpdateStatArrays(PRI);
}

simulated event PostBeginPlay()
{
	local class<AnnouncerVoice> VoiceClass;

	Super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		VoiceClass = class<AnnouncerVoice>(DynamicLoadObject(CustomStatusAnnouncerPack,class'Class'));
		StatusAnnouncer = Spawn(VoiceClass);
		VoiceClass = class<AnnouncerVoice>(DynamicLoadObject(CustomRewardAnnouncerPack,class'Class'));
		RewardAnnouncer = Spawn(VoiceClass);
		PrecacheAnnouncements();
	}
}

function AwardAdrenaline(float amount)
{
	if ( bAdrenalineEnabled )
	{
		if ( (Adrenaline < AdrenalineMax) && (Adrenaline+amount >= AdrenalineMax) && ((Pawn == None) || !Pawn.InCurrentCombo()) )
			ClientDelayedAnnouncementNamed('Adrenalin',15);
		Super.AwardAdrenaline(Amount);
	}
}

function ClientDelayedAnnouncementNamed(name Announcement, byte Delay)
{
	local AnnounceAdrenaline A;

	A = spawn(class'AnnounceAdrenaline', self);
	A.Announcement = Announcement;
	A.settimer(0.1*delay,false);
}

// OBSOLETE
function ClientDelayedAnnouncement(sound AnnouncementSound, byte Delay)
{
	local AnnounceAdrenaline A;

	A = spawn(class'AnnounceAdrenaline', self);
	A.AnnounceSound = AnnouncementSound;
	A.settimer(0.1*delay,false);
}

function LogMultiKills(float Reward, bool bEnemyKill)
{
	local int BoundedLevel;

	if ( bEnemyKill && (Level.TimeSeconds - LastKillTime < 4) )
	{
		AwardAdrenaline( Reward );
		if ( TeamPlayerReplicationInfo(PlayerReplicationInfo) != None )
		{
			BoundedLevel = Min(MultiKillLevel,6);
			TeamPlayerReplicationInfo(PlayerReplicationInfo).MultiKills[BoundedLevel] += 1;
			if ( (MultiKillLevel > 0) && (TeamPlayerReplicationInfo(PlayerReplicationInfo).MultiKills[BoundedLevel-1] > 0) )
				TeamPlayerReplicationInfo(PlayerReplicationInfo).MultiKills[BoundedLevel-1] -= 1;
		}
		MultiKillLevel++;
		UnrealMPGameInfo(Level.Game).SpecialEvent(PlayerReplicationInfo,"multikill_"$MultiKillLevel);
	}
	else
		MultiKillLevel=0;

	if ( bEnemyKill )
		LastKillTime = Level.TimeSeconds;
}

exec function ShowAI()
{
	myHUD.ShowDebug();
	if ( UnrealPawn(ViewTarget) != None )
		UnrealPawn(ViewTarget).bSoakDebug = myHUD.bShowDebugInfo;
}

function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
}

function bool AutoTaunt()
{
	if (!bAutoTaunt || LastAutoTauntTime > Level.TimeSeconds - 2)
		return false;

	LastAutoTauntTime = Level.TimeSeconds;
	return true;
}

function bool DontReuseTaunt(int T)
{
	if ( T == LastTaunt )
		return true;

	if( T == Level.LastTaunt[0] || T == Level.LastTaunt[1] )
		return true;

	LastTaunt = T;

	Level.LastTaunt[1] = Level.LastTaunt[0];
	Level.LastTaunt[0] = T;

	return false;
}

exec function SoakBots()
{
	local Bot B;

	log("Start Soaking");
	UnrealMPGameInfo(Level.Game).bSoaking = true;
	ForEach DynamicActors(class'Bot',B)
		B.bSoaking = true;
}

function SoakPause(Pawn P)
{
	log("Soak pause by "$P);
	SetViewTarget(P);
	SetPause(true);
	bBehindView = true;
	myHud.bShowDebugInfo = true;
	if ( UnrealPawn(P) != None )
		UnrealPawn(P).bSoakDebug = true;
}

exec function BasePath(byte num)
{
	if (PlayerReplicationInfo.Team == None )
		return;
	ServerShowPathToBase(num);
}

function ServerShowPathToBase(int TeamNum)
{
	if ( (Level.NetMode != NM_Standalone) && (Level.TimeSeconds - LastWhispTime < 0.5) )
		return;
	LastWhispTime = Level.TimeSeconds;

	if ( (Pawn == None) || !Level.Game.bTeamGame || !UnrealMPGameInfo(Level.Game).CanShowPathTo(Self, TeamNum) )
		return;

	UnrealMPGameInfo(Level.Game).ShowPathTo(Self, TeamNum);
}

function byte GetMessageIndex(name PhraseName)
{
	if ( PlayerReplicationInfo.VoiceType == None )
		return 0;
	return PlayerReplicationInfo.Voicetype.Static.GetMessageIndex(PhraseName);
}

exec function RandomTaunt()
{
	local int tauntNum;

	if(Pawn == None)
		return;

	// First 4 taunts are 'order' anims. Don't pick them.
	tauntNum = Rand(Pawn.TauntAnims.Length - 4);
	Taunt(Pawn.TauntAnims[4 + tauntNum]);
}

exec function Taunt( name Sequence )
{
	if( Vehicle(Pawn) != None && Sequence == 'gesture_point' )
	{
		PlayVehicleHorn(0);
		return;
	}

	if ( (Pawn != None) && (Pawn.Health > 0) && (Level.TimeSeconds - LastTauntAnimTime > 0.5) && Pawn.FindValidTaunt(Sequence) )
	{
		ServerTaunt(Sequence);
        LastTauntAnimTime = Level.TimeSeconds;
	}
}

function ServerTaunt(name AnimName )
{
	if ( (Pawn != None) && (Pawn.Health > 0) && (Level.TimeSeconds - LastTauntAnimTime > 0.3) && Pawn.FindValidTaunt(AnimName) )
	{
		Pawn.SetAnimAction(AnimName);
        LastTauntAnimTime = Level.TimeSeconds;
	}
}

exec function PlayVehicleHorn( int HornIndex )
{
	local Vehicle V;

	V = Vehicle(Pawn);
	if ( (V != None) && (V.Health > 0) && (Level.TimeSeconds - LastTauntAnimTime > 0.3)  )
	{
		ServerPlayVehicleHorn(HornIndex);
		LastTauntAnimTime = Level.TimeSeconds;
	}
}

function ServerPlayVehicleHorn( int HornIndex )
{
	local Vehicle V;

	V = Vehicle(Pawn);
	if ( (V != None) && (V.Health > 0) && (Level.TimeSeconds - LastTauntAnimTime > 0.3)  )
	{
		V.ServerPlayHorn(HornIndex);
		LastTauntAnimTime = Level.TimeSeconds;
	}
}

simulated function PlayStatusAnnouncement(name AName, byte AnnouncementLevel, optional bool bForce)
{
	local float Atten;

	if ( AnnouncementLevel > AnnouncerLevel )
	{
		if ( AnnouncementLevel == 2 )
		{
			Atten = FClamp(0.1 + float(AnnouncerVolume)*0.225,0.2,1.0);
			ClientPlaySound(Sound'GameSounds.DDAverted',true,Atten,SLOT_Talk);
		}
		else if ( AnnouncementLevel == 1 )
			PlayBeepSound();
		return;
	}
	Super.PlayStatusAnnouncement(AName, AnnouncementLevel, bForce);
}

simulated function PlayRewardAnnouncement(name AName, byte AnnouncementLevel, optional bool bForce)
{
	local float Atten;

	if ( AnnouncementLevel > AnnouncerLevel )
	{
		if ( AnnouncementLevel == 2 )
		{
			Atten = FClamp(0.1 + float(AnnouncerVolume)*0.225,0.2,1.0);
			ClientPlaySound(Sound'GameSounds.DDAverted',true,Atten,SLOT_Talk);
		}
		else if ( AnnouncementLevel == 1 )
			PlayBeepSound();
		return;
	}
	Super.PlayRewardAnnouncement(AName, AnnouncementLevel, bForce);
}

simulated function PlayAnnouncement(sound ASound, byte AnnouncementLevel, optional bool bForce)
{
	local float Atten;

	if ( AnnouncementLevel > AnnouncerLevel )
	{
		if ( AnnouncementLevel == 2 )
		{
			Atten = FClamp(0.1 + float(AnnouncerVolume)*0.225,0.2,1.0);
			ClientPlaySound(Sound'GameSounds.DDAverted',true,Atten,SLOT_Talk);
		}
		else if ( AnnouncementLevel == 1 )
			PlayBeepSound();
		return;
	}
	Super.PlayAnnouncement(ASound,AnnouncementLevel,bForce);
}


event KickWarning()
{
	if ( Level.TimeSeconds - LastKickWarningTime > 0.5 )
	{
		ReceiveLocalizedMessage( class'IdleKickWarningMessage', 0, None, None, self );
		LastKickWarningTime = Level.TimeSeconds;
	}
}

function PlayStartupMessage(byte StartupStage)
{
	ReceiveLocalizedMessage( class'StartupMessage', StartupStage, PlayerReplicationInfo );
}

simulated event PostNetReceive()
{
	Super.PostNetReceive();

	if ( ChatManager != None )
		ChatManager.PlayerOwner = Self;
}

simulated function InitInputSystem()
{
	Super.InitInputSystem();

	if (LoginMenuClass != "")
		ShowLoginMenu();

	bReadyToStart = true;
	ServerSetReadyToStart();
}

function ServerSetReadyToStart()
{
	bReadyToStart = true;
}

simulated function ClientReceiveLoginMenu(string MenuClass, bool bForce)
{
	LoginMenuClass = MenuClass;
	bForceLoginMenu = bForce;
}

simulated function ShowLoginMenu()
{
	local int x;
	local string NetworkAddress;

	if (Level.NetMode != NM_Client || (Pawn != None && Pawn.Health > 0) || (bDontShowLoginMenu && !bForceLoginMenu))
		return;

	//Show login menu if first time in this server or if server is forcing it to always be displayed
	if (!bForceLoginMenu)
	{
		NetworkAddress = GetServerNetworkAddress();
		if (NetworkAddress == "")
			return;
		for (x = 0; x < RecentServers.length; x++)
			if (NetworkAddress ~= RecentServers[x])
			{
				RecentServers.Insert(0, 1);
				RecentServers[0] = NetworkAddress;
				RecentServers.Remove(x+1, 1);
				SaveConfig();
				return;
			}
		RecentServers.Insert(0, 1);
		RecentServers[0] = NetworkAddress;
		if (RecentServers.length > MaxRecentServers)
			RecentServers.length = MaxRecentServers;	//kill oldest entries

		SaveConfig();
	}
	ClientReplaceMenu(LoginMenuClass);
}

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local int iDam;
	local vector AttackLoc;

	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);

	DamageShake(Damage);
	iDam = Clamp(Damage,0,250);
	if ( InstigatedBy != None )
		AttackLoc = InstigatedBy.Location;

	NewClientPlayTakeHit(AttackLoc, hitLocation - Pawn.Location, iDam, damageType);
}

function NewClientPlayTakeHit(vector AttackLoc, vector HitLoc, byte Damage, class<DamageType> damageType)
{
	local vector HitDir;

	if ( (myHUD != None) && ((Damage > 0) || bGodMode) )
	{
		if ( AttackLoc != vect(0,0,0) )
			HitDir = Normal(AttackLoc - Pawn.Location);
		else
			HitDir = Normal(HitLoc);
		myHUD.DisplayHit(HitDir, Damage, DamageType);
	}
	HitLoc += Pawn.Location;
    if( bEnableDamageForceFeedback )        // jdf
        ClientPlayForceFeedback("Damage");  // jdf
    if ( Level.NetMode == NM_Client )
		Pawn.PlayTakeHit(HitLoc, Damage, damageType);
}

function ClientPlayTakeHit(vector HitLoc, byte Damage, class<DamageType> damageType)
{
	NewClientPlayTakeHit(Location, HitLoc, Damage, DamageType);
}

function PlayWinMessage(bool bWinner)
{
	if ( bWinner )
		bDisplayWinner = true;
	else
		bDisplayLoser = true;
}

auto state PlayerWaiting
{
    exec function Fire(optional float F)
    {
        LoadPlayers();
        if ( !bForcePrecache && (Level.TimeSeconds > 0.2) && bReadyToStart )
		ServerReStartPlayer();
    }

    function bool CanRestartPlayer()
    {
    	return ((bReadyToStart || (DeathMatch(Level.Game) != None && DeathMatch(Level.Game).bForceRespawn)) && Super.CanRestartPlayer());
    }
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise;

	function bool NotifyLanded(vector HitNormal)
	{
		if (DoubleClickDir == DCLICK_Active)
		{
			DoubleClickDir = DCLICK_Done;
			ClearDoubleClick();
			Pawn.Velocity *= Vect(0.1,0.1,1.0);
		}
		else
			DoubleClickDir = DCLICK_None;

		if ( Global.NotifyLanded(HitNormal) )
			return true;

		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( UnrealPawn(Pawn).Dodge(DoubleClickMove) )
				DoubleClickDir = DCLICK_Active;
		}

		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
	}
}

state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

	exec function Fire( optional float F )
	{
		if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}
		if ( PlayerReplicationInfo.bOutOfLives )
			ServerSpectate();
		else
			Super.Fire(F);
	}

Begin:
    Sleep(3.0);
	if ( (ViewTarget == None) || (ViewTarget == self) || (VSize(ViewTarget.Velocity) < 1.0) )
	{
		Sleep(1.0);
		if ( myHUD != None )
			myHUD.bShowScoreBoard = true;
	}
	else
		Goto('Begin');
}

exec function DropFlag()
{
	ServerDropFlag();
}

function ServerDropFlag()
{
	if (PlayerReplicationInfo==None || PlayerReplicationInfo.HasFlag==None)
    	return;

    PlayerReplicationInfo.HasFlag.Drop(Pawn.Velocity * 0.5);
}

function ShowMidGameMenu(bool bPause)
{
	// Pause if not already
	if(Level.Pauser == None)
		SetPause(true);

	if ( Level.NetMode != NM_DedicatedServer )
		StopForceFeedback();  // jdf - no way to pause feedback

	// Open menu

	if (bDemoOwner)
		ClientopenMenu(DemoMenuClass);

	else if ( LoginMenuClass != "" )
		ClientOpenMenu(LoginMenuClass);

	else ClientOpenMenu(MidGameMenuClass);
}

simulated function string GetCustomStatusAnnouncerClass()
{
	return CustomStatusAnnouncerPack;
}

simulated function SetCustomStatusAnnouncerClass(string NewAnnouncerClass)
{
	CustomStatusAnnouncerPack = NewAnnouncerClass;
}

simulated function string GetCustomRewardAnnouncerClass()
{
	return CustomRewardAnnouncerPack;
}

simulated function SetCustomRewardAnnouncerClass(string NewAnnouncerClass)
{
	CustomRewardAnnouncerPack = NewAnnouncerClass;
}

simulated function bool NeedNetNotify()
{
	return Super.NeedNetNotify() || ChatManager == None;
}

// =====================================================================================================================
// =====================================================================================================================
//  Voice Chat
// =====================================================================================================================
// =====================================================================================================================
simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if ( Level.NetMode == NM_Client || Level.NetMode == NM_ListenServer )
		bVoiceChatEnabled = bool(ConsoleCommand("get ini:Engine.Engine.AudioDevice UseVoIP"));
}

simulated function AutoJoinVoiceChat()
{
	local int i, j, cnt;
	local string DefaultChannel;

	if ( !bVoiceChatEnabled || (Level.NetMode != NM_Client && Level.NetMode != NM_ListenServer) )
		return;

	if ( VoiceReplicationInfo == None )
	{
		log(Name@"AutoJoinVoiceChat() do not have VRI yet!",'VoiceChat');
		return;
	}

	cnt = VoiceReplicationInfo.GetPublicChannelCount(True);
	for ( i = 0; i < cnt; i++ )
	{
		if ( bool(AutoJoinMask & (1 << i)) )
		{
			Join(VoiceReplicationInfo.PublicChannelNames[i],"");
			for ( j = RejoinChannels.Length - 1; j >= 0; j-- )
				if ( RejoinChannels[j] == VoiceReplicationInfo.PublicChannelNames[i] )
					RejoinChannels.Remove(j,1);
		}
	}

	// Rejoin any channels we were members of during the last match
	for (i = 0; i < RejoinChannels.Length; i++)
		Join(RejoinChannels[i],"");

	// If we were speaking on a particular chatroom last match, re-activate the same room, if possible
	if ( LastActiveChannel != "" )
		Speak(LastActiveChannel);

	else if ( ActiveRoom == None && bEnableInitialChatRoom )
	{
		DefaultChannel = GetDefaultActiveChannel();
		if ( DefaultChannel != "" )
			Speak(DefaultChannel);
	}

	if (RejoinChannels.Length > 0 || LastActiveChannel != "")
	{
		RejoinChannels.Length = 0;
		LastActiveChannel = "";
		SaveConfig();
	}
}

function ClientGameEnded()
{
	local int i;
	local array<VoiceChatRoom> Channels;

	if (bVoiceChatEnabled && PlayerReplicationInfo != None && VoiceReplicationInfo != None)
	{
		log(Name@PlayerReplicationInfo.PlayerName@"ClientGameEnded()",'VoiceChat');
		Channels = VoiceReplicationInfo.GetChannels();

	// Get a list of all channels currently a member of, and store them for the next match.
		for (i = 0; i < Channels.Length; i++)
		{
			if ( Channels[i] != None && Channels[i].IsMember(PlayerReplicationInfo, True) )
				RejoinChannels[RejoinChannels.Length] = Channels[i].GetTitle();
		}

		if ( ActiveRoom != None )
			LastActiveChannel = ActiveRoom.GetTitle();
	}

	if (RejoinChannels.Length > 0 || LastActiveChannel != "")
		SaveConfig();

	Super.ClientGameEnded();
}

function ServerChatDebug()
{
	local BroadcastHandler B;

	for ( B = Level.Game.BroadcastHandler; B != None; B = B.NextBroadcastHandler )
		if ( UnrealChatHandler(B) != None )
			UnrealChatHandler(B).DoChatDebug();
}

//debug bot when a net client
exec function NetDebugBot()
{
	if (Level.NetMode == NM_Client && ViewTarget != Pawn)
		ServerSendBotDebugString();
}

function ServerSendBotDebugString()
{
	if (Bot(RealViewTarget) != None)
		ClientReceiveBotDebugString("(ORDERS: "$Bot(RealViewTarget).Squad.GetOrders()$") "$Bot(RealViewTarget).GoalString);
	else
		ClientReceiveBotDebugString("");
}

simulated function ClientReceiveBotDebugString(string DebugString)
{
	NetBotDebugString = DebugString;
	if (NetBotDebugString != "")
		ServerSendBotDebugString();
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas, YL, YPos);

	if (NetBotDebugString != "")
	{
		Canvas.SetDrawColor(255, 255, 255);
		Canvas.DrawText("Bot ViewTarget's Goal: "$NetBotDebugString);
		YPos += YL;
		Canvas.SetPos(4, YPos);
	}
}

defaultproperties
{
     CustomStatusAnnouncerPack="UnrealGame.FemaleAnnouncer"
     RecentServers(0)="81.30.148.30:33000"
     RecentServers(1)="81.30.148.29:30900"
     RecentServers(2)="217.160.185.185:7778"
     RecentServers(3)="145.239.149.160:7778"
     RecentServers(4)="146.0.42.104:7877"
     RecentServers(5)="81.30.148.30:32400"
     RecentServers(6)="134.255.253.90:62000"
     RecentServers(7)="134.255.253.90:16000"
     RecentServers(8)="134.255.253.93:8137"
     RecentServers(9)="81.30.148.29:32500"
     RecentServers(10)="31.186.251.20:7777"
     MaxRecentServers=25
     LastKickWarningTime=-1000.000000
     PlayerChatType="UnrealGame.UnrealPlayerChatManager"
     FovAngle=85.000000
     PlayerReplicationInfoClass=Class'UnrealGame.TeamPlayerReplicationInfo'
}
