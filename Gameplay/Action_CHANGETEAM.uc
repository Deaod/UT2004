class ACTION_ChangeTeam extends ScriptedAction;

var(Action) int Team;

function bool InitActionFor(ScriptedController C)
{

	local PlayerReplicationInfo P;

	if (C.PlayerReplicationInfo==None)
	{
		P = c.spawn(class'PlayerReplicationInfo',C,,C.Pawn.Location, C.Pawn.Rotation);
		if (P==None)
			return false;

		C.PlayerReplicationInfo = P;
		C.Pawn.PlayerReplicationInfo=P;
		P = None;
	}

	C.bIsPlayer=true;
	C.Level.Game.GameReplicationInfo.Teams[Team].AddToTeam(c);

	return false;
}

defaultproperties
{
     ActionString="Change Team"
}
