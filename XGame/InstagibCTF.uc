class InstagibCTF extends xCTFGame;

var globalconfig bool bZoomInstagib;
var globalconfig bool bAllowBoost;
var globalconfig bool bLowGrav;
var localized string ZoomDisplayText, ZoomDescText;


static function bool AllowMutator( string MutatorClassName )
{
	if ( MutatorClassName == "" )
		return false;

	if ( static.IsVehicleMutator(MutatorClassName) )
		return false;
	if ( MutatorClassName ~= "xGame.MutInstagib" )
		return false;
	if ( MutatorClassName ~= "xGame.MutZoomInstagib" )
		return false;

	return super.AllowMutator(MutatorClassName);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.RulesGroup, "bAllowBoost", class'MutInstagib'.default.BoostDisplayText, 0, 1, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bZoomInstagib", default.ZoomDisplayText, 0, 1, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bLowGrav", class'MutLowGrav'.default.Description, 0, 1, "Check");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bAllowBoost":			return class'MutInstagib'.default.BoostDescText;
		case "bZoomInstagib":		return default.ZoomDescText;
		case "bLowGrav":			return class'MutLowGrav'.default.Description;
	}

	return Super.GetDescriptionText(PropName);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ( InStr(PropertyName, "bWeaponStay") != -1 )
		return false;
	if ( InStr(PropertyName, "bAllowWeaponThrowing") != -1 )
		return false;

	return Super.AcceptPlayInfoProperty(PropertyName);
}

defaultproperties
{
     bAllowBoost=True
     ZoomDisplayText="Allow Zoom"
     ZoomDescText="Instagib rifles have sniper scopes."
     bAllowTrans=False
     bDefaultTranslocator=False
     MutatorClass="xGame.InstagibMutator"
     GameName="Instagib CTF"
     DecoTextName="XGame.InstagibCTF"
     Acronym="ICTF"
}
