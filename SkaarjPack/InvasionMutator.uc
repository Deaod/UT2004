class InvasionMutator extends DMMutator
	HideDropDown
	CacheExempt;


function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	// set bSuperRelevant to false if want the gameinfo's super.IsRelevant() function called
	// to check on relevancy of this actor.

	bSuperRelevant = 0;
	if ( Pawn(Other) != None )
	{
		Pawn(Other).bAutoActivate = true;
	}
	else if ( GameObjective(Other) != None )
    {
		Other.bHidden = true;
		GameObjective(Other).bDisabled = true;
		GameObjective(Other).DefenderTeamIndex = 255;
		GameObjective(Other).StartTeam = 255;
		Other.SetCollision(false,false,false);
	}
	else if ( GameObject(Other) != None )
		return false;
	return true;
}

defaultproperties
{
}
