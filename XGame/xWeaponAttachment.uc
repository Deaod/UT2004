class xWeaponAttachment extends WeaponAttachment;

// player animation specification
var() bool bHeavy;
var() bool bRapidFire;
var() bool bAltRapidFire;
var vector mHitNormal;
var actor mHitActor;
var Weapon LitWeapon;

simulated function GetHitInfo()
{
	local vector HitLocation, Offset;
	
	// if standalone, already have valid HitActor and HitNormal
	if ( Level.NetMode == NM_Standalone )
		return;
	Offset = 20 * Normal(Instigator.Location - mHitLocation);
	mHitActor = Trace(HitLocation,mHitNormal,mHitLocation-Offset,mHitLocation+Offset, false);
    NetUpdateTime = Level.TimeSeconds - 1;
}

simulated function Hide(bool NewbHidden)
{
	bHidden = NewbHidden;
}

simulated event ThirdPersonEffects()
{
    if (Level.NetMode != NM_DedicatedServer)
    {
		if ( xPawn(Instigator) == None )
			return;
        if (FlashCount == 0)
        {
            xPawn(Instigator).StopFiring();
        }
        else if (FiringMode == 0)
        {
            xPawn(Instigator).StartFiring(bHeavy, bRapidFire);
        }
        else
        {
            xPawn(Instigator).StartFiring(bHeavy, bAltRapidFire);
        }
    }
}

simulated function PostNetBeginPlay()
{
    if ( Instigator != None && xPawn(Instigator) != None ) 
    {
        xPawn(Instigator).SetWeaponAttachment(self);
    }
}

simulated function Vector GetTipLocation()
{
    local Coords C;
    C = GetBoneCoords('tip');
    return C.Origin;
}

simulated function WeaponLight()
{
    if ( (FlashCount > 0) && !Level.bDropDetail && (Instigator != None) 
		&& ((Level.TimeSeconds - LastRenderTime < 0.2) || (PlayerController(Instigator.Controller) != None)) )
    {
		if ( Instigator.IsFirstPerson() )
		{
			LitWeapon = Instigator.Weapon;
			LitWeapon.bDynamicLight = true;
		}
		else
			bDynamicLight = true;
        SetTimer(0.15, false);
    }
    else 
		Timer();
}

function InitFor(Inventory I)
{
	Super.InitFor(I);
	
	if ( xPawn(I.Instigator) == None )
		return;
	
	if ( xPawn(I.Instigator).bClearWeaponOffsets )
		SetRelativeLocation(vect(0,0,0));	
}

simulated function Timer()
{
	if ( LitWeapon != None )
	{
		LitWeapon.bDynamicLight = false;
		LitWeapon = None;
	}
    bDynamicLight = false;
}

defaultproperties
{
     DrawScale=0.400000
}
