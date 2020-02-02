class MutLightweightVehicles extends Mutator;

var config float VehicleMomentumMult;
var localized string DisplayText, DescText;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Vehicle(Other) != None)
		Vehicle(Other).MomentumMult *= VehicleMomentumMult;

	return true;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.RulesGroup, "VehicleMomentumMult", default.DisplayText, 0, 1, "Text", "4;2:10");
}

static event string GetDescriptionText(string PropName)
{
	if (PropName == "VehicleMomentumMult")
		return default.DescText;

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     VehicleMomentumMult=3.000000
     DisplayText="Momentum Multiplier"
     DescText="Vehicles get this many times as much momentum from damage"
     FriendlyName="Lightweight Vehicles"
     Description="Vehicles fly farther when you hit them."
}
