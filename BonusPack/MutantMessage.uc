// ====================================================================
//  Class: BonusPack.MutantMessage
//
//  For displaying localized messages related to the Mutant game type.
//
//  Written by James Golding
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

#exec OBJ LOAD FILE=GameSounds.uax

class MutantMessage extends LocalMessage;

var	localized string 	YouAreMutantMessage;

var localized string 	SomeoneIsMutantMessage;
var localized string 	SomeoneIsMutantMessageTrailer;
var localized string    FFAMessage;
var localized string    BottomFeederMessage;
var localized string    NotBottomFeederMessage;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	switch(SwitchNum)
	{
	case 0: // You are the Mutant
		return Default.YouAreMutantMessage;

	case 1: // Someone is the Mutant
		if (RelatedPRI_1 == None)
			 return "";

		return Default.SomeoneIsMutantMessage@RelatedPRI_1.PlayerName@Default.SomeoneIsMutantMessageTrailer;

	case 2: // First blood becomes Mutant!
		return Default.FFAMessage;

	case 3: // You are the Bottom Feeder!
		return Default.BottomFeederMessage;

	case 4: // No longer Bottom Feeder!
		return Default.NotBottomFeederMessage;
	}
}

static simulated function ClientReceive( 
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	switch(SwitchNum)
	{
	case 0: // You are the Mutant
		P.PlayStatusAnnouncement('you_have_mutated', 1, true);
		break;

	case 1: // Someone is the Mutant
		P.PlayStatusAnnouncement('new_mutant', 1, true);
		break;

	case 2: // First blood becomes Mutant!
		P.PlayAnnouncement(sound'GameSounds.UT2K3Fanfare11', 1, true);
		break;

	case 3: // You are the Bottom Feeder!
		P.PlayStatusAnnouncement('bottom_feeder', 1, true);
		break;

	case 4: // No longer Bottom Feeder!
		P.PlayAnnouncement(sound'GameSounds.UT2K3Fanfare08', 1, true);
		break;
	}
}

defaultproperties
{
     YouAreMutantMessage="You Have Mutated!"
     SomeoneIsMutantMessage=" "
     SomeoneIsMutantMessageTrailer="Has Mutated!"
     FFAMessage="First Blood Mutates!"
     BottomFeederMessage="You Are The Bottom Feeder!"
     NotBottomFeederMessage="No Longer Bottom Feeder!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=6
     DrawColor=(B=128,G=0)
     StackMode=SM_Down
     PosY=0.242000
}
