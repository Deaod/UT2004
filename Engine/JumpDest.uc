//=============================================================================
// JumpDest.
// specifies positions that can be reached with greater than normal jump
// forced paths will check for greater than normal jump capability
// NOTE these have NO relation to JumpPads
//=============================================================================
class JumpDest extends NavigationPoint
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var bool bOptionalJumpDest;
var() bool bForceDoubleJump;	// hack for map fixing
var int NumUpstreamPaths;
var ReachSpec UpstreamPaths[8];
var vector NeededJump[8];
var float CalculatedGravityZ[8];

function int GetPathIndex(ReachSpec Path)
{
	local int i;

	if ( Path == None )
		return 0;

	for ( i=0; i<4; i++ )
		if ( UpstreamPaths[i] == Path )
			return i;
	return 0;
}

event int SpecialCost(Pawn Other, ReachSpec Path)
{
	local int Num;

	if ( Other.Physics == PHYS_Flying )
		return 100;
	if ( Vehicle(Other) != None )
		return 10000000;	
		
	Num = GetPathIndex(Path);
	if ( Abs(Other.JumpZ/Other.PhysicsVolume.Gravity.Z) >= Abs(NeededJump[Num].Z/CalculatedGravityZ[Num]) )
		return 100;

	return 10000000;
}

function DoJump(Pawn Other)
{
	Other.bWantsToCrouch = false;
	Other.Controller.MoveTarget = self;
	Other.Controller.Destination = Location;
	Other.bNoJumpAdjust = true;
	if ( bForceDoubleJump )
		Other.Velocity = Other.Controller.EAdjustJump(0,Other.Default.GroundSpeed);
	else
		Other.Velocity = Other.Controller.EAdjustJump(0,Other.GroundSpeed);
	Other.Acceleration = vect(0,0,0);
	Other.SetPhysics(PHYS_Falling);
	Other.Controller.SetFall();
	Other.DestinationOffset = CollisionRadius;
}

event bool SuggestMovePreparation(Pawn Other)
{
	local int Num;
	if ( Other.Controller == None )
		return false;

	Num = GetPathIndex(Other.Controller.CurrentPath);
	if ( Abs(Other.JumpZ/Other.PhysicsVolume.Gravity.Z) < Abs(NeededJump[Num].Z/CalculatedGravityZ[Num]) )
		return false;

	DoJump(Other);
	return false;
}

defaultproperties
{
     bSpecialForced=True
}
