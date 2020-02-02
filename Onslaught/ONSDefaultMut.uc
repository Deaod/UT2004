class ONSDefaultMut extends DMMutator
	HideDropDown
	CacheExempt;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Controller(Other) != None && MessagingSpectator(Other) == None)
	{
		Controller(Other).bAdrenalineEnabled = false;
		Controller(Other).PlayerReplicationInfoClass = class'ONSPlayerReplicationInfo';
	}
	else if (Other.IsA('AdrenalinePickup'))
		return false;

	return true;
}

defaultproperties
{
}
