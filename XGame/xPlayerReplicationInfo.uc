class xPlayerReplicationInfo extends TeamPlayerReplicationInfo;

var xUtil.PlayerRecord Rec;

var bool bForceNoPlayerLights;  // OBSOLETE
var bool bNoTeamSkins; //OBSOLETE

simulated function UpdatePrecacheMaterials()
{
	if ( CharacterName == "" )
		return;
    rec = class'xUtil'.static.FindPlayerRecord(CharacterName);
	if ( rec.Species != None )
	{
		if ( Team == None )
			rec.Species.static.LoadResources(rec, Level,self,255);
		else
			rec.Species.static.LoadResources(rec, Level,self,Team.TeamIndex);
	}
}

simulated function SetCharacterName(string S)
{
	Super.SetCharacterName(S);
	UpdateCharacter();
}

simulated event UpdateCharacter()
{
    Rec = class'xUtil'.static.FindPlayerRecord(CharacterName);
}

simulated function material GetPortrait()
{
	if ( Rec.Portrait == None )
		return Material(DynamicLoadObject("PlayerPictures.cDefault", class'Material'));
	return Rec.Portrait;
}

defaultproperties
{
}
