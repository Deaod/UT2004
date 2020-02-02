class MutFastWeapSwitch extends Mutator;

auto state Startup
{
	function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
	{
		bSuperRelevant = 0;
		if ( GameReplicationInfo(Other) != None )
		{
			GameReplicationInfo(Other).bFastWeaponSwitching = true;
			GotoState('');
		}
		if ( xPawn(Other) != None )
			xPawn(Other).bCanBoostDodge = true;
		return true;
	}
}

defaultproperties
{
     GroupName="WeapSwitch"
     FriendlyName="UT2003 Style"
     Description="UT2003 style fast weapon switching and boost dodging."
}
