//=============================================================================
// LiftExit.
//=============================================================================
class LiftExit extends NavigationPoint
	placeable
	native;

#exec Texture Import File=Textures\Lift_exit.pcx Name=S_LiftExit Mips=Off MASKED=1

var() name LiftTag;
var	Mover MyLift;
var() byte SuggestedKeyFrame;	// mover keyframe associated with this exit - optional
var byte KeyFrame;
var(LiftJump) bool bLiftJumpExit;
var(LiftJump) bool bNoDoubleJump;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( bLiftJumpExit && (MyLift != None) )
	{
		if ( Level.Game.GameDifficulty < 4 )
			ExtraCost = 10000000;
		MyLift.bJumpLift = true;
	}
}

function bool CanBeReachedFromLiftBy(Pawn Other)
{
	local float RealJumpZ;
	
	if ( bLiftJumpExit )
	{
		if ( (MyLift.Velocity.Z < 100) || (MyLift.KeyNum == 0)  )
			return false;
		RealJumpZ = Other.JumpZ;
		if ( !bNoDoubleJump )
			Other.JumpZ = Other.JumpZ * 1.5;
		Other.JumpZ += MyLift.Velocity.Z;
		Other.bWantsToCrouch = false;
		Other.Controller.MoveTarget = self;
		Other.Controller.Destination = Location;
		Other.bNoJumpAdjust = true;
		Other.Velocity = SuggestFallVelocity(Location + vect(0,0,100), Other.Location, Other.JumpZ, Other.GroundSpeed);
		Other.Acceleration = vect(0,0,0);
		Other.SetPhysics(PHYS_Falling);
		Other.Controller.SetFall();
		Other.DestinationOffset = CollisionRadius;
		Other.JumpZ = RealJumpZ;
		if ( !bNoDoubleJump )
			Other.Controller.SetDoubleJump();
		return true;
	}
	
	return ( (Location.Z < Other.Location.Z + Other.CollisionHeight)
			 && Other.LineOfSightTo(self) );
}

event bool SuggestMovePreparation(Pawn Other)
{
	local Controller C;
	
	if ( (MyLift == None) || (Other.Controller == None) )
		return false;
	if ( Other.Physics == PHYS_Flying )
	{
		if ( Other.AirSpeed > 0 )
			Other.Controller.MoveTimer = 2+ VSize(Location - Other.Location)/Other.AirSpeed;
		return false;
	}
	if ( (Other.Base == MyLift)
			|| ((LiftCenter(Other.Anchor) != None) && (LiftCenter(Other.Anchor).MyLift == MyLift)
				&& (Other.ReachedDestination(Other.Anchor))) )
	{
		// if pawn is on the lift, see if it can get off and go to this lift exit
		if ( CanBeReachedFromLiftBy(Other) )
			return false;

		// make pawn wait on the lift
		Other.DesiredRotation = rotator(Location - Other.Location);
		Other.Controller.WaitForMover(MyLift);
		return true;
	}
	else
	{
		for ( C=Level.ControllerList; C!=None; C=C.nextController )
			if ( (C.Pawn != None) && (C.PendingMover == MyLift) && C.SameTeamAs(Other.Controller) && C.Pawn.ReachedDestination(self) )
			{
				Other.DesiredRotation = rotator(Location - Other.Location);
				Other.Controller.WaitForMover(MyLift);
				return true;
			}
	}
	return false;
}

defaultproperties
{
     SuggestedKeyFrame=255
     bNeverUseStrafing=True
     bForceNoStrafing=True
     bSpecialMove=True
     Texture=Texture'Engine.S_LiftExit'
}
