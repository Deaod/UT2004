//=============================================================================
// ShieldPack
//=============================================================================
class ShieldPack extends ShieldPickup;

#exec OBJ LOAD FILE=PickupSounds.uax
#exec OBJ LOAD FILE=E_Pickups.usx

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheStaticMesh(StaticMesh'E_Pickups.RegShield');
}

defaultproperties
{
     ShieldAmount=50
     bPredictRespawns=True
     PickupSound=Sound'PickupSounds.ShieldPack'
     PickupForce="ShieldPack"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'E_Pickups.General.RegShield'
     Physics=PHYS_Rotating
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     CollisionRadius=32.000000
     RotationRate=(Yaw=24000)
}
