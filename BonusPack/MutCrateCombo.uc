class MutCrateCombo extends Mutator;

var xPlayer NotifyPlayer[32];
var config bool bAllowCamouflage;
var config bool bAllowPint;
var localized string CamoDisplayText, MiniDisplayText, CamoDescText, MiniDescText;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.RulesGroup, "bAllowCamouflage", default.CamoDisplayText, 0, 1, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bAllowPint", default.MiniDisplayText, 0, 1, "Check");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bAllowCamouflage":	return default.CamoDescText;
		case "bAllowPint":			return default.MiniDescText;
	}

	return Super.GetDescriptionText(PropName);
}

function Timer()
{
	local int i;

	for ( i=0; i<32; i++ )
		if ( NotifyPlayer[i] != None )
		{
			NotifyPlayer[i].ClientReceiveCombo("Bonuspack.ComboCrate");
			NotifyPlayer[i].ClientReceiveCombo("Bonuspack.ComboMiniMe");
			NotifyPlayer[i] = None;
		}
}

function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
	local int i;

	if ( xPlayer(Other) != None )
	{
		for ( i=0; i<16; i++ )
		{
			if ( xPlayer(Other).ComboNameList[i] ~= "Bonuspack.ComboCrate" )
				break;
			else if ( xPlayer(Other).ComboNameList[i] == "" )
			{
				xPlayer(Other).ComboNameList[i] = "Bonuspack.ComboCrate";
				break;
			}
		}
		for ( i=0; i<16; i++ )
		{
			if ( xPlayer(Other).ComboNameList[i] ~= "Bonuspack.ComboMiniMe" )
				break;
			else if ( xPlayer(Other).ComboNameList[i] == "" )
			{
				xPlayer(Other).ComboNameList[i] = "Bonuspack.ComboMiniMe";
				break;
			}
		}
		for ( i=0; i<32; i++ )
			if ( NotifyPlayer[i] == None )
			{
				NotifyPlayer[i] = xPlayer(Other);
				SetTimer(0.5, false);
				break;
			}
	}
	if ( NextMutator != None )
		return NextMutator.IsRelevant(Other, bSuperRelevant);
	else
		return true;
}

defaultproperties
{
     bAllowCamouflage=True
     bAllowPint=True
     CamoDisplayText="Camouflage Combo"
     MiniDisplayText="Pint-sized Combo"
     CamoDescText="When enabled, this adrenaline combo covers you with a holographic projection of a rock or a part of a building"
     MiniDescText="When enabled, this adrenaline combo makes you smaller"
     FriendlyName="Bonus Combos"
     Description="Adds the Pint-sized combo (LLLL) and the Camouflage Combo (RRRR)."
}
