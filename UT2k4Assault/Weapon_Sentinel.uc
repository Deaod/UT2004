//=============================================================================
// Weapon_Sentinel
//=============================================================================

class Weapon_Sentinel extends Weapon
    config(user)
    HideDropDown
	CacheExempt;

simulated function bool HasAmmo()
{
    return true;
}

function byte BestMode()
{
	return 0;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'UT2k4Assault.FM_Sentinel_Fire'
     FireModeClass(1)=Class'UT2k4Assault.FM_Sentinel_Fire'
     AIRating=0.680000
     CurrentRating=0.680000
     bCanThrow=False
     bNoInstagibReplace=True
     Priority=1
     SmallViewOffset=(Z=-40.000000)
     CenteredRoll=0
     PlayerViewOffset=(Z=-40.000000)
     AttachmentClass=Class'UT2k4Assault.WA_Sentinel'
     ItemName="Sentinel weapon"
     DrawType=DT_None
     DrawScale=3.000000
     AmbientGlow=64
}
