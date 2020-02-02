class ONSRVWebProjectile extends Projectile
	native
	nativereplication;

var class<Emitter>	ProjectileEffectClass; // Assumes Emitter 0 is the beam to next projectile.
var Emitter			ProjectileEffect;

var ONSRVWebProjectileLeader	Leader;
var	int							ProjNumber;
var	float						LastTickTime;
var bool						bBeingSucked;

var Actor	StuckActor;
var vector	StuckNormal;

var() int   BeamSubEmitterIndex; // Emitter index of BeamEmitter than connects projectiles.
var() float	ExplodeDelay;
var() sound StuckSound;

var() class<Actor>		ExplodeEffect;
var() sound				ExplodeSound;

var() class<Actor>		ExtraDamageClass; // If we stick to this class, do more damage.
var() float				ExtraDamageMultiplier;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		Leader, ProjNumber;
}

simulated function Destroyed()
{
	if (ProjectileEffect != None)
		ProjectileEffect.Destroy();

	if ( Level.NetMode != NM_DedicatedServer && EffectIsRelevant(Location, false) )
	{
		Spawn(ExplodeEffect,,, Location, rotator(StuckNormal));
		PlaySound(ExplodeSound,,2.5*TransientSoundVolume);
	}

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Velocity = Speed * Vector(Rotation);

	if (Level.NetMode != NM_DedicatedServer)
	{
		ProjectileEffect = spawn(ProjectileEffectClass, self,, Location, Rotation);
		ProjectileEffect.SetBase(self);
	}

	// On client - add this projectile in next free slot leaders list of projectiles.
	if( Role < ROLE_Authority )
	{
		if(Leader != None && ProjNumber != -1)
		{
			if(Leader.Projectiles.Length < ProjNumber + 1)
				Leader.Projectiles.Length = ProjNumber + 1;

			Leader.Projectiles[ ProjNumber ] = self;
		}
		else
		{
			bNetNotify = true; // We'll need the PostNetReceive to add this projectile to its leader.
		}
	}
}

simulated event PostNetReceive()
{
	if( Leader != None && ProjNumber != -1 )
	{
		if(Leader.Projectiles.Length < ProjNumber + 1)
			Leader.Projectiles.Length = ProjNumber + 1;

		Leader.Projectiles[ ProjNumber ] = self;

		bNetNotify = false; // Don't need PostNetReceive any more.
	}
}

simulated function ProcessTouch(actor Other, vector HitLocation)
{
	//Don't hit the player that fired me
	if (Other == Instigator || (Vehicle(Instigator) != None && Other == Vehicle(Instigator).Driver))
		return;

	// If we hit some stuff - just blow up straight away.
	if( Other.IsA('Projectile') || Other.bBlockProjectiles )
	{
		if(Role == ROLE_Authority)
			Leader.DetonateWeb();
	}
	else
	{
		StuckActor = Other;
		if ( (Level.NetMode != NM_Client) && (StuckActor != None) && ClassIsChildOf(StuckActor.Class, ExtraDamageClass)
			&& (Bot(Pawn(StuckActor).Controller) != None) && (Level.Game.GameDifficulty > 4 + 2 * FRand()) )
		{
			//about to blow up, so bot will bail
			Vehicle(StuckActor).VehicleLostTime = Level.TimeSeconds + 10;
			Vehicle(StuckActor).KDriverLeave(false);
		}
		StuckNormal = normal(HitLocation - Other.Location);
		GotoState('Stuck');
	}
}

simulated function HitWall(vector HitNormal, Actor Wall)
{
    if (Wall.bBlockProjectiles)
    {
        if (Role == ROLE_Authority)
            Leader.DetonateWeb();

        return;
    }

	StuckActor = Wall;
	StuckNormal = HitNormal;
	GoToState('Stuck');
}

// Server-side only
function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp(HitLocation);
	Destroy();
}

function BlowUp(vector HitLocation)
{
	NetUpdateTime = Level.TimeSeconds - 1;
	if (StuckActor != None && ClassIsChildOf(StuckActor.Class, ExtraDamageClass))
		Damage *= ExtraDamageMultiplier;

	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	MakeNoise(1.0);
}


state Stuck
{
	simulated function BeginState()
	{
		if (Leader != None)
			Leader.NotifyStuck();

		NetPriority = 1.5;
		NetUpdateTime = Level.TimeSeconds - 1;
		SetPhysics(PHYS_None);

		PlaySound(StuckSound,,2.5*TransientSoundVolume);

		if (StuckActor != None)
		{
			LastTouched = StuckActor;
			SetBase(StuckActor);
		}

		SetCollision(false, false);
		bCollideWorld = false;

		if (Role == ROLE_Authority)
			SetTimer(ExplodeDelay, false);
	}

	function Timer()
	{
		// Should only happen on Authority, where Leader should always be valid.
		if ( Leader != None )
			Leader.DetonateWeb();
		else
			Explode(Location,StuckNormal);
		NetUpdateTime = Level.TimeSeconds - 1;
	}
}

defaultproperties
{
     ProjectileEffectClass=Class'Onslaught.ONSRVWebProjectileEffect'
     ProjNumber=-1
     BeamSubEmitterIndex=2
     ExplodeDelay=3.000000
     StuckSound=Sound'ONSVehicleSounds-S.WebLauncher.WebStick'
     ExplodeEffect=Class'XEffects.GoopSparks'
     ExplodeSound=SoundGroup'WeaponSounds.BioRifle.BioRifleGoo1'
     ExtraDamageClass=Class'Onslaught.ONSHoverBike'
     ExtraDamageMultiplier=1.500000
     Speed=1750.000000
     Damage=65.000000
     DamageRadius=150.000000
     MomentumTransfer=10000.000000
     MyDamageType=Class'Onslaught.DamTypeONSWeb'
     DrawType=DT_None
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     NetUpdateFrequency=10.000000
}
