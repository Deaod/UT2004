//=============================================================================
// MiniHealthPack
//=============================================================================
class MiniHealthPack extends TournamentHealth;

// todo: need custom sound effect for this!

defaultproperties
{
     HealingAmount=5
     bSuperHeal=True
     MaxDesireability=0.300000
     PickupMessage="You picked up a Health Vial +"
     PickupSound=Sound'PickupSounds.HealthPack'
     PickupForce="HealthPack"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XPickups_rc.MiniHealthPack'
     CullDistance=4500.000000
     Physics=PHYS_Rotating
     DrawScale=0.060000
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     CollisionRadius=24.000000
     RotationRate=(Yaw=24000)
}
