//=============================================================================
// SuperShockRifle
//=============================================================================
class SuperShockRifle extends ShockRifle
	HideDropDown
	CacheExempt;

#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax
#exec OBJ LOAD FILE=XEffectMat.utx

simulated event RenderOverlays( Canvas Canvas )
{
    if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 1) )
		ConstantColor'UT2004Weapons.ShockControl'.Color = class'HUD'.Default.BlueColor;
	else
		ConstantColor'UT2004Weapons.ShockControl'.Color = class'HUD'.Default.RedColor;
	Super.RenderOverlays(Canvas);
}

simulated function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
    return true;
}

simulated function CheckOutOfAmmo()
{
}

function float GetAIRating()
{
	return AIRating;
}

simulated function bool StartFire(int mode)
{
	bWaitForCombo = false;
	return Super.StartFire(mode);
}

function float RangedAttackTime()
{
	return 0;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	return 0;
}

defaultproperties
{
     FireModeClass(0)=Class'XWeapons.SuperShockBeamFire'
     FireModeClass(1)=Class'XWeapons.SuperShockBeamFire'
     AIRating=1.000000
     bCanThrow=False
     PickupClass=Class'XWeapons.SuperShockRiflePickup'
     ItemName="Super Shock Rifle"
     bNetNotify=False
}
