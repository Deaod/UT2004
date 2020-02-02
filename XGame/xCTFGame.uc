//=============================================================================
// xCTFGame.
//=============================================================================
class xCTFGame extends CTFGame
    config;

#exec OBJ LOAD FILE=GameSounds.uax
#exec OBJ LOAD File=XGameShadersB.utx

static function PrecacheGameTextures(LevelInfo myLevel)
{
	class'xTeamGame'.static.PrecacheGameTextures(myLevel);
}

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
	class'xDeathMatch'.static.PrecacheGameStaticMeshes(myLevel);
}


function actor FindSpecGoalFor(PlayerReplicationInfo PRI, int TeamIndex)
{
	local XPlayer PC;
    local Controller C;
    local CTFFlag Flags[2],F;

    PC = XPlayer(PRI.Owner);
    if (PC==None)
    	return none;

    // Look for a Player holding the flag


    for (C=Level.ControllerList;C!=None;C=C.NextController)
    {
    	if ( (C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo.HasFlag!=None)
    		&& (PC.ViewTarget == None || PC.ViewTarget != C.Pawn) )
        	return C.Pawn;
    }

	foreach AllActors(class'CTFFlag',f)
    	Flags[f.TeamNum]=f;

    if ( vsize(PC.Location - Flags[0].Location) < vsize(PC.Location - Flags[1].Location) )
    	return Flags[1];
    else
    	return Flags[0];

    return none;

}

event SetGrammar()
{
	LoadSRGrammar("CTF");
}

defaultproperties
{
     DefaultEnemyRosterClass="xGame.xTeamRoster"
     HUDType="XInterface.HudCCaptureTheFlag"
     MapListType="XInterface.MapListCaptureTheFlag"
     DeathMessageClass=Class'XGame.xDeathMessage'
     OtherMesgGroup="CTFGame"
     GameName="Capture the Flag"
     ScreenShotName="UT2004Thumbnails.CTFShots"
     DecoTextName="XGame.CTFGame"
     Acronym="CTF"
}
