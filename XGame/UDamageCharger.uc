//=============================================================================
// UDamageCharger.
//=============================================================================
class UDamageCharger extends xPickupBase;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetLocation(Location + vect(0,0,-1)); // adjust because reduced drawscale
}

defaultproperties
{
     PowerUp=Class'XPickups.UDamagePack'
     SpawnHeight=60.000000
     bDelayedSpawn=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_rc.ShieldChargerMesh'
     Texture=None
     DrawScale=0.800000
}
