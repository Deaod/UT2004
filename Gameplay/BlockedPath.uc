//=============================================================================
// BlockedPath.
// 
//=============================================================================
class BlockedPath extends NavigationPoint
	placeable;

var bool bStartBlocked;

function PostBeginPlay()
{
	bStartBlocked = bBlocked;
	Super.PostBeginPlay();
}

function Reset()
{
	Super.Reset();
	bBlocked = bStartBlocked;
}

function Trigger( actor Other, pawn EventInstigator )
{
	bBlocked = !bBlocked;
}

defaultproperties
{
     bBlocked=True
     bBlockable=True
}
