//=============================================================================
// FX_Turret_IonCannon_FireEffect
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_Turret_IonCannon_FireEffect extends Actor;

#exec OBJ LOAD FILE=XEffectMat.utx

var Vector			HitLocation, HitNormal;
var FX_NewIonCore		IonCore;
var FX_NewIonPlasmaBeam	BeamEffect;

var		float StartTime;
var()	float DropTime;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        HitLocation, HitNormal;
}

function AimAt(Vector hl, Vector hn)
{
    HitLocation = hl;
    HitNormal = hn;
    if ( Level.NetMode != NM_DedicatedServer )
        SpawnEffects();
}

simulated function PostNetBeginPlay()
{
    if ( Role < ROLE_Authority )
        SpawnEffects();
}

simulated function SpawnEffects()
{
	local Rotator	R;

	R = Rotator( HitLocation - Location );
	SetRotation( R );
	BeamEffect = Spawn(class'FX_NewIonPlasmaBeam',,, Location, Rotation);
	IonCore = Spawn(class'FX_NewIonCore',,, Location, Rotation);

    GotoState('Drop');
}

state Drop
{
    simulated function BeginState()
    {
        StartTime = Level.TimeSeconds;
        SetTimer(DropTime, false);
    }

    simulated function Tick(float dt)
    {
        local float Delta;
        Delta = FMin((Level.TimeSeconds - StartTime) / DropTime, 1.0);
		
		IonCore.SetLocation( Location*(1.0-delta) + HitLocation*delta );
		BeamEmitter(BeamEffect.Emitters[0]).BeamDistanceRange.Max = VSize( Location - HitLocation ) * Delta;
		BeamEmitter(BeamEffect.Emitters[0]).BeamDistanceRange.Min = BeamEmitter(BeamEffect.Emitters[0]).BeamDistanceRange.Max;
    }

    simulated function Timer()
    {
        local Actor A;

		BeamEmitter(BeamEffect.Emitters[0]).BeamDistanceRange.Max = VSize( Location - HitLocation );
		BeamEmitter(BeamEffect.Emitters[0]).BeamDistanceRange.Min = BeamEmitter(BeamEffect.Emitters[0]).BeamDistanceRange.Max;

		IonCore.Kill();

		A = Spawn(class'FX_Turret_IonCannon_BeamExplosion',,, HitLocation+HitNormal*32, Rotator(HitNormal) );
		A.RemoteRole = ROLE_None;
		GotoState('');
    }
}

defaultproperties
{
     DropTime=0.500000
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=160
     LightSaturation=140
     LightBrightness=255.000000
     LightRadius=12.000000
     DrawType=DT_None
     bDynamicLight=True
     bNetTemporary=True
     bAlwaysRelevant=True
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000
}
