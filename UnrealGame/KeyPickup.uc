class KeyPickup extends Pickup
	notplaceable;

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	Copy = Super.SpawnCopy(Other);
	Copy.Tag = Tag;
	KeyInventory(Copy).MyPickup = self;
	return Copy;
}

State Sleeping
{
	ignores Touch;
Begin:
}

defaultproperties
{
     InventoryType=Class'UnrealGame.KeyInventory'
     RespawnTime=9999.000000
     PickupMessage="You picked up a Key."
}
