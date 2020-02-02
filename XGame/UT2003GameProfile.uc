class UT2003GameProfile extends GameProfile;

/*
 * This class is a concrete subclass of GameProfile that
 * refers directly to the UT2003 ladder.
 *
 * author: capps 8/20/02
 */

// completely overrides GameProfile
function ContinueSinglePlayerGame(LevelInfo level, optional bool bReplace)
{
	local Controller C;
	local PlayerController PC;

	// set character, player in current game
	PC = none;
	for ( C=level.ControllerList; C!=None; C=C.NextController ) 
	{
		if ( PlayerController(C) != None ) {
			PC = PlayerController(C);
			break;		
		}
	}
	if ( PC == none ) {
		return;
	}

	if (level.game.SavePackage(PackageName)) {
		Log("SINGLEPLAYER UT2003GameProfile::ContinueSinglePlayerGame() saved profile.");
	} else {
		Log("SINGLEPLAYER UT2003GameProfile::ContinueSinglePlayerGame() save profile FAILED.");
	}

	PC.ConsoleCommand("disconnect");
	if ( bReplace ) 
		PC.Player.GUIController.ReplaceMenu("xInterface.UT2SinglePlayerMain");				
	else
		PC.Player.GUIController.OpenMenu("xInterface.UT2SinglePlayerMain");				
}

defaultproperties
{
     TeamSymbolName="TeamSymbols_UT2003.sym01"
     SalaryCap=3500
     ladderrung(0)=1
     GameLadderName="xGame.UT2003LadderInfo"
}
