//=============================================================================
// PhysicsVolume:  a bounding volume which affects actor physics
// Each Actor is affected at any time by one PhysicsVolume
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class PhysicsVolume extends Volume
	native
	nativereplication;

var()		vector		ZoneVelocity;
var()		vector		Gravity;

var			vector		BACKUP_Gravity;

var()		float		GroundFriction;
var()		float		TerminalVelocity;
var()		float		DamagePerSec;
var() class<DamageType>	DamageType;
var()		int			Priority;	// determines which PhysicsVolume takes precedence if they overlap
var() sound	EntrySound;			//only if waterzone
var() sound	ExitSound;			// only if waterzone
var() editinline I3DL2Listener VolumeEffect;
var() class<actor> EntryActor;	// e.g. a splash (only if water zone)
var() class<actor> ExitActor;	// e.g. a splash (only if water zone)
var() class<actor> PawnEntryActor; // when pawn center enters volume

var() float  FluidFriction;
var() vector ViewFlash, ViewFog;

var()		bool		bPainCausing;	 // Zone causes pain.
var			bool		BACKUP_bPainCausing;
var()		bool	bDestructive; // Destroys most actors which enter it.
var()		bool	bNoInventory;
var()		bool	bMoveProjectiles;// this velocity zone should impart velocity to projectiles and effects
var()		bool	bBounceVelocity;	// this velocity zone should bounce actors that land in it
var()		bool	bNeutralZone; // Players can't take damage in this zone.
var()		bool	bWaterVolume;
var()		bool	bNoDecals;
var()		bool	bDamagesVehicles;

// Distance Fog
var(VolumeFog) bool   bDistanceFog;	// There is distance fog in this physicsvolume.
var(VolumeFog) color DistanceFogColor;
var(VolumeFog) float DistanceFogStart;
var(VolumeFog) float DistanceFogEnd;

// Karma
var(Karma)	   float KExtraLinearDamping; // Extra damping applied to Karma actors in this volume.
var(Karma)	   float KExtraAngularDamping;
var(Karma)	   float KBuoyancy;			  // How buoyant Karma things are in this volume (if bWaterVolume true). Multiplied by Actors KarmaParams->KBuoyancy.

var	Info PainTimer;
var PhysicsVolume NextPhysicsVolume;

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		Gravity;
}

simulated function PreBeginPlay()
{
	if ( Base == None )
	{
		RemoteRole = ROLE_None;
		bAlwaysRelevant = false; // true by default to put it in the networked list of static actors, turn back on if change gravity or base
	}
	super.PreBeginPlay();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	BACKUP_Gravity		= Gravity;
	BACKUP_bPainCausing	= bPainCausing;
	if( VolumeEffect == None && bWaterVolume )
		VolumeEffect = new(Level.xLevel) class'EFFECT_WaterVolume';
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Gravity			= BACKUP_Gravity;
	bPainCausing	= BACKUP_bPainCausing;
	NetUpdateTime = Level.TimeSeconds - 1;
}

/* Called when an actor in this PhysicsVolume changes its physics mode
*/
event PhysicsChangedFor(Actor Other);

event ActorEnteredVolume(Actor Other);
event ActorLeavingVolume(Actor Other);

simulated event PawnEnteredVolume(Pawn Other)
{
	local vector HitLocation,HitNormal;
	local Actor SpawnedEntryActor;

	if ( bWaterVolume && (Level.TimeSeconds - Other.SplashTime > 0.3) && (PawnEntryActor != None) && !Level.bDropDetail && (Level.DetailMode != DM_Low) && EffectIsRelevant(Other.Location,false) )
	{
		if ( !TraceThisActor(HitLocation, HitNormal, Other.Location - Other.CollisionHeight*vect(0,0,1), Other.Location + Other.CollisionHeight*vect(0,0,1)) )	
		{
			SpawnedEntryActor = Spawn(PawnEntryActor,Other,,HitLocation,rot(16384,0,0));
		}
	}

	if ( (Role == ROLE_Authority) && Other.IsPlayerPawn() )
		TriggerEvent(Event,self, Other);
}

event PawnLeavingVolume(Pawn Other)
{
	if ( Other.IsPlayerPawn() )
		UntriggerEvent(Event,self, Other);
}

function PlayerPawnDiedInVolume(Pawn Other)
{
	UntriggerEvent(Event,self, Other);
}

singular event BaseChange()
{
	if ( Base != None )
	{
		bAlwaysRelevant = true;
		RemoteRole = ROLE_DumbProxy;
	}
}

/*
TimerPop
damage touched actors if pain causing.
since PhysicsVolume is static, this function is actually called by a volumetimer
*/
function TimerPop(VolumeTimer T)
{
	local actor A;
	local bool bFound;

	if ( T == PainTimer )
	{
		if ( !bPainCausing )
		{
			PainTimer.Destroy();
			return;
		}
		ForEach TouchingActors(class'Actor', A)
			if ( A.bCanBeDamaged && !A.bStatic )
			{
				CausePainTo(A);
				bFound = true;
			}

		if ( !bFound )
			PainTimer.Destroy();
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn P;

	// turn zone damage on and off
	if (DamagePerSec != 0)
	{
		bPainCausing = !bPainCausing;
		if ( bPainCausing )
		{
			if ( PainTimer == None )
				PainTimer = spawn(class'VolumeTimer', self);
		    ForEach TouchingActors(class'Pawn', P)
			    CausePainTo(P);
		}
	}
}

simulated event touch(Actor Other)
{
	local Pawn P;
	local bool bFoundPawn;

	Super.Touch(Other);
	if ( Other == None )
		return;
	if ( (Other.Role == ROLE_Authority) || Other.bNetTemporary )
	{
		if ( bNoInventory && (Pickup(Other) != None) && (Other.Owner == None) )
		{
			Other.LifeSpan = 1.5;
			return;
		}
		if ( bMoveProjectiles && (ZoneVelocity != vect(0,0,0)) )
		{
			if ( Other.Physics == PHYS_Projectile )
				Other.Velocity += ZoneVelocity;
			else if ( (Other.Base == None) && Other.IsA('Emitter') && (Other.Physics == PHYS_None) )
			{
				Other.SetPhysics(PHYS_Projectile);
				Other.Velocity += ZoneVelocity;
			}
		}
		if ( bPainCausing )
		{
			if ( Other.bDestroyInPainVolume )
			{
				Other.Destroy();
				return;
			}
			if ( Other.bCanBeDamaged && !Other.bStatic )
			{
				CausePainTo(Other);
				if ( Other == None )
					return;
				if ( Role == ROLE_Authority )
				{
					if ( PainTimer == None )
						PainTimer = Spawn(class'VolumeTimer', self);
					else if ( Pawn(Other) != None )
					{
						ForEach TouchingActors(class'Pawn', P)
							if ( (P != Other) && P.bCanBeDamaged )
							{
								bFoundPawn = true;
								break;
							}
						if ( !bFoundPawn )
							PainTimer.SetTimer(1.0,true);
					}
				}
			}
		}
	}
	if ( bWaterVolume && Other.CanSplash() )
		PlayEntrySplash(Other);
}

simulated function PlayEntrySplash(Actor Other)
{
	local vector StartLoc, Vel2D;
	
	if( EntrySound != None )
	{
		Other.PlaySound(EntrySound, SLOT_Interact, Other.TransientSoundVolume);
		if ( Other.Instigator != None )
			MakeNoise(1);
	}
	if( (EntryActor != None) && (Level.NetMode != NM_DedicatedServer) )
	{
		StartLoc = Other.Location - Other.CollisionHeight*vect(0,0,0.8);
		if ( Other.CollisionRadius > 0 )
		{
			Vel2D = Other.Velocity;
			Vel2D.Z = 0;
			if ( VSize(Vel2D) > 100 )
				StartLoc = StartLoc + Normal(Vel2D) * CollisionRadius;
		}
		Spawn(EntryActor,,,StartLoc,rot(16384,0,0));
	}
}

simulated event untouch(Actor Other)
{
	if ( bWaterVolume && Other.CanSplash() )
		PlayExitSplash(Other);
}

simulated function PlayExitSplash(Actor Other)
{
	if( ExitSound != None )
		Other.PlaySound(ExitSound, SLOT_Interact, Other.TransientSoundVolume);
	if( (ExitActor != None) && (Level.NetMode != NM_DedicatedServer) )
		Spawn(ExitActor,,,Other.Location - Other.CollisionHeight*vect(0,0,0.8),rot(16384,0,0));
}

function CausePainTo(Actor Other)
{
	local float depth;
	local Pawn P;

	// FIXMEZONE figure out depth of actor, and base pain on that!!!
	depth = 1;
	P = Pawn(Other);

	if ( DamagePerSec > 0 )
	{
		if ( Region.Zone.bSoftKillZ && (Other.Physics != PHYS_Walking) )
			return;
		Other.TakeDamage(int(DamagePerSec * depth), None, Location, vect(0,0,0), DamageType);
		if ( (P != None) && (P.Controller != None) )
			P.Controller.PawnIsInPain(self);
	}
	else
	{
		if ( (P != None) && (P.Health < P.HealthMax) )
			P.Health = Min(P.HealthMax, P.Health - depth * DamagePerSec);
	}
}

defaultproperties
{
     Gravity=(Z=-950.000000)
     GroundFriction=8.000000
     TerminalVelocity=2500.000000
     FluidFriction=0.300000
     bDamagesVehicles=True
     KBuoyancy=1.000000
     bAlwaysRelevant=True
     bOnlyDirtyReplication=True
     NetUpdateFrequency=0.100000
}
