// ====================================================================
//  Class: BonusPack.xMutantGame
//
//  Main 'Mutant' game type tab. Basic idea:
//  - When there is no existing mutant, first blood mutates.
//  - Everyone else must hunt down the mutant - you can't kill each other. You get a radar to find them.
//  - If you kill the mutant, you mutate.
//  - Mutant gets invisibility, agility and regen based on number of other players.
//
//  Written by James Golding
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

#exec OBJ LOAD FILE=XGameShaders.utx
#exec OBJ LOAD FILE=MutantSkins.utx
#exec OBJ LOAD FILE=InterfaceContent.utx

class xMutantGame extends xDeathMatch;

// Settings
var()	Material				MutantMaterial;

// Internal
var		Controller				CurrentMutant;
var		Controller				CurrentBottomFeeder;
var		float					RegenTimeCarryOver;

var()	float					DegenInterval;
//var()	InterpCurve				RegenRate; // Health mutant gets each second as a function of other players
var()	int						MultiKillBonus; // Additional points for each level of multi-kill
var()	int						BaseKillScore; // Basic number of points for a kill
var()	int						MutantSuicidePenalty; // When the mutant suicides, number of points they lose
var()	int						MaxMultiKillScore; // Cap on multi-kill score
var()	int 					MutantKillHealthBonus; // Health the mutant gets for killing someone
var()	int						BottomFeederKillScore; // Points the mutant gets for killing the bottom feeder

var()	config bool				bEnableBottomFeeder;

var localized string	MutPropText;
var localized string	MutDescText;

function bool WantsPickups(bot B)
{
	return (B != CurrentMutant);
}

static function PrecacheGameTextures(LevelInfo myLevel)
{
	Super.PrecacheGameTextures(myLevel);

	myLevel.AddPrecacheMaterial(class'HUDMutant'.default.BottomFeederIcon);
	myLevel.AddPrecacheMaterial(Material'MutantSkins.Cellular_0');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.TeamBeaconT');
	myLevel.AddPrecacheMaterial(Material'InterfaceContent.BorderBoxD');
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( !bRewardSounds )
	{
		V.PrecacheSound('you_have_mutated');
		V.PrecacheSound('new_mutant');
		V.PrecacheSound('bottom_feeder');
	}
}

/* OBSOLETE UpdateAnnouncements() - preload all announcer phrases used by this actor */
simulated function UpdateAnnouncements() {}

event Tick(float deltaSeconds)
{
	local xMutantPawn p;

	Super.Tick(deltaSeconds);

	if(CurrentMutant == None)
		return;

	p = xMutantPawn(CurrentMutant.Pawn);

	// Regenrate the Mutant
	RegenTimeCarryOver += deltaSeconds;
	while(RegenTimeCarryOver > DegenInterval)
	{
		p.MutantDamage();

		RegenTimeCarryOver -= DegenInterval;
	}
}

// Parse options for this game type
event InitGame( string Options, out string Error )
{
	local string InOpt;

	Super.InitGame(Options, Error);

	// Should we enable bottom feeders
	InOpt = ParseOption( Options, "BottomFeeder");
	if(InOpt != "")
	{
        log("BottomFeeder: "$bool(InOpt));
		bEnableBottomFeeder=bool(InOpt);
	}
}

function int ComparePRI(PlayerReplicationInfo PRI1, PlayerReplicationInfo PRI2)
{
	// Highest score is best
	if(PRI1.Score > PRI2.Score)
		return 1;
	else if(PRI1.Score < PRI2.Score)
		return -1;

	// Least deaths is best
	if(PRI1.Deaths > PRI2.Deaths)
		return -1;
	else if(PRI1.Deaths < PRI2.Deaths)
		return 1;

	// Most recent start time is best
	if(PRI1.StartTime > PRI2.StartTime)
		return 1;
	else if(PRI1.StartTime < PRI2.StartTime)
		return -1;

	// Just can't decide...
	return 0;
}

// When someone scores, update the list of 'bottom feeders'
function UpdateBottomFeeder()
{
	local int i;
	local PlayerReplicationInfo myPRI;
	local Controller oldBF;
	local PlayerController Player;

	oldBF = CurrentBottomFeeder;
	CurrentBottomFeeder = None;

	if(!bEnableBottomFeeder)
		return;

	for(i=0; i<GameReplicationInfo.PRIArray.Length; i++)
	{
		myPRI = GameReplicationInfo.PRIArray[i];

		// Spectators/mutant can't be BF
		if( myPRI.bOnlySpectator || (CurrentMutant != None && myPRI == CurrentMutant.PlayerReplicationInfo) )
			continue;

		if(CurrentBottomFeeder == None)
			CurrentBottomFeeder = Controller(myPRI.Owner);
		else
		{
			// Compare current BF with this PRI. If its worse, make it the new BF.
			if( ComparePRI(CurrentBottomFeeder.PlayerReplicationInfo, myPRI) > 0 )
				CurrentBottomFeeder = Controller(myPRI.Owner);
		}
	}

	// Set the BF PRI into the Mutant GRI
	if(CurrentBottomFeeder != None)
		MutantGameReplicationInfo(GameReplicationInfo).BottomFeederPRI = CurrentBottomFeeder.PlayerReplicationInfo;
	else
		MutantGameReplicationInfo(GameReplicationInfo).BottomFeederPRI = None;

	// Dont send messages once game is over.
	if( IsInState('MatchOver') )
		return;

	// If its a new bottom feeder - send messages to new and old
	if(CurrentBottomFeeder != oldBF)
	{
		// 'No Longer Bottom Feeder' message
		if(oldBF != None)
		{
			Player = PlayerController(oldBF);
			if(Player != None)
				Player.ReceiveLocalizedMessage(class'BonusPack.MutantMessage', 4);
		}

		// 'New Bottom Feeder' message
		if(CurrentBottomFeeder != None)
		{
			Player = PlayerController(CurrentBottomFeeder);
			if(Player != None)
				Player.ReceiveLocalizedMessage(class'BonusPack.MutantMessage', 3);
		}
	}

	//Log( "FEEDER: "$CurrentBottomFeeder.PlayerReplicationInfo.PlayerName );
}

function bool IsBottomFeeder(Controller C)
{
	if(C == None)
		return false;

	if(C == CurrentBottomFeeder)
		return true;

	return false;
}

// Send message stating current Mutant situation to single client.
function SendCurrentMutantMessage(PlayerController Player)
{
	// Dont send messages once game is over.
	if( IsInState('MatchOver') )
		return;

	if(CurrentMutant == None)
		Player.ReceiveLocalizedMessage(class'BonusPack.MutantMessage', 2);
	else
	{
		if(Player == CurrentMutant)
			Player.ReceiveLocalizedMessage(class'BonusPack.MutantMessage', 0);
		else
			Player.ReceiveLocalizedMessage(class'BonusPack.MutantMessage', 1, CurrentMutant.PlayerReplicationInfo);
	}
}

// Send message stating current Mutant situation to all clients.
function SendAllCurrentMutantMessage()
{
    local Controller P;
	local PlayerController Player;

	// Dont send messages once game is over.
	if( IsInState('MatchOver') )
		return;

	for(P = Level.ControllerList; P != None; P = P.nextController)
	{
		Player = PlayerController(P);

		if (Player != None)
		{
			SendCurrentMutantMessage(Player);
		}
	}
}


function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;
	local float Score;

	Score = Super.RatePlayerStart(N,Team,Player);

	// If there is a Mutant around - pick a start point a distance away.
	if(Player != None && CurrentMutant != None)
	{
		P = PlayerStart(N);
		if ( P != None )
			Score += 10 * VSize(P.Location - CurrentMutant.Pawn.Location);
	}

	return Score;
}

function RandomTeleportMutant(Controller Pred, xPawn PredPawn)
{
	local NavigationPoint N;
	local PlayerController pcPred;

	N = FindPlayerStart(Pred);

	if(N == None)
	{
		Log("Could not teleport Mutant");
		return;
	}

	Pred.SetLocation(N.Location);
	Pred.SetRotation(N.Rotation);

	PredPawn.SetLocation(N.Location);
	PredPawn.SetRotation(N.Rotation);
	PredPawn.Velocity = vect(0,0,0);

	Pred.ClientSetLocation(N.Location, N.Rotation);

	// Flash clients screen purple
	pcPred = PlayerController(Pred);
	if(pcPred != None)
		pcPred.ClientFlash(0.1, vect(700,0,700));
}


function EquipMutant(xPawn PredPawn)
{
	local Inventory Inv;

	PredPawn.CreateInventory("XWeapons.BioRifle");
	PredPawn.CreateInventory("XWeapons.FlakCannon");
	PredPawn.CreateInventory("XWeapons.LinkGun");
	PredPawn.CreateInventory("XWeapons.Minigun");
	PredPawn.CreateInventory("XWeapons.RocketLauncher");
	PredPawn.CreateInventory("XWeapons.ShockRifle");
	PredPawn.CreateInventory("XWeapons.SniperRifle");

	for( Inv=PredPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Weapon(Inv) != None )
			Weapon(Inv).SuperMaxOutAmmo();
}

function SetMutant(Controller Pred, xPawn PredPawn, bool isPred)
{
    local Inventory Inv;
	local UnrealPlayer uPred;

	if(isPred)
	{
		// Invisibility
		PredPawn.SetInvisibility(2000000.0);

		if(!PredPawn.IsA('xMutantPawn'))
			Log("NON MUTANT PAWN");

		// This will trigger glowy effect
		//xMutantPawn(PredPawn).bMutantEffect = true;

		// Agility combo
		PredPawn.AirControl = PredPawn.Default.AirControl * 1.5;
		PredPawn.GroundSpeed = PredPawn.Default.GroundSpeed * 1.5;
		PredPawn.WaterSpeed = PredPawn.Default.WaterSpeed * 1.5;
		PredPawn.AirSpeed = PredPawn.Default.AirSpeed * 1.5;
		PredPawn.JumpZ = PredPawn.Default.JumpZ * 1.5;

		// Give the mutant something to start with.
		PredPawn.GiveHealth(150, 150);
		PredPawn.AddShieldStrength(100); 

		// Give the mutant weapons
		EquipMutant(PredPawn);

		// Dont let Mutant use or pickup Adrenaline.
		// Also, make sure they have at most 99 adrenaline, so they can't perform combos.
		Pred.bAdrenalineEnabled = false;
		Pred.Adrenaline = FMin(99, Pred.Adrenaline);

		// Teleport new Mutant to somewhere in the level.
		RandomTeleportMutant(Pred, PredPawn);

		// Triple jump
		//PredPawn.MaxMultiJump = 2;
		//PredPawn.MultiJumpBoost = 50;

		// Reset regen clock
		RegenTimeCarryOver = 0.0;

		// Set Berserk on
		if (PredPawn.Weapon != None)
			PredPawn.Weapon.StartBerserk();

		PredPawn.bBerserk = true;
	}
	else
	{
		// Turn invisible off
		PredPawn.SetInvisibility(0.0);

		// Turn off glowy effect
		//xMutantPawn(PredPawn).bMutantEffect = false;

		//PredPawn.InvisMaterial = class'xpawn'.default.InvisMaterial;

		// Turn off agility
	    Level.Game.SetPlayerDefaults(PredPawn);

		// Back to just double jump
		//PredPawn.MaxMultiJump = 1;
		//PredPawn.MultiJumpBoost = 25;

		// Re-enable adrenaline
		Pred.bAdrenalineEnabled = true;

		// Turn Berserk off
		for( Inv=PredPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			if (Inv.IsA('Weapon'))
				Weapon(Inv).StopBerserk();
		}

		PredPawn.bBerserk = false;
	}

	// Re-zero multi kill level whenever you transform
	uPred = UnrealPlayer(Pred);
	if(uPred != None)
		uPred.MultiKillLevel = 0;
}

function NotifyKilled(Controller Killer, Controller Other, Pawn OtherPawn)
{
	local xPawn xKiller, xOther;

	Super.NotifyKilled(Killer, Other, OtherPawn);

	// If no-one died - no nothing
	if(Other == None)
		return;

	// Get xPawns involved
	if(Other.Pawn != None)
		xOther = xPawn(Other.Pawn);

	if(Killer != None && Killer.Pawn != None)
		xKiller = xPawn(Killer.Pawn);

	// If there was no Mutant (ie were in FFA)
	if( CurrentMutant == None )
	{
		// As long as this wasn't a suicide, and the killer is still alive, make the killer the Mutant.
		if(Killer != None && Killer != Other && xKiller != None && xKiller.Health > 0)
		{
			CurrentMutant = Killer;
			MutantGameReplicationInfo(GameReplicationInfo).MutantPRI = CurrentMutant.PlayerReplicationInfo;
			SetMutant(Killer, xKiller, true);

			SendAllCurrentMutantMessage();
		}
	}
	// If it was the Mutant that was killed, decide what to do.
	else if( Other == CurrentMutant )
	{
		// If the Mutant killed themselves or suicided, enter FFA again
		if( Killer == None || Killer == Other )
		{
			CurrentMutant = None;
			MutantGameReplicationInfo(GameReplicationInfo).MutantPRI = None;
			SetMutant(Other, xOther, false);

			SendAllCurrentMutantMessage();
		}
		else if(xKiller != None && xKiller.Health > 0) // Make the killer the mutant - if they are still alive
		{
			SetMutant(Other, xOther, false);

			CurrentMutant = Killer;
			MutantGameReplicationInfo(GameReplicationInfo).MutantPRI = CurrentMutant.PlayerReplicationInfo;
			SetMutant(Killer, xKiller, true);

			SendAllCurrentMutantMessage();
		}
		else // Mutual kill - free for all
		{
			CurrentMutant = None;
			MutantGameReplicationInfo(GameReplicationInfo).MutantPRI = None;
			SetMutant(Other, xOther, false);

			SendAllCurrentMutantMessage();
		}
	}
	else
	{
		// If this the Mutant killing another player, give them back some health.
		if(Killer == CurrentMutant && Other.bIsPlayer)
		{
			xKiller.GiveHealth(MutantKillHealthBonus, 150);
		}
	}

	// Update list of bottom players when someone scores
	UpdateBottomFeeder();
}




// Don't let the Mutant pick up adrenaline, health or armor.
function bool PickupQuery( Pawn Other, Pickup item )
{
    local byte bAllowPickup;

	if(Other.Controller == CurrentMutant)
	{
		//if( item.IsA('AdrenalinePickup') || item.IsA('UDamagePack') )
		if( item.IsA('AdrenalinePickup') || item.IsA('UDamagePack') || item.IsA('TournamentHealth') || item.IsA('ShieldPickup') )
			return false;
	}

    if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
        return (bAllowPickup == 1);

    if ( Other.Inventory == None )
        return true;
    else
        return !Other.Inventory.HandlePickupQuery(Item);
}

// see if this score means the game ends
function CheckScore(PlayerReplicationInfo Scorer)
{
	if ( CheckMaxLives(Scorer) )
		return;

    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
        return;

    if ( (Scorer != None) && (bOverTime || (GoalScore > 0)) && (Scorer.Score >= GoalScore) )
        EndGame(Scorer,"fraglimit");
}

function ScoreKill(Controller Killer, Controller Other)
{
	local PlayerReplicationInfo OtherPRI;
	local UnrealPlayer uKiller;
	local int KillScore;

	// Check if we have used up all our lives
	OtherPRI = Other.PlayerReplicationInfo;
    if ( OtherPRI != None )
    {
        OtherPRI.NumLives++;
        if ( (MaxLives > 0) && (OtherPRI.NumLives >=MaxLives) )
            OtherPRI.bOutOfLives = true;
    }

	// Do suitable taunt!
	if ( bAllowTaunts && (Killer != None) && (Killer != Other) && Killer.AutoTaunt()
		&& (Killer.PlayerReplicationInfo != None) && (Killer.PlayerReplicationInfo.VoiceType != None) )
	{
		if( Killer.IsA('PlayerController') )
			Killer.SendMessage(OtherPRI, 'AUTOTAUNT', Killer.PlayerReplicationInfo.VoiceType.static.PickRandomTauntFor(Killer, false, false), 10, 'GLOBAL');
		else
			Killer.SendMessage(OtherPRI, 'AUTOTAUNT', Killer.PlayerReplicationInfo.VoiceType.static.PickRandomTauntFor(Killer, false, true), 10, 'GLOBAL');
	}

	// Score negative for suicide
    if( (killer == Other) || (killer == None) )
	{
		if ( OtherPRI != None )
		{
			if(Other == CurrentMutant)
				Other.PlayerReplicationInfo.Score -= MutantSuicidePenalty; // Mutant loses a third of their score if they suicide
			else
				Other.PlayerReplicationInfo.Score -= BaseKillScore; // Ordinary players lose normal kill amount
			Other.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			if (GameStats!=None)
				GameStats.ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
		}
	}
    else if ( killer.PlayerReplicationInfo != None )
	{
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		if(CurrentMutant != None) // Mutant present
		{
			if(Other == CurrentMutant) // Mutant was killed
			{
				if ( OtherPRI != None )
					KillScore = 0.5 * (OtherPRI.Score - Killer.PlayerReplicationInfo.Score);
				KillScore = Max(KillScore, BaseKillScore);

				//Log("KILLED MUTANT: "$KillScore);

				Killer.PlayerReplicationInfo.Score += KillScore;

				if (GameStats!=None)
					GameStats.ScoreEvent(Killer.PlayerReplicationInfo,1,"frag");
			}
			else if(Killer == CurrentMutant) // Mutant killed someone
			{
				uKiller = UnrealPlayer(Killer);

				if(uKiller != None)
				{
					//Log("MUTANT KILL: "$BaseKillScore + (uKiller.MultiKillLevel * MultiKillBonus));

					// If the mutant killed the bottom feeder, they get a special score
					// Otherwise - score base on multi-kill level

					if( IsBottomFeeder(Other) )
						Killer.PlayerReplicationInfo.Score += BottomFeederKillScore;
					else
						Killer.PlayerReplicationInfo.Score += Min( BaseKillScore + (uKiller.MultiKillLevel * MultiKillBonus), MaxMultiKillScore );
				}
				else
				{
					//Log("MUTANT KILL: "$BaseKillScore);
					Killer.PlayerReplicationInfo.Score += BaseKillScore; // FIXME: Give bots multi-kill bonus?
				}

				if (GameStats!=None)
					GameStats.ScoreEvent(Killer.PlayerReplicationInfo,1,"frag");
			}
			else if( IsBottomFeeder(Killer) )
			{
				//Log("BOTTOM FEEDER KILL: "$BaseKillScore);
				Killer.PlayerReplicationInfo.Score += BaseKillScore;

				if (GameStats!=None)
					GameStats.ScoreEvent(Killer.PlayerReplicationInfo,1,"frag");
			}
		}
		else if(CurrentMutant == None) // FFA Kill
		{
			Killer.PlayerReplicationInfo.Score += BaseKillScore;

			if (GameStats!=None)
				GameStats.ScoreEvent(Killer.PlayerReplicationInfo,1,"frag");
		}
	}

	// Let the game rules modify the score as well
    if ( GameRulesModifiers != None )
        GameRulesModifiers.ScoreKill(Killer, Other);

	// Check if this means the end of the match
    if (Killer != None)
        CheckScore(Killer.PlayerReplicationInfo);

    if ( (killer == None) || (Other == None) )
        return;

	// Adjust bot skills if desired
    if ( bAdjustSkill && (killer.IsA('PlayerController') || Other.IsA('PlayerController')) )
    {
        if ( killer.IsA('AIController') )
            AdjustSkill(AIController(killer), PlayerController(Other),true);
        if ( Other.IsA('AIController') )
            AdjustSkill(AIController(Other), PlayerController(Killer),false);
    }
}

//
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	// If there is a Mutant - disable friendly fire (except for bottom feeder).
	if( CurrentMutant != None &&
		(injured != None && injured.Controller != CurrentMutant) &&
		(instigatedBy != None && instigatedBy.Controller != CurrentMutant) &&
		!IsBottomFeeder(instigatedBy.Controller) )
		return 0;

	// Regular damage evaluation
	return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
}

// Change the default pawn class to xMutantPawn on login.
event PlayerController Login( string Portal, string Options, out string Error )
{
	local PlayerController pc;

	pc = Super.Login(Portal, Options, Error);

	if(pc != None)
	{
		pc.PawnClass = class'BonusPack.xMutantPawn';
		xPlayer(pc).ComboNameList[3] = ""; // Remove invis combo from players list.
	}

	return pc;
}

event PostLogin( PlayerController NewPlayer )
{
	Super.PostLogin(NewPlayer);

	// Update list of bottom players when someone joins
	UpdateBottomFeeder();
}

// If the Mutant leaves - put things back into FFA
function Logout(Controller Exiting)
{
	local xPawn xExit;

	if ( Exiting == CurrentMutant )
	{
		if( Exiting.Pawn != None )
			xExit = xPawn(Exiting.Pawn);

		if(	xExit != None )
			SetMutant(Exiting, xExit, false);

		CurrentMutant = None;
		MutantGameReplicationInfo(GameReplicationInfo).MutantPRI = None;
		SendAllCurrentMutantMessage();
	}

	// Update list of bottom players when someone leaves
	UpdateBottomFeeder();

	Super.Logout(Exiting);
}

// So bots dont try and do invis combo
function string RecommendCombo(string ComboName)
{
	local float R;

	// Change combo if its invisibility.
	if( ComboName == "xGame.ComboInvis" )
	{
		R = FRand();

		if( R < 0.33 )
			ComboName = "xGame.ComboSpeed";
		else if( R > 0.66 )
			ComboName = "xGame.ComboBerserk";
		else
			ComboName = "xGame.ComboDefense";
	}

	return Super.RecommendCombo(ComboName);
}

// Set bot pawn class
function Bot SpawnBot(optional string botName)
{
	local Bot B;

	B = Super.SpawnBot(botName);

	if(B != None)
	{
		B.PawnClass = class'BonusPack.xMutantPawn';
	}

	// Update list of bottom players when a bot joins
	UpdateBottomFeeder();

	return B;
}

static function FillPlayInfo(PlayInfo PI)
{
	Super.FillPlayInfo(PI);

	PI.AddSetting(default.GameGroup,  "bEnableBottomFeeder", default.MutPropText, 40, 1, "Check",,,,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bEnableBottomFeeder":	return default.MutDescText;
	}

	return Super.GetDescriptionText(PropName);
}

function GetServerDetails(out ServerResponseLine ServerState)
{
	local int i;

	Super.GetServerDetails(ServerState);

	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i + 1;
	ServerState.ServerInfo[i].Key = "bEnableBottomFeeder";
	ServerState.ServerInfo[i].Value = Locs(bEnableBottomFeeder);
}

defaultproperties
{
     MutantMaterial=FinalBlend'XGameShaders.PlayerShaders.InvisFinal'
     DegenInterval=0.800000
     MultiKillBonus=1
     BaseKillScore=2
     MutantSuicidePenalty=4
     MaxMultiKillScore=4
     MutantKillHealthBonus=25
     BottomFeederKillScore=5
     bEnableBottomFeeder=True
     MutPropText="Enable BottomFeeder"
     MutDescText="If enabled, the player with the lowest score is the BottomFeeder, and can kill other players."
     DMSquadClass=Class'BonusPack.MutSquadAI'
     ScoreBoardType="BonusPack.MutantScoreboard"
     HUDType="BonusPack.HudMutant"
     MapListType="BonusPack.MapListMutant"
     GoalScore=20
     GameReplicationInfoClass=Class'BonusPack.MutantGameReplicationInfo'
     GameName="Mutant"
     Description="The first player to score a frag becomes the Mutant.  Everyone else hunts the Mutant, as by killing the mutant, a player becomes the mutant, with superhuman powers.  The player with the lowest score is the Bottom Feeder.  He can also kill other players."
     ScreenShotName="UT2004Thumbnails.MutantShots"
     DecoTextName="BonusPack.MutantGame"
     Acronym="MUT"
}
