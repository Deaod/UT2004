//=============================================================================
// Ammo.
//=============================================================================
class Ammo extends Pickup
	abstract
	native;

#exec Texture Import File=Textures\Ammo.pcx Name=S_Ammo Mips=Off MASKED=1

var() int AmmoAmount;

simulated static function UpdateHUD(HUD H)
{
	H.LastPickupTime = H.Level.TimeSeconds;
	H.LastAmmoPickupTime = H.LastPickupTime;
}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	local Inventory inv;
	local Weapon W;
	local float Desire;
	
	if ( Other.Weapon.AIRating >= 0.5 )
		return 0;
	
	for ( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		W = Weapon(Inv);
		if ( W != None )
		{
			Desire = W.DesireAmmo(InventoryType, true);
			if ( Desire != 0 )
				return Desire * MaxDesireability/PathWeight;
		}
	}
	return 0;
}

function float BotDesireability(Pawn Bot)
{
	local Inventory inv;
	local Weapon W;
	local float Desire;
	local Ammunition M;
	
	if ( Bot.Controller.bHuntPlayer )
		return 0;
	for ( Inv=Bot.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		W = Weapon(Inv);
		if ( W != None )
		{
			Desire = W.DesireAmmo(InventoryType, false);
			if ( Desire != 0 )
				return Desire * MaxDesireability;
		}
	}
	M = Ammunition(Bot.FindInventoryType(InventoryType));
	if ( (M != None) && (M.AmmoAmount >= M.MaxAmmo) )
		return -1;
	return 0.25 * MaxDesireability;
}

function inventory SpawnCopy( Pawn Other )
{
	local Inventory Copy;

	Copy = Super.SpawnCopy(Other);
	Ammunition(Copy).AmmoAmount = AmmoAmount;
	return Copy;
}

defaultproperties
{
     MaxDesireability=0.200000
     RespawnTime=30.000000
     PickupMessage="You picked up some ammo."
     CullDistance=4000.000000
     Texture=Texture'Engine.S_Ammo'
     AmbientGlow=128
}
