//=============================================================================
// ASVehicle_Sentinel_Ceiling_Swivel
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ASVehicle_Sentinel_Ceiling_Swivel extends ASTurret_Minigun_Swivel;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

	// Hack to instance correctly the skeletal collision boxes
    GetBoneCoords('');
    SetCollision(false, false);
    SetCollision(true, true);
}

auto state Sleeping
{
	simulated event AnimEnd( int Channel )
	{
		if ( ASVehicle_Sentinel(Owner).bActive )
			GotoState('Opening');
		else
			PlayAnim('IdleClosed', 4, 0.0);
	}

	simulated function BeginState()
	{
		AnimEnd( 0 );
	}
}

state Active
{
	simulated event AnimEnd( int Channel )
	{
		GotoState('Active');
	}

	simulated function BeginState()
	{
		PlayAnim('IdleOpen', 4, 0.0);
	}
}

state Opening
{
	simulated function BeginState()
	{
		PlayAnim('Open', 0.33, 0.0);
	}
}

state Closing
{
	simulated function BeginState()
	{
		PlayAnim('Close', 0.33, 0.0);
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'AS_Vehicles_M.CeilingTurretBase'
     DrawScale=0.500000
     CollisionRadius=96.000000
     CollisionHeight=100.000000
}
