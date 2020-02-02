//=============================================================================
// Weapon_Turret_IonCannon
//=============================================================================

class Weapon_Turret_IonCannon extends Weapon
    config(user)
    HideDropDown
	CacheExempt;

#exec OBJ LOAD FILE=..\Animations\AS_VehiclesFull_M.ukx

simulated function bool IsFiring() // called by pawn animation, mostly
{
    return  ( FireMode[0].IsFiring() || FireMode[1].IsFiring() );
}

simulated function ClientStartFire(int mode)
{
	local PlayerController PC;

    if ( mode == 1 )
    {
		PC = PlayerController(Instigator.Controller);
		if ( PC.DesiredFOV == PC.DefaultFOV )
			PC.DesiredFOV = ASTurret(Instigator).MinPlayerFOV;
		else
			PC.DesiredFOV = PC.DefaultFOV;
		PlayerController(Instigator.Controller).bAltFire = 0;
    }
    else
        super.ClientStartFire( mode );
}

simulated function PawnUnpossessed()
{
	if ( (Instigator != None) && (PlayerController(Instigator.Controller) != None) )
		PlayerController(Instigator.Controller).DesiredFOV = PlayerController(Instigator.Controller).DefaultFOV;
}

/* BestMode() choose between regular or alt-fire */
function byte BestMode()
{
	return 0;
}

simulated function bool HasAmmo()
{
    return true;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'UT2k4AssaultFull.FM_Turret_IonCannon_Fire'
     FireModeClass(1)=Class'UT2k4Assault.FM_Turret_Minigun_AltFire'
     AIRating=0.680000
     CurrentRating=0.680000
     bCanThrow=False
     bNoInstagibReplace=True
     Priority=1
     SmallViewOffset=(Z=-40.000000)
     CenteredRoll=0
     PlayerViewOffset=(Z=-40.000000)
     AttachmentClass=Class'UT2k4AssaultFull.WA_Turret_IonCannon'
     ItemName="Ion Cannon Turret weapon"
     DrawType=DT_None
}
