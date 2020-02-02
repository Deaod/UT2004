//=============================================================================
// FX_Turret_IonCannon_BeamFire
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_Turret_IonCannon_BeamFire extends Actor;

var()	Sound	FireSound;
var()	float	MinRange, MaxRange;
var()	float	MaxAngle;

var()	int					Damage;				// per wave
var()	float				MomentumTransfer;	// per wave
var()	float				DamageRadius;		// of final wave
var()	class<DamageType>	DamageType;

var		Vector		BeamDirection;
var		Vector		DamageLocation;
var		Vector		HitNormal;
var()	Vector		MarkLocation;
var		AvoidMarker Fear;

var()	class<FX_Turret_IonCannon_FireEffect> IonEffectClass;

// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view


function AimAt(Vector HL, Vector HN)
{
    HitNormal		= HN;
    MarkLocation	= HL;

    if ( Role == Role_Authority )
        GotoState('FireSequence');
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != instigator) && (Victims != self) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
			if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
		}
	}
	bHurtEntry = false;
}

state FireSequence
{
    function BeginState()
    {
        BeamDirection	= Normal(MarkLocation - Location);
        DamageLocation	= MarkLocation - BeamDirection * 200.0;
    }

    function SpawnEffect()
    {
        local FX_Turret_IonCannon_FireEffect IonBeamEffect;

        IonBeamEffect = Spawn(IonEffectClass,,, Location, Rotation);
        if ( IonBeamEffect != None )
        {
            IonBeamEffect.AimAt(MarkLocation, HitNormal ); //Normal(-1.f*BeamDirection)
        }
    }
    
    function ShakeView()
    {
        local Controller C;
        local PlayerController PC;
        local float Dist, Scale;

        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            PC = PlayerController(C);
            if ( PC != None && PC.ViewTarget != None && PC.ViewTarget.Base != None )
            {
                Dist = VSize(DamageLocation - PC.ViewTarget.Location);
                if ( Dist < DamageRadius * 2.0)
                {
                    if (Dist < DamageRadius)
                        Scale = 1.0;
                    else
                        Scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
                    C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
                }
            }
        }
    }

Begin:
    if ( Fear == None )
		Fear = Spawn(class'AvoidMarker',,, MarkLocation);
	if ( (Instigator != None) && (Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.Team != None) )
		Fear.TeamNum = Instigator.PlayerReplicationInfo.Team.TeamIndex;
    Fear.SetCollisionSize(DamageRadius, 200); 
    Fear.StartleBots();
    //Sleep(0.5);
    SpawnEffect();
    PlaySound(FireSound);
    Sleep(0.5);

    ShakeView();
    HurtRadius(Damage, DamageRadius*0.125, DamageType, MomentumTransfer, DamageLocation);
    Sleep(0.5);
	PlaySound(sound'WeaponSounds.redeemer_explosionsound');
    HurtRadius(Damage, DamageRadius*0.300, DamageType, MomentumTransfer, DamageLocation);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.475, DamageType, MomentumTransfer, DamageLocation);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.650, DamageType, MomentumTransfer, DamageLocation);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.825, DamageType, MomentumTransfer, DamageLocation);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*1.000, DamageType, MomentumTransfer, DamageLocation);
		
	if ( Fear != None )
		Fear.Destroy();

	Destroy();
}

defaultproperties
{
     FireSound=Sound'WeaponSounds.TAGRifle.IonCannonBlast'
     MinRange=1000.000000
     MaxRange=10000.000000
     MaxAngle=45.000000
     Damage=150
     MomentumTransfer=150000.000000
     DamageRadius=2000.000000
     DamageType=Class'UT2k4AssaultFull.DamTypeIonCannonBlast'
     IonEffectClass=Class'UT2k4AssaultFull.FX_Turret_IonCannon_FireEffect'
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     DrawType=DT_None
     RemoteRole=ROLE_None
     TransientSoundVolume=1.000000
     TransientSoundRadius=2000.000000
}
