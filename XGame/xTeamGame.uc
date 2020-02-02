//=============================================================================
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
//=============================================================================
class xTeamGame extends TeamGame;

#exec OBJ LOAD FILE=TeamSymbols.utx				// needed right now for Link symbols, etc.

static function PrecacheGameTextures(LevelInfo myLevel)
{
	class'xDeathMatch'.static.PrecacheGameTextures(myLevel);

	myLevel.AddPrecacheMaterial(Material'TeamSymbols.TeamBeaconT');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.LinkBeaconT');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.RedShell');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.BlueShell');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.soundBeacon_a00');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.soundBeacon_a01');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.soundBeacon_a02');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.soundBeacon_a03');
}

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
	class'xDeathMatch'.static.PrecacheGameStaticMeshes(myLevel);
}

defaultproperties
{
     DefaultEnemyRosterClass="xGame.xTeamRoster"
     HUDType="XInterface.HudCTeamDeathMatch"
     MapListType="XInterface.MapListTeamDeathMatch"
     DeathMessageClass=Class'XGame.xDeathMessage'
     GameName="Team DeathMatch"
     ScreenShotName="UT2004Thumbnails.TDMShots"
     DecoTextName="XGame.TeamGame"
     Acronym="TDM"
}
