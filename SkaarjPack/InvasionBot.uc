class InvasionBot extends xBot;

var bool bDamagedMessage;

/* YellAt()
Tell idiot to stop shooting me
*/
function YellAt(Pawn Moron)
{
	if ( (Enemy != None) || (FRand() < 0.7) )
		return;

	SendMessage(None, 'FRIENDLYFIRE', 0, 5, 'TEAM');
}	

function bool AllowVoiceMessage(name MessageType)
{
	if ( Level.TimeSeconds - OldMessageTime < 3 )
		return false;
	else
		OldMessageTime = Level.TimeSeconds;

	return true;
}

event SeeMonster(Pawn Seen)
{
	local Pawn CurrentEnemy;
	
	CurrentEnemy = Enemy;
	
	if ( !Seen.bAmbientCreature )
		SeePlayer(Seen);
	
	if ( Enemy != None )
	{	
		if (  CurrentEnemy == None )
		{
			if ( InvasionSquad(Squad).IncomingWave != Invasion(Level.Game).WaveNum )
			{
				SendMessage(None, 'OTHER', 14, 12, 'TEAM'); 
				InvasionSquad(Squad).IncomingWave = Invasion(Level.Game).WaveNum;
			}
		}
		else if ( (CurrentEnemy != Enemy) && (Pawn.Health < 80) && LineOfSightTo(CurrentEnemy) )
		{
			if ( InvasionSquad(Squad).bHeavyAttack )
				SendMessage(None, 'OTHER', 21, 12, 'TEAM'); 
			else
				SendMessage(None, 'OTHER', 22, 12, 'TEAM'); 
			InvasionSquad(Squad).bHeavyAttack = !InvasionSquad(Squad).bHeavyAttack;
		}
	}
}

defaultproperties
{
}
