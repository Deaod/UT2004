//=============================================================================
// SuperHealthPack
//=============================================================================
class SuperHealthPack extends TournamentHealth
	notplaceable;

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheStaticMesh(StaticMesh'E_Pickups.SuperKeg');
}

defaultproperties
{
     HealingAmount=100
     bSuperHeal=True
     MaxDesireability=2.000000
     bAmbientGlow=False
     bPredictRespawns=True
     RespawnTime=60.000000
     PickupMessage="You picked up a Big Keg O' Health +"
     PickupSound=Sound'PickupSounds.LargeHealthPickup'
     PickupForce="LargeHealthPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'E_Pickups.Health.SuperKeg'
     Physics=PHYS_Rotating
     DrawScale=0.400000
     AmbientGlow=64
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     bUnlit=True
     TransientSoundRadius=450.000000
     CollisionRadius=42.000000
     RotationRate=(Yaw=2000)
}
