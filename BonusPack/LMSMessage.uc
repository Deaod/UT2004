// ====================================================================
//  Class: BonusPack.LMSMessage
//
//  For displaying localized messages related to the Last Man Standing game type.
//
//  Written by James Golding
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

#exec OBJ LOAD FILE=TauntPack.uax

class LMSMessage extends LocalMessage;

var	localized string 	YouAreCamperMessage;
var			  sound		YouAreCamperSound;	// OBSOLETE

var localized string 	SomeoneIsCamperMessage;
var localized string 	SomeoneIsCamperMessageTrailer;
var			  sound		SomeoneIsCamperSound;	// OBSOLETE

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	switch(SwitchNum)
	{
	case 0: // You are a camper
		return Default.YouAreCamperMessage;

	case 1: // Someone is a camper
		if (RelatedPRI_1 == None)
			 return "";

		return Default.SomeoneIsCamperMessage@RelatedPRI_1.PlayerName@Default.SomeoneIsCamperMessageTrailer@"("$RelatedPRI_1.GetLocationName()$")";
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
	case 0: // You are a camper
		if(Default.YouAreCamperSound != None)
			P.PlayStatusAnnouncement('Camper', 1, true);
		break;
	}
}

defaultproperties
{
     YouAreCamperMessage="You Are Camping!"
     SomeoneIsCamperMessage=" "
     SomeoneIsCamperMessageTrailer="Is Camping!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=6
     DrawColor=(B=128,G=0)
     StackMode=SM_Down
     PosY=0.100000
}
