class ACTION_TeleportToPoint extends LatentScriptedAction;

var(Action) name DestinationTag;	// tag of destination - if none, then use the ScriptedSequence
var(Action) bool bPlaySpawnEffect;

var Actor Dest;

function bool InitActionFor(ScriptedController C)
{
	local Pawn P;
	Dest = C.SequenceScript.GetMoveTarget();

	if ( DestinationTag != '' )
	{
		ForEach C.AllActors(class'Actor',Dest,DestinationTag)
			break;
	}
	P = C.GetInstigator();
	P.SetLocation(Dest.Location);
	P.SetRotation(Dest.Rotation);
	P.OldRotYaw = P.Rotation.Yaw;
	if ( bPlaySpawnEffect )
		P.PlayTeleportEffect(false,true);
	return false;	
}

defaultproperties
{
}
