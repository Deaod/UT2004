class InvasionSquad extends SquadAI;

var int IncomingWave;
var bool bHeavyAttack;

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
	local Bot B;
	local int i;
	local Monster P;

	if ( Killed == None )
		return;
		
	// if teammate killed, no need to update enemy list
	if ( (Team != None) && (Killed.PlayerReplicationInfo != None)
		&& (Killed.PlayerReplicationInfo.Team == Team) )
	{
		if ( IsOnSquad(Killed) )
		{
			for	( B=SquadMembers; B!=None; B=B.NextSquadMember )
				if ( (B != Killed) && (B.Pawn != None) )
				{
					B.SendMessage(None, 'OTHER', B.GetMessageIndex('MANDOWN'), 4, 'TEAM'); 
					break;
				}
		}
		return;
	}
	RemoveEnemy(KilledPawn);

	B = Bot(Killer);
	if ( (B != None) && (B.Squad == self) && (B.Enemy == None) && (B.Pawn != None) )
	{
		// if no enemies left, area secure
		for ( i=0; i<8; i++ )
			if ( Enemies[i] != None )
				return;
		IncomingWave = 0;
		ForEach DynamicActors(class'Monster',P)
			if ( (P.Health > 0) && VSize(B.Pawn.Location - P.Location) < 3000 )
				return;
		B.SendMessage(None, 'OTHER', 11, 12, 'TEAM');
	}
}

defaultproperties
{
     IncomingWave=-1
}
