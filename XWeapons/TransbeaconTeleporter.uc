class TransbeaconTeleporter extends Keypoint;

var() name JumpSpotTag;
var JumpSpot myJumpSpot;

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if ( JumpSpotTag != '' )
		ForEach AllActors(class'JumpSpot',myJumpSpot,JumpSpotTag)
			break;
}
	
event Touch(Actor Other)
{
	if ( (TransBeacon(Other) == None) || (myJumpSpot == None) )
		return;
		
	Other.SetLocation(myJumpSpot.Location);
	if ( TransBeacon(Other).Trail != None )
	    TransBeacon(Other).Trail.mRegen = false;
}
		

defaultproperties
{
     CollisionRadius=30.000000
     CollisionHeight=30.000000
     bCollideActors=True
}
