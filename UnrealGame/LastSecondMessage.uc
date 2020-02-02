class LastSecondMessage extends CriticalEventPlus;

var(Message) localized string LastSecondRed, LastSecondBlue;

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	if ( Switch == 1 )
		P.PlayRewardAnnouncement('Denied',1, true);
	else
		P.PlayStatusAnnouncement('Last_Second_Save',1, true);
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( TeamInfo(OptionalObject) == None )
		return "";
	if ( TeamInfo(OptionalObject).TeamIndex == 0 ) 
		return Default.LastSecondRed;
	else
		return Default.LastSecondBlue;
}

defaultproperties
{
     LastSecondRed="Last second save by Red!"
     LastSecondBlue="Last second save by Blue!"
     StackMode=SM_Down
     PosY=0.100000
}
