/*=============================================================================
// LadderVolumes, when touched, cause ladder supporting actors to use Phys_Ladder.
// note that underwater ladders won't be waterzones (no breathing problems)
============================================================================= */

class LadderVolume extends PhysicsVolume
	native;

var() name ClimbingAnimation, TopAnimation;	// name of animation to play when climbing this ladder
var() rotator WallDir;
var vector LookDir;
var vector ClimbDir;	// pawn can move in this direction (or reverse)
var const Ladder LadderList;		// list of Ladder actors associated with this LadderVolume
var() bool	bNoPhysicalLadder;	// if true, won't push into/keep player against geometry in lookdir
var() bool	bAutoPath;			// add top and bottom ladders automatically
var() bool  bAllowLadderStrafing;  // if true, players on ladder can strafe sideways

var Pawn PendingClimber;

simulated function PostBeginPlay()
{
	local Ladder L, M;
	local vector Dir;

	Super.PostBeginPlay();
	LookDir = vector(WallDir);
	if ( !bAutoPath && (LookDir.Z != 0) )
	{
		ClimbDir = vect(0,0,1);
		for ( L=LadderList; L!=None; L=L.LadderList )
			for ( M=LadderList; M!=None; M=M.LadderList )
				if ( M != L )
				{
					Dir = Normal(M.Location - L.Location);
					if ( (Dir dot ClimbDir) < 0 )
						Dir *= -1;
					ClimbDir += Dir;
				}

		ClimbDir = Normal(ClimbDir);
		if ( (ClimbDir Dot vect(0,0,1)) < 0 )
			ClimbDir *= -1;
	}
}

function bool InUse(Pawn Ignored)
{
	local Pawn StillClimbing;

	ForEach TouchingActors(class'Pawn',StillClimbing)
	{
		if ( (StillClimbing != Ignored) && StillClimbing.bCollideActors && StillClimbing.bBlockActors )
			return true;
	}

	if ( PendingClimber != None )
	{
		if ( (PendingClimber.Controller == None)
			|| !PendingClimber.bCollideActors || !PendingClimber.bBlockActors 
			|| (Ladder(PendingClimber.Controller.MoveTarget) == None)
			|| (Ladder(PendingClimber.Controller.MoveTarget).MyLadder != self) )
				PendingClimber = None;
	}
	return ( (PendingClimber != None) && (PendingClimber != Ignored) );
}

simulated event PawnEnteredVolume(Pawn P)
{
	local rotator PawnRot;

	Super.PawnEnteredVolume(P);
	if ( !P.CanGrabLadder() )
		return;

	PawnRot = P.Rotation;
	PawnRot.Pitch = 0;
	if ( (vector(PawnRot) Dot LookDir > 0.9)
		|| ((AIController(P.Controller) != None) && (Ladder(P.Controller.MoveTarget) != None)) )
		P.ClimbLadder(self);
	else if ( !P.bDeleteMe && (P.Controller != None) )
		spawn(class'PotentialClimbWatcher',P);
}

simulated event PawnLeavingVolume(Pawn P)
{
	local Controller C;

	if ( P.OnLadder != self )
		return;
	Super.PawnLeavingVolume(P);
	P.OnLadder = None;
	P.EndClimbLadder(self);
	if ( P == PendingClimber )
		PendingClimber = None;

	// tell all waiting pawns, if not in use
	if ( !InUse(P) )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( C.bPreparingMove && (Ladder(C.MoveTarget) != None)
				&&(Ladder(C.MoveTarget).MyLadder == self) )
			{
				C.bPreparingMove = false;
				PendingClimber = C.Pawn;
				return;
			}
	}
}

simulated event PhysicsChangedFor(Actor Other)
{
	if ( (Other.Physics == PHYS_Falling) || (Other.Physics == PHYS_Ladder) || Other.bDeleteMe || (Pawn(Other) == None) || (Pawn(Other).Controller == None) )
		return;
	spawn(class'PotentialClimbWatcher',Other);
}

defaultproperties
{
     ClimbDir=(Z=1.000000)
     bAutoPath=True
     RemoteRole=ROLE_SimulatedProxy
}
