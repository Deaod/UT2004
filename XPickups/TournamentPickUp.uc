//=============================================================================
// TournamentPickup.
//=============================================================================
class TournamentPickup extends Pickup;

function RespawnEffect()
{
	spawn(class'PlayerSpawnEffect');
}

defaultproperties
{
     bAmbientGlow=True
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
