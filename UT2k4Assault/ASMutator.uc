class ASMutator extends DMMutator
	HideDropDown
	CacheExempt;

function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('AdrenalinePickup') )
	{
    	bSuperRelevant = 0;
		return false;
	}
	if ( Controller(Other) != None && MessagingSpectator(Other) == None )
	{
		Controller(Other).bAdrenalineEnabled = false;
		Controller(Other).PlayerReplicationInfoClass = class'ASPlayerReplicationInfo';
	}

	return Super.IsRelevant(Other, bSuperRelevant);
}

defaultproperties
{
}
