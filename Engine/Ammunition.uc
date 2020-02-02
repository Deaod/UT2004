//=============================================================================
// Ammunition: the base class of weapon ammunition
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================

class Ammunition extends Inventory
	abstract
	native
	nativereplication;

var travel int MaxAmmo;						// Max amount of ammo
var travel int AmmoAmount;
var int InitialAmount; // sjs					// Amount of Ammo current available
var travel int PickupAmmo;					// Amount of Ammo to give when this is picked up for the first time	

// Used by Bot AI

var		bool	bRecommendSplashDamage;
var		bool	bTossed;
var		bool	bTrySplash;
var		bool	bLeadTarget;
var		bool	bInstantHit;
var		bool	bSplashDamage;	
var		bool	bTryHeadShot; 


// Damage and Projectile information

var class<Projectile> ProjectileClass;
var class<DamageType> MyDamageType;
var float WarnTargetPct;
var float RefireRate;

var Sound FireSound;

var float MaxRange; // for autoaim
var() Material IconFlashMaterial;

// Network replication
//

replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
		AmmoAmount;
}

simulated function CheckOutOfAmmo()
{
    if (AmmoAmount <= 0)
        Pawn(Owner).Weapon.OutOfAmmo();
}

simulated function bool UseAmmo(int AmountNeeded, optional bool bAmountNeededIsMax)
{
    if (bAmountNeededIsMax && AmmoAmount < AmountNeeded)
        AmountNeeded = AmmoAmount;
        
	if (AmmoAmount < AmountNeeded)
	{
		CheckOutOfAmmo();
        return false;   // Can't do it
    }
    
    AmmoAmount -= AmountNeeded;
    NetUpdateTime = Level.TimeSeconds - 1;
    
    if (Level.NetMode == NM_StandAlone || Level.NetMode == NM_ListenServer)
        CheckOutOfAmmo();
	
    return true;
}

simulated function bool HasAmmo()
{
	return ( AmmoAmount > 0 );
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Canvas.DrawText("Ammunition "$GetItemName(string(self))$" amount "$AmmoAmount$" Max "$MaxAmmo);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}
	
function bool HandlePickupQuery( pickup Item )
{
	if ( class == item.InventoryType ) 
	{
		if (AmmoAmount==MaxAmmo) 
			return true;
		item.AnnouncePickup(Pawn(Owner));
		AddAmmo(Ammo(item).AmmoAmount);
        item.SetRespawn(); 
		return true;				
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

// If we can, add ammo and return true.  
// If we are at max ammo, return false
//
function bool AddAmmo(int AmmoToAdd)
{
	if ( Level.GRI.WeaponBerserk > 1.0 )
		AmmoAmount = MaxAmmo;
	else if ( AmmoAmount < MaxAmmo )
		AmmoAmount = Min(MaxAmmo, AmmoAmount+AmmoToAdd);
    NetUpdateTime = Level.TimeSeconds - 1;
	return true;
}

defaultproperties
{
     InitialAmount=10
     MyDamageType=Class'Engine.DamageType'
     WarnTargetPct=0.500000
     RefireRate=0.500000
     NetUpdateFrequency=1.000000
}
