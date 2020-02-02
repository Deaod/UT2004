//=============================================================================
// WA_SpaceFighter
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class WA_SpaceFighter extends xWeaponAttachment;


var FX_SpaceFighter_3rdpMuzzle	MuzFlash[2];
var	float						MuzzleScale;
var	bool						bSwitch;

var class<FX_SpaceFighter_3rdpMuzzle>		MuzzleFlashClass;

var byte	OldSpawnHitCount;
var vector	mOldHitLocation;
var float	LastFireTime;


simulated function Destroyed()
{
    if ( MuzFlash[0] != None )
        MuzFlash[0].Destroy();

	if ( MuzFlash[1] != None )
        MuzFlash[1].Destroy();

    super.Destroyed();
}

/* UpdateHit
- used to update properties so hit effect can be spawn client side
*/
function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal)
{
	SpawnHitCount++;
	mHitLocation	= HitLocation;
	mHitActor		= HitActor;
	mHitNormal		= HitNormal;
}


simulated event ThirdPersonEffects()
{
	bSwitch = ( (FlashCount % 2) == 1 );

    if ( Level.NetMode != NM_DedicatedServer && Instigator != None && FlashCount > 0 )
	{
        if ( FiringMode == 0 )
        {
			if ( bSwitch )
				MuzzleFlashEffect( 0, 1 );		// Right Muzzle
			else
				MuzzleFlashEffect( 1,-1 );		// Left Muzzle
        }

		// have pawn play firing anim
		if ( Instigator != None && FiringMode == 0 && FlashCount > 0 )
		{
			if ( bSwitch )
				Instigator.PlayFiring(1.0, '1');
			else
				Instigator.PlayFiring(1.0, '0');
		}
    }

    super.ThirdPersonEffects();
}


simulated function MuzzleFlashEffect( int number, float fSide )
{
	local vector					Start;

	Start = GetFireStart( fSide );

    if ( MuzFlash[number] == None )
    {
		// Spawn Team colored Muzzle Flash effect
		MuzFlash[number] = Spawn(MuzzleFlashClass,,, Start, Instigator.Rotation);

		if ( MuzFlash[number] != None )
		{
			MuzFlash[number].SetScale( MuzzleScale );
			MuzFlash[number].SetBase( Instigator );

			if ( Instigator.GetTeamNum() == 0 ) // Red color version
				MuzFlash[number].SetRedColor();
		}
    }
	else
	{
		// Revive dead particles...
		MuzFlash[number].Emitters[0].SpawnParticle( 3 );
	}

	PlayFireFX( fSide );
}


simulated function PlayFireFX( float fSide )
{
	local vector					Start, HL, HN;
	local FX_PlasmaImpact			FX_Impact;
	local Actor						HitActor;

	if ( Instigator != None && ASVehicle_SpaceFighter(Instigator) != None )
	{
		Start = GetFireStart( fSide );
		HitActor = ASVehicle_SpaceFighter(Instigator).CalcWeaponFire( HL, HN );
		Spawn(class'UT2k4AssaultFull.FX_SpaceFighter_InstantHitLaser', Instigator, , Start, Rotator(HL - Start) );
	}

	// Impact effect
	if ( OldSpawnHitCount != SpawnHitCount )
	{
		OldSpawnHitCount = SpawnHitCount;
		GetHitInfo();
		
		if ( EffectIsRelevant(mHitLocation, false) && mHitNormal != vect(0,0,0) )
		{
			FX_Impact = Spawn(class'FX_PlasmaImpact',,, mHitLocation + mHitNormal * 2, rotator(mHitNormal));

			if ( Instigator != None && Instigator.GetTeamNum() == 0 )
				FX_Impact.SetRedColor();

			FX_Impact.PlaySound(Sound'WeaponSounds.BioRifle.BioRifleGoo2');
			
			if ( mHitActor != None && mHitActor.IsA('Pawn') )
			{
				FX_Impact.SetScale( 2.5 );
				FX_Impact.SetBase( mHitActor );
			}
			else
				FX_Impact.SetScale( 1.5 );
		}
	}
}


simulated function vector GetFireStart( float fSide )
{
	local vector	X, Y, Z, MuzzleSpawnOffset;

	if ( Instigator != None && ASVehicle(Instigator) != None )
		MuzzleSpawnOffset = ASVehicle(Instigator).VehicleProjSpawnOffset;

	GetAxes( Instigator.Rotation, X, Y, Z );
    return Instigator.Location + X*MuzzleSpawnOffset.X + fSide*Y*MuzzleSpawnOffset.Y + Z*MuzzleSpawnOffset.Z;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     MuzzleScale=1.000000
     MuzzleFlashClass=Class'UT2k4Assault.FX_SpaceFighter_3rdpMuzzle'
     bRapidFire=True
     bAltRapidFire=True
     bHidden=True
     Mesh=SkeletalMesh'Weapons.LinkGun_3rd'
}
