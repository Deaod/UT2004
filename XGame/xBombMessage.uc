//=============================================================================
// BombMessage.
//=============================================================================
class xBombMessage extends CriticalEventPlus;

var(Message) localized string ReturnBlue, ReturnRed;
var(Message) localized string ReturnedBlue, ReturnedRed;
var(Message) localized string CaptureBlue, CaptureRed;
var(Message) localized string DroppedBlue, DroppedRed;
var(Message) localized string HasBlue,HasRed;

var sound	ReturnSounds[2];  // OBSOLETE
var sound	DroppedSounds[2]; // OBSOLETE
var Sound	TakenSounds[2];   // OBSOLETE
var sound	Riffs[3];

var name	ReturnSoundNames[2];  
var name	DroppedSoundNames[2];
var name	TakenSoundNames[2];

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Switch == 3 )
		P.PlayStatusAnnouncement(default.ReturnSoundNames[0],1, true);

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	if ( TeamInfo(OptionalObject) == None )
		return;

	switch (Switch)
	{
		case 0:
			P.ClientPlaySound(Default.Riffs[Rand(3)]);
			break;
		// Returned the flag.
		case 1:
		case 3:
		case 5:
			P.PlayStatusAnnouncement(default.ReturnSoundNames[TeamInfo(OptionalObject).TeamIndex],1, true);
			break;

		// Dropped the flag.
		case 2:
			P.PlayStatusAnnouncement(default.DroppedSoundNames[TeamInfo(OptionalObject).TeamIndex],2, true);
			break;
		case 4:
		case 6:
			P.PlayStatusAnnouncement(default.TakenSoundNames[TeamInfo(OptionalObject).TeamIndex],2, true);
			break;
	}
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
		// Captured the flag.
		case 0:
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.PlayerName@Default.CaptureBlue;
			break;

		// Returned the flag.
		case 1:
			if (RelatedPRI_1 == None)
				return Default.ReturnedBlue;
			return RelatedPRI_1.playername@Default.ReturnBlue;
			break;

		// Dropped the flag.
		case 2:
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.playername@Default.DroppedBlue;
			break;

		// Was returned.
		case 3:
			return Default.ReturnedBlue;
			break;

		// Has the flag.
		case 4:
			if (RelatedPRI_1 == None)
				return "";
			return RelatedPRI_1.playername@Default.HasBlue;
			break;

		// Auto send home.
		case 5:
			return Default.ReturnedBlue;
			break;

		// Pickup
		case 6:
			if (RelatedPRI_1 == None)
				return "";
			return RelatedPRI_1.playername@Default.HasBlue;
			break;
	}
	return "";
}

defaultproperties
{
     ReturnBlue="returns the ball!"
     ReturnRed="returns the ball!"
     ReturnedBlue="The ball was returned!"
     ReturnedRed="The ball was returned!"
     CaptureBlue="scored the goal!"
     CaptureRed="scored the goal!"
     DroppedBlue="dropped the ball!"
     DroppedRed="dropped the ball!"
     HasBlue="has the ball!"
     HasRed="has the ball!"
     Riffs(0)=Sound'GameSounds.Fanfares.UT2K3Fanfare03'
     Riffs(1)=Sound'GameSounds.Fanfares.UT2K3Fanfare07'
     Riffs(2)=Sound'GameSounds.Fanfares.UT2K3Fanfare08'
     ReturnSoundNames(0)="BallReset"
     ReturnSoundNames(1)="BallReset"
     DroppedSoundNames(0)="Red_Pass_Fumbled"
     DroppedSoundNames(1)="Blue_Pass_Fumbled"
     TakenSoundNames(0)="Red_Team_on_Offence"
     TakenSoundNames(1)="Blue_Team_on_Offence"
     StackMode=SM_Down
     PosY=0.100000
}
