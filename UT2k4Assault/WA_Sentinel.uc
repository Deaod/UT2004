//=============================================================================
// WA_Sentinel
//=============================================================================

class WA_Sentinel extends xWeaponAttachment;

var FX_SpaceFighter_3rdpMuzzle			MuzFlash;
var	float								MuzzleScale;
var class<FX_SpaceFighter_3rdpMuzzle>	MuzzleFlashClass;


simulated function Destroyed()
{
    if ( MuzFlash != None )
        MuzFlash.Destroy();

    super.Destroyed();
}

simulated event ThirdPersonEffects()
{
	local vector	Start;

    if ( Level.NetMode != NM_DedicatedServer && Instigator != None && FlashCount > 0 )
	{
        if ( FiringMode == 0 )
        {
			// Muzzle Flash
			Start = GetFireStart();

			if ( MuzFlash == None )
			{
				// Spawn Team colored Muzzle Flash effect
				MuzFlash = Spawn(MuzzleFlashClass,,, Start, Instigator.Rotation);

				if ( MuzFlash != None )
				{
					MuzFlash.SetScale( MuzzleScale );
					MuzFlash.SetBase( Instigator );

					if ( Instigator.GetTeamNum() == 0 ) // Red color version
						MuzFlash.SetRedColor();
				}
			}
			else
			{
				// Revive dead particles...
				MuzFlash.Emitters[0].SpawnParticle( 3 );
			}
        }

		// have pawn play firing anim
		if ( Instigator != None && FiringMode == 0 && FlashCount > 0 )
		{
			Instigator.PlayFiring(1.0, '0');
		}
    }

    super.ThirdPersonEffects();
}


simulated function vector GetFireStart()
{
	local vector	X, Y, Z, MuzzleSpawnOffset;

	if ( Instigator != None && ASVehicle(Instigator) != None )
		MuzzleSpawnOffset = ASVehicle(Instigator).VehicleProjSpawnOffset;

	GetAxes( Instigator.Rotation, X, Y, Z );
    return Instigator.Location + X*MuzzleSpawnOffset.X + Y*MuzzleSpawnOffset.Y + Z*MuzzleSpawnOffset.Z;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     MuzzleScale=1.500000
     MuzzleFlashClass=Class'UT2k4Assault.FX_SpaceFighter_3rdpMuzzle'
     bRapidFire=True
     bAltRapidFire=True
     bHidden=True
     Mesh=SkeletalMesh'Weapons.LinkGun_3rd'
}
