class UTJumpPad extends JumpPad
	placeable;

function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	if ( (Level.Game != None) && Level.Game.IsA('ONSOnslaughtGame') )
	{
		// fixme - useful for all gametypes, but only tested with Onslaught
		// should be in path creation code
		for ( i=0; i<PathList.Length; i++ )
			if ( PathList[i].End == JumpTarget )
			{
				PathList[i].Distance *= 0.5;
				break;
			}
	}
}

event Touch(Actor Other)
{
	if ( (UnrealPawn(Other) == None) || (Other.Physics == PHYS_None) )
		return;

	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;
}

event PostTouch(Actor Other)
{
	local Pawn P;
	local Bot B;

	Super.PostTouch(Other);

	P = UnrealPawn(Other);
	if ( P == None )
		return;

	B = Bot(P.Controller);	
	if ( (B != None) && (PhysicsVolume.Gravity.Z > PhysicsVolume.Default.Gravity.Z) )
		B.Focus = B.FaceActor(2);
}	

/*
defaultproperties
{
	JumpSound=sound'
}
*/

defaultproperties
{
}
