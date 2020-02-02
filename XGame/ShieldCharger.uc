//=============================================================================
// ShieldCharger.
//=============================================================================
class ShieldCharger extends xPickupBase;

function PostbeginPlay()
{
	if ( (Level.Title ~= "IronDeity") && (Name == 'ShieldCharger0') )
	{	
		SpawnHeight = 130.0;
		Super.PostBeginPlay();
		if ( myPickup != None )
			myPickup.PrePivot.Z = 85.0; 
		return;
	}
	
	Super.PostBeginPlay();
	SetLocation(Location + vect(0,0,-2)); // adjust because reduced drawscale
}

defaultproperties
{
     PowerUp=Class'XPickups.ShieldPack'
     SpawnHeight=45.000000
     bDelayedSpawn=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_rc.ShieldChargerMesh'
     Texture=None
     DrawScale=0.700000
}
