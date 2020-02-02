//warning message for players in an IonCannonKillVolume that they're about to be vaporized
class IonCannonKillWarning extends CriticalEventPlus;

var() localized string CountDownTrailer, WarningString;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	if (Switch > 0)
		return Switch$default.CountDownTrailer;
	else
		return default.WarningString;
}

static function GetPos(int Switch, out EDrawPivot OutDrawPivot, out EStackMode OutStackMode, out float OutPosX, out float OutPosY)
{
	Super.GetPos(Switch, OutDrawPivot, OutStackMode, OutPosX, OutPosY);

	if (Switch == 0)
		OutPosY = 0.75;
}

defaultproperties
{
     CountDownTrailer="..."
     WarningString="You have been targeted by an orbital Ion Satellite!"
     bIsUnique=False
     bIsPartiallyUnique=True
     Lifetime=1
}
