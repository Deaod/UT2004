/* BossDM
designed for 1 vs 1 DM against boss bot that tries to stay just a little better than you
*/

class BossDM extends xDeathMatch
	CacheExempt;

var float BaseDifficulty;

event InitGame( string Options, out string Error )
{
    Super.InitGame(Options, Error);
    BaseDifficulty = GameDifficulty;
	bAdjustSkill = true;
	bForceRespawn = true;
}

function AdjustSkill(AIController B, PlayerController P, bool bWinner)
{
	if ( B.PlayerReplicationInfo.Score <= P.PlayerReplicationInfo.Score + 1 )
	{
		if ( bWinner )
		{
			if ( AdjustedDifficulty > BaseDifficulty + 1.5 )
				AdjustedDifficulty -= 0.2;
			return;
		}
		else if ( AdjustedDifficulty < BaseDifficulty + 4 )
			AdjustedDifficulty += 0.8;
	}
	else if ( bWinner )
	{
		if ( B.PlayerReplicationInfo.Score > P.PlayerReplicationInfo.Score + 4 )
			Bot(B).Accuracy *= 0.5;
		AdjustedDifficulty = FMax(BaseDifficulty, AdjustedDifficulty - 0.4);
	}

    B.Skill = AdjustedDifficulty;
}

defaultproperties
{
     bForceRespawn=True
     bAdjustSkill=True
     GameName="Championship Match"
     Acronym=
}
