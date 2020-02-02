//=============================================================================
// HealthPack
//=============================================================================
class HealthPack extends TournamentHealth
	notplaceable;

#exec OBJ LOAD FILE=PickupSounds.uax
#exec OBJ LOAD FILE=E_Pickups.usx

defaultproperties
{
     HealingAmount=25
     PickupSound=Sound'PickupSounds.HealthPack'
     PickupForce="HealthPack"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'E_Pickups.Health.MidHealth'
     CullDistance=6500.000000
     Physics=PHYS_Rotating
     DrawScale=0.300000
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     TransientSoundVolume=0.350000
     RotationRate=(Yaw=24000)
}
