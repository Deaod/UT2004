// ====================================================================
//  Class: BonusPack.MutLastManStanding
//
//	Used to remove weapons from the level.
//
//  Written by James Golding
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class MutLastManStanding extends DMMutator
	HideDropDown
	CacheExempt;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local xLastManStandingGame LMSGame;

	LMSGame = xLastManStandingGame(Level.Game);

	if(LMSGame == None)
	{
		Log("Should only use MutLastManStanding with xLastManStandingGame game type.");
		bSuperRelevant = 0;
		return true;
	}

	// Remove conventional weapon pickups. Leave super weapons, all ammo etc.
	if ( Other.IsA('Pickup') )
	{
    	if (!LMSGame.bAllowPickups)
	    	return !Level.bStartup;

		if (Other.IsA('AdrenalinePickup') && !LMSGame.bAllowAdrenaline)
        	return false;

		if( Other.IsA('WeaponPickup') )
		{
			if( LMSGame.bAllowSuperweapons && (Other.IsA('PainterPickup') || Other.IsA('RedeemerPickup')) )
			{
				bSuperRelevant = 0;
				return true;
			}
			else
				return !Level.bStartup;
		}
		else
		{
			bSuperRelevant = 0;
			return true;
		}
	}

	// Hide all weapon bases apart from super weapons
	if ( Other.IsA('xPickupBase') )
	{
		if ( Other.IsA('xWeaponBase') )
        {
            if( LMSGame.bAllowSuperweapons && (xWeaponBase(Other).WeaponType == class'Painter' || xWeaponBase(Other).WeaponType == class'Redeemer') )
                Other.bHidden = false;
            else
                Other.bHidden = true;
        }
        else if (!LMSGame.bAllowPickups)
        	Other.bHidden = true;

	}

	bSuperRelevant = 0;
	return true;
}

defaultproperties
{
}
