//=============================================================================
// ASTurret_LinkTurret_Swivel
//=============================================================================

class ASTurret_LinkTurret_Swivel extends ASTurret_Minigun_Swivel;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

	// Hack to instance correctly the skeletal collision boxes
    GetBoneCoords('');
    SetCollision(false, false);
    SetCollision(true, true);
}

simulated function UpdateSwivelRotation( Rotator TurretRotation )
{
	local Rotator	CogRotation;

	CogRotation.Pitch = TurretRotation.Pitch;
	SetBoneRotation( 'SwivelCog', CogRotation );

	super.UpdateSwivelRotation( TurretRotation );
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'AS_VehiclesFull_M.LinkSwivel'
     DrawScale=0.300000
     CollisionRadius=96.000000
     CollisionHeight=100.000000
}
