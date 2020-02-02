//
// CTF Messages
//
// Switch 0: Capture Message
//	RelatedPRI_1 is the scorer.
//	OptionalObject is the flag.
//
// Switch 1: Return Message
//	RelatedPRI_1 is the scorer.
//	OptionalObject is the flag.
//
// Switch 2: Dropped Message
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.
//	
// Switch 3: Was Returned Message
//	OptionalObject is the flag's team teaminfo.
//
// Switch 4: Has the flag.
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 5: Auto Send Home.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 6: Pickup stray.
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.

class CTFMessage extends CriticalEventPlus;

#exec OBJ LOAD FILE=GameSounds.uax

var(Message) localized string ReturnBlue, ReturnRed;
var(Message) localized string ReturnedBlue, ReturnedRed;
var(Message) localized string CaptureBlue, CaptureRed;
var(Message) localized string DroppedBlue, DroppedRed;
var(Message) localized string HasBlue,HasRed;

var sound	ReturnSounds[2]; // OBSOLETE
var sound	DroppedSounds[2]; // OBSOLETE
var Sound	TakenSounds[2]; // OBSOLETE
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
			P.PlayStatusAnnouncement(default.ReturnSoundNames[TeamInfo(OptionalObject).TeamIndex],2, true);
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
	if ( TeamInfo(OptionalObject) == None )
		return "";
	switch (Switch)
	{
		// Captured the flag.
		case 0:
			if (RelatedPRI_1 == None)
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) 
				return RelatedPRI_1.PlayerName@Default.CaptureRed;
			else
				return RelatedPRI_1.PlayerName@Default.CaptureBlue;
			break;

		// Returned the flag.
		case 1:
			if (RelatedPRI_1 == None)
			{
				if ( TeamInfo(OptionalObject).TeamIndex == 0 ) 
					return Default.ReturnedRed;
				else
					return Default.ReturnedBlue;
			}
			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) 
				return RelatedPRI_1.PlayerName@Default.ReturnRed;
			else
				return RelatedPRI_1.playername@Default.ReturnBlue;
			break;

		// Dropped the flag.
		case 2:
			if (RelatedPRI_1 == None)
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) 
				return RelatedPRI_1.playername@Default.DroppedRed;
			else
				return RelatedPRI_1.playername@Default.DroppedBlue;
			break;

		// Was returned.
		case 3:
			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) 
				return Default.ReturnedRed;
			else
				return Default.ReturnedBlue;
			break;

		// Has the flag.
		case 4:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) 
				return RelatedPRI_1.playername@Default.HasRed;
			else
				return RelatedPRI_1.playername@Default.HasBlue;
			break;

		// Auto send home.
		case 5:
			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) 
				return Default.ReturnedRed;
			else
				return Default.ReturnedBlue;
			break;

		// Pickup
		case 6:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject).TeamIndex == 0 ) 
				return RelatedPRI_1.playername@Default.HasRed;
			else
				return RelatedPRI_1.playername@Default.HasBlue;
			break;
	}
	return "";
}

defaultproperties
{
     ReturnBlue="returned the blue flag!"
     ReturnRed="returned the red flag!"
     ReturnedBlue="The blue flag was returned!"
     ReturnedRed="The red flag was returned!"
     CaptureBlue="captured the blue flag!"
     CaptureRed="captured the red flag!"
     DroppedBlue="dropped the blue flag!"
     DroppedRed="dropped the red flag!"
     HasBlue="took the blue flag!"
     HasRed="took the red flag!"
     Riffs(0)=Sound'GameSounds.Fanfares.UT2K3Fanfare01'
     Riffs(1)=Sound'GameSounds.Fanfares.UT2K3Fanfare04'
     Riffs(2)=Sound'GameSounds.Fanfares.UT2K3Fanfare06'
     ReturnSoundNames(0)="Red_Flag_Returned"
     ReturnSoundNames(1)="Blue_Flag_Returned"
     DroppedSoundNames(0)="Red_Flag_Dropped"
     DroppedSoundNames(1)="Blue_Flag_Dropped"
     TakenSoundNames(0)="Red_Flag_Taken"
     TakenSoundNames(1)="Blue_Flag_Taken"
     StackMode=SM_Down
     PosY=0.100000
}
