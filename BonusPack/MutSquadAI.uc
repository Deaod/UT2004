class MutSquadAI extends DMSquad;

// This only runs on server
function bool SetEnemy( Bot B, Pawn NewEnemy )
{
	local xMutantGame mutantGame;
	local pawn mutantPawn;
	local int i;

	mutantGame = xMutantGame(Level.Game);
	
	// If no-one is a mutant (or we are), or we are the bottom feeder, do as normal DM. 
	if( mutantGame.CurrentMutant == None || mutantGame.CurrentMutant == B || mutantGame.CurrentBottomFeeder == B )
		return Super.SetEnemy(B, NewEnemy);

	mutantPawn = mutantGame.CurrentMutant.Pawn;

	// ??? If there is a mutant, remove all non-mutant enemies.
	for(i=0; i<8; i++)
	{
		if(Enemies[i] != mutantPawn)
			RemoveEnemy(Enemies[i]);
	}

	// Return false if NewEnemy != mutant.
	if( NewEnemy != mutantGame.CurrentMutant.Pawn )
		return false;

	if ( !AddEnemy(NewEnemy) )
		return false;

	return FindNewEnemyFor(B,(B.Enemy !=None) && B.LineOfSightTo(SquadMembers.Enemy));
}

function bool FindNewEnemyFor(Bot B, bool bSeeEnemy)
{
	local xMutantGame mutantGame;
	local Pawn OldEnemy, MutantPawn;

	mutantGame = xMutantGame(Level.Game);

	// If no-one is a mutant (or we are), or we are the bottom feeder, do as normal DM. 
	if( mutantGame.CurrentMutant == None || mutantGame.CurrentMutant == B || mutantGame.CurrentBottomFeeder == B )
		return Super.FindNewEnemyFor(B, bSeeEnemy);

	OldEnemy = B.Enemy;
	
	MutantPawn = mutantGame.CurrentMutant.Pawn;

	if(MutantPawn != None)
	{
		if ( VSize(MutantPawn.Location - B.Pawn.Location) < 1500 )
			bSeeEnemy = B.LineOfSightTo(MutantPawn);
		else
			bSeeEnemy = B.CanSee(MutantPawn);	// only if looking at him
	}
	B.Enemy = MutantPawn;

	if(OldEnemy != MutantPawn)
	{
		B.EnemyChanged(bSeeEnemy);
		return true;
	}

	return false;
}

function bool AssignSquadResponsibility(Bot B)
{
	local xMutantGame mutantGame;
	local pawn mutantPawn;

	mutantGame = xMutantGame(Level.Game);

	// If there is a mutant (and I'm not it)
	if(mutantGame.CurrentMutant != None && mutantGame.CurrentMutant != B)
	{
		mutantPawn = mutantGame.CurrentMutant.Pawn;

		// If I'm not the bottom feeder but i'm hunting someone, it can only be the mutant.
		if(B.Enemy != None && mutantGame.CurrentBottomFeeder != B && B.Enemy != mutantPawn)
		{
			FindNewEnemyFor(B, false);
		}
	}

	return Super.AssignSquadResponsibility(B);
}

defaultproperties
{
}
