class SPECIES_Merc extends SPECIES_Human
	abstract;


static function string GetRagSkelName(string MeshName)
{
	if(InStr(MeshName, "Gitty") >= 0)
		return Default.FemaleRagSkelName;
	if(InStr(MeshName, "Ophelia") >= 0)
		return Default.FemaleRagSkelName;
	
	return Super.GetRagSkelName(MeshName);
}

defaultproperties
{
     MaleSoundGroup="XGame.xMercMaleSoundGroup"
     FemaleSoundGroup="XGame.xMercFemaleSoundGroup"
     SpeciesName="Mercenary"
     RaceNum=4
}
