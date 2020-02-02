//=============================================================================
// ASVehicleFactory
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================
// Factory to spawn vehicles in Assault
// - Supports startup or trigger spawning
// - round reset
// - respawn when killed
// - progress respawn
// - ON/OFF triggering
//
// Note: Assault factories can only spawn and handle a single vehicle at a time
//=============================================================================

class ASVehicleFactory extends SVehicleFactory
	placeable;

var()	bool	bEnabled;
var()	bool	bVehicleTeamLock;		// Vehicle is locked to specific team.
var()	bool	bEnter_TeamUnlocks;		// When a player enters vehicle, it is unlocked.
var()	bool	bHUDTrackVehicle;	// If true, Vehicle will tracked on HUD. (For Objectives in Assault)
var()	bool	bRespawnWhenDestroyed;	// when vehicle is destroyed spawn a new one
var()	bool	bSpawnProtected;
var()	bool	bHighScoreKill;		// vehicle is considered important and awards 5 points upon destruction
var()	bool	bKeyVehicle;		// Hint for AI to hunt down vehicle (when vehicle is considered an objective like in Glacier or Junkyard)
var()	bool	bSpawnBuildEffect;

var		bool	BACKUP_bEnabled;
var		bool	bSoundsPrecached;
var		bool	bResetting;

var()	byte	VehicleTeam;
var()	enum EASVF_TriggeredFunction
{
	EAVSF_ToggleEnabled,
	EAVSF_TriggeredSpawn,
	EAVSF_SpawnProgress,
} TriggeredFunction;

// published
var()	name	VehicleTag;			// Tag to set on vehicle (to use with possess triggers for example)
var()	name	VehicleEvent;		// Event to set on vehicle (triggered when vehicle is destroyed)
var()	name	NextFactoryTag;		// next Factory to enable with Spawn Progress...
var()	name	VehiclePossessedEvent;
var()	String	VehicleClassStr;

var()	float	RespawnDelay;

var()	int		VehicleHealth;				// health vehicle gets (values <= 0 mean vehicle default)
var()	float	VehicleDriverDamageMult;	// multiplier to damage on vehicle's driver (applied to all positions vehicle has)
var()	float	VehicleDamageMomentumScale;
var()	float	VehicleLinkHealMult;

var()	Sound	Announcement_Destroyed;
var()	byte	VehicleAmbientGlow;

var()	float	AIVisibilityDist;	// AI Sight Radius

// internal
var		Vehicle				Child;
var		float				SpawnDelay;		// Spawn delay to avoid spawning vehicles during resetting...
var		ASVehicleFactory	NextFactory;
var()	int					MaxSpawnBlockCount;
var		int					BlockCount;

var		Emitter				BuildEffect;
var		class<Emitter>		BuildEffectClass;
var	DestroyVehicleObjective	MyDestroyVehicleObjective;


simulated function PostBeginPlay()
{
	if ( VehicleClass == None && VehicleClassStr != "" )
		VehicleClass = class<Vehicle>(DynamicLoadObject(VehicleClassStr, class'Class'));

	if ( Role == Role_Authority )
	{
		if ( NextFactoryTag != '' )
			ForEach AllActors(class'ASVehicleFactory', NextFactory, NextFactoryTag)
				break;

		BACKUP_bEnabled = bEnabled;

		// Should the vehicle spawn at startup ?
		if ( bEnabled && TriggeredFunction != EAVSF_TriggeredSpawn )
			SetTimer(SpawnDelay, false);
	}
}

simulated function UpdatePrecacheMaterials()
{
	if ( bSpawnBuildEffect )
	{
		Level.AddPrecacheMaterial( Material'VMParticleTextures.buildEffects.PC_buildBorderNew' );
		Level.AddPrecacheMaterial( Material'VMParticleTextures.buildEffects.PC_buildStreaks' );
	}
	
	if ( VehicleClass == None && VehicleClassStr != "" )
		VehicleClass = class<Vehicle>(DynamicLoadObject(VehicleClassStr, class'Class'));

	if ( VehicleClass != None )
		VehicleClass.static.StaticPrecache( Level );
	
	super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	if ( bSpawnBuildEffect )
		Level.AddPrecacheStaticMesh( StaticMesh'VMStructures.CoreGroup.CoreShieldSM' );
	super.UpdatePrecacheStaticMeshes();
}



function bool SelfTriggered()
{
	return true;
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	local Vehicle	AliveChild;

	if ( TriggeredFunction == EAVSF_TriggeredSpawn )
	{
		// if Factory already has a child, destroy it...
		if ( Child != None )
		{
			Child.Destroy();
			Child = None;
			return;
		}

		// Spawn vehicle
		SetTimer(SpawnDelay, false);
	}
	else
	{
		if ( bEnabled && TriggeredFunction == EAVSF_SpawnProgress && NextFactory != None )
		{
			// Spawn progress, we disable current vehicle factory and switch child to next one.
			if ( Child != None )
			{			
				AliveChild			= Child;
				Child.ParentFactory = NextFactory;
				NextFactory.Child	= Child;
				Child				= None;

				// If vehicle left alone at initial spawn location, make it respawn at new spawn location.
				if ( AliveChild.IsVehicleEmpty() 
					&& (VSize(AliveChild.Location - Location) > VSize(AliveChild.Location - NextFactory.Location) 
					|| !FastTrace(NextFactory.Location, AliveChild.Location)) )
				{
					AliveChild.Destroy();
					NextFactory.Child = None;
				}
			}

			NextFactory.SetEnabled( !NextFactory.bEnabled );
		}

		SetEnabled( !bEnabled );
	}
}

function SetEnabled( bool bNewEnabled )
{
	bEnabled = bNewEnabled;

	if ( bEnabled && (Child == None) && (TriggeredFunction != EAVSF_TriggeredSpawn) )
	{
		SetTimer(SpawnDelay, false);
	}
}

function ShutDown()
{
	SetEnabled( false );

	if ( Child != None )
	{
		if ( Child.Driver != None )
			Child.KDriverLeave( true );
		
		if ( !Child.bDeleteMe && !Child.IsInState('Dying') )
			Child.Destroy();

		Child = None;
	}
}

function SpawnVehicle()
{
	local Pawn		P;
	local bool		bBlocked;
	local Vehicle	CreatedVehicle;

	if ( !Level.Game.bAllowVehicles || VehicleClass == None )
		return;

	if ( BlockCount < MaxSpawnBlockCount )
	{
		foreach CollidingActors(class'Pawn', P, VehicleClass.default.CollisionRadius * 1.5)
		{
			bBlocked = true;
			if ( PlayerController(P.Controller) != None )
				PlayerController(P.Controller).ReceiveLocalizedMessage(class'Message_ASKillMessages', 2+BlockCount );
		}

		if ( bBlocked )
		{
			if ( bSpawnBuildEffect )
				SpawnBuildEffect();
			BlockCount++;
    		SetTimer(1.5, false); //try again later
			return;
		}
	}
	
	CreatedVehicle = Spawn(VehicleClass,,, Location, Rotation);

	if ( CreatedVehicle != None )
	{
		BlockCount = 0;
		Child = CreatedVehicle;
		VehicleSpawned();
	}
	else
	{
		SetTimer(SpawnDelay, false);	// try again
		log("ASVehicleFactory::SpawnVehicle - Couldn't spawn vehicle"@String(VehicleClass));
	}
	
}

function SpawnBuildEffect()
{
    local rotator	YawRot;
	local int		TeamNum;

	TeamNum			= SetVehicleTeam();
    YawRot			= Rotation;
    YawRot.Roll		= 0;
    YawRot.Pitch	= 0;

    BuildEffect = Spawn(BuildEffectClass,,, Location, YawRot);
}

function VehicleSpawned()
{
	local Vehicle	V;

	// Make sure Vehicle is not destroyed when player exits
	if ( !Child.IsA('ASVehicle') )
	{
		Child.bEjectDriver		= true; // in Assault, force ejecting drivers when vehicle is destroyed
		Child.bSpawnProtected	= true; // Force spawn protection on ONS vehicles in Assault
	}
	else
		Child.bSpawnProtected	= bSpawnProtected;

	if ( VehicleTag != '' )
		Child.Tag = VehicleTag;

	if ( VehicleEvent != '' )
		Child.Event = VehicleEvent;

	if ( VehicleHealth < 1 )
		VehicleHealth = Child.Health;

	Child.Health = VehicleHealth;
	Child.HealthMax = Child.Health;

	if ( VehicleAmbientGlow > 0 )
		Child.AmbientGlow = VehicleAmbientGlow;

	Child.MomentumMult		*= VehicleDamageMomentumScale;
	Child.DriverDamageMult	*= VehicleDriverDamageMult;
	foreach Child.BasedActors(class'Vehicle', V)
	{
		V.DriverDamageMult	*= VehicleDriverDamageMult;
		V.MomentumMult		*= VehicleDamageMomentumScale;
		V.HealthMax = Child.HealthMax;
	}

	Child.LinkHealMult = VehicleLinkHealMult;

	Child.SetTeamNum( SetVehicleTeam() );
	Child.PrevTeam			= Child.Team;
	Child.bTeamLocked		= bVehicleTeamLock;		// Vehicle is locked to specific team.
	Child.bEnterringUnlocks	= bEnter_TeamUnlocks;	// When a player enters vehicle, it is unlocked.
	Child.ParentFactory		= Self;
	Child.SightRadius		= AIVisibilityDist;
	Child.bHUDTrackVehicle	= bHUDTrackVehicle;
	Child.bKeyVehicle		= bKeyVehicle;
	Child.bHighScoreKill	= bHighScoreKill;
	Child.bNoFriendlyFire	= bHighScoreKill || bKeyVehicle || bHUDTrackVehicle;

	if ( bHUDTrackVehicle || MyDestroyVehicleObjective != None )
		Child.bAlwaysRelevant = true;

	if ( MyDestroyVehicleObjective != None )
		MyDestroyVehicleObjective.VehicleSpawned( Child );
}

function byte SetVehicleTeam()
{
	local byte DefendingTeam;

	// Set to defenders by default
	if ( VehicleTeam > 1 )
		VehicleTeam = 1;

	DefendingTeam = Level.Game.GetDefenderNum();

	// Check Attackers
	if ( VehicleTeam == 0 )
		return (1 - DefendingTeam);
	else
		return DefendingTeam;
}


function Reset()
{
	bResetting		= true;
	bEnabled		= BACKUP_bEnabled;
	BlockCount		= 0;

	// Force vehicle destruction at round reset
	if ( Child != None )
	{
		Child.Destroy();
		Child = None;
	}

	// Spawn at startup
	if ( bEnabled && TriggeredFunction != EAVSF_TriggeredSpawn )
		SetTimer(SpawnDelay, false);

	bResetting = false;
}

function Timer()
{
	if ( bResetting || !bEnabled )
		return;

	// Spawn vehicle
	if ( Child == None )
		SpawnVehicle();
}

event VehiclePossessed( Vehicle V )
{
	TriggerEvent(VehiclePossessedEvent, Self, V);
}

event VehicleDestroyed( Vehicle V )
{
	local Controller	C;

	Child = None;

	if ( !bEnabled || bResetting )
		return;

	if ( Role == Role_Authority && Announcement_Destroyed != None )
	{
		if ( Level.Game.IsA('ASGameInfo') )
			ASGameInfo(Level.Game).QueueAnnouncerSound( Announcement_Destroyed.Name, 1, 255 );
		else
		{
			for ( C = Level.ControllerList; C != None; C = C.NextController )
				if ( PlayerController(C) != None )
					PlayerController(C).PlayStatusAnnouncement(Announcement_Destroyed.Name, 1, true);
		}
	}

	if ( bRespawnWhenDestroyed )
		SetTimer(RespawnDelay, false);
}

simulated function PrecacheAnnouncer(AnnouncerVoice V, bool bRewardSounds)
{
	if ( !bRewardSounds && !bSoundsPrecached && (Announcement_Destroyed != None) )
	{
		bSoundsPrecached = true;
		V.PrecacheSound(Announcement_Destroyed.Name);
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bEnabled=True
     bSpawnBuildEffect=True
     VehicleTeam=1
     RespawnDelay=3.000000
     VehicleDriverDamageMult=1.000000
     VehicleDamageMomentumScale=1.000000
     VehicleLinkHealMult=0.350000
     AIVisibilityDist=15000.000000
     SpawnDelay=0.150000
     MaxSpawnBlockCount=5
     BuildEffectClass=Class'UT2k4Assault.FX_ASVehicleBuildEffect'
     VehicleClass=Class'UT2k4Assault.ASTurret'
     bMovable=False
}
