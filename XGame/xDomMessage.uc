//=============================================================================
// xDomMessage.
//=============================================================================
class xDomMessage extends LocalMessage;

var(Message) localized string YouControlBothPointsString;
var(Message) localized string EnemyControlsBothPointsString;
var(Message) color RedColor, BlueColor;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	if (Switch == 0)
		return Default.RedColor;
	else
		return Default.BlueColor;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 0:
			return Default.YouControlBothPointsString;
			break;

		case 1:
			return Default.EnemyControlsBothPointsString;
			break;
	}
	return "";
}

defaultproperties
{
     YouControlBothPointsString="Your team controls both points!"
     EnemyControlsBothPointsString="The enemy controls both points!"
     RedColor=(G=255,R=255,A=255)
     BlueColor=(G=255,R=255,A=255)
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=1
     DrawColor=(G=160,R=0)
     StackMode=SM_Down
     PosY=0.100000
     FontSize=1
}
