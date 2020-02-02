// Onslaught Link Designer and link setup related messages

class ONSLinkDesignMessage extends LocalMessage;

var(String) localized string SetupString, SaveSetupString, LoadSetupString, SaveFailedString, LoadFailedString, DeleteSetupString,
			DeleteOfficialFailedString, DeleteNothingString, NoPathToPowerCoreString, LoadFailedNoPathToCoreString;

static function ClientReceive(	PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if (Switch == 7)
		P.ClientOpenMenu("GUI2K4.UT2K4GenericMessageBox",,, default.NoPathToPowerCoreString);
	else if (Switch == 8)
		P.ClientOpenMenu("GUI2K4.UT2K4GenericMessageBox",,, default.LoadFailedNoPathToCoreString);
	else
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

static function color GetConsoleColor(PlayerReplicationInfo RelatedPRI_1)
{
	return class'HUD'.Default.WhiteColor;
}

static function string GetString( optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2,
			 optional Object OptionalObject )
{
	switch (Switch)
	{
	case 0:
		return Default.SaveSetupString;
	case 1:
		return Default.SaveFailedString;
	case 2:
		return Default.LoadSetupString;
	case 3:
		return Default.LoadFailedString;
	case 4:
		return Default.DeleteSetupString;
	case 5:
		return Default.DeleteOfficialFailedString;
	case 6:
		return Default.DeleteNothingString;
	}
}

defaultproperties
{
     SaveSetupString="Successfully saved Link Setup."
     LoadSetupString="Successfully loaded Link Setup."
     SaveFailedString="You can't overwrite official Link Setups!"
     LoadFailedString="Failed to load Link Setup because no setup of that name exists."
     DeleteSetupString="Successfully deleted Link Setup."
     DeleteOfficialFailedString="You can't delete official Link Setups!"
     DeleteNothingString="Failed to delete Link Setup because no setup of that name exists."
     NoPathToPowerCoreString="Cannot save Link Setup: There must be a complete path between the PowerCores."
     LoadFailedNoPathToCoreString="Failed to load Link Setup because it does not have a complete path between the PowerCores."
     bIsSpecial=False
}
