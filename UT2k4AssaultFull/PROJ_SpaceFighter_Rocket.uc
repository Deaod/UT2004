//=============================================================================
// PROJ_SpaceFighter_Rocket
//=============================================================================

class PROJ_SpaceFighter_Rocket extends Projectile;

var bool		bHitWater, bWaterStart;
var vector		Dir;

// FX
var Emitter			TrailEmitter;
var class<Emitter>	TrailClass;

//Homing
var Vehicle			HomingTarget;
var vector			InitialDir;
var float			HomingAggressivity;
var	float			HomingCheckFrequency, HomingCheckCount;

replication
{
	reliable if (bNetInitial && Role==ROLE_Authority)
		HomingTarget;
}

simulated function Destroyed()
{
	if ( Role == Role_Authority && HomingTarget != None )
		HomingTarget.NotifyEnemyLostLock();

	if ( TrailEmitter != None )
		TrailEmitter.Destroy();

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if ( PhysicsVolume.bWaterVolume )
	{
		bHitWater = true;
		Velocity = 0.6 * Velocity;
	}
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	Dir = Vector(Rotation);

	// Add Instigator's velocity to projectile
	if ( Instigator != None )
	{
		Speed		= Instigator.Velocity Dot Dir;
		Velocity	= Speed * Dir + (Vect(0,0,-1)>>Instigator.Rotation) * 100.f;
	}

	SetTimer(0.33, false);
}

simulated function Timer()
{
	// Rockets is done falling, now it's flying
	SpawnTrail();

	Velocity = Speed * Dir;
	GotoState('Flying');
}


simulated function SpawnTrail()
{
	if ( Level.NetMode == NM_DedicatedServer || Instigator == None )
		return;

	TrailEmitter = Spawn(TrailClass,,, Location, Rotation);

    if ( TrailEmitter == None )
        return;

	if ( Instigator.GetTeamNum() == 0 ) // Red Team version
	{
		TrailEmitter.Emitters[0].Texture = Texture'AS_FX_TX.Trails.Trail_Red';
		TrailEmitter.Emitters[1].ColorScale[0].Color = class'Canvas'.static.MakeColor(200, 64, 64);
		TrailEmitter.Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor(200, 64, 64);
	}
	TrailEmitter.SetBase( Self );
}


state Flying
{
	simulated function Tick(float DeltaTime)
	{
		local vector	ForceDir;
		local float		VelMag;

		// Homing
		if ( HomingTarget != None && HomingTarget != Instigator && (default.LifeSpan-LifeSpan) > default.LifeSpan * 0.18 )
		{
			HomingCheckCount += DeltaTime;
			if ( HomingCheckCount > HomingCheckFrequency )
			{
				HomingCheckCount -= HomingCheckFrequency;

				if ( InitialDir == vect(0,0,0) )
					InitialDir = Normal(Velocity);

				ForceDir = Normal(HomingTarget.Location - Location);

				if ( (ForceDir Dot InitialDir ) > 0 )
				{
					VelMag			= VSize(Velocity);		
					ForceDir		= Normal(ForceDir * HomingAggressivity * VelMag + Velocity);
					Velocity		= VelMag * ForceDir;  
					Acceleration   += 5 * ForceDir; 
					HomingAggressivity += HomingAggressivity * 0.03;
				}
				else if ( Role == Role_Authority && HomingTarget != None )
				{
					HomingTarget.NotifyEnemyLostLock();
					HomingTarget = None;
				}

				// Update rocket so it faces in the direction its going.
				SetRotation( rotator(Velocity) );
			}
		}

		// Increase Speed progressively
		Speed		+= 2000.f * DeltaTime;
		Acceleration = vector(Rotation) * Speed;
	}

	simulated function Landed( vector HitNormal )
	{
		Explode(Location,HitNormal);
	}


	function BlowUp(vector HitLocation)
	{
		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, Location );
		MakeNoise(1.0);
	}
}


simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
	{
		//log("PROJ_SpaceFighter_Rocket::ProcessTouch Other:"@Other@"bCollideActors:"@Other.bCollideActors@"bBlockActors:"@Other.bBlockActors);
		Explode(HitLocation,Vect(0,0,1));
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;
	
	PlaySound(sound'WeaponSounds.BExplosion3',, 2.5*TransientSoundVolume);

	if ( TrailEmitter != None )
	{
		TrailEmitter.Kill();
		TrailEmitter = None;
	}

    if ( EffectIsRelevant(Location, false) )
    {
    	Spawn(class'NewExplosionA',,, HitLocation + HitNormal*16, rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();	
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation, rotator(HitNormal));

		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp( HitLocation + HitNormal * 2.f );
	Destroy();
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     TrailClass=Class'UT2k4AssaultFull.FX_SpaceFighter_Rocket_Trail'
     HomingAggressivity=0.250000
     HomingCheckFrequency=0.067000
     MaxSpeed=20000.000000
     Damage=400.000000
     DamageRadius=512.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'UT2k4AssaultFull.DamTypeSpaceFighterMissile'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RocketProj'
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=4.000000
     AmbientGlow=32
     SoundVolume=255
     SoundRadius=100.000000
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
