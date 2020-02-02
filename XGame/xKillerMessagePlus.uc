class xKillerMessagePlus extends LocalMessage;

var(Message) localized string YouKilled;
var(Message) localized string YouKilledTrailer;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	if (RelatedPRI_1 == None)
		return "";
	if (RelatedPRI_2 == None)
		return "";

	if (RelatedPRI_2.PlayerName != "")
		return Default.YouKilled@RelatedPRI_2.PlayerName@Default.YouKilledTrailer;
}

defaultproperties
{
     YouKilled="You killed"
     bIsUnique=True
     bFadeMessage=True
     DrawColor=(G=160,R=0)
     StackMode=SM_Down
     PosY=0.100000
}
