//=============================================================================
// MutMovementModifier.
//=============================================================================

class MutMovementModifier extends Mutator
	config;

var() globalconfig bool bMegaSpeed;
var() globalconfig float AirControl;

function ModifyPlayer(Pawn Other)
{
	Other.AirControl = AirControl;
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting(default.RulesGroup,  "AirControl", class'DMMutator'.default.DMMutPropsDisplayText[1], 0, 1, "Text", "8;0.1:10.0");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "AirControl":	return class'DMMutator'.default.DMMutDescText[1];
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     AirControl=0.350000
     FriendlyName="Air Control"
     Description="Change how players move in the air."
}
