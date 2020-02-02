//=============================================================================
// WA_Turret_IonCannon
//=============================================================================
// Created by Laurent Delayen (C) 2003 Epic Games
//=============================================================================

class WA_Turret_IonCannon extends xWeaponAttachment;


var	byte	ChargeCount, ReleaseCount;
var	byte	OldChargeCount, OldReleaseCount;

var ASTurret_IonCannon	CannonPawn;

// FX
var float LastFXUpdate;

var FX_Turret_IonCannon_LaserBeam	LaserBeam;
var	float							BeamSize;

var FX_Turret_IonCannon_ChargeBeam	ChargeBeam[2];
var float							ChargeBeamSize;
var	vector							RightChargeBeamOffset;

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && (!bNetOwner || bDemoRecording || bRepClientDemo) && (Role==ROLE_Authority) )
		ChargeCount, ReleaseCount;

}

simulated event PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	UpdateInstigator();
}

simulated function Destroyed()
{
	StopChargeFX();
	super.Destroyed();
}

simulated event PostNetReceive()
{
	UpdateInstigator();

	if ( ChargeCount != OldChargeCount )
	{
		OldChargeCount = ChargeCount;
		PlayCharge();
	}
	if ( ReleaseCount != OldReleaseCount )
	{
		OldReleaseCount = ReleaseCount;
		PlayRelease();
	}
}


simulated event ThirdPersonEffects()
{
	UpdateInstigator();

	if ( CannonPawn != None && FlashCount > 0 )
		PlayFire();
}


simulated function UpdateInstigator()
{
	if ( Instigator != None && CannonPawn != Instigator )
	{
		CannonPawn = ASTurret_IonCannon(Instigator);
		StopChargeFX();
	}
}

simulated function PlayCharge()
{
	if ( CannonPawn != None )
		CannonPawn.PlayCharge();
	StartChargeFX();
}

simulated function PlayRelease()
{
	if ( CannonPawn != None )
		CannonPawn.PlayRelease();
	StopChargeFX();
}

simulated function PlayFire()
{
	if ( Instigator != None && FiringMode == 0 )
	{
		StopChargeFX();
		Instigator.PlayFiring(1.0, '0');
	}
}

simulated function StartChargeFX()
{
	BeamSize		= 0.f;
	ChargeBeamSize	= 0.f;
	LastFXUpdate	= Level.TimeSeconds;
	SetTimer( 0.01f, false );
}

simulated function StopChargeFX()
{
	SetTimer( 0.f, false );
	if ( LaserBeam != None )
		LaserBeam.Destroy();

	if ( ChargeBeam[0] != None )
		ChargeBeam[0].Destroy();

	if ( ChargeBeam[1] != None )
		ChargeBeam[1].Destroy();
}

simulated function Timer()
{
	local float		UpdateFreq;

	UpdateInstigator();

	if ( CannonPawn == None )
	{
		StopChargeFX();
		return;
	}

	if ( LaserBeam == None && Role == Role_Authority )
		SpawnLaserBeam();

	UpdateChargeBeam();

	LastFXUpdate = Level.TimeSeconds;
	UpdateFreq = 0.02;

	if ( Level.bDropDetail || Level.DetailMode == DM_Low )
		UpdateFreq += 0.02;

	SetTimer( UpdateFreq, false );
}

simulated function SpawnLaserBeam()
{
	local vector	Start, HL;
	local rotator	Rot;

	UpdateLaserBeamLocation( Start, HL );

	Rot = Rotator( HL - Start );
	LaserBeam = Spawn(class'UT2k4AssaultFull.FX_Turret_IonCannon_LaserBeam', Self,, Start, Rot);
}

simulated function UpdateLaserBeamLocation( out vector Start, out vector HitLocation )
{
	local vector HN;

	Start = CannonPawn.GetFireStart();
	CannonPawn.CalcWeaponFire( HitLocation, HN );
}

simulated function UpdateChargeBeam()
{
	UpdateSingleChargeBeam( 0 );
	UpdateSingleChargeBeam( 1 );
}

simulated function UpdateSingleChargeBeam( byte n )
{
	local float		Dist;

	if ( ChargeBeam[n] == None )
	{
		//log("WA_Turret_IonCannon::UpdateChargeBeam Spawning ChargeBeam");
		ChargeBeam[n] = Spawn(class'UT2k4AssaultFull.FX_Turret_IonCannon_ChargeBeam');
		if ( ChargeBeam[n] != None )
		{
			CannonPawn.AttachToBone( ChargeBeam[n], 'BeamFront' );

			if ( n == 1 )
				ChargeBeam[n].SetRelativeLocation( RightChargeBeamOffset );
		}
	}

	if ( ChargeBeam[n] != None )
	{
		// Correct Length
		Dist = VSize( CannonPawn.GetBoneCoords( 'BeamFront' ).Origin - CannonPawn.GetBoneCoords( 'BeamRear' ).Origin );
		BeamEmitter(ChargeBeam[n].Emitters[0]).BeamDistanceRange.Min	= Dist;
		BeamEmitter(ChargeBeam[n].Emitters[0]).BeamDistanceRange.Max	= Dist;	
		SpriteEmitter(ChargeBeam[n].Emitters[2]).StartLocationOffset.X	= Dist;

		// Size Scale
		BeamEmitter(ChargeBeam[n].Emitters[0]).StartSizeRange.X.Min = 15.0 * BeamSize * 0.5;
		BeamEmitter(ChargeBeam[n].Emitters[0]).StartSizeRange.X.Max = 50.0 * BeamSize * 0.5;

		SpriteEmitter(ChargeBeam[n].Emitters[1]).StartSizeRange.X.Min =  75.0 * BeamSize * 0.5;
		SpriteEmitter(ChargeBeam[n].Emitters[1]).StartSizeRange.X.Max = 100.0 * BeamSize * 0.5;

		SpriteEmitter(ChargeBeam[n].Emitters[2]).StartSizeRange.X.Min =  75.0 * BeamSize * 0.5;
		SpriteEmitter(ChargeBeam[n].Emitters[2]).StartSizeRange.X.Max = 100.0 * BeamSize * 0.5;
	}

}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RightChargeBeamOffset=(Y=200.000000)
     bHidden=True
     bNetNotify=True
}
