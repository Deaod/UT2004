class ActionMessage extends CriticalEventPlus;

var localized string Messages[32];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.Messages[Switch];
}

defaultproperties
{
     Lifetime=8
     DrawColor=(B=0,G=255,R=255)
     PosY=0.850000
     FontSize=0
}
