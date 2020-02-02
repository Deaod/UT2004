//=============================================================================
// SuperShieldPack
//=============================================================================
class SuperShieldPack extends ShieldPickup
	notplaceable;

#exec OBJ LOAD FILE=E_Pickups.usx

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheStaticMesh(StaticMesh'E_Pickups.SuperShield');
}

defaultproperties
{
     ShieldAmount=100
     RespawnTime=60.000000
     PickupMessage="You picked up a Super Shield Pack +"
     PickupSound=Sound'PickupSounds.LargeShieldPickup'
     PickupForce="LargeShieldPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'E_Pickups.General.SuperShield'
     Physics=PHYS_Rotating
     DrawScale=0.600000
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     TransientSoundRadius=450.000000
     CollisionRadius=32.000000
     RotationRate=(Yaw=24000)
}
