class GameObjective extends JumpSpot
	abstract;

#exec OBJ LOAD File=AnnouncerAssault.uax

// HUD drawing
var(Assault)	float	DrawDistThresHold;	// Don't draw objective beyond this distance (0 = unlimited)
var(Assault)	bool	bUsePriorityOnHUD;	// if false, objective won't be displayed on HUD
var(Assault)	bool	bOverrideZoneCheck;	// Override Zone check (USE DrawDistThreshold to minimize CPU resources!!)
var(Assault)	bool	bOverrideVisibilityCheck;	// No line trace
var(Assault)	bool	bReplicateObjective;	// For basic Objective replication
var(Assault)	bool	bAnnounceNextObjective;			// when disabled, announce next objective
var(MothershipHack)	    bool    bMustBoardVehicleFirst;
var(Assault)	bool	bBotOnlyObjective;			// invisible to players, for bots only

var()	bool	bInitiallyActive;
var		bool	bActive;
var()	bool	bTriggerOnceOnly;
var()	bool	bOptionalObjective;
var		bool	bIgnoredObjective;	// sometimes set by AI for optional Objectives
var		bool	bDisabled;			// true when objective has been destroyed
var		bool	bOldDisabled;
var		bool	bFirstObjective;	// First objective in list of objectives defended by same team
var()	bool	bTeamControlled;	// disabling changes the objectives team rather than removing it
var()	bool	bAccruePoints;		// controlling team accrues points
var		bool	bHasShootSpots;
var		bool	bSoundsPrecached;
var		bool	bIsCritical;				// Set when Attackers are located in the 'Critical Volume'
var				bool			bHighlightPhysicalObjective, bOldHighlightPhysicalObjective;
var		bool	bIsBeingAttacked;	// temp flag - not always valid
var		bool	bClearInstigator;	// disable objective, but ignore instigator
var		bool	bOldCritical;
var(Assault)	bool	bPlayCriticalAssaultAlarm;

var()	byte	DefenderTeamIndex;	// 0 = defended by team 0
var		byte	StartTeam;
var()	byte	DefensePriority;	// Higher priority defended/attacked first
var()	int		Score;				// score given to player that completes this objective

var()	Name					DefenseScriptTags;	// tags of scripts that are defense scripts
var		UnrealScriptedSequence	DefenseScripts;

var()	localized	String	ObjectiveName;
var()	localized	String	DestructionMessage;
var()	localized	String	LocationPrefix, LocationPostfix;
var		localized	String	ObjectiveStringPrefix, ObjectiveStringSuffix;

var GameObjective	NextObjective;	// list of objectives defended by the same team
var SquadAI			DefenseSquad;	// squad defending this objective;
var AssaultPath		AlternatePaths;

var()	name	AreaVolumeTag;
var		Volume	MyBaseVolume;
var()	float	BaseExitTime;		// how long it takes to get entirely away from the base
var()	float	BaseRadius;			// radius of base
var()	float	BotDamageScaling;	// potentially used by gametype
var()	name	CriticalObjectiveVolumeTag;	// GameObjective will be considered in danger when an attacker enters this volume
var()	Material	ObjectiveTypeIcon;

// Priority system for Assault
// Lower priority means displayed first on HUD and in briefing list
// Count starts at 0 and up until a no more objectives can be found (if there is a gap, list will be stopped!).
// Assault internal priority is built from the default one (DefensePriority)
var	byte	ObjectivePriority;

var				float	LastDrawTime;		// -- internal to on-HUD objective display
var				float	DrawTime;			// -- internal to on-HUD objective display

var(Assault)	Localized	String	ObjectiveDescription;		// Description displayed in Briefing screen
var(Assault)	Localized	String	Objective_Info_Attacker;	// Description displayed on HUD for attackers
var(Assault)	Localized	String	Objective_Info_Defender;	// Description displayed on HUD for defenders

var	localized string	UseDescription;	// Description is drawn on HUD using brackets (ObjectiveType_Use)

var(Assault)	sound	Announcer_DisabledObjective;	// announcement when objective is disabled.
var(Assault)	sound	Announcer_ObjectiveInfo;		// info on how to disable objective
var(Assault)	sound	Announcer_DefendObjective;		// defenders version

var PlayerReplicationInfo	DisabledBy;

var				Material		HighlightOverlay[2];		// UV2 Material for physical objective highlighting
var				Array<Actor>	PhysicalObjectiveActors;	// Array of linked actors for objective's physical representation
var(Assault)	name			PhysicalObjectiveActorsTag;

// Assault Cinematics
var(Assault) name	EndCameraTag;
var			Actor	EndCamera;

var Controller DelayedDamageInstigatorController;

var() name		VehiclePathName;
var NavigationPoint VehiclePath;

var int		ObjectiveDisabledTime;		// Assault stats
var float	SavedObjectiveProgress;

// Score sharing
struct ScorerRecord
{
	var Controller	C;
	var float		Pct;
};
var array<ScorerRecord>	Scorers;


replication
{
	unreliable if ( (Role==ROLE_Authority) && bReplicateObjective && bNetDirty )
		bDisabled, bActive, DefenderTeamIndex, bHighlightPhysicalObjective, bIsCritical, ObjectiveDisabledTime, SavedObjectiveProgress;
}


function float GetDifficulty()
{
	return 0;
}

function bool CanDoubleJump(Pawn Other)
{
	return true;
}

simulated event PreBeginPlay()
{
	super.PreBeginPlay();

	if ( bReplicateObjective )
		bNetNotify = true;
}

simulated function PostBeginPlay()
{
	local GameObjective O, CurrentObjective;
	local AssaultPath A;
	local UnrealScriptedSequence W;
	local Actor	Ac;
	local NavigationPoint N;

	super.PostBeginPlay();

	if ( Role == Role_Authority )
	{
		SetActive( bInitiallyActive );
		StartTeam	= DefenderTeamIndex;

		// find defense scripts
		if ( DefenseScriptTags != '' )
			ForEach AllActors(class'UnrealScriptedSequence', DefenseScripts, DefenseScriptTags)
				if ( DefenseScripts.bFirstScript )
					break;

		// clear defense scripts bFreelance
		for ( W=DefenseScripts; W!=None; W=W.NextScript )
			W.bFreelance = false;

		// add to objective list
		if ( bFirstObjective )
		{
			CurrentObjective = self;
			ForEach AllActors(class'GameObjective',O)
				if ( O != CurrentObjective )
				{
					CurrentObjective.NextObjective = O;
					O.bFirstObjective = false;
					CurrentObjective = O;
				}
		}

		// set up AssaultPaths
		ForEach AllActors(class'AssaultPath', A)
			if ( A.ObjectiveTag == Tag )
				A.AddTo(self);

		// find AreaVolume
		if ( CriticalObjectiveVolumeTag != '' )
			ForEach AllActors(class'Volume', MyBaseVolume, CriticalObjectiveVolumeTag)
			{
				MyBaseVolume.AssociatedActor = Self;
				if ( !MyBaseVolume.IsA('ASCriticalObjectiveVolume') )
					warn( "CriticalObjectiveVolumeTag is not a ASCriticalObjectiveVolume actor!!!" );

				break;
			}

		if ( MyBaseVolume == None )
			ForEach AllActors(class'Volume', MyBaseVolume, AreaVolumeTag)
				break;

		if ( (MyBaseVolume != None) && (MyBaseVolume.LocationName ~= "unspecified") )
			MyBaseVolume.LocationName = LocationPrefix@GetHumanReadableName()@LocationPostfix;

		if ( bAccruePoints )
			SetTimer(1.0,true);

		if ( EndCameraTag != '' )
			ForEach AllActors(class'Actor', EndCamera, EndCameraTag)
				break;

		if ( VehiclePathName != '' )
		{
			for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
				if ( N.Name == VehiclePathName )
				{
					VehiclePath = N;
					break;
				}
		}
	}

	/* Cache Linked actors for Physical Objective Highlighting */
	if ( Level.NetMode != NM_DedicatedServer && PhysicalObjectiveActorsTag != '' )
		ForEach AllActors(class'Actor', Ac, PhysicalObjectiveActorsTag)
			PhysicalObjectiveActors[PhysicalObjectiveActors.Length] = Ac;
}

simulated function UpdateLocationName()
{
	if ( MyBaseVolume == None )
		ForEach AllActors(class'Volume', MyBaseVolume, AreaVolumeTag)
			break;

    // Update location volume if we have one
    if ( (MyBaseVolume != None) && (MyBaseVolume.default.LocationName ~= "unspecified") )
        MyBaseVolume.LocationName = LocationPrefix@GetHumanReadableName()@LocationPostfix;
}

function PlayAlarm();

function bool BotNearObjective(Bot B)
{
	if ( NearObjective(B.Pawn)
		|| ((B.RouteGoal == self) && (B.RouteDist < 2500))
		|| (B.bWasNearObjective && (VSize(Location - B.Pawn.Location) < BaseRadius)) )
	{
		B.bWasNearObjective = true;
		return true;
	}

	B.bWasNearObjective = false;
	return false;
}

function bool NearObjective(Pawn P)
{
	if ( MyBaseVolume != None )
		return P.IsInVolume(MyBaseVolume);
	if ( (VSize(Location - P.Location) < BaseRadius) && P.LineOfSightTo(self) )
		return true;
}

function Timer()
{
	if ( DefenderTeamIndex < 2 )
	{
		Level.GRI.Teams[DefenderTeamIndex].Score += Score;
		Level.Game.TeamScoreEvent(DefenderTeamIndex, Score, "game_objective_score");
	}
}

function bool OwnsDefenseScript(UnrealScriptedSequence S)
{
	return ( DefenseScriptTags == S.Tag );
}

simulated function string GetHumanReadableName()
{
	if ( ObjectiveName != "" )
		return ObjectiveName;

	if ( Default.ObjectiveName != "" )
		return Default.ObjectiveName;

	return ObjectiveStringPrefix$class'TeamInfo'.Default.ColorNames[DefenderTeamIndex]$ObjectiveStringSuffix;
}

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(Bot B)
{
	return B.Squad.FindPathToObjective(B,self);
}

function int GetNumDefenders()
{
	if ( DefenseSquad == None )
		return 0;
	return DefenseSquad.GetSize();
	// fiXME - max defenders per defensepoint, when all full, report big number
}

/* triggered by intro cinematic to auto complete objective */
function CompleteObjective( Pawn Instigator )
{
	DisableObjective( Instigator );
}

function DisableObjective(Pawn Instigator)
{
	local PlayerReplicationInfo	PRI;

	if ( !IsActive() || !UnrealMPGameInfo(Level.Game).CanDisableObjective( Self ) )
		return;

	NetUpdateTime = Level.TimeSeconds - 1;

	if ( bClearInstigator )
	{
		Instigator = None;
	}
	else
	{
		if ( Instigator != None )
		{
			if ( Instigator.PlayerReplicationInfo != None )
				PRI = Instigator.PlayerReplicationInfo;
			else if ( Instigator.Controller != None && Instigator.Controller.PlayerReplicationInfo != None )
				PRI = Instigator.Controller.PlayerReplicationInfo;
		}

		if ( DelayedDamageInstigatorController != None )
		{
			if ( Instigator == None )
				Instigator = DelayedDamageInstigatorController.Pawn;

			if ( PRI == None && DelayedDamageInstigatorController.PlayerReplicationInfo != None )
				PRI = DelayedDamageInstigatorController.PlayerReplicationInfo;
		}

		if ( !bBotOnlyObjective && DestructionMessage != "" )
			PlayDestructionMessage();
	}


	if ( bTeamControlled )
	{
		if (PRI != None)
			DefenderTeamIndex = PRI.Team.TeamIndex;
	}
	else
	{
		bDisabled	= true;
		SetActive( false );
	}

	SetCriticalStatus( false );
	DisabledBy	= PRI;
	if ( MyBaseVolume != None && MyBaseVolume.IsA('ASCriticalObjectiveVolume') )
		MyBaseVolume.GotoState('ObjectiveDisabled');

	if ( bAccruePoints )
		Level.Game.ScoreObjective( PRI, 0 );
	else
		Level.Game.ScoreObjective( PRI, Score );

	if ( !bBotOnlyObjective )
		UnrealMPGameInfo(Level.Game).ObjectiveDisabled( Self );

	TriggerEvent(Event, self, Instigator);

	UnrealMPGameInfo(Level.Game).FindNewObjectives( Self );
}

simulated function PlayDestructionMessage()
{
	local PlayerController	PC;

	if ( DestructionMessage == default.DestructionMessage )
		DestructionMessage = Level.GRI.Teams[DefenderTeamIndex].TeamName@DestructionMessage;

	if ( !bReplicateObjective )
	{
		Level.Game.Broadcast(Self, DestructionMessage, 'CriticalEvent');
		return;
	}

	PC = Level.GetLocalPlayerController();
	if ( PC != None )
		PC.TeamMessage(PC.PlayerReplicationInfo, DestructionMessage, 'CriticalEvent');
}

function bool BetterObjectiveThan(GameObjective Best, byte DesiredTeamNum, byte RequesterTeamNum)
{
	if ( !IsActive() || (DefenderTeamIndex != DesiredTeamNum) )
		return false;

	if ( (Best == None) || (Best.DefensePriority < DefensePriority) )
		return true;

	return false;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	super.Reset();

	bClearInstigator	= false;
	DefenseSquad		= None;
	LastDrawTime		= 0.f;
	bDisabled			= false;
	DefenderTeamIndex	= StartTeam;
	DisabledBy			= None;
	Scorers.Length		= 0;
	HighlightPhysicalObjective( false );
	SetActive( bInitiallyActive );
	SetCriticalStatus( false );
	DelayedDamageInstigatorController = None;
}

function SetActive( bool bActiveStatus )
{
	if ( bDisabled )				// Cannot be active if objective is disabled
		bActiveStatus = false;

	bActive = bActiveStatus;
	NetUpdateTime = Level.TimeSeconds - 1;
}

simulated function bool IsActive()
{
	return (!bDisabled && bActive);
}

simulated function bool IsCritical()
{
	return IsActive() && bIsCritical;
}

function SetCriticalStatus( bool bNewCriticalStatus )
{
	bIsCritical = bNewCriticalStatus;
	CheckPlayCriticalAlarm();
}

function CheckPlayCriticalAlarm()
{
	local bool bNewCritical;

	if ( !bPlayCriticalAssaultAlarm )
		return;

	bNewCritical = IsCritical();
	if ( bOldCritical != bNewCritical )
	{
		if ( bNewCritical )
		{
			// Only set alarm if objective is currently relevant
			if ( UnrealMPGameInfo(Level.Game).CanDisableObjective( Self ) )
			{
				AmbientSound = Sound'GameSounds.CTFAlarm';
				bOldCritical = bNewCritical;
			}
		}
		else
		{
			AmbientSound = None;
			bOldCritical = bNewCritical;
		}
	}
}

// TriggerObjective ON/OFF
function Trigger(Actor Other, Pawn Instigator)
{
	if ( bDisabled || (bTriggerOnceOnly && bActive != bInitiallyActive) )
		return;

	SetActive( !bActive );
}

simulated function PrecacheAnnouncer(AnnouncerVoice V, bool bRewardSounds)
{
	local string SoundPackageName;
	local int pos;

	if ( !bRewardSounds && !bSoundsPrecached )
	{
		bSoundsPrecached = true;
		if ( Announcer_DisabledObjective != None )
		{
			pos = InStr(string(Announcer_DisabledObjective), ".");
			SoundPackageName = left(string(Announcer_DisabledObjective),pos);
			if ( SoundPackageName != "" )
				V.AlternateFallbackSoundPackage = SoundPackageName;
			else
				V.AlternateFallbackSoundPackage = V.Default.AlternateFallbackSoundPackage;
			V.PrecacheSound(Announcer_DisabledObjective.Name);
		}
		if ( Announcer_ObjectiveInfo != None )
		{
			pos = InStr(string(Announcer_ObjectiveInfo), ".");
			SoundPackageName = left(string(Announcer_ObjectiveInfo),pos);
			if ( SoundPackageName != "" )
				V.AlternateFallbackSoundPackage = SoundPackageName;
			else
				V.AlternateFallbackSoundPackage = V.Default.AlternateFallbackSoundPackage;
			V.PrecacheSound(Announcer_ObjectiveInfo.Name);
		}
		if ( Announcer_DefendObjective != None )
		{
			pos = InStr(string(Announcer_DefendObjective), ".");
			SoundPackageName = left(string(Announcer_DefendObjective),pos);
			if ( SoundPackageName != "" )
				V.AlternateFallbackSoundPackage = SoundPackageName;
			else
				V.AlternateFallbackSoundPackage = V.Default.AlternateFallbackSoundPackage;
			V.PrecacheSound(Announcer_DefendObjective.Name);
		}
		V.AlternateFallbackSoundPackage = V.Default.AlternateFallbackSoundPackage;
	}
}


function HighlightPhysicalObjective( bool bShow )
{
	CheckPlayCriticalAlarm();
	bHighlightPhysicalObjective = bShow;
	NetUpdateTime = Level.TimeSeconds - 1;

	if ( Level.NetMode != NM_DedicatedServer )
		SetObjectiveOverlay( bShow );
}

simulated function PostNetReceive()
{
	if ( bOldDisabled != bDisabled )
	{
		if ( bDisabled && !bBotOnlyObjective && DestructionMessage != "" )
			PlayDestructionMessage();
		bOldDisabled = bDisabled;
	}

	if ( bHighlightPhysicalObjective != bOldHighlightPhysicalObjective )
	{
		SetObjectiveOverlay( bHighlightPhysicalObjective );
		bOldHighlightPhysicalObjective = bHighlightPhysicalObjective;
	}
}

/* Add pulsing overlay on objective's physical representation */
simulated function SetObjectiveOverlay( bool bShow )
{
	local int		i;
	local Material	newUV2Material;

	// Material
	if ( !bShow )
		newUV2Material = None;
	else
		newUV2Material = HighlightOverlay[DefenderTeamIndex];

	// if Objective is visible and displaying a staticmesh, apply overlay
	if ( DrawType == DT_StaticMesh && StaticMesh != None )
		UV2Texture = newUV2Material;

	// Linked actors for objective's physical representation
	if ( PhysicalObjectiveActors.Length > 0 )
		for (i=0; i<PhysicalObjectiveActors.Length; i++)
			if  ( PhysicalObjectiveActors[i] != None )
				PhysicalObjectiveActors[i].UV2Texture = newUV2Material;
}

/* returns objective's progress status 1->0 (=disabled) */
simulated function float GetObjectiveProgress()
{
	return 0;
}

simulated function UpdatePrecacheMaterials()
{
	if ( ObjectiveTypeIcon != None )
		Level.AddPrecacheMaterial(ObjectiveTypeIcon);

	Level.AddPrecacheMaterial(HighlightOverlay[0]);
	Level.AddPrecacheMaterial(HighlightOverlay[1]);

	super.UpdatePrecacheMaterials();
}

// Score Sharing

/* Keep track of players who contributed in completing the objective to share the score */
function AddScorer( Controller C, float Pct )
{
	local ScorerRecord	S;
	local int			i;

	// Look-up existing entry
	if ( Scorers.Length > 0 )
		for (i=0; i<Scorers.Length; i++)
			if ( Scorers[i].C == C )
			{
				Scorers[i].Pct += Pct;
				return;
			}

	// Add new entry
	S.C		= C;
	S.Pct	= Pct;
	Scorers[Scorers.Length] = S;
}

/* Share score between contributors */
function ShareScore( int Score, string EventDesc )
{
	local int	i;
	local float	SharedScore;

	for (i=0; i<Scorers.Length; i++)
	{
		if ( Scorers[i].C == None )	// FIXME: obsolete player (left game)
			continue;

		//SharedScore = Round(float(Score) * Scorers[i].Pct);
		SharedScore = float(Score) * Scorers[i].Pct;
		if ( SharedScore > 0 )
		{
			Scorers[i].C.AwardAdrenaline(SharedScore);
			Scorers[i].C.PlayerReplicationInfo.Score += SharedScore;
			Level.Game.ScoreEvent(Scorers[i].C.PlayerReplicationInfo, SharedScore, EventDesc);
			if (Level.Game.GameRulesModifiers != None)
				Level.Game.GameRulesModifiers.ScoreObjective(Scorers[i].C.PlayerReplicationInfo, SharedScore);
		}
	}
}

/* Award Assault score to player(s) who completed the objective */
function AwardAssaultScore( int Score )
{
	if ( DisabledBy != None )
	{
		DisabledBy.Score += Score;
		Level.Game.ScoreEvent(DisabledBy, Score, "Objective_Completed");
	}
}

function SetTeam(byte TeamIndex)
{
	DefenderTeamIndex = TeamIndex;
}

defaultproperties
{
     bUsePriorityOnHUD=True
     bAnnounceNextObjective=True
     bInitiallyActive=True
     bActive=True
     bFirstObjective=True
     Score=5
     DestructionMessage="Objective Disabled!"
     LocationPrefix="Near"
     ObjectiveStringSuffix=" Team Base"
     BaseExitTime=8.000000
     BaseRadius=2000.000000
     BotDamageScaling=1.500000
     ObjectiveDescription="Disable Objective."
     Objective_Info_Attacker="Disable Objective"
     Objective_Info_Defender="Defend Objective"
     UseDescription="USE"
     Announcer_DisabledObjective=Sound'AnnouncerAssault.Generic.Objective_disabled'
     Announcer_ObjectiveInfo=Sound'AnnouncerAssault.Generic.Move_onto_next_objective'
     Announcer_DefendObjective=Sound'AnnouncerAssault.Generic.Defend_next_objective'
     HighlightOverlay(0)=FadeColor'AS_FX_TX.Skins.ObjectiveOverlay_Red'
     HighlightOverlay(1)=FadeColor'AS_FX_TX.Skins.ObjectiveOverlay_Blue'
     bOptionalJumpDest=True
     bForceDoubleJump=True
     bMustBeReachable=True
     bUseDynamicLights=True
     bReplicateMovement=False
     bOnlyDirtyReplication=True
     NetUpdateFrequency=1.000000
     SoundVolume=255
     SoundRadius=512.000000
}
