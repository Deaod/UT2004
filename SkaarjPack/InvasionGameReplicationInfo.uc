class InvasionGameReplicationInfo extends GameReplicationInfo;

var byte WaveNumber,BaseDifficulty;

replication
{
	reliable if ( bNetInitial && (Role == ROLE_Authority) )
		BaseDifficulty;
	reliable if(Role == ROLE_Authority)
		WaveNumber;
}

defaultproperties
{
}
