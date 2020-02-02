class xVictimMessage extends LocalMessage;

var(Message) localized string YouWereKilledBy, KilledByTrailer;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	if (RelatedPRI_1 == None)
		return "";

	if (RelatedPRI_1.PlayerName != "")
		return Default.YouWereKilledBy@RelatedPRI_1.PlayerName$Default.KilledByTrailer;
}

defaultproperties
{
     YouWereKilledBy="You were killed by"
     KilledByTrailer="!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=6
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.100000
}
