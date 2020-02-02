class KeyInventory extends Inventory;

var KeyPickup MyPickup;

function UnLock(LockedObjective O)
{
	if ( !UnrealMPGameInfo(Level.Game).CanDisableObjective( O ) )
		O.DisableObjective(Pawn(Owner));
}

function Destroyed()
{
	MyPickup.GotoState('Pickup');
	Super.Destroyed();
}

defaultproperties
{
}
