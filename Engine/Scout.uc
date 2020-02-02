//=============================================================================
// Scout used for path generation.
//=============================================================================
class Scout extends Pawn
	native
	notplaceable;

var const float MaxLandingVelocity;

simulated function PreBeginPlay()
{
	Destroy(); //scouts shouldn't exist during play
}

defaultproperties
{
     AccelRate=1.000000
     RemoteRole=ROLE_None
     CollisionRadius=52.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bProjTarget=False
     bPathColliding=True
}
