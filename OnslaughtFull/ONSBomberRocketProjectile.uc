//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSBomberRocketProjectile extends Projectile;

var xEmitter SmokeTrail;
var Effects Corona;
var float AccelerationAddPerSec;
var bool bLockedOn;
var Actor HomingTarget;

replication
{
	reliable if (Role == ROLE_Authority)
		HomingTarget, bLockedOn;
}

simulated function Destroyed()
{
	if ( SmokeTrail != None )
		SmokeTrail.mRegen = False;
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'RocketTrailSmoke',self);
		Corona = Spawn(class'RocketCorona',self);
	}

	Acceleration = vector(Rotation);
	if (PhysicsVolume.bWaterVolume)
		Velocity=0.6*Velocity;

	SetTimer(0.1, True);
	Super.PostBeginPlay();
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
//    if ( EffectIsRelevant(Location,false) )
//    {
//    	Spawn(class'NewExplosionA',,,HitLocation + HitNormal*20,rotator(HitNormal));
//        Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
//		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
//			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
//    }
	if (Level.NetMode != NM_Client)
		spawn(class'ONSAVRiLRocketExplosion',,,HitLocation,rotator(HitNormal));
	BlowUp(HitLocation);
	Destroy();
}

simulated function Timer()
{
    local vector ForceDir;
    local float VelMag;

    if (Role == ROLE_Authority)
    {
        // Dampen Lateral Velocity
//        VelMag = VSize(Velocity);
////        Velocity -= Normal(Velocity) * 0.1 * (Velocity Dot vector(Rotation));\
//        Velocity -= Normal(Velocity - Vector(Rotation) * (Velocity Dot Vector(Rotation))) * 250.0;

    	if (Instigator != None && Instigator.Controller != None && ONSAVRiL(Instigator.Weapon) != None)
    	{
    		bLockedOn = ONSAVRiL(Instigator.Weapon).bLockedOn;
    		HomingTarget = ONSAVRiL(Instigator.Weapon).HomingTarget;
    	}
    	else
    		bLockedOn = False;
    }

    if (bLockedOn && HomingTarget != None)
    {
    	// Do normal guidance to target.
    	ForceDir = Normal(HomingTarget.Location - Location);

    	ForceDir = Normal(ForceDir * 0.7 * VelMag + Velocity);
    	Velocity =  VelMag * ForceDir;
    	Acceleration += 5 * ForceDir;

    	// Update rocket so it faces in the direction its going.
    	SetRotation(rotator(Velocity));
    }
}

simulated function Tick(float deltaTime)
{
	if (VSize(Velocity) >= MaxSpeed)
	{
		Acceleration = vect(0,0,0);
		disable('Tick');
	}
	else
		Acceleration += Normal(Velocity) * (AccelerationAddPerSec * deltaTime);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if (Damage > 0)
		Explode(HitLocation, vect(0,0,0));
}

defaultproperties
{
     AccelerationAddPerSec=8000.000000
     Speed=400.000000
     MaxSpeed=15000.000000
     Damage=100.000000
     DamageRadius=110.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'Onslaught.DamTypeONSAVRiLRocket'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMWeaponsSM.AVRiLGroup.AVRiLprojectileSM'
     bNetTemporary=False
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=7.000000
     DrawScale=0.125000
     AmbientGlow=96
     SoundVolume=255
     SoundRadius=100.000000
     bProjTarget=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
